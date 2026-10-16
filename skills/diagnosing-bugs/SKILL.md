---
name: diagnosing-bugs
description: "Always load when a bug, failure, or regression needs reproducing or diagnosing."
---

# Diagnosing bugs: build the feedback loop first

**This is the hard part.** With a **tight** pass/fail signal for the bug (one that goes red on _this_ bug), you will find the cause; bisection, hypothesis testing, and instrumentation all consume it. Without one, reading code won't save you. Spend disproportionate effort here.

In `poteto-mode`, this is step 1 of the Bug fix playbook. Then find the cause with `principle-fix-root-causes` and land the failing check before the fix (`tdd`).

## Redact captured evidence

Replace secrets with `<REDACTED>` before showing commands, output, or artifacts. Read credentials from environment variables, not the command text. From HAR files, logs, and payloads, which may carry auth headers or tokens, quote only the signal-carrying lines. For developer-supplied evidence, request redacted captures.

## Ways to build one, in roughly this order

1. **Failing test** at whatever seam reaches the bug (`npm test -- <path>`; see the `testing` skill).
2. **Scripted call** into the running app, through `window.app` or the local MCP endpoint (`scripts/mcp-smoke.mjs` shows how).
3. **Script with a fixture input**, diffing its output against a known-good result.
4. **Drive the real app** with `scripts/verify-electron.mjs` (the `verify-electron` skill), asserting on the DOM, renderer errors, or main-process failures.
5. **Replay captured data.** Copy the project state or payload where the bug happened (never modify the developer's own project) and run it through the code path in isolation.
6. **Throwaway harness.** A minimal slice of the system that exercises the bug's code path with one call.
7. **Property or fuzz loop.** For "sometimes wrong" output, run many random inputs and look for the failure.
8. **Bisection.** If it worked at a known commit, script the check and run `git bisect run` with it.
9. **Differential loop.** Run the same input through the old and new build, or two configurations, and diff.
10. **Human in the loop.** Last resort, once the options above are exhausted: give the developer exact steps and record what they report.

## Tighten the loop

Once you have _a_ loop, make it faster (cache setup, skip unrelated startup, narrow the scope), sharper (assert on the specific symptom, not "didn't crash"), and deterministic (pin time, seed randomness, isolate the filesystem). A 30-second flaky loop is barely better than none; a 2-second deterministic one is tight.

**Non-deterministic bugs:** aim for a higher reproduction rate, not a clean repro. Loop the trigger, add stress, narrow timing windows. A 50% flake is debuggable; 1% is not, so keep raising the rate.

**When you cannot build a loop:** say so, list what you tried, and ask the developer for what would reproduce it (the project state, a screen recording, exact steps). A probe's "not reproduced" or zero count holds only if the same probe has caught a forced positive on the same surface; a branch it never reached is unproven.

## Minimize the reproduction

After reproducing the exact symptom, remove inputs, configuration, data, callers, or steps one at a time, rerunning after each and keeping a removal only if the same failure remains. Stop when every remaining element contributes. For a flaky bug, compare reproduction rates and keep the trigger stable. Keep the original scenario for verifying the fix.

## State falsifiable hypotheses

Once minimized, rank competing hypotheses, each with a prediction: "If X is the cause, changing Y should remove the failure, or changing Z should make it worse." Discard claims with no observable prediction. Share the ranked list, then test without waiting for approval. Each probe changes one variable and rules hypotheses in or out.

## Done when

You can name **one command** you have **already run** (show it and its redacted output) that is:

- **Red-capable:** it drives the actual bug's code path and asserts the exact symptom, so it goes red on this bug and green once fixed.
- **Deterministic:** same verdict every run (for flaky bugs, a pinned, high reproduction rate).
- **Fast:** seconds, not minutes.
- **Agent-runnable:** it runs unattended.
- **Minimal:** each remaining input or step contributes to the exact failure.

If you catch yourself reading code to build a theory before this command exists, stop. No red-capable command, no hypotheses.
