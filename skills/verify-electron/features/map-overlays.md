# Map overlays

The Map tools toolbar draws pins, lines, routes, areas, place boundaries, influence areas, and links to other map families over a map. A writer selects an overlay to rename it, drags its vertices, hides overlay kinds with Layers, and deletes an overlay from the viewed date.

## Sub-features

- `overlays-pin` places an annotation pin, or a place pin when "Place" is set.
- `overlays-draw` draws Line, Route (with Class), and Area, with "Finish", "Undo point", and "Cancel drawing".
- `overlays-place-shapes` draws Boundary and Influence for a chosen place.
- `overlays-edit` saves a new label from the viewed date or discards it, and drags a vertex.
- `overlays-link` links a point to a target point on another map family.
- `overlays-layers` hides and shows overlay kinds without changing storage.
- `overlays-delete` ends an overlay from the viewed date after a confirm.

## How to get to it (user POV)

- Maps, then `group "Map tools"` in the toolbar: "Select", "Pan", "Pin", "Route", "Line", "Area", "Boundary", "Influence", "Link", "Character", "Measure".
- Each drawing tool opens a sidebar region named after it. Drafts show `group "Drawing"` above the canvas.
- Choose "Map tools" at the sidebar foot for Layers and On this map. Choosing an On this map entry opens "Edit place" or the overlay's editor.
- Right-clicking an overlay offers "Edit overlay" and "Delete overlay".

## Driving it with verify-electron

Preconditions:

- A fresh `start`. Prefix every command with `node scripts/verify-electron.mjs`. Open `#/maps/4` (Glasswake Expedition Logistics) with `shot --route '#/maps/4?worldTick=20000000'`, then `click --role button --name 'Map tools'` and `click --role button --name 'Fit map'`.
- Read overlays with `eval '(async () => (await window.app.getMapContext({mapId:4,asOfTick:20000000})).overlays.map(o => [o.id, o.label, o.content.kind]))()'`, called `<overlays>` below. Fixture Ashfold is overlay `13`; the Starhold Lighthouse link is `24`.
- Points come from `click --role application --name 'Map canvas'` (the canvas center) and from clicks on existing overlay or character circles, which snap to their point.
- New overlays take the next ids. On a fresh sample the first pin below is `26` and the place pin `27`.

