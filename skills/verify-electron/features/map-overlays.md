# Map overlays

The Map tools toolbar draws pins, lines, routes, areas, place boundaries, influence areas, and links to other map families over a map. The writer selects an overlay to rename it or drag its vertices, hides overlay kinds with Layers, and deletes an overlay from the viewed date.

## Sub-features

- `overlays-pin` places an annotation pin, or a place pin when "Place" is set.
- `overlays-draw` draws Line, Route (with Class), and Area, with "Finish", "Undo point", and "Cancel drawing".
- `overlays-place-shapes` draws Boundary and Influence for a chosen place.
- `overlays-edit` saves a new label from the viewed date or discards it, and drags a vertex.
- `overlays-link` links a point to a target point on another map family.
- `overlays-layers` hides and shows overlay kinds without changing storage.
- `overlays-delete` ends an overlay from the viewed date after a confirm.
- `overlays-guard` asks "Discard unsaved changes?" before a drawing in progress loses its date or its page.

## How to get to it (user POV)

- Maps, then `group "Map tools"` in the toolbar: "Select", "Pan", "Pin", "Route", "Line", "Area", "Boundary", "Influence", "Link", "Character", "Measure".
- Each drawing tool opens a sidebar region named after it. Drafts show `group "Drawing"` above the canvas.
- Choose "Map tools" at the sidebar foot for Layers and On this map. Choosing an On this map entry opens "Edit place" or the overlay's editor.
- Right-clicking an overlay offers "Edit overlay" and "Delete overlay".

## Driving it with verify-electron

Preconditions:

- Open `#/maps/4` (Glasswake Expedition Logistics) with `shot --route '#/maps/4?worldTick=20000000'`, then `click --role button --name 'Map tools'` and `click --role button --name 'Fit map'`.
- `<overlays>` below is `eval '(async () => (await window.appHost.invoke("getMapContext", {mapId:4,asOfTick:20000000}, {})).output.overlays.map(o => [o.id, o.label, o.content.kind]))()'`. Fixture Ashfold is overlay `13`; the Starhold Lighthouse link is `24`.
- Points come from `click --role application --name 'Map canvas'` (the canvas center) and from clicks on existing overlay or character circles, which snap to their point.
- New overlays take the next ids. On a fresh sample the first pin below is `26` and the place pin `27`.

