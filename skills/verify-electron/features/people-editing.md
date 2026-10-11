# Create and edit a person

A writer adds a character from the People collection and records dated changes or corrections with the framework form, including portraits and death as the status Dead.

## Sub-features

- `person-create` saves a new character and opens its page.
- `person-change` saves a dated change with "Change from this time".
- `person-correct` rewrites the value at the viewed date with "Correct this value".
- `person-discard` asks before dropping a draft.
- `person-portrait` chooses a portrait, or restores an earlier one under "Prior images".
- `person-death` records a death with the toolbar "End", which sets the status Dead at the chosen date.
- `person-never-ends` sets a character to never end, so no death estimate shows.

## How to get to it (user POV)

- The People collection toolbar has "New character" and "Show dead".
- A person's toolbar has "End", "More" (holding "Remove"), "Edit" and "History".
- The form has textboxes "Name", "Summary", "Gender", "Role", "Current situation" and "Notable traits", the combobox "Type" (Character, Deity), the groups "Portrait", "Origin", "Affiliation" and "Home", the date group "Born", and the checkbox "Never ends". Location, Influence and the pin are not in the form; the pin is set on the map or in the Position section.

## Driving it with verify-electron

Preconditions:

- "Verify tide surveyor" is a new test record. After saving, resolve its id with `eval '(async () => (await window.appHost.invoke("records.character.list", {}, {at:20000000})).output.items.find((c) => c.title === "Verify tide surveyor").id)()'`.

- **Open the form.** `click --role button --name 'People'`, then `click --role button --name 'New character'`. `snapshot` shows the form with `button "Save" [disabled]` and "Born" set to the viewed date.
- **Fill it.** `click --role textbox --name 'Name'` and `type 'Verify tide surveyor'`. Repeat for "Summary" with `Checks doubtful bearings.`, "Role" with `Survey assistant`, and "Notable traits" with `Patient and observant.`.
- **Save.** `click --role button --name 'Save'` and `wait --role heading --name 'Verify tide surveyor'`. The route becomes `#/people/<id>`, and `shot --name person-created` shows "Alive · Age 0", the summary, Role and the "Traits" section.
- **Confirm storage.** `eval '(async () => { const c = (await window.appHost.invoke("records.character.get", {id:<id>}, {at:20000000})).output; return [c.summary, c.role, c.traits]; })()'` returns `["Checks doubtful bearings.", "Survey assistant", "Patient and observant."]`.
- **Record a change.** At a later date, `click --role button --name 'Edit'`, replace "Summary" with `Rechecks the northern bearings.`, and `click --role button --name 'Change from this time'`. The page shows the new summary there and the old one at the creation date.
- **Discard a draft.** `click --role button --name 'People'`, `click --role button --name 'New character'`, type a Name, and `click --role button --name 'Cancel'`. A dialog asks "Discard this new character draft?" with "Keep editing" and "Discard".
- **Restore a portrait.** On Mara, `click --role button --name 'Edit'`. The group "Portrait" shows her portrait, plus "Prior images" and "Restore" when she has earlier ones. Choose a file with `click --role button --name 'Choose portrait' --file "<png>"` and Change from this time. `records.character.get` returns `portrait` `app-asset://characters/<sha256>.png` at the viewed date and the earlier one before it.
- **Death.** Run this last. On Mara, `click --role button --name 'End'`. The dialog "End" has "Date", set to the viewed date, and "Note"; confirm with its "End" button. "Linked to Mara Venn" then lists every record that still links to her, such as her notes and the Brineglass Compass, with "Move" and "Remove"; close it. Dates read Status "Dead from Bloomtide 1, Year 42 · 21:20", the header reads "Dead · Age 33", Facts show Death "Bloomtide 1, Year 42 · 21:20", and the toolbar offers "Mark alive". `records.character.list` without `show:"all"` no longer holds her at `20000000`.

## Gotchas

- Edit opens the form at the viewed date; there is no separate change date.
- A change at the person's own start date is refused; use Correct this value there.
- Affiliation and Origin have no overlap rule, so they accept a faction or place that is not active at the date.
- Home is checked against the place's life: a Home that ends while the person lives there shows a Continuity warning.

## Source and tests

- `src/features/character/contract.ts` (labels, limits, statuses, the 80-year default for a Character and none for a Deity).
- `src/framework/ui/pages/RecordEditing.tsx`, `RecordForm.tsx`, `StatusDialog.tsx`, `EndImpactDialog.tsx`, `PriorImages.tsx`.
- `npm test -- src/features/character src/app/record-kinds.test.ts`.
