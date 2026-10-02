# Code Archaeology (git + in-repo)

## What this source contains

- Commit history (messages, dates, authors, diffs)
- Merge commits and their branch names
- Inline code comments, TODOs, FIXMEs, deprecation notes
- ADRs (architectural decision records) if the repo keeps them
- Tests. Names and assertions often encode the edge cases that motivated a change
- Related files modified in the same commits (co-change signal)
- CHANGELOG entries, release notes in the repo
- Plan or doc paths mentioned in commit messages

The most trustworthy source, tied directly to the code, and the most complete. Everything that went through the repo should be here.

## How to search it

Expand the seed commit list:

```bash
# Full history of the file through renames
git log --follow --oneline -- <file>

# Pickaxe: commits that added or removed this exact text
git log -S '<exact_string_from_code>' -- <file>

# Or for patterns:
git log -G '<regex>' -- <file>

# Who wrote each line and when
git blame -L <start>,<end> <file>

# The full diff of a specific commit
git show <hash>

# Commits between two points affecting this file
git log <old>..<new> -p -- <file>
```

For each substantive commit, pull the merge context:

```bash
# Full message of the commit
git log -1 --format=%B <hash>

# The merge that brought it into main, and the branch name
git log --merges --ancestry-path --oneline <hash>..main | tail -1

# Sibling commits on the same branch
git log --oneline <merge>^1..<merge>^2
```

Look for out-of-band docs:

```bash
# ADRs often live in docs/adr/ or similar
rg -l -i 'architecture.decision' --glob '*.md'

# TODOs and FIXMEs near the target
rg -n -C2 '(TODO|FIXME|HACK|XXX|NOTE)' <target_file>

# Related tests. Names often encode the "why"
rg -l '<symbol>' --glob '*test*'
```

## What good evidence looks like here

- A commit body that explains the problem being solved, not just the change ("This fixes the pagination bug that caused X")
- An inline comment near the target line that explains a non-obvious constraint
- A test named `test_handles_edge_case_when_X` that reveals an edge case motivating the code
- A commit message that references a plan, review, or backlog entry
- A CHANGELOG entry that summarizes the user-visible rationale

## Common pitfalls

- **Squashed history.** A squashed branch loses its individual commits. Fall back to the squash commit body and any plan it names.
- **Misleading commit messages.** "Small refactor" sometimes hides an intentional behavior change. Look at the diff, not the message.
- **Cargo-culted patterns.** The author may have copied a pattern without understanding why. Check if the pattern originated earlier in the codebase and investigate *that* commit.
- **Bot commits and auto-merges.** Dependabot, Renovate, and automated backports usually don't carry motivation. Skip them when trying to find intent.
- **Treating code as evidence of intent.** The code itself isn't evidence for why it exists. Evidence comes from commit messages, comments, tests, docs. Don't cite "the function is named X" as evidence of intent.

## What to return

Every commit/comment that bears on the question, with:
- The exact text (quoted)
- The hash / file:line
- Author and date
- Whether it's direct (explicitly addresses the question) or circumstantial
