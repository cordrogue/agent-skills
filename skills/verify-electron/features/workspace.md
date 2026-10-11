# Workspace cards

Named workspaces hold world-record cards in tiles or columns. A writer creates and copies workspaces, adds and arranges cards, and opens or removes them.

## Sub-features

- `workspace-names` creates, copies, lists, and reopens named workspaces.
- `workspace-add` adds records through the picker, the empty-area menu, "Open in workspace", or a sidebar drag.
- `workspace-record` opens a card's record and removes a card without touching the record.
- `workspace-layout` switches Tiles and Columns, splits a card, and resizes a split.
- `workspace-move` reorders cards from Card actions or by dragging.
- `workspace-image` changes a card's image shape.
- `workspace-delete` deletes a workspace and keeps its records.

## How to get to it (user POV)

- Activity bar "Workspaces", route `#/workspace?workspace=<uuid>`. The toolbar has tabs Tiles and Columns, "Add card", "New workspace", "Save workspace as…", "Delete workspace", and combobox "Workspace" (first option "All workspaces", route `#/workspace?view=all`).
- Each card is an `article` with "Drag to move", "Card actions", `Open <name>`, and "Remove card". Splits are separators "Resize workspace split".
- Record menus in collections and on Board offer "Open in workspace".

## Driving it with verify-electron

Preconditions:

- Fixtures are characters Mara Venn (id 1), Sera Nhal, Tovan Ash, and Kesh Ash.
- Workspaces live in renderer `localStorage` under `app-card-workspace`, apart from project data. Read them with `eval 'JSON.parse(localStorage.getItem("app-card-workspace"))'`.
- Check that records survive with `eval '(async () => (await window.appHost.invoke("records.character.list", {show:"all"}, {at:20000000})).output.items.map((c) => c.title))()'`.

- **Create.** `click --role button --name 'Workspaces'`, `click --role button --name 'New workspace'`, `type 'Verification desk'`, and `click --role button --name 'Create workspace'`. The heading reads "Verification desk" and region "Card workspace" says "Empty workspace".
- **Picker.** `click --role button --name 'Add card'`. Dialog "Add workspace card" focuses combobox "Search world records". `type 'Mara Venn'` and `press Enter` add a card with "Open Mara Venn". Repeat with 'Sera Nhal'; a separator "Resize workspace split" with value 50 joins them.
- **Empty-area menu.** In an empty workspace, `click --role region --name 'Card workspace' --button right` offers menuitem "Add card", which opens the same dialog.
- **Record menu.** On Items or Board, a record menu's `click --role menuitem --name 'Open in workspace'` goes to `#/workspace?workspace=<uuid>` with that record's card. With no workspace yet, it creates "Untitled workspace".
- **Sidebar drag.** `click --role button --name 'Expand sidebar'`, `click --role button --name 'Expand People'`, and `drag --role button --name 'Kesh Ash' --role region --name 'Card workspace'`. An "Open Kesh Ash" card joins in a new split.
- **Resize.** `click --role separator --name 'Resize workspace split'` and `press ArrowRight` twice. The separator value goes from 50 to 60.
- **Card actions.** `click --role button --name 'Card actions' --nth 0` opens menu "Card actions" with Open, Move previous, Move next, Split right, Split below, Auto, Portrait, Square, Landscape, and Remove.
- **Move.** `click --role menuitem --name 'Move next'` swaps the card order in `snapshot --role region --name 'Card workspace'`. Dragging also swaps: `drag --role button --name 'Drag to move' --nth 0 '[data-workspace-card-id="<second card id>"]'`, with ids from `eval '[...document.querySelectorAll("[data-workspace-card-id]")].map(e => e.dataset.workspaceCardId)'`.
- **Image shape.** `click --role menuitem --name 'Square'`. The card image turns square beside its text, and the stored workspace includes `square`.
- **Split.** `click --role menuitem --name 'Split below'`, `type 'Tovan Ash'`, and `press Enter`. Tiles puts Tovan below the first card with a new separator.
- **Layout.** `click --role tab --name 'Columns'` selects Columns and keeps every card. `click --role tab --name 'Tiles'` restores the split tree.
- **Open and remove.** `click --role button --name 'Open Mara Venn'` goes to `#/people/1`. Back on the workspace, `click --role button --name 'Remove card' --nth 1` drops that card, and the records query still has the record.
- **Copy and list.** `click --role button --name 'Save workspace as…'`, `type 'Verification copy'`, and `click --role button --name 'Save workspace'`. The heading reads "Verification copy" with the same cards. Choose "All workspaces" in the Workspace combobox (`press Home`, `press Enter`). Region "Workspaces" has links such as "Verification desk 3 cards".
- **Persist.** From All workspaces, `click --role link --name 'Verification desk 3 cards'`. Cards, split values, and the square shape return. After `reload` on the workspace route, `snapshot --role region --name 'Card workspace'` lists the same cards and separator value 60, and the stored workspace in `localStorage` matches.
- **Delete.** `click --role button --name 'Delete workspace' --dismiss` lists the confirm `Delete workspace "Verification desk"? Its records are kept.` with `answer:false`, and the stored workspace titles are unchanged. `click --role button --name 'Delete workspace'` answers OK. The route moves to another workspace, the stored titles drop "Verification desk", and the records query still has its records.

## Gotchas

- A fresh `start` has no stored workspaces. The first "Open in workspace" or "Workspaces" visit creates "Untitled workspace".
- Card controls repeat per card. Add `--nth` or scope with a `[data-workspace-card-id]` selector.

## Source and tests

- `src/renderer/features/workspace/WorkspacePage.tsx`, `WorkspacePane.tsx`, `cardWorkspaceStore.ts`, `workspaceLayout.ts`, `workspaceCardFormat.ts`.
- `src/renderer/components/design-system/ElementContextMenu.tsx`, `src/renderer/lib/recordDrag.ts`.
- `npm test -- src/renderer/features/workspace`.
