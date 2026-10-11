### Landing on main

Invoked at the end of every other playbook. Work lands on local `main`, with no PRs, CI, or forge.

**Worktree.** Work from a git worktree off local `main` (`git worktree add ../worktrees/<task> -b <branch> main`). With `git -C main worktree add`, pass an absolute path, because git resolves a relative one inside `main/`. Run `git worktree remove <path>` from `main`, because removing the worktree your shell stands in fails with a `getcwd` error. `git worktree add` links main's `node_modules` through `.githooks/post-checkout` when the lock file matches main's; otherwise hard-link from the worktree whose lock matches (the owner's when the branch changed dependencies). Never copy or link `samples/<sample>`'s database, because each checkout generates its own. Subagents inherit the worktree. Several subagents on the same branch each get their own worktree, or `git reset --hard <branch>` between them. Dirty branch with unrelated work: patch out, fresh worktree, apply. Snarled worktree: reset from `main`, redo minimally. Small interactive edits the user asks for directly may go straight on `main`. Never use `git stash`, which every worktree shares.

**Commits.** Commit liberally. Before landing, rebase into small, ordered commits, each landable on its own and ordered to tell the story. Amend when the fix belongs in a just-made commit. New commit when separable. Stage only the paths you changed (`git add <paths>`, never `git add -A` at the repository root). A delegate brief cuts its steps so each one ends green, and keeps each deletion in the step with the tests and fixtures that name it. A step that cannot end green commits as `WIP:` before the turn ends.

**Cleanup.** Run the **deslop** skill over the diff before commit and the **no-comments** skill before landing. Write every commit message with **technical-writing** (every layer except Diátaxis, one word per action, keep articles, a plain verb over `-ing` where one works), then apply **unslop**.

**Subjects.** Write the subject as a short, plain imperative sentence, as `git log --oneline -20` shows, with no Conventional Commits prefix and no trailing period. Name a real symbol when one carries the change, as in `Hash symlink targets in the feedback check instead of reading them`.

**Bodies.** The body is a briefing for a reader who has the diff, under about 40 lines, and does not restate the subject. It says why the change exists, what is out of scope, who or what it touches and why that is safe or risky, and how you proved it works. If `main` is red, state the cost of leaving it red. Full SHAs, swarm or arena lane recitals, lever-correction essays, file-by-file checklists, and "CLEAN" verdicts go in a linked artifact, not the body. For a performance change, report one primary number with its unit in `before → after` form.

**Check.** Run the feedback check before merging, and fix what it reports.

```bash
mise exec node@24.18.0 -- node scripts/feedback/check.mjs </dev/null
```

**Merge.** Rebase the branch onto current `main`, rerun the check if `main` moved, then run `node scripts/land.mjs <branch>` in `main`. It fast-forwards `main` when no uncommitted file there overlaps the branch. When the branch changed dependencies, run `mise exec node@24.18.0 -- npm install --no-audit --no-fund` in `main` after the merge. Remove the worktree once the branch lands. Never push unless the user asks.

**Another session's edits.** When main's checkout holds another session's uncommitted edits, `land.mjs` lands without asking and re-applies those edits. List in your reply every file it reports as lacking its edits or holding conflict markers, and leave the markers for the session that owns the file.

**Size.** Prefer five narrow commits to one large one. Independent work gets its own branch off `main`. Dependent work branches from its parent branch and lands after it.

A subagent that finishes a unit runs `interrogate`, `deslop`, and `no-comments`, commits on its branch, and reports the branch and head commit to the parent. The parent reviews the diff and merges. An Opus writer started from a Codex parent commits nothing, `WIP:` included, and reports its worktree and checks. The parent reviews, commits, and merges, per `../references/models.md`.
