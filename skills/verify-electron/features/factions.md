# Factions

Factions, offices, reporting links and authority links are four framework record kinds. A faction page shows its fields, Governance, Subordinates and Organizations; an office page shows its occupants and History; a coronation causes an office change; and the Timeline's Line view draws the reigns of realm offices. A character names a primary faction, and a war or treaty names factions as sides or parties. Dated changes, corrections, End, Show ended and prior images work as in [Bestiary](bestiary.md).

## Sub-features

- `factions-list` opens the Factions gallery, whose cards show each faction's image, name, scope, summary and headquarters; `offices-list`, `reporting-links-list` and `authority-links-list` open their lists. World search finds a faction by its scope, as "realm" finds the Veyran Tidecourt.
- `factions-detail` shows a faction's Type, Scope, Tier, Headquarters, Parent faction and image, with the reverse sections "Subordinates" and "Organizations".
- `factions-governance` shows a faction's Governance section: Offices, Reporting lines, Exceptional authority and Informal influence at the viewed time, and the disclosure "All recorded governance", which lists every office, reporting link and authority link of the faction whatever the viewed time. Every value shows as the record's own page shows it. A value uncertain at the viewed time, such as an occupant changed at a date given as a range, shows each possibility joined by "or". A record whose start is a range around the viewed time reads "May not exist yet", and an authority link whose kind may be either is listed under both.
- `offices-detail` shows an office's Faction, Purpose, Occupants with their capacity, Assertion and Evidence, and its World history. An occupant added in the form starts as incumbent, and a save with an occupant given no capacity is refused with "Give <name> a capacity in Occupants." under Occupants. The new-office form offers Cause.
- `offices-cause` shows the investiture as the cause of Ysolde Dunmore's change on the Tide Magistrate, and moving the investiture moves that change.
- `events-crowning` shows "Crowns <character> as <office>, <faction>" on a coronation's page, and the page's "Crown" action writes the caused office change (see [Events](events.md)).
- `reigns` draws one reign band per holder of a head office of a realm faction in the Timeline's Line view.
- `character-faction` picks a primary faction on a character from every recorded faction, and links to it from the profile.
- `event-sides` picks factions for an event's Side A, Side B or Parties in the event editor, and the event page names them whatever the viewed time.

## How to get to it (user POV)

- Sidebar "Factions", "Offices", "Reporting links" and "Authority links" open `#/factions`, `#/offices`, `#/reporting-links` and `#/authority-links`. Each card or row is a link named by the record's name or label that opens `#/<segment>/<numeric id>`.
- A character's profile links its Affiliation to the faction page. A coronation's page links "Crowns" to the character and the faction.
- The Timeline's Line view (`#/timeline?view=line`) draws reigns under the legend entry "Reigns".
- The collection toolbar has "Show ended" and "New faction" (or "New office", "New reporting link", "New authority link"). The record toolbar has "End", "More" (a menu with "Remove"), "Edit", and "History".

## Driving it with verify-electron

Preconditions:

- Faction fixtures, by id: 1 Veyran Tidecourt (Faction type, realm scope, headquarters Veyra-on-the-Tide, tick 1030000), 2 Lantern Cartographers' Compact (Guild, regional), 3 Glassward Bank (institution), 4 Free Harbors League (regional), 5 Order of the Drowned Lamp (Order, local), 6 Ashfold Kin (Tribe, local). None has a parent.
- Office fixtures, by id: 1 Tide Magistrate (Veyran Tidecourt, from tick 17000000: Harl Dunmore incumbent; from the Investiture of Ysolde Dunmore, event 19 at tick 18200000: Ysolde Dunmore incumbent, caused by that event; from tick 19000000: Oda Vell incumbent), 2 Beacon Warden (Veyran Tidecourt, Tovan Ash acting, Disputed, caused by Charter Renewal), 3 First Navigator (Compact, Mara Venn incumbent and Captain Orin Venn advisor, caused by Starhold Expedition), 4 Harbor-Speaker (Free Harbors League, Ilsabet Corrow), 5 Lamp-Keeper (Order of the Drowned Lamp, Brother Aumery Tallow).
- Reporting link 1 "Answers to the Magistrate" makes the Beacon Warden a direct subordinate of the Tide Magistrate. Authority links 1 "Emergency appointment" (exceptional authority, Tide Magistrate over Beacon Warden) and 2 "Lamp-Keeper's blessing" (informal influence, Brother Aumery Tallow over Beacon Warden).
- Kind ids `faction`, `office`, `reportingLink` and `authorityLink`, read as in the README baseline. `window.appHost.invoke("listReigns", {}, {})` answers `{output}` with the reign rows the Line view draws; it takes no `at`. `db 'select * from office_occupants_links'` shows occupants by `point_id`, and `db 'select record_id, authored_date_json, cause_kind, cause_id from office_state_points'` shows each office point's date and cause.

