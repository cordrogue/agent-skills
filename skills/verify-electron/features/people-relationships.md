# Relationships between people

A relationship is a framework record that ties a source record to a target record. Every end's page, such as a person's, lists its relationships at the viewed date with the other end, its role from that end's side, and its label. A writer adds a relationship from either side, opens its own page to record a dated change, correct a value, end it, or remove it, and names custom roles on the relationship itself.

## Sub-features

- `relationship-browse` lists an end's relationships at the viewed date and toggles all recorded relationships.
- `relationship-create` adds a relationship with this record as the source or the target.
- `relationship-family` shows Cultural context, Kinship, Visibility, and Perspective only for Parent of, Sibling of, and Spouse of.
- `relationship-roles` saves a "Connected to" relationship with its own source and target role labels, and a blank label as its source role label.
- `relationship-change` records a dated change from the relationship's page.
- `relationship-correct` corrects a value without a new date.
- `relationship-end` ends a relationship or marks it separated from a date.
- `relationship-remove` removes a mistaken relationship after a confirm.
- `relationship-history` revises or removes a dated entry; [Record world history](temporal-history.md) drives it.

## How to get to it (user POV)

- Open a person at `#/people/<id>`. `heading "Relationships"` follows Continuity and precedes Scenes. Other framework kinds a relationship joins show the same section, such as Echo Reading at `#/powers/1` ("Sera Nhal · Connected to · Practices") and Veyran Tidecourt at `#/factions/1`.
- The section has `button "Add relationship"`, a menu with "This record is the source" and "This record is the target", and `button "All recorded relationships"`.
- Each row reads `link "<other end>"`, then `link "<role>"`, then the label when it differs from the role, then the status in parentheses, such as "(ended)", when the relationship is no longer present. The role link opens the relationship's page at `#/relationships/<id>`.
- The relationship's page toolbar has "Mark separated", "End", "More" (a menu with "Remove"), "Edit", and "History". History opens `#/settings?tab=history&subjectType=relationship&subjectId=<id>`.
- `#/relationships` lists every relationship. The sidebar has no entry for it; removing a relationship lands there.

## Driving it with verify-electron

Preconditions:

- Open Mara with `click --role button --name 'People'` and `click --role link --name 'Mara Venn'`.
- Fresh-sample ids are Mara `1`, Orin `2`, Sera `3`, Kesh `6`, and Oda Vell `8`. Mara's relationships are `1` (Orin, Father and daughter), `2` (Sera, Spouses and research partners), and `17` (Kesh, Rim guide). New relationships take `18`, then `19`.
- Read an end's relationships with `eval '(async () => (await window.appHost.invoke("records.relationship.edges", { record: { kind: "character", id: 1 } }, { at: 20000000 })).output.map((e) => [e.record.id, e.side, e.other.name, e.record.title, e.record.type]))()'`. Read one relationship with `records.relationship.get` and `{ id: <id> }` at a tick.

