# Command palette

The command palette is the app's global search. It opens pages, searches world records and the manuscript, reopens recently visited records, and runs actions offered by the current page.

## Sub-features

- `palette-open` opens from the search button or Ctrl+K and dismisses with Escape or Close.
- `palette-pages` opens a page from the Pages group.
- `palette-world` searches and opens a world record.
- `palette-manuscript` opens a matching scene at its saved version.
- `palette-recent` reopens a recently visited world record.
- `palette-actions` runs a "Create here" action from the current page.
- `palette-backup` backs up the project from the Project group.

## How to get to it (user POV)

- The magnifier button "Open command palette" at the top left, or Ctrl+K or Meta+K anywhere.
- Type into the "Search commands" combobox, then choose an option or press Enter.

## Driving it with verify-electron

Preconditions:

- Fixtures are character "Tovan Ash" (id 4) and scene "The Salt Bell" in "The Three Witnesses".

- **Open.** Run `click --role button --name 'Open command palette'` and `wait --role dialog --name 'App command palette'`. `snapshot --role dialog` shows the focused combobox "Search commands" and listbox "Commands" with groups "Recent records", "Pages", and "Project".
- **Dismiss.** `press Escape`, then `wait --role dialog --name 'App command palette' --gone`. Reopen with `press Control+k` (or `press Meta+k`) and close with `click --role button --name 'Close'`.
- **Pages.** Open the palette, `type 'Timeline'`, and `click --role option --name 'Timeline'`. The route is `#/timeline` and the dialog closes.
- **World record.** Open the palette, `type 'Tovan Ash'`, and `wait --role group --name 'People'`. Results group as "People" (Tovan Ash, Kesh Ash), "In the manuscript", "Items", "Events" and "Offices". `click '[role="group"][aria-label="People"] [role="option"]' --nth 0` routes to `#/people/4`.
- **Recent.** Visit a record first, as above or with `shot --route '#/people/4'`. Run `click --role button --name 'Overview'`, open the palette, and `wait --role option --name 'Tovan Ash'`. `snapshot --role group --name 'Recent records'` lists visited records, newest first. `click --role option --name 'Tovan Ash'` reopens `#/people/4`. A Maps visit also adds its open map, such as "Lumae and the Lantern Coast" at `#/maps/1`.
- **Manuscript.** Open the palette, `type 'The Salt Bell'`, and `wait --role group --name 'In the manuscript'`. `click --role option --name 'The Salt Bell'` opens `#/writing?view=write&scene=<id>&version=<id>`. Then `wait --role button --name 'Return to draft'` succeeds and the footer reads "Version 1 · The Salt Bell".
- **Action.** `click --role button --name 'People'` and open the palette. The empty-query list has a "Create here" group with "New character". `type 'New character'`, `wait --role option --name 'New character'`, and `press Enter`. The palette closes and the heading is "New character" over the new character form. `click --role button --name 'Cancel'` returns to "People", and `eval` of `window.appHost.invoke('records.character.list', {show:'all'}, {at:20000000})` still has 10 `output.items`.
- **Back up.** Open the palette and `wait --role option --name 'Back up project'`. `click --role option --name 'Back up project' --dismiss` lists a `save` dialog "Back Up Project" with `answer:null`, closes the palette, and writes nothing. Reopen and run `click --role option --name 'Back up project' --file "$HOME/.cache/agent-swarm/<dir>/palette-backup"`; the dialog answer is that path. The copy first appears as `palette-backup.partial-<hex>`, then as `palette-backup` with `app.project.json` named "The Sample World backup <date> <time>", `app.sqlite`, and `.app/assets`. The next command lists a `message` "Backup complete" answered "OK", and `getCurrentProject()` still names the session's project.

## Gotchas

- An option name can repeat across groups. "Tovan Ash" is under both "Recent records" and "People" after a visit, so scope by group with the CSS selector and `--nth`.
- `:first-child` inside a palette group matches the group heading, not the first option. Use `--nth 0`.
- Escape does not dismiss the "New character" form opened by the action. Use "Cancel".
- Back up copies the whole project (about 195 MB on the sample) and finishes after the click returns. Poll the target folder from the shell before reading the "Backup complete" record.
- Recent records are record visits, not Overview's editorial Recent list. They load a moment after the palette opens, so wait for the option before clicking.

## Source and tests

- `src/renderer/components/app-shell/CommandSearchButton.tsx`, `CommandPalette.tsx`, `commandPaletteRecords.ts`, `useAppShellProject.ts`, and `src/renderer/components/ui/command.tsx`.
- `src/shared/authoring-search.ts`, `src/backend/services/authoring-search-service.ts`.
- `npm test -- src/renderer/components/ui/command.test.tsx src/renderer/components/app-shell/commandPaletteRecords.test.ts src/renderer/components/app-shell/useAppShellProject.test.tsx`.
- `npm test -- src/backend/services/authoring-search-service.test.ts`.
