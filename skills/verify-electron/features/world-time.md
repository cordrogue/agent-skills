# Viewed time and the footer clock

Every page shows the world as of the viewed date. The footer clock steps between authored changes, takes a typed date or a shortcut, and expands into a timeline scrubber. Moving viewed time never changes the saved story present, and a change saved at a later viewed date leaves earlier dates as they were.

## Sub-features

- `time-adjacent` jumps to the previous or next authored change, from the arrows or their context menu.
- `time-date` applies a typed date, rejects an invalid one, and offers Return to story present, Start of year, and Next year.
- `time-route` keeps viewed time in the route across page changes.
- `time-scrub` expands the scrubber, scrubs the slider, and pans, zooms, and centers the ruler without moving viewed time.
- `time-state` saves a record change at a later date while earlier dates keep the old value.

## How to get to it (user POV)

- The footer (complementary "Timeline controls") on every project page. Its date button reads "Viewed date <date>", between "Go to previous authored change" and "Go to next authored change".
- Right-click either arrow for "Previous authored change" and "Next authored change".
- "Expand timeline scrubber" at the footer's right end.
- A record's "Add change" toolbar button saves a change at the viewed date.

## Driving it with verify-electron

Preconditions:

- Run `doctor` after `start`.
- `eval '(async () => (await window.appHost.invoke("getTimelineBounds", undefined, {})).output)()'` returns `storyPresentTick` 20000000; re-read it after each step below, and it must not change.
- Fixture for `time-state` is "Mara Venn", id 1, status "Active on the Starhold survey".

- **Adjacent.** On Overview, `click --role button --name 'Go to previous authored change'`. The route becomes `worldTick=19990360`, matching `getAdjacentTimelineChange({direction:"backward",tick:20000000})`, and the footer reads "Viewing Starhold Ledger Review at Greengale 23, Year 42 · 04:40." `click --role button --name 'Go to next authored change'` goes to 20040000, "Relighting of Starhold". Story present is not a stop.
- **Context menu.** `click --role button --name 'Go to previous authored change' --button right`, then `click --role menuitem --name 'Previous authored change'`. The route steps back to 19990360.
- **Date editor.** `click 'button[aria-label^="Viewed date "]'` and `wait --role group --name 'Viewed date'`. The group has "Return to story present", "Start of year", "Next year", spinbuttons "Viewed date day", "year", "hour", and "minute", and a disabled "Apply date".
- **Typed date.** From story present, `click --role spinbutton --name 'Viewed date day'`, `press Control+a`, `type '2'`, and `click --role button --name 'Apply date'`. The route becomes `worldTick=20001440` and the button reads "Viewed date Bloomtide 2, Year 42 · 21:20".
- **Invalid date.** Reopen and set "Viewed date year" to `0` the same way. An alert reads "Year must be 1 or later." and Apply date stays disabled. `press Escape`, or a click outside the editor, closes it without applying the draft; Escape also returns focus to the date button.
- **Shortcuts.** Each closes the editor at once. "Return to story present" sets 20000000. "Start of year" from Bloomtide 2 gives 19837440, "Dawnmere 1, Year 42 · 00:00". "Next year" adds 483840 ticks.
- **Route.** `click --role button --name 'Timeline'`. The route keeps the same `worldTick`.
- **Scrubber.** `click --role button --name 'Expand timeline scrubber'` and `wait --role region --name 'Timeline ruler'`. The aside's `data-state` is `expanded`, with slider "Scrub visible dates", event and record lanes, "Timeline category", and the viewport buttons. `click --role slider --name 'Scrub visible dates'` moves viewed time to the clicked date, and `press ArrowRight` adds one tick. "Pan timeline earlier", "Zoom timeline in", and "Center timeline on viewed date" change the slider's `min` and `max` while the route's `worldTick` stays put.
- **Collapse.** `click --role button --name 'Collapse timeline scrubber'` and `wait --role region --name 'Timeline ruler' --gone`. With focus inside the expanded dock, `press Escape` also collapses it.
- **Dated change.** `shot --route '#/people/1?worldTick=20000000'`, open the date editor and `wait` for its group, then `click --role button --name 'Next year'` (route `worldTick=20483840`). `click --role button --name 'Edit' --nth 0`, `click --role textbox --name 'Current situation'`, `press Control+a`, `type 'Verification survey update'`, and `click --role button --name 'Change from this time'`. The form closes and the profile shows the new Current situation; "Return to story present" shows the old one. `eval` of `window.appHost.invoke('records.character.get', {id:1}, {at:20000000})` and `{at:20483840}` returns the two values in `output.situation`.
- **Reload.** At `worldTick=20483840`, `reload`. A `window` marker set with `eval` is gone afterwards, the route keeps `worldTick=20483840`, the date button reads "Viewed date Bloomtide 1, Year 43 · 21:20", Current situation reads "Verification survey update", and `getTimelineBounds()` still gives `storyPresentTick` 20000000. "Return to story present" then shows "Active on the Starhold survey".

## Gotchas

- After Save, a record form stays in edit mode. Use "Cancel" to return to the profile.
- The date editor opens after `click` returns. `wait --role group --name 'Viewed date'` before a shortcut, or the click misses.
- Story present is set in Settings. See [settings-world-time.md](settings-world-time.md).

## Source and tests

- `src/renderer/components/BottomTemporalScrubber.tsx`, `TemporalInput.tsx`, `temporal/TemporalControls.tsx`, `app-shell/AppShellTemporalDock.tsx`, and `src/renderer/lib/worldTime.ts`.
- `src/renderer/features/settings/useTemporalReadController.ts`, `src/renderer/features/shared/recordPage.ts` (dated save), `src/shared/calendar.ts`.
- `npm test -- src/renderer/components/BottomTemporalScrubber.test.tsx src/renderer/components/TemporalInput.test.tsx src/renderer/components/temporal/TemporalControls.test.tsx src/renderer/components/AppShell.worldTime.test.tsx`.
