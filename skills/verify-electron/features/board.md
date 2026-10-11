# Board

Board is one saved canvas of world-record cards, sticky notes, and directed arrows. The writer drags records in from the sidebar, writes notes, moves and links cards, previews or opens records, and removes items with undo.

## Sub-features

- `board-records` adds a record card by dragging a sidebar record onto the canvas.
- `board-notes` adds sticky notes from Add note, a canvas double-click, or the canvas menu, and edits them.
- `board-arrange` moves cards, pans with the wheel, zooms with Control and the wheel, and fits the board.
- `board-link` draws a directed arrow from a card's Connect node handle and refuses duplicates and self-links.
- `board-remove` deletes arrows, notes, and record cards, and Control+z restores them.
- `board-open` previews a record, opens its page, or opens it in a workspace.

## How to get to it (user POV)

- Activity bar "Board", route `#/board`. The canvas is a region "Board" with "Add note" and "Fit" buttons.
- "Expand sidebar", then `Expand <section>`, then drag a record button onto the canvas.
- The empty canvas menu offers "Add note here" and "Fit board". A note menu offers "Edit note" and "Delete note". A record card menu offers Open, Open in workspace, Copy name, Copy link, Preview, and Remove from board. An arrow menu offers "Delete arrow".

## Driving it with verify-electron

Preconditions:

- `eval '(async () => (await window.appHost.invoke("getBoard", undefined, {})).output)()'` returns `null` on the sample. Board saves debounce for 300 ms, so poll `getBoard()` with `wait --until`.
- Fixture is Mara Venn, character id 1.

- **Enter.** `click --role button --name 'Board'`. Region "Board" holds the hint "Drag records here from the sidebar. Double-click to add a note."
- **Record card.** Run `click --role button --name 'Expand sidebar'`, `click --role button --name 'Expand People'`, then `drag --role button --name 'Mara Venn' --role region --name 'Board'`. A card `generic "Mara Venn"` appears at the canvas center. Poll `wait --until '(async () => (await window.appHost.invoke("getBoard", undefined, {})).output?.nodes?.some(n => n.type === "record" && n.recordId === 1))()'`.
- **Add note.** `click --role button --name 'Add note'` adds a `generic "Sticky note"` with textbox "Note text" focused. Run `type 'Check the Rim Road bearings'` and `click --role button --name 'Fit'` to blur. Poll `getBoard()` until a node has `type: "note"` and that text.
- **Move.** The new note lands on top of the card. `drag --role generic --name 'Sticky note' --dx 350 --dy 0` grows the note's stored `x` by 350.
- **Link.** Run `hover --role generic --name 'Sticky note'`, then `drag --role button --name 'Connect node' --nth 1 --role generic --name 'Mara Venn'`. An arrow points from the note to Mara, and `getBoard().edges` holds one edge with `from` the note id and `to` the card id. Repeating the drag, or dropping the handle on its own note, leaves one edge.
- **Edit note.** `click --role generic --name 'Sticky note' --count 2` opens the textbox with the caret at the click point. Run `press Control+End`, `type ' Confirmed.'`, and `click --role button --name 'Fit'`. Poll `getBoard()` for "Check the Rim Road bearings Confirmed.".
- **Delete arrow.** Run `click '[data-board-edge-id] path[stroke="transparent"]'` and `press Delete`. Poll until `edges.length === 0`. `press Control+z` restores the same edge id.
- **Delete note.** Run `click --role generic --name 'Sticky note' --button right` and `click --role menuitem --name 'Delete note'`. The note and its arrow leave `getBoard()`. `press Control+z` restores both.
- **Remove card.** Run `click --role generic --name 'Mara Venn' --button right` and `click --role menuitem --name 'Remove from board'`. The record node and its arrow leave `getBoard()`, and `eval '(async () => (await window.appHost.invoke("records.character.list", {show:"all"}, {at:20000000})).output.items.map((c) => c.title))()'` still has Mara. Undo restores them. `click --role generic --name 'Mara Venn'` then `press Backspace` also removes the selected card.
- **Pan and fit.** Read `eval 'document.querySelector("section[aria-label=\"Board\"] > div").style.transform'`. `scroll --role region --name 'Board' --dy 400` shifts its translate y by about -400, and `--dy -400` shifts it back. The canvas menu's "Fit board" or the "Fit" button reframes all cards, scaling below 1 when they spread out.
- **Zoom.** From `scale(1)`, `scroll --role region --name 'Board' --dy -20 --modifiers Control` gives `scale(1.2214)`, with the translate moved so the point under the pointer stays put. Each Control wheel event scales by at most 2x either way, so `--dy -600 --modifiers Control` gives `scale(2)` and `--dy 600 --modifiers Control` halves it. Scale stops at 3 (observed) and 0.2 (`BOARD_ZOOM_LIMITS`).
- **Canvas notes.** With the center empty after a pan, run `click --role region --name 'Board' --button right` and `click --role menuitem --name 'Add note here'`, or `click --role region --name 'Board' --count 2`. Each opens a focused "Note text".
- **Preview.** Run `click --role generic --name 'Mara Venn' --button right` and `click --role menuitem --name 'Preview'`. Dialog "Mara Venn" shows "33 years", her summary, Role, Status, Location, Affiliation, "Open", and "Close". Its "Open" goes to `#/people/1`.
- **Open.** `click --role generic --name 'Mara Venn' --count 2` goes to `#/people/1`. The card menu's "Open in workspace" goes to `#/workspace?workspace=<uuid>` with a Mara card.
- **Persist.** Run `reload` on `#/board` and `wait --role generic --name 'Mara Venn'`. The record card returns and matches `getBoard()`. Leaving through Overview and returning brings back every card, note, and arrow.

## Gotchas

- Check what sits at the canvas center with `eval 'document.elementFromPoint(847,454)'` before a canvas click. After Fit, an arrow can cross the center, turning the canvas menu into "Delete arrow", and a double-click on a note edits that note.
- The record card has no accessible role beyond `generic`. Its sidebar twin is a button, so keep `--role generic`.

## Source and tests

- `src/renderer/features/board/BoardPage.tsx`, `RecordPreviewSheet.tsx`, `ProjectBoardSync.tsx`, `boardStore.ts`, `boardSync.ts`, `boardGeometry.ts`.
- `src/renderer/lib/recordDrag.ts`, `src/renderer/lib/useCanvasViewport.ts`, `src/shared/board.ts`, `src/backend/services/board-service.ts`.
- `npm test -- src/renderer/features/board src/backend/services/board-service.test.ts`.
