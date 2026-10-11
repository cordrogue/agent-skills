---
name: testing
description: "Always load when writing, changing, or running tests, verifying a change before calling it done, or reviewing runtime errors."
---

# Testing

**Gates** run on you automatically. Between gates, climb the **ladder**: run
the lowest rung that can go red on your change, and climb only when the change
reaches something that rung cannot see.

## Gates

| When | What runs |
| --- | --- |
| Turn end (Stop hook) | `check:fast` (format, lint, typecheck, script tests, knip, and tests that import changed files, side by side), then the runtime error backlog, within 110 s. Biome formats, so fix a format finding with `npx biome format --write <file>` |
| `git commit` | The same check, with up to 240 s to wait for a check slot and 240 s to run; Claude Code's Bash timeout defaults to 600 s here to cover both. It reuses the turn-end result when the commit holds the whole working tree. A checkpoint commit whose subject starts with `WIP:` skips it, and main refuses `WIP:` commits, so squash them before merging |
| `git push` | `verify:code`: dependency checks, the full suite, and a production build |

A clean gate prints nothing, and a tree that already passed in any worktree
skips the check, so a review lane that changes nothing never reruns it. Leave
`check:fast` to the gate. All worktrees share two check slots, so other checks
wait; a timeout while waiting is not a finding, so rerun. A turn-end check that
times out, or that finds a rebase, merge or cherry-pick in progress, ends the
turn with a note instead.

A failing gate prints lines starting `feedback (`, each naming a file and line;
the full output is in `.tmp-vite/feedback/last-failure.md`. Fix every finding.
The hook re-checks at each turn end and gives up after three failures in a row,
so a turn ending on that third failure is unverified; report it as failing. For
a `runtime-error` finding, follow [runtime-errors.md](runtime-errors.md). If
the developer asked for a failing test, report the expected failure and stop.

Subagents, and lanes started with `APP_SKIP_STOP_CHECK=1`, get no turn-end
gate. Run it yourself before reporting done, with stdin closed or it waits
forever:

```bash
mise exec node@24.18.0 -- node scripts/feedback/check.mjs </dev/null
```

## Ladder

| Rung | Run | When | Cost |
| --- | --- | --- | --- |
| Focused | `npm run typecheck`, `npm test -- <path>` | While editing, after each step you'd want to know broke | Seconds |
| Scripts | `npm run test:scripts`, or `node --test '<quoted glob>'`; Node 24 takes no folder | A change under `scripts/` | Seconds |
| Branch | `npm test -- --changed=main` | Before reporting a branch done; covers committed and uncommitted changes | Seconds to a minute |
| Smoke | `npm run test:smoke` | Electron main, preload, MCP, packaging, or SQLite changed | About 10 s with the build |
| Full | `npm test` | Tests could reach the change without importing it: fixtures, sample data, config, test setup | About 50 s |
| Live | `verify-electron` skill | The behavior is visible only in the running app | Minutes |
| Merge | `npm run verify` | Before a merge or release | About a minute |

Live checks stay on the changed workflow; routine edits need no theme, zoom, or
accessibility sweep. `verify-electron` builds your checkout, runs it on a
fresh sample copy, and defines when the check is done. Packaged `package:*`
output is proven only on its target OS.

`run-app` is the developer's quick view, reusing one long-running dev server.
Use it when the developer asks to see the app. For a quick check of your own:

- Before any write, point `APP_PROJECT_PATH` at a throwaway project from
  `npm run sample:build -- <tmp>`. The default project is the checkout's own
  sample, which the developer looks at.
- Finish with a screenshot of the change and `npm run errors` at 0 unresolved.
- In a worktree, run `npm run app:stop` when done. On main the session is the
  developer's: leave it running, and run `npm run app:restart` whenever
  `npm run app:status` shows `failed` or a nonempty `restartFor`, or the gate
  notes errors from an outdated dev server. Their browser tab reloads.

## Writing tests

- Test observable behavior at the smallest useful layer, beside the owning
  module: `.test.ts` for module behavior, `.test.tsx` for rendered UI. Pages
  prove the user-visible result.
- When a workflow needs the real runtime, invoke contract, production
  providers, or persistence, use `src/renderer/test/renderWithRuntime.tsx`, and
  dispose runtimes and temporary directories.
- A record kind under `src/features` gets the record-kind suite
  (`src/framework/testing/record-kind-suite.ts`), which
  `src/app/record-kinds.test.ts` runs against every discovered kind with every
  feature's rules off (`rules: null`). Test the code a feature writes,
  including its own rules and host commands, with `createTestHost` from
  `@app/framework/testing`. Run the suite with
  `npm test -- src/app/record-kinds.test.ts`.
- A change to framework types, discovery, routes, or generated files also runs
  `npm test -- src/framework/discovery/typecheck-features.test.ts` and
  `npm run lint`. Those two build a second feature beside the Bestiary;
  `npm run typecheck` sees only the app's own features, and a type that widens
  to `any` is no type error.
- When a test covers both deleted and surviving code, delete only the
  assertions on the deleted code.
- Every test must be able to go red for a defect. For each guard or refusal
  clause the change adds or keeps, delete the clause and watch a test fail
  with `node scripts/mutate.mjs <mutations.json>`, which restores each file
  and reports a mutation whose text no longer matches. Apply
  [principle-test-behavior-not-implementation](../principle-test-behavior-not-implementation/SKILL.md).
  Cut tests that inspect production source text, snapshot static JSX without a
  behavioral assertion, or guard against deleted features; bundled-source
  constraints belong in build or package scans.
- A replacement for an existing read keeps today's behavior only when a test
  compares it with a trunk worktree on today's data and after each of a short
  run of ordinary edits, such as a later edit, an end and a backdated addition.
  K6 matched every existing row and still shipped duplicates and reordering
  that ordinary edits expose.
- A differential oracle (a second implementation the code is compared against)
  is correctness evidence only when a different agent derived it from the
  spec's worked examples. One by the code's own author shares its reading of
  the spec, so report its agreement as regression protection.
- File size is a review judgment, with no file-length or complexity ceilings.
- For a test-first bug fix, follow [tdd](../tdd/SKILL.md).

## Read when

- A test needs a server, child process, shared file, or environment variable,
  you change the test groups or worker count in `vite.config.mts`, or tests
  time out only under load: [test-groups.md](test-groups.md).
- A test that fails in the full suite and passes alone gets a backlog line.
- Changing crash recovery, dev-server shutdown, or the board; checking
  dependency advisories; or debugging a smoke in a visible window:
  [specialty-checks.md](specialty-checks.md).
- Any claim about frame time, startup speed, or main-process blocking:
  [performance.md](performance.md).
