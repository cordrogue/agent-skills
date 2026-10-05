# Record world history

A dated record lists every recorded change under "World history", and marks the entry in effect at the viewed date. "Revise entry" corrects what an entry recorded or when it took effect, without rewriting the editorial history. Characters also show location and note histories the same way.

## Sub-features

- `history-list` lists a record's dated entries and marks the current one.
- `history-related` opens Location history, Position history, and a character note's history.
- `history-cancel` discards an unfinished correction.
- `history-revise` saves a corrected value at the same date.
- `history-date` moves an entry to an unknown date.
- `history-remove` removes a mistaken entry after a confirm.

## How to get to it (user POV)

- Open a dated record and scroll below its details to region "World history". Each entry has "Revise entry", which opens "Save revision", "Cancel", and "Remove entry".
- Character pages add "Position history" and "Location history" disclosures.
- A character's "Notes" tab has the "All recorded notes" disclosure with "History: <note title>" buttons.

## Driving it with verify-electron

Preconditions:

- A fresh `start`, then `doctor`. Commands below are arguments to `node scripts/verify-electron.mjs`.
- Fixtures are "Mara Venn" (id 1) and "Tovan Ash" (id 4).
- Make the entry to correct through the UI. `shot --route '#/people/1?worldTick=20000000'`, `click --role button --name 'Add change'`, `click --role textbox --name 'Summary'`, `press Control+a`, `type 'Verification history marker'`, `click --role button --name 'Save'`, then `click --role button --name 'Cancel'` to leave the form.
- The read-only view is `eval 'window.app.listTemporalHistory({subjectType:"character",subjectId:1})'`. It now returns two points, the creation at 19000000 and the marker at 20000000 with `assertedRevisionId` 170 on a fresh sample.

- **List.** `snapshot --role region --name 'World history'` shows "Greengale 7, Year 40" with every original field, then "Bloomtide 1, Year 42" with Summary "Verification history marker". Only the last `li` has `aria-current="date"`.
- **Related.** `click --role DisclosureTriangle --name 'Location history'` opens region "Location history" with "Veyra-on-the-Tide". `click --role DisclosureTriangle --name 'Position history'` opens region "Position history", whose first entry is "Frostwane 2, Year 42". On `#/people/4?worldTick=20000000`, `click --role tab --name 'Notes'`, `click --role DisclosureTriangle --name 'All recorded notes'`, and `click --role button --name 'History: Scalded left hand'`. Region "Note history" lists "Rainreach 16, Year 42" with Kind "Condition".
- **Cancel.** `click 'section[aria-label="World history"] > ol > li:last-child button'` opens the last entry's editor. The editor offers "Effective date" and textboxes Name, Summary, Gender, and Notable traits. Type "Discard this correction" into Summary, then `click --role button --name 'Cancel'`. The row still reads "Verification history marker", and the history query never contains the discarded text.
- **Revise.** Open the same editor again, replace Summary with "Corrected verification marker", and `click --role button --name 'Save revision'`. The editor closes and the row shows the new text. `getCharacter({id:1,asOfTick:20000000}).record.summary` is the correction, `asOfTick:19999999` is still the original, and `listTemporalHistory` with `editorialRevisionId:170` still returns "Verification history marker".
- **Unknown date.** Open the same editor, `click --role combobox --name 'Effective date'`, `press Home`, `press Enter` (value "Unknown"), and `click --role button --name 'Save revision'`. The row reads "Unknown". The query shows `authoredDate.kind` `"unknown"`, and no row has `aria-current` any more.
- **Remove, cancelled.** On a fresh marker (before Revise), open the last entry's editor and `click --role button --name 'Remove entry' --dismiss`. `dialogs` lists the confirm "Remove this recorded change? Later independent changes will remain." answered `false`, and `listTemporalHistory` still returns both points.
- **Remove.** Repeat without `--dismiss`. World history keeps only "Greengale 7, Year 40", now `[current=date]`. `listTemporalHistory` returns the creation point alone, `getCharacter({id:1,asOfTick:20000000}).record.summary` is the original, and the head revision's `commandKey` is `temporal.remove`.

## Gotchas

- The correction form lists only editable text fields. Status and Role are not among them, so build the fixture on Summary.
- Every saved correction gets a new `pointId`. Re-read it instead of reusing the old one.
- The top-bar "History" button opens editorial Change history, not World history.

## Source and tests

- `src/renderer/features/shared/RecordPageView.tsx`, `WorldRecordContext.tsx`, `src/renderer/features/temporal-history/TemporalHistoryEditor.tsx`, `TemporalHistoryDetails.tsx`, `temporalHistoryQueries.ts`.
- `src/renderer/features/characters/CharacterNotesView.tsx`, `src/renderer/components/AuthoredDateInput.tsx`, `src/shared/temporal-history.ts`, `src/backend/services/temporal-history-service.ts`.
- `npm test -- src/renderer/features/temporal-history/TemporalHistoryEditor.test.tsx src/renderer/features/characters/CharacterNotesView.test.tsx src/backend/services/temporal-history-service.test.ts`.
