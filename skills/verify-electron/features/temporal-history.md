# Record world history

A relationship, a map, and a map overlay keep the legacy editable history. It lists every recorded change with its date and marks the entry in effect at the viewed date. "Revise entry" corrects what an entry recorded or when it took effect, without rewriting the editorial history. Framework record pages, such as a place or a person, show a read-only "World history" with no Revise entry.

## Sub-features

- `history-list` lists a subject's dated entries and marks the current one.
- `history-cancel` discards an unfinished correction.
- `history-revise` saves a corrected value at the same date.
- `history-date` moves an entry to an unknown date.
- `history-remove` removes a mistaken entry after a confirm.

## How to get to it (user POV)

- On a record page's Relationships panel, a row's "History" button, or "History" in its person link's context menu, opens region "Relationship history" under that row.
- In Maps, "Map tools" then the disclosure "Map settings" holds the disclosure "Map history". With the Select tool, a selected overlay's panel ends in the disclosure "History".
- Each entry has "Revise entry", which opens "Effective date", the editable fields, "Save revision", "Cancel", and "Remove entry".

## Driving it with verify-electron

Preconditions:

- The fixture is Mara Venn's relationship with Sera Nhal (relationship id 2), one entry "Dawnmere 22, Year 40" on a fresh sample. Open Mara with `click --role button --name 'People'` and `click --role link --name 'Mara Venn'`.
- Make the entry to correct through the UI: `click --role link --name 'Sera Nhal' --button right`, `click --role menuitem --name 'Edit relationship'`, `click --role textbox --name 'Relationship state'`, `press Control+a`, `type 'Verification history marker'`, and `click --role button --name 'Save'`.
- The read-only view is `eval '(async () => JSON.stringify((await window.appHost.invoke("listTemporalHistory", {subjectType:"relationship",subjectId:2}, {})).output))()'`. It now returns point 2 at 18900000 and point 18 at 20000000 with `assertedRevisionId` 189 and the changed `label`. The value in effect is `(await window.appHost.invoke("listWorldRelationships", {entityType:"character",entityId:1,asOfTick:20000000}, {})).output.find(r => r.id === 2).label`.

- **List.** `click --role link --name 'Sera Nhal' --button right` and `click --role menuitem --name 'History'`. `snapshot --role region --name 'Relationship history'` shows "Dawnmere 22, Year 40" with every original field (Relationship kind "Spouse of", Label "Spouses and research partners", Kinship "Legal", and so on), then "Bloomtide 1, Year 42" with Label "Verification history marker". Only that last `listitem` is `[current=date]`.
- **Cancel.** `click --role button --name 'Revise entry' --nth 1` opens the marker's editor: combobox "Effective date" ("Exact date"), textboxes "Label", "Summary", "Family cultural context" and "Evidence summary", comboboxes "Kinship", "Visibility" and "Assertion", and a disabled "Save revision". `click --role textbox --name 'Label'`, `press Control+a`, `type 'Discard this correction'`, and `click --role button --name 'Cancel'`. The row still reads "Verification history marker", and the history query never contains the discarded text.
- **Remove, cancelled.** Open the same editor and `click --role button --name 'Remove entry' --dismiss`. `dialogs` lists the confirm "Remove this recorded change? Later independent changes will remain." answered `false`, and the query still returns two points. `click --role button --name 'Cancel'`.
- **Revise.** Open the same editor, replace Label with `Corrected verification marker`, and `click --role button --name 'Save revision'`. The editor closes, and the row and Sera's line read "Corrected verification marker". The label in effect is the correction at 20000000 and "Spouses and research partners" at 19999999. The query returns the marker as point 19, and with `editorialRevisionId:189` still point 18 "Verification history marker".
- **Unknown date.** Open the same editor, `click --role combobox --name 'Effective date'`, `press Home`, `press Enter` (value "Unknown"), and `click --role button --name 'Save revision'`. The row reads "Unknown", the query shows point 20 with `authoredDate` `{kind:"unknown"}`, no `listitem` is `[current=date]`, and Sera's line and the label in effect go back to "Spouses and research partners".
- **Remove.** Open the same editor and `click --role button --name 'Remove entry'`. The confirm is answered `true`. Relationship history keeps only "Dawnmere 22, Year 40", now `[current=date]`. The query returns point 2 alone, and `(await window.appHost.invoke("listEditorialRevisions", {limit:1}, {})).output.items[0].commandKey` is `temporal.remove`.

## Gotchas

- `listTemporalHistory` accepts only `relationship`, `map` and `mapOverlay`. Any other `subjectType`, such as `location`, is refused with "Please correct the highlighted fields."
- Every saved correction gets a new `pointId`. Re-read it instead of reusing the old one.
- "Revise entry" and "Cancel" repeat across rows and editors. Keep one history and one editor open, and target the marker with `--nth 1`.
- Saving or closing an editor can scroll the page away from the history. `hover --role heading --name 'Relationship history'` before a `shot`.
- The editor names fields without the list's labels: "Family cultural context" and "Evidence summary" in the editor are "Cultural context" and "Evidence" in the list.

## Source and tests

- `src/renderer/features/temporal-history/TemporalHistoryEditor.tsx`, `TemporalHistoryDetails.tsx` (map and overlay disclosures), `temporalHistoryQueries.ts`, `describeHistoryValue.ts`.
- Callers `src/renderer/features/relationships/RelationshipsView.tsx` and `src/renderer/features/maps/MapSidebar.tsx`. The read-only page section is `src/framework/ui/pages/WorldHistory.tsx`.
- `src/renderer/components/AuthoredDateInput.tsx`, `src/shared/temporal-history.ts`, `src/backend/services/temporal-history-service.ts`.
- `npm test -- src/renderer/features/temporal-history/TemporalHistoryEditor.test.tsx src/backend/services/temporal-history-service.test.ts`.
