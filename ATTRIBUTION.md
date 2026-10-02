# Attribution

Most of this repo is other people's work, copied and adapted under the MIT
license. Each source's license text is in `licenses/`. The adaptations add
Claude Code and Codex support, drop Cursor-only, pull request, and CI steps,
and carry local edits. Mistakes introduced in adapting them are this repo's,
not the original authors'.

## pstack by Lauren Tan

Source: [cursor/plugins](https://github.com/cursor/plugins), `pstack/` at
commit `2eb7ed46`. License: MIT, `licenses/pstack.txt`.

- `poteto-mode`, including its playbooks. `playbooks/landing-on-main.md`
  replaces the upstream `opening-a-pr` playbook. `references/harness-tools.md`
  and `references/models.md` are new here.
- Every `principle-*` skill.
- `architect` (`SKILL.md`, `references/design-red-flags.md`,
  `references/rationale-template.md`, `references/runner-prompt.md`),
  `arena`, `automate-me`, `blast-radius`, `bro`, `figure-it-out`, `how`,
  `interrogate`, `recall`, `reflect`, `show-me-your-work`, `swarm`, `tdd`,
  `teach`, `technical-writing`, `typescript-best-practices`, `unslop`, `why`.
  `why/references/sources/project-docs.md` is new here.
- `agents/poteto-agent.md`.

## Cursor

Source: [cursor/plugins](https://github.com/cursor/plugins) at commit
`2eb7ed46`. License: MIT, Copyright Cursor.

- From `thermos/` (`licenses/cursor-thermos.txt`): `thermos`,
  `thermo-nuclear-review`, `thermo-nuclear-code-quality-review`,
  `agents/thermo-nuclear-review-subagent.md`, and
  `agents/thermo-nuclear-code-quality-review-subagent.md`.
- From `cursor-team-kit/` (`licenses/cursor-team-kit.txt`): `deslop`.

## Matt Pocock

Source: [mattpocock/skills](https://github.com/mattpocock/skills) at commit
`d81f3a1`. License: MIT, `licenses/mattpocock-skills.txt`.

- `grilling`, `domain-modeling`, `wizard`, `writing-for-agents`, `retro`,
  `improve-codebase-architecture`.
- `architect/references/codebase-design.md`, `DEEPENING.md`, and
  `DESIGN-IT-TWICE.md`, from his `codebase-design` skill.
- `diagnosing-bugs`: the "build a feedback loop" section of his skill of the
  same name.

## Emil Kowalski

Source: [emilkowalski/skills](https://github.com/emilkowalski/skills) at
commit `d16ebe6`. License: MIT, `licenses/emilkowalski-skills.txt`.

- `prototype`, including `PICKER.md`.
- `design-foundations`: the design principles and process sections of his
  `apple-design` skill.

## open-pstack by Eric Litman

Source: [ericlitman/open-pstack](https://github.com/ericlitman/open-pstack) at
commit `1c91e65`. License: MIT, `licenses/ericlitman-open-pstack.txt`.

No files are copied. The approach in `poteto-mode/references/harness-tools.md`
and `models.md` for translating Cursor tools to Claude Code and Codex follows
his port.

## Ideas credited inside the skills

These skills build on published ideas and name them where they are used:

- John Ousterhout, *A Philosophy of Software Design*: deep modules and
  "Design It Twice" (`architect/references/`).
- Michael Feathers, *Working Effectively with Legacy Code*: the "seam"
  (`architect/references/codebase-design.md`).
- Apple's WWDC talk *Principles of Great Design*, as summarized by Emil
  Kowalski (`design-foundations`).

## Written for this repo

`alpha-build`, `backlog`, `run-app`, `testing`, `ui-preferences`,
`user-communication`, `verify-electron`. MIT, see `LICENSE`.
