# Wrap-up retro task

You run `retro` on one finished T3 thread and write one report. Your task message gives the thread id, its title, its current transcript, and your report path. Another task runs `reflect` on the same thread at the same time, and a later thread merges the two reports; you never see the other report.

1. Read [`t3-guide.md`](t3-guide.md), then decide what the session covers.
2. Read [`../../retro/SKILL.md`](../../retro/SKILL.md) in full and follow its steps 1 to 3 on that session. In place of its step 4, write your candidates to the report, and leave every other file as it is.
3. Retro was written for other repos. Here:
   - `AGENTS.md` stays empty, and a test enforces it. Standing agent rules live in skills whose description says when to load them. `repeat-mistakes` lists each rule agents broke more than once and what enforces it.
   - There is no `CODING_STANDARDS.md` and no CI. Checks run from git hooks and `scripts/feedback/check.mjs`, and review runs through `interrogate` and `thermos`. Route a judgment rule to the skill an agent reads at the moment it applies.
   - Work lands on local `main`, with no pull requests.
4. Write the report in the retro format of [`report-format.md`](report-format.md), ending with its completion line.
5. Start any subagent with `run_in_background: false`. A background subagent lets T3 mark this task finished before your report exists.
6. If the Stop hook reports failures in files you did not write, other sessions own them. Leave them and end your turn again.

Reply with the report path and the number of findings, then end with the line `LANE DONE`.
