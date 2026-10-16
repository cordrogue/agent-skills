# Harness tools

These skills run in Claude Code and in Codex. Skill text names Claude Code tools, and in Codex only the tool names change. Model choice is in [`models.md`](models.md).

## Tool actions

| Claude Code | Codex |
|---|---|
| Read a file (`Read`) | Shell (`cat`, `sed -n`, `head`) |
| Edit or create a file (`Edit`, `Write`) | `apply_patch` |
| Run a command (`Bash`) | Shell |
| Search (`Grep`, `Glob`) | Shell (`rg`, `find`) |
| Invoke a skill (`Skill` tool, `/<name>`) | Skills load natively. Read `.agents/skills/<name>/SKILL.md` by path when a skill names another. |
| Spawn a subagent (`Agent`) | `spawn_agent` |
| Several subagents at once | Several `spawn_agent` calls in one response |
| Wait for a subagent | `wait_agent` |
| Track tasks (todo list) | `update_plan` |
| Ask the user (`AskUserQuestion`) | Ask in chat and wait for the answer |
| Background command (`Bash` with `run_in_background: true`) | Exec session. Keep the session id and poll it. |
| Recurring wake (background Bash `sleep <interval>` with `run_in_background`, re-armed as the last step of every tick) | In T3 Code, `schedule_task` bound to the thread, per `playbooks/autonomous-run.md` step 2; probed from a Claude thread only. Outside T3 Code, none verified: tell the operator unattended monitoring is unavailable, and wait on running work with bounded `wait_agent` calls or exec polls. |

"The todolist" means the todo tool in Claude Code and `update_plan` in Codex. With neither, keep the list as a checklist file beside the decision trail and tick it there.

`how`, `why`, `unslop`, and `typescript-best-practices` stay model-invocable so `poteto-mode` and other skills can load them by name. `disable-model-invocation: true` would hide them from the Skill tool in Claude Code.

## Subagents

