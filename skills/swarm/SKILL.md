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
4. Pick the worker model from the `swarm workers` role in [`models.md`](../poteto-mode/references/models.md). A worker that writes code or tests runs on Opus at the matching code role's effort. For a model race, name each arm's model up front and race only models allowed to produce that artifact. An unavailable model is a dropout, never a substitution.
5. Give each worker its own writable output when it writes, and its own git worktree when it touches the repository. A worker that only reads or verifies a commit gets a detached worktree at that commit, never a writer's live one. A Sol worker on `codex exec` runs with `--cd` set to that worktree, in the sandbox `models.md` names for its lane. One on `delegate_task` only reads, so its brief names the worktree to run commands in. Scratch lives under `~/.cache/agent-swarm/<unit>/`, per [`harness-tools.md`](../poteto-mode/references/harness-tools.md#scratch).
6. When workers verify or measure commits, each brief names the exact SHAs. A measurement brief also names the method (sample count, what one sample is, order). The worker records both in its result.

When the swarm verifies a unit's head for an owner who fixes the findings, it runs in rounds. Read [`references/fix-rounds.md`](references/fix-rounds.md) before framing each round for the severity scale, the merge bar, and what each round re-checks.

## Phase B: Fan out

Start all N workers in one fan-out on the step 4 model, each in the background with its handle kept. Per `models.md`, a worker on the parent's provider is a native subagent and any other takes the cross-provider route. Tool names per harness are in [`harness-tools.md`](../poteto-mode/references/harness-tools.md).

A worker that starts from a branch other than `main` gets that branch checked out in its own worktree, named in its brief.

Every brief stands alone. Include the goal, scope, exact slice or race arm, how to verify, and what to report.

- **Verdict.** The report's first line is `PASS`, `ISSUES`, or `BLOCKED`, with evidence below it. `PASS` means no defect, no unlisted difference, the requested comparison against main ran, and the worker reached its target surface. A skipped comparison or an unreachable surface is `BLOCKED`. A worker that can prove a defect reports `ISSUES` and lists every issue it can prove, not only the first, each with a severity from `references/fix-rounds.md` when the swarm verifies a unit. Observations that block nothing go on one `NOTES:` line.
- **Judgment calls.** The report ends with "Judgment calls I made", every policy question the worker settled on its own, such as treating a pattern as allowed.
- **Check log.** The worker appends each finished check, with its SHAs, method, result, and evidence path, to `<lane>-notes.md` in its scratch folder as it goes. A resumed or relaunched worker reuses a logged check only when its SHAs, method, and pass predicate are unchanged.
- **Short hand-back.** Every hand-back line lands in the root's context. A Sol worker's full report is its `--output-last-message` file or its `delegate_task` result, and the root reads all of it before aggregating. An Opus worker hands back the verdict line, one line per issue, its judgment calls, and its check log path, with no narrative.
- **Quiet exit.** Before handing back, the worker stops every Monitor and background watcher it started. A running Monitor wakes it again; two F12 lanes sent their 5 KB reports twice.
- **Purpose, not allowed lists.** For each rule under review, give the invariant, such as "every derived row equals a fresh rebuild after any write", and the consumer's real use. A list of allowed patterns or a designer's list of cases decides the question for the reviewer.
- **A worktree, not a paste.** A reviewer gets a worktree and the `git diff` command to run. A pasted diff hides the surrounding code.
- **The repo's own checks.** A gates worker runs `npm run verify:code` and the feedback check, never a rule restated in the brief. Below lint's 300-line limit for non-test source, file size is a review judgment under the **testing** skill.
- **The consumer.** An audit names the code that uses what it reviews today, and any next-unit consumer the brief names. A wrong answer in code nothing calls yet is still a finding, rated per `references/fix-rounds.md`. A capability missing outside the current scope is input for the next unit.
- **Linter QA.** Frame guardrail coverage as linter QA that looks for missed cases and false alarms. The same work framed as a "red team" tripped the safety classifier.
- **No findings documents.** Claude Code refuses a findings document such as `FINDINGS.md` from a subagent, so a brief never orders one. Findings come back in the hand-back, and the root commits what the repo keeps.

If a worker drops out, proceed with N-1 and note it. A worker stopped by a session or rate limit is a dropout only if it cannot continue after the reset. Resume a native worker with SendMessage when the provider-limit rule in [poteto-mode](../poteto-mode/SKILL.md) allows it. Rerun any other stopped worker fresh on its original route, with consolidated scope and its check log. A `delegate_task` rerun gets a new `clientRequestId`.

## Phase C: Aggregate

Read the terminal results, and take each verdict from the first line of the worker's own report. Drop a result that does not record the SHAs and method its brief names, and rerun that worker once. A bare "No findings." that names nothing it checked counts as a dropout. After a second miss, record a gap. A gap does not count as a pass. A `BLOCKED` stays `BLOCKED` until a rerun reaches what the worker could not, even when tests or other workers cover the same ground. When a worker is `BLOCKED` on a state the product cannot produce, such as a save the form never sends, record the original predicate and the evidence that it is unreachable, rerun the lane against the nearest reachable state that tests the same invariant, and report both the gap and the replacement. A replacement that changes coverage, policy, or scope goes in the operator's decision batch first. For coverage, every required slice needs a result. For a race, apply the selection rule declared up front. Use first pass, rank all, or best-of. Do not paste raw worker dumps.

Keep a compact result table, one-line evidenced issues, and explicit gaps or dropouts. Issues carry a severity per `references/fix-rounds.md` when the swarm verifies a unit, or per the brief's scale.

## Phase D: Report

Return one consolidated in-chat report with the table, issue one-liners, gaps or dropouts, and the race rule when used.
