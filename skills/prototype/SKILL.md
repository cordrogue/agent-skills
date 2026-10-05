---
name: prototype
description: Build UI variants behind a visual picker, or a clickable state-model demo with guided scenarios. Only runs when explicitly invoked; it does not trigger on its own.
disable-model-invocation: true
---

# Prototype

## Choose the question

For a business-logic, state-transition, or data-model question, follow [LOGIC.md](LOGIC.md). It builds one self-contained HTML demo with readable state, free-play actions, and guided scenarios.

For a visual UI question, follow the UI variant workflow below. Keep its picker, the project's design rules, dev-only route, and promotion process. If the question is ambiguous, infer it from the request and state the assumption.

## UI variants

A divergence skill. It does ONE thing: take a described piece of UI ("a toast", "the pricing card", "a hold-to-delete button"), build several genuinely different versions of it, and put them behind a visual picker so the user can flip through them live and choose a winner. It does not review existing UI, plan fixes for it, or choose dependencies.

## Operating Posture

You are a senior design engineer running a design exploration. The entire value of this skill is **divergence**: three tints of the same idea waste the picker — the user learns nothing by flipping between them. Each variant must be a direction you could defend shipping on its own, exploring a genuinely different answer to the same brief.

Divergence is not an excuse to drop the craft bar. Every variant is polished on its own terms: deliberate structure and placement, consistent alignment and spacing, and the `ui-preferences` and `alpha-build` skills respected. A sloppy variant doesn't widen the exploration; it just loses on execution and teaches nothing about the direction it represents.

## Hard Rules

1. **Never touch production code during exploration.** Everything lives in an isolated prototype surface (see Phase 4). Integration happens only in Phase 6, only for the variant the user picked. In this project, the one exception is the dev-only route entry from Phase 4.
2. **Variants diverge on a named axis** — layout, density, personality, motion, interaction model. Before building, you must be able to state each variant's axis in a phrase. Sharing the project's tokens is not convergence; variants *should* feel native to the product. In this project, variants have no motion: drop the motion axis and render state changes instantly. Every axis stays inside the `ui-preferences` skill: true black, dense, flat sections without decorative cards or pills, opaque surfaces without glass or blur, and motion that settles instead of looping.
3. **Every variant fully works.** Real interactions, real motion, realistic content — actual product-shaped copy, plausible names and numbers. No lorem ipsum, no dead buttons, no "imagine this part".
4. **The picker is chrome, not a contestant.** Its exact markup, styles, and behavior are specified in [PICKER.md](PICKER.md) — copy them verbatim. Its look is not a design decision and never adapts to the project.
5. **Clean up after the choice.** When a winner is promoted, delete the prototype surface unless the user asks to keep it.

## Workflow

### Phase 1 — Scope

One thing per run. If the description spans multiple components ("the dashboard"), narrow it: pick the single highest-leverage piece, say which and why, and offer the rest as follow-up runs. Restate the brief in one sentence — what the thing is, where it will live, what it must do.

### Phase 2 — Recon

Before designing anything, map the ground the variants must stand on:

- **Stack**: framework, styling system (Tailwind, CSS modules, vanilla), motion library if any.
- **Tokens**: colors, radii, spacing, fonts, easing/duration variables. Variants use these — every variant should look like it could ship in this product tomorrow.
- **Personality**: playful consumer app or crisp dashboard? This bounds how far the boldest variant may go.
- **Context**: where the piece renders — against what background, beside what neighbors, at what sizes.

In this project, read the [theme contract](../../../docs/agents/contracts/theme.md) for tokens and layout rules, and read [design-foundations](../design-foundations/SKILL.md) for the principles each variant answers to.

If there is no project (empty directory, or the user is just exploring), skip to the standalone branch in Phase 4 and choose a restrained default look: neutral grays, one accent, system font stack.

### Phase 3 — Choose directions

Default **3 variants**; up to 5 when the user asks or the design space is genuinely wide. More than 5 dilutes the comparison.

Before writing any code, list the set: a name and an axis for each. Names describe the direction — "Quiet", "Editorial", "Playful", "Dense" — never "Option A/B/C". If two proposed directions would differ only in accent color or copy, they are one direction; replace one with a real alternative (different layout, different interaction model, different motion story).

