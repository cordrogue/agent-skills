# Items

Items is a framework record kind: a grid of item cards, each with a name, summary, type, quantity, condition, image, owner, and location. An item's page tracks its ownership and location history, links back from its owner's Possessions and its place's Items here, and warns when its owner is dead. Items can also come from manuscript prose.

## Sub-features

- `items-list` opens the collection from the sidebar as a grid of cards with image, owner, location, and summary.
- `items-detail` opens a record and shows its fields, the section "Ownership and location history", Dates, Continuity, Scenes, Relationships, and World history.
- `items-reverse` lists each item once under "Possessions" on its owner's page and under "Items here" on its place's page.
- `items-change` saves a dated owner or location change, which adds an entry to the ownership and location history.
- `items-continuity` warns while a dead character owns an item.
- `items-extraction` accepts an item proposal from Scene context, and one undo of that revision removes the item.

## How to get to it (user POV)

- Sidebar "Items" opens `#/items`. Each card has a link named by the item, such as "Brineglass Compass", that opens `#/items/<numeric id>`.
- An owner's Possessions link and a place's Items here link open the same record page.
- The record toolbar has "End", "More", "Edit", and "History". The editor toolbar has "Change from this time", "Correct this value", and "Cancel".

## Driving it with verify-electron

Preconditions:

- Fixtures are eight items with ids 1 to 8. "Brineglass Compass" (id 1) has quantity 1, owner Mara Venn (character 1), no condition, no location, and exists from Suncrest 20, Year 40 · 21:20. "Starhold Lens" (id 6) and "Emberseed Provision Crate" (id 3, quantity 24) are at Starhold Lighthouse (place 5). Harl Dunmore (character 9) dies between Starfrost 16, Year 36 and Emberwane 11, Year 38.
- Kind id `item`, read as in the README baseline, such as `eval '(async () => JSON.stringify((await window.appHost.invoke("records.item.get", {id:1}, {at:20000000})).output))()'`.

- **List.** `click --role button --name 'Items'` routes to `#/items?worldTick=20000000`. Main has the list "Items" with eight cards in name order, from "Ashkey Sextant" to "Starhold Lens". Each card links the item and its owner or location. The Brineglass Compass card shows its image, "Mara Venn", and its summary.
- **Detail.** `shot --route '#/items/1?worldTick=20000000'`. Description list "Fields" shows Name, Summary, Type "Item", Quantity "1", an empty Condition, Image, Owner "Mara Venn", and an empty Location. Section "Ownership and location history" has one entry, "Suncrest 20, Year 40 · 21:20", with Owner "Mara Venn". Dates show Exists from "Suncrest 20, Year 40 · 21:20" and Status "Active". Continuity holds a note that Mara Venn is estimated to end at Greengale 6, Year 89 · 18:40.
- **Possessions.** On `shot --route '#/people/1?worldTick=20000000'`, `snapshot` shows heading "Possessions" with one link, "Brineglass Compass".
- **Items here.** On `shot --route '#/places/5?worldTick=20000000'`, `snapshot` shows heading "Items here" with the links "Emberseed Provision Crate" and "Starhold Lens", once each.
- **Move it.** On the compass, `click --role button --name 'Edit'`. The form has textboxes "Name", "Summary", and "Condition", combobox "Type" (Item, Armor, Potion, Weapon, Artifact, Vehicle), spinbutton "Quantity", group "Image", groups "Owner" and "Location" with comboboxes, and group "Exists from". Run `click --role combobox --name 'Location'`, `type 'Starhold'`, `wait --role option --name 'Starhold Lighthouse'`, `click --role option --name 'Starhold Lighthouse'`, `click --role button --name 'Change from this time'`, and `wait --role button --name 'Edit'`. Fields show Location "Starhold Lighthouse", and the history adds the entry "Bloomtide 1, Year 42 · 21:20" with that Location.
- **A dead owner.** On a fresh `start`, open the compass and run `click --role button --name 'Edit'`, `click --role combobox --name 'Owner'`, `press Control+a`, `type 'Harl'`, `wait --role option --name 'Harl Dunmore'`, `click --role option --name 'Harl Dunmore'`, `click --role button --name 'Change from this time'`, and `wait --role button --name 'Edit'`. Fields show Owner "Harl Dunmore", the history adds a Bloomtide 1, Year 42 entry with that owner, and Continuity warns "Brineglass Compass lists Harl Dunmore as Owner from Bloomtide 1, Year 42 · 21:20, but Harl Dunmore dies between Starfrost 16, Year 36 · 08:00 and Emberwane 11, Year 38 · 21:20."
- **Extraction.** Run `click --role button --name 'Writing'`, `click --role button --name 'Open The Salt Bell'`, `click --role textbox --name 'Scene prose'`, `press Control+End`, `type ' She carried the sword called Dawnshear.'`, `click --role button --name 'Save version'`, and `click --role button --name 'Find new names'`. Region "Possible new records" shows "Dawnshear", "item", "Accept", and "Reject". Run `click --role button --name 'Accept'` and `wait --until '(async () => (await window.appHost.invoke("records.item.list", {show:"all"}, {at:20000000})).output.items.some((r) => r.title === "Dawnshear"))()'`. `shot --route '#/items/9?worldTick=20000000'` shows Dawnshear with Type "Item", no owner or location, Exists from "Starfrost 3, Year 41 · 00:00" (the scene's start), and Scenes "The Salt Bell".
- **Undo the extraction.** Read the head revision's id `<n>` with `eval '(async () => (await window.appHost.invoke("framework:history.revisions", {limit:1}, {})).output.items[0].id)()'`. On `shot --route '#/settings?tab=history'`, the head revision is "#<n> · Created item Dawnshear" with two subjects. `click --role button --name 'Undo'` opens Dialog "Undo revision #<n>? …"; `click --role button --name 'Undo revision'` confirms it. `records.item.list` no longer has Dawnshear, and `#/items/9` shows "Item 9 does not exist." with Retry.

## Gotchas

- The ownership and location history lists only entries that set Owner or Location, and is hidden on an item with neither.
- The Dates rows follow the ownership and location history directly, with no heading between them.
- Every owned item whose owner has an estimated end carries a continuity note naming that estimate. Only a certain overlap with a dead owner is drawn as a warning.
- The owner and location pickers search by name and list ended records too. Type part of a name, then wait for the option.
- Revision numbers in Settings depend on what the session wrote before, so read the head's id instead of assuming one.

## Source and tests

- `src/features/item/contract.ts` (fields, statuses, "Exists from"), `ui/entrypoint.ts` (grid collection), `ui/card.tsx`, `ui/profile.tsx`, `host/search.ts` ("Quantity: N").
- `src/backend/services/manuscript-extraction-service.ts` (an accepted item proposal writes the item in the acceptance revision).
- `src/framework/ui/pages/RecordPage.tsx`, `RecordPanels.tsx`, `WorldHistory.tsx`.
- `npm test -- src/features/item src/app/record-kinds.test.ts src/backend/services/manuscript-extraction-service.test.ts`.
