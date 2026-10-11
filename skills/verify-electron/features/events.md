# Events

Events is a framework record kind: a gallery of event cards, each with an image, name, type and status. An event's page shows its type, place, the fields its type uses, facts derived from other events, Consequences and World history. Dated changes, corrections, Mark over, Show over, prior images and Remove work as in [Bestiary](bestiary.md). The Timeline views are in [timeline.md](timeline.md).

## Sub-features

- `events-list` opens the Events gallery from the sidebar, in name order.
- `events-detail` opens an event from its card, the expanded sidebar, the command palette, or a Timeline view, and shows its image and summary, then Type, Place, Crowns (coronations only), the fields its type uses, and the derived facts During, Battles, Begins and Ends.
- `events-editor` shows the type's fields only. The Type select groups its 21 types under Ages, Conflict, Journeys, Politics, Calamity, Culture, Story and General, and changing the type clears the fields the new type hides.
- `events-sides` refuses a faction on both Side A and Side B with "A faction cannot be on both sides." under Side B.
- `events-crown` crowns a ruler from a coronation's page through the "Crown" dialog, and the page then reads "Crowns <character> as <office>, <faction>".
- `events-consequences` lists the changes an event caused under "Consequences", or "No direct consequences.".
- `events-remove` refuses removing an event that another event names in Part of, Begins with or Ends with, or that a relationship names as its source event.

## How to get to it (user POV)

- Sidebar "Events" opens `#/events`. Each card is a link named by the event, such as "Moonfall Accord", that opens `#/events/<numeric id>`.
- After "Expand sidebar", "Expand Events" lists the events as buttons named by their name.
- Every Timeline view opens an event's page, keeping the viewed time.
- The collection toolbar has "Show over" and "New event". The record toolbar has "Mark over" ("Mark under way" once the event is over), "More" (a menu with "Remove"), "Edit" and "History", and on a coronation also "Crown".

## Driving it with verify-electron

Preconditions:

- Event fixtures keep their ids. 1 Moonfall Accord (Treaty at Veyra-on-the-Tide, ticks 16500000 to 16501440), 4 Starhold Expedition, 13 Age of Lamps (Age, ends at 12000000), 14 Drowned Age (Age, no end), 15 Toll War (War, 17000000 to 17400000), 16 Battle of the Saltmarrow Roads and 17 Siege of the Veyra Quay (Part of Toll War), 19 Investiture of Ysolde Dunmore (Coronation at tick 18200000, no end, so its 3-day default length applies). The first event you save gets id 21.
- Kind id `event`, read as in the README baseline. A write needs a request key: `{at: <tick>, requestKey: "page:" + crypto.randomUUID()}`. `window.appHost.invoke("event.crowning", {id: 19}, {at: 20000000})` answers the crowned character, office and faction. The Timeline's read is `window.appHost.invoke("listEventTimeline", {}, {})`.

- **List.** `click --role button --name 'Events'` routes to `#/events?worldTick=20000000`. Main lists the 4 events under way, in name order: Drowned Age, Investiture of Ysolde Dunmore, Starhold Expedition and The Starhold Survey. Each card shows its image, name, type and, once over or probably over, its status. `click --role button --name 'Show over'` adds the 15 events that are over. Relighting of Starhold starts later, at tick 20040000, and is not listed.
- **Detail.** Run `click --role link --name 'Moonfall Accord'` and `wait --role heading --name 'Moonfall Accord'`. The route is `#/events/1?worldTick=20000000`. Description list "Fields" reads Type "Treaty", Place "Veyra-on-the-Tide", Parties "Veyran Tidecourt" and "Free Harbors League", and During "Drowned Age" (the age has no end, so its 1000-year default length covers Year 35). The page then has Dates (Status "Over"), Consequences, Relationships, Scenes and World history.
- **Battles.** On `#/events/15?worldTick=20000000` the facts list Battles "Battle of the Saltmarrow Roads" and "Siege of the Veyra Quay". On `#/events/16`, Part of reads "Toll War".
- **Editor.** On a Treaty, `click --role button --name 'Edit'`. The form shows Parties and no Side A, Side B, Victor, Part of, Characters, Begins with or Ends with. Changing combobox "Type" to Battle adds Side A, Side B, Victor and Part of and drops Parties. Cancel and Discard.
- **Both sides.** On a Battle, choose the same faction under Side A and Side B and save. The form refuses with "A faction cannot be on both sides." under Side B.
- **Crowns.** On `#/events/19?worldTick=20000000`, the fact "Crowns" reads "Ysolde Dunmore as Tide Magistrate, Veyran Tidecourt", each a link.
- **Crown.** Create a Coronation at the viewed time with "New event", Type "Coronation", then save. The toolbar shows "Crown". `click --role button --name 'Crown'` opens dialog "Crown a ruler" with pickers "Character" and "Office"; its "Crown" button stays disabled until both are chosen. Pick a character and "Beacon Warden", then `click --role button --name 'Crown'`. The dialog closes, the page reads "Crowns <character> as Beacon Warden, Veyran Tidecourt", and the Beacon Warden's World history names the coronation as the cause. Crowning again on another office shows "Could not crown" with "This coronation already crowned <name> as Beacon Warden. Undo that change before crowning on another office."
- **Consequences.** On `#/events/19?worldTick=20000000`, "Consequences" lists the Tide Magistrate change. An event that caused nothing reads "No direct consequences."
- **Remove a referenced event.** Open Toll War, then `click --role button --name 'More'` and `click --role menuitem --name 'Remove'`. The removal is refused because the battles name it in Part of, and `records.event.get` for id 15 still answers.

## Gotchas

- "Crown" shows only on a saved coronation's page, and a coronation needs an exact start. A coronation on the day its office starts is refused with "<Office> starts on the coronation date. Crown a ruler after the office is established."
- Moving a coronation's start moves the office change with it, because the change is dated relative to the event's start.
- Rebellions show "Side A" and "Side B", like wars.

## Source and tests

- `src/features/event/contract.ts`, `ui/entrypoint.ts`, `ui/editor.tsx`, `ui/profile.tsx`, `ui/derived.ts`, `ui/actions.tsx`, `host/service.ts` (`crown`, `crowning`), `host/rules.ts`.
- `src/backend/services/event-timeline.ts`, `src/shared/timeline-event.ts`.
- `npm test -- src/app/record-kinds.test.ts src/features/event src/renderer/features/events/EventConsequences.test.tsx`.
