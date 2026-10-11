# Powers

Powers is a framework record kind: a gallery of cards for the world's powers, spells, technologies and conditions, each with a name, summary, subtype, and image. Dated changes, corrections, discarding drafts and prior images work as in [Bestiary](bestiary.md), on the same framework pages.

## Sub-features

- `powers-list` opens the collection from the sidebar as a gallery of cards, showing only powers that first appear before the viewed time.
- `powers-detail` opens a record from its card, the expanded sidebar, or the command palette, and shows Fields, Dates, Scenes, Relationships, and World history.
- `powers-create` saves a new power first appearing at the viewed time, with a Subtype of Power, Spell, Technology, or Condition.
- `powers-end` ends a power at a date chosen in the End dialog, and Show ended brings it back into the collection.
- `powers-remove` removes a power added by mistake after a question.

## How to get to it (user POV)

- The sidebar button "Powers" opens `#/powers`.
- Each card's name link, such as "Echo Reading", opens `#/powers/<numeric id>`.
- After "Expand sidebar", "Expand Powers" lists the powers under the list "Powers records" as buttons named by the power's name alone.
- The command palette groups matching powers under "Powers".
- The collection toolbar has "Show ended" (a toggle) and "New power". The record toolbar has "End", "More" (a menu with "Remove"), "Edit", and "History". A new draft has "Save" and "Cancel".

## Driving it with verify-electron

Preconditions:

- Year 44 is tick 20967680.
- Fixtures are "Echo Reading" (id 1, first appears tick 1000000, Dawnmere 23, Year 3 · 10:40), "Beacon Kindling" (id 2, tick 5000000), and "Rimsense" (id 3, tick 2000000), all subtype Power, each with one image. Sera Nhal practices Echo Reading, Kesh Ash practices Rimsense, and the Starhold Lens is the focus for Beacon Kindling. The first power you save gets id 4.
- Kind id `power`, read as in the README baseline. The `db` query below is `db 'select point_role, effective_tick, status from power_state_points where record_id = <id> and superseded_revision_id is null'`.

- **List.** `click --role button --name 'Powers'`. The route is `#/powers?worldTick=20000000`, and main has the list "Powers" with links "Beacon Kindling", "Echo Reading", and "Rimsense" in name order, each card showing an image, "Power", and the summary. `shot --route '#/powers?worldTick=1500000'` lists only Echo Reading.
- **Detail.** `click --role link --name 'Echo Reading'` and `wait --role heading --name 'Echo Reading'`. The route is `#/powers/1?worldTick=20000000`. `snapshot` shows the description list "Fields" (Name, Summary, Subtype "Power", Image with an image), "Dates" (First appears "Dawnmere 23, Year 3 · 10:40", Status "Active" "from Dawnmere 23, Year 3 · 10:40"), heading "Scenes" with "Not in any saved Scene.", the region "Relationships" with the link "Sera Nhal" labelled "Connected to · Practices" and the note "Practices may remain active after Sera Nhal ends.", and heading "World history" with one entry.
- **Ids.** `eval '(async () => JSON.stringify((await window.appHost.invoke("records.power.list", {show:"all"}, {at:20000000})).output.items.map((r) => [r.id, r.title])))()'` returns `[[2,"Beacon Kindling"],[1,"Echo Reading"],[3,"Rimsense"]]`, the ids the seed relationships name.
- **Sidebar.** `click --role button --name 'Expand sidebar'` and `click --role button --name 'Expand Powers'`. The list "Powers records" has buttons "Beacon Kindling", "Echo Reading", and "Rimsense".
- **Create.** On the collection, `click --role button --name 'New power'`. The heading is "New power", the route stays `#/powers`, and the form has textboxes "Name" and "Summary", the combobox "Subtype" set to "Power" with options Power, Spell, Technology, and Condition, the group "Image" with "Choose image", and the group "First appears" preset to the viewed time. Run `click --role textbox --name 'Name'`, `type 'Tidecalling'`, `click --role textbox --name 'Summary'`, `type 'Calling a slack tide early by singing to the brineglass buoys.'`, `click --role combobox --name 'Subtype'`, `press ArrowDown`, `click --role button --name 'Save'`, and `wait --role heading --name 'Tidecalling'`. The route is `#/powers/4?worldTick=20000000`.
- **Confirm create.** `eval '(async () => { const o = (await window.appHost.invoke("records.power.get", {id:4}, {at:20000000})).output; return JSON.stringify({start:o.start, subtype:o.subtype, summary:o.summary}); })()'` returns `start {"kind":"exact","tick":20000000}`, `subtype "spell"`, and the typed summary.
- **Remove.** On Tidecalling, `click --role button --name 'More'` and `click --role menuitem --name 'Remove'`. The in-app dialog "Remove this power?" offers "Cancel" (focused) and "Remove". `click --role button --name 'Remove'` returns to `#/powers?worldTick=20000000`, and `records.power.get` for id 4 answers `appError` code `not_found`, "Power 4 does not exist."
- **End.** On Echo Reading at tick 20000000, `click --role button --name 'End'`. The dialog "End" has the group "Date" preset to the viewed time, the textbox "Note", and a submit button "End". Run `click --role spinbutton --name 'Date year'`, `press Control+a`, `type '44'`, and `click --role button --name 'End'`. The dialog closes. The `db` query for record 1 returns a `start` row at 1000000 and a `change` row at 20967680 with status `ended`.
- **Show ended.** `shot --route '#/powers?worldTick=20967680'` lists only Beacon Kindling and Rimsense. `click --role button --name 'Show ended'` adds the card "Echo Reading" with the text "Ended".
- **Command palette.** `click --role button --name 'Open command palette'`, `wait --role dialog --name 'App command palette'`, `type 'Rimsense'`, and `wait --role option --name 'Rimsense'`. `snapshot --role dialog` shows the listbox "Commands" with the group "Powers" holding the option. `click --role option --name 'Rimsense'` opens `#/powers/3?worldTick=20000000`.

## Gotchas

- Powers has no legacy commands, so `listPowerPage` and the like are gone. Read through `window.appHost.invoke("records.power.get", ...)`, `mcp`, or `db` as in Preconditions.
- Subtype is a native select whose popup never shows offscreen. Click it, then `press ArrowDown` from Power: one press is Spell, two Technology, three Condition.
- Ending Echo Reading closes the End dialog with no impact list, even though Sera Nhal practices it: relationships do not open the impact list.
- Remove on a fixture power also asks "Remove this power?". Answer "Cancel" unless the run starts fresh afterwards, because the seed relationships name the fixtures.
- The record table is `power_state_points`, the legacy table's name, with `record_id` in place of the legacy `power_id`.

## Source and tests

- `src/features/power/contract.ts` (fields, statuses, "First appears"), `ui/entrypoint.ts` (gallery collection), `ui/card.tsx`.
- `src/framework/ui/pages/CollectionPage.tsx`, `RecordPage.tsx`, `RecordEditing.tsx`, `RecordForm.tsx`, `StatusDialog.tsx`, `EndImpactDialog.tsx`.
- `npm test -- src/app/record-kinds.test.ts`.