**Completion criterion:** every variant has a name and a stated axis, and no two variants share an axis position.

### Phase 4 — Build the picker harness

Two branches, by what exists:

- **In this project.** A dev-only TanStack Router route at `/prototypes/<slug>`. Routes are code-based in `src/renderer/router.tsx`; there are no file routes. Put the harness and one file per variant in `src/renderer/prototypes/<slug>/`. Register the route behind `import.meta.env.DEV`, which Vite replaces with `false` in production builds, so the route and its lazy chunk drop out:

  ```tsx
  const prototypeRoutes = import.meta.env.DEV
    ? [
        createRoute({
          getParentRoute: () => rootRoute,
          path: '/prototypes/<slug>',
          component: routePage(
            'prototype:<slug>',
            () => import('@renderer/prototypes/<slug>/Harness'),
            'Harness',
          ),
        }),
      ]
    : [];
  // then spread ...prototypeRoutes into rootRoute.addChildren([...])
  ```

  The route renders inside the app shell with the open project. Realistic content comes from the sample project, the default project of the `run-app` skill: read its records through the same queries the real feature would use. View it with `run-app` in browser mode at `<rendererUrl>#/prototypes/<slug>` (the router uses hash history). Nothing outside `src/renderer/prototypes/` and that guarded route entry imports from the prototype surface.
- **In another project with a dev server** — an isolated route or page (`/prototypes/<slug>`, or the framework's equivalent), one file per variant plus a small harness file. Nothing imports from the prototype surface into production code.
- **No project / static context** — a single self-contained HTML file (inline CSS/JS) the user can open directly in a browser.

The picker's markup, styles, keyboard wiring, and placement come from [PICKER.md](PICKER.md), verbatim — load it now and build exactly that. Beyond the picker itself, the harness must render **one variant at a time, full size, in realistic surrounding context** — a toast needs a page behind it, a card needs siblings, a button needs a form. Side-by-side thumbnails distort spacing and scale; never judge UI at postage-stamp size. Switching is **instant** — flipping is a 100+/session action; by the frequency rule the variant swap gets no animation.

### Phase 5 — Verify and hand off

Run the harness. Confirm every variant renders, every interaction responds, and the console is clean — flip through all of them yourself before showing the user. If browser tooling is available, screenshot each variant.

Then present the set and **stop — the choice belongs to the user**:

| # | Variant | Axis | When it's the right choice | Its cost |
| --- | --- | --- | --- | --- |
| 1 | Quiet | Minimal motion, borders over shadows | The product is a daily-use tool | Least memorable |
| 2 | Editorial | Large type, generous whitespace | The moment deserves weight | Eats vertical space |

Close with where the picker is running (URL or file path) and the keys to flip.

**Completion criterion:** every variant is reachable from the picker and behaves correctly; no console errors; the table names each variant's tradeoff honestly.

### Phase 6 — Promote on selection

When the user picks: integrate that variant where it belongs, following the project's existing conventions (file layout, naming, token usage), then delete the prototype surface per Hard Rule 5. In this project, that means the `src/renderer/prototypes/<slug>/` folder and its route entry, and the change lands through the [Landing on main](../poteto-mode/playbooks/landing-on-main.md) playbook. If the user instead wants another round, keep the harness and run Phase 3 again, diverging *around* the direction they gravitated to.

## Invocation Variants

| Invocation | Behavior |
| --- | --- |
| `<UI description>` | Full UI workflow: scope → recon → 3 variants → picker → wait for choice |
| `<logic or state-model question>` | Follow [LOGIC.md](LOGIC.md): question → pure model → clickable demo → guided scenarios → decision |
| `<UI description> x5` | UI variant workflow with that many variants, capped at 5 |
| `riff <variant>` | New round: keep the harness, generate a fresh set diverging around the named variant's direction |
| `keep <variant>` | Promote that variant into the codebase and delete the prototype surface |
| `keep <variant>, leave the picker` | Promote, but keep the prototype surface around |

## Tone

Sell each variant honestly — one line on when it wins, one on what it costs. Never pre-pick a favorite in the table; if the user asks which you'd choose, answer with a reason rooted in the product's personality and frequency of use, not aesthetics alone. If two variants converged while you built them, cut one and say so: a picker with two truly distinct directions beats one padded to three.