- **List.** `click --role button --name 'Factions'` routes to `#/factions?worldTick=20000000`, and main lists the six factions in name order. The Veyran Tidecourt's card reads its name, "Realm or nation", its summary and "Veyra-on-the-Tide".
- **Faction detail.** Run `click --role link --name 'Free Harbors League'` and `wait --role heading --name 'Free Harbors League'`. The route is `#/factions/4?worldTick=20000000`. Section "Organizations" lists "Saltmarrow Salvage Syndicate". "Subordinates" appears once a faction names the League as its Parent faction.
- **Governance.** On `#/factions/1?worldTick=20000000`, under heading "Governance", region "Offices" lists "Beacon Warden" (Occupied, "Tovan Ash acting", Disputed) and "Tide Magistrate" (Occupied, "Oda Vell incumbent", Confirmed). "Reporting lines" reads "Beacon Warden → Tide Magistrate", Direct, with the link "Answers to the Magistrate". "Exceptional authority" lists "Emergency appointment" (Tide Magistrate → Beacon Warden), and "Informal influence" lists "Lamp-Keeper's blessing" (Brother Aumery Tallow → Beacon Warden). Each office, link label and occupant links to its own page.
- **All recorded governance.** On `#/factions/1?worldTick=18500000`, "Offices" lists only "Tide Magistrate" with "Ysolde Dunmore incumbent", and the other three regions read "No reporting relationships authored.", "No exceptional authority authored." and "No informal influence authored.". After `click --role button --name 'All recorded governance'`, the list under it reads "Beacon Warden Office Active", "Tide Magistrate Office Active", "Answers to the Magistrate Reporting link Active", "Emergency appointment Authority link Active" and "Lamp-Keeper's blessing Authority link Active". An ended record shows its absent status, such as Dissolved, and a removed one is gone.
- **Office detail.** Run `click --role button --name 'Offices'`, then `click --role link --name 'Tide Magistrate'`. The route is `#/offices/1?worldTick=20000000`, and Occupants reads "Oda Vell" with the capacity incumbent. At `#/offices/1?worldTick=18500000` it reads "Ysolde Dunmore". Choose Edit, type a name into "Add to Occupants" and pick it: its select "<name> role" reads incumbent.
- **Cause.** On the Tide Magistrate's World history, Ysolde Dunmore's entry names "Investiture of Ysolde Dunmore" as its cause. Move the investiture's start on its event page and reopen the office: the entry follows the new date, and `office_state_points` shows that point's `authored_date_json` as `relative` to event 19.
- **Crowning.** On `#/events/19`, the fact "Crowns" reads "Ysolde Dunmore as Tide Magistrate, Veyran Tidecourt", with links to the character and the faction.
- **Reigns.** Open the Timeline, choose the Line view, and scrub across Year 38. The Tide Magistrate's reign row shows Harl Dunmore, Ysolde Dunmore, then Oda Vell. The Beacon Warden has no row because it reports to the Tide Magistrate, and advisors never get a band.
- **Primary faction.** Open a character, choose Edit, and open combobox "Primary faction". It lists every recorded faction, whatever the viewed time; saving one that is not active on the date is refused.

## Gotchas

- A coronation on the day its office is established is refused with "<Office> starts on the coronation date. Crown a ruler after the office is established." A coronation moved to another office than the one it already changed is refused until that change is undone.
- The Governance section has no inline forms and the faction page has no "Add subordinate" action. Offices, reporting links and authority links are created, edited and ended on their own pages, and a subordinate is made by setting its Parent faction.
- Office, reporting link and authority link faction links are fixed: the edit form shows the faction with no picker.

## Source and tests

- `src/features/faction`, `src/features/office`, `src/features/reportingLink`, `src/features/authorityLink` (contracts and entrypoints). `src/features/faction/ui/profile.tsx`, `governance.tsx` and `recordedGovernance.tsx` draw the Governance section.
- `src/features/event/host/service.ts` (the `crown` and `crowning` commands), `src/backend/services/crownings.ts` (the Line view's coronation names), `reign-service.ts` and `governance-records.ts` (reign rows), `character-service.ts` and `references.ts` (primary faction checks and names).
- `npm test -- src/app/record-kinds.test.ts src/features/event/host/service.test.ts src/features/event/host/rules.test.ts src/backend/services/reign-service.test.ts src/backend/services/character-faction.test.ts src/renderer/features/events/TimelinePage.test.tsx src/renderer/features/faction/factionProfile.test.tsx src/renderer/features/faction/governanceUncertainty.test.tsx`.
