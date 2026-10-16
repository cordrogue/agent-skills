# Relationship graph

Graph draws every world record at the viewed date as a node, with lines between them from the framework graph read: a solid line for each pair joined by a relationship record, and a dashed line for each pair joined only by a reference. Relationships are lines, never nodes, and a relationship to a map draws no line because maps are not nodes. Selecting a node lists its links, opens it, and opens each relationship on a link. Kind toggles, a References toggle, drag, pan, fit, and Display and Forces sliders change the view without changing data.

## Sub-features

- `graph-inspect` selects a node, lists its links, follows a neighbor, and clears with Escape.
- `graph-open` opens a record from "Open" or by double-clicking its node, and a relationship from its button under a link.
- `graph-filter` hides a record kind or reference links.
- `graph-navigation` drags nodes, pans by wheel or blank-canvas drag, and fits.
- `graph-zoom` zooms with Ctrl plus wheel.
- `graph-settings` adjusts Display and Forces sliders and "Single links outside", then resets them.
- `graph-sections` collapses and expands control sections from their context menu.

## How to get to it (user POV)

- "Graph" in the activity bar opens `#/graph`.
- `region "Graph"` holds `SvgRoot "Element graph"`, one `button` per node, and `group "Graph controls"`.
- Selecting a node opens `complementary "Selected element"` with "Open" and `list "Links"`. Each link is a button named by the other node and its labels; a link carrying relationships adds `list "Relationships with <name>"` with one button per relationship. Links carrying relationships come first, and a link's relationship labels come before its reference labels ("Free Harbors League Harbor-Speaker, Affiliation").

## Driving it with verify-electron

Preconditions:

- Mara is `character:1`.
- Nodes are `[data-canvas-circle="<kind>:<id>"]` with `role="button"` and the record name as label. Use the CSS form, because a name such as "Mara Venn" also matches sidebar buttons.
- Kind buttons carry their count, such as "People 9" and "Places 11" on a fresh sample (People counts only the living). Read them from `snapshot`.
- Lines live in two unfocused paths, `[data-canvas-lines=solid]` for relationships and `[data-canvas-lines=dashed]` for references, one `M…L…` segment per line. `eval 'document.querySelector("[data-canvas-lines=solid]:not([data-canvas-focus])").getAttribute("d").split("M").length - 1'` counts 17 relationship lines on a fresh sample, and the same for `dashed` counts 78. The read behind them is `framework:graph` with `{}` and `{ at: 20000000 }`; its edges with a `via` relationship are the solid lines.

- **Enter.** `click --role button --name 'Graph'`. `eval 'document.querySelector("section[aria-label=Graph]").getAttribute("aria-busy")'` returns `"false"`. Controls show "Fit", `region "Elements"` with thirteen kind buttons `[pressed]`, from "Authority links 2" to "Reporting links 1", "References" `[pressed]`, `region "Display"`, and `region "Forces"`.
- **Inspect.** `click '[data-canvas-circle="character:1"]'`. The node becomes `[pressed]`, the panel heading is "Mara Venn", and Links include "Veyra-on-the-Tide Origin, Home", "Brineglass Compass ← Owner", "Captain Orin Venn ← Father and daughter", and "Kesh Ash ← Rim guide". Under Kesh, `list "Relationships with Kesh Ash"` holds `button "← Rim guide"`.
- **Follow and clear.** `click --role button --name 'Kesh Ash ← Rim guide'` changes the heading to "Kesh Ash". `press Escape` and `wait --role complementary --name 'Selected element' --gone`.
- **Open a relationship.** Select Mara and `click --role button --name '← Rim guide'`. The route is `#/relationships/17?worldTick=20000000` with heading "Rim guide". Return with `click --role button --name 'Graph'`.
- **Open.** Select Mara again and `click --role button --name 'Open'`. The route is `#/people/1?worldTick=20000000`. Return with `click --role button --name 'Graph'`; `click '[data-canvas-circle="character:1"]' --count 2` opens the same route.
- **Hide a kind.** `click --role button --name 'People 9'` and `wait '[data-canvas-circle="character:1"]' --gone`. The button is `[not pressed]`. Click it again and `wait '[data-canvas-circle="character:1"]'`.
- **Hide references.** `click --role button --name 'References'`. `eval '[...document.querySelectorAll("[data-canvas-lines=dashed]")].map(p => p.getAttribute("d").length)'` drops its first entry, the unfocused path, to 0. Select Mara; Links keep only her three relationships, such as "Kesh Ash ← Rim guide", and the relationship path keeps its 17 lines. Click "References" again.
- **Drag a node.** Read `eval 'document.querySelector("[data-canvas-circle=\"character:1\"]").getAttribute("transform")'` before and after `drag '[data-canvas-circle="character:1"]' --dx 150 --dy 100`. The node's lines move with it: an end of one segment in the solid path's `d` equals the node's new translate.
- **Pan and fit.** Read `eval 'document.querySelector("svg[aria-label=\"Element graph\"] > g").getAttribute("transform")'`, the scene translation. `scroll 'svg[aria-label="Element graph"]' --dy 240` moves its y by -240. When `eval 'document.elementFromPoint(847,454).tagName'` is `"svg"`, `drag 'svg[aria-label="Element graph"]' --dx 100 --dy 0` moves its x by exactly 100. `click --role button --name 'Fit'` recenters.
- **Zoom.** Read the transform of `[data-canvas-circle="character:1"]`, then `scroll 'svg[aria-label="Element graph"]' --dy -240 --modifiers Control`. Node offsets double (for example `translate(77.2 -106.3)` becomes `translate(154.5 -212.5)`) and the scene translate shifts to keep the point under the pointer. `--dy 240 --modifiers Control` restores the earlier transforms. Without the modifier the scroll pans.
- **Adjust and reset.** For "Node size", "Title size", "Repel", "Link strength", "Link distance", and "Center", `click --role slider --name '<name>'` then `press ArrowRight`; values change and "Reset" appears. `click --role button --name 'Single links outside'` makes it `[pressed]`. `click --role button --name 'Reset'` returns the values to 1, 11, 260, 1, 70, 0.05 and the toggle to `[not pressed]`, while kind and References toggles keep their state.
- **Sections.** `click --role region --name 'Display' --button right`. The menu offers "Collapse Display", "Collapse all", and a disabled "Expand all". "Collapse Display" replaces the sliders with `button "Display" [collapsed]`, which restores them when clicked. "Collapse all" leaves buttons "Elements", "Display", and "Forces". "Expand all", from any section menu, restores all six sliders.

## Gotchas

- Clicking a slider jumps it to the click point before the arrow step. Assert a change, not an exact value.
- Dragged nodes do not save Board positions, and Reset leaves kind toggles alone.
- Records created earlier in the session appear as nodes and change kind counts. A relationship created in the session adds a solid line, or turns a dashed line solid.

## Source and tests

- `src/features/graph/ui/view.tsx`, `GraphControls.tsx`, `SelectedElementPanel.tsx`, `elementGraph.ts`, `drawing.ts`, `forceLayout.ts`.
- `src/framework/design/GraphCanvas.tsx` and `src/framework/design/canvas/graph/` draw the graph, run its layout loop, place its labels and frame the view.
- `src/framework/host/collectors/graph.ts` (the `framework:graph` read); the relationship kind declares its edge in `src/features/relationship/contract.ts`.
- `src/framework/design/canvas/viewportController.ts`, `src/renderer/components/app-shell/ActivityBar.tsx`.
- `npm test -- src/features/graph src/renderer/features/graph src/framework/design/GraphCanvas src/framework/design/canvas/graph src/framework/host/collectors/graph.test.ts`.
