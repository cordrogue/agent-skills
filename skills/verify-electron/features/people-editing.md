# Create and edit a person

A writer adds a character from the Characters collection and records dated changes to an existing person. Saving a change keeps the editor open, an unfinished new draft asks before it is discarded, and a portrait can be cleared from a date onward.

## Sub-features

- `person-create` saves a new character and opens its profile.
- `person-change` saves a dated change to an existing character and keeps the editor open.
- `person-discard` asks "Discard this new character draft?" before dropping a draft.
- `person-portrait` chooses or replaces a portrait from a file, from the change date onward.
- `person-portrait-clear` clears a portrait from the change date while earlier dates keep it.
- `person-end` ends a character at the viewed date after a confirm.

## How to get to it (user POV)

- Characters collection toolbar, "Add character". The toolbar title becomes "New character".
- A person's toolbar, "Add change" (pencil icon). The editor toolbar shows "Save", "Cancel", and "End".
- The date group is "Create this character starting at" on create and "Change from this date onward" on edit.

## Driving it with verify-electron

Preconditions:

- A fresh `start`. Prefix every command with `node scripts/verify-electron.mjs`. Viewed time is tick `20000000`.
- "Verify tide surveyor" is a new test record. On a fresh sample it gets id `11`; resolve it by name after saving.

- **Open the form.** Run `click --role button --name 'Characters'` and `click --role button --name 'Add character'`. `snapshot` shows heading "New character", `button "Save" [disabled]`, and textboxes "Name", "Summary", "Gender", "Role", "Status", and "Notable traits".
- **Fill it.** Run `click --role textbox --name 'Name'` and `type 'Verify tide surveyor'`. Repeat for "Summary" with `Checks doubtful bearings.`, "Role" with `Survey assistant`, and "Notable traits" with `Patient and observant.`.
- **Save.** Run `click --role button --name 'Save'` and `wait --role heading --name 'Verify tide surveyor'`. The route becomes `#/people/11`. `shot --name person-created` shows the summary, Role, Traits, and "Position unknown.".
- **Confirm storage.** Run `eval '(async () => { const c = (await window.app.listCharacters({asOfTick:20000000})).find(c => c.name === "Verify tide surveyor"); return [c.id, c.summary, c.role, c.notableTraits]; })()'`. It returns `[11, "Checks doubtful bearings.", "Survey assistant", "Patient and observant."]`.
- **Record a change.** Run `click --role button --name 'Add change'`, `click --role textbox --name 'Summary'`, `press Control+a`, `type 'Rechecks the northern bearings.'`, and `click --role button --name 'Save'`. Run `wait --until '(async () => (await window.app.getCharacter({id:11,asOfTick:20000000})).record.summary === "Rechecks the northern bearings.")()'`. The editor stays open with "Save" disabled and the status "Editing".
- **Leave the editor.** Run `click --role button --name 'Cancel'`. The profile shows the new summary and no dialog appears.
- **Discard a draft.** Run `click --role button --name 'Characters'`, `click --role button --name 'Add character'`, `click --role textbox --name 'Name'`, `type 'Discard surveyor'`, and `click --role button --name 'Cancel'`. `dialog "Discard this new character draft?"` appears with "Keep editing" focused and "Discard".
- **Keep, then discard.** Run `click --role button --name 'Keep editing'`. The Name textbox still holds "Discard surveyor". Run `click --role button --name 'Cancel'` and `click --role button --name 'Discard'`. The Characters heading returns. `eval '(async () => (await window.app.listCharacters({asOfTick:20000000})).some(c => c.name === "Discard surveyor"))()'` returns `false`.
- **Clear a portrait.** Open Mara with `click --role button --name 'Open Mara Venn, Alive'`, then `click --role button --name 'Add change'`. The Portrait group shows "Replace portrait" and "Clear from this date". Run `click --role button --name 'Clear from this date'` and `click --role button --name 'Save'`.
- **Confirm the portrait.** Run `eval '(async () => [(await window.app.getCharacter({id:1,asOfTick:20000000})).record.portraitAssetPath, (await window.app.getCharacter({id:1,asOfTick:19999999})).record.portraitAssetPath])()'`. It returns `[null, "app-asset://characters/65b4…png"]`. Run `click --role button --name 'Cancel'`; the profile has no portrait.
- **Choose a portrait.** In the Add character form, after Name, run `click --role button --name 'Choose portrait' --file "$HOME/.cache/agent-swarm/<dir>/<image>.png"`. `dialogs` lists an `open` dialog answered with that path. Save; `getCharacter({id:11,asOfTick:20000000}).record.portraitAssetPath` is `app-asset://characters/<sha256>.png` of that file.
- **Replace a portrait.** On a fresh Mara, Add change, `click --role button --name 'Replace portrait' --file <png>`, and Save. `portraitAssetPath` changes at `20000000` and stays `65b4…png` at `19999999`. Without `--file` the picker cancels and nothing changes.
- **End, cancelled.** On Mara's Add change, `click --role button --name 'End' --dismiss`. The confirm "End this character at the viewed story date, Bloomtide 1, Year 42 · 21:20? The change date above applies only to Save." is answered `false`. Mara still reads "Alive · Age 33" and `getCharacter({id:1,asOfTick:20000000}).record.existsToTick` stays `null`.
- **End.** Repeat without `--dismiss`. The profile reads "Dead · Age 33" with Death "Bloomtide 1, Year 42". `getCharacter({id:1,asOfTick:20000000}).record` has `existsToTick` 20000000 and `deathDate.tick` 20000000, and the head revision's `commandKey` is `character.endAtTick`. Run it last.

## Gotchas

- The edit action is "Add change", not "Edit".
- Mara's Place combobox is disabled and named "Place Location follows dated map positions. Set it in Maps.".
- "End" uses the viewed date, not the editor's change date, and the character stays in `listCharacters` at that tick.

## Source and tests

- `src/renderer/features/characters/CharacterEditor.tsx`, `CharacterPage.tsx`.
- `src/renderer/features/shared/RecordFields.tsx`, `RecordPageView.tsx`, `recordPage.ts` (End confirmation).
- `src/renderer/components/app-shell/UnsavedChanges.tsx`; `src/backend/services/character-service.ts`.
- `npm test -- src/renderer/features/characters/CharacterPage.test.tsx src/renderer/features/shared/recordPage.test.tsx src/renderer/components/app-shell/UnsavedChanges.test.tsx`.
