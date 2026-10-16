# Story present and the project calendar

Settings, General, "World time" saves the project's story present, the default date that pages open at. The save is quiet: it adds no Change history line, so the Undo of the edit before it stays enabled. Below it, "Project calendar" edits the calendar's name, time units, periods, weekdays, and eras, previews the story-present date in the draft, and saves or discards the draft. A calendar save is a Change history revision that cannot be undone. A draft keeps the calendar revision it started from, so a save after another window's save is refused instead of overwriting it. Neither save moves the viewed date.

## Sub-features

- `present-draft` drafts a story present by typed date or shortcut without storing it.
- `present-save` saves story present quietly and leaves viewed time alone.
- `calendar-save` saves a calendar name or structure change as a new revision.
- `calendar-preview` shows the story present in the draft calendar beside the saved one.
- `calendar-discard` throws away an unsaved draft.
- `calendar-validation` blocks saving an invalid draft.
- `calendar-stale` refuses a draft another window's save made stale, with Reload and Keep editing.

## How to get to it (user POV)

- The "Settings" activity-bar button opens General (tab "General" in the top bar). Route `#/settings`.
- The "Story present" group and "Save story present" sit under heading "World time".
- The "Project calendar" button sits below and opens the editor (`[expanded]`). Its text also shows the calendar name and counts, plus "Unsaved changes" while dirty, and that text is its accessible description, not part of its name.

## Driving it with verify-electron

Preconditions:

- Run `doctor` after `start`.
- Read-only views are `eval '(async () => (await window.appHost.invoke("getTimelineBounds", undefined, {})).output)()'` (`storyPresentTick` 20000000) and `eval '(async () => (await window.appHost.invoke("getCalendarSettings", undefined, {})).output)()'` (`revision` 1, `config.name` "World Calendar", 12 periods of 28 days, 7 weekdays, 1 era).

- **Draft.** `click --role button --name 'Settings'`, `click --role spinbutton --name 'Story present year'`, `press Control+a`, `type '43'`, and `click --role button --name 'Apply date'`. The group's date reads "Bloomtide 1, Year 43 · 21:20", "Save story present" enables, and `storyPresentTick` is still 20000000.
- **Save.** Read the head first with `eval '(async () => (await window.appHost.invoke("framework:history.revisions", {limit:1}, {})).output.headRevisionId)()'`. `click --role button --name 'Save story present'`. The page says "Story present updated. Your viewed date did not move." `storyPresentTick` is 20483840, the route keeps `worldTick=20000000`, and the head id is unchanged.
- **Quiet save.** Change a record first (for example Mara Venn's summary) so it is the head, then save a new story present. `shot --route '#/settings?tab=history'` lists no story present line, the record change is still the newest revision, and its "Undo" is enabled.
- **Shortcuts.** "Start of year", "Next year", and "Use viewed date" each change only the draft. "Use viewed date" copies the footer's date; saving it restores 20000000.
- **Open calendar.** `click --role button --name 'Project calendar'`. Its description reads "World Calendar · 12 periods · 336 days · 7 weekdays". Textboxes "Calendar name", "Hours per day", and "Minutes per hour" appear, then regions "Periods", "Weekdays", and "Eras". Rows use names such as "Period 5 name" and "Weekday 1 short name". "Save calendar" is disabled.
- **Rename.** `click --role textbox --name 'Calendar name'`, `press Control+a`, `type 'Verification calendar'`. "Discard changes" appears. `click --role button --name 'Save calendar'`. The page says "Calendar revision 2 saved. Existing story dates and your viewed date did not move." `getCalendarSettings()` returns revision 2 and the new name, and `storyPresentTick` is unchanged.
- **Structure.** `click --role button --name 'Add weekday'` adds "Weekday 8 name" with value "Day 8" and short "D8". Save, and `config.weekdays` has 8 entries at the next revision. "Add period" adds "Period 13" (28 days, so the header reads "364 days a year") and "Add era" adds "Era 2". Discard drops both.
- **Preview.** Set "Period 5 name" to "Blossom". The description list shows "Story present" as "Blossom 1, Year 42 · 21:20" and "Saved calendar" as "Bloomtide 1, Year 42 · 21:20". `config.periods[4].name` is still "Bloomtide".
- **Discard.** `click --role button --name 'Discard changes'`. "Period 5 name" reads "Bloomtide" again, "Unsaved changes" leaves the summary, and the revision is unchanged.
- **Stale draft.** Rename the calendar to "Glass Coast" without saving. Save another name as a second window would, with `eval '(async () => { const { revision, config } = (await window.appHost.invoke("getCalendarSettings", undefined, {})).output; return (await window.appHost.invoke("framework:calendar.set", { expectedRevision: revision, config: { ...config, name: "Harbor Reckoning" } }, { at: 0 })).output.revision; })()'`. The draft keeps "Glass Coast". `click --role button --name 'Save calendar'`: the page says "Another window changed the calendar." with "Reload" and "Keep editing", and `getCalendarSettings()` still names "Harbor Reckoning". "Keep editing" keeps the draft, and Save is refused again. "Reload" drops the draft and the editor shows "Harbor Reckoning".
- **Validation.** `click --role textbox --name 'Hours per day'`, `press Control+a`, `press Backspace`. The field is marked invalid with "Hours per day must be a whole number." and "Save calendar" is disabled. Discard restores 24.

## Gotchas

- Story-present date fields are spinbuttons. Calendar unit and row fields are textboxes.
- A typed date needs "Apply date" before "Save story present". The shortcuts update the draft directly.
- A save whose reply is lost after the host committed it shows the failure with "Retry", which sends the same request again and shows the first answer.
- Saving story present changes where pages open by default. A route with an explicit `worldTick` keeps its viewed date.

## Source and tests

- `src/features/settings/ui/worldTimeDrafts.ts` (the drafts, held in the view above the tabs), `storyPresentEditor.tsx`, `calendarEditor.tsx`, `calendarRows.tsx`, and `calendarDraft.ts`.
- The framework's `TickInput`, `useCalendar`, `previewCalendar`, `storyPresent.set` and `calendar.set` (`src/framework/host/collectors/project-settings.ts`), and `src/shared/calendar.ts`.
- `npm test -- src/renderer/features/settings/SettingsView.worldTime.test.tsx src/features/settings/ui/calendarDraft.test.ts src/renderer/lib/settingsPremise.test.tsx`.
