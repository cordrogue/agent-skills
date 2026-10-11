# Converters

A one-off converter moves the developer's project to a new format; `scripts/converters/lib/project.ts` runs its steps in order. These rules come from the record kinds converter reviews. State each in the converter's spec and test it:

1. **Opening an unconverted project writes nothing.** Until the converter runs, the app reads the old format or shows the feature empty, and the project stays exactly as it was.
2. **Converted means every old row has a counterpart.** A project counts as converted only when each live old row has its new record. New records existing proves nothing; one live old row without a counterpart means the conversion is unfinished.
3. **The final self-check compares every value.** Before it commits, the converter reads each converted record back and compares every stored value, every version included, with its source row. Row counts alone miss a moved date or a lost field.

The developer runs a converter with `node scripts/converters/run-on-project.mjs <converter> <project>`, which rehearses it on a checked copy, and adds `--original` once the rehearsal output looks right.

A converter that rebuilds a table also follows [`sqlite-table-rebuild.md`](sqlite-table-rebuild.md).
