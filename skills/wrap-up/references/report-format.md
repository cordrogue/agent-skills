# Wrap-up report format

Every wrap-up writes three reports about one T3 thread, one per folder. Later agents plan from them for months, so names and formats stay fixed.

## Layout

```
<main>/docs/reviews/
  retro/<name>_retro.md
  reflect/<name>_reflect.md
  combined/<name>_combined.md
```

`<main>` is the main checkout. `<name>` is `<session date>_<title slug>_t3-<thread8>`:

- **Session date**: the thread's `createdAt` from `t3_thread_read`, as a local `YYYY-MM-DD` (`date -d <createdAt> +%F`).
- **Title slug**: the thread title without a leading `Wrap-up: `, lowercased, each run of characters other than `a-z` and `0-9` replaced by one `-`, trimmed of `-` at both ends, cut to 60 characters.
- **thread8**: the first 8 characters of the first UUID in the thread id. Ids come bare, with an `mcp:` prefix, or wrapped like a task's `thread:delegated-task:...`, so take the first match of `grep -oE '[0-9a-f]{8}-[0-9a-f]{4}-' | head -n 1 | cut -c1-8`.

A second wrap-up of the same thread appends `_r2` to `<name>`, then `_r3`. No report is overwritten.

Example: `2026-10-05_orchestrate-session-cleanup-and-improvement-loops_t3-33f9a83f_combined.md`.

## Header and end

Every report opens with YAML front matter:

```yaml
---
report: retro            # retro, reflect, or combined
thread: 33f9a83f-f658-4536-a8a4-f1679f303d15
thread_title: Orchestrate Session Cleanup and Improvement Loops
session_date: 2026-10-05
written: 2026-10-09
models: { retro: claude-opus-5-5 }
sources:                 # every transcript and thread the report counted
  - /home/me/.claude/projects/-home-me-project/8c0a705e-626d-4755-941e-c1e2fece1f76.jsonl
  - t3 thread 33f9a83f-f658-4536-a8a4-f1679f303d15
---
```

The combined report adds `retro_report` and `reflect_report` (paths relative to its own folder, or `missing: <reason>`), `consolidate_thread` (its own thread id), and `counts` (findings per destination). Its `models` lists every role that ran, Sol's review included.

Every report ends with this line, which tells the waiting thread the file is complete:

```
<!-- wrap-up report complete -->
```

## Retro report

1. `## Session scope`: what counted as the session and why.
2. `## Findings`: one `### R<nn> <title>` per candidate, in severity order, with these fields:
   - **Category**: retro's category, such as Navigation or Automated checks.
   - **Severity**: `high` cost the session real time or produced a wrong result, `medium` cost some, `low` is polish.
   - **Evidence**: transcript path and line, or a short quote.
   - **Change**: the proposed change and the file it lands in.

## Reflect report

1. `## Session scope`: what counted as the session and why.
2. `## Synthesizer output`: the synthesizer's Accepted, Rejected, and Backlog lists, verbatim.
3. `## Moved to backlog by step 4`: each item reflect's structural check moved, with its reason.
4. `## Reviewer outputs`: `### Judgment`, `### Tooling`, and `### Divergent`, each reviewer's full output, verbatim.

## Combined report

1. `## Decisions for the developer`: numbered, each with its default in brackets, written per the **user-communication** skill.
2. `## Findings`: one `### <id> <title>` per finding, in severity order. The id is `<thread8>-F<nn>`, or `<thread8>-r2-F<nn>` in a rerun. Ids never change once committed, because backlog lines and commits cite them. Fields:
   - **Source**: `retro R<nn>`, `reflect <list> <n>`, or both.
   - **Severity**: as in the retro report.
   - **Evidence**: transcript path and line, or a short quote.
   - **Change**: what to change, and where.
   - **Destination**: one of the destinations below.
   - **Status**: `open`, `landed <commit>`, `filed to backlog`, or `declined by developer`.
3. `## Disagreements`: where the two reports conflicted and how it was settled.
4. `## Rejected`: each dropped finding, its source, and the reason.
5. `## Leftovers`: worktrees, branches, and untracked files the session left behind. Wrap-up lists them and never deletes them.
6. `## Review`: each finding from Sol's review and what was done with it.

## Stacks

[`wrap-up-stack`](../../wrap-up-stack/SKILL.md) writes each thread's retro and reflect reports as above, adding `stack: <stack>` to the front matter when a task message names a stack. The stack gets one combined report instead of one per thread:

- **File**: `combined/<stack>_stack_combined.md`, with `_r2` and later for a rerun.
- **Front matter**: `stack` in place of `thread`, `thread_title`, and `session_date`. `threads` lists each thread id with its title. `source_reports` replaces `retro_report` and `reflect_report`, with one path or `missing: <reason>` per thread and report.
- **Ids**: `<stack>-F<nn>`, or `<stack>-r2-F<nn>` in a rerun.
- **Source**: each source starts with its thread's thread8, as in `1a2b3c4d retro R03`.

## Destinations

Each finding in the combined report gets exactly one destination, which the consolidate thread assigns and Sol's review checks against these rules.

- `check: <what fails on the mistake>`: a lint rule, type, test, or hook fitting one commit. Mechanical rules, such as banned calls or file-location rules, get one.
- `backlog`: a mechanical rule whose check needs more than one commit, or other work outside one commit. This settles the case where retro says build the check now and reflect's step 4 moved it to the backlog.
- `skill edit: <skill path>`: a judgment rule no check can catch, placed in the skill an agent reads when the rule applies; also a description rewrite or a new skill. A change retro aims at `AGENTS.md` or `CODING_STANDARDS.md` goes here, because `AGENTS.md` stays empty and this repo has no `CODING_STANDARDS.md`.
- `decision`: a product or direction question only the developer answers.
- `rejected`: listed under `## Rejected` with its reason.

A rule with a row under **Skill text only** in [`repeat-mistakes`](../../repeat-mistakes/SKILL.md) that was broken again is a repeat, and moves up a level per that skill: `check` when a check can catch it, otherwise a `skill edit` that moves the rule to where the agent reads it at the moment it applies.
