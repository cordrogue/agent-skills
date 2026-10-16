# Board

Board is one saved canvas of world-record cards, sticky notes, and directed arrows. The writer drags records in from the sidebar, writes notes, moves and links cards, previews or opens records, and removes items with undo. It is a plain framework feature, `src/features/board`, drawn on the kit `Canvas`. Its edits are project writes, so none reaches Change history.

## Sub-features

- `board-records` adds a record card by dragging a sidebar record or map onto the canvas.
- `board-notes` adds sticky notes from Add note, a canvas double-click, or the canvas menu, and edits them.
- `board-arrange` moves cards, pans with the wheel, zooms with Control and the wheel, and fits the board with an eased move.
- `board-link` draws a directed arrow from a card's Connect node handle and refuses duplicates and self-links.
- `board-remove` deletes arrows, notes, and record cards. Control+z undoes moves, note edits, additions and removals, one step each.
- `board-open` previews a record, opens its page, or opens it in a workspace.

## How to get to it (user POV)

- Activity bar "Board", route `#/board`. The canvas is a region "Board" with "Add note" and "Fit" buttons.
- "Expand sidebar", then `Expand <section>`, then drag a record button onto the canvas.
- Each card is an `article` named by its title, or "Sticky note" for a note, with a "Connect node" button after it. The empty canvas menu offers "Add note here" and "Fit board". A note menu offers "Edit note" and "Delete note". A record card menu offers Open, Open in workspace, Copy name, Copy link, Preview, and Remove from board. An arrow menu offers "Delete arrow".

## Driving it with verify-electron

Preconditions:

- `eval '(async () => (await window.appHost.invoke("board.show", {}, {at:20000000})).output)()'` returns `{"cards":[],"arrows":[]}` on the sample. Each gesture sends one command when it ends. The card draws at once, dimmed (`data-dimmed` on its card) until the host stores it, so read `board.show` once the dimming clears, or poll it with `wait --until`.
- Fixture is Mara Venn, character id 1, and the map Glasswake Expedition Logistics, map id 4.

