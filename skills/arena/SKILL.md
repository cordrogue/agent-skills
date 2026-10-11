---
name: arena
description: "Spawn N parallel candidates at the same task, pick a base, graft the strongest parts of the losers into it. Use for /arena, 'arena this', 'throw it in the arena', or when one attempt at a non-trivial artifact would lock in the wrong shape."
disable-model-invocation: true
---

# Arena

Open a todolist with one entry per phase (Frame, Fan out, Cross-judge, Pick, Graft, Verify) before launching anything.

## Phase A: Frame

Every candidate gets the same prompt, so the prompt is the contract.

1. State the artifact each candidate is producing.
2. Derive the rubric, 3-6 concrete gradeable criteria for what success looks like on *this* task. It is the picker's tool in Phase D. Candidates only see the task.
3. Pick the runners. Use the `arena runners` role in [`models.md`](../poteto-mode/references/models.md), one runner per entry, routed as that file says. A runner whose model runs on the parent's provider is a native subagent. Any other runner takes the cross-provider route. If a runner's model is unavailable, record a dropout. Never substitute another model. Spawn more runners when the arena covers multiple design directions. Use the same model N times when the work is generation-bound rather than judgment-sensitive.
4. Give each candidate its own output location (a git worktree where possible, otherwise `~/.cache/agent-swarm/arena-<slug>/candidate-<n>/`), per the **separate-before-serializing-shared-state** principle skill. A `delegate_task` or `Agent` runner writes its whole package there and replies with the path and a summary of at most 20 lines. K1's runner replied with a 99,463-character package, which overflowed `task_status`.

## Phase B: Fan out

Start all N candidates in one fan-out, each in the background with its handle kept, each with the task, the path to the shared grounding, its own output path, and instructions to produce the artifact and a short rationale naming the alternatives it considered and what it rejected.

If a candidate produces no output, proceed with N-1 and note the dropout. Record the model each candidate ran on.

## Phase C: Cross-judge

After all Phase B candidates complete, check whether they converge on one shape. If they do, probe or grep each "nothing does X today" premise. Give the judge the results, and note that agreement among runners sharing one owner-written grounding is dependent evidence. Then choose one model from the `arena cross-judge pool` role in `models.md`. Prefer a different model family from the parent's. Spawn one read-only judge on that model, routed per `models.md`. It sees the rubric and the candidates by path label, scores each criterion, and recommends a base with rationale. It runs in parallel with your reading in Phase D. Don't spawn it while candidates are still writing.

## Phase D: Pick a base

Read every candidate end to end before picking. Score each against the rubric criterion by criterion, not on holistic feel, and compare with the cross-judge. Agreement on the base confirms the pick. Disagreement means one of you is biased or the rubric was ambiguous. Read both rationales before deciding.

Pick the base a future maintainer can extend most easily without breaking invariants. When two feel tied, prefer the cleaner boundary or smaller API, per the Laziness Protocol.

## Phase E: Graft

Walk each losing candidate once more for what is worth porting into the base, usually one or two things per candidate, not most of it. Fold each graft in per the **redesign-from-first-principles** principle skill, so the result stays coherent under one mental model. An Opus writer applies code grafts in its own worktree, and you review its diff. Apply other grafts by hand. Don't paste mechanically.

If the candidates converge on one shape, record the convergence and the premise checks, and ship the base Phase D picked. No graft is needed. If they wildly diverge, Phase A was under-specified. Reframe and re-run rather than averaging the divergence.

## Phase F: Verify

Verify the synthesized artifact like any other output, per the **prove-it-works** principle skill. If verification finds a problem the arena missed, either Phase A was wrong (re-frame and re-run) or a candidate caught it and you missed the graft (go back to Phase E). Don't paper over it.

## Outputs

One synthesized artifact, with a short synthesis note alongside naming the base and why, the cross-judge's verdict, each graft with its source candidate, what was rejected and why, any convergence or dropouts, and the verification result.
