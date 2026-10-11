# Writing works

A Work groups Chapters and Scenes. A writer creates, picks, renames, and removes Works, and reads a Work's saved Chapter Scenes as one compiled manuscript.

## Sub-features

- `work-create` creates a named Work with a summary and makes it active.
- `work-select` changes the shown Work from the Work combobox or the sidebar.
- `work-rename` commits a new name on Enter and cancels on Escape.
- `work-read` compiles saved Chapter Scenes and links each to its saved version.
- `work-remove` removes the selected Work.

## How to get to it (user POV)

- Sidebar "Writing", route `#/writing` (Draft tab). The toolbar has tabs Draft, Read, Accepted Plot, and Scene sequence, plus "New Work", "Rename Work", "Remove Work", and a combobox "Work".
- "Expand sidebar", then "Expand Writing", lists Works as buttons named by Work name.
- The Read tab is `&view=manuscript`.

## Driving it with verify-electron

Preconditions:

- The sample has one Work, "The Three Witnesses", so create one before testing selection. Resolve Work ids with `eval '(async()=> (await window.appHost.invoke("listWorks", {}, {})).output.map(w => [w.id, w.name]))()'`.

- **Open.** `click --role button --name 'Writing'`. The combobox "Work" reads "The Three Witnesses" and region "Scene selector" lists Chapters "The Salt Bell", "The Rim Road", "The Ledger", and an Unassigned "Drafting" group.
- **Create.** `click --role button --name 'New Work'` opens a form "Create Work". `click --role textbox --name 'Work name'`, `type 'Verification Work'`, `click --role textbox --name 'Work summary'`, `type 'A verification manuscript.'`, and `click --role button --name 'Create and make active'`. The combobox reads "Verification Work", the route gains `work=<uuid>`, and the selector says "No Scenes yet".
- **Confirm create.** `eval '(async()=>({works:(await window.appHost.invoke("listWorks", {}, {})).output,active:(await window.appHost.invoke("getActiveWork", {}, {})).output}))()'` lists the new Work with its summary, and `active.workId` is its id.
- **Rename.** `click --role button --name 'Rename Work'` opens a focused textbox "Work name" holding the current name. `type 'Verification Work renamed'` and `press Enter`. The combobox and `listWorks` show the new name.
- **Cancel rename.** `click --role button --name 'Rename Work'`, `type 'Discarded name'`, and `press Escape`. The combobox and `listWorks` keep the old name.
- **Select with the combobox.** `click --role combobox --name 'Work'`, `press Home`, `press ArrowDown`, and `press Enter`. Options are "No active Work", then each Work by name. The combobox reads "The Three Witnesses" and `eval '(async () => (await window.appHost.invoke("getActiveWork", {}, {})).output)()'` returns its id.
- **Select from the sidebar.** `click --role button --name 'Expand sidebar'`, `click --role button --name 'Expand Writing'`, then `click --role button --name 'Verification Work renamed'`. The route's `work=` and the combobox change. The stored active Work does not.
- **Read.** With "The Three Witnesses" shown, `click --role tab --name 'Read'`. Article "The Three Witnesses compiled Manuscript" lists Chapters in order with their Scenes. "Ilsabet's Letter", the unassigned draft, is absent.
- **Open saved source.** `click --role button --name 'Open The Salt Bell saved Version 1'`. The route gains `view=write&scene=<uuid>&version=<uuid>` and the editor shows "Return to draft".
- **Remove.** With the Work to remove shown, `click --role button --name 'Remove Work' --dismiss` lists the confirm "Remove this Work? Undo in Change history restores it until the next change." with `answer:false`, and `listWorks` and `getActiveWork` are unchanged. `click --role button --name 'Remove Work'` answers OK. `listWorks` drops the Work, `work=` leaves the route, and removing the active Work leaves `getActiveWork({})` at `workId: null` with the page reading "No active Work".

## Gotchas

- A sidebar Work click only sets `work=` in the route, which outranks the stored active Work. Use the combobox to prove the stored change.

## Source and tests

- `src/renderer/features/authoring/WritingWorkspacePage.tsx`, `CreateWorkForm.tsx`, `RenameInput.tsx`, `WritingWorkspaceViews.tsx`, `writingWorkspaceMutations.ts`.
- `src/shared/writing.ts`, `src/backend/services/writing-service.ts`.
- `npm test -- src/renderer/features/authoring/CreateWorkForm.test.tsx src/renderer/features/authoring/WritingWorkspacePage.test.tsx`.
