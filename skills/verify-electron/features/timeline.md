# Timeline views

Timeline shows the world's events three ways, from one read of every framework event (`listEventTimeline`) that the page and the bottom dock share. Chronology spaces event tracks by date and lists exact event-title mentions in saved scenes. Line selects and previews an event. Calendar lays events across a period's days with an agenda for the selected day. Every view opens the event's record, and undated events get their own list.

## Sub-features

- `timeline-chronology` opens an event from its track title or bar.
- `timeline-viewport` zooms, fits, and recenters Chronology on the viewed date.
- `timeline-line` selects an event, previews it, and opens it.
- `timeline-calendar` steps periods, returns to the story date, and opens an event from the agenda.
- `timeline-manuscript` lists scene mentions of event titles and opens the event or the scene.
- `timeline-context` opens an event from its right-click menu.
- `timeline-uncertain` lists separately the events whose start, or authored end, is not exact, with their dates in the framework's date words.
- `timeline-dock` draws each exact event as one bar in the bottom dock's Events lane, in place of its start, change and Over marks.

## How to get to it (user POV)

- The sidebar "Timeline" button. Route `#/timeline` opens Chronology.
- The top bar's tablist "Timeline views" has tabs "Chronology", "Line", and "Calendar". Routes add `?view=line` or `?view=calendar`.
- Chronology's "Manuscript occurrences" disclosure sits below the tracks.

## Driving it with verify-electron

Preconditions:

- Run `doctor` after `start`.
- Fixtures are event "Moonfall Accord" (id 1, Year 35) and "Starhold Expedition" (id 4, spanning story present 20000000). Scene "The Salt Bell" mentions Moonfall Accord.

- **Chronology.** `click --role button --name 'Timeline'`. Tabpanel "Chronology" lists each event as a title button plus an "Open <title>" bar. `click --role button --name 'Moonfall Accord'` opens `#/events/1`. Back on Timeline, `click --role button --name 'Open Moonfall Accord'` opens the same record.
- **Zoom.** Group "Timeline zoom controls" has "Present", "Fit", "Zoom out", and "Zoom in". `click --role button --name 'Zoom in'` sets `data-event-timeline-zoom` to `2` and shows "2×". `click --role button --name 'Fit'` returns it to `1` and disables Fit.
- **Present.** At zoom 2, `scroll --role region --name 'Scrollable chronology' --dy 0 --dx -1000` moves `scrollLeft` from 1335 to 335, as its `before` and `after` report. `click --role button --name 'Present'` brings it back to 1335.
- **Line.** `click --role tab --name 'Line'` (route `?view=line`). `click --role button --name 'Moonfall Accord'` keeps the route and shows complementary "Selected event" with heading "Moonfall Accord", When, Place "Veyra-on-the-Tide", and Type "Treaty". `click --role button --name 'Open'` opens `#/events/1`. Selecting "Battle of the Saltmarrow Roads" shows Part of "Toll War", and selecting Toll War lists both its battles under Battles; a battle that does not name a war in Part of is never linked to one.
- **Calendar.** `shot --route '#/timeline?view=calendar&worldTick=20000000'`. Group "Calendar period controls" reads "Bloomtide, Year 42". Day buttons read like "Bloomtide 1, Year 42, 3 events, selected, current story date". `click --role button --name 'Next period'` shows "Suncrest, Year 42", "Previous period" steps back, and `click --role button --name 'Current story date'` returns to Bloomtide.
- **Agenda.** The complementary "Bloomtide 1, Year 42 agenda" lists Drowned Age, Starhold Expedition, and The Starhold Survey as "Continues". `click 'aside[aria-label$=" agenda"] button[aria-label="Open Starhold Expedition"]'` opens `#/events/4`.
- **Manuscript.** In Chronology, `click --role DisclosureTriangle --name 'Manuscript occurrences'`. Group "Scene sequence" lists each scene of "The Three Witnesses". The Salt Bell has list "Scene mentions in The Salt Bell" with button "Scene mention · Moonfall Accord", which opens `#/events/1`. Other scenes say "No exact Event-title occurrences in saved version 1." `click --role link --name 'The Salt Bell'` opens `#/writing?view=write&scene=<uuid>`.
- **Context menu.** `click --role button --name 'Moonfall Accord' --button right`. The menu has "Open", "Open in workspace", "Copy name", and "Copy link". `click --role menuitem --name 'Open'` opens `#/events/1`.
- **Uncertain dates.** The sample has none, so make one: `eval 'window.appHost.invoke("records.event.create", {fields:{name:"Verify Drifting Rumor"}, start:{kind:"range", earliest:19990000, latest:19995000}}, {at:19990000, requestKey:"page:" + crypto.randomUUID()})'`. On Timeline, region "Events with uncertain dates" holds a button whose text starts "Verify Drifting Rumor", then "between <date> and <date>; estimated end ..." or "ends Unknown". It opens the new event, and no Chronology track, Line mark or Calendar bar draws it.
- **Dock.** `click --role button --name 'Expand timeline scrubber'`. The lanes run Places, Maps and World first, then the framework kinds, People and Events among them. Starhold Expedition is one bar in the Events lane, with no separate start or Over clip.

## Gotchas

- In Line, a title button only selects. Use "Open" in "Selected event".
- Calendar repeats "Open <title>" buttons in every week row and in the agenda. Scope by the agenda selector.
- Present and Current story date move the view only, not viewed time or story present.
- A calendar weekday change in Settings changes the Calendar grid's columns. Run this recipe on a fresh sample.

## Source and tests

- `src/renderer/features/events/TimelinePage.tsx`, `UncertainEvents.tsx`, `EventTimelineView.tsx`, `EventChronologyView.tsx`, `EventLineView.tsx`, `EventCalendarView.tsx`, `EventContextTarget.tsx`.
- `timelineEvents.ts` (the shared query and the event link), `eventTypes.ts` (type groups, ranks and colors, labels from the event contract), `eventLinks.ts` (Part of, Battles, Begins with, Ends with, Begins, Ends, During).
- `src/shared/timeline-event.ts` (`TimelineEvent`, `isCharted`, `timelineEventEnd`), `src/backend/services/event-timeline.ts`.
- `src/renderer/components/app-shell/AppShellTemporalDock.tsx`, `src/renderer/components/temporal/timelineClipLayout.ts`, `TemporalLanes.tsx`.
- `npm test -- src/renderer/features/events src/renderer/components/temporal src/renderer/components/BottomTemporalScrubber.test.tsx`.
