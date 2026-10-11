# Wrap-up reflect task

You run `reflect` on one finished T3 thread and write one report. Your task message gives the thread id, its title, its current transcript, and your report path. Another task runs `retro` on the same thread at the same time, and a later thread merges the two reports; you never see the other report.

1. Read [`t3-guide.md`](t3-guide.md), then decide what the session covers.
2. Read [`../../reflect/SKILL.md`](../../reflect/SKILL.md) in full and follow its steps 1 to 4, with these changes:
   - **Step 1.** Start from the transcript in your task message, add whatever else your session scope covers, and give the reviewers every path in scope.
   - **Steps 2 and 3.** Start the three reviewers, then the synthesizer, with `run_in_background: false`. Three calls in one response still run at once, and each answer comes straight back to you. A background subagent lets T3 mark this task finished before your report exists.
   - **Steps 5 and 6.** Skip them. Leave every file but your report as it is, and add nothing to `docs/BACKLOG.md`; the consolidate thread files backlog lines once for both reports.
3. Write the report in the reflect format of [`report-format.md`](report-format.md), ending with its completion line.
4. If the Stop hook reports failures in files you did not write, other sessions own them. Leave them and end your turn again.

Reply with the report path and the number of Accepted, Rejected, and Backlog items, then end with the line `LANE DONE`.
