# Rebuilding a SQLite table in a converter

The app opens every project with foreign keys on, and dropping a table with foreign keys on deletes every `ON DELETE CASCADE` child row. A converter that rebuilds a table follows SQLite's documented procedure, in this order:

1. Run `PRAGMA foreign_keys=OFF` before `BEGIN`. The pragma does nothing inside a transaction.
2. Drop other tables' triggers and views whose SQL names the table, or the rename fails on them, as `scene_version_passages_validate_insert` does for `scene_versions`.
3. Create the new table under a temporary name, with its table-qualified references rewritten to that name. `"events"."removed_revision_id"` in a CHECK becomes `"events__new"."removed_revision_id"`, or the CREATE fails with "no such column". The rename writes the real name back.
4. Copy the rows.
5. For an AUTOINCREMENT table, read the old table's `sqlite_sequence` row before the drop. The copy resets `seq` to the highest surviving id, so the next insert would reuse a deleted row's id.
6. Drop the old table, and rename the new one into place.
7. For an AUTOINCREMENT table, delete the table's `sqlite_sequence` row, then insert the saved `seq` only if the old row existed. A never-used table has none.
8. Recreate the table's indexes and triggers, and the triggers and views dropped in step 2.
9. Run `PRAGMA foreign_key_check`. Roll back and fail on any row.
10. Commit, then run `PRAGMA foreign_keys=ON`.

That order keeps other tables' `REFERENCES` text unchanged, which the project's table fingerprints require.
