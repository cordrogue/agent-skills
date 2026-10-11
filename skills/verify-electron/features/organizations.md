# Organizations

Organizations is a framework record kind: a gallery of guilds, schools, companies, temples, orders and societies, each with a name, summary, subtype, image, and the factions it belongs to. Each faction's page lists the organizations that name it.

## Sub-features

- `organizations-list` opens the collection from the sidebar as a gallery of cards.
- `organizations-detail` opens an organization from its card, the expanded sidebar, or the command palette, and shows Fields (with Factions), Dates, Scenes, Relationships, and World history.
- `organizations-faction` follows a Factions link to the faction page, whose "Organizations" section lists each organization that names the faction, once.
- `organizations-history` opens the organization's editorial revisions from History.
- `organizations-create` saves a new organization first appearing at the viewed time, with one of the eight subtypes and any number of factions.
- `organizations-change`, `organizations-correct`, `organizations-end`, `organizations-discard` and `organizations-prior-images` follow the [Bestiary](bestiary.md) recipe with the substitutions under Gotchas.
- `organizations-remove` removes an organization added by mistake after a question.

## How to get to it (user POV)

- Sidebar "Organizations" opens `#/organizations`. Each card has a link named by the organization, such as "Veyra Pilots' School", that opens `#/organizations/<numeric id>`.
- After "Expand sidebar", "Expand Organizations" lists them under list "Organizations records" as buttons named by the name alone.
- The command palette groups matching organizations under "Organizations".
- A faction page, such as `#/factions/2`, links each organization that names it in its "Organizations" section.
- The collection toolbar has "Show ended" (a toggle) and "New organization". The record toolbar has "End", "More" (a menu with "Remove"), "Edit", and "History".

## Driving it with verify-electron

Preconditions:

- Fixtures are "Veyra Pilots' School" (id 1, Educational, faction Lantern Cartographers' Compact, faction id 2, first appearing at tick 8000000), "Saltmarrow Salvage Syndicate" (id 2, Commercial, faction Free Harbors League, faction id 4, tick 16500000) and "Temple of the Drowned Lamp" (id 3, Religious, faction Order of the Drowned Lamp, faction id 5, tick 5300000). Each first appears when its faction does and has one image. The first organization you save gets id 4.
- Kind id `organization`, read as in the README baseline. `db 'select * from organization_factions_links'` shows the faction links by `point_id`.

- **List.** `click --role button --name 'Organizations'` routes to `#/organizations?worldTick=20000000`. Main has the list "Organizations" with links "Saltmarrow Salvage Syndicate", "Temple of the Drowned Lamp" and "Veyra Pilots' School", in name order, each card showing an image, its subtype ("Commercial", "Religious", "Educational"), and the summary.
- **Detail.** Run `click --role link --name "Veyra Pilots' School"` and `wait --role heading --name "Veyra Pilots' School"`. The route is `#/organizations/1?worldTick=20000000`. Under "Fields", Subtype reads "Educational" and Factions holds the link "Lantern Cartographers' Compact".
- **Faction.** Run `click --role link --name "Lantern Cartographers' Compact"` and `wait --role heading --name "Lantern Cartographers' Compact"`. The route is `#/factions/2?worldTick=20000000`, and section "Organizations" lists the link "Veyra Pilots' School" once. `click --role link --name "Veyra Pilots' School"` returns to `#/organizations/1?worldTick=20000000`.
- **Command palette.** Run `click --role button --name 'Open command palette'`, `wait --role dialog --name 'App command palette'`, `type 'Salvage Syndicate'`, and `wait --role option --name 'Saltmarrow Salvage Syndicate'`. `snapshot --role dialog` shows group "Organizations" holding the option. `click --role option --name 'Saltmarrow Salvage Syndicate'` opens `#/organizations/2?worldTick=20000000`.
- **History.** On Veyra Pilots' School, `click --role button --name 'History'` routes to `#/settings?tab=history&subjectType=organization&subjectId=1&worldTick=20000000`, and list "Editorial revisions" holds one revision, "Created organization Veyra Pilots' School", whose Undo is disabled.
- **Sidebar.** Run `click --role button --name 'Expand sidebar'`, `click --role button --name 'Expand Organizations'`, then `click --role button --name 'Temple of the Drowned Lamp'`. The route is `#/organizations/3?worldTick=20000000`.
- **Create.** On the collection, `click --role button --name 'New organization'`. The heading is "New organization", and combobox "Subtype" is set to "Political" with the options Political, Dynastic, Professional, Educational, Commercial, Religious, Military and Social or clandestine. Run `click --role textbox --name 'Name'`, `type 'Tideward Ferrymen'`, `click --role combobox --name 'Subtype'`, `press End`, `press Enter` (value "Social or clandestine"), `click --role button --name 'Save'`, and `wait --role heading --name 'Tideward Ferrymen'`. The route is `#/organizations/4?worldTick=20000000`, and `records.organization.get` for id 4 returns `subtype "socialClandestine"` and no factions.
- **Remove.** On Tideward Ferrymen, run `click --role button --name 'More'` and `click --role menuitem --name 'Remove'`. The in-app dialog "Remove this organization?" offers "Cancel" (focused) and "Remove". `click --role button --name 'Remove'` returns to `#/organizations?worldTick=20000000`, and `records.organization.get` for id 4 answers `appError` code `not_found`, "Organization 4 does not exist."

## Gotchas

- For the Bestiary recipe's change, correct, End, Show ended, Cancel and Prior images steps, use any organization. The Cancel dialogs read "Discard unsaved changes to this organization?" and "Discard this new organization draft?".
- A Factions link must hold for the whole time the organization is present. An organization that first appears before its faction shows a continuity warning on the record page, which is why each fixture starts with its faction.
- The legacy Catalog page and the `catalog_*` agent tools are gone; an agent creates an organization with `create_entity` and lists them with `list_entities` for `organization`.

## Source and tests

- `src/features/organization/contract.ts` (fields, subtypes, the Factions links field and its "Organizations" reverse section, statuses, "First appears"), `ui/entrypoint.ts` (gallery collection), `ui/card.tsx`.
- The framework pages listed in [Bestiary](bestiary.md). The faction page is a framework record page, covered in [Factions](factions.md).
- `npm test -- src/app/record-kinds.test.ts src/features/organization/host/contract.test.ts src/backend/services/scene-mention-service.test.ts`.
