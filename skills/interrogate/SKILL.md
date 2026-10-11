---
name: interrogate
description: "Use for \"interrogate\", \"adversarial review\", \"multi-model review\", \"challenge this\", \"stress test this code\", \"find blind spots\", or \"tear this apart\". Multiple LLM reviewers challenge changes from independent angles."
disable-model-invocation: true
---

# Interrogate

Spawn one reviewer per configured model to adversarially review code changes. The adversarial signal comes from model diversity, not assigned personas. The deliverable is a synthesized verdict. Do NOT auto-apply changes.

## Step 1, Scope

Identify what to review from context:

- If the user points at specific files or a diff, use that.
- If on a feature branch, run `git diff main...HEAD` (or the appropriate base branch) for the full changeset.
- If the user's message references recent work, gather the relevant files.

Give reviewers a worktree at the head under review and the exact `git diff <base>...<head>` command to run there, or the file paths. Reviewers read the surrounding code themselves, which a pasted diff hides. For an unmerged branch, the worktree is a detached one at its head, per `models.md`.

## Step 2, Intent

Before spawning reviewers, state the intent in one clear paragraph from the user's message, commit messages, the code, and the spec or work paper if one exists. Find a spec through `docs/README.md`. Plans live in `docs/work/`. If you found a spec, read it and give reviewers its path. If you're unsure about the intent, ask the user before proceeding.

## Step 3, Spawn Reviewers

Launch all reviewers in one fan-out, in the background, one per entry in the `interrogate reviewers` role in [`models.md`](../poteto-mode/references/models.md), labeled Reviewer A, B, and so on to match the entry count.

| Subagent | Model |
|----------|-------|
| Reviewer A | Opus |
| Reviewer B | Sol |

Every reviewer is read-only and routed per `models.md`. A reviewer whose model runs on the parent's provider is a native subagent. The other takes the cross-provider route.

If a reviewer's model is unavailable, record it as a dropout and say so. A reply of "No findings." that names nothing it checked is also a dropout. Never substitute another model. Do not block the review on a dropout.

Read `references/reviewer-prompt.md` and fill in the same template for every reviewer with the stated intent, the worktree path and the `git diff` command or the file paths, the rubric from `references/rubric.md`, the code-quality lens from `references/code-quality-review.md`, and the spec path from Step 2 or "none".

## Step 4, Synthesize

As results come back, build a unified picture. Parse every reviewer's findings. Merge findings that describe the same issue differently, and note which models raised each one. Findings two or more models raised independently are the highest signal. Read a lone model's finding, but weight it accordingly. Note disagreements. If one model flags something and another explicitly says the opposite, that is context for the verdict.

## Step 5, Lead Judgment

You are the lead reviewer, a pragmatic senior engineer, not a neutral aggregator. Read `references/lead-judgment.md` for the full framework. Put every finding in one of four buckets, with the model(s) that raised it and a one-line rationale.

- **Act on**. Real issues affecting correctness, security, or maintainability given the actual goals. They would block a real merge.
- **Consider**. Legitimate, but you're not sure they outweigh the cost of addressing them now. Worth the user's attention.
- **Noted**. Technically valid but not actionable. Context-dependent, premature optimization, or low-impact at this stage.
- **Dismissed**. Wrong, nitpicky, or missing context, with a brief reason.

## Output Format

### Intent
> [The stated intent paragraph from Step 2]

### Reviewers
- Reviewer [label]: [model name], [N findings] (one bullet per reviewer)

### Act On
[Each: description, which models raised it, why it matters.]

### Consider
[Each: description, which models raised it, the tradeoff.]

### Noted
[Brief list.]

### Dismissed
[Each with a brief rationale.]

### Agreement Map
[Where models agreed and diverged, and what that pattern tells us.]
