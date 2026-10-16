# Fix rounds

Read this before each round when a swarm verifies a unit's head and an owner fixes its findings and returns a new head. The loop ends at the merge bar below, not when every lane says `PASS`: each fresh reviewer finds something new.

## Severity and the merge bar

Every finding carries one severity:

- **P1.** A wrong answer or data loss from an ordinary action, in shipped code or in the next unit's named consumer.
- **P2.** A wrong answer only at extremes, or in code that nothing calls yet.
- **P3.** Test, oracle, doc, or export tidiness.

Each finding also says whether the code breaks the spec or the spec doesn't cover the case.

- The unit merges when no P1 and no regression is open. A regression breaks main's behavior. Grade breaks against this unit's earlier heads by their own severity.
- Fix a P2 that can write or delete the developer's real project in this unit. Fix converter P2s only for inputs possible in the developer's project, the sample, or the next unit's named consumer. Record others in `accepted.md`. Other P2s go into the next unit's checklist as failing tests.
- A P3 goes to `docs/BACKLOG.md` through the **backlog** skill.
- Cases the spec doesn't cover go to the operator as one batch of decisions, each with a default, and the spec records the answer. The owner never settles the rule inside a fix round.
  - Each default keeps today's behavior unless keeping it needs a new mechanism, and the batch marks every default that drops it, tagging its `accepted.md` entry `[drops-behavior]` (or `[loosens-budget]` for a loosened plan budget), which `land.mjs --unit` refuses until the entry cites `[developer: <when and where>]`. F12 dropped trunk's undo note "to keep the dialog short" without saying so. Only operator decisions override today's behavior, not root-added plan wording. A default never keeps a data loss in code the unit changes or a family it fixes; that is a P1. When the fix needs a new mechanism, give its smallest shape, in lines and files, in the batch.
  - An accepted item that changes the developer's own project data or History goes in the batch too. F12's conversion left a History entry nobody can undo, and the developer learned of it afterward.
- After round 4, write the operator a scope-cut proposal instead of starting round 5.

## What each round re-checks

- Rounds 1 and 2 review the whole unit. From round 3, a returning audit confirms its own open findings and reads only `git diff <previous head> <head>`.
- A new audit joins only for a mechanism the round added, and reads only that mechanism's files.
- An audit retires after one round with no P1 or P2 in its diff.
- One audit per unit is briefed from the design doc and the operator's stated goal, by someone other than the plan's author. Audits briefed from the plan miss what the plan got wrong.
- After round 1, the live check is one scripted sweep of the screens the fix touched, per `git diff --stat`. Add a full live lane only for a new screen or new behavior.
- After round 1, run the gates lane only on the head you expect to merge. Rebase onto `main` before that round, so its gates, lane 1, and perf lanes double as the integration check.
- When the plan's in-memory perf gesture first becomes a round trip, such as navigation or a host query, time it against trunk before accepting the writer's branch, and again on the final head.
- A lane that measures time runs alone, after the gates lane's tests finish. Under that load, F12's timing sweep stalled and the owner's commit check timed out 7 times. It times trunk against head with `node scripts/swarm/perf-pairs.mjs`, the trail cites the script's result file, and the root dispatches nothing while it runs.
- Before any live lane starts, diff the head and main builds (`diff -rq` over `dist` and `dist-electron`). When they are identical, one smoke lane replaces the live set.
- After a rebase or other history rewrite that follows the verdict, diff the new head against the verified head. A check carries over only when its own inputs are unchanged: identical `dist` and `dist-electron` trees carry the live and perf lanes, and the gates lane reruns on any non-empty diff, a reword included, because a commit hook can change files. The MERGE-READY report records the tested head, the delivered head, and each reused check with the evidence that its inputs did not change.

## One findings ledger per unit

Keep `findings.tsv` in the unit's scratch folder, one row per finding, with the columns `id`, `round`, `lane`, `title`, `severity`, `status`, and `brief item`. The severity is the lane's rating; a different judgment goes in the status. Set statuses with `node scripts/swarm/ledger.mjs set <unit folder> <id>[,<id>] <status>`, which names the allowed statuses.

- Every lane's `NOTES:` line also gets a `note` row, which the launcher adds for its lanes. Give it a status like any finding, `dropped <reason>` included, so no note is triaged from memory.
- Before sending a fix brief, list the open rows. Each leaves the round as a brief item or with a new status: fixed, accepted, P2 to the next unit, P3 to the backlog, or a question for the operator.
- Keep `accepted.md` beside the ledger for items you judged and accepted. Each names the decision and every consequence you judged; a pointer such as "the owner defaults" accepts nothing. Before round 1, copy in every default an earlier unit recorded for a mechanism this unit inherits. Send a default every later unit will inherit to the root once, as a program-wide default. Every brief includes the file, and a lane reports a listed consequence as "known, unchanged", never as `ISSUES`.
- Drop a mutation finding only after rerunning that mutation in the gate the next agent runs.
- Tell the owner it gets one Sol review before code-ready. After that your swarm is the only reviewer, and you and the owner read the same ledger.
- Log each round's real cost in the decision trail: Claude agents' from `node scripts/agent-cost.mjs <session-id>` or the cost line `node scripts/swarm/ledger.mjs list` prints, each Codex lane's from the `tokens` column of the round's `results.tsv`.

