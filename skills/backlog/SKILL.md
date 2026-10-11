---
name: backlog
description: "Always load when you find a problem outside the current task's scope, or when a skill says to file a backlog item, issue, or ticket."
---

# Backlog

The project has no issue tracker. Out-of-scope problems go in [`docs/BACKLOG.md`](../../../docs/BACKLOG.md), and any skill that says to file an issue, ticket, or backlog item means that file.

- Don't fix an out-of-scope problem in the current change. File it and keep going.
- When a helper's report names an out-of-scope problem it did not file, file it before you accept the work.
- One line per entry, naming the problem, not the fix. For longer entries, write and link a `docs/work/` paper.
- File it under the closest existing group, adding a group only when none fits.
- Before adding, check for an existing entry, and update or merge it instead of duplicating.
- Remove an entry when its problem is fixed, in the same change as the fix. Parallel lanes that fix backlog entries leave `docs/BACKLOG.md` alone; whoever takes a lane's commit removes its line in that commit.
- Before you remove a user-visible entry that another change fixed, reproduce it on the current head, on the surface where the user sees it. A commit message or a unit test is not that check.
- Mention what you filed in your reply to the developer.
