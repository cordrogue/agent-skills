### Multi-phase plan

**You own the plan, not the code. The plan is a checklist an owner runs box by box and the operator audits from the evidence.** The plan is the deliverable. Do not implement.

1. When the change is one or two files with an obvious approach, skip the plan. Say so and stop.
2. Settle open questions by prototype before you write. Run `playbooks/prototype.md` for each. Keep the branch, the SHA, and the screenshots for Appendix A. Ask the operator only about a product or preference call that no run can settle. Give options (the **never-block-on-the-human** principle skill).
3. Explore in `poteto-agent` subagents with an explicit model per the Subagents section (the **guard-the-context-window** principle skill). Each returns file pointers, conventions, test commands, and entry points. No inlined dumps.
4. Copy the skeleton below into the plan file and fill every placeholder. Unless the operator names a path, write the file under `docs/work/`. Keep every heading and every sub-block in the order shown. One section per unit. One unit is one change with its own evidence that lands on `main` as its own commits (the **sequence-verifiable-units** principle skill). Name the execution playbook in **How to read this**. An unattended program takes `playbooks/autonomous-run.md`. Otherwise name the playbook that fits the units, such as `playbooks/feature.md`.
5. Write under `/technical-writing` in full, then `/unslop`. The body is one Diátaxis mode, how-to. Appendices hold explanation and reference. Each heading states the task or the finding. No long dashes. No mid-sentence colons.
6. Hand back. Post the plan path, then stop. Execution starts on the operator's explicit go, under the execution playbook the plan names.

**Verification.** Tests alone are not sufficient verification. A change is verified only when its unit, live, and perf boxes are all checked (the **prove-it-works** principle skill). That sentence is the verification rule. Every verification block opens with it. The live block is mandatory. Ten lanes at the unit's head commit drive the real surface through its control skill, per the **swarm** skill, on the `swarm workers` model in `../references/models.md`. Each lane is one box with a concrete scenario, the screenshot it saves, and its pass predicate. One lane is the **Regression lane against trunk.** It runs the same load-bearing scenario on trunk and head. If trunk does not have the feature, the lane records that fact and gates the behavior the diff adds plus the end state the user waits for instead of inventing a trunk result. The perf gate is dual-sided. Trunk and head must both produce the named metric. If trunk lacks the feature, also isolate the work the diff adds and set an absolute budget for that work plus the end-to-end state the user waits for. Do not claim a ratio between unlike scenarios. The perf block names the metric, the interleaved probe, the trunk baseline measured first, and the rule with the number that fails. A unit that changes an interaction is review-gated. The operator reviews it in chat with screenshots and a video before merge. A unit that changes no interaction writes `**Review gate.** None. <unit id> is not review-gated.` and no boxes under it.

**Control skill.** Pick it by surface. The app's UI uses the **run-app** skill. CLIs and TUIs run directly in the shell. Native mobile uses whatever simulator-driving skill the repo has. A unit that touches two surfaces gets lanes on both. A surface with no control skill is a risk in Appendix C, and its live block still names how each lane drives it.

````markdown
# <Program> plan

<Under ten lines. What changes, for whom, the rule the program enforces, and the unit ids in order.>

## How to read this

One box is one unit of work. Every box names the evidence that checks it. A nested box is a sub-step of the box above it. Check a box only when its evidence exists, a file, a log line, a screenshot, a test run, or a SHA. The body is a how-to. The appendices explain and record.

The program runs `.agents/skills/poteto-mode/playbooks/<execution playbook>.md`. <Who merges to `main`, and which unit ids are the operator's items that stop at merge-ready.>

Tests alone are not sufficient verification. A change is verified only when its unit, live, and perf boxes are all checked.

## Program checklist

### Arm the program