- **Browse.** `snapshot` shows rows "Kesh Ash · Student of · Rim guide", "Sera Nhal · Spouse of · Spouses and research partners", and "Captain Orin Venn · Child of · Father and daughter".
- **Create.** `click --role button --name 'Add relationship'` opens `menu "Add relationship"`. `click --role menuitem --name 'This record is the source'` routes to `#/relationships?new=…` with heading "New relationship" and `combobox "Source"` set to "Mara Venn". `click --role textbox --name 'Label'`, `type 'Charter allies'`, `click --role combobox --name 'Target'`, `type 'Oda'`, `click --role option --name 'Oda Vell Character'`, keep "Relationship kind" at "Ally of", and `click --role button --name 'Save'`. The route is `#/relationships/18` with heading "Charter allies", and the edges read starts with `[18, "source", "Oda Vell", "Charter allies", "ally"]`.
- **Other end.** On the relationship's page, `click --role link --name 'Oda Vell'`. `#/people/8` lists "Mara Venn · Ally of · Charter allies".
- **Toggle.** Run `shot --route '#/people/1?worldTick=19999999'`. Charter allies begins at 20000000, so the rows hold only Kesh, Sera, and Orin. `click --role button --name 'All recorded relationships'` turns it into `button "View selected date" [pressed]`, shows the text "Recorded history, including undated and future entries.", and adds "Oda Vell · Ally of · Charter allies". Click "View selected date" to return.
- **Family fields.** Run `shot --route '#/people/1?worldTick=20000000'`, `click --role button --name 'Add relationship'`, and `click --role menuitem --name 'This record is the target'`. The form shows `combobox "Target"` set to "Mara Venn" and no Kinship. `select --role combobox --name 'Relationship kind' --option 'Spouse of'` adds textbox "Cultural context" and comboboxes "Kinship" (Unspecified), "Visibility" (Open), and "Perspective". `select --role combobox --name 'Kinship' --option 'Legal'`.
- **Custom roles.** In the same form, `select --role combobox --name 'Relationship kind' --option 'Connected to'` opens `dialog "Discard the family details?"` with buttons "Cancel" and "Discard". `click --role button --name 'Cancel'` keeps "Relationship kind" at "Spouse of" and Kinship at "Legal". Select "Connected to" again and `click --role button --name 'Discard'`, which hides the family fields. Leave "Label" blank, run `click --role combobox --name 'Source'`, `type 'Oda'`, and `click --role option --name 'Oda Vell Character'`, type `Charts with` into "Source role label" and `Charted with by` into "Target role label", and Save. "Label" stays empty up to the Save. The route is `#/relationships/19` with heading "Charts with", the source role label. Mara lists "Oda Vell · Charted with by", with no label because it repeats the source role, and the edges read gives Oda's entry title "Charts with", `type` "custom", `role` "Charts with", and `inverseRole` "Charted with by".
- **Change from a date.** On Mara, `click --role link --name 'Spouse of'` opens `#/relationships/2`. `click --role button --name 'Edit'` opens the form in place: "Label", Source and Target as links, "Relationship kind", the family fields (Cultural context "Veyran civic marriage", Kinship "Legal"), group "Began", group "Date" at the viewed date, "Note", and "Cause". The toolbar has a disabled "Change from this time", a disabled "Correct this value", and "Cancel". `click --role textbox --name 'Label'`, `press Control+a`, `type 'Spouses and survey partners'`, and `click --role button --name 'Change from this time'`. The heading becomes "Spouses and survey partners". `records.relationship.get` gives that title at 20000000 and "Spouses and research partners" at 19999999, with `culturalContext` "Veyran civic marriage" at both.
- **Correct a value.** `click --role button --name 'Edit'`, replace "Summary" with `Corrected household note.`, and `click --role button --name 'Correct this value'`. `summary` reads "Corrected household note." at both 20000000 and 19999999, because the correction rewrites the entry that set the summary, Dawnmere 22, Year 40. The toolbar's History lists it as "Corrected summary at Dawnmere 22, Year 40 · 00:00".
- **End.** Run `shot --route '#/relationships/18?worldTick=20000000'` and `click --role button --name 'End'` opens `dialog "End"` with group "Date" at the viewed date, comboboxes "End reason" and "Ended participant" (both None, Ended participant offering "None", "Mara Venn", and "Oda Vell"), textbox "Note", and button "End". Ending at the start date is refused with the dialog's alert "Charter allies starts at Bloomtide 1, Year 42 · 21:20 with End reason and Ended participant and Status set. Correct its start instead, or pick another date.", whatever the comboboxes hold. `select --role combobox --name 'End reason' --option 'Completed'`, `click --role spinbutton --name 'Date day'`, `press Control+a`, `type '2'`, and `click --role button --name 'End'`. `records.relationship.get` gives `status.key` "active" at 20000000 and "ended" with `endReason` "completed" at 20001440. At `#/people/1?worldTick=20001440` the row reads "Oda Vell · Ally of · Charter allies (ended)".
- **Mark separated.** Run `shot --route '#/relationships/19?worldTick=20000000'` and `click --role button --name 'Mark separated'` opens `dialog "Mark separated"` with group "Date", textbox "Note", and button "Mark separated". `click --role button --name 'Close'` leaves the relationship active.
- **Remove, cancelled.** Run `shot --route '#/relationships/18?worldTick=20000000'`. `click --role button --name 'More'` and `click --role menuitem --name 'Remove'` open `dialog "Remove this relationship?"` with "Cancel" and "Remove". `click --role button --name 'Cancel'` keeps 18 in Mara's edges read.
- **Remove.** Repeat and `click --role button --name 'Remove'`. The route becomes `#/relationships`, Mara's edges read no longer holds 18, and `db 'select command_key from editorial_revisions order by id desc limit 1'` gives `records.relationship.remove`.

## Gotchas

- The section is a heading, not a region. Target a row by its links.
- "All recorded relationships" stays pressed when `shot --route` moves the same page to another date.
- Row roles depend on whose page is open. Mara reads "Student of" Kesh; the stored type is `teacher` with Kesh as the source.
- Correct this value rewrites the entry in effect for that field, which can be dated long before the viewed date.
- End, Mark separated, and Remove are in-app dialogs, so `dialogs` stays empty. Click the dialog's own buttons.
- The relationship page's Fields list leaves out Cultural context, Kinship, Visibility, and Perspective unless the tie is, or may have become by the viewed date, Parent of, Sibling of, or Spouse of. It shows End reason and Ended participant at their defaults when the status does not use them, and reads Ended participant as "Source" or "Target", not the end's name.
- Records created earlier in the session add rows and shift the next new id.

## Source and tests

- `src/features/relationship/contract.ts` (the kind, its edge, statuses, and roles), `ui/panel.tsx` (the Relationships section), `ui/editor.tsx` (family fields), `ui/entrypoint.ts`.
- `src/features/relationship/host/rules.ts`, `host/continuity.ts`; `src/framework/ui/pages/RecordPanels.tsx`, `StatusDialog.tsx`.
- Fixtures in `samples/<sample>/seed/relationship.json`.
- `npm test -- src/renderer/features/relationship src/features/relationship src/app/relationship-premise.test.ts`.
