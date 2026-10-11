---
name: reflect
description: Spawn three parallel review subagents over the active transcript, surface learnings, and route each to a concrete edit on an existing skill. Use when the user says reflect.
disable-model-invocation: true
---

# Reflect

Mine the current conversation for durable learnings, then route them into skill edits.

Invoke when the user says "reflect" or "/reflect". Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

## 1. Locate the active transcript

Before fanning out, find this conversation's transcript. The paths are in [`harness-tools.md`](../poteto-mode/references/harness-tools.md). Do not glob across every project or session. That crosses workspace boundaries and reads private chats from unrelated projects.

```bash
# Claude Code
ls "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects/<encoded-cwd>/$CLAUDE_CODE_SESSION_ID.jsonl"
# Codex
ls ~/.codex/sessions/*/*/*/rollout-*-"$CODEX_THREAD_ID".jsonl
```

Claude Code subagent transcripts sit in `<session-id>/subagents/`. Check that the file holds the conversation's opening user prompt. If no path resolves, pass a tight digest of the session instead.

## 2. Spawn three reviewers in parallel

One fan-out, three native subagents on the parent's model, per the roles below in [`models.md`](../poteto-mode/references/models.md). Reviewers need MCP access to look up the tickets, chat threads, and observability traces the transcript references, and a cross-provider lane gets only its own provider's MCP servers.

| Lens | Role | Prompt template |
|---|---|---|
| Judgment | `reflect judgment, divergent, synthesizer` | `references/judgment-reviewer.md` |
| Tooling | `reflect tooling` | `references/tooling-reviewer.md` |
| Divergent | `reflect judgment, divergent, synthesizer` | `references/divergent-reviewer.md` |

Pass each template verbatim, substituting the transcript path or digest where marked. Reviewers return findings in their final reply.

## 3. Synthesize

One native subagent on the parent's model, role `reflect judgment, divergent, synthesizer`. It spot-verifies citations, which can require MCP access. Pass `references/synthesizer.md` verbatim, with each reviewer's full output inlined where marked. It returns an Accepted / Rejected / Backlog list.

## 4. Structural enforcement check

Move any Accepted item that a lint rule, script, metadata flag, or runtime check would enforce more reliably to Backlog. See the **encode-lessons-in-structure** principle skill.

## 5. Apply

Write every edit and backlog line in your own worktree off `main`, per [Landing on main](../poteto-mode/playbooks/landing-on-main.md).

Present the synthesizer's full Accepted / Rejected / Backlog output and wait for explicit approval before applying any Accepted edit. The user picks the subset and may redirect routings. Skill changes affect every future agent in this repository. Do not auto-apply.

File each Backlog item to `docs/BACKLOG.md` without waiting, one line each under the closest group, per that file's header. Only the Accepted list waits for approval.

Follow each approved row's Routing exactly:

- Trivial existing-skill edit (a one-line bullet, a tightened sentence, a stale fact corrected): the parent does it directly.
- Substantive existing-skill edit (a new section, a new pattern table, more than ~10 lines): follow the **writing-for-agents** skill and the Authoring a skill playbook (`../poteto-mode/playbooks/authoring-a-skill.md`). Before it lands, check the edit against the prompt or transcript that exposed the failure.
- `tune description: <skill path>` (the skill exists but didn't trigger when it should have): rewrite the description per **writing-for-agents** and its [`SKILL-MECHANICS.md`](../writing-for-agents/SKILL-MECHANICS.md). Then check that the missed-trigger prompt would now select the skill.
- `new skill via writing-for-agents: <kebab-name>`: create it per **writing-for-agents**. Do not invent the shape ad hoc.

If your environment ships a SKILL.md validator, run it on every touched skill before declaring done.

## 6. Summarize for the user

Short list, no preamble:

- Edits applied: `<skill path>`. What changed, one line each.
- New skills created: `<skill path>`. One line each (rare).
- Backlog filed to `docs/BACKLOG.md`: `<entry>` (`<group>`). One line each.
- Dropped: one line per rejected finding + reason from the synthesizer.
