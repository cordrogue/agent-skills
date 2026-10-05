# Performance evidence

Read and apply [benchmark-checklist](../benchmark-checklist/SKILL.md) before
reporting a measured result. The fixture and display-specific checks below
remain part of the evidence.

A source-level argument does not prove a claim about frame time or startup
speed. Next to each task, record the fixture, build, machine, load average,
command, and the before and after results.

- Frame budget is 1000 ms divided by the refresh rate. Fix regressions against
  60 Hz (16.7 ms) and also report 120 Hz (8.3 ms), the developer's display,
  and 165 Hz (6.1 ms), kept as headroom.
- Per gesture, report intervals over budget (a true count, budget from
  `--frame-rate`), missed frames (over 1.5x the interval), main-thread busy and
  layout per frame, long tasks, React commits, and IPC reads, with project size
  and trace duration.
- The profile scripts drive a production build in an offscreen Electron window
  and take `--help`: `gesture-profile.mjs` (board, map, and timeline gestures),
  `shell-resize-profile.mjs`, `timeline-zoom-profile.mjs`, and
  `agent-stream-profile.mjs`. They share `scripts/lib/electron-harness.mjs` and
  `scripts/lib/frame-trace.mjs`.
- For startup timing, build, then run `node scripts/startup-profile.mjs --help`.
  It opens a visible window, so before any perf lane starts the orchestrator
  installs the window rule from the `silent-workspace-test` skill; a subagent
  may not install it. On that unviewed workspace Chromium never records first
  paint, and `time-to-first-paint` reads missing. Metrics that work there or
  offscreen are `time-to-content` (`renderer:workspace-content`), the
  `shell-resize-profile.mjs` p95, and built CSS bytes. A Sol perf lane needs
  the verification-lane sandbox in
  [models.md](../poteto-mode/references/models.md).
- The machine is shared. Alternate before and after runs under the same load
  and weigh only the gaps between paired runs. A perf gate compares medians of
  30 or more runs per side, never the slowest of a few runs, and reports
  INCONCLUSIVE instead of failing when the load average is above about
  `nproc`/4.
- Browser traces cannot see host or main-process blocking. The host runs in
  its own process; `node scripts/host-stall-bench.mjs` measures key delay in
  the page while the host works. Measure other main-process work in the owning
  feature's check.
