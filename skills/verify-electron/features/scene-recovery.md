# Scene recovery and versions

Edits to scene prose autosave as a protected recovery draft that survives leaving the Scene. Save version turns the draft into a numbered saved version, which opens read-only until the writer returns to the draft.

## Sub-features

- `recovery-autosave` protects an edit as a recovery draft without creating a version.
- `recovery-reload` keeps the edited prose after leaving the Scene and coming back, and after a page reload.
- `version-save` saves the draft as the next version number.
- `version-view` shows a saved version read-only, from the save or from Version history.
- `version-return` returns from a saved version to the draft.

## How to get to it (user POV)

- Sidebar "Writing", then a Draft index row such as "Open The Salt Bell". Route `#/writing?view=write&scene=<uuid>`.
- A shown saved version adds `&version=<uuid>`.
- "More editor actions", then "Version history", opens dialog "Versions · <count>" with "Open recovery draft" and `Open saved Version <n>` buttons.

## Driving it with verify-electron

Preconditions:

- Fixture is Scene "The Salt Bell" in Work "The Three Witnesses". Every sample Scene starts with Version 1 saved. Resolve the scene id with `eval '(async()=>{const w=(await window.appHost.invoke("listWorks", {}, {})).output.find(w=>w.name==="The Three Witnesses");return (await window.appHost.invoke("getWorkSceneIndex", {workId:w.id}, {})).output.scenes.find(s=>s.title==="The Salt Bell").id;})()'`.

- **Open.** `click --role button --name 'Writing'` and `click --role button --name 'Open The Salt Bell'`. The textbox "Scene prose" holds the sample prose, and the footer status reads "Recovery draft protected".
- **Edit.** `click --role textbox --name 'Scene prose'`, `press Control+End`, and `type ' Verification line.'`. The footer status reads "Recovery draft pending", then "Recovery draft protected"; poll with `wait --until '[...document.querySelectorAll("[role=status]")].some(e => e.textContent.includes("Recovery draft protected"))'`. `getSceneWriting({sceneId}).selected.scene.recoveryDraft.bodyMarkdown` ends with the typed text, and `listSceneVersions({sceneId})` still has one item.
- **Leave and return.** `click --role button --name 'Overview'`, `click --role button --name 'Writing'`, and `click --role button --name 'Open The Salt Bell'`. `wait --until 'document.querySelector("[aria-label=\"Scene prose\"]")?.value.endsWith("Verification line.")'` passes and "Save version" is enabled.
- **Reload.** `eval 'window.__marker = 1'` and `reload`. The route keeps `scene=<uuid>`, `eval 'window.__marker'` is undefined on the fresh page, and the same `wait --until` on the prose passes. The footer reads "Recovery draft protected" and "Save version" stays enabled.
- **Save version.** `click --role button --name 'Save version'` and `wait --until 'location.hash.includes("version=")'`. The footer reads "Version 2 · The Salt Bell", the toolbar shows "Return to draft", and "Scene prose" is `[readonly]`. `eval '(async()=> (await window.appHost.invoke("listSceneVersions", {sceneId:"<sceneId>"}, {})).output.items.map(v=>v.versionNumber))()'` returns `[2,1]`.
- **History.** `click --role button --name 'More editor actions'`, `click --role menuitem --name 'Version history'`, then `click --role button --name 'Open saved Version 1'`. The hash's `version=` changes, the footer reads "Version 1 · The Salt Bell", and the prose is read-only.
- **Return.** `click --role button --name 'Return to draft'`. `version=` leaves the hash and "Save version" is disabled until the next edit.

## Gotchas

- On a project with earlier saves, Save version produces the next unused number, not 2.
- Snapshot values truncate long prose. Read the full text with `eval` on the textarea `value` or on `getSceneWriting`.
- The editor has two `main` landmarks. Use `snapshot --role main --nth 0`.
- Control+z in Scene prose undoes one character per press. That is a filed product gap, not a driver fault.

## Source and tests

- `src/renderer/features/authoring/WritingWorkspaceViews.tsx` (autosave queue and status), `SceneDetailEditor.tsx`, `sceneRecoveryQueue.ts`, `useSceneRecoveryAutosave.ts`, `WritingWorkspacePage.tsx`, `writingWorkspaceMutations.ts`, `writingQueries.ts`.
- `src/backend/services/writing-service.ts`, `src/shared/writing.ts`.
- `npm test -- src/renderer/features/authoring/WritingWorkspacePage` (split by area: `.recovery`, `.removal`, `.names`).
- `npm test -- src/backend/services/writing-service.test.ts`.
