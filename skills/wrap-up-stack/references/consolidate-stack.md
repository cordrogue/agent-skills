# Consolidate a wrap-up stack

The `wrap-up-stack` skill started this thread after the last thread of a stack finished. Your first message names the stack, each thread with its retro and reflect reports, and the path of the combined report you write. Follow [`consolidate.md`](../../wrap-up/references/consolidate.md) with these changes:

- **Read.** Read every report your first message lists, and the Stacks section of [`report-format.md`](../../wrap-up/references/report-format.md). Each report's `sources` header names its thread's transcripts.
- **Merge.** Merge findings across every thread at once. At equal severity, a problem raised in more than one thread ranks above one raised by both reports of one thread, which ranks above a single report's finding. Each source names its thread, as in the Stacks section.
- **Find leftovers** for every thread in the stack.
- **Review.** In the review task message, replace the Retro report, Reflect report, and Thread transcript lines with `Source reports:` and every report path. The transcripts are in each report's `sources` header. Use `wrap-up-stack review: <stack>` as the title.
- **Commit** with the subject `Add the wrap-up reports for the <stack> stack`.
