# Maps

Maps shows image maps with their overlays and character pins. The writer picks a map, zooms, opens detail maps and linked map families, corrects a root map's scale by number or by calibration, and corrects a detail map's placement on its parent, optionally carrying its contents along.

## Sub-features

- `maps-open` picks a map from the "Map" combobox, fits it, and zooms with the wheel.
- `maps-navigation` opens a detail map from its frame or On this map, returns by Map path or "Parent map", and follows map links both ways.
- `maps-scale` saves "Meters per pixel" for every date of a root map.
- `maps-calibrate` sets scale from two clicked points and a known distance.
- `maps-placement` moves or resizes a detail frame with "Save placement only" or "Save and move <n> items".
- `maps-history` lists dated map entries under "Map history".
- `maps-create` creates a root map, or a detail map placed by two corners on its parent.
- `maps-images` replaces a map image from the viewed date and lists Prior images.
- `maps-remove` removes a map as a mistake after a confirm.

## How to get to it (user POV)

- "Maps" in the sidebar opens `#/maps/<id>`, the map last viewed.
- The toolbar holds `group "Map tools"`, "Fit map", "Zoom to selection", "Remove mistake", and `navigation "Map path"` with `combobox "Map"`.
- "Map tools" at the sidebar foot shows Layers, On this map, and Map settings. "Browse" restores record navigation.

## Driving it with verify-electron

Preconditions:

- Map ids are 1 Lumae, 2 Political Chart, 3 Veyra Harbor, 4 Glasswake Expedition Logistics (root, 100 m per pixel), 5 Starhold Lighthouse Plan, and 6 Rim Road Survey (detail of 4 at `760, 250, 600, 400`).

