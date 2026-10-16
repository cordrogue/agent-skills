# Cultures

Cultures is a framework record kind: a gallery of cultures, ethnicities, languages, traditions and professions, each with a name, summary, subtype, and image. The sample project has none.

## Sub-features

- `cultures-list` opens the collection from the sidebar; it is empty in the sample.
- `cultures-create` saves a new culture entry first appearing at the viewed time, with one of the five subtypes.
- `cultures-detail` opens the saved entry with Fields, Dates, Scenes, Relationships, and World history.
- `cultures-change`, `cultures-correct`, `cultures-end`, `cultures-discard` and `cultures-prior-images` follow the [Bestiary](bestiary.md) recipe with the substitutions under Gotchas.
- `cultures-remove` removes an entry added by mistake after a question.

## How to get to it (user POV)

- Sidebar "Cultures" opens `#/cultures`. A card's link, named by the entry, opens `#/cultures/<numeric id>`.
- After "Expand sidebar", "Expand Cultures" lists the entries under list "Cultures records".
- The command palette groups matching entries under "Cultures".
- The collection toolbar has "Show ended" (a toggle) and "New culture entry". The record toolbar has "End", "More" (a menu with "Remove"), "Edit", and "History".

## Driving it with verify-electron

Preconditions:

- There are no culture fixtures. The first entry you save gets id 1.
- Kind id `culture`, read as in the README baseline, with table `culture_state_points`.

- **List.** `click --role button --name 'Cultures'` routes to `#/cultures?worldTick=20000000`, and main reads "No cultures yet".
- **Create.** `click --role button --name 'New culture entry'`. The heading is "New culture entry", and combobox "Subtype" is set to "Culture" with the options Culture, Ethnicity, Language, Tradition and Profession. Run `click --role textbox --name 'Name'`, `type 'Harbor Cant'`, `click --role combobox --name 'Subtype'`, `press Home`, two `press ArrowDown`, `press Enter` (value "Language"), `click --role button --name 'Save'`, and `wait --role heading --name 'Harbor Cant'`. The route is `#/cultures/1?worldTick=20000000`.
- **Confirm create.** `eval '(async () => { const o = (await window.appHost.invoke("records.culture.get", {id:1}, {at:20000000})).output; return JSON.stringify({start:o.start, subtype:o.subtype}); })()'` returns `start {"kind":"exact","tick":20000000}` and `subtype "language"`.
- **Remove.** On Harbor Cant, run `click --role button --name 'More'` and `click --role menuitem --name 'Remove'`. The in-app dialog "Remove this culture entry?" offers "Cancel" (focused) and "Remove". `click --role button --name 'Remove'` returns to `#/cultures?worldTick=20000000`, and `records.culture.get` for id 1 answers `appError` code `not_found`, "Culture entry 1 does not exist."

## Gotchas

- For the Bestiary recipe's change, correct, End, Show ended, Cancel and Prior images steps, save an entry first. The Cancel dialogs read "Discard unsaved changes to this culture entry?" and "Discard this new culture entry draft?".
- The route is `#/cultures` but the kind id, the addresses and the table use the singular `culture`.

## Source and tests

- `src/features/culture/contract.ts` (fields, subtypes, statuses, "First appears"), `ui/entrypoint.ts` (gallery collection), `ui/card.tsx`.
- The framework pages listed in [Bestiary](bestiary.md).
- `npm test -- src/app/record-kinds.test.ts src/features/culture/host/contract.test.ts`.
