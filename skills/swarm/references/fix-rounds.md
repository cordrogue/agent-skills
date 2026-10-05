# Fix rounds

Read this before each round when a swarm verifies a unit's head and its findings go back to an owner, who fixes them and returns a new head. The loop ends at the merge bar below. Waiting for every lane to say `PASS` never ends it, because each fresh reviewer finds something new.

## Severity and the merge bar

Every finding carries one severity:

- **P1.** A wrong answer or data loss from an ordinary action, in shipped code or in the next unit's named consumer.
- **P2.** A wrong answer only at extremes, or in code that nothing calls yet.
- **P3.** Test, oracle, doc, or export tidiness.

Each finding also says whether the code breaks the spec or the spec doesn't cover the case. Then:

- The unit merges when no P1 and no regression is open.
- A P2 goes into the next unit's checklist as a failing test.
- A P3 goes to `docs/BACKLOG.md` through the **backlog** skill.
- Cases the spec doesn't cover go to the operator as one batch of decisions, each with a default, and the spec records the answer. The owner never settles the rule inside a fix round.
- After round 4, write the operator a scope-cut proposal instead of starting round 5.

## What each round re-checks

- Rounds 1 and 2 review the whole unit. From round 3, a returning audit confirms its own open findings and reads only `git diff <previous head> <head>`.
- A new audit joins only for a mechanism the round added, and reads only that mechanism's files.
- An audit retires after one round with no P1 or P2 in its diff.
- One audit per unit stays briefed from the design doc and the operator's stated goal, and someone other than the plan's author writes its brief. Audits briefed from the plan miss what the plan got wrong.
- After round 1, the live check is one scripted sweep of the screens the fix touched, found from `git diff --stat`. Add a full live lane only for a new screen or new behavior.
- After round 1, run the gates lane only on the head you expect to merge.
- Before any live lane starts, diff the head and main builds (`diff -rq` over `dist` and `dist-electron`). When they are identical, one smoke lane replaces the live set.

## One findings ledger per unit

Keep `findings.tsv` in the unit's scratch folder, one row per finding, with the columns `id`, `round`, `lane`, `title`, `severity`, `status`, and `brief item`.

- Before sending a fix brief, list the open rows. Each one leaves the round as a brief item or with a new status: fixed, accepted, P2 to the next unit, P3 to the backlog, or a question for the operator.
- Keep `accepted.md` beside the ledger for items you judged and accepted. Every brief includes it, and a lane reports a match as "known, unchanged", never as `ISSUES`.
- Tell the owner it gets one Sol review before code-ready. After that your swarm is the only reviewer, and you and the owner read the same ledger.
- Log each round's real cost in the decision trail. Claude agents' cost comes from `node scripts/agent-cost.mjs <session-id>`, and each Codex lane's from the `tokens used` line at the end of its log.

## Fix briefs

- Each item names its defect family, such as "every function that collapses an uncertain value to one", next to the scenario that exposed it. An item that names only the literal scenario gets that case fixed and its sibling found next round.
- The owner's report lists every path in the family and the test that covers each.
- Count recurrence by family. When a family comes back a second time, open the next brief by questioning the approach or cutting scope, per **principle-attack-the-premise**, instead of adding another item.

## Lane briefs

Render every round's lane briefs fresh from one template plus the unit's current-rules file, which states today's rules and nothing older. Past rounds' rendered briefs stay in `rN/` folders as the history. A brief edited in place with `sed`, with each round's changes appended, keeps reversed rules and broken sentences that lanes then judge against.
