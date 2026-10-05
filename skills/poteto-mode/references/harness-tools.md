# Harness tools

These skills run in Claude Code and in Codex. Skill text names Claude Code tools. In Codex, the same files apply, and only the tool names change. Model choice is in [`models.md`](models.md).

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
| Recurring wake (`/loop`) | None. Re-check at the end of each turn, or use a Codex automation if one exists. |

Where a skill says "the todolist", use the todo tool in Claude Code and `update_plan` in Codex. With neither tool, keep the list as a checklist file beside the decision trail and tick it there.

`how`, `why`, `unslop`, and `typescript-best-practices` stay model-invocable so `poteto-mode` and other skills can load them by name. `disable-model-invocation: true` would hide them from the Skill tool in Claude Code.

## Subagents

- **Claude Code.** Call `Agent` with `subagent_type: "poteto-agent"` for a helper inside a playbook step. Set `model` per `models.md` and `run_in_background: true`. A routed skill (`how`, `why`, `interrogate`, `thermos`, `reflect`, `swarm`, `arena`, `architect`) sets its own lanes.
- **Codex.** There are no named agent types. Call `spawn_agent` and start its instructions with "Read `.agents/skills/poteto-mode/SKILL.md` in full first." Subagents need `multi_agent = true` under `[features]` in `~/.codex/config.toml`.
- **Read-only lanes.** Claude Code has no read-only flag on `Agent`. Say "read-only, do not modify files" in the prompt, or use the read-only command in `models.md`. Codex lanes say the same in the prompt. A lane that reads a commit gets its own detached worktree, made with `git worktree add --detach <path> <sha>`.
- **Writers.** Give each writer its own worktree. Create it from local `main` with `git worktree add ../worktrees/<task> -b <branch> main`. The `Agent` tool's `isolation: "worktree"` branches from `origin/main`, which lags local `main` here because work lands locally. If you use it, reset the delegate onto local `main` first.
- Pass file paths, not pasted context. Review every subagent's diff yourself.
- **Waiting.** Start each helper and long command in the background, then end the turn. Its task notification resumes you, in a subagent as well as in the root. To wait on several lanes or on files a command writes, use the `exit=` recipe in [`models.md`](models.md#rules).
- **Stopping a helper.** `TaskStop` fails on a task another agent owns, including your own helper after you were resumed. Send the helper a stop order with SendMessage instead.
- **Cost.** The `subagent_tokens` in a task notification is the agent's final context size, not what it cost. Measure cost with `scripts/agent-cost.mjs <session> [agent]`, which sums usage across the subagent transcripts.

## Scratch

`/tmp` is a 31 GB RAM disk with a per-user quota, and Claude Code keeps its own task output there, so a full `/tmp` also loses command output. Program scratch goes under `~/.cache/agent-swarm/<unit>/`, and every lane and owner exports `TMPDIR` there before its first command.

- A Codex lane cannot export its own. Under `workspace-write` it can write its `--cd` folder and the `TMPDIR` it was started with, but no other folder under `~/.cache`, so the parent creates `~/.cache/agent-swarm/<unit>/<lane>/` and puts `TMPDIR=<that folder>` in front of the `codex exec` command.
- Probe scripts and bulky probe data go in the lane worktree's `.tmp-vite/`. Node resolves imports from the script's folder, so a probe in `/tmp` can't import the repo's packages, and `cp -al` from the repo into `/tmp` fails across filesystems.
- A unit's decision trail lives in the repo beside the plan, not in scratch.
- Before deleting scratch, copy each round's verdicts and reports into `docs/work/<program>/review/`. Never delete a folder that a `decisions.tsv` row cites.

## Machine notes

- GNU `tail` rejects `tail -3 a b`. Write `tail -n 3`.
- `/usr/bin/time` and Python Pillow are installed. This machine has no `bc` or DejaVu font: use `node -e` for arithmetic and `magick -list font` to pick a font that exists.
- T3 Code sets `ELECTRON_RUN_AS_NODE=1`, and agent shells inherit it. Launch Electron by hand with `env -u ELECTRON_RUN_AS_NODE`.

## Transcripts

| Harness | Current session | All sessions for this checkout |
|---|---|---|
| Claude Code | `~/.claude/projects/<encoded-cwd>/$CLAUDE_CODE_SESSION_ID.jsonl` | `~/.claude/projects/<encoded-cwd>/*.jsonl` |
| Codex | `~/.codex/sessions/<yyyy>/<mm>/<dd>/rollout-*-$CODEX_THREAD_ID.jsonl` | `~/.codex/sessions/**/rollout-*.jsonl` whose first line has this `cwd` |

`<encoded-cwd>` is the workspace path with each `/` replaced by `-`, so `/home/me/project` becomes `-home-me-project`. Claude Code subagent transcripts sit in `<session-id>/subagents/`. A child process inherits its parent's environment, so a Codex lane started from Claude Code also sees `CLAUDE_CODE_SESSION_ID`. Use the variable for the harness you run in.

Read only the transcript you need. Don't glob across every project or session. That reads unrelated private chats.

## Instructions file

Where a skill says "your instructions file", that is `AGENTS.md`. `CLAUDE.md` in this repository imports it.

## Hooks

Both harnesses run `scripts/agent-hooks/bash-guard.mjs` before each shell command and `scripts/feedback/check.mjs` as a Stop hook, from `.claude/settings.json` and `.codex/hooks.json`. Change both together; `scripts/agent-hooks/hook-parity.test.mjs` checks them.

- Claude Code reads the session's own checkout's `.claude/settings.json`. Codex reads the main checkout's `.codex/hooks.json` even in a linked worktree and runs each hook in the session's folder, so a Codex hook resolves its script from the main checkout.
- Codex runs a project hook only while the developer's approval matches its current text, in interactive sessions and `codex exec` alike. An edit to `.codex/hooks.json` voids the approval: until the developer approves it again in Codex, Codex runs no repo hook, and `.codex/rules/project.rules` still refuses `pkill -f`, `git stash` and `prettier`.
- `APP_SKIP_STOP_CHECK=1` makes both Stop hooks skip the full check. Opus lanes started from Codex set it and keep the guard, using the `claude -p` command in `models.md`.
