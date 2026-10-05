# Character positions

A character has one dated position on a map family. The writer sets it from the profile's Position section or with the map's Character tool, drags the pin, or marks it unknown. The position drives the profile's Location and Inside facts, appears on parent and detail maps, and feeds a place's Characters here and Nearby characters.

## Sub-features

- `position-view` opens Maps at the pin from "View pin" or the "Recorded on" link.
- `position-record` saves a pin chosen on the profile preview by click or arrow keys.
- `position-map` sets or drags a pin on the map with the Character and Select tools.
- `position-related` projects the same position onto the Rim Road Survey detail map.
- `position-presence` shows Inside and Influence, Characters here, and Nearby characters.
- `position-unknown` records an unknown position through "Mark unknown" or "Remove character pin".
- `position-history` lists dated positions under "Position history".

## How to get to it (user POV)

- A character's Profile tab, `heading "Position"`. The facts list also has Map pin "View pin".
- Maps, toolbar "Character" tool, or a pin's right-click menu.
- In Maps with "Map tools" chosen at the sidebar foot, "On this map" lists People. Choosing one opens `region "Character"`.
- A place record such as `#/places/6` (Glasswake Caldera).

## Driving it with verify-electron

Preconditions:

- A fresh `start`. Prefix every command with `node scripts/verify-electron.mjs`. Mara is id `1`.
- Mara starts at `{mapId:4, x:1100, y:490}` from tick `19880000` on map 4, "Glasswake Expedition Logistics". Map 6, "Rim Road Survey", is a detail of map 4 at rect `(760, 250, 600, 400)`.
- Read her position with `eval '(async () => (await window.app.listCharacterPositions({asOfTick:20000000})).find(p => p.characterId === 1))()'`, called `<pos>` below.

- **View pin.** On Mara's profile run `click --role link --name 'View pin'`. The route is `#/maps/4?focus=point%3A1100%2C490` and Mara's pin is centered. Return with `click --role button --name 'Go back'`.
- **Draft on the profile.** Run `click --role button --name 'Choose position on Glasswake Expedition Logistics'` and `press ArrowRight`. A white draft marker moves; `<pos>` still reads `1100, 490`.
- **Record.** Run `click --role button --name 'Record position'`. `<pos>` now has `effectiveTick` `20000000` and about `x 783.5, y 511.8` (center plus one percent of 1536). At `asOfTick:19999999` it is still `1100, 490`. `getCharacter({id:1,asOfTick:20000000}).record.placement.kind` is `positioned`.
- **History.** Run `click --role DisclosureTriangle --name 'Position history'`. `region "Position history"` lists "Frostwane 2, Year 42" and "Bloomtide 1, Year 42". `eval 'window.app.getCharacterPositionHistory({characterId:1})'` returns the same two ticks.
- **Select on the map.** Run `click --role link --name 'Glasswake Expedition Logistics'` and `click --role button --name 'Map tools'`. Run `click --role button --name 'Mara Venn'`. `region "Character"` shows Inside "Glasswake Caldera", Influence "None", a "Travel check" group, and "Close selection".
- **Character tool.** Run `click --role button --name 'Close selection'`, `click --role button --name 'Character'`, `click --role combobox --name 'Character'`, `press End`, and `press Enter`. It reads "Mara Venn" and offers "Remove character pin". Run `click --role button --name 'Fit map'` and `click --role application --name 'Map canvas'`. `<pos>` becomes about `768, 560`.
- **Drag.** Run `click --role button --name 'Select'` and `drag '[data-character-id="1"] circle' --dx 120 --dy 60`. `<pos>` changes again.
- **Remove pin.** Run `click '[data-character-id="1"] circle' --button right` and `click --role menuitem --name 'Remove character pin'`. `<pos>.position` is `null`, placement kind is `unplaced`, and tick `19999999` keeps `1100, 490`. No confirmation appears.
- **Detail projection.** Record a profile position again near `768, 512`. `eval '(async () => (await window.app.getMapContext({mapId:6,asOfTick:20000000})).characters.find(c => c.characterId === 1).point)()'` returns about `x 20.9, y 670` with `physicalLocationIds` `[6]`. On map 4 run `click --role button --name 'Open Rim Road Survey map'`; Mara's pin shows at the detail's left edge.
- **Place presence.** Run `click --role button --name 'Open Glasswake Caldera record'`. `#/places/6` lists "Characters here" (Kesh Ash, Mara Venn, Tovan Ash) and `region "Nearby characters"` with "Proximity map" and `spinbutton "Radius in map units"` at 100.
- **Nearby radius.** Run `click --role spinbutton --name 'Radius in map units'`, `press Control+a`, and `type '400'`. Run `wait --until '[...document.querySelectorAll("section[aria-label=\"Nearby characters\"] a")].some(a => a.textContent === "Mara Venn")'`. `eval 'window.app.nearbyCharacters({mapId:4,x:1020,y:495,radius:400,asOfTick:20000000})'` returns the same names and distances.
- **Mark unknown.** On Mara's profile run `click --role button --name 'Mark unknown'`. "Position unknown." appears, and "Record position" and "Mark unknown" are disabled. Storage matches "Remove pin".

## Gotchas

- The profile preview changes only a draft. The map Character tool saves on click.
- `click --role application --name 'Map canvas'` hits the canvas center. Run "Fit map" first, or the click lands where the map was last focused.
- Sidebar "Map tools" mode persists. In "Browse" mode with Characters expanded, "Mara Venn" also names a sidebar record button.
- Nearby radius uses root-map units from the center of the place shape's bounds, and debounces. Wait for the list.

## Source and tests

- `src/renderer/features/character-positions/CharacterPositionEditor.tsx`, `NearbyCharacters.tsx`, `characterPositionQueries.ts`.
- `src/renderer/features/characters/CharacterProfileView.tsx`; `src/renderer/features/locations/LocationProfileView.tsx`.
- `src/renderer/features/maps/MapToolOptions.tsx`, `MapSelectionContext.tsx`, `MapCanvas.tsx`.
- `src/shared/character-position.ts`, `character-position-ipc.ts`; `src/backend/services/character-position-service.ts`.
- `npm test -- src/renderer/features/character-positions src/backend/services/character-position-service.test.ts`.
