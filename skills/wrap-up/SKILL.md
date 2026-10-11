---
name: wrap-up
description: Wrap up a finished thread. Runs retro and reflect as T3 tasks, then starts a new thread that merges their reports, has Sol review the result, and files the backlog.
disable-model-invocation: true
---

# Wrap-up

The developer types `/wrap-up` (in Codex, "use wrap-up") in a thread whose work has finished. This thread only starts the work: two T3 tasks write the retro and reflect reports, then a new thread merges them, has Sol review the merge, files backlog lines, and takes the developer's decisions. This thread's job ends once that new thread has started.

Reports live in the main checkout's `docs/reviews/`, whichever checkout this thread runs in. [`references/report-format.md`](references/report-format.md) owns the layout, file names, and every report's format.

## Steps

1. **Read this thread.**
   - Call `orchestrator_capabilities`; `parentThreadId` is this thread's id. `t3_thread_launch` needs `runtimeMode` `full-access` and `interactionMode` `default`. If either differs, ask the developer to switch this thread to full access and default mode, and stop.
   - Call `t3_thread_read` on that id with `limit: 1` for the `title` and `createdAt`.
   - Find the main checkout with `git worktree list --porcelain | sed -n '1s/^worktree //p'`. Every path below is absolute under it, written `<main>`.
   - Find this thread's current transcript per [Transcripts](../poteto-mode/references/harness-tools.md#transcripts) and check that the file exists.
   - Build `<name>` per `report-format.md`, then `mkdir -p <main>/docs/reviews/{retro,reflect,combined}`.

2. **Rename this thread** to `Wrap-up: <title>` with `t3_thread_update`, `action: "rename"`, and no `threadId`, unless the title already starts with `Wrap-up: `.

3. **Start the two tasks** with two `delegate_task` calls in one response:

   ```json
   {
     "task": "Read <main>/.agents/skills/wrap-up/references/retro-task.md in full and follow it.\n\nThread: <thread id>\nTitle: <title>\nThread transcript: <transcript path>\nReport: <main>/docs/reviews/retro/<name>_retro.md",
     "title": "wrap-up retro: <title>",
     "role": "review",
     "target": { "providerInstanceId": "<claude instance>", "model": "claude-opus-5-5", "options": { "effort": "high" } },
     "mode": "async",
     "clientRequestId": "wrap-up:<name>:retro:try1"
   }
   ```

   The reflect call is the same with `reflect` in place of `retro`. `<claude instance>` is `inheritedProviderInstanceId` when it names a Claude instance, otherwise `claudeAgent`. Both run on Opus per the `wrap-up` rows in [`models.md`](../poteto-mode/references/models.md), as T3 tasks rather than native subagents so each shows in T3 as its own session and reflect can start its own reviewers. Send the developer one line saying both tasks started, then end the turn.

4. **Wait for both reports.** Each task's completion wakes this thread; read it with `task_status`. A task is done when its status is `completed` and its report's last line is `<!-- wrap-up report complete -->`. Any other end is a dropout: run that task once more with `try2` in its clientRequestId, and after a second dropout go on without that report. While the other task still runs, reply with one status line and end the turn.

5. **Start the consolidate thread** once both tasks are done or dropped:

   ```json
   {
     "title": "Consolidate: <title> (t3-<thread8><rerun suffix>)",
     "workspaceStrategy": { "type": "root" },
     "modelSelection": { "instanceId": "<claude instance>", "model": "claude-opus-5-5", "options": [{ "id": "effort", "value": "high" }] },
     "message": "Read <main>/.agents/skills/wrap-up/references/consolidate.md in full and follow it.\n\nWrapped-up thread: <thread id>\nTitle: <title>\nThread transcript: <transcript path>\nRetro report: <path, or 'missing: <reason>'>\nReflect report: <path, or 'missing: <reason>'>\nCombined report: <main>/docs/reviews/combined/<name>_combined.md"
   }
   ```

   `<rerun suffix>` is the `_r2` or later suffix of `<name>`, or nothing. `t3_thread_launch` has no retry key, so after an error look for the title with `t3_thread_list` and `titleContains` before launching again. A launched thread never wakes this one: read it with `t3_thread_read`, up to five times, until its status leaves `preparing`, `queued`, and `starting`. If it ends `failed` or never leaves those states, give the developer the launch message to start the thread by hand.

6. **Hand off.** Tell the developer, in two lines, the new thread's title and the two report paths. That thread is their next stop.
