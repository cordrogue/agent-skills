---
name: reflect
description: Spawn three parallel review subagents over the active transcript, surface learnings, and route each to a concrete edit on an existing skill. Use when the user says reflect.
disable-model-invocation: true
---

# Reflect

Mine the current conversation for durable learnings, then route them into skill edits.

## When to invoke

Invoke when the user says "reflect" or "/reflect". Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

## Process

### 1. Locate the active transcript

The parent finds its own transcript file before fanning out. The paths are in [`harness-tools.md`](../poteto-mode/references/harness-tools.md). Do not glob across every project or session. That crosses workspace boundaries and reads private chats from unrelated projects.

```bash
# Claude Code
ls ~/.claude/projects/<encoded-cwd>/"$CLAUDE_CODE_SESSION_ID".jsonl
# Codex
ls ~/.codex/sessions/*/*/*/rollout-*-"$CODEX_THREAD_ID".jsonl
```

Claude Code subagent transcripts sit in `<session-id>/subagents/`. Check that the file holds the conversation's opening user prompt. If no path resolves, write a tight digest of the session and pass that instead.

### 2. Spawn three reviewers in parallel

One fan-out, three native subagents on the parent's model, per the roles below in [`models.md`](../poteto-mode/references/models.md). Reviewers need MCP access for context lookups (tickets, chat threads, observability traces referenced in the transcript), and a cross-provider lane gets none.

| Lens | Role | Prompt template |
|---|---|---|
| Judgment | `reflect judgment, divergent, synthesizer` | `references/judgment-reviewer.md` |
| Tooling | `reflect tooling` | `references/tooling-reviewer.md` |
| Divergent | `reflect judgment, divergent, synthesizer` | `references/divergent-reviewer.md` |

Pass each template verbatim, substituting the transcript path or digest where marked. Reviewers return findings in their final reply.

### 3. Synthesize

One native subagent on the parent's model, role `reflect judgment, divergent, synthesizer`. The synthesizer's quality check includes spot-verifying citations, which can require MCP access. Use `references/synthesizer.md` verbatim, with each reviewer's full output inlined where marked. The synthesizer returns a structured Accepted / Rejected / Backlog list.

### 4. Structural enforcement check

Sanity-check the synthesizer's Accepted list. For any item that would be enforced more reliably by a lint rule, script, metadata flag, or runtime check, move it from Accepted to Backlog. See the **encode-lessons-in-structure** principle skill.

### 5. Apply

Before applying any Accepted edit, present the synthesizer's full Accepted/Rejected/Backlog output to the user and wait for explicit approval. The user picks which subset to apply and may redirect routings. Skill changes affect every future agent in this repository. Do not auto-apply.

Backlog items file to `docs/BACKLOG.md` automatically, one line each under the closest group, per that file's header. Only the Accepted list waits for approval.

For each approved Accepted item, follow the Routing field exactly:

- Trivial existing-skill edit (a one-line bullet, a tightened sentence, a stale fact corrected): parent does directly.
- Substantive existing-skill edit (a new section, a new pattern table, more than ~10 lines): follow the **writing-for-agents** skill and the Authoring a skill playbook (`../poteto-mode/playbooks/authoring-a-skill.md`).
- `tune description: <skill path>` (the skill exists but didn't trigger when it should have): rewrite the description per **writing-for-agents** and its [`SKILL-MECHANICS.md`](../writing-for-agents/SKILL-MECHANICS.md).
- `new skill via writing-for-agents: <kebab-name>`: create it per **writing-for-agents**. Do not invent the shape ad hoc.

If your environment ships a SKILL.md validator, run it on every touched skill before declaring done. Skip this step if it doesn't.

### 6. Summarize for the user

Short list, no preamble:

- Edits applied: `<skill path>`. What changed, one line each.
- New skills created: `<skill path>`. One line each (rare).
- Backlog filed to `docs/BACKLOG.md`: `<entry>` (`<group>`). One line each.
- Dropped: one line per rejected finding + reason from the synthesizer.
