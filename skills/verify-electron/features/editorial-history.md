# Editorial history and undo

Every saved edit becomes an editorial revision. Settings, Change history lists revisions newest first and shows a selected revision's detail and the records it touched. Only the current head revision can be undone, and undo records a new revision so the undone one stays readable.

## Sub-features

- `history-list` lists revisions newest first, with the head marked "Current".
- `history-detail` shows a selected revision and links to the record it changed.
- `history-ineligible` disables Undo with a reason for older revisions and the baseline.
- `history-undo` undoes the head revision as a new `editorial.undo` revision.

## How to get to it (user POV)

- Settings, then the top-bar tab "Change history". Route `#/settings?tab=history`.
- A link may add `&revision=<id>` to open with that revision selected. Clicking a row selects it without changing the route.

## Driving it with verify-electron

Preconditions:

- A fresh `start`, then `doctor`. Commands below are arguments to `node scripts/verify-electron.mjs`. The sample's own revisions end at #169.
- Make a head revision through the UI. `shot --route '#/places?worldTick=20000000'`, `click --role button --name 'Add place'`, `click --role textbox --name 'Name'`, `type 'Verify Harbor'`, and `click --role button --name 'Save'`. The route becomes `#/places/12`. `eval 'window.app.listEditorialRevisions({limit:1})'` returns `items[0]` id 170 with `commandKey` `location.create`.

- **List.** `click --role button --name 'Settings'` and `click --role tab --name 'Change history'`. Region "Revisions" reads "50 loaded" above list "Editorial revisions" and a "Load older" button. Row names carry the local time, such as `#170 · Location Create Current Oct 2, 2026, 1:45 PM`. Copy the exact name from `snapshot`.
- **Detail.** The head is selected (`aria-current="true"`). Region "#170 · Location Create" shows an enabled "Undo", "Create place.", Actor "User", Parent revision "#169", "This revision can be restored as a new revision.", and region "Revision subjects" with link "Verify Harbor". `click --role link --name 'Verify Harbor'` opens `#/places/12`.
- **Ineligible.** Click the `#169 · Authoring Note Create …` row. The route stays `#/settings?tab=history`, "Undo" is disabled, and the reason reads "Only the current revision can be undone." `shot --route '#/settings?tab=history&revision=1'` selects "#1 · Project Baseline", whose disabled Undo explains "The baseline revision cannot be undone."
- **Undo, cancelled.** Select #170 again and `click --role button --name 'Undo' --dismiss`. `dialogs` lists the confirm "Undo revision #170? The app will create a new revision restoring its previous assertions. Existing history will remain unchanged." answered `false`. `listEditorialRevisions({limit:1}).items[0]` is still #170 and `listLocations({search:'Verify Harbor'})` still has one entry.
- **Undo.** Repeat without `--dismiss`. Alert "Undo revision created" reads "Created revision #171 undoing revision #170." The new head `#171 · Editorial Undo` is selected with subject "Verify Harbor", "Location · Removed". `listEditorialRevisions({limit:2}).items` gives `[171, "editorial.undo"]` then `[170, "location.create"]`, and `listLocations({search:'Verify Harbor'})` is empty.

## Gotchas

- Do not replace `window.confirm` with `eval`. That skips the action under test. The driver answers it, so read `dialogs` instead.
- Selection is local state. Opening `#/settings?tab=history` without `revision` can keep the row clicked earlier instead of the head. Click the row you need.
- Head status alone is not enough to undo. `src/backend/services/editorial-undo-service.ts` holds the other eligibility rules.

## Source and tests

- `src/renderer/features/editorial-history/EditorialHistoryPage.tsx`, `editorialHistoryQueries.ts`, `src/renderer/features/settings/SettingsPage.tsx` (tab).
- `src/backend/services/editorial-history-service.ts`, `editorial-undo-service.ts`, `src/shared/editorial-history.ts`.
- `npm test -- src/renderer/features/editorial-history/EditorialHistoryPage.test.tsx`.
- `npm test -- src/backend/services/editorial-undo-service.test.ts`.
