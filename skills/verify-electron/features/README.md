# Verification map

The maintained source for verifying the app's user-facing behavior. Read this index before driving the app, then follow the matching feature file. [`verify-electron`](../SKILL.md) owns launch, drive commands, evidence, and cleanup. Keep the map current with the **maintain-verification-skill** skill.

## Features

Shell and navigation

- [App shell](app-shell.md). Activity bar, sidebar sections and records, sidebar filter, back and forward, window close.
- [Command palette](command-palette.md). Open and dismiss, pages, world records, manuscript scenes, recent records, page actions.
- [Overview](overview.md). Recent editorial work, Around the viewed date, Needs you, Jump to story present.

Time

- [Viewed time](world-time.md). Footer clock, adjacent changes, date editor, scrubber, route, dated record changes.
- [Story present and calendar](settings-world-time.md). Draft and save story present; edit, preview, discard, and validate the calendar.
- [Timeline](timeline.md). Chronology, Line, Calendar, manuscript occurrences, context menu, uncertain dates.
- [Record world history](temporal-history.md). A relationship's editable World history and the legacy map and overlay histories: list, revise, move or unknown date, remove.

People

- [People list and detail](people-list-detail.md). People collection, Show dead, views, opening a person, profile with Home, Location and Influence, links, history.
- [Editing people](people-editing.md). Add a character, dated changes and corrections, discard a draft, portraits, death as the Dead status.
- [Relationships](people-relationships.md). Browse, create from either end, family fields, custom roles, change, correct, end, remove.
- [Person notes](people-notes.md). Notes tab, author-only marker, dated changes, revisions, history, ending, drafts across dates, Narrative on Profile.
- [Character positions](character-positions.md). Dated positions from the profile and the map Character tool, presence, nearby characters.

Places and maps

- [Places](places.md). Browse and filter, detail and links, create, discard, child place, dated change, end.
- [Maps](maps.md). Pick and zoom, detail and linked maps, scale and calibration, detail placement, history.
- [Map overlays](map-overlays.md). Pins, lines, routes, areas, boundaries, influence, map links, label and vertex edits, layers.

Records

- [Bestiary](bestiary.md). Gallery, record page, create, dated change, correct, end, show ended, prior images, remove.
- [Ecology](ecology.md). Gallery, record page, sidebar, create with a subtype, command palette, remove.
- [Lore](lore.md). Gallery, command palette, History, sidebar, create with a subtype, remove.
- [Materials](materials.md). Empty gallery, create with a subtype, remove.
- [Cultures](cultures.md). Empty gallery, create with a subtype, sidebar, remove.
- [Organizations](organizations.md). Gallery, record page, faction link and the faction page's Organizations section, command palette, History, sidebar, create with a subtype, remove.
- [Items](items.md). Collection, record page with ownership and location history, Possessions and Items here, owner continuity, extraction.
- [Factions](factions.md). Factions, offices, reporting links and authority links; an office change caused by a coronation; reigns in the Timeline's Line view.
- [Events](events.md). Event list across time, detail, create and edit with date precision, remove.
- [Powers](powers.md). Gallery, record page, Sera Nhal's relationship, create with a subtype, end, show ended, remove.

Canvases

- [Relationship graph](relationship-graph.md). Relationship and reference lines, select, open a record or relationship, filter, drag, pan, fit, settings, sections.
- [Board](board.md). Record and map cards from sidebar drags, sticky notes, arrows, undo of every gesture, preview and open.
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

- A fresh `start` on the current build copies the sample project. App shell, Command palette, Editorial history, and Overview run `doctor` next. Feature commands are `node scripts/verify-electron.mjs` arguments.
- Story present, and the viewed time after `start`, is Bloomtide 1, Year 42 · 21:20, tick 20000000. Routes carry it, as in `#/bestiary?worldTick=20000000`. One year is 483840 ticks.
- World-record and revision IDs are numeric. Writing artifact and SceneVersion IDs are UUIDs. Resolve them by name with `eval`.
- Framework record kinds (Bestiary, Ecology, Lore, Materials, Cultures, Organizations, Items, Factions, Events, Powers) read through `window.appHost.invoke("<address>", <input>, {at: <tick>})`, which answers `{output}` or `{appError}`. The addresses are `records.<kind>.list` with input `{show:"all"}` and `records.<kind>.get` with `{id}`, where `<kind>` is the singular kind id, such as `culture` for `#/cultures`. `mcp get_entity '{"entityType":"<kind>","id":<id>,"at":<tick>}'` reads a record as an agent does, and `db 'select * from <kind>_state_points where record_id = <id>'` shows each stored dated point. The preload has no `window.app`. Other data reads by its command name through the same call, which answers the same way, such as `window.appHost.invoke("listWorks", {}, {})`. A command that takes no input gets `undefined`, as in `window.appHost.invoke("getTimelineBounds", undefined, {})`.

## Driving conventions

- Start every recipe from the baseline unless its preconditions say otherwise.
- Reach a feature through navigation and controls, as a user does. `eval` is for lookups and read-only checks, not the action under test.
- Prefer accessible roles and names over CSS selectors or DOM position, and poll a condition instead of sleeping.
- Type into the command palette only after `wait --role dialog --name 'App command palette'`. Keys typed before it opens are lost.
- After expanding the Bestiary, Ecology, Lore, Organizations, or Powers sidebar list, run `click --role button --name 'Collapse <Section>'` and `click --role button --name 'Collapse sidebar'` before targeting a bare record name elsewhere, since a sidebar button shares it.

## Proof and skip reporting

- Proof follows the skill's [Evidence](../SKILL.md#evidence) rules: the user action and its resulting state, not only the final screen; a second, read-only view of any stored value, such as an `eval` query or a reload; and empty `rendererErrors` and `mainFailures` from every command.
- Record the feature file and entry point with every artifact.
- Report an unreachable path with the attempted command and the unmet precondition. Do not report a skipped entry point as verified through a different path.

## Feature entry contract

Each feature file starts with an H1 title and one paragraph describing the user-visible behavior, then these H2 sections in order.

1. `Sub-features` lists short IDs with one line for each behavior.
2. `How to get to it (user POV)` lists every user entry point.
3. `Driving it with verify-electron` starts with `Preconditions:` and pairs each user action with an exact command and observable result. Preconditions name only what the baseline above lacks, such as fixtures and read commands.
4. `Gotchas` lists traps that can waste or invalidate a run.
5. `Source and tests` names the owning files and the focused test commands.
