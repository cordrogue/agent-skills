# Authoring notes

Notes hold Brainstorms, Outlines, and Theories with Markdown bodies. A writer saves edits explicitly, organizes notes by category, Work, parent, and tags, filters the Note selector, and removes saved notes.

## Sub-features

- `note-save` creates and updates a titled note.
- `note-format` saves formatted Markdown from the formatting toolbar.
- `note-organize` sets category, Work, parent note, and tags.
- `note-filter` narrows the Note selector by category, Work, or tag.
- `note-discard` asks before dropping unsaved edits.
- `note-remove` removes a saved note.

## How to get to it (user POV)

- Sidebar "Notes", route `#/notes`. It opens the most recent note.
- "Expand sidebar", then "Expand Notes", lists notes as buttons named by title. Route `#/notes?note=<uuid>`.
- The toolbar holds "New note" (route `#/notes?note=new`), "Save note", "Remove note", a save status, combobox "Filter notes", and combobox "Note".
- The editor has textbox "Title", comboboxes "Category", "Work", and "Parent note", textbox "Add tag", `Remove tag <tag>` buttons, group "Text formatting", and textbox "Note body".

## Driving it with verify-electron

Preconditions:

- A fresh `start`. Commands below are `node scripts/verify-electron.mjs` subcommands.
- Fixtures are "What the missing crates prove" (Brainstorm), "Three claimants", and "The compass follows remembered routes" (Theory, tag brineglass). Read them with `eval 'window.app.listAuthoringNotes({})'`.

- **Open.** Run `click --role button --name 'Expand sidebar'`, `click --role button --name 'Expand Notes'`, and `click --role button --name 'The compass follows remembered routes'`. The route gains `note=<uuid>`, Title holds that name, and Category reads "Theory".
- **Create.** Run `click --role button --name 'New note'`, `click --role textbox --name 'Title'`, `type 'Verification note'`, `click --role textbox --name 'Note body'`, and `type 'Check the beacon inventory.'`. The toolbar status reads "Unsaved".
- **Save.** Run `click --role button --name 'Save note'` and `wait --until '(async()=> (await window.app.listAuthoringNotes({})).some(n=>n.title==="Verification note"&&n.bodyMarkdown.includes("Check the beacon inventory.")))()'`. The status reads "Saved" and `note=new` becomes the note's uuid.
- **Format.** Run `click --role textbox --name 'Note body'`, `press Control+End`, `press Enter`, `click --role button --name 'Bold'` (now `[pressed]`), `type 'Inventory checked'`, and `click --role button --name 'Save note'`. The stored `bodyMarkdown` is `"Check the beacon inventory.\n\n**Inventory checked**"`.
- **Organize.** For each combobox, `click` it, press keys, then `press Enter`. Category uses `press End` (Theory). Work uses `press Home` and `press ArrowDown` (The Three Witnesses). Parent note uses `press Home` and `press ArrowDown` (The compass follows remembered routes). Then run `click --role textbox --name 'Add tag'`, `type 'verification'`, `press Enter`, and `click --role button --name 'Save note'`. The note reads `kind: "theory"`, the Work's id, the compass note's `parentNoteId`, and `tags: ["verification"]`.
- **Remove a tag.** Run `click --role button --name 'Remove tag verification'` and `click --role button --name 'Save note'`. Stored `tags` is `[]`.
- **Filter.** Options in "Filter notes" are All notes, then groups Category, Work, and Tag. On a fresh sample, `click --role combobox --name 'Filter notes'`, `press Home`, three `press ArrowDown`, and `press Enter` select "Theory". Four select "The Three Witnesses" and five select "brineglass". Read the narrowed list with `snapshot --role combobox --name 'Note'`. Theory and brineglass leave the compass note, plus the selected note.
- **Keep editing.** Run `click --role button --name 'New note'`, type a Title, and `click --role button --name 'New note'` again. Dialog "Discard unsaved changes?" offers "Keep editing" (focused) and "Discard". `click --role button --name 'Keep editing'` keeps the typed title.
- **Discard.** Repeat and `click --role button --name 'Discard'`. A blank Title returns and `listAuthoringNotes` has no such title.
- **Remove.** On a saved note, `click --role button --name 'Remove note' --dismiss` lists the confirm "Remove this note? Undo in Change history restores it until the next change." with `answer:false`, and `listAuthoringNotes({})` still has the note. `click --role button --name 'Remove note'` answers OK. The route becomes `note=new` with a blank Untitled note, and `listAuthoringNotes({})` no longer has the title.

## Gotchas

- Notes never autosave. Navigate away only after "Saved" or an explicit Discard.
- Each extra Work adds a Work option and shifts the tag keyboard counts by one.
- The selected note stays in the Note selector even when it fails the filter.

## Source and tests

- `src/renderer/features/authoring/NotesWorkspacePage.tsx`, `NotesMarkdownEditor.tsx`, `noteMetadata.tsx`.
- `src/shared/authoring-note.ts`, `src/backend/services/authoring-note-service.ts`.
- `npm test -- src/renderer/features/authoring/NotesWorkspacePage.test.tsx`.
