# People list and detail

Characters lists every person alive or recorded at the viewed date. Opening one shows the profile with facts, portrait, traits, possessions, scene appearances, relationships, and world history, plus editorial history in Settings.

## Sub-features

- `people-list` lists people as cards at the viewed date.
- `people-views` switches between grid, list, table, and gallery.
- `people-open` opens a person from the collection, its context menu, or the sidebar.
- `people-profile` shows summary, facts, portrait, traits, possessions, and narrative notes.
- `people-links` follows possession and scene links.
- `people-history` shows world history, Location history, and editorial history.

## How to get to it (user POV)

- "Characters" in the sidebar opens `#/people`.
- A collection card, or its right-click menu item "Open", opens `#/people/<id>`.
- With the sidebar expanded, "Expand Characters" lists every person by name.
- The toolbar "History" button opens Settings at `tab=history&subjectType=character&subjectId=<id>`.

## Driving it with verify-electron

Preconditions:

- A fresh `start`. Prefix every command with `node scripts/verify-electron.mjs`.
- Mara Venn is character id `1` on a fresh sample. Confirm with `eval '(async () => (await window.app.listCharacters({asOfTick:20000000})).find(c => c.name === "Mara Venn").id)()'`.

- **List.** Choose Characters. Run `click --role button --name 'Characters'` and `snapshot main`. The `list "Characters"` holds ten cards, each a button named `Open <name>, <Alive|Dead>`, such as "Open Mara Venn, Alive" and "Open Harl Dunmore, Dead".
- **Views.** Switch layouts. Run `click --role button --name 'List view'`, then "Table view", "Gallery view", and "Grid view". After each, `snapshot` shows that button `[pressed]` and Mara still listed. Table view renders her as a `cell "Open Mara Venn, Alive Alive"`.
- **Open from the collection.** Choose Mara's card. Run `click --role button --name 'Open Mara Venn, Alive'`. The route is `#/people/1`, the heading is "Mara Venn", and the toolbar shows tabs "Profile" and "Notes" with "Add change" and "History".
- **Profile.** Run `snapshot main` and `shot --name people-profile`. Facts list Location "Glasswake Caldera", Origin "Veyra-on-the-Tide", Map pin "View pin", and Inside "Glasswake Caldera". The page shows `image "Mara Venn"`, a "Traits" heading, `list "Mara Venn inventory"` with "Brineglass Compass", and a Narrative note "Trusts the compass over the chart".
- **Open from the context menu.** Return with `click --role button --name 'Characters'`. Run `click --role button --name 'Open Mara Venn, Alive' --button right`. The menu offers "Open", "Open in workspace", "Copy name", and "Copy link". Run `click --role menuitem --name 'Open'`. Mara's profile opens.
- **Open from the sidebar.** Run `click --role button --name 'Expand sidebar'` and `click --role button --name 'Expand Characters'`. The `list "Characters records"` appears. Run `click --role button --name 'Mara Venn'`. The route is `#/people/1`.
- **Possession link.** Run `click --role link --name 'Brineglass Compass'`. The route is `#/items/1` with heading "Brineglass Compass". Return with `click --role button --name 'Go back'`.
- **Scene link.** Run `click --role link --name 'The Salt Bell'`. The route becomes `#/writing?view=write&scene=<uuid>` and gains `work=` once the scene loads. Return with "Go back".
- **World and Location history.** `snapshot` shows `region "World history"` with a "Greengale 7, Year 40" entry. Run `click --role DisclosureTriangle --name 'Location history'`. The disclosure becomes `[expanded]` and `region "Location history"` lists Location "Veyra-on-the-Tide" from Greengale 7, Year 40.
- **Editorial history.** Run `click --role button --name 'History' --nth 0`. The route is `#/settings?tab=history&subjectType=character&subjectId=1`. The page says "Showing saved changes for Mara Venn" and lists "#20 · Character Create".

## Gotchas

- The route says `people` but every label says "Characters".
- Collection cards are buttons, not links. Their names carry the life state.
- Four buttons are named "History" on a profile. Index 0 is the toolbar button; the others are relationship rows.
- Location shows the map-pin place ("Glasswake Caldera"). Location history shows the manual place ("Veyra-on-the-Tide"). Both are correct.
- The sidebar expanded state persists for the rest of the session. With it expanded, "Characters" stays unique but each person also has a sidebar button.
- The possessions heading reads "Possessions1" in the accessibility tree because the count is part of the name.

## Source and tests

- `src/renderer/features/characters/CharacterPage.tsx`, `CharacterProfileView.tsx`, `CharacterPossessionsView.tsx`.
- `src/renderer/components/design-system/ElementCollection.tsx`, `ElementViewSwitcher.tsx`; `src/renderer/components/Sidebar.tsx`.
- `src/renderer/features/shared/RecordDetail.tsx`, `RecordPageView.tsx`, `SceneAppearances.tsx`, `WorldRecordContext.tsx`.
- Fixtures in `samples/<sample>/seed/people.json`, `items.json`, `writing.json`.
- `npm test -- src/renderer/features/characters/CharacterPage.test.tsx src/renderer/components/design-system/ElementCollection.test.tsx`.
