# agent-skills

An agent skill stack for Claude Code and Codex, built for a desktop app
written mostly by coding agents. Most of it is adapted from other people's
skills; see [ATTRIBUTION.md](ATTRIBUTION.md) for who wrote what.

## Layout

- `skills/`: one directory per skill, each with a `SKILL.md`.
- `agents/`: Claude Code subagent definitions that some skills launch
  (`poteto-agent`, and the two `thermos` reviewers).
- `ATTRIBUTION.md`: the source and author of every skill.
- `licenses/`: license texts for each source.

## Install

Copy or symlink into a project:

```sh
cp -r skills <project>/.agents/skills        # Codex reads this
ln -s ../.agents/skills <project>/.claude/skills   # Claude Code reads the same files
cp -r agents <project>/.claude/agents
```

Or put them in `~/.claude/skills` and `~/.codex/skills` to use them everywhere.

## What's here

**Base: pstack, by Lauren Tan.** `poteto-mode` is the entry point. It matches a task to a
playbook and reads the `principle-*` skills when a step needs them. Also from
pstack: `architect`, `arena`, `automate-me`, `benchmark-checklist`,
`blast-radius`, `bro`, `correct`, `figure-it-out`, `how`, `interrogate`,
`poteto-help`, `recall`, `reflect`, `show-me-your-work`, `swarm`, `tdd`,
`teach`, `technical-writing`, `typescript-best-practices`, `unslop`, `why`.

**Verification, from pstack and Cursor:** `control-ui`, `control-cli`,
`verify-this`, `create-verification-skill`, and
`maintain-verification-skill`.

**Review, from Cursor:** `thermos`, `thermo-nuclear-review`,
`thermo-nuclear-code-quality-review`, and `deslop`.

**From Matt Pocock:** `grilling`, `domain-modeling`, `wizard`,
`writing-for-agents`, `retro`, `improve-codebase-architecture`, and part of
`diagnosing-bugs`.

**Design, from Emil Kowalski:** `prototype` and `design-foundations`.

**Written for this repo:** `alpha-build`, `backlog`, `repeat-mistakes`,
`run-app`, `silent-workspace-test`, `testing`, `ui-preferences`,
`user-communication`, `verify-electron`. These name
one app's scripts, docs, and sample data, so expect to rewrite them for
your project.

Ported skills are copies with Cursor-only tools translated to Claude Code and
Codex (see `skills/poteto-mode/references/harness-tools.md`) and model roles
in `skills/poteto-mode/references/models.md`. Some carry local edits.

## License

MIT, see `LICENSE`. Adapted skills keep their original MIT licenses and
copyright notices; see [ATTRIBUTION.md](ATTRIBUTION.md) and `licenses/`.
