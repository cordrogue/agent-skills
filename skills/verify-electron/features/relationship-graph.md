# Relationship graph

Graph draws every world record at the viewed date as a node, with relationship and reference links between them. Selecting a node lists its links and opens it. Kind toggles, a References toggle, drag, pan, fit, and Display and Forces sliders change the view without changing data.

## Sub-features

- `graph-inspect` selects a node, lists its links, follows a neighbor, and clears with Escape.
- `graph-open` opens a record from "Open" or by double-clicking its node.
- `graph-filter` hides a record kind or reference links.
- `graph-navigation` drags nodes, pans by wheel or blank-canvas drag, and fits.
- `graph-zoom` zooms with Ctrl plus wheel.
- `graph-settings` adjusts Display and Forces sliders and "Single links outside", then resets them.
- `graph-sections` collapses and expands control sections from their context menu.

## How to get to it (user POV)

- "Graph" in the activity bar opens `#/graph`.
- `region "Graph"` holds `SvgRoot "Element graph"`, one `button` per node, and `group "Graph controls"`.
- Selecting a node opens `complementary "Selected element"` with "Open" and `list "Links"`.

## Driving it with verify-electron

Preconditions:

- A fresh `start`. Prefix every command with `node scripts/verify-electron.mjs`. Mara is `character:1`.
- Nodes are `g[data-graph-node="<kind>:<id>"]` with `role="button"` and the record name as label. Use the CSS form, because a name such as "Mara Venn" also matches sidebar buttons.
- Kind buttons carry their count, such as "Characters 10" and "Places 11" on a fresh sample. Read them from `snapshot`.

- **Enter.** Run `click --role button --name 'Graph'`. `eval 'document.querySelector("section[aria-label=Graph]").getAttribute("aria-busy")'` returns `"false"`. Controls show "Fit", `region "Elements"` with ten kind buttons `[pressed]`, "References" `[pressed]`, `region "Display"`, and `region "Forces"`.
- **Inspect.** Run `click 'g[data-graph-node="character:1"]'`. The node becomes `[pressed]`, the panel heading is "Mara Venn", and Links include "Veyra-on-the-Tide Origin", "Brineglass Compass ← Held by", "Captain Orin Venn ← Father and daughter", and "Kesh Ash ← Rim guide".
- **Follow and clear.** Run `click --role button --name 'Kesh Ash ← Rim guide'`; the heading becomes "Kesh Ash". Run `press Escape` and `wait --role complementary --name 'Selected element' --gone`.
- **Open.** Select Mara again and `click --role button --name 'Open'`. The route is `#/people/1?worldTick=20000000`. Return with `click --role button --name 'Graph'` and run `click 'g[data-graph-node="character:1"]' --count 2`; the same route opens.
- **Hide a kind.** Run `click --role button --name 'Characters 10'` and `wait 'g[data-graph-node="character:1"]' --gone`. The button is `[not pressed]`. Click it again and `wait 'g[data-graph-node="character:1"]'`.
- **Hide references.** Run `click --role button --name 'References'`. `eval '[...document.querySelectorAll("path[data-graph-links=reference]")].map(p => p.getAttribute("d").length)'` drops its first entry to 0. Select Mara; Links keep only relationships such as "Kesh Ash ← Rim guide". Click "References" again.
- **Drag a node.** Read `eval 'document.querySelector("g[data-graph-node=\"character:1\"]").getAttribute("transform")'`, run `drag 'g[data-graph-node="character:1"]' --dx 150 --dy 100`, and read it again. It changes.
- **Pan and fit.** Read `eval 'document.querySelector(".app-graph-scene").getAttribute("transform")'`. `scroll 'svg[aria-label="Element graph"]' --dy 240` moves its y by -240. When `eval 'document.elementFromPoint(847,454).tagName'` is `"svg"`, `drag 'svg[aria-label="Element graph"]' --dx 100 --dy 0` moves its x by exactly 100. `click --role button --name 'Fit'` recenters.
- **Zoom.** Read the transform of `g[data-graph-node="character:1"]`, then run `scroll 'svg[aria-label="Element graph"]' --dy -240 --modifiers Control`. Node offsets double (for example `translate(77.2 -106.3)` becomes `translate(154.5 -212.5)`) and the scene translate shifts to keep the point under the pointer. `--dy 240 --modifiers Control` restores the earlier transforms. The same scroll without the modifier pans instead.
- **Adjust and reset.** For "Node size", "Title size", "Repel", "Link strength", "Link distance", and "Center", run `click --role slider --name '<name>'` then `press ArrowRight`; values change and "Reset" appears. Run `click --role button --name 'Single links outside'`; it becomes `[pressed]`. Run `click --role button --name 'Reset'`. Values return to 1, 11, 260, 1, 70, 0.05 and the toggle to `[not pressed]`, while kind and References toggles keep their state.
- **Sections.** Run `click --role region --name 'Display' --button right`. The menu offers "Collapse Display", "Collapse all", and a disabled "Expand all". Choose "Collapse Display"; a `button "Display" [collapsed]` replaces the sliders, and clicking it restores them. "Collapse all" leaves buttons "Elements", "Display", and "Forces". From any section menu, "Expand all" restores all six sliders.

## Gotchas

- Clicking a slider jumps it to the click point before the arrow step. Assert a change, not an exact value.
- Graph changes are view state. Dragged nodes do not save Board positions, and Reset leaves kind toggles alone.
- Records created earlier in the session appear as nodes and change kind counts.

## Source and tests

- `src/renderer/features/graph/GraphPage.tsx`, `GraphControls.tsx`, `SelectedElementPanel.tsx`, `elementGraph.ts`, `graphPainter.ts`, `graphSimulation.ts`.
- `src/renderer/components/KindToggleList.tsx`, `src/renderer/lib/useCanvasViewport.ts`, `src/renderer/components/app-shell/ActivityBar.tsx`.
- `npm test -- src/renderer/features/graph src/renderer/lib/canvasViewport.test.ts`.