- **Annotation pin.** Run `click --role button --name 'Pin'`. `region "Pin"` has "Label" and `combobox "Place"` set to "None". Type `Verification marker` into Label and click the canvas. `<overlays>` gains it with `content` `{kind:"annotation", geometry:{type:"point"}}`.
- **Place pin.** Pan first with `click --role button --name 'Pan'` and `drag --role application --name 'Map canvas' --dx 150 --dy 0`. Choose Pin, then `click --role combobox --name 'Place'` and `press ArrowDown` until it reads a place, then `press Enter` and click the canvas. `<overlays>` gains `{kind:"place", locationId:<id>}`.
- **Line.** Run `click --role button --name 'Line'`, type a Label, then click two targets such as `click '[data-overlay-id="26"] circle'` and `click '[data-overlay-id="27"] circle'`. Run `click --role button --name 'Finish'`. The stored geometry is `{type:"path"}` with two points.
- **Route.** Run `click --role button --name 'Route'`. Set `combobox "Class"` to "Track" (`press ArrowDown`, `press Enter`), add two points, and Finish. Content is `{kind:"route", routeClass:"track"}`.
- **Area.** Run `click --role button --name 'Area'` and add three points, for example `click '[data-overlay-id="24"] g'`, `click '[data-character-id="4"] circle'`, and `click '[data-character-id="6"] circle'`. Finish stores `{type:"polygon"}` with three points.
- **Boundary and Undo point.** Run `click --role button --name 'Boundary'` and add three points. With Place at "Choose a place" the combobox is `[invalid]` and "Finish" is disabled. Pick a place; Finish enables. `click --role button --name 'Undo point'` disables it again until a third point returns. Finish stores `{kind:"boundary", locationId:<id>}`.
- **Influence and Cancel drawing.** Run `click --role button --name 'Influence'`, add two points, then `click --role button --name 'Cancel drawing'`. `group "Drawing"` disappears and nothing is stored. Drawing three points and Finish stores `{kind:"influence"}`.
- **Edit a label.** Run `click --role button --name 'Select'` and `click --role button --name 'Ashfold' --nth 0` (On this map). `region "Edit place"` shows "Label", "Place", "Save overlay", "Discard", "Delete overlay", and "Close selection". Replace Label with `Verification Ashfold pin` and Save overlay. Overlay `13` has that label at `20000000` and "Ashfold" at `19999999`. Type another label, then "Discard" restores the saved one.
- **Drag a vertex.** With Ashfold selected, hide covering overlays with `click --role button --name 'Routes'` and `click --role button --name 'Annotations'`. Run `drag --role graphics-symbol --name 'Move vertex 1' --dx 40 --dy 40`. The point saves at once at `20000000`; `19999999` keeps the old point.
- **Layers.** Each Layers button toggles `[pressed]`. After the steps above, hiding Routes and Annotations drops rendered `[data-overlay-id]` elements from 18 to 7, and "Influence areas" drops them to 6. Showing them returns 18, and `<overlays>` keeps 18 entries throughout.
- **Link.** Run `click --role button --name 'Close selection'` and `click --role button --name 'Link'`. Type a Label, then `click --role combobox --name 'Target map'`, `press End`, `press ArrowUp`, and `press Enter` for "Veyra Harbor and Tidewards". Run `click --role button --name 'Pick target point'`, `click --role application --name 'Target point on Veyra Harbor and Tidewards'`, and click the main canvas. Content is `{kind:"mapLink", targetMapId:3, targetPoint:{…}}`, and `getMapContext({mapId:3,…}).inboundLinks` lists it.
- **Delete, cancelled.** On a fresh map 4, run `click '[data-overlay-id="24"] g' --button right`. The menu offers "Edit overlay" and "Delete overlay". Run `click --role menuitem --name 'Delete overlay' --dismiss`. `dialogs` lists the confirm "Delete Starhold Lighthouse from Bloomtide 1, Year 42 · 21:20?" answered `false`, and `<overlays>` still has `24`.
- **Delete.** Repeat without `--dismiss`. Overlay `24` leaves the canvas and `<overlays>` at `20000000`, and stays at `19999999`. With Ashfold selected (Select tool, `click --role button --name 'Ashfold' --nth 0`), `click --role button --name 'Delete overlay'` asks "Delete Ashfold from Bloomtide 1, Year 42 · 21:20?" and ends overlay `13` the same way.

## Gotchas

- After clicking an overlay as a drawing point, focus sits on that overlay. `press Enter` then selects it instead of finishing. Use the "Finish" button.
- Overlay labels and later overlays cover pin circles. The driver rejects a covered target; pick another, or hide layers.
- An unlabeled place pin is named "place" in the accessibility tree and shows no canvas label. Find it by `data-overlay-id`.
- The last Label and Place carry over between tools and after Cancel drawing.

## Source and tests

- `src/renderer/features/maps/mapTools.ts`, `MapToolbar.tsx`, `MapToolOptions.tsx`, `MapLinkOptions.tsx`, `MapDraftControls.tsx`, `MapLayers.tsx`, `MapCanvas.tsx`, `MapSidebar.tsx`, `MapPage.tsx` (delete confirmation).
- `src/shared/map.ts`, `map-ipc.ts`; `docs/agents/contracts/map-editor.md`.
- `npm test -- src/renderer/features/maps/mapEditor.test.ts src/renderer/features/maps/useMapWrites.test.tsx src/backend/services/map-service.test.ts`.
