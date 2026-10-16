# Record world history

A record's world history lists every recorded change with its date and marks the entry in effect at the viewed date. Two editors let a writer revise an entry without rewriting the editorial history. A relationship is the one framework kind whose "World history" section is editable: each entry has "Revise entry", which corrects what the entry recorded or when it took effect, or removes it. Maps and map overlays keep the legacy editor, which also offers an unknown date. Every other framework record page, such as a place or a person, shows a read-only "World history" with no Revise entry.

## Sub-features

- `history-list` lists a subject's dated entries and marks the current one.
- `history-cancel` discards an unfinished correction.
- `history-revise` saves a corrected value at the same date.
- `history-date` moves an entry to another date; only the legacy editor offers Unknown.
- `history-remove` removes a mistaken entry after a confirm.

## How to get to it (user POV)

- A relationship's page, `#/relationships/<id>`, ends with `heading "World history"`. Reach it from the role link in a Relationships row, or from a relationship's button in the Graph's selected-element panel.
- In Maps, "Map tools" then the disclosure "Map settings" holds the disclosure "Map history". With the Select tool, a selected overlay's panel holds the disclosure "History".
- In both editors, "Revise entry" opens "Revise what was recorded at this date.", combobox "Effective date", the editable fields, "Save revision" (disabled until something changes), "Cancel", and "Remove entry".
- The relationship editor's "Effective date" offers Exact, Between, Before, and After, with no Relative mode because a relationship takes no relative date, and its fields are Label, Summary, Evidence, Cultural context, Kinship, Visibility, and Assertion. "Remove entry" opens an in-app dialog.
- The legacy editor's "Effective date" offers Unknown, Exact date, and Between dates, with the shortcuts "Keep current date", "Start of year", and "Next year". "Remove entry" asks a native confirm.

## Driving it with verify-electron

Preconditions:

- The relationship fixture is Mara Venn's relationship with Sera Nhal, `#/relationships/2`, with one entry "Dawnmere 22, Year 40 · 00:00" on a fresh sample.
- Make the relationship entry to revise: `shot --route '#/relationships/2?worldTick=20000000'`, `click --role button --name 'Edit'`, `click --role textbox --name 'Label'`, `press Control+a`, `type 'Spouses and survey partners'`, and `click --role button --name 'Change from this time'`.
- The relationship history read is `eval '(async () => (await window.appHost.invoke("framework:history", { record: { kind: "relationship", id: 2 } }, {})).output.map((e) => [e.key, JSON.stringify(e.date), e.fields.map((f) => f.label + "=" + f.value).join("; ")]))()'`. It now returns entry 1 at tick 18900000 with every field and entry 2 at 20000000 with only "Label=Spouses and survey partners". `framework:states` with the same input lists each entry's editable values. The value in effect is `(await window.appHost.invoke("records.relationship.get", { id: 2 }, { at: 20000000 })).output.title`.
- For the legacy editor, open Glasswake Expedition Logistics with `shot --route '#/maps/4?worldTick=20000000'`. The overlay fixture is Ashfold, overlay `13`, with one entry "Starfrost 3, Year 41".
- Before the overlay steps, make the overlay entry to revise: `click --role button --name 'Map tools'`, `click --role button --name 'Select'`, `click --role button --name 'Ashfold' --nth 0`, `click --role textbox --name 'Label'`, `press Control+a`, `type 'Verification history marker'`, and `click --role button --name 'Save overlay'`.
- The overlay history read is `eval '(async () => (await window.appHost.invoke("listTemporalHistory", {subjectType:"mapOverlay",subjectId:13}, {})).output.map((p) => [p.pointId, JSON.stringify(p.authoredDate), p.fields.find((f) => f.key === "label")?.value]))()'`. It now returns point 13 at 19800000 and point 26 at 20000000 with the marker. For the map itself use `{subjectType:"map",subjectId:4}`.

