# Overview

Overview is the project home page. It lists recent editorial work, shows what changes in the world around the viewed date, and adds a "Needs you" section when something waits on the writer, such as an unsaved recovery draft. Each entry links to its record or writing.

## Sub-features

- `overview-recent` lists recently edited notes and scenes and opens them.
- `overview-around` lists dated world changes around the viewed date and opens their records.
- `overview-attention` shows "Needs you" only when a group is nonempty, and opens a recovery draft.
- `overview-jump` returns from another viewed date to story present.

## How to get to it (user POV)

- The "Overview" activity-bar button, or the "Overview" page in the command palette.
- `start` lands here. Route `#/overview`.

## Driving it with verify-electron

Preconditions:

- The heading is "The Sample World".
- The read-only second view is `eval '(async () => (await window.appHost.invoke("getAuthoringOverview", {viewedTick:20000000}, {})).output)()'`. On a fresh sample its `attention` is empty, with `recoveryDrafts` and `agentChanges` `[]` and `continuity.total` and `openProposals.count` 0.

- **Recent.** `snapshot --role region --name 'Recent'` lists eight links, matching the query's `recent`. The first is "What the missing crates prove" (Note), the last "The Salt Bell" (Scene). `click --role link --name 'What the missing crates prove'` opens `#/notes?note=<uuid>` with that note in the editor. Back on Overview, `click --role link --name 'The Salt Bell'` opens `#/writing?view=write&scene=<uuid>`.
- **Around.** The region is named "Around Bloomtide 1, Year 42 · 21:20". The current-date row has `aria-current="date"`, followed by "The Starhold Survey", "Starhold Expedition", and "Drowned Age" marked "in progress". `click --role link --name 'The Starhold Survey' --nth 0` opens `#/events/20`.
- **No attention.** On a fresh sample `wait 'section[aria-label="Needs you"]' --gone` succeeds at once.
- **Recovery draft.** Open "The Salt Bell" from Recent, `click --role textbox --name 'Scene prose'`, `press Control+End`, and `type ' Overview check.'`. The footer status reads "Recovery draft protected". `click --role button --name 'Overview'` and `wait --role region --name 'Needs you'`. Its snapshot shows heading "Recovery drafts 1" and link "The Salt Bell", and the query's `attention.recoveryDrafts` holds that scene. `click 'section[aria-label="Needs you"] a'` reopens the scene with the edited prose and adds `&work=<uuid>` to the route.
- **Jump.** On Overview, `click --role button --name 'Go to previous authored change'`. The route becomes `worldTick=19990360` and the region "Around Greengale 23, Year 42 · 04:40", with a row "Before story present, Bloomtide 1, Year 42 · 21:20" and a "Jump" button. Run `click --role button --name 'Jump to story present'` and `wait --role button --name 'Jump to story present' --gone`. The route returns to `worldTick=20000000` and the Around heading to Bloomtide 1.

## Gotchas

- Two Around rows link "The Starhold Survey" (in progress and ended), so add `--nth 0`.
- The recovery status element has no accessible name, so `wait --role status --name 'Recovery draft protected'` times out. Read it with `snapshot` or wait on the "Needs you" region.
- `press End` in Scene prose goes to the end of the visual line, not the document. Use `press Control+End`.
- Recent shows editorial changes. Visiting a record or making a recovery draft adds no row.
- The fresh sample has no continuity warnings, open proposals, or assistant changes, so those "Needs you" groups stay unverified here.

## Source and tests

- `src/renderer/features/overview/OverviewPage.tsx`, `OverviewView.tsx`, and `overviewQueries.ts`.
- `src/backend/services/authoring-overview-service.ts`, `src/shared/authoring-overview.ts`.
- `npm test -- src/renderer/features/overview/OverviewPage.test.tsx src/renderer/features/overview/OverviewView.test.tsx`.
- `npm test -- src/backend/services/authoring-overview-service.test.ts`.
