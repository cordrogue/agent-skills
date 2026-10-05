### Autonomous run

**You own the exit condition. Define done, then drive to it without stopping.**

Before the operator's go on an unattended program, read `../SKILL.md` in full, not its head, and every principle leaf the plan or its briefs cite.

1. State the exit condition as a checkable predicate before the first iteration (tests green, repro fixed, all N units landed on `main`, pixel-diff zero).
2. Pick the wake mechanism using Claude Code's `/loop` command (a built-in, not a pstack skill). Codex has no `/loop`, see `../references/harness-tools.md`. An event to watch (a long command finishing, a merge, a ref advancing) gets a watcher subagent that wakes you on the event, with a long time-based heartbeat as fallback. No event gets a fixed-interval heartbeat sized to when the result is worth re-checking. After arming a heartbeat, start a background `sleep` of its interval plus five minutes, with the Bash `timeout` above that, and when it returns, confirm the first tick's `decisions.tsv` row exists. If it does not, re-arm as a self-paced `/loop` with no interval, which wakes through `ScheduleWakeup` instead of cron. When every open item waits on the operator, stop the heartbeat and re-arm it on their reply, because each idle tick re-reads your whole context.
3. Each iteration makes the smallest change the evidence justifies, verifies it against the predicate, commits if it advanced, discards changes that didn't help. Belt-and-suspenders that "might help" gets reverted, not left to ride.
   Sequence the work via the **sequence-verifiable-units** principle skill, verifying each unit before the next instead of batching checks at the end.
   When owners run units for you, brief each owner to write `handoff.md` (branch, head, worktrees, open decisions, live helper ids) in the unit's scratch folder with every code-ready report, and to save each census or audit result in the unit's facts folder, `~/.cache/agent-swarm/<unit>/facts/`. Open later briefs on a topic with "start from this" and that result's path. Replace an owner with a fresh one started from its `handoff.md` after two fix rounds, or once its context passes about 400K tokens (the `subagent_tokens` in its last notification). A resumed owner re-reads its whole history on every step.
4. Mid-run discoveries are yours. Address broken skills, related bugs, flaky verifiers, review noise, tooling failures, orphaned follow-ups, and fixable drift yourself via poteto-mode. Put out-of-band fixes in their own commit. Do not park reversible work for the human or ask the user. Surface only irreversible actions, genuine product or preference calls no experiment can settle, or a real dead end. Keep the predicate as the main drive, and return to it after each side fix.
5. Checkpoint every iteration via the **show-me-your-work** skill, a row for what changed and whether the predicate moved.
6. Stop when the predicate is met. A plateau is not a stop, so keep going and pivot your approach to push past it. Surface a genuine dead end rather than spinning, and never relax the predicate to declare victory.

**Reply:** the exit condition, iterations run, what landed, what was discarded, final predicate state.
