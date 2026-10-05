# Names and mentions in prose

The scene editor suggests existing record names while the writer types. Scene context lists the records a saved version mentions, lets the writer mark characters present, and proposes new records from cued names.

## Sub-features

- `name-click` replaces a typed prefix with a clicked suggestion.
- `name-keyboard` accepts the first suggestion with Tab.
- `name-dismiss` closes suggestions with Escape and keeps the typed text.
- `saved-mentions` lists mentioned characters, items, and events, plus ambiguous forms, and links to each record.
- `character-presence` marks a character present apart from prose mentions.
- `name-proposals` finds cued new names in the saved version and accepts one as a record.

## How to get to it (user POV)

- Sidebar "Writing", then "Open The Salt Bell" in the Draft index.
- Typing in "Scene prose" opens a group "Name suggestions" of buttons.
- Region "Scene context" under the prose has "Find new names", regions Characters, Items, Events, and Ambiguous, record links, and `<name> present` checkboxes.

## Driving it with verify-electron

Preconditions:

- A fresh `start`. Commands below are `node scripts/verify-electron.mjs` subcommands. Fixture is Scene "The Salt Bell". Mara Venn is character id 1.
- Resolve `<sceneId>` as in [scene-recovery.md](scene-recovery.md) and `<versionId>` with `eval '(async()=> (await window.app.getSceneWriting({sceneId:"<sceneId>"})).selected.currentVersion.id)()'`.

- **Open.** Run `click --role button --name 'Writing'` and `click --role button --name 'Open The Salt Bell'`. Scene context lists Mara Venn, Sera Nhal, Tovan Ash, and Captain Orin Venn, item Cinderglass Ledger, and event Moonfall Accord.
- **Click a name.** Run `click --role textbox --name 'Scene prose'`, `press Control+End`, `press Enter`, and `type 'Ma'`. "Name suggestions" lists "Mara Venn", "Mariner's Vault", and "Mara". Run `click --role button --name 'Mara Venn'` and `wait --role group --name 'Name suggestions' --gone`. Poll `wait --until '(async()=> (await window.app.getSceneWriting({sceneId:"<sceneId>"})).selected.scene.recoveryDraft.bodyMarkdown.endsWith("Mara Venn"))()'`.
- **Tab.** Run `press Enter`, `type 'Ser'`, and `press Tab`. Suggestions were "Sera Nhal" and "Sera". The draft ends with "Sera Nhal".
- **Dismiss.** Run `press Enter`, `type 'To'`, `wait --role group --name 'Name suggestions'`, `press Escape`, and `wait --role group --name 'Name suggestions' --gone`. The draft ends with "To" and the editor stays open.
- **Mentions.** `eval 'window.app.listSceneVersionMentions({sceneVersionId:"<versionId>"})'` holds a mention with `form: "Mara Venn"`. Run `click --role link --name 'Mara Venn'`. The route is `#/people/1`. `click --role button --name 'Go back'` returns to the Scene.
- **Presence.** Run `click --role checkbox --name 'Mara Venn present'`. It reads `[checked]`, and `listSceneVersionMentions` has `presentCharacterIds: [1]`. Clicking again unchecks it and empties the array. The Mara Venn link stays.
- **Propose.** Run `click --role textbox --name 'Scene prose'`, `press Control+End`, `type ' Captain Brannoch waited.'`, `click --role button --name 'Save version'`, and `click --role button --name 'Find new names'`. Region "Possible new records" shows "Brannoch", "character", "Accept", and "Reject". Run `click --role button --name 'Accept'`. Poll `wait --until '(async () => (await window.app.listCharacters({})).some(c => c.name === "Brannoch"))()'`. Characters gains a "Brannoch" link and "Brannoch present".
- **No proposals.** On the unchanged sample version, "Find new names" shows the alert "No new character, location, or item mentions were found."

## Gotchas

- Proposals come only from cue patterns such as "Captain <Name>", "city of <Name>", or "sword named <Name>". A bare new name like "Verity Holloway" finds nothing.
- Scene context reads the shown saved version, or the current version while editing the draft. Draft edits change mentions only after Save version.
- Suggestions replace prose text and insert no link. They need two typed characters.
- "Mara Venn" names both a suggestion button and a context link. Keep `--role` on every target.

## Source and tests

- `src/renderer/features/authoring/SceneDetailEditor.tsx`, `nameCompletion.ts`, `SceneContextPanel.tsx`.
- `src/shared/scene-mentions.ts`, `src/backend/services/manuscript-extraction-service.ts`.
- `npm test -- src/renderer/features/authoring/WritingWorkspacePage.names.test.tsx src/renderer/features/authoring/SceneContextPanel.test.tsx src/backend/services/manuscript-extraction-service.test.ts`.
