# Converters

A one-off converter moves the developer's project to a new format; `scripts/converters/lib/project.ts` runs its steps in order. These rules come from the record kinds converter reviews. State each in the converter's spec and test it:

1. **Opening an unconverted project writes nothing.** Until the converter runs, the app reads the old format or shows the feature empty, and the project stays exactly as it was.
2. **Converted means every old row has a counterpart.** A project counts as converted only when each live old row has its new record. New records existing proves nothing; one live old row without a counterpart means the conversion is unfinished.
3. **The final self-check compares every value.** Before it commits, the converter reads each converted record back and compares every stored value, every version included, with its source row. Row counts alone miss a moved date or a lost field.
4. **A crash after any commit leaves the project untouched, converted, or refused.** The app must never open a half-converted project, and a rerun must finish the work. Do the set-aside, the version bump, the copy and the read-back inside `prepared.convert(db, step)`, which makes them one commit, so a failed read-back changes nothing. Test every stop with one call to `checkEveryStop` from `scripts/converters/lib/every-stop.mjs`, as `relationship-to-framework.test.mjs` does.

A bump converter pins the version it converts from in its plan's `from`, so a later bump makes it refuse before any write, and its tests fail until the unit that makes the bump deletes it.

The developer runs a converter with `node scripts/converters/run-on-project.mjs <converter> <project>`, which rehearses it on a checked copy, and adds `--original` once the rehearsal output looks right.

For table rebuilds, call `rebuildTables` per [`sqlite-table-rebuild.md`](sqlite-table-rebuild.md).
