# Bestiary

The Bestiary is a framework record kind: a gallery of creature cards, each with a name, summary, subtype, and image. It is the reference recipe for dated changes, corrections, End, Show ended, discard, and prior images, which the other gallery kinds follow.

## Sub-features

- `bestiary-list` opens the collection from the sidebar as a gallery of cards.
- `bestiary-detail` opens a record from its card, the expanded sidebar, or the command palette, and shows Fields, Dates, Scenes, Relationships, and World history.
- `bestiary-create` saves a new creature first appearing at the viewed time, with subtype Creature.
- `bestiary-change` saves a dated change, so each date shows its own value.
- `bestiary-correct` rewrites the value at an earlier date without adding a change.
- `bestiary-end` ends a creature at a date chosen in the End dialog, and Show ended brings it back into the collection.
- `bestiary-discard` asks before Cancel throws away a changed or new draft.
- `bestiary-prior-images` lists earlier images in the editor with Restore.
- `bestiary-remove` removes a creature added by mistake after a question.

## How to get to it (user POV)

- Sidebar "Bestiary" opens `#/bestiary`. Each card has a link named by the creature, such as "Glassmaw", that opens `#/bestiary/<numeric id>`.
- After "Expand sidebar", "Expand Bestiary" lists the creatures under list "Bestiary records" as buttons named by the creature alone.
- The command palette groups matching creatures under "Bestiary".
- The collection toolbar has "Show ended" (a toggle) and "New creature". The record toolbar has "End", "More" (a menu with "Remove"), "Edit", and "History". The editor toolbar has "Change from this time", "Correct this value", and "Cancel"; a new draft has "Save" and "Cancel".

## Driving it with verify-electron

Preconditions:

- Year 43 is tick 20483840 and Year 44 is tick 20967680.
- Fixtures are "Glassmaw" (id 1) and "Ashback Tortoise" (id 2), both subtype Creature, first appearing Dawnmere 1, Year 1 (tick 0, worded without a clock), each with one image and no earlier image. The first creature you save gets id 3.
- Kind id `bestiary`, read as in the README baseline.

