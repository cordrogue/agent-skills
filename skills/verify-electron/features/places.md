# Places

Places is a framework record kind: a grid of place cards that a writer filters by role and tier. A place's page shows its fields, the records that point at it, the maps that show it and the characters near it, and offers adding a place inside it and recording dated changes. The form sets tier and role from the type and describes each tier and role option.

## Sub-features

- `places-browse` lists the places present at the viewed date as cards with image, tier, role (left out where it repeats the tier), summary and parent.
- `places-filter` filters the collection by Role and Tier through the "Filter places" menu. Both filters live in page state, not the URL, so a reload or Back clears them.
- `places-detail` shows Fields and Dates, then each reverse section that lists anything, in the framework's order Residents, Characters here, Within influence, Items here and Places, then Continuity when it has a finding, then the shell panels Scenes, Relationships, Maps and Nearby characters, then World history.
- `places-maps` lists each map that shows the place at the viewed date, linked to the map focused on it.
- `places-nearby` measures characters' pins from a chosen shape that names the place.
- `places-create` saves a new place, with tier and role following the type until the author sets them, or asks "Discard this new place draft?" on Cancel.
- `places-inside` opens the new place form from a place with Parent set to that place.
- `places-change` saves a dated change from the viewed date onward, or corrects a value.
- `places-remove` removes a place nothing names, and refuses one that a record, a relationship or a map shape names.

## How to get to it (user POV)

- The sidebar button "Places" opens `#/places`. People sorts before Places in the sidebar, palette and pickers, by folder order.
- Each card's name link, such as "Veyra-on-the-Tide", opens `#/places/<numeric id>`.
- The collection toolbar has "Filter places", "Show ended" and "New place". The record toolbar has "End", "Add place inside", "More" (Remove), "Edit" and "History". The editor toolbar has "Change from this time", "Correct this value" and "Cancel".
- In Maps, "Open <place> record" in On this map opens the record page, and each Maps panel link opens the map with `focus=place:<id>`.

## Driving it with verify-electron

Preconditions:

- Fixtures are eleven places with ids 1 to 11, each with an image and on at least one map: Lumae 1 (world, place), The Sample World 2 (region, place, inside 1), Veyra-on-the-Tide 3 (settlement, settlement, inside 2), Tideglass Archive 4 (site, landmark, inside 3), Starhold Lighthouse 5 (site, landmark, inside 2), Glasswake Caldera 6 (region, wilderness, inside 2), Mariner's Vault 7 (site, bank, inside 3), Saltmarrow 8 (town; settlement, settlement, inside 2), Ashfold 9 (hamlet; settlement, settlement, inside 6), The Rim Road 10 (landmark; site, landmark, inside 6) and Drowned Lamp Shrine 11 (dungeon; site, landmark, inside 2). Places without a type note are type Location.
- The Role, Tier and Type selects are native selects: `click` one, `type` the option's label, and `press Enter`.
- Read a place the way the page does with `eval '(async () => JSON.stringify((await window.appHost.invoke("records.location.get", {id:3}, {at:20000000})).output))()'`, list them with `records.location.list`, and read stored points with `db 'select * from location_state_points where record_id = 3'`.

