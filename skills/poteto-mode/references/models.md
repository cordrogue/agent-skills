# Models

Which model runs each pstack role, and how a parent reaches it. Skills name a role line from this file. Upstream pstack reads the same role names from a per-user rule file. This file replaces that rule.

## Models

| Model | Provider | Name to pass | Runs in |
|---|---|---|---|
| Opus 5.5 | Claude | `opus` | Claude Code |
| Astra | Codex | `gpt-6-astra` | Codex |
| Sol 6.1 | Codex | `gpt-6.1-sol` | Codex |

Opus writes all code, tests included. Astra and Sol never write code in this repository; they read, review, and verify. Astra does judgment, prose, synthesis, and the hardest reasoning. Sol runs cheap parallel work.

## Roles

Effort is `high` unless a row says otherwise.

| Role | Model |
|---|---|
| `feature, refactoring` | Opus |
| `bug-fix` | Opus |
| `perf-issue` | Opus |
| `hillclimb` | Opus |
| `judgment and prose` | Astra |
| `hardest tasks` | Opus when the task writes code. Astra, effort `xhigh`, when it only reasons. |
| `how explorer` | Sol, effort `medium` |
| `how explainer` | Astra |
| `why investigators` | parent |
| `why synthesizer` | parent |
| `reflect tooling` | parent |
| `reflect judgment, divergent, synthesizer` | parent |
| `arena runners` | Opus, Sol. A runner whose candidate is code runs on Opus |
| `arena cross-judge pool` | Opus, Sol, Astra |
| `swarm workers` | Sol, effort `medium` |
| `architect runners` | Opus, Sol |
| `interrogate reviewers` | Opus, Sol |
| `thermos reviewers` | parent, unless the user names a model |

A panel row lists one lane per model. The parent session judges the panel. "Parent" means the lane runs on the parent's own model through its native subagent tool. Why and reflect lanes need the parent's MCP tools, and a cross-provider lane gets none, so they stay on the parent.

## Routing

The parent picks the route once, before fan-out. A lane never chooses its own model or starts another model.

| Parent | Opus lane | Astra or Sol lane |
|---|---|---|
| Claude Code | native `Agent` | `codex exec` in background Bash |
| Codex | `claude -p` in a background exec session | native `spawn_agent` |

Native lanes:

- **Claude Code.** Call the `Agent` tool with `model: "opus"` and `run_in_background: true`. The tool has no effort parameter. Opus effort comes from `~/.claude/settings.json`.
- **Codex.** Call `spawn_agent` with the model name and `reasoning_effort`. Codex subagents already run beside the parent.

`references/harness-tools.md` covers the rest of each native tool.

## Cross-provider commands

Write the full lane prompt to a file first. Pass it on stdin. Never put prompt text in the command line.

### Codex parent to Opus

```bash
cd <repository or dedicated worktree> && APP_SKIP_STOP_CHECK=1 claude -p \
  --model opus --effort high \
  --permission-mode plan \
  --strict-mcp-config \
  --tools "Read,Grep,Glob,Bash" \
  --disable-slash-commands \
  --no-session-persistence \
  --output-format json \
  < <prompt file> > <output file>
```

- `APP_SKIP_STOP_CHECK=1` skips the Stop hook's full feedback check. The worktree's `.claude/settings.json` still runs the Bash guard, and project `CLAUDE.md` still loads.
- `--permission-mode plan` is read-only. Read-only Bash such as `git log` still runs.
- For a writer, use `--permission-mode acceptEdits` and `--tools "Read,Grep,Glob,Bash,Edit,Write"`, and run it only in a dedicated worktree.
- `--tools` leaves out `Agent`, so the lane cannot spawn subagents. `--strict-mcp-config` with no `--mcp-config` loads no MCP servers.
- The JSON result holds the reply in `.result`. Record the model from the `modelUsage` keys. Claude Code can add a small side model there for its own checks. The requested model is the one that did the work.

### Claude parent to Sol or Astra

```bash
codex exec \
  --model gpt-6.1-sol -c model_reasoning_effort='"high"' \
  --sandbox read-only \
  --cd <repository or dedicated worktree> \
  --ephemeral \
  --disable plugins --disable multi_agent --disable memories \
  --output-last-message <output file> \
  - < <prompt file> > <log file> 2>&1
```

- Use `--model gpt-6-astra` for an Astra lane.
- `--output-last-message` saves the lane's final message, so the prompt asks for the answer as that message and never asks the lane to write a file.
- Pick `--sandbox` and `--cd` by what the lane does. A brief for a writable sandbox says "never edit tracked files".

| Lane | `--sandbox` | `--cd` |
|---|---|---|
| Review or research that only reads | `read-only` | the repository |
| Audit of a branch head | `workspace-write`, with `TMPDIR` set per [Scratch](harness-tools.md#scratch) | a detached worktree at that head |
| Verification lane (app, builds, tests, perf) | `danger-full-access` | a detached worktree at that head |

- An audit runs the branch's own tests there with `npx vitest run <file>`. Under `read-only`, node cannot spawn git (`spawnSync git EPERM`) and tests cannot write temp files, and from `main` the branch's files are missing.
- A verification lane needs full access because Electron dies under `workspace-write` with `sandbox_host_linux.cc:41 Check failed: . shutdown: Operation not permitted`.
- Make the detached worktree with `git worktree add --detach <path> <head>`, and hard-link `node_modules` from `main`, or from the owner's worktree when the branch changed dependencies. Remove it when the lane ends.
- The lane runs the repo's hooks while the developer's approval of `.codex/hooks.json` is current, and `.codex/rules/project.rules` refuses the guarded commands either way, per [`harness-tools.md`](harness-tools.md#hooks). Its Stop hook's feedback check covers only uncommitted files, so it passes for a lane that leaves tracked files alone and runs in a worktree with `node_modules`. Without `node_modules` the check fails, and its failure replaces the lane's final message. `--disable hooks` turns off the guard as well, so lanes keep hooks on. `--disable multi_agent` stops nested subagents.
- The log's header carries a `model:` line. Record it.

## Rules

- Give every lane its own prompt file, output file, and worktree when it writes.
- Start every cross-provider lane in the background and keep its handle. Claude Code uses Bash with `run_in_background: true` and keeps the task id. Codex keeps the exec session id and polls it. A foreground call can time out on a healthy lane.
- Wait by acting on each lane's background-task notification. When one wait must cover several lanes, empty `done.txt` with `: > done.txt`, run each lane as `codex exec … ; echo "<lane> exit=$?" >> done.txt`, start `until [ "$(wc -l < done.txt)" -ge <lane count> ]; do sleep 10; done` in the background, and end the turn. Read a lane's output only after its `exit=` line exists. An output file appears while the lane is still writing it and never appears when a run fails first, and `pgrep -fa "codex exec"` lists every agent's runs, not only yours.
- Start native and cross-provider lanes in the same fan-out. Judge only after every lane has finished.
- Never fall back to a different model. A missing CLI, failed login, unknown model, empty output, or non-zero exit is a dropout. Record it and follow the calling skill's dropout rule.
- Record which model each lane used, in the synthesis note or decision trail.
- An Opus writer started from a Codex parent leaves its changes uncommitted in its worktree. The parent reviews the diff and commits.
- When a capability limit decides which model runs expensive work, such as which models can launch the app, probe it with a short run before planning around it.
