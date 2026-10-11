# Character positions

A character has one dated pin on a map family, stored in the character's `pin` field. The writer sets it from the character page's Position panel or the map's Character tool, drags it, or marks it unknown. After every command the app stores the character's Location (the innermost boundary holding the pin) and Influence (every influence area holding it). The pin appears on parent and detail maps, and a place page lists the character under the framework reverse sections "Characters here" and "Within influence", and under Nearby characters.

## Sub-features

- `position-view` opens Maps at the pin from "View pin" or the "Recorded on" link.
- `position-record` saves a pin chosen on the Position panel's preview by click or arrow keys.
- `position-map` sets or drags a pin on the map with the Character and Select tools.
- `position-related` projects the same pin onto the Rim Road Survey detail map.
- `position-presence` shows Influence on the map selection, a place's Characters here and Within influence, and Nearby characters.
- `position-unknown` records an unknown pin through "Mark unknown" or "Remove character pin".
- `position-history` lists dated pins under "Position history".

## How to get to it (user POV)

- A character's page, `#/people/<id>`, `heading "Position"` below Relationships and above World history, on the record page only, not while editing.
- Maps, toolbar "Character" tool, or a pin's right-click menu.
- In Maps with "Map tools" chosen at the sidebar foot, "On this map" lists People. Choosing one opens `region "Character"`.
- A place record such as `#/places/6` (Glasswake Caldera).

## Driving it with verify-electron

Preconditions:

- Mara is id `1`. She starts at `{mapId:4, x:1100, y:490}` from tick `19880000` on map 4, "Glasswake Expedition Logistics". Map 6, "Rim Road Survey", is a detail of map 4 at rect `(760, 250, 600, 400)`.
- `<pos>` below is her pin, `eval '(async () => (await window.appHost.invoke("listCharacterPositions", {asOfTick:20000000}, {})).output.find(p => p.characterId === 1))()'`. `<placed>` is her stored places, `eval '(async () => (await window.appHost.invoke("getMapContext", {mapId:4,asOfTick:20000000}, {})).output.characters.find(c => c.characterId === 1))()'`. `<placed>.locationId` is `6` (Glasswake Caldera).

- **View pin.** On `#/people/1`, `click --role link --name 'View pin'` routes to `#/maps/4?focus=point%3A1100%2C490` with Mara's pin centered. Return with `click --role button --name 'Go back'`.
- **Draft in the panel.** In `heading "Position"`, run `click --role button --name 'Choose position on Glasswake Expedition Logistics'` and `press ArrowRight`. A white draft marker moves; `<pos>` still reads `1100, 490`.
- **Record.** `click --role button --name 'Record position'`. `<pos>` now has `effectiveTick` `20000000` and about `x 783.5, y 511.8` (center plus one percent of 1536). At `asOfTick:19999999` it is still `1100, 490`. `<placed>.locationId` is the boundary that holds the new point, or `null` outside every boundary.
- **History.** `heading "Position history"` in the panel lists two read-only entries, "Bloomtide 1, Year 42" and "Frostwane 2, Year 42", each reading "Map pin Changed". `eval '(async () => (await window.appHost.invoke("getCharacterPositionHistory", {characterId:1}, {})).output)()'` returns the same two ticks.
- **Select on the map.** Run `click --role link --name 'Glasswake Expedition Logistics'`, `click --role button --name 'Map tools'`, and `click --role button --name 'Mara Venn'`. `region "Character"` shows Influence, a "Travel check" group, and "Close selection", and no Inside row.
- **Character tool.** Run `click --role button --name 'Close selection'`, `click --role button --name 'Character'`, `click --role combobox --name 'Character'`, `type 'Mara Venn'`, and `press Enter`. It reads "Mara Venn", shows Influence and `heading "Position history"`, and offers "Remove character pin". Run `click --role button --name 'Fit map'` and `click --role application --name 'Map canvas'`. `<pos>` becomes about `768, 560`.
- **Drag.** Run `click --role button --name 'Select'` and `drag '[data-character-id="1"] circle' --dx 120 --dy 60`. `<pos>` changes again, and `<placed>` follows in the same History entry.
- **Remove pin.** Run `click '[data-character-id="1"] circle' --button right` and `click --role menuitem --name 'Remove character pin'`. No confirmation appears. `<pos>.position` is `null`, `<placed>` is `undefined`, and tick `19999999` keeps `1100, 490`. Home on Mara's page does not change.
- **Detail projection.** Record a panel position again near `768, 512`. `eval '(async () => (await window.appHost.invoke("getMapContext", {mapId:6,asOfTick:20000000}, {})).output.characters.find(c => c.characterId === 1))()'` returns a point of about `x 20.9, y 670` and `locationId` `6`. On map 4, `click --role button --name 'Open Rim Road Survey map'`; Mara's pin shows at the detail's left edge.
- **Place presence.** `click --role button --name 'Open Glasswake Caldera record'`. `#/places/6` lists, under "Characters here", every character whose `locationId` is `6` in `getMapContext({mapId:4,asOfTick:20000000})`, and `region "Nearby characters"` with "Proximity map" and `spinbutton "Radius in map units"` at 100. The legacy profile no longer has its own Characters here or Within influence lists.
- **Nearby radius.** Run `click --role spinbutton --name 'Radius in map units'`, `press Control+a`, `type '400'`, and `wait --until '[...document.querySelectorAll("section[aria-label=\"Nearby characters\"] a")].some(a => a.textContent === "Mara Venn")'`. `eval '(async () => (await window.appHost.invoke("nearbyCharacters", {mapId:4,x:1020,y:495,radius:400,asOfTick:20000000}, {})).output)()'` returns the same names and distances.
- **Mark unknown.** On `#/people/1`, `click --role button --name 'Mark unknown'` in the Position panel. "Position unknown." appears, and "Record position" and "Mark unknown" are disabled. Storage matches "Remove pin".

## Gotchas

- The panel preview changes only a draft. The map Character tool saves on click.
- `click --role application --name 'Map canvas'` hits the canvas center. Run "Fit map" first, or the click lands where the map was last focused.
- Sidebar "Map tools" mode persists. In "Browse" mode with People expanded, "Mara Venn" also names a sidebar record button.
- The Character select lists people by name, and Ysolde Dunmore sorts last, so choose by typing the name, not by position.
- Nearby radius uses root-map units from the center of the place shape's bounds, and debounces. Wait for the list.
- Recording a pin at the spot the character already holds adds no change and no History entry.
- An agent sets a pin only with `set_character_position` and `clear_character_position`. Both return `output: null`; read the character after the commit. `update_entity` and `create_entity` refuse `pin`.

## Source and tests

- `src/renderer/features/character-positions/CharacterPositionEditor.tsx`, `characterPositionPanel.tsx`, `NearbyCharacters.tsx`, `characterPositionQueries.ts`; `src/renderer/components/app-shell/frameworkShell.ts`.
- `src/renderer/features/locations/LocationProfileView.tsx`.
- `src/renderer/features/maps/MapToolOptions.tsx`, `MapSelectionContext.tsx`, `MapCanvas.tsx`, `mapCharacters.ts`.
- `src/shared/character-position.ts`, `character-position-ipc.ts`; `src/backend/services/character-position-service.ts`.
- `npm test -- src/renderer/features/character-positions src/backend/services/character-position-service.test.ts`.
