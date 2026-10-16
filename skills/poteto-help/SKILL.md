---
name: poteto-help
description: Guides the developer through /poteto-mode and picking the skill, playbook, or principle for a task. Type /poteto-help with a question.
disable-model-invocation: true
---

# Poteto help

Answer the developer's question about this repo's agent skill stack, hand them a prompt they can send, and give the path of the file the answer came from. For a help question, don't start the work. The developer asked how, and a `poteto-mode` run spends real tokens, so let them send the prompt.

A message that asks for work, such as "use poteto mode to fix this bug", is not a help question. Read [`poteto-mode`](../poteto-mode/SKILL.md) and do the work under it.

This file maps questions to the skills and docs that hold the answers. Those files own the details. Read the file you route to before you quote it, and trust it when it disagrees with this map. Give its repo-relative path, such as `.agents/skills/how/SKILL.md`, which the developer can open from the chat. [`docs/humans/USER.md`](../../../docs/humans/USER.md) is the developer's own guide to the stack.

The stack runs in Claude Code, where the developer types `/poteto-mode`, and in Codex, where they write "use poteto-mode". Give the form for this chat's harness.

## Find out what they need

Infer the need from the message and the conversation. A named situation, such as "which skill reviews a branch?", goes straight to its section. If the need is still unclear, ask one multiple-choice question with these options, then answer only the section they pick:

- Start a task with `poteto-mode`
- Pick a skill for a situation
- Fix a run that went wrong
- Models and cost
- Make the stack my own

## Start a task with `poteto-mode`

`poteto-mode` matches the task to a playbook, copies the playbook's steps into the todo list, and runs the other skills as the steps need them. A step it skips stays in the list as `skip: <reason>`. A good prompt states the goal and how to tell it's done. It doesn't list skills, because a hand-written sequence tends to drop or reorder steps the playbook would keep. Read [`references/prompting.md`](references/prompting.md) before you help word one.

Typing `/poteto-mode` loads it for the rest of the chat. Nothing loads it automatically, so a fresh chat starts without it. Mid-chat, "new task" makes the mode match a fresh playbook. In a long chat, type `/poteto-mode` again if replies stop following it. Trivial edits don't need it.

Playbook helpers already follow `poteto-mode`. A helper the developer starts gets the style from `subagent_type: "poteto-agent"` in Claude Code, or from a Codex prompt that opens with "Read `.agents/skills/poteto-mode/SKILL.md` in full first." Read [`harness-tools.md`](../poteto-mode/references/harness-tools.md) and [`models.md`](../poteto-mode/references/models.md) before giving launch instructions.

## Pick a skill

The default answer is `poteto-mode`, which runs most of the others when its steps need them. Name a skill directly when the developer wants more or less of something than the playbook gives. Read the skill before you recommend it, and give one example prompt. For proving a change works, start with `verify-electron`, and mention `create-verification-skill` only if no working verification skill exists.

