---
name: verify-electron
description: "Always load when checking a change in the real built Electron app instead of the browser dev view."
---

# Verify in the built Electron app

`scripts/verify-electron.mjs` drives the built app the way a user does. The real main window renders offscreen at 1440x900 on a fresh copy of the sample project, so no window reaches the developer's screen. Each worktree has its own session in `.tmp-vite/verify-electron/`, so parallel agents never collide. Run every command as `node scripts/verify-electron.mjs <command>`; `--help` lists them all. Each prints one JSON line with the route, any artifact path, and the `rendererErrors` and `mainFailures` seen during that command.

## Launch

1. Run `npm run build` after every source change. The script runs `dist/` and `dist-electron/`, never source.
2. Run `start`. It is ready when it prints `"ok":true` with an Overview screenshot path and `"staleBuild":false`. A new `start` replaces the previous session.

## Doctor

Run `doctor` first whenever anything looks off: a command fails oddly, a screenshot shows the wrong state, or you return to a session. It never launches. Drive only when it reports `"healthy":true`. `"staleBuild":true` means rebuild, then `start`.

## Drive

1. Open the feature's file in the [feature map](features/README.md). It names the entry points, fixtures, and the end state that proves the feature.
2. Run `snapshot` to see roles and accessible names, then act on targets by `--role <role> --name '<name>'`. A CSS selector is the fallback.
3. Act the way a user does with `click`, `type`, `press`, `hover`, `drag`, and `scroll`. `shot --route` navigates when a user would arrive by link.
   Confirms and native file or message dialogs never show offscreen: every command answers them (OK by default, Cancel with `--dismiss`, a file picker path with `--file`) and lists them under `dialogs`. Use `reload` for a renderer reload; `location.reload()` is blocked by the app's navigation guard.
4. Set another window size with `viewport <width> <height>`. It holds until `viewport --reset`, `reload`, or `start`, and every command reports the size under `viewport`.
5. Check a hover, focus ring, or pressed look with `force <target> --state hover|focus-visible|active`. It reports the computed styles the state changes on the target and its children, with a screenshot. The state ends when the command returns, so there is nothing to clear.
6. Wait with `wait <target>` or `wait --until '<expression>'`, never a sleep.
7. Use `eval` for fixture lookups through `window.app` and for read-only checks of stored values. Perform the action under test through the UI.

## Slow drags, frame samples, and computed styles

The script has no command for these yet. Until it does, write a probe script in the worktree's `.tmp-vite/`, where it can import the repo's helpers. Read `port` from `.tmp-vite/verify-electron/session.json`, take the `file:` page from `http://127.0.0.1:<port>/json/list`, and open its `webSocketDebuggerUrl` with `connectCdp` from `scripts/lib/electron-harness.mjs`.

- **Slow drag.** Get each end with `targetPoint(cdp, { role, name })` from `scripts/lib/page-targets.mjs`. Send `Input.dispatchMouseEvent` the way `drag` in `scripts/lib/cdp-input.mjs` does, and wait between the `mouseMoved` steps and before `mouseReleased`.
- **Frame samples.** Start a `requestAnimationFrame` loop through `Runtime.evaluate` that pushes the watched value into a page array each frame, act, then read the array back. For images, `Page.startScreencast` sends a `Page.screencastFrame` per painted frame; acknowledge each with `Page.screencastFrameAck`.
- **Computed styles.** `resolveTarget` from `scripts/lib/page-targets.mjs` gives the element's `objectId`. After `DOM.enable`, `CSS.enable`, and `DOM.getDocument`, `DOM.requestNode` turns it into the node id that `CSS.getComputedStyleForNode` reads. For hover, focus, and pressed looks, use `force`.

## Evidence

- The check is done when screenshots show the action and its resulting state with sample project data, a read-only second view confirms any stored change, and every command reported empty `rendererErrors` and `mainFailures`.
- Open each screenshot and look at it after every visible step.
- `start` clears `shots/`. Copy the artifacts you report to `~/.cache/agent-swarm/<slug>/` before the next `start`.

## Cleanup

Run `stop`. It ends the process group this session started and deletes the project copy. Screenshots and snapshots stay in `.tmp-vite/verify-electron/shots/`.

## Limits

Offscreen mode renders at scale 1 and has no on-screen window. Only native `title` tooltips, native menus, and compositor behavior need a visible window; check those with the `silent-workspace-test` skill. Focus and sizing work here: the page takes focus at the first `click` or `press`, after which `press Tab` draws focus rings, and `viewport` sets the size. Plain `APP_TEST_MODE=hidden` is unfit for visual checks: CDP screenshots hang, and `webContents.capturePage` stops the window drawing afterwards.
