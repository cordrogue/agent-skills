# Story present and the project calendar

Settings, General, "World time" saves the project's story present, the default date that pages open at. Below it, "Project calendar" edits the calendar's name, time units, periods, weekdays, and eras, previews the story-present date in the draft, and saves or discards the draft. Neither save moves the viewed date.

## Sub-features

- `present-draft` drafts a story present by typed date or shortcut without storing it.
- `present-save` saves story present and leaves viewed time alone.
- `calendar-save` saves a calendar name or structure change as a new revision.
- `calendar-preview` shows the story present in the draft calendar beside the saved one.
- `calendar-discard` throws away an unsaved draft.
- `calendar-validation` blocks saving an invalid draft.

## How to get to it (user POV)

- The "Settings" activity-bar button opens General (tab "General" in the top bar). Route `#/settings`.
- The "Story present" group and "Save story present" sit under heading "World time".
- The "Project calendar" disclosure sits below. Its summary also shows the calendar name and counts, plus "Unsaved changes" while dirty.

## Driving it with verify-electron

Preconditions:

- A fresh `start`, then `doctor`. Commands below are arguments to `node scripts/verify-electron.mjs`.
- Read-only views are `eval 'window.app.getTimelineBounds()'` (`storyPresentTick` 20000000) and `eval 'window.app.getCalendarSettings()'` (`revision` 1, `config.name` "World Calendar", 12 periods of 28 days, 7 weekdays, 1 era).

- **Draft.** `click --role button --name 'Settings'`. `click --role spinbutton --name 'Story present year'`, `press Control+a`, `type '43'`, and `click --role button --name 'Apply date'`. The group's date reads "Bloomtide 1, Year 43 · 21:20", "Save story present" enables, and `storyPresentTick` is still 20000000.
- **Save.** `click --role button --name 'Save story present'`. The page says "Story present updated. Your viewed date did not move." `storyPresentTick` is 20483840 and the route keeps `worldTick=20000000`.
- **Shortcuts.** "Start of year", "Next year", and "Use viewed date" each change only the draft. "Use viewed date" copies the footer's date. Saving it restores 20000000.
- **Open calendar.** `click --role DisclosureTriangle --name 'Project calendarWorld Calendar · 12 periods · 336 days · 7 weekdays'`. Textboxes "Calendar name", "Hours per day", and "Minutes per hour" appear, then regions "Periods", "Weekdays", and "Eras". Rows use names such as "Period 5 name" and "Weekday 1 short name". "Save calendar" is disabled.
- **Rename.** `click --role textbox --name 'Calendar name'`, `press Control+a`, `type 'Verification calendar'`. "Discard changes" appears. `click --role button --name 'Save calendar'`. The page says "Calendar revision 2 saved. Existing story dates and your viewed date did not move." `getCalendarSettings()` returns revision 2 and the new name, and `storyPresentTick` is unchanged.
- **Structure.** `click --role button --name 'Add weekday'` adds "Weekday 8 name" with value "Day 8" and short "D8". Save, and `config.weekdays` has 8 entries at the next revision. "Add period" adds "Period 13" (28 days, so the header reads "364 days a year") and "Add era" adds "Era 2". Discard drops both.
- **Preview.** Set "Period 5 name" to "Blossom". The description list shows "Story present" as "Blossom 1, Year 42 · 21:20" and "Saved calendar" as "Bloomtide 1, Year 42 · 21:20". `config.periods[4].name` is still "Bloomtide".
- **Discard.** `click --role button --name 'Discard changes'`. "Period 5 name" reads "Bloomtide" again, "Unsaved changes" leaves the summary, and the revision is unchanged.
- **Validation.** `click --role textbox --name 'Hours per day'`, `press Control+a`, `press Backspace`. The field is marked invalid with "Hours per day must be a whole number." and "Save calendar" is disabled. Discard restores 24.

## Gotchas

- Story-present date fields are spinbuttons. Calendar unit and row fields are textboxes.
- A typed date needs "Apply date" before "Save story present". The shortcuts update the draft directly.
- The disclosure's accessible name includes the calendar summary, so it changes after a rename or a weekday add. Take it from `snapshot`.
- Saving story present changes where pages open by default. A route with an explicit `worldTick` keeps its viewed date.

## Source and tests

- `src/renderer/features/settings/SettingsPage.tsx`, `WorldTimeSettings.tsx`, `WorldTimeSettingsEditors.tsx`, `ProjectCalendarEditor.tsx`, and `calendarDraft.ts`.
- `src/renderer/components/TemporalInput.tsx`, `src/shared/project-settings-ipc.ts`, `src/shared/calendar.ts`.
- `npm test -- src/renderer/features/settings/WorldTimeSettings.mutations.test.tsx src/renderer/features/settings/calendarDraft.test.ts`.
