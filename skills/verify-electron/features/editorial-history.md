# Editorial history and undo

Every saved edit becomes an editorial revision. Settings, Change history lists revisions newest first and shows a selected revision's detail and the records it touched. Only the current head revision can be undone, and undo records a new revision, so the undone one stays readable. Saving the story present records no revision, so it never adds a line here.

## Sub-features

- `history-list` lists revisions newest first, with the head marked "Current", 50 a page.
- `history-detail` shows a selected revision and links to the record it changed.
- `history-ineligible` disables Undo with a reason for older revisions and the baseline.
- `history-undo` asks in a Dialog, then undoes the head revision as a new revision.

## How to get to it (user POV)

- Settings, then the top-bar tab "Change history". Route `#/settings?tab=history`.
- A link may add `&revision=<id>` to open with that revision selected. Clicking a row selects it without changing the route.
- A record's History link adds `&subjectType=<kind>&subjectId=<id>`, which lists only that record's revisions under "Showing saved changes for <name>."

## Driving it with verify-electron

Preconditions:

- Read revision ids live instead of assuming them. `eval '(async () => (await window.appHost.invoke("framework:history.revisions", {limit:1}, {})).output.items[0].id)()'` returns the head id `<h>`. On a fresh sample it is #187, and the last authoring note is #170, but any earlier session or sample change moves both.
- Make a head revision through the UI: `shot --route '#/places?worldTick=20000000'`, `click --role button --name 'Add place'`, `click --role textbox --name 'Name'`, `type 'Verify Harbor'`, and `click --role button --name 'Save'`. The route becomes `#/places/12`. The head read now returns `<n>`, which is `<h> + 1`, with `commandKey` `records.location.create` and description "Created place Verify Harbor".

- **List.** `click --role button --name 'Settings'` and `click --role tab --name 'Change history'`. Region "Revisions" holds list "Editorial revisions" and, below it, "50 loaded" and a "Load older" button. Row names carry the local time, such as `#<n> · Created place Verify Harbor Current Oct 13, 2026, 8:33 PM`, so copy the exact name from `snapshot`. "Load older" adds the next 50 rows and the count reads "100 loaded".
- **Detail.** The head is selected (`aria-current="true"`). The region named by its title, "#<n> · Created place Verify Harbor", shows an enabled "Undo", Actor "User", Parent revision "#<h>", World context as a calendar date without a clock, "This revision can be restored as a new revision.", "Subjects · 1", and region "Revision subjects" with link "Verify Harbor" over "Place · Created". `click --role link --name 'Verify Harbor'` opens `#/places/12`.
- **Ineligible.** Click the `#<h> · …` row. The route stays `#/settings?tab=history`, "Undo" is disabled, and the reason reads "Only the current revision can be undone." `shot --route '#/settings?tab=history&revision=1'` selects "#1 · Project Baseline", whose disabled Undo explains "The baseline revision cannot be undone.", with "Subjects · 0" and "No subjects."
- **Undo, cancelled.** Select #<n> again and `click --role button --name 'Undo'`. Dialog "Undo revision #<n>? The app will create a new revision restoring its previous assertions. Existing history will remain unchanged." offers "Cancel" and "Undo revision". `click --role button --name 'Cancel'` closes it. The head read still returns #<n>, and `records.location.list` still has Verify Harbor.
- **Undo.** `click --role button --name 'Undo'` and `click --role button --name 'Undo revision'`. Alert "Undo revision created" reads "Created revision #<n+1> undoing revision #<n>." The new head #<n+1> is selected with subject "Verify Harbor", "Place · Removed". `eval '(async () => (await window.appHost.invoke("framework:history.revisions", {limit:2}, {})).output.items.map((r) => [r.id, r.commandKey]))()'` gives `[<n+1>, "editorial.undo"]` then `[<n>, "records.location.create"]`, and Verify Harbor is gone from `records.location.list`.
- **Story present stays quiet.** On General, save a new story present, then return to Change history. The head is still #<n+1>, and its Undo is still enabled.

## Gotchas

- Undo asks in the app's own Dialog, not `window.confirm`, so `dialogs` lists nothing. Answer it with its buttons.
- Selection is local state. Opening `#/settings?tab=history` without `revision` can keep the row clicked earlier instead of the head. Click the row you need.
- While an older page loads, or reloads after another write moved the head, the list's foot shows a disabled "Loading…" in place of "Load older".
- Head status alone is not enough to undo. `src/backend/services/editorial-undo-service.ts` holds the other eligibility rules.

## Source and tests

- `src/features/settings/ui/history/HistoryTab.tsx`, `pages.tsx`, `detail.tsx`, `words.tsx`, and the tab bar in `src/features/settings/ui/bar.ts`.
- `src/backend/services/editorial-history-service.ts`, `editorial-undo-service.ts`, `src/shared/editorial-history.ts`.
- `npm test -- src/renderer/features/settings/SettingsView.history.test.tsx`.
- `npm test -- src/backend/services/editorial-undo-service.test.ts`.
