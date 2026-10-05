# App shell and navigation

The shell frames every page. The activity bar opens the top-level areas, the sidebar opens record sections and lists their records, a filter narrows the sidebar, Go back and Go forward walk navigation history, and the window controls close the app.

## Sub-features

- `shell-areas` opens Overview, Workspaces, Graph, Board, and Settings from the activity bar.
- `shell-sections` opens each record section and page from the sidebar.
- `shell-records` expands a sidebar section and opens one of its records.
- `shell-collapse` collapses the sidebar and hides the activity bar, then restores both.
- `shell-filter` limits the sidebar to a preset and restores All.
- `shell-history` returns to earlier and later pages with buttons or Alt+arrows.
- `shell-close` closes the window and ends the app.

## How to get to it (user POV)

- The activity bar on the far left (navigation "Activity bar") has "Overview", "Workspaces", "Graph", "Board", and "Settings" at the bottom.
- The sidebar (navigation "Application sections") starts collapsed to icons. "Expand sidebar" widens it and adds an "Expand <Section>" arrow beside each section, plus "Filter sidebar".
- "Go back" and "Go forward" sit in the top bar, or in the sidebar header while it is expanded. Alt+Left and Alt+Right do the same.
- The top right has "Minimize window", "Toggle fullscreen", and "Close window" (group "Window controls").

## Driving it with verify-electron

Preconditions:

- A fresh `start` on the current build, then `doctor` reports `"healthy":true`. Commands below are arguments to `node scripts/verify-electron.mjs`. Every command prints the route.
- Fixture is character "Tovan Ash", id 4 on a fresh sample.

- **Areas.** Run `click --role button --name 'Workspaces'`, then the same for "Graph", "Board", "Settings", and "Overview". The routes are `#/workspace`, `#/graph`, `#/board`, `#/settings`, and `#/overview`, each with `?worldTick=20000000`.
- **Sections.** Run `click --role button --name 'Characters'`. The route is `#/people`. The other sections map by lowercase name (`Bestiary` to `#/bestiary`, `Places` to `#/places`, and so on), plus `Maps`, `Timeline`, `Notes`, and `Writing`.
- **Records.** Run `click --role button --name 'Expand sidebar'`, `click --role button --name 'Expand Characters'`, and `wait --role button --name 'Tovan Ash'`. Then `click --role button --name 'Tovan Ash'`. The route is `#/people/4` and the sidebar row is highlighted. `snapshot --role navigation --name 'Application sections'` lists `list "Characters records"`.
- **Collapse.** Run `click --role button --name 'Collapse Characters'` and `wait --role list --name 'Characters records' --gone`. Run `click --role button --name 'Collapse sidebar'` and `wait --role button --name 'Expand sidebar'`. Run `click --role button --name 'Hide activity bar'` and `wait --role navigation --name 'Activity bar' --gone`. The area icons disappear and only the section icons remain. `click --role button --name 'Show activity bar'` brings them back.
- **Filter.** With the sidebar expanded, run `click --role button --name 'Filter sidebar'`. A dialog "Filter sidebar" shows group "Presets" (All, World, Writing) and a checkbox per section. Run `click '[aria-label="Presets"] button:nth-child(3)'` for Writing, then `press Escape`. The sidebar lists only Notes and Writing, and the button is now "Filter sidebar, 1 active". Reopen it with that name, `click --role button --name 'All'`, `press Escape`, and `wait --role button --name 'Expand Characters'`.
- **History.** Run `click --role button --name 'Overview'`, `click --role button --name 'Characters'`, and `click --role button --name 'Places'`. Then `click --role button --name 'Go back'` reports `#/people`, and `click --role button --name 'Go forward'` reports `#/places`. `press Alt+ArrowLeft` and `press Alt+ArrowRight` move the same way.
- **Close.** Run this last, since it ends the session. `click --role button --name 'Close window'` reports `"ok":false` with "DevTools closed during Runtime.evaluate". `doctor` then reports `"processAlive":false`. Run `start` before driving again.

## Gotchas

- The sidebar's preset "Writing" and the section "Writing" share a role and name, so `--role button --name 'Writing'` errors with two matches. Use the Presets selector above.
- The Writing preset hides Timeline too. Only Notes and Writing remain.
- A collapsed sidebar has no "Expand <Section>" arrows and no "Filter sidebar". Expand it first.
- The snapshot does not print `aria-current`. Check the highlighted row in a screenshot.
- Minimize and fullscreen act on the window manager and have no visible effect offscreen. Check them with the `silent-workspace-test` skill.
- The window is fixed at 1440x900, so the compact "Open navigation" layout never appears here.

## Source and tests

- `src/renderer/components/AppShell.tsx`, `Sidebar.tsx`, `WindowControls.tsx`, and `app-shell/ActivityBar.tsx`, `AppShellTopBar.tsx`, `HistoryButtons.tsx`, `FilterMenu.tsx`, `useAppShellLayout.ts`.
- `src/renderer/router.tsx`, `src/shared/record-kinds.ts`, `src/main/index.ts` (window close).
- `npm test -- src/renderer/components/Sidebar.test.tsx src/renderer/components/AppShell.navigation.test.tsx src/renderer/components/app-shell/useAppShellLayout.test.tsx`.
