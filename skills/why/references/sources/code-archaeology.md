# Code Archaeology (git + in-repo)

## What this source contains

- Commit history (messages, dates, authors, diffs)
- Merge commits and their branch names
- Inline code comments, TODOs, FIXMEs, deprecation notes
- ADRs (architectural decision records) if the repo keeps them
- Tests, whose names and assertions often encode the edge cases that motivated a change
- Related files modified in the same commits (co-change signal)
- CHANGELOG entries and release notes in the repo
- Plan or doc paths mentioned in commit messages

The most trustworthy source, tied directly to the code, and the most complete. Everything that went through the repo should be here.

## How to search it

Expand the seed commit list:

```bash
# History through renames
git log --follow --oneline -- <file>

# Pickaxe: commits that added or removed this exact text
git log -S '<exact_string_from_code>' -- <file>

# Or for patterns:
git log -G '<regex>' -- <file>

# Who wrote each line and when
git blame -L <start>,<end> <file>

# One commit's full diff
git show <hash>

# Commits between two points affecting this file
git log <old>..<new> -p -- <file>
```

For each substantive commit, read its full message, then any merge context:

```bash
# Full message of the commit
git log -1 --format=%B <hash>

# Candidate merge that brought it into main
git log --merges --first-parent --ancestry-path --reverse --format=%h <hash>..main | head -1

# Succeeds if <hash> was on main before this merge, so this merge did not bring it in
git merge-base --is-ancestor <hash> <merge>^1

# Sibling commits on the same branch, when the check above fails
git log --oneline <merge>^1..<merge>^2
```

With no introducing merge, report that and rely on the commit and doc evidence. A target that is a merge is its own merge context.

Look for out-of-band docs:

```bash
# ADRs often live in docs/adr/ or similar
rg -l -i 'architecture.decision' --glob '*.md'

# TODOs and FIXMEs near the target
rg -n -C2 '(TODO|FIXME|HACK|XXX|NOTE)' <target_file>

# Related tests
rg -l '<symbol>' --glob '*test*'
```

## What good evidence looks like here

- A commit body that explains the problem, not just the change ("This fixes the pagination bug that caused X")
- An inline comment near the target line that explains a non-obvious constraint
- A test named `test_handles_edge_case_when_X` that reveals a motivating edge case
- A commit message that references a plan, review, or backlog entry
- A CHANGELOG entry that summarizes the user-visible rationale

## Common pitfalls

- **Squashed history.** A squashed branch loses its individual commits. Fall back to the squash commit body and any plan it names.
- **Misleading commit messages.** "Small refactor" sometimes hides an intentional behavior change. Look at the diff, not the message.
- **Cargo-culted patterns.** The author may have copied a pattern without understanding why. Check whether it originated earlier in the codebase, and investigate *that* commit.
- **Bot commits and auto-merges.** Dependabot, Renovate, and automated backports usually carry no motivation. Skip them when looking for intent.
- **Treating code as evidence of intent.** The code isn't evidence for why it exists. Evidence comes from commit messages, comments, tests, and docs. Don't cite "the function is named X" as evidence of intent.

## What to return

Every commit/comment that bears on the question, with:
- The exact text (quoted)
- The hash / file:line
- Author and date
- Whether it's direct (explicitly addresses the question) or circumstantial