- **List.** `click --role button --name 'Bestiary'` routes to `#/bestiary?worldTick=20000000`. Main has the list "Bestiary" with links "Ashback Tortoise" and "Glassmaw", in name order, each card showing an image, "Creature", and the summary.
- **Detail.** Run `click --role link --name 'Glassmaw'` and `wait --role heading --name 'Glassmaw'`. The route is `#/bestiary/1?worldTick=20000000`. `snapshot` shows the description list "Fields" (Name, Summary, Subtype "Creature", Image), "Dates" (First appears "Dawnmere 1, Year 1", Status "Active" "from Dawnmere 1, Year 1"), heading "Scenes" with the link "The Glassmaw", heading "Relationships" with "No relationships recorded at this date.", and heading "World history" with one entry dated Dawnmere 1, Year 1.
- **Sidebar.** Run `click --role button --name 'Expand sidebar'`, `click --role button --name 'Expand Bestiary'`, then `click --role button --name 'Glassmaw'`. The route is `#/bestiary/1?worldTick=20000000`, and the row "Glassmaw" is `[current=page]`; with the Bestiary list collapsed the section "Bestiary" is current instead.
- **Create.** On the collection, `click --role button --name 'New creature'`. The heading is "New creature", the route stays `#/bestiary`, and the form has textboxes "Name" and "Summary", combobox "Subtype" set to "Creature" (its only choice), group "Image" with "Choose image", and group "First appears" preset to the viewed time. Run `click --role textbox --name 'Name'`, `type 'Lamp Moth'`, `click --role textbox --name 'Summary'`, `type 'A pale moth that gathers on crate lamps along the Rim Road.'`, `click --role button --name 'Save'`, and `wait --role heading --name 'Lamp Moth'`. The route is `#/bestiary/3?worldTick=20000000`.
- **Confirm create.** `eval '(async () => { const o = (await window.appHost.invoke("records.bestiary.get", {id:3}, {at:20000000})).output; return JSON.stringify({start:o.start, subtype:o.subtype, summary:o.summary}); })()'` returns `start {"kind":"exact","tick":20000000}`, `subtype "creature"`, and the typed summary.
- **Dated change.** On Lamp Moth, `click --role button --name 'Edit'` opens the form in place, with the route unchanged. It adds group "Date" (preset to the viewed time), textbox "Note", and combobox "Cause"; "Change from this time" and "Correct this value" stay disabled until a field changes. Run `click --role spinbutton --name 'Date year'`, `press Control+a`, `type '43'`, `click --role textbox --name 'Summary'`, `press Control+a`, `type 'The lamp moths now swarm the whole caldera rim.'`, `click --role button --name 'Change from this time'`, and `wait --role button --name 'Edit'`. World history gains a second entry, "Bloomtide 1, Year 43 · 21:20", whose only term is the new Summary, while Fields still shows the first summary.
- **Each date shows its value.** `shot --route '#/bestiary/3?worldTick=20483840'` shows the footer "Viewed date Bloomtide 1, Year 43 · 21:20" and Fields Summary "The lamp moths now swarm the whole caldera rim." `eval '(async () => { const at = async (t) => (await window.appHost.invoke("records.bestiary.get", {id:3}, {at:t})).output.summary; return [await at(20000000), await at(20483840)]; })()'` returns the first summary, then the Year 43 summary.
- **Correct an earlier value.** Run `shot --route '#/bestiary/3?worldTick=20000000'`, `click --role button --name 'Edit'`, `click --role textbox --name 'Summary'`, `press Control+a`, `type 'A pale moth that gathers on lanterns along the Rim Road.'`, `click --role button --name 'Correct this value'`, and `wait --role button --name 'Edit'`. The same `eval` returns the corrected summary for tick 20000000 and the unchanged Year 43 summary, and World history still has two entries.
- **Cancel a changed draft.** Run `click --role button --name 'Edit'`, `click --role textbox --name 'Summary'`, `type ' Draft words.'`, and `click --role button --name 'Cancel'`. The in-app dialog "Discard unsaved changes to this creature?" offers "Keep editing" (focused) and "Discard". `click --role button --name 'Keep editing'` leaves the typed words in Summary. `click --role button --name 'Cancel'` and `click --role button --name 'Discard'` return to the record, and `records.bestiary.get` still has the corrected summary.
- **Cancel a new draft.** On the collection, `click --role button --name 'New creature'`, type a Name, then `click --role button --name 'Cancel'`. The dialog is "Discard this new creature draft?" with the same two buttons. "Discard" returns to the collection with no new card.
- **End.** On Lamp Moth at tick 20000000, `click --role button --name 'End'`. The dialog "End" has group "Date" preset to the viewed time, textbox "Note", and a submit button "End". Run `click --role spinbutton --name 'Date year'`, `press Control+a`, `type '44'`, and `click --role button --name 'End'`. The dialog closes and the record still reads Status "Active" at Year 42. `db 'select point_role, effective_tick, status from bestiary_state_points where record_id = 3 and superseded_revision_id is null'` ends with a `change` row at 20967680 with status `ended`.
- **Show ended.** `shot --route '#/bestiary?worldTick=20967680'` lists only Glassmaw and Ashback Tortoise. `click --role button --name 'Show ended'` makes the toggle "[pressed]" and adds the card "Lamp Moth" with the Year 43 summary and the text "Ended".
- **Prior images.** At tick 20000000 open Glassmaw and `click --role button --name 'Edit'`. Group "Image" has an image, "Choose image", and "Clear image", and no "Prior images". `click --role button --name 'Choose image' --file <png path>` lists an `open` dialog answered with the path, and list "Prior images" appears with the item "Dawnmere 1, Year 1" and a button "Restore". Run `click --role button --name 'Change from this time'` and `wait --role button --name 'Edit'`; `records.bestiary.get` at ticks 10000000 and 20000000 now returns different `image` values. Run `click --role button --name 'Edit'`, `click --role button --name 'Restore'` (the list now offers the Year 42 image instead), `click --role button --name 'Correct this value'`, and `wait --role button --name 'Edit'`. Both ticks return the original image again.
- **Command palette.** Run `click --role button --name 'Open command palette'`, `wait --role dialog --name 'App command palette'`, `type 'Ashback'`, and `wait --role option --name 'Ashback Tortoise'`. `snapshot --role dialog` shows listbox "Commands" with group "Bestiary" holding the option. `click --role option --name 'Ashback Tortoise'` opens `#/bestiary/2?worldTick=20000000`.
- **Remove.** On Lamp Moth (`shot --route '#/bestiary/3?worldTick=20000000'`), run `click --role button --name 'More'` and `click --role menuitem --name 'Remove'`. The in-app dialog "Remove this creature?" offers "Cancel" (focused) and "Remove". `click --role button --name 'Cancel'` closes it, and `eval '(async () => (await window.appHost.invoke("records.bestiary.list", {show:"all"}, {at:20000000})).output.items.map((r) => r.title))()'` still lists Lamp Moth. Reopen it and `click --role button --name 'Remove'`. The route returns to `#/bestiary?worldTick=20000000`, the list `eval` returns only Glassmaw and Ashback Tortoise, and `records.bestiary.get` for id 3 answers `appError` code `not_found`, "Creature 3 does not exist."

## Gotchas

- A second change to the same field at the same date is refused with the alert "Glassmaw already changes image at Bloomtide 1, Year 42 · 21:20. Correct that change instead, or pick another date." Use "Correct this value", or set another Date.
- The End dialog's impact list "Linked to <name>" opens after End only when other records link to the creature. The sample creatures have none, so End just closes. While the End dialog is open, `--role button --name 'End'` matches only the dialog's button.

## Source and tests

- `src/features/bestiary/contract.ts` (fields, statuses, "First appears"), `ui/entrypoint.ts` (gallery collection), `ui/card.tsx`.
- `src/framework/ui/pages/CollectionPage.tsx`, `RecordPage.tsx`, `RecordEditing.tsx`, `RecordForm.tsx`, `StatusDialog.tsx`, `EndImpactDialog.tsx`, `PriorImages.tsx`, `WorldHistory.tsx`.
- `npm test -- src/app/record-kinds.test.ts src/features/bestiary/host/contract.test.ts`.