## Fix briefs

- Send every fix brief to a fresh owner started from its `handoff.md`. An owner that is its own root caps its context at about 400K tokens: it reads its size from the line `node scripts/swarm/ledger.mjs list <unit folder>` prints before each fix brief (or `node scripts/agent-cost.mjs "$CLAUDE_CODE_SESSION_ID" --line`), and past the limit writes `handoff.md` and asks the developer to start a fresh owner from it. F13's owner ran past 400K and read about 34M tokens after that point. A resumed owner re-reads its whole history on every step: F12's grew to 899K, and its fix rounds cost about 205M tokens.
- While any writer or integrator runs, the owner runs `node scripts/swarm/stall-check.mjs <unit>` at every turn, and when it exits 1 replaces the stalled helper with a fresh one briefed from that worktree's diff and last `WIP:` commit, because a native subagent can stop with no notification (RF4's W8, RF5's INT, RF10's W1d and W2a).
- Each item names its defect family, such as "every function that collapses an uncertain value to one", next to the scenario that exposed it. An item naming only the scenario gets that case fixed and its sibling found next round.
- Name the family by what the user sees, such as "what was on screen stays", and by the mechanism the move changed. List every input that changes what is shown (a refresh, a changed date or search, another page, a first load) and every reader the mechanism rewired, agent and MCP tools included, and ask one test for each. F13's first failed-read brief named the library's states, refetch against first load, and missed the changed date.
- An item that keeps today's behavior asks for the trunk comparison in the testing skill's bullet on replacement reads. K8's writers built the owner's paraphrase of trunk, and audits found trunk did otherwise three times.
- The owner's report lists every path in the family and the test that covers each.
- Check every "unless" or "except" in a fix report against the mechanism the brief asked for, and test that branch before accepting the report.
- If stored data must act as if absent, a fix infers unrecorded state, or a module repeats an existing reader's calculation, open the first fix brief with a differential test. Build its table by crossing the host's author actions in source with every input shape, such as each date kind anchored to its own record or another.
- Count recurrence by family, across units, pre-review findings and cases a writer finds included. A family inherited in a unit's "From Fn" list keeps its count, and a sibling under a narrower name counts as a return. Before setting a severity, search earlier units' `accepted.md` files for the family. When a family returns a second time, the next brief opens with a failing test of the premise every earlier fix shared, or with a scope cut, per **principle-attack-the-premise**, instead of another item. Write a scope cut into the current-rules file at once. Its brief lists each earlier fix in the family and deletes it or says why it stays. F13 inherited the failed-read family on its fourth return, spent a round fixing sites on the old premise, and cut scope only on the fifth.

## Lane briefs

`scripts/swarm/launch.mjs` runs the round's Sol lanes. It renders each brief fresh from one template plus the unit's `current-rules.md`, which states today's rules and nothing older. Each rule states behavior someone saw in code or a run, and a rule about trunk cites the trunk file or test that shows it. Check an inferred side effect before writing it, or mark it unverified; K8's rule 13 misstated trunk's reign naming, and only the pre-review caught it. State stored-data invariants over table shapes read from copies of the developer's project and the sample, per alpha-build's **One project's data**. A brief edited in place with `sed`, each round's changes appended, keeps reversed rules and broken sentences that lanes then judge against.

1. Write `round.json` beside `current-rules.md` and `findings.tsv` in the unit's scratch folder. `node scripts/swarm/launch.mjs --help` lists its fields. A lane outside the numbered rounds, such as a pre-review or a solo perf lane, takes a named round such as `"round": "pre-review"` and shares the unit's rules and ledger. The goal audit sets `"rules": false`, which leaves `current-rules.md` and `accepted.md` out of its brief.
2. Before launch, run each mutation the brief pairs with tests through `node scripts/mutate.mjs` with the gate the lane runs as its command, and see each come back `killed`. Confirm each head-against-trunk comparison measures something trunk has.
3. Run `node scripts/swarm/launch.mjs <round.json>` in the background and act on its exit. It runs each lane in its own worktree at the lane's commit and removes it after, with any worktree the lane added under its scratch folder. It writes one exit line per lane to `r<N>/done.txt`, each lane's verdict, model, and tokens to `r<N>/results.tsv`, and each issue and `NOTES:` line to `findings.tsv` as an open row. The briefs and reports stay in `r<N>/` as the history.
4. If the launcher dies or T3 Code restarts, rerun the same command. It stops leftover lanes, removes their worktrees, and starts only the lanes with no exit line.
5. Opus lanes and `delegate_task` lanes stay with the root. Add their findings to the same `findings.tsv`.
6. Before each fix brief, run `node scripts/swarm/ledger.mjs list <unit folder>` and give every open row a brief item or a new status. The MERGE-READY report names every row it lists as a P1 not fixed or as accepted.
7. Land with `node scripts/land.mjs <branch> --unit <unit folder>` from main. It lands nothing while a receipt fails: an open P1, a `fixed` row whose commit the branch lacks, no `results.tsv` row on the branch's tree, or a guardrail change without its trailer.
