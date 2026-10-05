# Catalog records

Items, Powers, Factions, Ecology, Organizations, Lore, Bestiary, Cultures, and Materials share one record page. A writer opens a collection, opens a record, creates a record dated at the viewed date, records a dated change, and removes a record added by mistake.

## Sub-features

- `catalog-list` opens each collection from the sidebar.
- `catalog-detail` opens a record from its collection, its context menu, the expanded sidebar, or a record link.
- `catalog-create` saves a new record at the viewed date.
- `catalog-discard` asks before discarding an unsaved draft.
- `catalog-edit` saves a dated change and shows it on the reopened record.
- `catalog-remove` removes a record added by mistake. Powers and Factions offer End instead.

## How to get to it (user POV)

- Sidebar section buttons open the collections.

| Sidebar button | Route | Create button |
| --- | --- | --- |
| Items | `#/items` | Add item |
| Powers | `#/powers` | Add power |
| Factions | `#/factions` | Add faction |
| Ecology | `#/ecology` | Add ecology entry |
| Organizations | `#/organizations` | Add organization |
| Lore | `#/lore` | Add lore entry |
| Bestiary | `#/bestiary` | Add creature |
| Cultures | `#/cultures` | Add culture entry |
| Materials | `#/materials` | Add material |

- A collection card is a button named `Open <name>`. Its context menu offers Open, Open in workspace, Copy name, and Copy link. Detail routes append `/<numeric id>`.
- After "Expand sidebar", each section has `Expand <section>`, which lists records as buttons named by the record name alone.
- Record links, such as a character's Possessions list, are links named by the record name.
- Create and Add change buttons sit in the top toolbar, next to Save and Cancel while editing.

## Driving it with verify-electron

Preconditions:

- A fresh `start`. Commands below are `node scripts/verify-electron.mjs` subcommands. Viewed date is Bloomtide 1, Year 42 · 21:20 (tick 20000000).
- Fixtures are item "Brineglass Compass" (id 1, owner Mara Venn) and ecology entry "Brineglass Reefs". Cultures and Materials have no sample records.

- **List.** Run `click --role button --name 'Items'`. The route is `#/items` and main has a list "Items" with "Open Brineglass Compass". `click --role button --name 'Cultures'` shows "No cultures at this date."
- **Detail.** Run `click --role button --name 'Open Brineglass Compass'` and `wait --role heading --name 'Brineglass Compass'`. The route is `#/items/1`. Detail lists Quantity 1 and an Owner link "Mara Venn". The toolbar has "Add change", "History", and "Show details".
- **Context menu.** Back on Items, run `click --role button --name 'Open Brineglass Compass' --button right`, then `click --role menuitem --name 'Open'`. The route is `#/items/1`.
- **Sidebar.** Run `click --role button --name 'Expand sidebar'`, `click --role button --name 'Expand Items'`, then `click --role button --name 'Brineglass Compass'`. The route is `#/items/1`.
- **Record link.** On the item, run `click --role link --name 'Mara Venn'`. Mara's Possessions list "Mara Venn inventory" has a link "Brineglass Compass". `click --role link --name 'Brineglass Compass'` returns to `#/items/1`.
- **Create.** On Items run `click --role button --name 'Add item'`. The toolbar heading reads "New item" and Save is disabled. Run `click --role textbox --name 'Name'`, `type 'Verification item'`, `click --role textbox --name 'Summary'`, `type 'Created through the item editor.'`, then `click --role button --name 'Save'`. Run `wait --role heading --name 'Verification item'`. The route gains the new id (9 on a fresh sample).
- **Confirm create.** `eval '(async () => (await window.app.listItems({asOfTick:20000000,editorialRevisionId:"head"})).find(x => x.name === "Verification item"))()'` returns the summary and `existsFromTick: 20000000`.
- **Edit.** Run `click --role button --name 'Add change'`, `click --role textbox --name 'Summary'`, `press Control+a`, `type 'Changed through the item editor.'`, and `click --role button --name 'Save'`. Save keeps the editor open. Poll `wait --until '(async () => (await window.app.getItem({id:<id>,asOfTick:20000000,editorialRevisionId:"head"})).record?.summary === "Changed through the item editor.")()'`. `click --role button --name 'Cancel'` returns to detail, which shows the new summary.
- **Other kinds.** Ecology uses the same flow with `Add ecology entry`, Name, Subtype, and Summary. Confirm through `window.app.listCatalogEntries({kind:"ecology",asOfTick:20000000,editorialRevisionId:"head"})` and `getCatalogEntry({id,kind:"ecology",asOfTick:20000000,editorialRevisionId:"head"})`.
- **Discard.** Run `click --role button --name 'Add ecology entry'`, type a Name, then `click --role button --name 'Cancel'`. A dialog "Discard this new ecology entry draft?" offers "Keep editing" (focused) and "Discard". Keep editing leaves the typed name. Discard returns to the list, and `listCatalogEntries` has no such name.
- **Remove.** Save a disposable item ("Disposable item", id 9 on a fresh sample) and run `click --role button --name 'Add change'`. The toolbar shows "End" and "Remove mistake". Powers and Factions show only "End". `click --role button --name 'Remove mistake' --dismiss` lists the confirm "Remove this item? Undo in Change history restores it until the next change." with `answer:false`, and `listItems` still has the item. `click --role button --name 'Remove mistake'` answers it OK, the route returns to `#/items`, and `listItems` no longer has it.

## Gotchas

- The item editor also has Type, Quantity, Condition, Owner, Place, and Choose image. Leave the date group "Change from this date onward" at the viewed date.
- Collection cards are `Open <name>` buttons. Sidebar record buttons and record links use the bare name. Collapse an expanded sidebar section ("Collapse Items") before targeting a bare name elsewhere on the page.

## Source and tests

- `src/renderer/features/shared/RecordPageView.tsx`, `recordPage.ts`, `RecordFields.tsx`, `recordFaces.tsx`.
- `src/renderer/features/items/ItemPage.tsx`, `ItemEditor.tsx`; `src/renderer/features/catalog/CatalogPage.tsx`, `CatalogEditor.tsx`; `src/renderer/features/entities/PowersPage.tsx`, `FactionsPage.tsx`.
- `npm test -- src/renderer/features/items/ItemPage.test.tsx src/renderer/features/catalog/CatalogPage.test.tsx src/renderer/features/entities/PowersPage.test.tsx src/renderer/features/entities/FactionsPage.test.tsx src/renderer/features/shared/recordPage.test.tsx`.
- `npm test -- src/backend/services/item-service.test.ts src/backend/services/catalog-entry-service.test.ts`.
