# Scene index and structure

The Draft view lists a Work's Scenes grouped by Chapter, with unassigned Scenes under Drafting. A writer creates, renames, reorders, places, sequences, and removes Scenes.

## Sub-features

- `scene-index` lists Chapter groups and sorts rows by title within each group.
- `scene-create` creates a Scene in a Chapter or in Drafting and opens its editor.
- `scene-rename` saves a new title into the Scene's recovery draft.
- `scene-order` moves a Scene up or down within its Chapter.
- `scene-placement` assigns a Scene to a Chapter from Scene details.
- `scene-sequence` sets or clears a Scene's story sequence position.
- `scene-remove` removes a Scene from its editor or the structure menu.

## How to get to it (user POV)

- Sidebar "Writing", tab "Draft", route `#/writing?view=write`. Index rows are buttons named `Open <title>`.
- Toolbar "Manage structure" opens dialog "Manage Chapters and Scenes". Its Scenes are buttons named by title, with `Move <title> up` and `Move <title> down`.
- An index row menu offers Open, Copy name, and "New scene in chapter" (or "New scene in Drafting"). A structure Scene menu offers Open, Copy name, Move scene up, Move scene down, and Remove scene; a Drafting Scene's has "New scene in Drafting" in place of the moves.
- In the editor, "More editor actions" lists Scene details, Version history, Focus mode, Back to scenes, and Remove scene.
- Tab "Scene sequence", route `&view=order`.

## Driving it with verify-electron

Preconditions:

- Fixture is Work "The Three Witnesses".
- Resolve ids with `eval '(async()=>{const w=(await window.appHost.invoke("listWorks", {}, {})).output.find(w=>w.name==="The Three Witnesses");return (await window.appHost.invoke("getWorkSceneIndex", {workId:w.id}, {})).output.scenes.map(s=>[s.id,s.title,s.chapterId,s.chapterOrder]);})()'`.

- **Index.** `click --role button --name 'Writing'`. Region "Scene selector" lists "Open The Salt Bell", "Open Ashfold Lanterns", "Open The Glassmaw", "Open Three Columns", and "Open Ilsabet's Letter" under Drafting.
- **Reorder.** `click --role button --name 'Manage structure'` and `click --role button --name 'Move Ashfold Lanterns down'`. `getWorkSceneIndex` gives The Glassmaw chapterOrder 1 and Ashfold Lanterns 2. `click --role button --name 'Ashfold Lanterns' --button right` and `click --role menuitem --name 'Move scene up'` reverse it.
- **Sort.** With Ashfold Lanterns moved down, `click --role button --name 'Close'` and `click --role button --name 'Sort Scenes by title'`. The button turns pressed and The Rim Road rows read Ashfold Lanterns, then The Glassmaw. Stored order does not change.
- **Create in a Chapter.** In the dialog, `click --role button --name 'Create Scene in The Rim Road'`. The route gains `scene=<uuid>` and the editor shows "Chapter 2 · The Rim Road" with Scene title "Untitled Scene". `getWorkSceneIndex` gives it chapterOrder 3.
- **Rename.** `click --role textbox --name 'Scene title'`, `press Control+a`, and `type 'Verification scene renamed'`. Poll `wait --until '(async()=> (await window.appHost.invoke("getSceneWriting", {sceneId:"<sceneId>"}, {})).output.selected.scene.recoveryDraft.title==="Verification scene renamed")()'`. `click --role button --name 'Back to scenes'` returns to the index, where the row reads "Not versioned".
- **Create in Drafting.** `click --role button --name "Open Ilsabet's Letter" --button right` and `click --role menuitem --name 'New scene in Drafting'` open an Untitled Scene with `chapterId: null`. From the dialog, `click --role textbox --name 'New unassigned Scene title'`, `type 'Verification draft'`, and `click --role button --name 'Add draft'` open a titled one.
- **Assign a Chapter.** In the Verification draft editor, `click --role button --name 'More editor actions'` and `click --role menuitem --name 'Scene details'`. Dialog "Scene details" has combobox "Chapter" (Drafting, The Salt Bell, The Rim Road, The Ledger). `click --role combobox --name 'Chapter'`, `press Home`, `press ArrowDown`, `press Enter`, and `click --role button --name 'Update placement'`. The status moves from "Placement pending" to "Placement saved" and `getWorkSceneIndex` puts the Scene in The Salt Bell.
- **Sequence.** `click --role tab --name 'Scene sequence'`. Each row has `Sequence position for <title>`, valued "Not placed". `click --role combobox --name 'Sequence position for The Salt Bell'`, `press Home`, `press ArrowDown`, and `press Enter`. The value is "1" and `getWorkWriting({workId}).storySequence` holds its sceneId with order 1. Choosing "Not placed" the same way empties `storySequence`.
- **Remove from the editor.** In a new Scene's editor, `click --role button --name 'More editor actions'` and `click --role menuitem --name 'Remove scene' --dismiss`. The confirm "Remove this Scene? Undo in Change history restores it until the next change." lists `answer:false` and `getWorkSceneIndex` keeps the Scene. Repeat without `--dismiss`: `scene=` leaves the route and the index drops the Scene.
- **Remove from the structure menu.** In the dialog, add a draft named "Disposable draft", then `click --role button --name 'Back to scenes'`. `click --role button --name 'Disposable draft' --button right` and `click --role menuitem --name 'Remove scene' --dismiss`, then the same pair without `--dismiss`. The index keeps the Scene after Cancel and drops it after OK.

## Gotchas

- Creating a Scene from the structure dialog leaves the dialog open behind the editor. "Back to scenes" brings it back and hides `main` from `snapshot`. Close it first.
- The editor has two `main` landmarks. Use `snapshot --role main --nth 0`.
- "The Salt Bell" is both a Chapter and a Scene, so `Move The Salt Bell up` matches twice. Add `--nth`.
- In the sample, sorting by title changes nothing until a Chapter's Scenes are out of title order.

## Source and tests

- `src/renderer/features/authoring/SceneSelector.tsx`, `SceneDetailEditor.tsx`, `SceneSequenceView.tsx`, `sceneSequence.ts`, `WritingWorkspaceViews.tsx`, `WritingWorkspacePage.tsx`.
- `src/backend/services/writing-service.ts`, `src/shared/writing.ts`.
- `npm test -- src/renderer/features/authoring/WritingWorkspacePage.test.tsx src/renderer/features/authoring/WritingWorkspacePage.removal.test.tsx src/backend/services/writing-service.test.ts`.
