# Person notes

A person's Notes tab records skills, tendencies, conditions, appearance, character arcs and arc stages at the viewed date. Each note is a `characterNote` record with no page of its own. Arc and appearance notes also show under Narrative on Profile.

## Sub-features

- `notes-browse` lists the notes at the viewed date, marks the author-only ones, and opens any recorded note from "All recorded notes".
- `notes-create` saves a titled note with Kind, Body and "Author only".
- `notes-change` saves "A change at the selected date" while earlier dates keep the old values.
- `notes-revise` saves "A revision of this entry" in place.
- `notes-history` shows the selected note's whole history under "Note history".
- `notes-end` ends a note at the viewed date after a confirm.
- `notes-draft` keeps an unsaved note while the viewed date moves or the notes refresh, and asks before leaving the page or before another note, New note, a "History: <title>", the Profile tab, Edit or Remove replaces it. It also stays while the viewed date moves before the person's birth.
- `notes-narrative` shows appearance, character arc and arc stage notes on Profile under Narrative.

## How to get to it (user POV)

- Open a person, then the tab "Notes" in the tablist "Character detail views". The region "Character notes" holds the list and the form.
- Choose a note button to edit it, or "New note" for a blank form.
- Choose "All recorded notes", then "History: <title>".
- The "Profile" tab shows Narrative.

## Driving it with verify-electron

Preconditions:

- Open Mara with `click --role button --name 'People'` and `click --role link --name 'Mara Venn'`. Mara is id `1`.
- Fixture notes, both shared, are Tendency "Records uncertainty first" (body "Mara labels doubtful observations before proposing a route conclusion.") and Arc stage "Trusts the compass over the chart".
- Read notes the way the tab does with `eval '(async () => (await window.appHost.invoke("records.characterNote.list", {where:{character:1}}, {at:20000000})).output.items.map((n) => [n.id, n.noteKind, n.title, n.body, n.authorOnly]))()'`.

- **Browse.** `click --role tab --name 'Notes'` and `snapshot main`. It shows "New note", one button per note named `<Kind> <Title> <Body>` with "Author only" after the kind for an author-only note, "All recorded notes", and a blank form with "Kind" (Skill), "Title", "Body", `checkbox "Author only" [checked]` and "Save note".
- **Create.** Type `Verify survey note` into "Title" and `Check the bearings.` into "Body", `click --role button --name 'Save note'`, and `wait --role button --name 'Skill Author only Verify survey note Check the bearings.'`. The form resets to blank, and the list query returns the note with `"authorOnly"`.
- **Dated change.** Select the fixture with `click --role button --name 'Tendency Records uncertainty first Mara labels doubtful observations before proposing a route conclusion.'`. The form gains `combobox "Save as"` ("A change at the selected date"), "Save changes" and "End note", and "Note history" appears below. Replace Body with `Mara labels doubtful observations at dawn.` and save. The list query returns the new body at `20000000` and the original at `19999999`.
- **Revision.** Select "Verify survey note", set "Save as" to "A revision of this entry", replace Body, and save. Its history keeps one entry.
- **History.** `click --role button --name 'All recorded notes'` lists "History: <title>" for every note, ended, future and undated ones included. Choosing one not active at the date shows "This note is not active at the selected date." with the form disabled and its "Note history".
- **Narrative.** `click --role tab --name 'Profile'`. Narrative lists "Trusts the compass over the chart"; Skill and Tendency notes are absent.
- **End.** In Notes, select the fixture Tendency note and `click --role button --name 'End note'`. The dialog `End note "Records uncertainty first" at Bloomtide 1, Year 42 · 21:20?` offers "Cancel" and "End note". Choose "End note". The note leaves the list and the form resets; the list query no longer holds it at `20000000` and still does at `19999999`. Its "Note history", from All recorded notes, ends with an entry setting Status "Ended".
- **Draft through a date move.** Type a Title, then move the viewed date with the timeline. The draft stays and no dialog asks. Leaving the person asks "Discard unsaved changes?". Moving the date before Mara's birth shows "Does not exist yet" above the profile, which keeps Notes and the draft until it is saved or discarded.
- **Draft through a switch.** Select a note, type into Body, then choose another note or "New note". Dialog "Discard unsaved changes?" offers "Keep editing" (focused) and "Discard". "Keep editing" keeps the typed text and the selected note; "Discard" opens the other note. Choosing the selected note again asks nothing. `click --role tab --name 'Profile'` asks the same: "Keep editing" stays on Notes with the text, and "Discard" opens Profile and leaves Notes blank. The top bar's Edit and More > Remove ask the same; "Discard" opens the editor, or runs the removal with the draft cleared.

## Gotchas

- Note button names hold the whole body. `snapshot` truncates long names with "…", so read the full body with the list query before clicking.
- The list is in title order.
- "End note" appears only for notes that start before the viewed date.
- A save at the note's own start date is always a revision, since the note's first values are its start.
- Note history is read-only. Change a note through the form at the date it should change.

## Source and tests

- `src/features/characterNote/contract.ts`; `src/features/character/ui/notes.tsx`, `noteForm.tsx`, `noteDraft.ts`, `narrative.tsx`.
- `src/framework/ui/shell.ts` (`useLeaveGuard(dirty, 'page')`), `src/framework/ui/pages/RecordPage.tsx` (`useHeldDrafts`), `src/framework/ui/pages/WorldHistory.tsx` (`RecordHistory`).
- Fixtures in `samples/<sample>/seed/characterNote.json`.
- `npm test -- src/renderer/features/people/characterNotes.test.tsx src/renderer/features/people/characterNoteDrafts.test.tsx src/features/characterNote`.
