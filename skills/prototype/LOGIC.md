# Logic Prototype

A single, self-contained HTML file (a **shareable demo**) that lets anyone drive a state model by clicking buttons. Use this when the question is about **business logic, state transitions, or data shape**: the kind of thing that looks reasonable on paper but only feels wrong once you push it through real cases.

Because it's one file with nothing to install, you can hand it to a non-developer (a designer, a PM, a domain expert) and let them feel the model for themselves. So it speaks their language, not the code's.

## When this is the right shape

- "I'm not sure if this state machine handles the edge case where X then Y."
- "Does this data model actually let me represent the case where..."
- "I want to feel out what the API should look like before writing it."
- Anything where someone wants to **press buttons and watch state change**.

If the question is "what should this look like," this is the wrong branch. Use the UI variant workflow in [SKILL.md](SKILL.md).

## Process

### 1. State the question

Before writing code, write down what state model and what question you're prototyping. One paragraph in the handoff, with a concise question label at the top of the demo. In this project, follow [ui-preferences](../ui-preferences/SKILL.md) for visible copy. A logic prototype that answers the wrong question is pure waste, so make the question explicit so it can be checked later, whether the user is watching now or returning to it AFK.

### 2. Isolate the logic in a portable module

Put the actual logic (the bit that's answering the question) in a single `<script>` block written as a small, pure module that could be lifted out and dropped into the real codebase later. The page around it is throwaway; this module isn't.

The right shape depends on the question:

- **A pure reducer**: `(state, action) => state`. Good when actions are discrete events and state is a single value.
- **A state machine**: explicit states and transitions. Good when "which actions are even legal right now" is part of the question.
- **A small set of pure functions** over a plain data type. Good when there's no implicit current state, just transformations.
- **A class or module with a clear method surface** when the logic genuinely owns ongoing internal state.

Pick whichever shape best fits the question being asked, *not* whichever is easiest to wire to a page. Keep it pure: no DOM, no `document`, no button handlers reaching inside it. The page calls into it; nothing flows the other direction. This is what makes the prototype useful past its own lifetime: once the question's answered, the validated reducer / machine / function set lifts into the real module on its own.

### 3. Build the shareable HTML file

Create the demo in an isolated temporary directory, outside production source. Use in-memory state; if persistence is the question, use a clearly named scratch database or file, never the developer's project.

One file, plain HTML/CSS/JS: no framework, no bundler, no server, everything inline so it opens by double-click and survives being emailed around. Anyone should be able to run it by opening it.

Write it for a non-developer. Every label is in **domain language**, not code: buttons and state read like the business, not the reducer. For this project, put explanations in the handoff; for other demos, explain in plain words on the page.

Lay it out with a clean hierarchy, top to bottom:

1. **Title and question label** for what this demo lets you explore.
2. **Current state**: the full relevant state, rendered as a readable panel (labelled fields, not a raw JSON dump), re-rendered after every click so the change is visible. Where it helps a non-developer follow, call out what just changed.
3. **Free-play buttons**: one button per action, always available, so anyone can poke at the model in any order. Each click dispatches its action and re-renders the state.
4. **Guided walkthroughs**: a set of **scenarios**, one per tab. For this project, each tab holds a scenario name and the ordered **buttons to press**, with the scenario description in the handoff. Outside this project, the tab can also show a short plain-language description of the scenario and what to watch for. Each step is a real button: clicking it performs that action and moves to the next step. Starting a walkthrough resets to a known initial state so the scenario runs the same way every time.

Choose scenarios that demonstrate the awkward cases, the ones hard to reason about on paper: the happy path, a tricky edge case, an attempt at something that should be illegal.

For this project, follow [ui-preferences](../ui-preferences/SKILL.md) and the [theme contract](../../../docs/agents/contracts/theme.md): true black, dense layout, opaque surfaces, instant state changes, and the existing font rules. For a standalone demo outside the app, use a restrained layout with clear state and buttons, without animations or decorative effects.

### 4. Hand it over

Before handing it over, drive the free-play actions and every guided scenario yourself with the browser tooling from [control-ui](../control-ui/SKILL.md). Check that each walkthrough resets to a known state, illegal actions produce the intended result, and the visible state matches the model. Before launching a visible GUI window on this machine, read [silent-workspace-test](../silent-workspace-test/SKILL.md).

Send them the file, or show it through that browser tooling. They'll click through the walkthroughs and free-play whenever they get to it; the interesting moments are when they say "wait, that shouldn't be possible" or "huh, I assumed X would be different"; those are the bugs in the _idea_, which is the whole point. If they want new actions or a new scenario, add them. Prototypes evolve.

### 5. Capture the answer and the prototype

Report the question, observed results, decision, and temporary HTML path, and keep the demo available while the developer reviews it. Once they choose the model, implement it through the Feature or Architect workflow, following production conventions and [Landing on main](../poteto-mode/playbooks/landing-on-main.md). Record the decision in the existing work artifact or commit. Delete the temporary demo after promotion unless the developer asks to keep it.

## Anti-patterns

- **Don't add tests.** A prototype that needs tests is no longer a prototype.
- **Don't wire it to the real database.** Use in-memory state unless the question is specifically about persistence.
- **Don't generalise.** No "what if we wanted to support X later." The prototype answers one question.
- **Don't blur the logic and the page together.** If the pure module references the DOM, `document`, or button handlers, it's no longer liftable. Keep the page as a thin shell over a pure module.
- **Don't reach for a framework, bundler, or server.** One file the recipient double-clicks; a React app or a dev server defeats "shareable".
- **Don't ship the HTML shell into production.** The page is optimised for being clicked through by hand. The logic module behind it is the bit worth keeping.
