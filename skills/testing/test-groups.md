# Test groups and concurrency

`vite.config.mts` selects test environments by path, without comment directives:

| Project | Tests | Environment | File execution |
| --- | --- | --- | --- |
| `parallel` | Source tests outside the groups below | Node | Parallel |
| `renderer` | All `src/renderer` tests and `src/{framework,features}/**/*.test.tsx` | jsdom | Parallel |
| `serialized` | `src/dev-browser`, `src/main`, and `src/preload`, except the bridge test | Node | Serialized |
| `browser-bridge` | `src/dev-browser/bridge.test.ts` | jsdom | Serialized |

The serialized projects share a single-worker group within one Vitest run.
Separate Vitest runs do not coordinate their workers, so each run is capped at
8 (`maxWorkers`). On the 32-core machine, two concurrent runs at Vitest's
default of 31 timed out renderer tests, and four concurrent runs at 8 passed.
Tests in one file run in sequence in one fork, so the slowest file sets the
floor for every run that selects it; split a file by area when it runs past
about 15 s.

Serialize only tests with a demonstrated collision on a shared resource. Owning
a server, child process, or environment variable is not enough when Vitest forks
isolate it. Prefer temporary paths, dynamic ports, local state, and reliable
cleanup. Add only the narrowest necessary pattern to `serializedTestIncludes`;
the shared list automatically excludes it from `parallel`.

After changing the groups, confirm every test appears exactly once, then run the
suite:

```bash
npx vitest list --filesOnly --staticParse
npx vitest run
```