- **Enter.** `click --role button --name 'Board'`. Region "Board" holds the hint "Drag records here from the sidebar. Double-click to add a note."
- **Record card.** Run `click --role button --name 'Expand sidebar'`, `click --role button --name 'Expand People'`, then `drag --role button --name 'Mara Venn' --role region --name 'Board'`. A card `article "Mara Venn"` appears centered on the drop point, with her image and a caption band reading "Mara Venn" and "Character". `board.show` then has a card with `type: "record"`, `record: {kind: "character", id: 1}`, `layer: 1`, and a 32-character hex `id`.
- **Map card.** Run `click --role button --name 'Expand Maps'` and `drag --role button --name 'Glasswake Expedition Logistics' --role region --name 'Board'`. The card `article "Glasswake Expedition Logistics"` draws the map image, captioned "1536 × 1024", and `board.show` holds `record: {kind: "map", id: 4}`. `eval '[...document.querySelectorAll("article[aria-label=\"Glasswake Expedition Logistics\"] img")].map((i) => i.naturalWidth)'` reads `[1536]`.
- **Add note.** `click --role button --name 'Add note'` adds an `article "Sticky note"` at the canvas center with textbox "Note text" focused. Run `type 'Check the Rim Road bearings'` and `click --role button --name 'Fit'` to blur. `board.show` then has a card with `type: "note"` and that text.
- **Move.** The new note lands on top of the card. `drag --role article --name 'Sticky note' --dx 350 --dy 0` grows the note's stored `x` by exactly 350 at zoom 1.
- **Link.** Run `hover --role article --name 'Sticky note'`, then `drag --role button --name 'Connect node' --nth 1 --role article --name 'Mara Venn'`. An arrow points from the note to Mara, and `board.show` has one arrow with `from` the note id and `to` the card id. Repeating the drag, or dropping the handle on its own note, leaves one arrow.
- **Edit note.** `click --role article --name 'Sticky note' --count 2` opens the textbox. Run `press Control+End`, `type ' Confirmed.'`, and `click --role button --name 'Fit'`. `board.show` reads "Check the Rim Road bearings Confirmed.".
- **Delete arrow.** Run `click '[data-canvas-arrow] path:first-child'` and `press Delete`. `board.show` has no arrows. `press Control+z` restores the same arrow id.
- **Delete note.** Run `click --role article --name 'Sticky note' --button right` and `click --role menuitem --name 'Delete note'`. The note and its arrow leave `board.show`. `press Control+z` restores both with the same ids and the note's `layer`.
- **Remove card.** Run `click --role article --name 'Mara Venn' --button right` and `click --role menuitem --name 'Remove from board'`. The record card and its arrow leave `board.show`, and `eval '(async () => (await window.appHost.invoke("records.character.list", {show:"all"}, {at:20000000})).output.items.map((c) => c.title))()'` still has Mara. Undo restores the card at `layer: 1`, under the note, with its arrow. `click --role article --name 'Mara Venn'` then `press Backspace` also removes the selected card.
- **Pan and fit.** Read `eval 'document.querySelector("section[aria-label=\"Board\"] > div").style.transform'`. `scroll --role region --name 'Board' --dy 400` shifts its translate y by about -400, and `--dy -400` shifts it back. The canvas menu's "Fit board" or the "Fit" button reframes all cards at a zoom between 0.2 and 1, easing over 450 ms: `record --eval '<the transform>' --after-ms 800 --during click --role button --name 'Fit'` reports a change on most frames of the move, where a jump would report one. Click a card only after the move ends, because a card in motion is not found.
- **Zoom.** From `scale(1)`, `scroll --role region --name 'Board' --dy -20 --modifiers Control` gives `scale(1.2214)`, with the translate moved so the point under the pointer stays put. Each Control wheel event scales by at most 2x either way, so `--dy -600 --modifiers Control` doubles it and `--dy 600 --modifiers Control` halves it. Scale stops at 3 and 0.2.
- **Remembered view.** After a pan, zoom or Fit, `eval 'Object.keys(localStorage).filter((k) => k.includes("/board/"))'` lists `app/remember/1/project/<project id>/board/x`, `/y` and `/zoom`. After `restart` the transform is the same.
- **Canvas notes.** With the center empty after a pan, run `click --role region --name 'Board' --button right` and `click --role menuitem --name 'Add note here'`, or `click --role region --name 'Board' --count 2`. Each adds a note with a focused "Note text".
- **Preview.** Run `click --role article --name 'Mara Venn' --button right` and `click --role menuitem --name 'Preview'`. Dialog "Mara Venn" shows "Character", her summary, Type, Gender, Role, Current situation, Notable traits, Origin, Affiliation, Home, Location, "Open", and "Close". Its "Open" goes to `#/people/1`.
- **Open.** `click --role article --name 'Mara Venn' --count 2` goes to `#/people/1`. The card menu's "Open in workspace" goes to `#/workspace?workspace=<uuid>` with a Mara card.
- **Persist.** Run `reload` on `#/board` and `wait --role article --name 'Mara Venn'`. Every card returns, and `eval '[document.querySelectorAll("[data-canvas-item]").length, document.querySelectorAll("[data-canvas-arrow]").length]'` matches `board.show`. The same holds after `restart`, and after leaving through Overview and returning.
- **No history.** `db 'select count(*) from editorial_revisions'` reads the same before and after every board action, and `db 'select count(*) from board_cards'` matches `board.show`.

## Gotchas

- Check what sits at the canvas center with `eval 'document.elementFromPoint(847,454)?.tagName'` before a canvas click. It reads `SECTION` on empty canvas. After Fit, an arrow can cross the center, turning the canvas menu into "Delete arrow", and a double-click on a note edits that note.
- A record card's sidebar twin is a button, so keep `--role article`.
- `board.show` takes `{}`, not `undefined`.

## Source and tests

- `src/features/board/contract.ts`, `host/service.ts`, `host/rows.ts`, `host/tables.sql`, `ui/view.tsx`, `ui/cards.tsx`, `ui/menu.tsx`, `ui/notices.tsx`, `ui/writer.ts`, `ui/useNoteDrafts.ts`, `ui/client.ts`.
- `src/framework/design/Canvas.tsx` and `src/framework/design/canvas/`, `src/framework/contract/recordDrag.ts`.
- `npm test -- src/features/board src/renderer/features/board src/framework/design/Canvas src/framework/design/canvas`.
