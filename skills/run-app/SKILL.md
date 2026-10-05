---
name: run-app
description: Use when asked to start, open, or view the app in the built-in T3 Code browser or the Codex browser.
---

# Open the app in the built-in browser

The managed session script owns preflight, the selected project, the dynamic
URL, detachment, and shutdown. Never start Vite or Electron directly. Do not
use `nohup` or a PTY as a workaround for status visibility.

## Launch

When command tools use a restricted sandbox, run every lifecycle command and
localhost probe with the tool's supported permission escalation or equivalent
host visibility. This includes the first `app:status` call, even if this turn
has not started the app. Keep that visibility consistent for `app:start`,
`app:stop`, later status checks, and the bridge fallback.

```bash
npm run --silent app:status -- --json
```

A sandboxed `stopped` result alone must not trigger start, stop, or state
cleanup. Check status with host visibility first. Process visibility errors
can appear as `stopped`, and starting then clears managed state while the
previous runtime may still be alive.

If it reports `ready` for the requested browser workspace and project with an
empty `restartFor`, reuse that session and its `rendererUrl`. If it reports
`starting`, wait for that start to finish and check status again. Start only
when it reports `stopped`:

```bash
npm run app:start -- --browser && npm run --silent app:status -- --json
```

`restartFor` lists files loaded only at start (dependencies, the Vite config,
the database baseline, dev launch scripts) that changed after the process
loading them started. The session restarts its dev server on its own a few
seconds after a dependency, Vite config, or baseline change and reports
`starting` until the new server is ready; a dev launch script change needs a
session restart. Backend code reloads on its own, so a `restartFor` that stays
nonempty or a `failed` state with its `error` is the signal to restart: run
`npm run app:restart`, which keeps the session's mode and clears the replaced
server's runtime errors. A start rebuilds the generated sample when the
baseline changed.

Do not open the browser until status reports `ready` with a nonempty
`rendererUrl`.

Respect an explicitly selected `APP_PROJECT_PATH`, and keep it separate
from any project an Electron window has open. Without one, the session uses the
generated sample project. The port is dynamic, so use
the exact `rendererUrl` returned by status.

In T3 Code, open the real URL once with `preview_open` using `open: true` and
`url: rendererUrl`. Keep the returned `tabId`. In the Codex browser, navigate
one tab directly to `rendererUrl`. Wait or take a snapshot in that tab and
verify `Overview` before reporting that the app opened. Do not call browser
preview status first or open a blank tab as a probe.

To check a reported symptom, find its route, fixture, and test in
the [verification map](../verify-electron/features/README.md).

## Browser unavailable

If the tool reports `No preview automation host is available`, the blocker is
the browser integration, not the app runtime. Do not repeat that call
without evidence that a host recovered, and do not restart the app to
repair it. For this or another browser error, use the fallback below and
report the exact browser blocker.

T3's desktop renderer registers the preview host for each connected
environment; opening the preview panel is not required. If the missing-host
error persists, ask the user to reconnect or reload the T3 desktop window for
the current environment, then retry `preview_open` once after reconnecting.
This is a recovery attempt, not a guaranteed fix. The available browser tools
cannot repair host registration.

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
  data: { kind: "request", id: 1, key: "listCharacters", input: {} } }));
socket.onmessage = ({ data }) => {
  const message = JSON.parse(data);
  if (message.event !== "app:wire" || message.data.id !== 1) return;
  console.log(JSON.stringify(message.data));
  process.exit(0);
};' "$renderer_url")"
node -e 'const b=JSON.parse(process.argv[1]); if(b.kind!=="reply"||!Array.isArray(b.envelope.output))process.exit(3); console.log(`bridge ready (${b.envelope.output.length} characters)`)' "$bridge_json"
```

The `output` must be an array; an empty array is valid. A reply alone is not
enough. This check proves the runtime and bridge respond. It does not
fulfill a request to view the app. Report that the browser request remains
unfulfilled, name the exact browser blocker, and leave a ready runtime
running. If the check fails, report the bridge failure and do not claim that
the runtime was verified.

## Restart and recovery

Stop a session only when the user asks, or when a restart is justified by a
different mode or project, or by changes to the dev launch scripts
(`scripts/dev-*.mjs`). Renderer `.tsx` edits hot-reload; renderer `.ts` edits
reload the page and drop unsaved UI state. Backend edits restart the dev
server and reload the page on their own. For a justified restart:

```bash
npm run app:stop
npm run app:start -- --browser
```

For any nonzero start, read `.tmp-vite/dev-session.log` before changing the
launch method. On bind `EPERM`, rerun the managed start with supported
permission escalation, then check status with the same visibility.

- If the generated sample is not at the current database baseline, stop the
  session, run `npm run sample:build`, and start again.
- If a selected path has no project manifest, keep the user's
  project intent explicit. Ask for or build the intended project with
  `npm run sample:build -- <dir>`. Use the generated sample project only
  when that matches the request.
- If status reports another running mode or project, stop it only when the
  requested view requires replacing it, then start the requested session.
