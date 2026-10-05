### Landing on main

Invoked at the end of every other playbook. Work lands on local `main`. There are no PRs, no CI, and no forge.

**Worktree.** Work from a git worktree off local `main` (`git worktree add ../worktrees/<task> -b <branch> main`). With `git -C main worktree add`, pass an absolute path, because git resolves a relative one inside `main/`. Remove a worktree from `main` (`cd` there, then `git worktree remove <path>`); removing the one your shell stands in fails with a `getcwd` error. Hardlink `node_modules` from `main` (`cp -al ../../main/node_modules node_modules`) instead of installing. Never copy or link `samples/<sample>`'s database: each checkout generates its own. Subagents inherit the worktree. Several subagents on the same branch each get their own worktree, or `git reset --hard <branch>` between them. Dirty branch with unrelated work: patch out, fresh worktree, apply. Snarled worktree: reset from `main`, redo minimally. Small interactive edits the user asks for directly may go straight on `main`. Never use `git stash`. The stash is shared across worktrees.

**Commits.** Commit liberally. Rebase into small, ordered commits before landing. Each commit is landable on its own and ordered to tell the story. Amend when the fix belongs in a just-made commit. New commit when separable. Stage only the paths you changed (`git add <paths>`, never `git add -A` at the repository root).

**Cleanup.** Run the **deslop** skill over the diff before commit. Write every commit message with the **technical-writing** skill, then apply **unslop**. Apply every technical-writing layer except Diátaxis. Use one word for each action, keep articles, and avoid `-ing` when a plain verb works.

**Subjects.** Write the subject as a plain imperative sentence, as `git log --oneline -20` shows. No Conventional Commits prefix. Keep the subject short. Name a real symbol when one carries the change. For example, `Hash symlink targets in the feedback check instead of reading them`. Do not add a trailing period.

**Bodies.** The commit body is a briefing, not the lab notebook. A reader who has the diff should learn why the change exists, what is out of scope, and how you proved it works. Keep it under about 40 lines. A body does not restate its subject. Do not paste full SHAs, swarm or arena lane recitals, lever-correction essays, file-by-file checklists, or "CLEAN" verdicts. Put those in a linked artifact. For a performance change, report one primary number with its unit in `before → after` form.

**Check.** Run the feedback check before merging, and fix what it reports.

```bash
mise exec node@24.18.0 -- node scripts/feedback/check.mjs </dev/null
```

**Merge.** Rebase the branch onto current `main`, rerun the check if `main` moved, then merge locally into `main`. When the branch changed dependencies, run `mise exec node@24.18.0 -- npm install --no-audit --no-fund` in `main` after the merge. Remove the worktree once the branch has landed. Never push unless the user asks.

**Another session's edits.** When main's checkout holds another session's uncommitted edits, land without asking by running `node scripts/land.mjs <branch>` in main, and put every file it reports as lacking its edits or holding conflict markers in your reply.

**Size.** Prefer five narrow commits to one large one. Independent work gets its own branch off `main`. Dependent work branches from its parent branch and lands after it.

A subagent that finishes a unit runs `interrogate` and `deslop`, commits on its branch, and reports the branch and head commit to the parent. The parent reviews the diff and merges.
