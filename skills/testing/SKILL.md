---
name: testing
description: "Always load when writing, changing, or running tests, verifying a change before calling it done, or reviewing runtime errors."
---

# Testing

Two kinds of checks. **Gates** run on you automatically. The **ladder** is what
you run yourself between gates: pick the lowest rung that can go red on your
change, and climb only when the change reaches something that rung cannot see.

## Gates

| When | What runs |
| --- | --- |
| Turn end (Stop hook) | `check:fast` (format, lint, typecheck, tests that import changed files), then the runtime error backlog. Biome is the formatter, so fix a format finding with `npx biome format --write <file>` |
| `git commit` | The same check; it reuses the turn-end result when the commit holds the whole working tree. A checkpoint commit whose subject starts with `WIP:` skips it, and main refuses `WIP:` commits, so squash them before merging |
| `git push` | `verify:code`: dependency checks, the full suite, and a production build |

A clean gate prints nothing, and an unchanged tree reuses the last clean
result. Leave `check:fast` to the gate.

A failing gate prints lines starting `feedback (`, each naming a file and
line; the full output is in `.tmp-vite/feedback/last-failure.md`. Fix every
finding. The hook re-checks each time you end the turn and gives up after three
failures in a row, so a turn that ends on that third failure ends unverified;
report it as failing. For a `runtime-error` finding, follow
[runtime-errors.md](runtime-errors.md). If the developer asked for a failing
test, report the expected failure and stop.

Subagents, and lanes started with `APP_SKIP_STOP_CHECK=1`, get no turn-end
gate. Run the gate yourself before reporting done, with stdin closed or it
waits forever:

```bash
mise exec node@24.18.0 -- node scripts/feedback/check.mjs </dev/null
```

## Ladder

| Rung | Run | When | Cost |
| --- | --- | --- | --- |
| Focused | `npm run typecheck`, `npm test -- <path>` | While editing, after each step you'd want to know broke | Seconds |
| Branch | `npm test -- --changed=main` | Before reporting a branch done; covers committed and uncommitted changes | Seconds to a minute |
| Smoke | `npm run test:smoke` | Electron main, preload, MCP, packaging, or SQLite changed | About 10 s with the build |
| Full | `npm test` | Tests could reach the change without importing it: fixtures, sample data, config, test setup | About 50 s |
| Live | `verify-electron` skill | The behavior is visible only in the running app | Minutes |
| Merge | `npm run verify` | Before a merge or release | About a minute |

Live checks stay on the changed workflow; routine edits need no theme, zoom, or
accessibility sweep. `verify-electron` builds your checkout, runs it on a fresh
sample copy, and defines when the check is done. Packaged `package:*` output is
proven only on its target OS.

`run-app` is the developer's quick view, built to reuse one long-running dev
server. Use it when the developer asks to see the app. If you use it for a
quick check:

- Before any write, point `APP_PROJECT_PATH` at a throwaway project from
  `npm run sample:build -- <tmp>`. The default project is the checkout's own
  sample, which the developer looks at.
- Finish with a screenshot of the change and `npm run errors` at 0 unresolved.
- In a worktree, run `npm run app:stop` when done. On main the session is the
  developer's: leave it running, and restart it with `npm run app:restart`
  whenever `npm run app:status` shows `failed` or a nonempty `restartFor`, or
  the gate notes errors from an outdated dev server. Their browser tab reloads.

## Writing tests

- Test observable behavior at the smallest useful layer, beside the module that
  owns it: `.test.ts` for module behavior, `.test.tsx` for rendered UI. Pages
  prove the user-visible result.
- When a workflow needs the real runtime, invoke contract, production
  providers, or persistence, use `src/renderer/test/renderWithRuntime.tsx`, and
  dispose runtimes and temporary directories.
- Every test must be able to go red for a defect. Apply
  [principle-test-behavior-not-implementation](../principle-test-behavior-not-implementation/SKILL.md).
  Cut tests that inspect production source text, snapshot static JSX without a
  behavioral assertion, or guard against deleted features; bundled-source
  constraints belong in build or package scans.
- A differential oracle, a second implementation the code is compared against,
  is correctness evidence only when a different agent derived it from the
  spec's worked examples. One written by the code's own author shares its
  reading of the spec, so report its agreement as regression protection.
- File size is a review judgment, with no file-length or complexity ceilings.
- For a test-first bug fix, follow [tdd](../tdd/SKILL.md).

## Read when

- A test needs a server, child process, shared file, or environment variable,
  you change the test groups or worker count in `vite.config.mts`, or tests
  time out only under load: [test-groups.md](test-groups.md).
- A `runtime-error` finding: [runtime-errors.md](runtime-errors.md).
- Changing crash recovery, dev-server shutdown, or the board; checking
  dependency advisories; or debugging a smoke in a visible window:
  [specialty-checks.md](specialty-checks.md).
- Any claim about frame time, startup speed, or main-process blocking:
  [performance.md](performance.md).
