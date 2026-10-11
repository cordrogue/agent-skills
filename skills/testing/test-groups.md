# Test groups and concurrency

`vite.config.mts` selects test environments by path, without comment directives:

| Project | Tests | Environment | File execution |
| --- | --- | --- | --- |
| `parallel` | Source tests outside the groups below | Node | Parallel |
| `renderer` | All `src/renderer` tests and `src/{framework,features}/**/*.test.tsx` | jsdom | Parallel |
| `browser-bridge` | `src/dev-browser/bridge.test.ts` | jsdom without the renderer setup | Parallel |

Separate Vitest runs do not coordinate workers, so each run is capped at 8
(`maxWorkers`). On the 32-core machine, two concurrent runs at Vitest's default
of 31 timed out renderer tests, and four concurrent runs at 8 passed. The
feedback check is the exception: it holds one of the two slots all worktrees
share (`APP_CHECK_SLOT`), so its run uses half the cores. The full suite
took 85.8 s at 16 workers against 122.2 s at 8, and two 16-worker runs at once
passed in 133 s each. Tests in one file run in sequence in one fork, so the
slowest file sets the floor for every run that selects it; split a file by
area when it runs past about 15 s.

`testTimeout` is 30 s for every test, because a run beside other worktrees'
suites can slow a test ninefold: `recordHistory.test.ts` takes 1.9 s alone and
took up to 18 s at load 80. Only a test that needs more than 30 s gets its own
timeout.

No project serializes its files. Vitest runs a project with
`fileParallelism: false` alone, after every other file, so add one only for
tests with a demonstrated collision on a shared resource, with the narrowest
pattern that holds them, and exclude that pattern from `parallel`. Owning a
server, child process, or environment variable is not enough when Vitest forks
isolate it: the 24 Electron main, preload and dev-browser files once ran
serialized, and passed 30 of 30 runs in parallel, six at a time at load 56 to
79. Prefer temporary paths, dynamic ports, local state, and reliable cleanup.

After changing the groups, confirm every test appears exactly once, then run
the suite:

```bash
npx vitest list --filesOnly --staticParse
npx vitest run
```
