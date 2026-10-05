# Events

Events lists every event across world time, past and future. A writer opens an event's dates, type, place, parties, and consequences, creates or edits an event with authored date precision, and removes an event added by mistake.

## Sub-features

- `events-list` lists events, including ones after the viewed date.
- `events-detail` opens an event from the list, its context menu, the sidebar, or Timeline.
- `events-create` saves a new event, and Cancel asks before discarding a draft.
- `events-edit` saves changes and shows them on the reopened event.
- `events-dates` saves an Unknown start through the Event starts precision select.
- `events-remove` removes an event added by mistake.

## How to get to it (user POV)

- Sidebar "Events", route `#/events`. Cards are buttons named `Open <title>`. Detail is `#/events/<numeric id>`.
- The card context menu offers Open, Open in workspace, Copy name, and Copy link.
- "Expand sidebar", then "Expand Events", lists events as buttons named by title.
- Timeline lists each event as a button named `Open <title>`.
- The toolbar has "Add event" on the list and "Edit" on detail. The editor toolbar has Save, Cancel, and Remove mistake.

## Driving it with verify-electron

Preconditions:

- A fresh `start`. Commands below are `node scripts/verify-electron.mjs` subcommands. Viewed date is tick 20000000.
- Fixture "Moonfall Accord" is id 1, a Treaty at Veyra-on-the-Tide, ticks 16500000 to 16501440. "Relighting of Starhold" starts after the viewed date.

- **List.** Run `click --role button --name 'Events'`. The route is `#/events` in List view, and main has both "Open Moonfall Accord" and "Open Relighting of Starhold".
- **Detail.** Run `click --role button --name 'Open Moonfall Accord'` and `wait --role heading --name 'Moonfall Accord'`. The route is `#/events/1`. Detail lists Status Ended, Starts "Frostwane 7, Year 35", Ends "Frostwane 8, Year 35", a Place link "Veyra-on-the-Tide", Parties links "Veyran Tidecourt" and "Free Harbors League", and a "Consequences1" heading. `eval 'window.app.getEvent({id:1,editorialRevisionId:"head"})'` returns the same ticks.
- **Context menu.** On Events, run `click --role button --name 'Open Moonfall Accord' --button right` and `click --role menuitem --name 'Open'`. The route is `#/events/1`.
- **Sidebar.** Run `click --role button --name 'Expand sidebar'`, `click --role button --name 'Expand Events'`, and `click --role button --name 'Moonfall Accord'`. The route is `#/events/1`.
- **Timeline.** Run `click --role button --name 'Timeline'` and `click --role button --name 'Open Moonfall Accord'`. The route is `#/events/1`.
- **Create.** On Events, run `click --role button --name 'Add event'`. The heading reads "New event" and Save is disabled. Run `click --role textbox --name 'Title'`, `type 'Verification event'`, `click --role textbox --name 'Summary'`, `type 'Created through the event editor.'`, and `click --role button --name 'Save'`. Save lands on detail. `wait --role heading --name 'Verification event'` passes and the route gains the new id (21 on a fresh sample).
- **Confirm create.** `eval '(async () => (await window.app.listEvents({editorialRevisionId:"head"})).find(x => x.title === "Verification event"))()'` has `startTick: 20000000`, `startDate.kind: "exact"`, `endDate: null`, `defaultEndDate.tick: 20001440`, and `primaryLocationId: null`.
- **Edit.** Run `click --role button --name 'Edit'`, `click --role textbox --name 'Summary'`, `press Control+a`, `type 'Changed through the event editor.'`, and `click --role button --name 'Save'`. Save keeps the editor open. Poll `wait --until '(async () => (await window.app.getEvent({id:<id>,editorialRevisionId:"head"})).record?.summary === "Changed through the event editor.")()'`.
- **Date precision.** In the editor, run `click --role combobox --name 'Event starts'`, `press Home`, and `press Enter`. The combobox value is "Unknown". Run `click --role button --name 'Save'` and poll `wait --until '(async () => (await window.app.getEvent({id:<id>,editorialRevisionId:"head"})).record?.startDate.kind === "unknown")()'`. `click --role button --name 'Cancel'` shows Status "State unknown", Starts "Unknown", and Ends "Unknown".
- **Reopen.** Run `click --role button --name 'Events'` and `click --role button --name 'Open Verification event'`. Detail shows the changed summary.
- **Discard.** Run `click --role button --name 'Add event'`, type a Title, then `click --role button --name 'Cancel'`. The dialog "Discard this new event draft?" offers "Keep editing" and "Discard". After `click --role button --name 'Discard'`, `listEvents` has no event with that title.
- **Remove.** Save a disposable event (id 21 on a fresh sample) and run `click --role button --name 'Edit'`. `click --role button --name 'Remove mistake' --dismiss` lists the confirm "Remove this event? Undo in Change history restores it until the next change." with `answer:false`, and `listEvents` still has the event. `click --role button --name 'Remove mistake'` answers OK, the route returns to `#/events`, and `listEvents` no longer has it.

## Gotchas

- "Event starts" names both the precision combobox and a date group. Target `--role combobox`. Its options are Unknown, Exact date, and Between dates. "Event ends" adds Default and No end.
- Native select popups never paint offscreen. Change a select with `click`, then `press Home` or arrows, then `press Enter`, and read the value from `snapshot`.
- Events uses Edit, not Add change, and has no End action.

## Source and tests

- `src/renderer/features/events/EventPage.tsx`, `EventPageView.tsx`, `EventDetailView.tsx`, `eventPageModel.ts`, `eventKindFields.tsx`; `src/renderer/components/AuthoredDateInput.tsx`.
- `src/shared/event.ts`, `event-ipc.ts`; `src/backend/services/event-service.ts`.
- `npm test -- src/renderer/features/events/EventPage.test.tsx src/renderer/features/shared/recordPage.test.tsx`.
- `npm test -- src/backend/services/event-service.test.ts`.