| The developer wants to | Skill |
|---|---|
| Do any non-trivial task with rigor | [`poteto-mode`](../poteto-mode/SKILL.md) |
| Know how code works now, or where new code should live | [`how`](../how/SKILL.md) |
| Know why code is shaped this way, or where a number came from | [`why`](../why/SKILL.md) |
| Understand a change or subsystem, explained plainly | [`teach`](../teach/SKILL.md) |
| Catch up on their own recent work on a topic | [`recall`](../recall/SKILL.md) |
| Catch up on everything in this chat since their last message, with enough context to decide each action item | [`ketchup`](../ketchup/SKILL.md) |
| Hear the last reply again in plain words | [`bro`](../bro/SKILL.md) |
| See every check, skill, loaded file and running plan feeding the agents, and what changed | [`command-center`](../command-center/SKILL.md) |
| Have their own plan or idea questioned until it holds up | [`grilling`](../grilling/SKILL.md) |
| Settle the project's words, the glossary, or record a decision | [`domain-modeling`](../domain-modeling/SKILL.md) |
| Settle types and module shape before code that crosses a function boundary | [`architect`](../architect/SKILL.md) |
| Find places where the code's structure could become simpler and deeper | [`improve-codebase-architecture`](../improve-codebase-architecture/SKILL.md) |
| Try 3 to 5 versions of one UI piece and pick one, or click through a state model | [`prototype`](../prototype/SKILL.md) |
| Check a design against Apple's design principles | [`design-foundations`](../design-foundations/SKILL.md) |
| Get several attempts at one brief, merged into the best one | [`arena`](../arena/SKILL.md) |
| Run parallel checks over slices, or race workers | [`swarm`](../swarm/SKILL.md) |
| Run a large or cross-cutting change, or one to review after stepping away | [`figure-it-out`](../figure-it-out/SKILL.md) |
| Keep a decision log during a run, and review it afterward | [`show-me-your-work`](../show-me-your-work/SKILL.md) |
| Reproduce and diagnose a bug | [`diagnosing-bugs`](../diagnosing-bugs/SKILL.md) |
| Fix a bug test-first when a cheap local test exists | [`tdd`](../tdd/SKILL.md) |
| See the change working in the real built app | [`verify-electron`](../verify-electron/SKILL.md) |
| Open the app themselves in the T3 Code browser | [`run-app`](../run-app/SKILL.md) |
| Check something that needs a visible window, kept off their screen | [`silent-workspace-test`](../silent-workspace-test/SKILL.md) |
| Prove one claim with a before and after | [`verify-this`](../verify-this/SKILL.md) |
| Vet a performance number before reporting or acting on it | [`benchmark-checklist`](../benchmark-checklist/SKILL.md) |
| Bring `verify-electron` and its feature map back in line with the app | [`maintain-verification-skill`](../maintain-verification-skill/SKILL.md) |
| Give a project with no verification skill a scripted way to drive its app | [`create-verification-skill`](../create-verification-skill/SKILL.md) |
| Build a custom harness to drive a CLI, or a UI other than the app's | [`control-cli`](../control-cli/SKILL.md), [`control-ui`](../control-ui/SKILL.md) |
| Know what a small diff could break outside itself | [`blast-radius`](../blast-radius/SKILL.md) |
| Have several models review a diff and try to break it | [`interrogate`](../interrogate/SKILL.md) |
| Get the harshest review, a correctness and security audit plus a maintainability audit | [`thermos`](../thermos/SKILL.md), which runs [`thermo-nuclear-review`](../thermo-nuclear-review/SKILL.md) and [`thermo-nuclear-code-quality-review`](../thermo-nuclear-code-quality-review/SKILL.md) |
| Clean AI slop out of code before landing | [`deslop`](../deslop/SKILL.md) |
| Strip comments before landing, using a reviewer that didn't write them | [`no-comments`](../no-comments/SKILL.md) |
| Clean AI tells out of prose | [`unslop`](../unslop/SKILL.md) |
| Write docs or commit messages to a standard | [`technical-writing`](../technical-writing/SKILL.md) |
| Write or edit a skill | [`writing-for-agents`](../writing-for-agents/SKILL.md) |
| Walk through steps only they can do, such as credentials or a third-party dashboard | [`wizard`](../wizard/SKILL.md) |
| Stop agents from repeating the same mistakes in this repo | [`correct`](../correct/SKILL.md) |
| Clean up after a long task: retro, reflect, one combined report, and the backlog | [`wrap-up`](../wrap-up/SKILL.md) |
| Wrap up every thread of a multi-thread plan, or an orchestrator's tree of nested tasks, then decide on all their findings at once | [`wrap-up-stack`](../wrap-up-stack/SKILL.md) |
| Turn what a finished task taught into skill edits | [`reflect`](../reflect/SKILL.md) |
| Look back on a session for changes to the agents' tools, checks, and docs | [`retro`](../retro/SKILL.md) |
| Turn their own working habits into a personal mode skill | [`automate-me`](../automate-me/SKILL.md) |
| Find their way around the stack | `poteto-help` |

These load on their own when the work calls for them, so the developer never names them: [`alpha-build`](../alpha-build/SKILL.md), [`backlog`](../backlog/SKILL.md), [`repeat-mistakes`](../repeat-mistakes/SKILL.md), [`testing`](../testing/SKILL.md), [`typescript-best-practices`](../typescript-best-practices/SKILL.md), [`ui-preferences`](../ui-preferences/SKILL.md), and [`user-communication`](../user-communication/SKILL.md). The `principle-*` skills are covered under principles below.

Close calls:

- `how` explains what the code does. `why` explains the reasons. `teach` runs one or both and explains the result plainly.
- `grilling` questions the developer about their plan. `interrogate` reviews code that exists.
- `interrogate` reviews the diff with several models. `thermos` is the explicit "go hard" audit. `blast-radius` looks for breakage outside the diff and proves the one fact that makes the change safe.
- `arena` gives every worker the same brief and merges the best parts. `swarm` splits work into slices or a race and returns one report.
- `architect` implements right after it settles the design. Add "with checkpoint" to review the design before it writes code.
- `verify-electron` is how agents check the built app, offscreen on a copy of the sample project. `run-app` is the developer's own view in the browser.
- `reflect` turns one session's lessons into skill edits. `retro` looks for changes to the agents' environment, such as checks and navigation. `correct` changes the repo so a repeated mistake class can't come back. `wrap-up` runs `retro` and `reflect` on a finished thread and merges the reports.
- `recall` rebuilds context across recent chats. `ketchup` covers only this chat since the developer's last message. Resuming one specific chat or branch is the Session pickup playbook.
- `figure-it-out` designs one rigorous run. The Autonomous run playbook drives one task to a finish condition.

