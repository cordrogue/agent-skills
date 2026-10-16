# General settings

Settings, General, holds project-level controls: project paths and desktop project commands, recent projects, whether the add-card picker includes records absent at the viewed date, and pausing automation writes. World time lives on the same page in [settings-world-time.md](settings-world-time.md). Settings is a framework feature page (`src/features/settings`) placed at the foot of the activity bar, drawn with kit components only.

## Sub-features

- `settings-tabs` switches between General and Change history.
- `settings-files` shows the project folder and database paths.
- `settings-project` runs Back up, Reveal, Open, and New.
- `settings-recent` reopens a recent project.
- `settings-picker` lists or hides absent records in the add-card picker.
- `settings-automation` pauses and resumes automation writes.

## How to get to it (user POV)

- The "Settings" activity-bar button, or "Settings" in the command palette. Route `#/settings`.
- The top bar has tabs "General" and "Change history". Change history is `#/settings?tab=history`.
- General has the heading "The Sample World" with "Back up", "Reveal", "Open", and "New", then "Project files", World time, "Workspace", "Automation", and "Recent Projects".

## Driving it with verify-electron

Preconditions:

- Run `doctor` after `start`.
- The read-only views are `eval '(async () => (await window.appHost.invoke("getCurrentProject", undefined, {})).output)()'`, `eval '(async () => (await window.appHost.invoke("getAutomationSettings", {}, {})).output)()'` (`writePaused` false), and `eval 'JSON.parse(localStorage.getItem("app-application-shell")).state.showAbsentRecordsInPicker'` (false).
- Fixture for the picker is "Mara Venn", who does not exist yet at tick 0.

- **Tabs.** `shot --route '#/settings?tab=history&revision=1&worldTick=0'`, then `click --role tab --name 'General'`. The route becomes `#/settings?worldTick=0`: General drops `tab`, `revision`, `subjectType`, and `subjectId` and keeps `worldTick` and every other key. `click --role tab --name 'Change history'` sets only `tab=history`. A tab switch keeps an unsaved story present or calendar draft and asks nothing.
- **Project files.** `click --role button --name 'Project files'`. The button turns `[expanded]`, and "Project folder" and "Database" show the session's `.tmp-vite/verify-electron/project` paths, matching `rootPath` and `databasePath` from `getCurrentProject()`.
- **Back up.** `click --role button --name 'Back up' --dismiss` lists a `save` dialog "Back Up Project" with `answer:null` and writes nothing. `click --role button --name 'Back up' --file "$HOME/.cache/agent-swarm/<dir>/settings-backup"` writes a full project copy there, named "The Sample World backup <date> <time>" in its `app.project.json`. Poll the folder from the shell; then any command lists `message` "Backup complete" answered "OK".
- **Open.** `click --role button --name 'Open' --dismiss` lists an `open` dialog with `answer:null`, and `getCurrentProject()` is unchanged. `click --role button --name 'Open' --file "$HOME/.cache/agent-swarm/<dir>/settings-backup"` switches to that project: `getCurrentProject()` returns its name and rootPath, and a project opened for the first time lands on `#/workspace` with "Empty workspace".
- **New.** `click --role button --name 'New' --file "$HOME/.cache/agent-swarm/<dir>/new-world"` on an empty folder writes `app.project.json`, `app.sqlite`, `world`, `manuscript`, and `.app` there, then switches to "Untitled World" at `#/workspace?worldTick=0`. Settings shows story present "Dawnmere 1, Year 1 · 00:00". `--dismiss` changes nothing.
- **Recent projects.** After those, `snapshot --role main` lists buttons such as `Untitled World /home/<user>/.cache/agent-swarm/<dir>/new-world` `[disabled]` for the open project and `The Sample World backup <date> <time> /home/<user>/.cache/agent-swarm/<dir>/settings-backup`. Clicking the enabled one switches to that project at its last route (`#/settings`), and `listRecentProjects()` puts it first. A row's context menu offers "Open project", disabled for the open project or a missing folder, and "Copy path". `eval '(async () => (await window.appHost.invoke("records.character.list", {show:"all"}, {at:20000000})).output.items.map((c) => c.title))()'` has the sample's 10.
- **Reveal.** verified-unreachable. It opens the desktop file manager on the developer's screen, so it was not clicked. Check it in a visible window with the `silent-workspace-test` skill.
- **Picker on.** `click --role checkbox --name 'List records absent at the viewed date when adding cards'`. The snapshot shows `[checked]` and the localStorage read returns true, before and after `reload`. Then `shot --route '#/workspace?worldTick=0'`, `click --role button --name 'Add card'`, and `type 'Mara'`. Dialog "Add workspace card" lists `option "Mara Venn State unknown"`, plus events marked "Not yet created".
- **Picker off.** `press Escape`, return to Settings, and click the checkbox again. The same search at `worldTick=0` lists no Mara Venn and no "Not yet created" options.
- **Automation.** `click --role button --name 'Pause writes'` and `wait --role button --name 'Resume writes'`. `getAutomationSettings({})` returns `writePaused` true. `click --role button --name 'Resume writes'` brings back "Pause writes" and `writePaused` false.

## Gotchas

- There is no `tab=general`. General is the route without `tab`.
- The session's own project opens without entering Recent Projects, so a fresh session shows "No recent projects yet." After switching away, return with `click --role button --name 'Open' --file <session project path>` before `stop`, or later recipes run against the wrong project.
- Back up, Open, and New write outside the session folder, and `stop` does not delete them. Remove `$HOME/.cache/agent-swarm/<dir>` after copying evidence.
- `listRecentProjects()` takes no argument. Passing `{}` fails with "Please correct the highlighted fields."
- The picker preference lives in localStorage, not the project. Read it before assuming the default.
- Pause status alone does not prove an MCP write is refused. That needs an automation client.

## Source and tests

- `src/features/settings/ui/view.tsx`, `general.tsx`, `recentProjects.tsx`, and `bar.ts`, over the framework's `useProjectFiles`, `useAutomation`, `useAppPreference`, and `useCopyText` (`src/renderer/components/app-shell/frameworkProjectCapabilities.ts`, `projectActions.ts`).
- `src/main/project-service.ts`, `src/main/native-dialogs.ts`, `src/shared/project-ipc.ts`.
- `npm test -- src/renderer/features/settings src/renderer/components/app-shell/projectCapabilities.test.tsx src/main/project-service.test.ts`.
