# People list and detail

People is a framework record kind. The collection shows a card per person alive at the viewed date. A person's page has the Profile and Notes tabs, then Dates, the reverse sections such as Possessions, Scenes, Relationships, Position, and World history.

## Sub-features

- `people-list` lists people as cards with a status icon, an age, the summary, Role, Current situation, Location and Affiliation.
- `people-dead` hides the dead until "Show dead" is on.
- `people-views` switches between grid, list, table, and gallery.
- `people-open` opens a person from a card, its context menu, or the sidebar.
- `people-profile` shows the header with portrait, facts, Traits, Narrative and Location history.
- `people-map` shows Location "(from the map)", Map pin "View pin" and Influence for a pinned person.
- `people-links` follows possession and scene links.
- `people-history` shows World history and editorial history.

## How to get to it (user POV)

- "People" in the sidebar opens `#/people`.
- Each card's name link opens `#/people/<id>`.
- With the sidebar expanded, "Expand People" lists every person by name.
- The record toolbar has "End", "More", "Edit" and "History". "History" opens Settings at `tab=history&subjectType=character&subjectId=<id>`.

## Driving it with verify-electron

Preconditions:

- Mara Venn is character id `1` on a fresh sample. Confirm with `eval '(async () => (await window.appHost.invoke("records.character.list", {}, {at:20000000})).output.items.find((c) => c.title === "Mara Venn").id)()'`.

- **List.** `click --role button --name 'People'` and `snapshot main`. The list "People" holds a card per living person in name order. Mara's card shows `img "Alive"`, "33 years", her summary, "Tide-cartographer and expedition lead" and "Active on the Starhold survey".
- **Show dead.** `click --role button --name 'Show dead'`. The button is `[pressed]` and the dead join the list, each with `img "Dead"` and the word "Dead".
- **Views.** `click --role button --name 'List view'`, then "Table view", "Gallery view" and "Grid view". After each, `snapshot` shows that button `[pressed]` and Mara still listed.
- **Open from the collection.** `click --role link --name 'Mara Venn'`. The route is `#/people/1`, the top bar title is "Mara Venn", and the tablist "Character detail views" has tabs "Profile" `[selected]` and "Notes".
- **Profile.** `snapshot main` and `shot --name people-profile`. The tabpanel "Profile" shows the heading "Mara Venn", "Alive · Age 33", her summary, `img "Portrait"` and the description list "Facts": Home "Veyra-on-the-Tide", Location "Glasswake Caldera (from the map)", Origin "Veyra-on-the-Tide", Affiliation "Lantern Cartographers' Compact", Role, Current situation, Gender, Death estimate, Map pin "View pin" and Influence. Hovering the Death estimate date shows the tooltip "Based on default lifespan". Below sit "Traits", "Narrative" with "Trusts the compass over the chart", and "Location history".
- **View pin.** `click --role link --name 'View pin'`. The route is `#/maps/<root map id>?focus=point:<x>,<y>` and the map centers on her pin. Return with `click --role button --name 'Go back'`.
- **Open from the context menu.** `click --role button --name 'People'`, then `click --role link --name 'Mara Venn' --button right`. The menu offers "Open", "Open in workspace", "Copy name" and "Copy link". `click --role menuitem --name 'Open'`.
- **Open from the sidebar.** `click --role button --name 'Expand sidebar'`, `click --role button --name 'Expand People'`, then `click --role button --name 'Mara Venn'`. The route is `#/people/1`.
- **Possession link.** `click --role link --name 'Brineglass Compass'` opens `#/items/1`, the framework Items page in [Items](items.md). Return with "Go back".
- **Scene link.** `click --role link --name 'The Salt Bell'` opens `#/writing?view=write&scene=<uuid>`. Return with "Go back".
- **History.** `snapshot` shows "World history" with a dated entry per change. "Location history" lists only the entries that set Home or Location. `click --role button --name 'History'` opens `#/settings?tab=history&subjectType=character&subjectId=1`.

## Gotchas

- The sidebar entry, the collection and every label say "People"; a single record is a "Character".
- The Dates section, the reverse sections, Position, Relationships and World history show under both tabs.
- Location follows the pin and has no picker. A pin outside every boundary reads "Outside mapped boundaries"; a person without a pin has no Location row.
- Facts leave out empty values, the ordinary Type "Character", and a Current situation that repeats the life state, such as "Alive".
- Collection cards show no fact labels. The age reads "Unknown age" for a birth that is unknown or one-sided, such as Harl Dunmore's "before Year 34".

## Source and tests

- `src/features/character/contract.ts`, `ui/entrypoint.ts`, `ui/card.tsx`, `ui/profile.tsx`, `ui/details.tsx`, `ui/narrative.tsx`, `ui/life.ts`.
- `src/framework/ui/pages/RecordPage.tsx`, `CollectionPage.tsx`, `RecordPanels.tsx`, `WorldHistory.tsx`; `src/framework/ui/age.ts`.
- Fixtures in `samples/<sample>/seed/character.json`, `characterNote.json`, `item.json`, `writing.json`, `maps.json`.
- `npm test -- src/features/character src/app/record-kinds.test.ts`.