- **Claude Code.** Call `Agent` with `subagent_type: "poteto-agent"` for a helper inside a playbook step, with `model` and `effort` per `models.md` and `run_in_background: true`. A Sol lane goes through T3 Code's `delegate_task` or `codex exec`, per `models.md`. A routed skill (`how`, `why`, `interrogate`, `thermos`, `reflect`, `swarm`, `arena`, `architect`) sets its own lanes.
- **Codex.** There are no named agent types. Call `spawn_agent` and start its instructions with "Read `.agents/skills/poteto-mode/SKILL.md` in full first." Subagents need `multi_agent = true` under `[features]` in `~/.codex/config.toml`.
- **Read-only lanes.** `Agent` has no read-only flag, and Codex lanes, `delegate_task` lanes included, run with full access in the calling thread's worktree ([`models.md`](models.md#claude-parent-to-sol-through-t3-code)). Say "read-only, do not modify files" in the prompt. A lane that reads a commit gets its own detached worktree, made with `git worktree add --detach <path> <sha>`.
- **Writers.** Give each writer its own worktree, created from local `main` with `git worktree add ../worktrees/<task> -b <branch> main`. The `Agent` tool's `isolation: "worktree"` branches from `origin/main`, which lags local `main` here because work lands locally. If you use it, reset the delegate onto local `main` first.
- **Waiting.** In Claude Code, start each helper and long command in the background, then end the turn. A background Bash notice resumes the agent that started it; an `Agent` helper's goes to the root (Nested helpers). Wait on a command's exit or `exit=` line, never on a side effect such as HEAD moving. In Codex, use `wait_agent` and exec polls. Read a `delegate_task` lane's `task_status` after its notification. To wait on several CLI lanes or on files a command writes, use the `exit=` recipe in [`models.md`](models.md#rules).
- **Nested helpers.** In Claude Code, a helper that an owner subagent starts hands back to the root, not to the owner. The root forwards the result to the owner with SendMessage in one line that names the result's path.
- **Stopping a helper.** In Claude Code, `TaskStop` fails on a task another agent owns, including your own helper after you were resumed. Send the helper a stop order with SendMessage instead. Stop a `delegate_task` lane with `task_cancel`.
- **Owner threads.** A unit owner that runs for hours can be its own top-level T3 thread instead of a subagent, so it waits for its own helpers and its history stays out of the root's context. The playbooks still spawn owners as subagents. F13's owner ran this way, started by the developer in its own thread, and reached merge-ready with Claude Code helpers and `delegate_task` lanes. It passed the 400K context limit without handing off, so an owner that is its own root applies the limit to itself (see `swarm/references/fix-rounds.md`, Fix briefs).
  - `t3_thread_launch` needs a calling thread in Full access. From Auto mode it fails with `capability_denied`.
  - It has no retry key. Give every thread a unique title, such as `<unit> owner r<n>`, and after any error check `t3_thread_list` with `titleContains` before retrying.
  - Make the worktree yourself first with `git worktree add ../worktrees/<unit> -b <branch> main`, commit the brief, and launch with `workspaceStrategy` `existing_worktree`. With `workspaceStrategy` `{ type: worktree, baseRef: main, startFromOrigin: false }`, T3 Code makes `~/.t3/worktrees/main/<name>`, a symlink into `worktrees/`. `git worktree add` links main's `node_modules` through `.githooks/post-checkout` when the lock file matches main's; otherwise hard-link from the worktree whose lock matches (the owner's when the branch changed dependencies). An omitted strategy puts the thread on `main`'s checkout. Uncommitted files are not copied.
  - A launched thread does not wake its launcher. End the owner's brief with a `t3_thread_send` to the root's thread id, `mode: queue`, one line naming the verdict, the head SHA, and the handoff path. Read the owner with `t3_thread_read`, keeping `nextPosition` so each read covers only what is new.
  - Before launching a replacement owner on the same worktree, confirm with `t3_thread_list` that the old thread is idle.
  - To retire an owner, send its last `t3_thread_send`, wait until `t3_thread_list` shows the thread idle, run `git worktree remove`, and confirm with `git worktree list` a minute later. T3 Code checks a removed worktree out again when its thread next runs.
  - Record each owner's thread id in the decision trail.
- **Cost.** A task notification's `subagent_tokens` is the agent's final context size, not its cost. Measure cost with `scripts/agent-cost.mjs <session> [agent]`, which sums usage across the subagent transcripts.

## Scratch

`/tmp` is a 31 GB RAM disk with a per-user quota, and Claude Code keeps its own task output there, so a full `/tmp` also loses command output. Program scratch goes under `~/.cache/agent-swarm/<unit>/`, and every lane and owner exports `TMPDIR` there before its first command.

- A Codex lane gets its `TMPDIR` from the parent, which creates `~/.cache/agent-swarm/<unit>/<lane>/` and puts `TMPDIR=<that folder>` in front of the `codex exec` command. `scripts/swarm/launch.mjs` does this for its lanes.
- Probe scripts and bulky probe data go in the lane worktree's `.tmp-vite/`. Node resolves imports from the script's folder, so a probe in `/tmp` can't import the repo's packages, and `cp -al` from the repo into `/tmp` fails across filesystems.
- A unit's decision trail lives in the repo beside the plan, not in scratch.
- Before deleting scratch, run `node scripts/swarm/archive.mjs ~/.cache/agent-swarm/<unit> docs/work/<program>/handoff/swarm-<unit>`. It copies the notebook: briefs, reports, notes, handoffs, TSV trails, round files, and the screenshots and check or probe scripts they cite, each script renamed to `.txt` so the repo's checks skip it. Logs, data dumps, diffs and listings stay in scratch, and `archive-manifest.tsv` lists each one it skipped. The archive is the whole commit, so a note quotes the output lines its claim rests on. Never delete a folder that a `decisions.tsv` row cites.

## Machine notes

- GNU `tail` rejects `tail -3 a b`. Write `tail -n 3`.
- `/usr/bin/time` and Python Pillow are installed. There is no `bc` or DejaVu font, so use `node -e` for arithmetic and `magick -list font` to pick a font that exists.
- T3 Code sets `ELECTRON_RUN_AS_NODE=1`, and agent shells inherit it. Launch Electron by hand with `env -u ELECTRON_RUN_AS_NODE`.
- Inspect a process with `node scripts/operator/process.mjs <pid>`. It prints parent PID, executable name, start identity and working directory, and leaves out command arguments and environment variables.

## Durable run tools

For a new run's verification, recovery checkpoints and waiting, use the opt-in commands in `docs/humans/operator-tools.md`. Existing hooks remain the landing gate. The tools observe and report; the operator's continuation policy decides whether execution resumes.

## Transcripts

| Harness | Current session | All sessions for this checkout |
|---|---|---|
| Claude Code | `<claude-config-root>/projects/<encoded-cwd>/$CLAUDE_CODE_SESSION_ID.jsonl` | `<claude-config-root>/projects/<encoded-cwd>/*.jsonl` |
| Codex | `~/.codex/sessions/<yyyy>/<mm>/<dd>/rollout-*-$CODEX_THREAD_ID.jsonl` | `~/.codex/sessions/**/rollout-*.jsonl` whose first line has this `cwd` |

`<claude-config-root>` is `CLAUDE_CONFIG_DIR`, or `$HOME/.claude` by default. For another account's session, use its recorded configuration root instead of the current shell's.

`<encoded-cwd>` is the workspace path with each `/` replaced by `-`, so `/home/me/project` becomes `-home-me-project`. Claude Code subagent transcripts sit in `<session-id>/subagents/`. A Codex lane started from Claude Code inherits `CLAUDE_CODE_SESSION_ID`, so use the variable for the harness you run in.

Read only the transcript you need. Globbing across every project or session reads unrelated private chats.

## Instructions file

`AGENTS.md` stays empty, and `scripts/skill-list.test.mjs` enforces it. A standing agent rule goes in the skill an agent reads when it applies, and the rule table `correct` keeps is `repeat-mistakes`. A lasting fact goes in `MEMORY.md`, which `CLAUDE.md` imports and Codex never reads.

## Hooks

Both harnesses run `scripts/agent-hooks/bash-guard.mjs` before each shell command and `scripts/feedback/check.mjs` as a Stop hook, from `.claude/settings.json` and `.codex/hooks.json`. Change both together; `scripts/agent-hooks/hook-parity.test.mjs` checks them.

- Claude Code reads the session's own checkout's `.claude/settings.json`. Codex reads the main checkout's `.codex/hooks.json` even in a linked worktree and runs each hook in the session's folder, so a Codex hook resolves its script from the main checkout.
- Codex runs a project hook only while the developer's approval matches its current text, in interactive sessions and `codex exec` alike. An edit to `.codex/hooks.json` voids the approval. Until the developer approves it again in Codex, Codex runs no repo hook, and `.codex/rules/project.rules` still refuses `pkill -f`, `git stash` and `prettier`.
- `APP_SKIP_STOP_CHECK=1` makes both Stop hooks skip the full check. Opus lanes started from Codex set it and keep the guard, using the `claude -p` command in `models.md`.
