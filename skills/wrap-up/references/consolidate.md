# Consolidate a wrap-up

The `wrap-up` skill started this thread after a thread's work finished. Your first message names that thread, its transcript, the retro and reflect reports, and the path of the combined report you write; `<name>` is that path's file name without `_combined.md`. You merge the two reports, have Sol review the merge, file the backlog, and carry out the developer's decisions. The developer talks to you here, so the wrap-up ends in this thread.

A report your first message marks `missing: <reason>` was not written. Merge from the report you have, put the reason in the header's `retro_report` or `reflect_report` field, tell the review task, and stage only the reports that exist.

1. **Read.** Read both reports in full and [`report-format.md`](report-format.md), including its Destinations section.

2. **Merge.** Write one finding per problem, matching findings by the problem they describe, not by wording. A problem both reports raise has source `both`, which is stronger evidence and ranks above one report's finding of the same severity. Where the reports disagree, or a finding rests on one quote, read the transcript at the cited place. Give each finding one destination per the Destinations section. A finding you drop goes under `## Rejected` with its source and reason, as does every item of reflect's Rejected list.

3. **Find leftovers.** Run `git worktree list`, `git branch --no-merged main`, and `git status --short` in the main checkout. List each worktree, branch, or untracked file that the session's transcripts name under `## Leftovers`, and add one decision for them with a default. Delete nothing.

4. **Write the combined report** at the path in your first message, in the combined format, with every header field and the completion line.

5. **Have Sol review it.** Call `delegate_task`:

   ```json
   {
     "task": "Read <main>/.agents/skills/wrap-up/references/review-task.md in full and follow it.\n\nCombined report: <path>\nRetro report: <path, or 'missing: <reason>'>\nReflect report: <path, or 'missing: <reason>'>\nThread transcript: <path>",
     "title": "wrap-up review: <title>",
     "role": "review",
     "target": { "providerInstanceId": "codex", "model": "gpt-6.1-sol", "options": { "reasoningEffort": "high" } },
     "mode": "async",
     "clientRequestId": "wrap-up:<name>:review:try1"
   }
   ```

   End the turn; the task's completion wakes you. Read it with `task_status`. When the summary lacks `LANE DONE`, read the task's last assistant message with `t3_thread_read` on its `childThreadId`. The review counts only when one of the two ends with `LANE DONE`. Any other end is a dropout: run it once more with `try2` in its clientRequestId, and after a second dropout write that the review dropped out under `## Review` and go on. Never switch the review to another model. Apply each Sol finding you agree with, and record every Sol finding and what you did with it under `## Review`.

6. **File the backlog.** Load the **backlog** skill. Before your first edit, run `git status --porcelain -- docs/BACKLOG.md`; any output means someone else has uncommitted changes there. File each `backlog` finding as one line ending `([wrap-up <id>](reviews/combined/<file>), <date>)`, merged into an existing entry when one matches, and set its Status to `filed to backlog`.

7. **Commit** on `main`. `git add` the reports and `docs/BACKLOG.md`, then run `git commit -m "<subject>" -- <paths>`, which leaves out anything else already staged. If step 6 found someone else's changes, leave `docs/BACKLOG.md` out of both commands and tell the developer. The subject is `Add the wrap-up reports for <title>`.

8. **Ask the developer.** Follow **user-communication**. Open with "waiting on you" and the numbered decisions with their defaults, then one line of counts per destination and the combined report's path. Keep it short; the report holds the detail.

9. **Apply what the developer approves**, then update each finding's Status in the report and commit it the same way.
   - `skill edit`: follow the routing rules in [`reflect`](../../reflect/SKILL.md) step 5.
   - `check`: build it and show it fails on this session's mistake.
   - Land each change per [Landing on main](../../poteto-mode/playbooks/landing-on-main.md). Record `landed <commit>` or `declined by developer`, and write each answered decision under it.

You are done when no finding is `open`, or the developer says to stop. Then tell the developer which findings stay open. If the Stop hook reports failures in files you did not write, other sessions own them; leave them and end your turn again.
