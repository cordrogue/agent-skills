---
name: testing
description: "Always load when writing, changing, or running tests, verifying a change before calling it done, or reviewing runtime errors."
---

# Testing

Follow [`docs/TEST.md`](../../../docs/TEST.md). It is the source of truth for:

- **Commands:** the lightest check that covers the change, and `verify` before a merge.
- **Test design** and **placement and concurrency.**
- **Turn-end feedback:** the Stop hook runs `scripts/feedback/check.mjs`. Run it yourself with stdin closed (`</dev/null`), or it hangs.
- **Runtime error backlog:** `npm run errors`.
- **Live review** of the running app, through the `run-app` skill, or of the built Electron app, through the `verify-electron` skill.
- **Performance evidence.**

For test-first bug fixes use the `tdd` skill. For what makes a test worth keeping, read `principle-test-behavior-not-implementation`.