- **Annotation pin.** `click --role button --name 'Pin'`. `region "Pin"` has "Label" and `combobox "Place"` set to "None". Type `Verification marker` into Label and click the canvas. `<overlays>` gains it with `content` `{kind:"annotation", geometry:{type:"point"}}`.
- **Place pin.** Pan first with `click --role button --name 'Pan'` and `drag --role application --name 'Map canvas' --dx 150 --dy 0`. Choose Pin, `click --role combobox --name 'Place'`, `press ArrowDown` until it reads a place, `press Enter`, and click the canvas. `<overlays>` gains `{kind:"place", locationId:<id>}`.
- **Line.** `click --role button --name 'Line'`, type a Label, then click two targets such as `click '[data-overlay-id="26"] circle'` and `click '[data-overlay-id="27"] circle'`, and `click --role button --name 'Finish'`. The stored geometry is `{type:"path"}` with two points.
- **Route.** `click --role button --name 'Route'`. Set `combobox "Class"` to "Track" (`press ArrowDown`, `press Enter`), add two points, and Finish. Content is `{kind:"route", routeClass:"track"}`.
- **Area.** `click --role button --name 'Area'` and add three points, for example `click '[data-overlay-id="24"] g'`, `click '[data-character-id="4"] circle'`, and `click '[data-character-id="6"] circle'`. Finish stores `{type:"polygon"}` with three points.
- **Boundary and Undo point.** `click --role button --name 'Boundary'` and add three points. With Place at "Choose a place" the combobox is `[invalid]` and "Finish" is disabled; picking a place enables it. `click --role button --name 'Undo point'` disables it again until a third point returns. Finish stores `{kind:"boundary", locationId:<id>}`. A character whose pin the new boundary holds, and no smaller one, gets that place as `locationId` in `getMapContext({mapId:4,…}).characters` from the viewed date, in the same History entry.
- **Influence and Cancel drawing.** `click --role button --name 'Influence'`, add two points, then `click --role button --name 'Cancel drawing'`. `group "Drawing"` disappears and nothing is stored. Three points and Finish store `{kind:"influence"}`.
- **Drawing guard.** Draw three Boundary points as above, then `click --role button --name 'Expand timeline scrubber'` and `drag --role slider --name 'Scrub visible dates' --dx 250 --dy 0 --steps 10 --step-ms 20`. `dialog "Discard unsaved changes?"` opens and the route keeps `worldTick=20000000`. "Keep editing" leaves 3 `.map-draft-vertex` elements, and Finish stores the boundary at `20000000`. "Discard" moves the date and clears the draft, and `press Enter` then stores nothing. Choosing another map in `combobox "Map"` or opening another page asks the same way, as do a calibration draft and a placed detail rectangle. A Measure draft never asks.
- **Edit a label.** `click --role button --name 'Select'` and `click --role button --name 'Ashfold' --nth 0` (On this map). `region "Edit place"` shows "Label", "Place", "Save overlay", "Discard", "Delete overlay", and "Close selection". Replace Label with `Verification Ashfold pin` and Save overlay. Overlay `13` has that label at `20000000` and "Ashfold" at `19999999`. Type another label, then "Discard" restores the saved one.
- **Drag a vertex.** With Ashfold selected, hide covering overlays with `click --role button --name 'Routes'` and `click --role button --name 'Annotations'`. `drag --role graphics-symbol --name 'Move vertex 1' --dx 40 --dy 40` saves the point at once at `20000000`; `19999999` keeps the old point.
- **Layers.** Each Layers button toggles `[pressed]`. After the steps above, hiding Routes and Annotations drops rendered `[data-overlay-id]` elements from 18 to 7, and "Influence areas" drops them to 6. Showing them returns 18, and `<overlays>` keeps 18 entries throughout.
- **Link.** `click --role button --name 'Close selection'` and `click --role button --name 'Link'`. Type a Label, then `click --role combobox --name 'Target map'`, `press End`, `press ArrowUp`, and `press Enter` for "Veyra Harbor and Tidewards". Run `click --role button --name 'Pick target point'`, `click --role application --name 'Target point on Veyra Harbor and Tidewards'`, and click the main canvas. Content is `{kind:"mapLink", targetMapId:3, targetPoint:{…}}`, and `getMapContext({mapId:3,…}).inboundLinks` lists it.
- **Delete, cancelled.** On a fresh map 4, `click '[data-overlay-id="24"] g' --button right` offers "Edit overlay" and "Delete overlay". `click --role menuitem --name 'Delete overlay' --dismiss` lists the confirm "Delete Starhold Lighthouse from Bloomtide 1, Year 42 · 21:20?" answered `false`, and `<overlays>` still has `24`.
- **Delete.** Repeat without `--dismiss`. Overlay `24` leaves the canvas and `<overlays>` at `20000000`, and stays at `19999999`. With Ashfold selected (Select tool, `click --role button --name 'Ashfold' --nth 0`), `click --role button --name 'Delete overlay'` asks "Delete Ashfold from Bloomtide 1, Year 42 · 21:20?" and ends overlay `13` the same way.

## Gotchas

- After clicking an overlay as a drawing point, focus sits on that overlay, and `press Enter` selects it instead of finishing. Use the "Finish" button.
- Overlay labels and later overlays cover pin circles. The driver rejects a covered target; pick another, or hide layers.
- An unlabeled place pin is named "place" in the accessibility tree and shows no canvas label. Find it by `data-overlay-id`.
- The last Label and Place carry over between tools and after Cancel drawing.
- Place lists, in name order, the places present at the viewed date. An existing pin or shape of an ended place keeps that place as its Place, and saving its label passes. A new shape, or a changed Place, naming a place ended at the viewed date is refused with "Place <name> is not active on <date> (tick <n>)."
- Removing a place that a pin, boundary or influence area named at any date is refused, naming the root map, as in "<place> can't be removed. Glasswake Expedition Logistics (Map) lists it as map boundary." A later change of the shape's Place, or its deletion from a date, keeps the refusal. Correcting the Place away at the shape's own date, or undoing the shape's creation, ends it.

## Source and tests

- `src/renderer/features/maps/mapTools.ts`, `mapPlaces.ts` (framework places at the viewed date), `mapEditor.ts` (the drawing guard), `MapToolbar.tsx`, `MapToolOptions.tsx`, `MapLinkOptions.tsx`, `MapDraftControls.tsx`, `MapLayers.tsx`, `MapCanvas.tsx`, `MapSidebar.tsx`, `MapPage.tsx` (delete confirmation).
- `src/shared/map.ts`, `map-ipc.ts`; `docs/agents/contracts/map-editor.md`.
- `npm test -- src/renderer/features/maps/mapEditor.test.ts src/renderer/features/maps/MapDrawingGuard.test.tsx src/renderer/features/maps/useMapWrites.test.tsx src/renderer/features/maps/MapSidebar.test.tsx src/backend/services/map-service.test.ts src/framework/host/records/legacy-holders.test.ts`.