Not in this stack:

- Upstream pstack's PR playbooks (opening a PR, babysit, shipping, autopilot, orchestrate) and its `setup-pstack` and `make-bot-ui` skills. Work lands on local `main` through the Landing on main playbook.
- `/loop`, `/simplify`, and `/code-review` are Claude Code built-ins with no Codex equivalent.

## Playbooks and principles

Playbooks are step lists inside `poteto-mode`, not skills, so they have no command. Inside `poteto-mode`, describing the task picks one, and these phrases name one directly:

- "pause safely", or "i'm about to restart t3 code", runs Pause safely: the agent commits its work and writes a resume note. Restarting T3 Code ends every agent it hosts, so say it before a restart.
- "take over this branch" runs Session pickup.
- "run until done" or "/loop until <check>" runs Autonomous run. `/loop` works only in Claude Code.
- "prototype a few options" runs Prototype.
- "turn this design into a plan" runs Multi-phase plan. It writes the plan and doesn't implement it.
- "run the eval playbook" runs Eval.

The Playbooks section of [`poteto-mode`](../poteto-mode/SKILL.md) lists every playbook and when it applies. Every playbook ends in [Landing on main](../poteto-mode/playbooks/landing-on-main.md): small ordered commits on local `main`, no PRs.

Principles are one-rule skills that `poteto-mode` reads and cites in its replies. The developer rarely invokes one, and steers with the names instead, as in "apply prove it works. show me the real output." In Claude Code, typing `/principle-<name>` loads one on demand. The Principles section of [`poteto-mode`](../poteto-mode/SKILL.md) lists them with when each applies.

## Fix a run that went wrong

| Symptom | Fix |
|---|---|
| The mode stopped applying in a long chat | Type `/poteto-mode` again, or start the next task in a fresh chat with it. |
| A question got treated as the next step of the last task | Say "new task", or say the turn doesn't need the mode. |
| Agents stopped after a T3 Code restart | The restart ended them. Resume in a fresh chat with "/poteto-mode take over this branch" and the worktree path. Next time, say "pause safely" first. |
| A skill didn't load on its own | A skill with `disable-model-invocation: true` loads only when typed or when a workflow reads its `SKILL.md` by path. `poteto-mode` reads only the skills its steps need. |
| A model change had no effect, or runs cost more than expected | See Models and cost. |
| Parallel agents overwrote each other | Give each agent its own worktree under `/home/me/worktrees/<task>`. |
| An unattended run moved but finished nothing | A loop needs a check that can pass or fail, not a duration. See the Autonomous run playbook. |
| The reply claims success from a green build or passing tests | Ask for the real artifact, such as `verify-electron` screenshots, the stored value, or the command output. That's the prove-it-works principle. |

For a run that drifts, [`references/prompting.md`](references/prompting.md) has one-line steers.

## Models and cost

[`poteto-mode/references/models.md`](../poteto-mode/references/models.md) names the model for each role. Opus writes all code. Sol, which runs in Codex, reads, reviews, and judges. A change there applies to the next run that reads the file. The T3 Code model picker changes only that one thread's model. The "Where models are named" section of `USER.md` lists every other place a model is set.

Subagents and review panels spend extra tokens. To spend fewer, lower a role's effort or shorten a panel row in `models.md` (each model in a panel row runs one lane), and save `poteto-mode` for work that needs rigor. A small, obvious edit doesn't.

## Make the stack my own

- [`automate-me`](../automate-me/SKILL.md) drafts a personal mode skill from the developer's own history.
- [`wrap-up`](../wrap-up/SKILL.md) in a finished thread runs `retro` and `reflect` and merges their findings into one decision set.
- [`reflect`](../reflect/SKILL.md) after a session turns its lessons into skill edits the developer approves.
- [`correct`](../correct/SKILL.md) fixes the repo when the developer keeps correcting the same mistake.
- "/poteto-mode write a skill for <workflow>" runs the authoring playbook. The Eval playbook tests a skill change blind.
- Fix a misbehaving skill in its own commit, not inside the feature work where it went wrong.
- "Updating from upstream" in `USER.md` explains how new pstack versions come in.

## Reply

Lead with the answer. Give at most one example prompt in a code block, adapted from [`references/recipes.md`](references/recipes.md) when one fits, then the path of the file the answer came from. Keep it short unless the developer asked for the whole map.
