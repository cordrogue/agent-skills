# Models

Which model runs each pstack role, and how a parent reaches it. Skills name a role from this file, which replaces upstream pstack's per-user rule file.

## Models

| Model | Provider | Name to pass | Runs in |
|---|---|---|---|
| Opus 5.5 | Claude | `opus` | Claude Code |
| Sol 6.1 | Codex | `gpt-6.1-sol` | Codex |

Opus reasons better, so it writes all code, tests included, and makes the decisions. Sol never writes code in this repository and makes no decisions. It is cheaper and faster, so it reads, searches, measures, summarizes, and takes small helper tasks, and it is pickier, so it runs the adversarial reviews. Sol is the only Codex model, so every Codex lane runs on `gpt-6.1-sol`.

## Roles

Effort is `high` unless a row says otherwise.

| Role | Model |
|---|---|
| `feature, refactoring` | Opus |
| `bug-fix` | Opus |
| `perf-issue` | Opus |
| `hillclimb` | Opus |
| `judgment and prose` | Opus |
| `hardest tasks` | Opus |
| `reading and helpers` | Sol, effort `medium` |
| `how explorer` | Sol, effort `medium` |
| `how explainer` | Sol |
| `why investigators` | parent |
| `why synthesizer` | parent |
| `reflect tooling` | parent |
| `reflect judgment, divergent, synthesizer` | parent |
| `wrap-up retro and reflect tasks, consolidate thread` | Opus |
| `wrap-up review` | Sol |
| `arena runners` | Opus, Sol. A runner whose candidate is code runs on Opus |
| `arena cross-judge pool` | Opus, Sol |
| `swarm workers` | Sol, effort `medium` |
| `architect runners` | Opus, Sol |
| `interrogate reviewers` | Opus, Sol |
| `thermos reviewers` | parent, unless the user names a model |

A panel row lists one lane per model, and the parent session judges the panel. A "parent" lane runs on the parent's own model through its native subagent tool. Why and reflect lanes stay on the parent because they need its MCP tools, and a cross-provider lane gets only its own provider's MCP servers.

## Routing

The parent picks the route once, before fan-out. A lane never chooses its own model or starts another model.

| Parent | Opus lane | Sol lane |
|---|---|---|
| Claude Code | native `Agent` | T3 Code `delegate_task` when the lane only reads. `codex exec` in background Bash when it needs its own worktree or a sandbox per the lane table below. |
| Codex | `claude -p` in a background exec session | native `spawn_agent` |

Native lanes:

- **Claude Code.** Call the `Agent` tool with `model: "opus"`, the role's `effort`, and `run_in_background: true`.
- **Codex.** Call `spawn_agent` with the model name and `reasoning_effort`. Codex subagents already run beside the parent.

`references/harness-tools.md` covers the rest of each native tool.

## Claude parent to Sol through T3 Code

Call the `t3-code` MCP tool `delegate_task` once per lane:

```json
{
  "task": "<full lane prompt>",
  "title": "<role>: <lane>",
  "role": "review",
  "target": { "providerInstanceId": "codex", "model": "gpt-6.1-sol", "options": { "reasoningEffort": "<role effort>" } },
  "mode": "async",
  "clientRequestId": "<run>-<lane>-<round>"
}
```

- The lane sees only `task`. It runs in the calling thread's worktree under Codex `danger-full-access` with approval policy `never` (probed 2026-10-08), so it can write any folder, the main checkout and other worktrees included, and it has network access. Codex's automatic command review still refuses commands containing `rm -f`. The lane's turn-end check runs in that worktree, so launch lanes from a thread whose worktree no writer is editing. The brief says "read-only, never edit tracked files, start no other agents". Leave `runtimeMode` unset; `approval-required` makes the lane ask the developer before every command.
- The brief ends with "End your final message with the line `LANE DONE`." A child that ends its turn while background work runs publishes that interim message as its `summary`, and `summary` never shows the real answer from its later run. When the line is missing, read the child's last assistant message with `t3_thread_read` on `childThreadId`.
- Each lane's completion wakes the parent. End the turn after the fan-out, then read each lane with `task_status` and record the model from its `model` field. Stop a lane with `task_cancel`.
- A `failed` or `cancelled` status, or a `provider_unavailable` or `model_unavailable` error, is a dropout. Quitting T3 Code cancels every running lane. A rerun takes a new `clientRequestId`; reusing one returns the old result.

## Cross-provider commands

