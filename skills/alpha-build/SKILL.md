---
name: alpha-build
description: "Always load when planning or scoping a feature, or changing an API, schema, project file format, configuration, or dependency, and before adding a migration, compatibility layer, or security hardening."
---

# Alpha build

The app is an alpha. Alpha drops the technical concerns of a production application. It does not lower the quality bar: everything that ships is polished.

## Drop production concerns

- **One project's data.** Data compatibility covers only the developer's own test project and the sample project. Don't design for other people's data or unknown history. When a format changes, a one-off converter for the developer's project is enough. The limit is about compatibility, not size. Speed on larger projects stays in scope, so keep timing gates that run on bigger generated projects. Never delete the developer's data. A converter that rebuilds a table follows [`references/sqlite-table-rebuild.md`](references/sqlite-table-rebuild.md), because a careless drop deletes child rows.
- **No compatibility layers.** Support only the current version of APIs, schemas, file formats, configuration, and dependencies. Backward compatibility, legacy migrations, deprecation periods, shims, and fallback paths are bloat; delete them and update callers, tests, and docs together. Conversions required by current features stay.
- **No excessive security.** The app is a local desktop app with one user. Keep the boundaries in [`docs/agents/local-automation-threat-model.md`](../../../docs/agents/local-automation-threat-model.md) and validate input where it enters the system. Skip the hardening a production service would need. Guardrail lint stops the shortcuts an agent would plausibly take; it is not a security boundary, so record a contrived bypass as accepted instead of fixing it.
- **Accessibility work is deferred.** Keep existing behavior, but it does not gate work.

## Keep the quality bar

- Ship fewer things, finished. A feature that lands is correct, complete, and consistent with the rest of the app. A rough feature is not an alpha feature; it is unfinished.
- Breaking changes cover code and data. UI conventions stay consistent and familiar.
- The UI is at its structure-first stage; the `ui-preferences` skill holds those rules.

The pstack principles `principle-migrate-callers-then-delete-legacy-apis` and `principle-outcome-oriented-execution` describe how to carry out a breaking change.