- **List.** `snapshot` shows "World history" with "Dawnmere 22, Year 40 · 00:00" (Label, Source, Target, Relationship kind, Summary, Evidence, Cultural context, Assertion, Kinship, Visibility, Status, and Cause "Charter Renewal") and "Bloomtide 1, Year 42 · 21:20" with Label alone. Only that last `listitem` is `[current=date]`, and each entry has `button "Revise entry"`.
- **Cancel.** `click --role button --name 'Revise entry' --nth 1` opens the editor under the second entry with group "Effective date" ("Exact", Bloomtide 1, Year 42, 21:20) and every editable field at its value in effect. `click --role textbox --name 'Label'`, `press Control+a`, `type 'Discard this correction'`, and `click --role button --name 'Cancel'`. The history read never contains the discarded text.
- **Remove, cancelled.** Open the same editor and `click --role button --name 'Remove entry'`. `dialog "Remove this recorded change? Later independent changes will remain."` offers "Cancel" and "Remove". `click --role button --name 'Cancel'` closes it, the editor stays open, and the read still returns two entries.
- **Revise.** In the editor, replace Label with `Corrected survey partners` and `click --role button --name 'Save revision'`. The editor closes. Entry 2 reads "Label=Corrected survey partners", the title is the correction at 20000000 and "Spouses and research partners" at 19999999, and `db 'select command_key from editorial_revisions order by id desc limit 1'` gives `records.relationship.reviseState`.
- **Move the date.** Open the same editor, `click --role spinbutton --name 'Effective date day'`, `press Control+a`, `type '2'`, and Save revision. Entry 2 moves to tick 20001440 and reads "Bloomtide 2, Year 42 · 21:20", the first entry becomes `[current=date]`, and the title at 20000000 and the page heading go back to "Spouses and research partners".
- **Remove.** Open the same editor, `click --role button --name 'Remove entry'`, and `click --role button --name 'Remove'`. World history keeps only "Dawnmere 22, Year 40 · 00:00", now `[current=date]`, the read returns entry 1 alone, and the last command key is `records.relationship.removeState`.
- **Overlay list.** `click --role DisclosureTriangle --name 'History'`. `region "History"` shows "Starfrost 3, Year 41" with Existence, Label "Ashfold", and Content "Changed", then "Bloomtide 1, Year 42" with Label "Verification history marker", the only `[current=date]` entry.
- **Overlay revise.** `click --role button --name 'Revise entry' --nth 1`, `click --role textbox --name 'Label' --nth 1` (the editor's, after Edit place's), `press Control+a`, `type 'Corrected verification marker'`, and `click --role button --name 'Save revision'`. The read returns the correction as point 27, and with `editorialRevisionId` set to point 26's `assertedRevisionId` still point 26 "Verification history marker".
- **Unknown date.** Open the same editor, `select --role combobox --name 'Effective date' --option 'Unknown'`, and Save revision. The entry reads "Unknown", the read gives it `authoredDate` `{kind:"unknown"}`, no `listitem` is `[current=date]`, and `getMapContext({mapId:4,asOfTick:20000000})` gives overlay 13 the label "Ashfold" again.
- **Overlay remove.** Open the same editor and `click --role button --name 'Remove entry'`. `dialogs` lists the confirm "Remove this recorded change? Later independent changes will remain." answered `true`. History keeps only "Starfrost 3, Year 41", now `[current=date]`, the read returns point 13 alone, and the last command key is `temporal.remove`. With `--dismiss` the confirm is answered `false` and nothing changes.
- **Map history.** `click --role button --name 'Close selection'`, `click --role DisclosureTriangle --name 'Map settings'`, and `click --role DisclosureTriangle --name 'Map history'`. `region "Map history"` lists "Dawnmere 1, Year 1" with Existence, Name, Image width, Image height, and Placement "Changed". `click --role button --name 'Revise entry'` offers only the textbox "Name". Saving `Glasswake Logistics` gives `listMaps({asOfTick:20000000})` that name and the command key `temporal.revise`. Moving that entry to Unknown is refused with the alert "The parent map is unavailable while its detail map is active on Dawnmere 16, …", because map 6 is a detail of map 4.

## Gotchas

- `listTemporalHistory` accepts only `map` and `mapOverlay`. A `relationship` subject is refused with "Please correct the highlighted fields." on `subjectType`; read relationship history with `framework:history`.
- The legacy editor gives every saved correction a new `pointId`; re-read it instead of reusing the old one. A relationship entry keeps its `key`.
- "Revise entry" and "Cancel" repeat across entries and editors. Keep one editor open and target the entry with `--nth`. On a map, close the overlay selection before revising Map history, and collapse Map history before revising an overlay, so only one list of entries shows.
- The relationship editor shows every editable field at its value in effect, even on an entry that recorded only Label.
- The relationship remove dialog hides the editor behind it, so `click --role button --name 'Cancel'` and `--name 'Remove'` each match the dialog's button.

## Source and tests

- Relationship history: `src/framework/ui/pages/WorldHistory.tsx`, `HistoryStateEditor.tsx`, `stateDraft.ts`; `src/framework/host/collectors/history.ts`, `world-history.ts`; `src/framework/host/records/correct-point.ts`. The kind opts in with `history.edit` in `src/features/relationship/contract.ts`.
- Legacy history: `src/renderer/features/temporal-history/TemporalHistoryEditor.tsx`, `TemporalHistoryDetails.tsx` (map and overlay disclosures), `temporalHistoryQueries.ts`, `describeHistoryValue.ts`, called from `src/renderer/features/maps/MapSidebar.tsx`. `src/renderer/components/AuthoredDateInput.tsx`, `src/shared/temporal-history.ts`, `src/backend/services/temporal-history-service.ts`.
- `npm test -- src/renderer/lib/frameworkRecordHistory.test.tsx src/framework/host/collectors/history-states.test.ts src/framework/host/collectors/world-history.test.ts src/renderer/features/temporal-history/TemporalHistoryEditor.test.tsx src/backend/services/temporal-history-service.test.ts`.
