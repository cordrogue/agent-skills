# Lore

Lore is a framework record kind: a gallery of legends, histories, religions, magic systems, natural laws and documents, each with a name, summary, subtype, and image.

## Sub-features

- `lore-list` opens the collection from the sidebar as a gallery of cards.
- `lore-detail` opens an entry from its card, the expanded sidebar, or the command palette, and shows Fields, Dates, Scenes, Relationships, and World history.
- `lore-history` opens the entry's editorial revisions from History.
- `lore-create` saves a new entry first appearing at the viewed time, with one of the six subtypes.
- `lore-change`, `lore-correct`, `lore-end`, `lore-discard` and `lore-prior-images` follow the [Bestiary](bestiary.md) recipe with the substitutions under Gotchas.
- `lore-remove` removes an entry added by mistake after a question.

## How to get to it (user POV)

- Sidebar "Lore" opens `#/lore`. Each card has a link named by the entry, such as "The Two Moonfall Texts", that opens `#/lore/<numeric id>`.
- After "Expand sidebar", "Expand Lore" lists the entries under list "Lore records" as buttons named by the entry alone.
- The command palette groups matching entries under "Lore".
- The collection toolbar has "Show ended" (a toggle) and "New lore entry". The record toolbar has "End", "More" (a menu with "Remove"), "Edit", and "History".

## Driving it with verify-electron

Preconditions:

- Fixtures are "The Drowning of the Lamps" (id 1, Legend), "The Two Moonfall Texts" (id 2, History), "Faith of the Drowned Lamp" (id 3, Religion) and "Brineglass Memory" (id 4, Magic system), each first appearing Dawnmere 1, Year 1 (tick 0) with one image. The first entry you save gets id 5.
- Kind id `lore`, read as in the README baseline.

- **List.** `click --role button --name 'Lore'` routes to `#/lore?worldTick=20000000`. Main has the list "Lore" with links "Brineglass Memory", "Faith of the Drowned Lamp", "The Drowning of the Lamps" and "The Two Moonfall Texts", in name order, each card showing an image, its subtype ("Magic system", "Religion", "Legend", "History"), and the summary.
- **Command palette.** Run `click --role button --name 'Open command palette'`, `wait --role dialog --name 'App command palette'`, `type 'Moonfall Texts'`, and `wait --role option --name 'The Two Moonfall Texts'`. `snapshot --role dialog` shows group "Lore" holding the option. `click --role option --name 'The Two Moonfall Texts'` and `wait --role heading --name 'The Two Moonfall Texts'` open `#/lore/2?worldTick=20000000`, with Subtype "History" under "Fields".
- **History.** On The Two Moonfall Texts, `click --role button --name 'History'` routes to `#/settings?tab=history&subjectType=lore&subjectId=2&worldTick=20000000`. Main reads "Showing saved changes for The Two Moonfall Texts.", and list "Editorial revisions" holds one revision, "Created lore entry The Two Moonfall Texts", whose Undo is disabled.
- **Sidebar.** Run `click --role button --name 'Expand sidebar'`, `click --role button --name 'Expand Lore'`, then `click --role button --name 'Brineglass Memory'`. The route is `#/lore/4?worldTick=20000000`.
- **Create.** On the collection, `click --role button --name 'New lore entry'`. The heading is "New lore entry", and combobox "Subtype" is set to "Legend" with the options Legend, History, Religion, Magic system, Natural law and Document. Run `click --role textbox --name 'Name'`, `type 'The Ash Ledger'`, `click --role combobox --name 'Subtype'`, `press End`, `press Enter` (value "Document"), `click --role button --name 'Save'`, and `wait --role heading --name 'The Ash Ledger'`. The route is `#/lore/5?worldTick=20000000`, and `records.lore.get` for id 5 returns `subtype "document"`.
- **Remove.** On The Ash Ledger, run `click --role button --name 'More'` and `click --role menuitem --name 'Remove'`. The in-app dialog "Remove this lore entry?" offers "Cancel" (focused) and "Remove". `click --role button --name 'Remove'` returns to `#/lore?worldTick=20000000`, and `records.lore.get` for id 5 answers `appError` code `not_found`, "Lore entry 5 does not exist."

## Gotchas

- For the Bestiary recipe's change, correct, End, Show ended, Cancel and Prior images steps, use any lore entry. The Cancel dialogs read "Discard unsaved changes to this lore entry?" and "Discard this new lore entry draft?".
- Searching "Moonfall" alone ranks the Moonfall Accord event and the Moonfall Chart item above the Lore group. Type "Moonfall Texts".

## Source and tests

- `src/features/lore/contract.ts` (fields, subtypes, statuses, "First appears"), `ui/entrypoint.ts` (gallery collection), `ui/card.tsx`.
- The framework pages listed in [Bestiary](bestiary.md).
- `npm test -- src/app/record-kinds.test.ts src/features/lore/host/contract.test.ts`.
