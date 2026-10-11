# Ecology

Ecology is a framework record kind: a gallery of ecosystem, fauna and flora cards, each with a name, summary, subtype, and image.

## Sub-features

- `ecology-list` opens the collection from the sidebar as a gallery of cards.
- `ecology-detail` opens an entry from its card, the expanded sidebar, or the command palette, and shows Fields, Dates, Scenes, Relationships, and World history.
- `ecology-create` saves a new entry first appearing at the viewed time, with subtype Ecology, Fauna, or Flora.
- `ecology-change`, `ecology-correct`, `ecology-end`, `ecology-discard` and `ecology-prior-images` follow the [Bestiary](bestiary.md) recipe with the substitutions under Gotchas.
- `ecology-remove` removes an entry added by mistake after a question.

## How to get to it (user POV)

- Sidebar "Ecology" opens `#/ecology`. Each card has a link named by the entry, such as "Lantern Moths", that opens `#/ecology/<numeric id>`.
- After "Expand sidebar", "Expand Ecology" lists the entries under list "Ecology records" as buttons named by the entry alone.
- The command palette groups matching entries under "Ecology".
- The collection toolbar has "Show ended" (a toggle) and "New ecology entry". The record toolbar has "End", "More" (a menu with "Remove"), "Edit", and "History".

## Driving it with verify-electron

Preconditions:

- Fixtures are "Brineglass Reefs" (id 1, subtype Ecology), "Emberseed" (id 2, Flora) and "Lantern Moths" (id 3, Fauna), each first appearing Dawnmere 1, Year 1 (tick 0), each with one image, no relationships, and no Scene mentions. The first entry you save gets id 4.
- Kind id `ecology`, read as in the README baseline.

- **List.** `click --role button --name 'Ecology'` routes to `#/ecology?worldTick=20000000`. Main has the list "Ecology" with links "Brineglass Reefs", "Emberseed" and "Lantern Moths", in name order, each card showing an image, its subtype ("Ecology", "Flora", "Fauna"), and the summary.
- **Detail.** Run `click --role link --name 'Lantern Moths'` and `wait --role heading --name 'Lantern Moths'`. The route is `#/ecology/3?worldTick=20000000`. `snapshot` shows the description list "Fields" (Name, Summary, Subtype "Fauna", Image), "Dates" (First appears "Dawnmere 1, Year 1", Status "Active" "from Dawnmere 1, Year 1"), heading "Scenes" with "Not in any saved Scene.", heading "Relationships" with "No relationships recorded at this date.", and heading "World history" with one entry dated Dawnmere 1, Year 1.
- **Sidebar.** Run `click --role button --name 'Expand sidebar'`, `click --role button --name 'Expand Ecology'`, then `click --role button --name 'Emberseed'`. The route is `#/ecology/2?worldTick=20000000`.
- **Create.** On the collection, `click --role button --name 'New ecology entry'`. The heading is "New ecology entry", and the form has textboxes "Name" and "Summary", combobox "Subtype" set to "Ecology" with the options Ecology, Fauna and Flora, group "Image", and group "First appears" preset to the viewed time. Run `click --role textbox --name 'Name'`, `type 'Tide Kelp'`, `click --role combobox --name 'Subtype'`, `press End`, `press Enter` (value "Flora"), `click --role button --name 'Save'`, and `wait --role heading --name 'Tide Kelp'`. The route is `#/ecology/4?worldTick=20000000`.
- **Confirm create.** `eval '(async () => { const o = (await window.appHost.invoke("records.ecology.get", {id:4}, {at:20000000})).output; return JSON.stringify({start:o.start, subtype:o.subtype}); })()'` returns `start {"kind":"exact","tick":20000000}` and `subtype "flora"`.
- **Command palette.** Run `click --role button --name 'Open command palette'`, `wait --role dialog --name 'App command palette'`, `type 'Lantern Moths'`, and `wait --role option --name 'Lantern Moths'`. `snapshot --role dialog` shows group "Ecology" holding the option. Clicking it opens `#/ecology/3?worldTick=20000000`.
- **Remove.** On Tide Kelp, run `click --role button --name 'More'` and `click --role menuitem --name 'Remove'`. The in-app dialog "Remove this ecology entry?" offers "Cancel" (focused) and "Remove". `click --role button --name 'Remove'` returns to `#/ecology?worldTick=20000000`, and `records.ecology.get` for id 4 answers `appError` code `not_found`, "Ecology entry 4 does not exist."

## Gotchas

- For the Bestiary recipe's change, correct, End, Show ended, Cancel and Prior images steps, use "Lantern Moths" (id 3) or a saved entry. The Cancel dialogs read "Discard unsaved changes to this ecology entry?" and "Discard this new ecology entry draft?".

## Source and tests

- `src/features/ecology/contract.ts` (fields, subtypes, statuses, "First appears"), `ui/entrypoint.ts` (gallery collection), `ui/card.tsx`.
- The framework pages listed in [Bestiary](bestiary.md).
- `npm test -- src/app/record-kinds.test.ts src/features/ecology/host/contract.test.ts`.
