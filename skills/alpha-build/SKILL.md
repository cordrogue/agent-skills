---
name: alpha-build
description: "Always load when planning or scoping a feature, or changing an API, schema, stored-data validation, project file format, configuration, or dependency, bug fixes included, and before adding a migration, compatibility layer (such as a looser read schema for old records), or security hardening."
---

# Alpha build

The app is an alpha. It drops the technical concerns of a production application but not the quality bar: everything that ships is polished.

## Drop production concerns

- **One project's data.** Data compatibility covers only the developer's own test project and the sample project, not other people's data or unknown history. When a format changes, a one-off converter for the developer's project is enough; it follows [`references/converters.md`](references/converters.md), and one that rebuilds a table follows [`references/sqlite-table-rebuild.md`](references/sqlite-table-rebuild.md), because a careless drop deletes child rows. This rule limits only which stored data a converter must handle: grade a lost ability the developer can reach on new data at its full severity, such as picking an ended faction after ending one. Speed on larger projects stays in scope, so keep timing gates that run on bigger generated projects. Never delete the developer's data.
- **No compatibility layers.** Support only the current version of APIs, schemas, file formats, configuration, and dependencies. Delete backward compatibility, legacy migrations, deprecation periods, shims, and fallback paths, and update callers, tests, and docs together. Conversions required by current features stay.
- **No excessive security.** the app is a local desktop app with one user. Keep the boundaries in [`docs/agents/local-automation-threat-model.md`](../../../docs/agents/local-automation-threat-model.md) and validate input where it enters the system. Skip production-service hardening. Guardrail lint stops the shortcuts an agent would plausibly take and is not a security boundary, so record a contrived bypass as accepted instead of fixing it.
- **Accessibility work is deferred.** Keep existing behavior, but don't gate work on it.

## Keep the quality bar

- Ship fewer things, finished. A feature that lands is correct, complete, and consistent with the rest of the app; a rough feature is unfinished, not alpha.
- Breaking changes cover code and data. UI conventions stay consistent and familiar.
- The UI is at its structure-first stage; the `ui-preferences` skill holds those rules.

For carrying out a breaking change, see `principle-migrate-callers-then-delete-legacy-apis` and `principle-outcome-oriented-execution`.
