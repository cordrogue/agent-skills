# Person notes

A person's Notes tab records skills, tendencies, conditions, appearance, arcs, and arc stages at the viewed date. A writer saves a new note, records a dated change or a revision of an existing note, opens a note's history, and reads arc and appearance notes under Narrative on Profile.

## Sub-features

- `notes-browse` lists notes at the viewed date and their histories.
- `notes-create` saves a titled note with kind, body, and "Author only".
- `notes-change` saves "A change at the selected date" while earlier dates keep the old body.
- `notes-revise` saves "A revision of this entry" in place.
- `notes-narrative` shows arc and appearance notes on Profile under Narrative.
- `notes-end` ends a note from the viewed date after a confirm.

## How to get to it (user POV)

- Open a person, then the toolbar tab "Notes". `region "Character notes"` holds the list and the form.
- Choose a note button to edit it, or "New note" for a blank form.
- Expand "All recorded notes" and choose "History: <title>".
- The "Profile" tab shows Narrative.

## Driving it with verify-electron

Preconditions:

- A fresh `start`, then `click --role button --name 'Characters'` and `click --role button --name 'Open Mara Venn, Alive'`. Prefix every command with `node scripts/verify-electron.mjs`. Mara is id `1`.
- Fixture notes are Arc stage "Trusts the compass over the chart" and Tendency "Records uncertainty first" (id `1`, body "Mara labels doubtful observations before proposing a route conclusion.").

- **Browse.** Run `click --role tab --name 'Notes'` and `snapshot main`. It shows "At selected date: Bloomtide 1, Year 42 · 21:20", "New note", one button per note named `<Kind> <Title> <Body>`, and a blank form with Kind "Skill", "Title", "Body", `checkbox "Author only" [checked]`, and "Save note".
- **Create.** Run `click --role textbox --name 'Title'`, `type 'Verify survey note'`, `click --role textbox --name 'Body'`, `type 'Check the bearings.'`, and `click --role button --name 'Save note'`. Run `wait --role button --name 'Skill Verify survey note Check the bearings.'`. The form resets to blank.
- **Confirm the note.** `eval '(async () => (await window.app.listCharacterNotes({characterId:1,asOfTick:20000000})).filter(n => n.title === "Verify survey note").map(n => [n.kind, n.body, n.authorOnly]))()'` returns `[["skill", "Check the bearings.", true]]`.
- **Dated change.** Select the fixture with `click --role button --name 'Tendency Records uncertainty first Mara labels doubtful observations before proposing a route conclusion.'`. The form gains `combobox "Save as"` ("A change at the selected date"), "Save changes", and "End note". Replace Body with `Mara labels doubtful observations at dawn.` and run `click --role button --name 'Save changes'`.
- **Confirm the change.** `eval '(async () => [(await window.app.listCharacterNotes({characterId:1,asOfTick:20000000})).find(n => n.id === 1).body, (await window.app.listCharacterNotes({characterId:1,asOfTick:19999999})).find(n => n.id === 1).body])()'` returns the new body, then the original.
- **Revision.** Select "Verify survey note" by its full button name. Run `click --role combobox --name 'Save as'`, `press End`, and `press Enter`; it reads "A revision of this entry". Replace Body with `Check the eastern bearings.` and Save changes. The stored body updates and its history keeps one entry.
- **History.** Run `click --role DisclosureTriangle --name 'All recorded notes'`. It lists "History: <title>" for every note. Run `click --role button --name 'History: Records uncertainty first'`. `region "Note history"` shows a dated entry per change with Existence, Kind, Title, Body, and Author only.
- **Narrative.** Run `click --role tab --name 'Profile'`. Narrative lists "Trusts the compass over the chart". The Skill note "Verify survey note" is absent.
- **End, cancelled.** On a fresh Mara, open Notes and select the fixture Tendency note by its full name. Run `click --role button --name 'End note' --dismiss`. `dialogs` lists the confirm `End note "Records uncertainty first" at Bloomtide 1, Year 42 · 21:20?` answered `false`, and `eval '(async () => (await window.app.listCharacterNotes({characterId:1,asOfTick:20000000})).some(n => n.id === 1))()'` stays `true`.
- **End.** Repeat without `--dismiss`. The note leaves the list and the form resets. The same query returns `false` at `20000000` and `true` at `19999999`, and the head revision's `commandKey` is `character-note.endAtTick`.

## Gotchas

- Note button names hold the whole body. `snapshot` truncates long names with "…", so read the full body with `listCharacterNotes` before clicking.
- Selecting another note keeps the last "Save as" choice. Check the combobox before saving, or a revision overwrites what should be a dated change. This is a product gap.
- "End note" appears only for notes that start before the viewed date.
- The list order changes after a save. Re-snapshot before choosing a note.

## Source and tests

- `src/renderer/features/characters/CharacterNotesView.tsx`, `CharacterPage.tsx`, `CharacterProfileView.tsx`.
- `src/shared/character-note.ts`, `character-ipc.ts`; `src/backend/services/character-note-service.ts`.
- Fixtures in `samples/<sample>/seed/people.json` (`notes`).
- `npm test -- src/renderer/features/characters/CharacterNotesView.test.tsx src/backend/services/character-note-service.test.ts`.