- **Pick a map.** Run `click --role button --name 'Maps'`, `click --role combobox --name 'Map'`, `press ArrowDown` until the value reads "Glasswake Expedition Logistics", and `press Enter`. The route is `#/maps/4`.
- **Fit and zoom.** Run `click --role button --name 'Fit map'`, then `scroll --role application --name 'Map canvas' --dy -300`. The scale bar (`eval 'document.querySelector("[aria-label=Scale]").textContent'`) goes from "10 km" to "5 km" and the route keeps `#/maps/4`.
- **Detail from its frame.** Run `click --role button --name 'Fit map'` and `click --role button --name 'Open Rim Road Survey'`. The route is `#/maps/6`, and Map path shows a "Glasswake Expedition Logistics" button before the combobox. Click it to return.
- **Detail from On this map.** Run `click --role button --name 'Map tools'` and `click --role button --name 'Open Rim Road Survey map'`. Then `click --role DisclosureTriangle --name 'Map settings'` and `click --role button --name 'Parent map'` return to `#/maps/4`.
- **Map links.** On map 4, `click --role button --name 'Open Starhold Lighthouse Plan map'` routes to `#/maps/5?focus=point%3A170%2C610`, and `getMapContext({mapId:5,asOfTick:20000000}).map.placement` is `{kind:"root", metersPerPixel:0.02}`. There, `click --role button --name 'Linked from Glasswake Expedition Logistics'` returns to `#/maps/4?focus=overlay%3A24`.
- **Scale.** On map 4 with Map settings open, run `click --role spinbutton --name 'Meters per pixel'`, `press Control+a`, and `type '125'`. "Corrects every date of this map." and "Save scale" appear. After `click --role button --name 'Save scale'`, `getMapContext` gives `map.metersPerPixel` 125 at ticks `20000000` and `19999999`, and map 6 becomes 48.83.
- **Calibrate.** Run `click --role button --name 'Fit map'` and `click --role button --name 'Calibrate'`. `region "Calibrate"` says "Click two points a known distance apart." Run `click '[data-overlay-id="24"] g'` (Starhold Lighthouse link) and `click --role application --name 'Map canvas'`; the text becomes "Type the distance between the points." Run `click --role spinbutton --name 'Distance'` and `type '40'`; the preview reads "79.86 m / pixel". `click --role button --name 'Save scale'` stores about 79.86 at both ticks.
- **Placement only.** On map 6, open Map settings and `click --role button --name 'Edit placement'`. The route moves to `#/maps/4` with `region "Placement of Rim Road Survey"` and buttons "Save and move 7 items", "Save placement only", and "Cancel". Run `drag --role graphics-symbol --name 'Move placement' --dx 40 --dy 20`, `drag --role graphics-symbol --name 'Resize placement se' --dx 30 --dy 20`, and `click --role button --name 'Save placement only'`. `listMaps` gives map 6 a new `placement.parentRect` at both ticks, aspect 1.5 kept.
- **Carry contents.** Edit placement again, `drag --role graphics-symbol --name 'Move placement' --dx -40 --dy -20`, and `click --role button --name 'Save and move 7 items'`. Ashfold (overlay 13) moves from `1110, 480` by the frame's offset, as do the pins of Tovan and Kesh, at both ticks, each pin at its own date. Their `locationId` and `influenceLocationIds` in `getMapContext({mapId:4,…}).characters` follow the moved pins in the same History entry, and one undo restores both.
- **History.** Open Map settings and `click --role DisclosureTriangle --name 'Map history'`. `region "Map history"` lists "Dawnmere 1, Year 1" with Name, Image width, Image height, and Placement.
- **New root map.** On map 4, open Map settings and `click --role button --name 'New map'`. Form "New image map" has "Name", "Choose image", "Meters per pixel" (1), and a disabled "Create map". Type `Verification chart`, run `click --role button --name 'Choose image' --file "$HOME/.cache/agent-swarm/<dir>/<map>.png"` (it becomes "Change image" with "1536 × 1024 pixels"), set Meters per pixel to `50`, and `click --role button --name 'Create map'`. The route is `#/maps/7`, and `listMaps` gives it `placement` `{kind:"root", metersPerPixel:50}` and an `imageAssetPath` named by the file's SHA-256.
- **New detail map.** On map 4, choose "New detail map". Form "Detail of Glasswake Expedition Logistics" needs Name and Choose image, then `click --role button --name 'Draw placement'`, `click --role application --name 'Map canvas'`, and `click '[data-overlay-id="24"] g'` for two corners. The text reads "Placement ready. Redraw to change it." Create map opens `#/maps/8`, stored as `{kind:"detail", parentMapId:4, parentRect:{…}}` with the image's aspect.
- **Replace image.** On map 4 in Map settings, `click --role button --name 'Replace image' --file <png>` saves at once. `getMapContext({mapId:4,…}).map.imageAssetPath` changes at `20000000`, keeps `fddba7f2…png` at `19999999`, and list "Prior images" shows "Dawnmere 1, Year 1 · 00:00" with "Restore".
- **Remove, cancelled.** On `#/maps/7`, `click --role button --name 'Remove mistake' --dismiss`. The confirm "Remove Verification chart as a mistake? You can undo it in History until the next change." is answered `false`, and `listMaps({asOfTick:20000000})` still has id `7`.
- **Remove.** Repeat without `--dismiss`. The route moves to `#/maps/1`, id `7` leaves `listMaps`, and the head revision's `commandKey` is `map.removeMistake`.

## Gotchas

- Map settings sometimes collapses after Cancel or a placement save, and sometimes stays open across `shot --route`. Its DisclosureTriangle toggles, so check `[expanded]` in `snapshot` before clicking it.
- Canvas clicks can report `ok` at coordinates outside the 1440x900 viewport when the map is zoomed away from the target. Run "Fit map" first. Overlay labels often cover a pin's circle; pick an uncovered target.
- Several On this map names repeat other buttons, such as "Places" (a layer toggle) and "Glasswake Caldera" (a canvas overlay). Prefer the "Open … record" or "Open … map" buttons.
- "Create map" and "Draw placement" stay disabled until "Choose image" returns a file, so pass `--file`.

## Source and tests

- `src/renderer/features/maps/MapPage.tsx`, `MapBreadcrumb.tsx`, `MapWorkspaceSidebar.tsx`, `MapSidebar.tsx`, `MapCalibration.tsx`, `MapPlacementLayer.tsx`, `MapImageForm.tsx`, `mapImage.ts`.
- `src/shared/map.ts`, `map-ipc.ts`; `src/backend/services/map-service.ts` (carry corrects each pin through the record engine); `docs/agents/contracts/map-editor.md`; fixtures in `samples/<sample>/seed/maps.json`.
- `npm test -- src/renderer/features/maps/MapPage.test.tsx src/backend/services/map-service.test.ts src/backend/services/map-history-validation.test.ts`.
