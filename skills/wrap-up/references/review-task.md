# Wrap-up review task

Read-only: never edit tracked files, and start no other agents. Your answer is your final message.

You review a combined report that merged retro and reflect reports about one finished T3 thread, or about every thread of a stack. Your task message gives the combined report, its source reports, and the transcripts, or says each report's `sources` header names them.

1. Read the combined report, every source report, and [`report-format.md`](report-format.md) in full. A source report your task message marks missing was never written, so check against the rest.
2. Check every finding in the combined report:
   - Its evidence supports it. When it rests on one quote, read the transcript at that place.
   - Its destination follows the Destinations section of `report-format.md`.
   - It does not repeat an entry in `docs/BACKLOG.md` or a rule a skill already states, unless it says so and explains why that rule failed.
   - A `both` source, or a finding credited to several threads, is real: each report it cites raises the same problem.
3. Check coverage. Every finding and rejected item in any source report appears in the combined report, under Findings or under Rejected with a reason.
4. Check the decisions. Each one says what the developer would see, gives a default, and follows the **user-communication** skill.

Reply with numbered findings, each naming the finding id or section, a severity (`high`, `medium`, or `low`), the problem, and the fix. Reply "no findings" when there are none. End with the line `LANE DONE`.
