# Rebuilding a SQLite table in a converter

Call `rebuildTables` from `scripts/converters/lib/rebuild.ts`. Keep its design when changing it:

- Foreign keys off before `BEGIN`, old setting restored after. `node:sqlite` opens with them on, so a drop would delete `ON DELETE CASCADE` children.
- Drops every view and other table's trigger, triggers first, then recreates them.
- Renames the new table's SQL through SQLite in `:memory:`, so table-qualified references follow.
- Parks `sqlite_sequence` rows by BigInt rowid in SQL. Copying through JS stored `17` as `17.0`.
- Qualifies every name with `main.` and refuses temp views or triggers.
- Rolls back on any `PRAGMA foreign_key_check` row.

Other tables' `REFERENCES` text stays unchanged, as table fingerprints require.
