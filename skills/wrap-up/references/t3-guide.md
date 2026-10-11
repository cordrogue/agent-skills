# T3 Code for wrap-up reviewers

T3 Code is the app the developer runs agents in. It hosts Claude Code and Codex sessions in one window, and a T3 thread is one conversation in its sidebar. You decide what counts as the session you review. Write that scope and its reason in your report's `## Session scope`, and list every transcript and thread you counted under `sources`.

## One thread

- A thread has an id, a title, a project, and a checkout: main, or a worktree. The id is a UUID, with an `mcp:` prefix when an agent launched the thread, or wrapped as `thread:delegated-task:...` for a task's child thread.
- `t3_thread_read` on the thread id returns the thread's state and its timeline of developer and assistant messages across every provider the thread used, and is the only record covering a thread from first message to last. `view: "activity"` adds tool items. Page with `afterPosition` set to the last `nextPosition`.
- A thread can switch provider or hand its context to a fresh session. The provider transcript then starts partway through, with the first line `Provider context handoff. Thread: <id>`, and the earlier history exists only in `t3_thread_read`. Thread `33f9a83f` started in Codex on 2026-10-05, and its Claude transcript starts on 2026-10-07.
- Provider transcripts hold the tool-level detail: every command, file read, and error. Their paths are in [Transcripts](../../poteto-mode/references/harness-tools.md#transcripts). To find every Claude transcript of a thread, `grep -l <thread id>` in the thread's transcript folder. Codex transcripts may not name the T3 thread id, so match them to `t3_thread_read` by time and opening prompt.

## Work a thread started

- **Native subagents** (Claude Code's `Agent` tool): transcripts at `<session id>/subagents/agent-<id>.jsonl` beside the parent transcript, each with a `.meta.json`.
- **T3 tasks** (`delegate_task`): each runs in its own child thread. The parent transcript's `delegate_task` results hold the `taskId` and `childThreadId`; read a child with `t3_thread_read` on its `childThreadId`. `t3_thread_list` with `includeSubagents: true` lists them.
- **New threads** (`t3_thread_launch`): separate top-level threads, whose ids are in the launch results.
- **CLI lanes** (`codex exec` or `claude -p` run in background Bash): only their prompt and output files remain. The parent transcript names them.
- **Cost**: `node scripts/agent-cost.mjs <session id> [agent]` sums a session's token use across its subagent transcripts.

## Reading

Transcripts run to megabytes. Grep first, then read only the matching regions, and only in the transcripts of this thread and the work it started, never other projects' or unrelated sessions'.
