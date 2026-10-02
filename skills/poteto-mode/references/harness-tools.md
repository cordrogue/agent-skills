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

Where a skill says "the todolist", use the todo tool in Claude Code and `update_plan` in Codex.

`how`, `why`, `unslop`, and `typescript-best-practices` stay model-invocable so `poteto-mode` and other skills can load them by name. `disable-model-invocation: true` would hide them from the Skill tool in Claude Code.

## Subagents

- **Claude Code.** Call `Agent` with `subagent_type: "poteto-agent"` for a helper inside a playbook step. Set `model` per `models.md` and `run_in_background: true`. A routed skill (`how`, `why`, `interrogate`, `thermos`, `reflect`, `swarm`, `arena`, `architect`) sets its own lanes.
- **Codex.** There are no named agent types. Call `spawn_agent` and start its instructions with "Read `.agents/skills/poteto-mode/SKILL.md` in full first." Subagents need `multi_agent = true` under `[features]` in `~/.codex/config.toml`.
- **Read-only lanes.** Claude Code has no read-only flag on `Agent`. Say "read-only, do not modify files" in the prompt, or use the read-only command in `models.md`. Codex lanes say the same in the prompt.
- **Writers.** Give each writer its own worktree. Create it from local `main` with `git worktree add ../worktrees/<task> -b <branch> main`. The `Agent` tool's `isolation: "worktree"` branches from `origin/main`, which lags local `main` here because work lands locally. If you use it, reset the delegate onto local `main` first.
- Pass file paths, not pasted context. Review every subagent's diff yourself.

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

Both harnesses run `scripts/feedback/check.mjs` as a Stop hook, from `.claude/settings.json` and `.codex/hooks.json`. Change both together. Cross-provider lanes turn hooks off (see `models.md`).
