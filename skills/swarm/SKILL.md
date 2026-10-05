---
name: swarm
description: "Fan out N parallel workers, drain them, and return one report. Use for /swarm, 'swarm this', or parallel coverage, races, gauntlets, and exploration."
disable-model-invocation: true
---

# Swarm

Fan out N parallel local background workers. They may cover separate slices, race the same brief, or mix both. The parent waits, aggregates, and returns one report.

## Start

Open a todolist with one entry per phase before launching anything.

1. Frame
2. Fan out
3. Aggregate
4. Report

## Phase A: Frame

1. State the done predicate and the artifact or report the swarm must return.
2. Choose the shape. Partition into slices, race N workers on identical briefs, or mix both. For a race or mixed shape, declare `first pass`, `rank all`, or `best-of` before spawning.
3. Set N from the user or derive it from the shape. N is total workers, not the concurrency limit.
4. Pick the worker model from the `swarm workers` role in [`models.md`](../poteto-mode/references/models.md). For a model race, name each arm's model up front. If a model is unavailable, record a dropout. Never substitute another model.
5. Give each worker its own writable output when it writes, and its own git worktree when it touches the repository. A worker that only reads or verifies a commit gets a detached worktree at that commit, never a writer's live one. A Sol worker runs with `--cd` set to that worktree, in the sandbox `models.md` names for its lane. Scratch lives under `~/.cache/agent-swarm/<unit>/`, per [`harness-tools.md`](../poteto-mode/references/harness-tools.md#scratch).
6. When workers verify or measure commits, each brief names the exact SHAs. A measurement brief also names the method (sample count, what one sample is, order). The worker records both in its result.

When the swarm verifies a unit's head and its findings go back to an owner who fixes them, the swarm runs in rounds. Read [`references/fix-rounds.md`](references/fix-rounds.md) before framing each round. It sets the severity scale, the merge bar, and what each round re-checks.

## Phase B: Fan out

Start all N workers in one fan-out on the step 4 model, each in the background with its handle kept. Route each per `models.md`. A worker whose model runs on the parent's provider is a native subagent. Any other worker runs the cross-provider command. Tool names per harness are in [`harness-tools.md`](../poteto-mode/references/harness-tools.md).

When a worker must start from a branch other than `main`, check that branch out in the worker's own worktree and name the worktree path in its brief.

Every brief stands alone. Include the goal, scope, exact slice or race arm, how to verify, and what to report.

- **Verdict.** The report's first line is `PASS`, `ISSUES`, or `BLOCKED`, with evidence below it. `PASS` means no defect, no difference the brief doesn't list, the comparison against main ran when the brief asks for one, and the worker reached its target surface. A skipped comparison or an unreachable surface is `BLOCKED`. A worker that can prove a defect reports `ISSUES` and lists every issue it can prove, not only the first, each with a severity from `references/fix-rounds.md` when the swarm verifies a unit. Observations that block nothing go on one `NOTES:` line.
- **Judgment calls.** The report ends with "Judgment calls I made", every policy question the worker settled on its own, such as treating a pattern as allowed.
- **Check log.** The worker appends each finished check, with its result and evidence path, to `<lane>-notes.md` in its scratch folder as it goes. A resumed or relaunched worker skips what the log shows done.
- **Short hand-back.** Every hand-back line lands in the root's context. A Sol worker's full report is its `--output-last-message` file, and the root reads its first lines. An Opus worker hands back the verdict line, one line per issue, its judgment calls, and its check log path, with no narrative.
- **Purpose, not allowed lists.** For each rule under review, say what the rule is for and which invariants to attack. A list of allowed patterns decides the question for the reviewer.
- **A worktree, not a paste.** A reviewer gets a worktree and the `git diff` command to run. A pasted diff hides the surrounding code.
- **The repo's own checks.** A gates worker runs `npm run verify:code` and the feedback check, never a rule restated in the brief. The repo's size rule exempts tests; restated rules have dropped that exemption.
- **The consumer.** An audit names the code that uses what it reviews today. A gap in something nothing calls yet is input for the next unit, not a defect.
- **Linter QA.** Frame guardrail coverage as linter QA that looks for missed cases and false alarms. The same work framed as a "red team" tripped the safety classifier.
- **No findings documents.** Claude Code refuses a findings document such as `FINDINGS.md` from a subagent, so a brief never orders one. Findings come back in the hand-back, and the root commits what the repo keeps.

If a worker drops out, proceed with N-1 and note it. A worker stopped by a session or rate limit has not dropped out. Resume it with SendMessage after the reset. Its context and finished checks survive, and a relaunch would redo them.

## Phase C: Aggregate

Read the terminal results, and take each verdict from the first line of the worker's own report. Drop a result that does not record the SHAs and method its brief names, and rerun that worker once. A bare "No findings." that names nothing it checked counts as a dropout. After a second miss, record a gap. A gap does not count as a pass. A `BLOCKED` stays `BLOCKED` until a rerun reaches what the worker could not, even when tests or other workers cover the same ground. For coverage, every required slice needs a result. For a race, apply the selection rule declared up front. Use first pass, rank all, or best-of. Do not paste raw worker dumps.

Keep a compact result table, one-line evidenced issues with their severity, and explicit gaps or dropouts.

## Phase D: Report

Return one consolidated in-chat report with the table, issue one-liners, gaps or dropouts, and the race rule when used.