- **Browse.** `click --role button --name 'Places'`. Main has the list "Places" with eleven cards in name order. The Veyra-on-the-Tide card shows its image, "Settlement" once, its summary and "The Sample World".
- **Filter.** `click --role button --name 'Filter places'`. The dialog "Filter places" has the selects "Role" and "Tier", each starting at "All". Role "Settlement" leaves Ashfold, Saltmarrow and Veyra-on-the-Tide, the URL stays `/places`, and the button reads "Filter places, 1 active". Adding Tier "Region" shows "No matching places" and "Filter places, 2 active". Both filters survive a viewed-date move. "Clear filters" restores all eleven. Pick a role again and reload: the filter is gone and the button reads "Filter places".
- **Detail.** `shot --route '#/places/3?worldTick=20000000'`. The description list "Fields" shows Name, Summary, Type "Location", Tier "Settlement", Role "Settlement", Image and Parent "The Sample World". The headings below are Residents (Mara Venn, Oda Vell, Ysolde Dunmore), Characters here and Within influence (Oda Vell, Sera Nhal), Places (Mariner's Vault, Tideglass Archive), Continuity, Scenes, Relationships, Maps, Nearby characters and World history. Starhold Lighthouse (`#/places/5`) shows Items here after Residents.
- **Maps panel.** On Veyra, "Maps" lists "Veyra Harbor and Tidewards". `click --role link --name 'Veyra Harbor and Tidewards'` opens `#/maps/3?focus=place%3A3&worldTick=20000000`. Every sample place has a map; the place Create saves reads "No connected maps at this story date".
- **Nearby characters.** On Veyra, "Nearby characters" has the select "Proximity map" ("Veyra Harbor and Tidewards · Veyra-on-the-Tide"), the spinbutton "Radius in map units" at 100, and "No recorded positions within this radius." At radius 1000 it lists Oda Vell at 143.2 units and Sera Nhal at 300.2 units. The place Create saves reads "Place this location on a map to find nearby characters."
- **Create.** From Places, `click --role button --name 'New place'`. The form has the textboxes "Name" and "Summary", the combobox "Type" (Location), the groups "Tier" and "Role" as radio lists with a description beside each option, the group "Image", the combobox "Parent", and the group "Exists from". Type "Town" moves Tier and Role to Settlement. Choose Tier "District" with `click 'main form fieldset:first-of-type input[value=district]'`, because Role has a District too; then Type "Kingdom" keeps Tier at District and moves Role to Place. Name it `Verification cove` and `click --role button --name 'Save'`; `#/places/12` opens with Type Kingdom, Tier District and Role Place.
- **Discard.** Open New place, type `Discarded cove` into Name, and `click --role button --name 'Cancel'`. The dialog "Discard this new place draft?" offers "Keep editing" and "Discard".
- **Add place inside.** On The Sample World (`#/places/2`), `click --role button --name 'Add place inside'`. The route becomes `#/places?new=%7B%22parent%22%3A2%7D&worldTick=20000000` and the New place form opens with Parent "The Sample World". Name it and Save; the new page's Parent links The Sample World, and The Sample World lists it under Places.
- **Dated change.** On Veyra, `click --role button --name 'Edit'`, replace Summary, and `click --role button --name 'Change from this time'`. World history adds a "Bloomtide 1, Year 42 · 21:20" entry with the new summary, and `records.location.get` at tick 19999999 still returns the earlier summary.
- **Remove, refused.** `click --role button --name 'More'`, choose the menu item "Remove", and confirm Remove in the dialog "Remove this place?". Records name every sample place. The refusal lists three holders, map shapes before records, and counts the rest: Glasswake Caldera (`#/places/6`) reads "Glasswake Caldera can't be removed. Glasswake Expedition Logistics (Map) lists it as map boundary, Mara Venn (Character) lists it as Location, Kesh Ash (Character) lists it as Location, and 4 more." To see a map shape's clause, give the place Create saved a boundary with `mcp create_map_overlay '{"mapId":4,"label":"","content":{"kind":"boundary","locationId":12,"points":[{"x":10,"y":10},{"x":60,"y":10},{"x":60,"y":60},{"x":10,"y":60}]},"effectiveAt":{"kind":"tick","worldTick":20000000},"operationId":"<a new uuid>"}'`; Remove then reads "Verification cove can't be removed. Glasswake Expedition Logistics (Map) lists it as map boundary." A place nothing names, such as the one Add place inside saved, is removed and the page returns to Places.
- **Cycle.** Edit The Sample World. Click the combobox "Parent", `press Control+a`, `type 'Veyra'`, click the option "Veyra-on-the-Tide", and run Change from this time. The form refuses it under Parent: "The Sample World would be part of itself from Bloomtide 1, Year 42 · 21:20: its parent is Veyra-on-the-Tide, which is part of The Sample World. Choose a place outside it." Cancel asks "Discard unsaved changes to this place?".

## Gotchas

- Places has no legacy commands. Read and write places through `window.appHost.invoke("records.location.<operation>", ...)`, `mcp get_entity '{"entityType":"location","id":3,"at":20000000}'`, or `db`.
- Reverse sections list names only, with no summary line or count. Places shows only the places directly inside.
- Maps and Nearby characters are shell panels: they sit below Relationships and above World history, and hide while editing.
- On a Maps route with the sidebar in "Map tools" mode, `button "Places"` is the Places layer toggle, not navigation. Choose "Browse" first.
- An ended parent warns under Continuity rather than refusing the save.
- Nearby characters' radius behavior is covered in `character-positions.md`.

## Source and tests

- `src/features/location/contract.ts` (fields, types, statuses, "Exists from"), `ui/entrypoint.ts` (grid, Role and Tier filters), `ui/card.tsx`, `ui/editor.tsx` (type defaults), `ui/fields/tier.tsx`, `ui/fields/role.tsx`, `ui/actions.tsx` (Add place inside).
- `src/renderer/features/places/placePanels.tsx` (Maps and Nearby characters), registered in `src/renderer/components/app-shell/frameworkShell.ts`.
- `src/framework/host/records/legacy-holders.ts` (map shapes that block removal).
- Fixtures in `samples/<sample>/seed/location.json`.
- `npm test -- src/features/location src/app/record-kinds.test.ts src/renderer/features/places src/renderer/lib/frameworkChoiceFilters.test.tsx`.
