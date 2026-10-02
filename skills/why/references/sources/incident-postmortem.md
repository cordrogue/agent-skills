# Incident & Postmortem Context

Not a separate source, a **cross-cutting angle**. Incidents often motivate defensive code ("we added this check after the X outage"), so if the target looks defensive (null checks, retry logic, timeout handling, rate limiting, feature flags), specifically hunt for incident history across every available source:

- **Project docs**: search `docs/work/` reviews and `docs/BACKLOG.md` for the target file, feature, or error string
- **Git**: commits with messages like "fix for incident", "add defensive check", "revert" followed by "re-apply with..." are strong signals
- **Runtime error log**: `npm run errors` lists recorded runtime errors with stacks. An error whose stack runs through the target, recorded before the target's commit, is circumstantial support for an error-driven origin
- **MCP sources**: an error tracker or ticket tracker MCP, if one is present, for records around the dates the target code was added

If you find an incident link, fetch the full record. Reviews and remediation plans in `docs/work/` typically have findings that tie directly to code changes. When multiple sources corroborate (a review finding names the error, a commit cites the review, and the error stops appearing after the fix), the evidence is especially strong.

Worth spending time on when the code's defensive character makes an incident-driven origin plausible. Skip it for code that doesn't look defensive.
