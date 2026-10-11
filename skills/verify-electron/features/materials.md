# Materials

Materials is a framework record kind: a gallery of materials, metals, stones, gems, woods, textiles and reagents, each with a name, summary, subtype, and image. the sample project has none.

## Sub-features

- `materials-list` opens the collection from the sidebar; it is empty in the sample.
- `materials-create` saves a new material first appearing at the viewed time, with one of the seven subtypes.
- `materials-detail` opens the saved material with Fields, Dates, Scenes, Relationships, and World history.
- `materials-change`, `materials-correct`, `materials-end`, `materials-discard` and `materials-prior-images` follow the [Bestiary](bestiary.md) recipe with the substitutions under Gotchas.
- `materials-remove` removes a material added by mistake after a question.

## How to get to it (user POV)

- Sidebar "Materials" opens `#/materials`. A card's link, named by the material, opens `#/materials/<numeric id>`.
- After "Expand sidebar", "Expand Materials" lists the materials under list "Materials records".
- The command palette groups matching materials under "Materials".
- The collection toolbar has "Show ended" (a toggle) and "New material". The record toolbar has "End", "More" (a menu with "Remove"), "Edit", and "History".

## Driving it with verify-electron

Preconditions:

- There are no material fixtures. The first material you save gets id 1.
- Kind id `material`, read as in the README baseline, with table `material_state_points`.

- **List.** `click --role button --name 'Materials'` routes to `#/materials?worldTick=20000000`, and main reads "No materials yet".
- **Create.** `click --role button --name 'New material'`. The heading is "New material", and the form has textboxes "Name" and "Summary", combobox "Subtype" set to "Material" with the options Material, Metal, Stone, Gem, Wood, Textile and Reagent, group "Image", and group "First appears" preset to the viewed time. Run `click --role textbox --name 'Name'`, `type 'Brineglass'`, `click --role textbox --name 'Summary'`, `type 'Crystallized tidewater cut from the reefs.'`, `click --role combobox --name 'Subtype'`, `press Home`, three `press ArrowDown`, `press Enter` (value "Gem"), `click --role button --name 'Save'`, and `wait --role heading --name 'Brineglass'`. The route is `#/materials/1?worldTick=20000000`.
- **Confirm create.** `eval '(async () => { const o = (await window.appHost.invoke("records.material.get", {id:1}, {at:20000000})).output; return JSON.stringify({start:o.start, subtype:o.subtype, summary:o.summary}); })()'` returns `start {"kind":"exact","tick":20000000}`, `subtype "gem"`, and the typed summary.
- **Remove.** On Brineglass, run `click --role button --name 'More'` and `click --role menuitem --name 'Remove'`. The in-app dialog "Remove this material?" offers "Cancel" (focused) and "Remove". `click --role button --name 'Remove'` returns to `#/materials?worldTick=20000000`. `eval '(async () => (await window.appHost.invoke("records.material.list", {show:"all"}, {at:20000000})).output.items.length)()'` returns 0, and `records.material.get` for id 1 answers `appError` code `not_found`, "Material 1 does not exist."

## Gotchas

- For the Bestiary recipe's change, correct, End, Show ended, Cancel and Prior images steps, save a material first. The Cancel dialogs read "Discard unsaved changes to this material?" and "Discard this new material draft?".
- The route is `#/materials` but the kind id, the addresses and the table use the singular `material`.

## Source and tests

- `src/features/material/contract.ts` (fields, subtypes, statuses, "First appears"), `ui/entrypoint.ts` (gallery collection), `ui/card.tsx`.
- The framework pages listed in [Bestiary](bestiary.md).
- `npm test -- src/app/record-kinds.test.ts src/features/material/host/contract.test.ts`.