Write the full lane prompt to a file and pass it on stdin, never in the command line.

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
- `--permission-mode plan` is read-only, though read-only Bash such as `git log` still runs.
- For a writer, use `--permission-mode acceptEdits` and `--tools "Read,Grep,Glob,Bash,Edit,Write"`, and run it only in a dedicated worktree.
- `--tools` leaves out `Agent`, so the lane cannot spawn subagents. `--strict-mcp-config` with no `--mcp-config` loads no MCP servers.
- The reply is in the JSON's `.result`. Record the model from the `modelUsage` keys. Claude Code can add a small side model there for its own checks, but the requested model did the work.

### Claude parent to Sol through `codex exec`

Use this route for a Sol lane that needs its own worktree or a sandbox other than the main checkout's. A lane that only reads uses `delegate_task` above.

```bash
codex exec \
  --model gpt-6.1-sol -c model_reasoning_effort='"high"' \
  --sandbox <sandbox> \
  --cd <dedicated worktree> \
  --ephemeral \
  --disable plugins --disable multi_agent --disable memories \
  --output-last-message <output file> \
  - < <prompt file> > <log file> 2>&1
```

- `--output-last-message` saves the lane's final message, so the prompt asks for the answer as that message and never asks the lane to write a file.
- Every lane runs `--sandbox danger-full-access`, and its brief says "never edit tracked files" unless it is a writer. Under `workspace-write` a lane's tests cannot listen on localhost (`listen EPERM`), lint cannot spawn git (`spawnSync git EPERM`), Electron dies, and `.agents/` is read-only; K4, K6 and K8 each lost a round to it. `scripts/swarm/round.mjs` refuses any other sandbox.
- An audit or verification lane runs with `--cd` set to a detached worktree at the head it checks, and runs the branch's own tests there with `npx vitest run <file>`. A writer runs in its own worktree.
- Never ask an audit to check what the perf lane covers.
- Make the detached worktree with `git worktree add --detach <path> <head>`. `git worktree add` links main's `node_modules` through `.githooks/post-checkout` when the lock file matches main's; otherwise hard-link from the worktree whose lock matches (the owner's when the branch changed dependencies). Remove it when the lane ends.
- The lane runs the repo's hooks while the developer's approval of `.codex/hooks.json` is current, and `.codex/rules/project.rules` refuses the guarded commands either way, per [`harness-tools.md`](harness-tools.md#hooks). The Stop hook checks only uncommitted files, so it passes for a lane that leaves tracked files alone in a worktree with `node_modules`. Without `node_modules` the check fails, and its failure replaces the lane's final message. Keep hooks on, because `--disable hooks` also turns off the guard. `--disable multi_agent` stops nested subagents.
- Record the `model:` line in the log's header. Codex writes the header to stderr and the final message to stdout, so send both to one descriptor, as `> <log file> 2>&1` does; two descriptors on the same file let the message overwrite the header. `launch.mjs` copies the line into `results.tsv`.

## Rules

- Give every CLI lane its own prompt file and output file, and every lane that writes its own worktree.
- A playbook helper's prompt begins with "Read `.agents/skills/poteto-mode/SKILL.md` in full before doing any work, including its Principles index." A routed workflow lane follows its own skill's brief instead.
- Start every cross-provider lane in the background and keep its handle: a `delegate_task` lane uses `mode: "async"` and keeps its `taskId`, a CLI lane in Claude Code uses Bash with `run_in_background: true` and keeps the task id, and Codex keeps the exec session id and polls it. A foreground call can time out on a healthy lane.
- Wait by acting on each lane's notification. When one wait must cover several CLI lanes, empty `done.txt` with `: > done.txt`, run each lane as `codex exec … ; echo "<lane> exit=$?" >> done.txt`, start `until [ "$(wc -l < done.txt)" -ge <lane count> ]; do sleep 10; done` in the background, and end the turn. Read a lane's output only after its `exit=` line exists. An output file appears before the lane finishes writing it, or never when a run fails first, and `pgrep -fa "codex exec"` lists every agent's runs, not only yours.
- Start native and cross-provider lanes in the same fan-out. Judge only after every lane has finished.
- Never fall back to a different model. A missing CLI, failed login, unknown model, empty output, or non-zero exit is a dropout. Record it and follow the calling skill's dropout rule.
- Record which model each lane used, in the synthesis note or decision trail.
- An Opus writer started from a Codex parent leaves its changes uncommitted in its worktree. The parent reviews the diff and commits.
- When a capability limit decides which model runs expensive work, such as which models can launch the app, probe it with a short run before planning around it.
