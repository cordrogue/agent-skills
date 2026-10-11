---
name: wrap-up-stack
description: Wrap up each thread of a multi-thread plan as it finishes, then review the whole stack's findings at once. Each run commits its thread's retro and reflect reports, and the last run starts one Consolidate thread for the stack.
disable-model-invocation: true
---

# Wrap-up stack

A stack is the set of threads that carry one plan, such as one thread per chunk. The developer types `/wrap-up-stack <stack name>` (in Codex, "use wrap-up-stack") in each thread once its work finishes, and says "last" in the stack's last thread. Each run writes and commits its thread's retro and reflect reports, tagged with the stack, and the last run starts one Consolidate thread that merges every report in the stack, so the developer decides once. The steps reuse [`wrap-up`](../wrap-up/SKILL.md)'s.

`<stack>` is the developer's stack name, slugged by the title-slug rule in [`report-format.md`](../wrap-up/references/report-format.md). Ask for the name when the message has none. When the developer asks only to consolidate a stack, take the mode check and `<main>` from `wrap-up` step 1, then go to step 4.

## Steps

1. **Start this thread's reports.** Run `wrap-up` steps 1 to 3, adding the line `Stack: <stack>` to both task messages. List the stacks that already have reports with `grep -h '^stack:' <main>/docs/reviews/retro/*.md | sort -u`. When `<stack>` is not among them, name the existing ones in your status line, so a mistyped name shows before the reports are written.

2. **Wait for both reports** per `wrap-up` step 4.

3. **Commit them** on `main`: `git -C <main> add <report paths>`, then `git -C <main> commit -m "Add the wrap-up reports for <title>" -- <report paths>`, which leaves out anything else already staged. When `index.lock` blocks the commit, another thread is committing, so wait a few seconds and retry. Unless this is the last thread, tell the developer in one line that the reports are committed under `<stack>` and how many of the stack's threads have reports, then stop.

4. **Gather the stack.** `grep -l '^stack: <stack>$' <main>/docs/reviews/{retro,reflect}/*.md` finds every report. Group them by their `thread` header. A thread with only one report gets `missing: <reason>` for the other. The combined report is `<main>/docs/reviews/combined/<stack>_stack_combined.md`, with `_r2` or later when that file exists.

5. **Start the Consolidate thread** per `wrap-up` step 5, with the title `Consolidate stack: <stack><rerun suffix>` and this message:

   ```
   Read <main>/.agents/skills/wrap-up-stack/references/consolidate-stack.md in full and follow it.

   Stack: <stack>
   Threads:
   - <thread id> | <title> | retro: <path, or 'missing: <reason>'> | reflect: <path, or 'missing: <reason>'>
   Combined report: <combined report path>
   ```

6. **Hand off** per `wrap-up` step 6, naming the combined report path and the number of threads in place of the two report paths.
