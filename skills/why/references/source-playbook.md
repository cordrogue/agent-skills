# Source playbooks

The why skill spawns one investigator per available evidence source. Source control and project docs each read the playbook below. An MCP investigator adapts the investigator prompt to its MCP's tools.

| Category | Playbook | Where it searches |
|---|---|---|
| Source control history | [`code-archaeology.md`](./sources/code-archaeology.md) | git |
| Project docs | [`project-docs.md`](./sources/project-docs.md) | `docs/` |

Cross-cutting:

- [`incident-postmortem.md`](./sources/incident-postmortem.md). Add this if the target code looks defensive (null checks, retry, timeout, rate limit, feature flag, egress guard, OOM handler).
