---
name: run-app
description: Use when asked to start, open, or view the app in the built-in T3 Code browser or the Codex browser.
---

# Open the app in the built-in browser

The managed session script owns preflight, the selected project, the dynamic
URL, detachment, and shutdown. Never start Vite or Electron directly, and don't
use `nohup` or a PTY to work around status visibility.

## Launch

In a restricted command sandbox, run every lifecycle command and localhost
probe with the tool's supported permission escalation or equivalent host
visibility, starting with the first `app:status` call even if this turn has not
started the app. Keep that visibility for `app:start`, `app:stop`, later status
checks, and the bridge fallback.

```bash
npm run --silent app:status -- --json
```

Never start, stop, or clean up state on a sandboxed `stopped` result alone;
check status with host visibility first. Process visibility errors can appear
as `stopped`, and a start then clears managed state while the previous runtime
may still be alive.

If status reports `ready` for the requested browser workspace and project with
an empty `restartFor`, reuse that session and its `rendererUrl`. If it reports
`starting`, wait for that start to finish and check again. Start only when it
reports `stopped`:

```bash
npm run app:start -- --browser && npm run --silent app:status -- --json
```

`restartFor` lists files loaded only at start (dependencies, the Vite config,
the database baseline, dev launch scripts) that changed after the process
loading them started. A few seconds after a dependency, Vite config, or
baseline change, the session restarts its dev server and reports `starting`
until the new server is ready; a dev launch script change needs a session
restart. A `restartFor` that stays nonempty, or a `failed` state with its
`error`, means run `npm run app:restart`, which keeps the session's mode and
clears the replaced server's runtime errors. A start rebuilds the generated
sample when the baseline changed.

Respect an explicitly selected `APP_PROJECT_PATH`, and keep it separate
from any project an Electron window has open. Without one, the session uses the
generated sample project.

Open the browser only once status reports `ready` with a nonempty
`rendererUrl`, and use that exact URL, since the port is dynamic.

In T3 Code, open the real URL once with `preview_open` using `open: true` and
`url: rendererUrl`, and keep the returned `tabId`. In the Codex browser,
navigate one tab directly to `rendererUrl`. Wait or take a snapshot in that tab
and verify `Overview` before reporting that the app opened. Don't call browser
preview status first or open a blank tab as a probe.

To check a reported symptom, find its route, fixture, and test in the
[verification map](../verify-electron/features/README.md).

## Browser unavailable

`No preview automation host is available` means the browser integration is
blocked, not the app runtime. Don't repeat that call without evidence that
a host recovered, and don't restart the app to repair it. For this or another
browser error, use the fallback below and report the exact browser blocker.

T3's desktop renderer registers the preview host for each connected
environment; the preview panel need not be open. If the missing-host error
persists, ask the user to reconnect or reload the T3 desktop window for the
current environment, then retry `preview_open` once after reconnecting. It may not help, and
the browser tools cannot repair host registration.

Confirm that app status still reports a ready browser session, then use its
current URL for one read-only request over the dev server's WebSocket:

```bash
set -e
status_json="$(npm run --silent app:status -- --json)"
renderer_url="$(node -e 'const s=JSON.parse(process.argv[1]); if(s.state!=="ready"||s.mode!=="browser"||!s.rendererUrl)process.exit(2); process.stdout.write(s.rendererUrl)' "$status_json")"
bridge_json="$(node -e '
const url = new URL("/", process.argv[1]);
url.protocol = url.protocol.replace("http", "ws");
const socket = new WebSocket(url, "vite-hmr");
setTimeout(() => process.exit(4), 10_000);
socket.onopen = () => socket.send(JSON.stringify({ type: "custom", event: "app:wire",
  data: { kind: "request", id: 1, key: "listLocations", input: {} } }));
socket.onmessage = ({ data }) => {
  const message = JSON.parse(data);
  if (message.event !== "app:wire" || message.data.id !== 1) return;
  console.log(JSON.stringify(message.data));
  process.exit(0);
};' "$renderer_url")"
node -e 'const b=JSON.parse(process.argv[1]); if(b.kind!=="reply"||!Array.isArray(b.envelope.output))process.exit(3); console.log(`bridge ready (${b.envelope.output.length} places)`)' "$bridge_json"
```

The `output` must be an array, possibly empty; a reply alone is not enough.
This check proves the runtime and bridge respond but does not fulfill a request
to view the app. Report that the browser request remains unfulfilled, name the
exact browser blocker, and leave a ready runtime running. If the check fails,
report the bridge failure and don't claim the runtime was verified.

## Restart and recovery

Stop a session only when the user asks, or when a different mode or project,
or a change to the dev launch scripts (`scripts/dev-*.mjs`), justifies a
restart. Renderer `.tsx` edits hot-reload; renderer `.ts` edits reload the page
and drop unsaved UI state. Backend edits restart the dev server and reload the
page on their own. For a justified restart, run `npm run app:restart`, adding
`-- --browser` or `-- --electron` to change mode. It stops and starts the
session and clears the replaced server's runtime errors, which a manual stop
and start leaves behind.

For any nonzero start, read `.tmp-vite/dev-session.log` before changing the
launch method. On bind `EPERM`, rerun the managed start with supported
permission escalation, then check status with the same visibility.

- If the generated sample is not at the current database baseline, stop the
  session, run `npm run sample:build`, and start again.
- If a selected path has no the app project manifest, keep the user's project
  intent explicit: ask for or build the intended project with
  `npm run sample:build -- <dir>`. Use the generated sample project only
  when that matches the request.
- If status reports another running mode or project, stop it only when the
  requested view requires replacing it, then start the requested session.