- [ ] State the protocol and this plan to the operator, then stop. Start execution only on the operator's explicit go.
- [ ] On the operator's go, write the program objective at the top of the todolist and the decision trail with this exact text. "<The plan path, the unit ids in order, the verification rule, who merges, and the done condition.>"
- [ ] Read these from trunk at program start. Re-read them at every tick.
  - [ ] `git show main:.agents/skills/poteto-mode/playbooks/<execution playbook>.md`
  - [ ] `git show main:.agents/skills/swarm/SKILL.md`
  - [ ] `git show main:<control skill path>`
  - [ ] `git show main:.agents/skills/poteto-mode/playbooks/landing-on-main.md`
  - [ ] `git show main:.agents/skills/<each other leaf skill the program uses>/SKILL.md`
- [ ] Arm the 30-minute audit tick. In Claude Code, a real `/loop`. Codex has no `/loop`, so use a Codex automation if one exists, otherwise run the tick at the end of every turn. Never leave the cadence to memory.
- [ ] Use this tick prompt, verbatim. "Re-read the execution playbook from trunk and the program objective. Audit the operation against both and fix drift in this tick. Probe every active lane and judge progress by side effects only. Stand down a stuck lane and dispatch its replacement now. Then post a short status message to the operator in chat only when the audit found a tracked change that no earlier status message reported, such as a unit started, a code-ready head, a round launched or closed, a verdict, a merge, a stuck agent and the action taken, a blocker added or cleared, or a decision only the operator can make. Name every such change and nothing else. Do not repeat a table, the merged list, or an unchanged blocker. If the audit found none, end the turn with no reply text. Either way, log this tick's row in your decision trail. The row names the items reported, or none."
- [ ] On the operator's hold or stand-down, send every owner a zero-writes order at once.

### Spawn owners

- [ ] Spawn one owner per unit, each in its own worktree, with the full lifecycle the execution playbook names.
- [ ] Follow this dependency graph. Start dependent work only after its parent merges, or base it on the parent branch when the execution playbook stacks.
  - [ ] <unit id> and <unit id> are independent and first. Both branch from `main`.
  - [ ] <unit id> after <unit id>.
- [ ] Hold the file boundaries. <unit id or class> touches only `<glob>`.
- [ ] Hold the review gate. <unit ids> change an interaction. They wait for the operator's review in chat with screenshots and a video before merge.

### Landing mechanics, for every unit

- [ ] Work on a branch off `main` in the owner's worktree, per `.agents/skills/poteto-mode/playbooks/landing-on-main.md`. A dependent unit branches from its parent's branch.
- [ ] Run the feedback check, `mise exec node@24.18.0 -- node scripts/feedback/check.mjs </dev/null`, before the code-ready report.
- [ ] Run `/deslop` before each commit.
- [ ] Rebase onto current `main` before the code-ready report. Keep that merge base in fix rounds. Rebase again only at merge prep or on a `git merge-tree` conflict with `main`.

### Verdict and merge, for every unit

- [ ] At the code-ready head SHA and at each later commit that changes the patch, run the swarm per `.agents/skills/swarm/SKILL.md`. One gates lane. The ten live lanes from the unit's **Verify, live** block. The perf lane from its **Verify, perf** block. Two or more audit lanes, each with its own focus, that read the diff and the receipts and distrust the commit messages. The root audits the receipts in the merge-ready report before the verdict.
- [ ] Clean only when every lane is `PASS`. Findings go back to the owner, including a defect that a lane filed as a note. A new head gets a fresh swarm and a fresh verdict, except after a rebase whose `git patch-id` matches the verified head.
- [ ] <The merge rule. Who merges the branch into `main` locally, and in what order. Never push unless the operator asks.>

### Boot recipe, for every live lane

Each live lane runs in its own worktree at the unit's head commit. Drive the app's UI through the **run-app** skill.

- [ ] `git worktree add --detach <lane worktree> <head SHA>`.
- [ ] <Start the backend and the surface. Wait for ready.>
- [ ] <Deliver input only through the control skill's commands. Name the read-only diagnostics.>
- [ ] Save every screenshot to `/tmp/swarm-<unit-id>/worker-<n>/<slug>.png` and return the paths with the report.

