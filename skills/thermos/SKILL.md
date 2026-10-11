---
name: thermos
description: "Launch both thermo-nuclear review subagents in parallel, then synthesize their findings. Use for thermos, double thermo review, or combined bug/security and code-quality branch audits."
disable-model-invocation: true
---

# Thermos

Run the two thermo review passes as background subagents in parallel, then synthesize their results.

## Workflow

1. Determine the review scope from the user request, current branch, or relevant changed files. By default it is everything since `main`: `git diff $(git merge-base main HEAD)` (commits plus staged and unstaged changes) and `git ls-files --others --exclude-standard` (untracked files), or a range the user names. Stop if both are empty.
2. Gather the diff and any file/context excerpts needed for reviewers to evaluate the change without guessing. Put them in the prompt under `### Git / diff output` and `### Untracked files`.
3. Launch both reviewers in the same message, in the background, read-only. Tool names per harness are in [`harness-tools.md`](../poteto-mode/references/harness-tools.md).
   - Bugs, breakages, security, devex regressions, feature-flag leaks, and other branch-audit risks. Claude Code: `Agent` with `subagent_type: "thermo-nuclear-review-subagent"`. Codex: `spawn_agent` whose instructions start with "Read `.agents/skills/thermo-nuclear-review/SKILL.md` in full first."
   - Maintainability, structure, file-size growth, spaghetti, abstractions, and codebase-health risks. Claude Code: `Agent` with `subagent_type: "thermo-nuclear-code-quality-review-subagent"`. Codex: `spawn_agent` whose instructions start with "Read `.agents/skills/thermo-nuclear-code-quality-review/SKILL.md` in full first."
   - Model: the `thermos reviewers` role in [`models.md`](../poteto-mode/references/models.md). Both run on the parent's model unless the user asks otherwise.
4. Pass each subagent the same scoped diff/file context and ask it to return prioritized findings with file references and evidence.
5. After both finish, synthesize the results with findings first, deduplicated across reviewers. Weight overlapping findings more heavily, resolve disagreements with your own judgment, and keep summaries brief.

If individual background summaries are already visible to the user, do not restate them wholesale. Surface the unified verdict, the highest-signal findings, and any remaining uncertainty.
