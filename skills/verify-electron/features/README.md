# Verification map

The maintained source for verifying the app's user-facing behavior. Read this index before driving the app, then use the matching feature file as the recipe. [`verify-electron`](../SKILL.md) owns launch, drive commands, evidence, and cleanup. Keep it current with the **maintain-verification-skill** skill.

## Features

Shell and navigation

- [App shell](app-shell.md). Activity bar, sidebar sections and records, sidebar filter, back and forward, window close.
- [Command palette](command-palette.md). Open and dismiss, pages, world records, manuscript scenes, recent records, page actions.
- [Overview](overview.md). Recent editorial work, Around the viewed date, Needs you, Jump to story present.

Time

- [Viewed time](world-time.md). Footer clock, adjacent changes, date editor, scrubber, route, dated record changes.
- [Story present and calendar](settings-world-time.md). Draft and save story present; edit, preview, discard, and validate the calendar.
- [Timeline](timeline.md). Chronology, Line, Calendar, manuscript occurrences, context menu, uncertain dates.
- [Record world history](temporal-history.md). History entries, location, position, and note histories, revise, remove.

People

- [People list and detail](people-list-detail.md). Characters collection, views, opening a person, profile, links, history.
- [Editing people](people-editing.md). Add a character, dated changes, discard a draft, portraits, end.
- [Relationships](people-relationships.md). Browse, change, correct, family details, history, create, custom types, remove.
- [Person notes](people-notes.md). Notes tab, dated changes, revisions, history, Narrative on Profile.
- [Character positions](character-positions.md). Dated positions from the profile and the map Character tool, presence, nearby characters.

Places and maps

- [Places](places.md). Browse and filter, detail and links, create, discard, child place, dated change, end.
- [Maps](maps.md). Pick and zoom, detail and linked maps, scale and calibration, detail placement, history.
- [Map overlays](map-overlays.md). Pins, lines, routes, areas, boundaries, influence, map links, label and vertex edits, layers.

Records

- [Catalog records](catalog-records.md). Items, Powers, Factions, Ecology, Organizations, Lore, Bestiary, Cultures, Materials.
- [Events](events.md). Event list across time, detail, create and edit with date precision, remove.

Canvases

- [Relationship graph](relationship-graph.md). Select, open, filter, drag, pan, fit, settings, sections.
- [Board](board.md). Record cards from sidebar drags, sticky notes, arrows, delete with undo, preview and open.
- [Workspace](workspace.md). Named workspaces, adding cards, layout, split, resize, move, image shape, delete.

Writing

- [Works](writing-works.md). Create, select, rename a Work, read the compiled manuscript, remove.
- [Scene index and structure](writing-scenes.md). Draft index, sort, create, rename, reorder, Chapter placement, story sequence.
- [Names in prose](writing-names.md). Name suggestions, Scene context mentions, character presence, new-name proposals.
- [Scene recovery and versions](scene-recovery.md). Recovery drafts, Save version, Version history, return to draft.
- [Authoring notes](authoring-notes.md). Save, format, organize, filter, discard, and remove notes.

Settings and agent

- [General settings](settings-general.md). Tabs, project files and commands, recent projects, record picker, automation writes.
- [Editorial history and undo](editorial-history.md). Revision list, detail and subject links, ineligible reasons, undo the head.
- [In-app agent](agent.md). Panel, local app-server start; signed-in flows need the developer.

## Baseline preconditions

- A fresh `node scripts/verify-electron.mjs start` on the current build. It copies the sample project, so every recipe starts from the same data.
- World-record and revision IDs are numeric. Writing artifact and SceneVersion IDs are UUIDs. Resolve them by name through `window.app` with `eval`.

## Driving conventions

- Start every recipe from the baseline state unless its preconditions say otherwise.
- Reach a feature the way a user does, through navigation and controls. Use `eval` for lookups and read-only checks, not to perform the action under test.
- Prefer accessible roles and names over CSS selectors or DOM position.
- Wait for UI by polling a condition, not by sleeping.

## Proof and skip reporting

- Capture the user action and the resulting state, not only the final screen.
- Mutation proof includes a second, read-only view of the stored value, such as a `window.app` query or a reload.
- Every command in the run reports empty `rendererErrors` and `mainFailures`.
- Record the feature file and entry point with every artifact.
- Report an unreachable path with the attempted command and the unmet precondition. Do not report a skipped entry point as verified through a different path.

## Feature entry contract

Each feature file starts with an H1 title and one paragraph describing the user-visible behavior, then these H2 sections in order.

1. `Sub-features` lists short IDs with one line for each behavior.
2. `How to get to it (user POV)` lists every user entry point.
3. `Driving it with verify-electron` starts with `Preconditions:` and pairs each user action with an exact command and observable result.
4. `Gotchas` lists traps that can waste or invalidate a run.
5. `Source and tests` names the owning files and the focused test commands.
