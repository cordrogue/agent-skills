---
name: repeat-mistakes
description: "Always load when the developer corrects an agent's mistake, and when running correct. Lists each rule agents broke more than once and what enforces it."
---

# Repeat mistakes

This is the rule table the `correct` skill keeps. AGENTS.md stays empty, so read "the agent instruction file" in `correct` as this file.

When the developer corrects a mistake:

1. Find the rule's row. A row under **Skill text only** makes the mistake a repeat: enforce it at the highest level `correct` lists, in the same change, and move the row up.
2. With no row, put the rule where an agent reads it at the moment it applies, then add a row.
3. Delete a row once its mistake can no longer happen, for example because the old path is gone.

Each row is done when its "Enforced by" cell names a check, hook, type, or design that fails on the mistake, or, for a judgment call no check can catch, the skill section that states it.

## Enforced by a check or hook

| Rule | Enforced by |
|---|---|
| AGENTS.md stays empty. Agent guidance goes in a skill whose description says when to load it. | `scripts/skill-list.test.mjs` |
| Every skill folder is named in `docs/humans/USER.md`, and a skill an agent creates gets a row in its Agent-created skills table. | `scripts/skill-list.test.mjs` |
| Format with Biome, never Prettier. | `scripts/feedback/pre-commit-fix.mjs` formats staged files; `scripts/agent-hooks/bash-guard.mjs` and, in Codex, `.codex/rules/project.rules` refuse `prettier` |
| Stop a process by its pid or process group, never `pkill -f`. | `scripts/agent-hooks/bash-guard.mjs`; in Codex, `.codex/rules/project.rules` |
| Keep work on a branch or in its own worktree, never `git stash`. | `scripts/agent-hooks/bash-guard.mjs`; in Codex, `.codex/rules/project.rules` |
| A commit that only shrinks files never fails on the file-growth allowlist. | `scripts/feedback/pre-commit-fix.mjs` tightens it; `scripts/guardrail-trailer.mjs` asks no trailer for a lowered limit |
| Errors from a dev server older than the build config don't block; restart that server. | `scripts/dev-vite.mjs` restarts the dev server when a file in `startOnlyFiles.server` (`scripts/lib/dev-restart.mjs`) changes and resolves the old server's errors; `scripts/runtime-errors.mjs` marks any left over stale, and `scripts/feedback/check.mjs` reports them as a note |
| Every agent hook lives in both `.claude/settings.json` and `.codex/hooks.json`. | `scripts/agent-hooks/hook-parity.test.mjs` |
| Time startup with `time-to-content` on a window nobody is viewing; first paint never records there. | `scripts/startup-profile.mjs` fails when no run paints |
| A rewrite never drops a program's `docs/work/*/decisions.tsv`. | `.githooks/reference-transaction` refuses a branch move onto a commit that deletes it without a `Guardrail-Change:` trailer |
| Checkpoint with a `WIP:` subject, never `--no-verify`, and squash `WIP:` commits before main. | `.githooks/commit-msg` skips the full check for `WIP:`; `.githooks/reference-transaction` and `.githooks/pre-push` refuse `WIP:` commits on main |

## Skill text only

| Rule | Where it lives |
|---|---|
| Opus writes all code, tests included. Sol and Astra read, review, and verify. | `poteto-mode/references/models.md` |
| Each Codex lane gets the sandbox and worktree its job needs. | `poteto-mode/references/models.md`, the lane table |
| A unit merges when no P1 and no regression is open. After round 4, propose a scope cut. | `swarm/references/fix-rounds.md` |
| Cases the spec doesn't cover go to the developer as one batch of decisions. | `swarm/references/fix-rounds.md` |
| A fix brief names the whole defect family, not one scenario. | `swarm/references/fix-rounds.md`, Fix briefs |
| `PASS` needs the comparison run and the surface reached; `BLOCKED` is never upgraded. | `swarm` Phase B and C |
| Gate on the developer only units meant to look or behave differently. | `poteto-mode/playbooks/multi-phase-plan.md`, Verification |
| A program built to prove one claim starts with a thin real slice of it. | `poteto-mode/playbooks/multi-phase-plan.md`, step 2 |
| Another model reviews a plan before it goes to the developer. | `poteto-mode/playbooks/multi-phase-plan.md`, step 7 |
| A subagent waits for a background helper by ending its turn, except after a SendMessage resume, when a turn end is its report. | `poteto-mode` Subagents, Waiting as a subagent |
| Resume an agent stopped by a usage limit instead of relaunching it. | `swarm` Phase B |
| Start a fresh helper each fix round; replace an owner after two rounds. | `poteto-mode` Subagents; `poteto-mode/playbooks/autonomous-run.md` |
| One writer per worktree; readers get a detached worktree at a pinned commit. | `poteto-mode` Subagents; `poteto-mode/references/harness-tools.md` |
| Program scratch goes under `~/.cache/agent-swarm/<unit>/`, not `/tmp`. | `poteto-mode/references/harness-tools.md`, Scratch |
| Measure an agent's cost with `scripts/agent-cost.mjs`, not `subagent_tokens`. | `poteto-mode/references/harness-tools.md`, Subagents |
| Stop the loop while every open item waits on the developer. | `poteto-mode/playbooks/autonomous-run.md`, step 2 |
| Keep one running list of the defaults applied for the developer. | `poteto-mode` Non-negotiables; `user-communication` |
| Speed on larger projects stays in alpha scope. | `alpha-build`, One project's data |
| Confirm domain assumptions taken from current code before redesigning. | `architect` Phase A |
| A check written by the code's own author proves agreement, not correctness. | `testing`, Writing tests |
