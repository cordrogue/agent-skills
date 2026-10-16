---
name: command-center
description: "Open the command center, the local page that maps what feeds the AI loops here (checks and how often they fire, skills, always-loaded context, plans and their live state), and add a Sol note on what changed. Use for /command-center."
disable-model-invocation: true
---

# Command center

The page is `scripts/command-center/`. It reads every fact from the repo, the transcript stores and `~/.cache/agent-swarm/` on each refresh, so this skill only starts it, shows it, and adds the note.

## Open the page

1. Run `npm run command-center` in the background from the main checkout, `/home/me/project`. It prints `command center: http://127.0.0.1:4317`. When a server for that checkout is already running it prints the same line and exits. When a server for another checkout holds the port it exits 1 and names that checkout. Tell the developer which checkout it reads; never stop a server you did not start.
2. Open `http://127.0.0.1:4317` in the T3 preview with `preview_open`. Outside T3 Code, give the developer the URL.

## Add the note

1. Find the newest note in `~/.cache/agent-swarm/command-center/runtime/notes/`. With none, run `node scripts/command-center/cli.ts --changes --since <24 hours ago, ISO>` from the main checkout. Otherwise run it without `--since`, which starts where the newest note ended.
2. When it prints `no changes`, or `no saved snapshot to compare with`, say so and stop. No note is written.
3. Otherwise start one Sol lane through `delegate_task`, routed as the `reading and helpers` role in `../poteto-mode/references/models.md`. Its task is the change list's full text pasted in, then: "Summarize what changed for the developer in at most 12 plain lines, grouped by section, most consequential first. Name the file behind each line. Say nothing the list does not show. Read only files the list names. Write no files. End your final message with the line `LANE DONE`."
4. The note is the lane's first message ending in `LANE DONE`. A failing turn-end check adds later turns that replace the `task_status` summary, so when the summary is not a note, read the note with `t3_thread_read` on the lane's `childThreadId`. Save the note, without the `LANE DONE` line, to `~/.cache/agent-swarm/command-center/runtime/notes/<to time>.md` with this front matter, taking both times from the list's first line:

   ```
   ---
   from: <from time>
   to: <to time>
   ---
   ```

5. The Changes section shows the note within 5 seconds, labeled as an AI summary. Reply with the note.

Write nothing else. The page and its scan cache own every other file under `runtime/`.
