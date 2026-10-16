---
name: wrap-up-stack
description: Wrap up a plan that ran as several threads, or as one orchestrator's tree of nested T3 tasks. Writes retro and reflect reports for each thread or branch, then starts one Consolidate thread that reviews the whole stack's findings at once.
disable-model-invocation: true
---

# Wrap-up stack

A stack is the set of threads that carry one plan. It comes in two shapes:

- **Separate threads**, such as one thread per chunk. The developer types `/wrap-up-stack <stack name>` (in Codex, "use wrap-up-stack") in each thread once its work finishes, and says "last" in the stack's last thread. Follow Steps.
- **A task tree**: one orchestrator thread whose work ran as nested T3 tasks. The developer types `/wrap-up-stack` once in the orchestrator. Follow Task trees.

Either way, each thread's retro and reflect reports are written and committed, tagged with the stack, and one Consolidate thread merges every report in the stack, so the developer decides once. The steps reuse [`wrap-up`](../wrap-up/SKILL.md)'s.

`<stack>` is the developer's stack name, slugged by the title-slug rule in [`report-format.md`](../wrap-up/references/report-format.md). Ask for the name when the message has none, except in a task tree, where the stack is the orchestrator's title slug. When the developer asks only to consolidate a stack, take the mode check and `<main>` from `wrap-up` step 1, then go to step 4.

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

## Task trees

A tree's **branches** are its T3 tasks that started T3 tasks of their own, at any depth. The orchestrator and each branch get one retro and one reflect report, each covering its thread and everything under it down to the next branch. A task that started no tasks, and every native subagent, falls under its parent's reports.

1. **Read the orchestrator.** Run `wrap-up` steps 1 and 2 in the orchestrator's thread.
2. **Find the branches.** Page `t3_thread_list` with `includeSubagents: true` and `limit: 100`, newest first, until a page reaches threads created before the orchestrator. Each thread's `parentThreadId` names its parent, and a task's thread id starts `thread:delegated-task:`. Walk down from the orchestrator's id, list each branch's thread id and title, and find each branch's transcript per [`t3-guide.md`](../wrap-up/references/t3-guide.md#one-thread). When there are no branches, tell the developer to run `/wrap-up` instead, and stop.
3. **Start every report.** Run `wrap-up` step 3 for the orchestrator and again for each branch, every call in one response, building each `<name>` from that task's own thread. Add two lines to every task message: `Stack: <stack>`, and `Branches: <every branch's thread id>`.
4. **Finish** with Steps 2 to 6, waiting for and committing every task's report, with the orchestrator as the stack's last thread.
