# Runtime error backlog

Development sessions record uncaught browser errors, unhandled rejections,
startup failures, and React error boundaries. The turn-end gate reports each
unresolved one as a `runtime-error` finding, so the backlog must read
`0 unresolved` before a turn can end clean.

For each pending error, read its JavaScript and React component stacks with
`npm run errors`, fix the cause, and exercise the affected workflow again. Then
record the fix and the verification evidence:

```bash
npm run errors -- resolve <id> [<id> ...] --note "Fix and verification evidence"
npm run errors
```

Only `resolve` with a note clears an error; reading, restarting by hand, or
deleting logs leaves it pending. A running dev server restarts itself when a
file in `startOnlyFiles.server` (`scripts/lib/dev-restart.mjs`) changes and
resolves the old server's errors with a note naming that file. An error from a
dev server started before the last such change does not block; the gate prints
it as a note. Restart that server, then clear those errors with
`npm run errors -- resolve --stale --note "Restarted the dev server"`. Events and resolution notes remain in
`.tmp-vite/runtime-errors/`, and a recurrence gets a new ID. If an error stays
unresolved, report the blocker and leave it pending. `npm run errors -- --all`
shows the history with resolution notes.

The backlog covers development builds only; the recorder is off in production.
For production runs, see the harness gates in
[specialty-checks.md](specialty-checks.md).

After changing `scripts/runtime-errors.mjs` or the feedback check, run
`npm run test:scripts`.
