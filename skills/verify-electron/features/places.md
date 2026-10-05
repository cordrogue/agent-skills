# Places

Places lists every location at the viewed date and filters it by role or tier. A place's detail shows its parent, nested places, characters here and within influence, connected maps, and nearby characters. The writer adds a place, adds a child place with its parent preset, and records dated changes.

## Sub-features

- `places-browse` lists places and filters by Role and Tier.
- `places-detail` shows Parent, Places, Characters here, Within influence, Maps, and Nearby characters.
- `places-navigate` follows nested, parent, and map links.
- `places-create` saves a new place, or asks "Discard this new place draft?" on Cancel.
- `places-child` creates a place with "Parent place" preset.
- `places-change` saves a dated change from the viewed date onward.
- `places-image` chooses or replaces a place image from the change date onward.
- `places-end` ends a place at the viewed date after a confirm.

## How to get to it (user POV)

- "Places" in the sidebar opens `#/places`. Each card is a button named `Select <name>`; a detail is `#/places/<id>`.
- Collection toolbar has "Filter places" and "Add place". Detail toolbar has "Add child place", "Add change", and "History".
- In Maps, "Open <place> record" in On this map opens the detail.

## Driving it with verify-electron

Preconditions:

- A fresh `start`. Prefix every command with `node scripts/verify-electron.mjs`.
- Fresh-sample ids are Veyra-on-the-Tide `3`, Tideglass Archive `4`, Glasswake Caldera `6`, and Mariner's Vault `7`. Resolve with `eval '(async () => (await window.app.listLocations({asOfTick:20000000})).map(p => [p.id, p.name]))()'`.

- **Browse.** Run `click --role button --name 'Places'` and `snapshot main`. `list "Places"` holds eleven buttons such as "Select Lumae" and "Select Veyra-on-the-Tide".
- **Filter.** Run `click --role button --name 'Filter places'`. `dialog "Filter places"` opens with `combobox "Role"` focused and `combobox "Tier"`. Run `press ArrowDown` three times; Role reads "Landmark" and the list shrinks to Tideglass Archive, Starhold Lighthouse, The Rim Road, and Drowned Lamp Shrine. Run `press Home` and `press Escape` to restore all eleven.
- **Detail.** Run `click --role button --name 'Select Veyra-on-the-Tide'`. The route is `#/places/3`. `snapshot main` shows "Settlement", Parent link "The Sample World", headings "Places2", "Characters here4", "Within influence2", "Maps1", and `region "Nearby characters"`.
- **Nested link.** Nested place links are named by name plus full summary. Read the summary with `listLocations`, then run `click --role link --name 'Tideglass Archive A vaulted archive where cinderglass ledgers preserve route testimony and disputed memories. Sera keeps disputed echoes marked separately from attested testimony, even when both concern the same route.'`. The route is `#/places/4`. Run `click --role link --name 'Veyra-on-the-Tide'` to return through Parent.
- **Map link.** Run `click --role link --name 'Veyra Harbor and Tidewards'`. The route is `#/maps/3?focus=place%3A3`. `eval 'window.app.getLocationMapContext({locationId:3,asOfTick:20000000})'` lists map 3 and Veyra's boundary overlay.
- **Create.** From Places, run `click --role button --name 'Add place'`. Heading "New place" shows "Name", "Type" (Location), "Summary", "Tier" (Site), "Role" (Place), "Parent place" (No parent), "Choose image", and group "Create this place starting at". Type `Verification cove` into Name and `A sheltered landing.` into Summary, then `click --role button --name 'Save'`. `wait --role heading --name 'Verification cove'` lands on `#/places/12`.
- **Confirm the place.** `eval '(async () => (await window.app.listLocations({asOfTick:20000000})).filter(p => p.name === "Verification cove").map(p => [p.summary, p.tier, p.role, p.existsFromTick]))()'` returns `[["A sheltered landing.", "site", "place", 20000000]]`.
- **Discard.** Open Add place, type `Discarded cove` into Name, and `click --role button --name 'Cancel'`. `dialog "Discard this new place draft?"` offers "Keep editing" and "Discard". Choose Discard; `listLocations` has no "Discarded cove".
- **Child place.** On Veyra run `click --role button --name 'Add child place'`. "Parent place" reads "Veyra-on-the-Tide". Name it `Verification quay` and Save. The new detail's Parent links Veyra, and `listLocations` gives it `parentLocationId` `3`.
- **Dated change.** On Veyra run `click --role button --name 'Add change'`. The editor shows "Save", "Cancel", "End", and group "Change from this date onward". Replace Summary with `Verification harbor summary.` and Save, then `click --role button --name 'Cancel'`. The detail shows the new summary. `listLocations({asOfTick:19999999})` still returns the original summary for id `3`.
- **Image.** In the "Add place" form, `click --role button --name 'Choose image' --file "$HOME/.cache/agent-swarm/<dir>/<image>.png"`. `dialogs` lists an `open` dialog answered with that path and the button becomes "Replace image". Save; `listLocations` gives the new place an `imageAssetPath` named by the file's SHA-256. On Veyra's Add change, `click --role button --name 'Replace image' --file <png>` and Save; `imageAssetPath` for id `3` changes at `20000000` and keeps `8027fcf0…png` at `19999999`. Without `--file` the picker cancels and nothing changes.
- **End, cancelled.** On Veyra's Add change, `click --role button --name 'End' --dismiss`. The confirm reads "End this place at the viewed story date, Bloomtide 1, Year 42 · 21:20? The change date above applies only to Save." and is answered `false`; `listLocations` still has id `3` at `20000000`.
- **End.** Repeat without `--dismiss`. The detail reads "This place no longer exists at Bloomtide 1, Year 42 · 21:20." and World history adds "Existence Ended". Id `3` is gone from `listLocations({asOfTick:20000000})`, present at `19999999`, and the head revision's `commandKey` is `location.endAtTick`.

## Gotchas

- On a Maps route with the sidebar in "Map tools" mode, `button "Places"` is the Places layer toggle, not navigation. Choose "Browse" first, or the click hides place overlays.
- Section headings carry their counts in the accessible name, such as "Characters here4".
- "End" ends the place at the viewed date, not at the editor's change date. Run it last; Veyra's characters then show lifetime warnings.
- Nearby characters is covered in `character-positions.md`.

## Source and tests

- `src/renderer/features/locations/LocationPage.tsx`, `LocationEditor.tsx`, `LocationProfileView.tsx`, `LocationInsightsView.tsx`.
- `src/renderer/features/shared/RecordPageView.tsx`, `RecordFields.tsx`, `recordPage.ts`; `src/shared/location-ipc.ts`.
- Fixtures in `samples/<sample>/seed/places.json`.
- `npm test -- src/renderer/features/locations/LocationPage.test.tsx src/backend/services/location-service.test.ts src/backend/services/location-service.temporal.test.ts`.