## <Task as a verb phrase> (<unit id>)

**Depends on.** <unit id, or None.>

**Files.**

- [ ] Edit `<path>`.
- [ ] Create `<path>`.
- [ ] Delete `<path>`.

**Build.**

- [ ] <One change. Name the symbol and the file.>

**You see.**

- [ ] <One observable result, with the exact log line or screen state.>

**Verify, unit.** Tests alone are not sufficient verification. A change is verified only when its unit, live, and perf boxes are all checked.

- [ ] <Test file and the case it gains.> Run `<command>`.

**Verify, live.** Tests alone are not sufficient verification. A change is verified only when its unit, live, and perf boxes are all checked. Ten lanes on `<swarm workers model>` at the unit's head commit, per the boot recipe.

- [ ] Lane 1. Regression lane against trunk. Run <the same load-bearing scenario> at trunk and head. If trunk lacks the feature, record that and gate <the behavior the diff adds plus the end state the user waits for>. Save `<slug>.png`. Pass when <predicate>.
- [ ] Lane 2. <Scenario.> Save `<slug>.png`. Pass when <predicate>.
- [ ] Lane 3. <Scenario.> Save `<slug>.png`. Pass when <predicate>.
- [ ] Lane 4. <Scenario.> Save `<slug>.png`. Pass when <predicate>.
- [ ] Lane 5. <Scenario.> Save `<slug>.png`. Pass when <predicate>.
- [ ] Lane 6. <Scenario.> Save `<slug>.png`. Pass when <predicate>.
- [ ] Lane 7. <Scenario.> Save `<slug>.png`. Pass when <predicate>.
- [ ] Lane 8. <Scenario.> Save `<slug>.png`. Pass when <predicate>.
- [ ] Lane 9. <Scenario.> Save `<slug>.png`. Pass when <predicate>.
- [ ] Lane 10. <Scenario.> Save `<slug>.png`. Pass when <predicate>.

**Verify, perf.** Tests alone are not sufficient verification. A change is verified only when its unit, live, and perf boxes are all checked.

- [ ] Metric. <What is measured at both trunk and head. If trunk lacks the feature, also name the diff-added work and the end-to-end state the user waits for.>
- [ ] Probe. <The command or procedure, run at trunk and at the head, interleaved. Both sides must produce the metric.>
- [ ] Baseline. Record the trunk <value> first.
- [ ] Rule. <Head against trunk, with the number that fails. If the scenarios differ, add absolute budgets for the diff-added work and the user-visible end state instead of an invalid ratio.>

**Review gate.** The operator reviews before merge.

- [ ] Copy lane <n> screenshots into `<media path>/<unit-id>-review-<slug>.png`.
- [ ] Record a 30 to 60 second video of the change from a lane worktree. Save it as `<media path>/<unit-id>-review.mp4`.
- [ ] Post the screenshots and the video in chat. Stop at merge-ready. Wait for the operator's click.

**Merge.**

- [ ] Root's clean verdict at the exact head SHA.
- [ ] Rebased onto current `main` after the verdict, patch-id unchanged.
- [ ] <The owner or the root merges the branch into `main` locally.>

## Close the program

- [ ] Every box above is checked with its evidence.
- [ ] Reply to the operator with the report the execution playbook names.

## Appendix A. Prototype evidence

<Each open question a prototype answered, with the branch, the SHA, and the artifact links. Each question that stays unproven.>

## Appendix B. Alternatives rejected

<Each approach weighed and why it lost.>

## Appendix C. Risks

<Each risk with the unit it lands in and what the owner watches.>

## Appendix D. Links and reading list

<Docs to read before editing. Which units get `.agents/skills/how/SKILL.md` and `.agents/skills/interrogate/SKILL.md`. The trail per `.agents/skills/show-me-your-work/SKILL.md`.>
````

**Reply:** the plan path, the unit ids with their dependencies and the review-gated set, and what the prototypes proved and what stays unproven.
