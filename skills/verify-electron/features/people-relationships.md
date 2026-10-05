# Relationships between people

A person's Relationships section lists connected records with their role and state at the viewed date. A writer adds a connection, records a dated change or corrects an entry, edits family details, opens a connection's history, and defines custom relationship types.

## Sub-features

- `relationship-browse` lists connections and toggles all recorded relationships.
- `relationship-change` records a dated change to a connection.
- `relationship-correct` corrects the current entry without a new date.
- `relationship-family` shows Assertion, Source event, Kinship, Visibility, Perspective, Cultural context, and Evidence.
- `relationship-history` opens a connection's dated entries.
- `relationship-create` finds a record and saves a new connection.
- `relationship-types` saves a custom type with source and target role labels.
- `relationship-remove` removes a mistaken connection after a confirm.

## How to get to it (user POV)

- Open a person at `#/people/<id>` and scroll to `region "Relationships"`.
- Section buttons are "Types", "Add relationship", and "All recorded relationships".
- Each row has "History" and "Edit" buttons. Right-clicking the row's person link adds "History", "Edit relationship", and "Remove mistake" below the usual Open and Copy items.
- A row's person link opens that person.

## Driving it with verify-electron

Preconditions:

- A fresh `start`, then `click --role button --name 'Characters'` and `click --role button --name 'Open Mara Venn, Alive'`. Prefix every command with `node scripts/verify-electron.mjs`.
- Fresh-sample ids are Mara `1`, Orin `2`, Sera `3`, Kesh `6`, and Oda Vell `8`. Resolve with `eval '(async () => (await window.app.listCharacters({asOfTick:20000000})).map(c => [c.id, c.name]))()'`.

- **Browse.** `snapshot` shows rows "Kesh Ash · Student of · Rim guide", "Sera Nhal · Spouse of · Spouses and research partners", and "Captain Orin Venn · Child of · Father and daughter". Run `click --role button --name 'All recorded relationships'`. It becomes `button "View selected date" [pressed]` with the text "Recorded history, including undated and future entries." Click "View selected date" to return.
- **Edit from the row menu.** Run `click --role link --name 'Sera Nhal' --button right` and `click --role menuitem --name 'Edit relationship'`. The form shows `combobox "Relationship edit mode"` set to "Add a change", a disabled "Relationship type" set to "Spouse of", and "Save", "Cancel", "Remove mistake".
- **Family details.** Run `click --role button --name 'Details'`. Comboboxes "Assertion", "Source event", "Kinship" (Legal), "Visibility" (Open), "Perspective" (Unscoped) and textboxes "Cultural context" ("Veyran civic marriage") and "Evidence" appear.
- **Record a change.** Run `click --role textbox --name 'Relationship state'`, `press Control+a`, `type 'Spouses and survey partners'`, and `click --role button --name 'Save'`. The form closes and Sera's row reads "Spouses and survey partners".
- **Confirm the change.** Run `eval '(async () => (await window.app.listWorldRelationships({entityType:"character",entityId:1,asOfTick:20000000})).find(r => r.relationshipKind === "spouse").label)()'` for "Spouses and survey partners". At `asOfTick:19999999` it still returns "Spouses and research partners". `familyCulturalContext` stays "Veyran civic marriage".
- **Correct the entry.** Run `click --role button --name 'Edit' --nth 1`, `click --role combobox --name 'Relationship edit mode'`, `press End`, and `press Enter`. The combobox reads "Correct this entry". Replace "Relationship description" with `Corrected household note.` and Save. The same query returns `summary` "Corrected household note." at `20000000` and the original summary at `19999999`.
- **History.** Run `click --role link --name 'Sera Nhal' --button right` and `click --role menuitem --name 'History'`. `region "Relationship history"` lists "Dawnmere 22, Year 40" and "Bloomtide 1, Year 42", the latter with the new label and description.
- **Create.** Run `click --role button --name 'Add relationship'`, `click --role textbox --name 'Find connected record'`, and `type 'Oda'`. Results include `button "Oda Vell · character"` and "Create character “Oda”". Choose Oda Vell. Leave "Ally of", type `Charter allies` into "Relationship state", and Save.
- **Confirm the connection.** A row "Oda Vell · Ally of · Charter allies" appears. `eval '(async () => (await window.app.listWorldRelationships({entityType:"character",entityId:1,asOfTick:20000000})).filter(r => r.relationshipKind === "ally").map(r => [r.sourceEntityId, r.targetEntityId, r.label]))()'` returns `[[1, 8, "Charter allies"]]`. Run `click --role link --name 'Oda Vell'`; `#/people/8` shows "Mara Venn · Ally of · Charter allies".
- **Custom type.** Back on Mara, run `click --role button --name 'Types'`. Type `Charts with` into "Source role label" and `Charted with by` into "Target role label", then `click --role button --name 'Save type'`. `eval '(async () => (await window.app.listWorldRelationshipTypes({})).find(t => t.label === "Charts with").inverseLabel)()'` returns "Charted with by". Reopen "Add relationship"; "Relationship type" lists "Charts with".
- **Remove, cancelled.** On a fresh Mara, run `click --role link --name 'Sera Nhal' --button right` and `click --role menuitem --name 'Remove mistake' --dismiss`. `dialogs` lists the confirm "Remove this relationship? Undo in Change history restores it until the next change." answered `false`, and `eval '(async () => (await window.app.listWorldRelationships({entityType:"character",entityId:1,asOfTick:20000000})).map(r => r.relationshipKind))()'` still returns `["teacher", "spouse", "parent"]`. The editor's "Remove mistake" button asks the same confirm.
- **Remove.** Repeat without `--dismiss`. The confirm is answered `true`, Sera's row disappears, and the query returns `["teacher", "parent"]` at both `20000000` and `19999999`. `listEditorialRevisions({limit:1}).items[0].commandKey` is `world-relationship.removeMistake`.

## Gotchas

- Row labels depend on whose profile is open. Mara reads "Student of" Kesh; the stored kind is `teacher` from Kesh.
- Several buttons are named "History", "Edit", and "Save". Use the row link's context menu or `--nth`, and keep one editor open.
- A saved row moves in the list. Re-snapshot before using `--nth` again.

## Source and tests

- `src/renderer/features/relationships/RelationshipsView.tsx`, `relationshipDetails.tsx`; `src/renderer/features/shared/WorldRecordContext.tsx`.
- `src/backend/services/continuity-service.ts`; `src/shared/continuity.ts`, `continuity-ipc.ts`.
- Fixtures in `samples/<sample>/seed/people.json` (`relationships`).
- `npm test -- src/renderer/features/relationships/RelationshipsView.test.tsx src/backend/services/relationship-authoring.test.ts src/backend/services/relationship-service.temporal.test.ts`.
