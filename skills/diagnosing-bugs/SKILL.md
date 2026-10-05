---
name: diagnosing-bugs
description: "Always load when a bug, failure, or regression needs reproducing or diagnosing."
---

# Diagnosing bugs: build the feedback loop first

**This is the hard part.** If you have a **tight** pass/fail signal for the bug (one that goes red on _this_ bug), you will find the cause; bisection, hypothesis testing, and instrumentation all just consume it. Without one, no amount of reading code will save you. Spend disproportionate effort here.

In `poteto-mode`, this is step 1 of the Bug fix playbook. Afterwards, find the cause with `principle-fix-root-causes` and land the failing check before the fix (`tdd`).

## Redact captured evidence

Replace secrets with `<REDACTED>` before showing commands, output, or artifacts. Read credentials from environment variables so they stay out of the command text. Quote only the signal-carrying lines from HAR files, logs, and payloads, which may contain auth headers or tokens. Request redacted captures when the developer supplies evidence.

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
10. **Human in the loop.** Last resort. Give the developer exact steps and record what they report, only after the options above are exhausted.

## Tighten the loop

Once you have _a_ loop, make it:

- **Faster:** cache setup, skip unrelated startup, narrow the scope.
- **Sharper:** assert on the specific symptom, not "didn't crash".
- **Deterministic:** pin time, seed randomness, isolate the filesystem.

A 30-second flaky loop is barely better than none; a 2-second deterministic one is tight.

**Non-deterministic bugs:** aim for a higher reproduction rate, not a clean repro. Loop the trigger, add stress, narrow timing windows. A 50% flake is debuggable; 1% is not, so keep raising the rate.

**When you cannot build a loop:** say so, list what you tried, and ask the developer for what would reproduce it (the project state, a screen recording, exact steps). Don't move on to hypotheses without a loop.

## Minimize the reproduction

After reproducing the exact symptom, remove inputs, configuration, data, callers, or steps one at a time. Rerun after each removal and keep it only when the same failure remains. Stop when every remaining element contributes to the failure. For a flaky bug, compare reproduction rates and keep the trigger stable. Retain the original scenario for verification after the fix.

## State falsifiable hypotheses

After the reproduction is minimized, rank competing hypotheses and state a prediction for each: "If X is the cause, changing Y should remove the failure, or changing Z should make it worse." Discard claims with no observable prediction. Share the ranked list, then test it without waiting for approval. Each probe changes one variable and rules hypotheses in or out. The Bug fix playbook uses this method for its cause search.

## Done when

You can name **one command** you have **already run** (show it and its redacted output) that is:

- **Red-capable:** it drives the actual bug's code path and asserts the exact symptom, so it goes red on this bug and green once fixed.
- **Deterministic:** same verdict every run (for flaky bugs, a pinned, high reproduction rate).
- **Fast:** seconds, not minutes.
- **Agent-runnable:** it runs unattended.
- **Minimal:** each remaining input or step contributes to the exact failure; the original scenario is retained for final verification.

If you catch yourself reading code to build a theory before this command exists, stop. No red-capable command, no hypotheses.
