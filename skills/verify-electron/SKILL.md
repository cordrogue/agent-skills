---
name: verify-electron
description: "Always load when checking a change in the real built Electron app instead of the browser dev view."
---

# Verify in the built Electron app

`scripts/verify-electron.mjs` drives the built app the way a user does. The real main window renders offscreen at 1440x900 on a fresh copy of the sample project, so no window reaches the developer's screen. Each worktree has its own session in `.tmp-vite/verify-electron/`, so parallel agents never collide. Run every command as `node scripts/verify-electron.mjs <command>`; `--help` lists them all. Each prints one JSON line. A command that reaches the page reports the route, any artifact path, and the `rendererErrors` and `mainFailures` seen during that command, and a failed one reports them beside its `error`.

## Launch

1. Run `npm run build` after every source change. The script runs `dist/` and `dist-electron/`, never source.
2. Run `start`. It is ready when it prints `"ok":true`, `"screen":"overview"`, a screenshot path, and `"staleBuild":false`. A new `start` replaces the previous session.
3. To open an existing project instead of the sample, run `start --project <path>` on a copy, never the original. When the app cannot open it, `start` still prints `"ok":true`, with `"screen":"refused"`, the app's message in `"refusal"`, and a screenshot. `stop` leaves a `--project` folder in place.
4. To check a packaged build, run `npm run package:dir`, then `start --executable release/linux-unpacked/app`. It reports `"staleBuild":null`, because the packaged app carries its own copy of `dist/`. Never install a packaged build.

## Doctor

Run `doctor` first whenever anything looks off: odd command failures, wrong screenshot states, or returning to a session. It never launches. Drive only when it reports `"healthy":true`. `"staleBuild":true` means rebuild, then `start`.

## Drive

1. Open the feature's file in the [feature map](features/README.md). It names the entry points, fixtures, and the end state that proves the feature.
2. Run `snapshot` to see roles and accessible names. A tree of up to 80 lines, such as `snapshot --role dialog`, prints under `tree`; a longer one is in the file it names. Then target `--role <role> --name '<name>'`. A CSS selector is the fallback.
3. Act as a user does with `click`, `type`, `press`, `hover`, `drag`, and `scroll`. `shot --route` navigates when a user would arrive by link; a route the app does not have fails at once and names where the app went.
   A native `<select>` list never shows offscreen; choose an option with `select <target> --option '<label>'`, which opens it and presses the arrow keys and Enter.
   For a slow drag, `--steps <n> --step-ms <ms>` spaces the moves and `--hold-ms <ms>` holds the button at the drop point before release. `drag --button middle` (or `right`) holds that button instead of the left one, as `click --button` does.
   Confirms and native file or message dialogs never show offscreen. Every command answers them (OK by default, Cancel with `--dismiss`, a file picker path with `--file`; a file picker without `--file` cancels) and lists them under `dialogs`. A dialog opened after a command returns is listed by the next command. Use `reload` for a renderer reload; the app's navigation guard blocks `location.reload()`.
   To prove something survives a restart, such as a saved view, run `restart`. It quits through the window close, so local storage is saved, and relaunches on the same project and user data. When the app relaunches itself, as Restart the app does, the next command follows the new process, waiting up to 10 s for it. Electron gives that process no output, so `mainFailures` stops at the relaunch.
4. `viewport <width> <height>` sets another window size until `viewport --reset`, `reload`, or `start`. Every command reports the size under `viewport`.
5. Check a hover, focus ring, or pressed look with `force <target> --state hover|focus-visible|active`. It reports the computed styles the state changes on the target and its children, with a screenshot. The state ends when the command returns.
   For the resting look, `styles <target>` reports the box and the computed styles that differ from the browser default; `--property color,padding-top` limits it to those.
6. Wait with `wait <target>` or `wait --until '<expression>'`, never a sleep.
7. Watch a value frame by frame with `record --eval '<expression>' --during <command>`, the command written after `--during` as usual. It writes every frame's value to a file and reports the frame count, longest frame gap, and changes; `--after-ms` keeps sampling after the command. It samples each document the page loads and tags each sample with its document, so `--during reload` times a reload.
8. Use `eval` for fixture lookups and read-only checks of stored values, through `window.appHost.invoke('<command>', <input>, { at: <tick> })`, such as `records.bestiary.get` with `{ id: 1 }`. `invoke` resolves to `{ output }` on success and `{ appError: { code, message } }` on a refusal, never throws for a refusal, and `eval`'s `value` wraps that payload. A command that takes no input gets `undefined`, not `{}`. Perform the action under test through the UI.
9. To see a failed read and its Retry, run `fail-next <host command>`, such as `fail-next framework:graph`, then do what makes the page read; the host fails that command's next request once. Writing the project database changes nothing on screen, because the host serves records from memory, and killing the host process ends the session.
10. `db '<sql>'` runs one read-only statement on the session's project database; `db` alone lists tables and columns. `mcp <tool> '<json>'` calls the app's MCP tools as an agent would; `mcp` alone lists each tool's arguments.

## Evidence

- The check is done when screenshots show the action and its resulting state with sample project data, a read-only second view confirms any stored change, and every command reported empty `rendererErrors` and `mainFailures`.
- Open and look at each screenshot after every visible step.
- When the change alters behavior a file in `features/` describes, update that file in the same commit.
- Record a video with `video start`, the commands that show the change, and `video stop`, which writes a 1440x900 H.264 mp4 to `shots/` and prints its path and duration. `stop` and `start` end a running recording without writing a video.
- `compare a.png b.png` counts the exactly differing pixels (`--threshold <0-255>` tolerates small channel differences) and writes a diff image with them in red.
- `start` clears `shots/`. Copy the artifacts you report to `~/.cache/agent-swarm/<slug>/` before the next `start`.

## Cleanup

Run `stop`. It ends the process group this session started and deletes the sample copy. Screenshots and snapshots stay in `.tmp-vite/verify-electron/shots/`.

## Limits

Offscreen mode renders at scale 1 with no on-screen window. Only native `title` tooltips, native menus, and compositor behavior need a visible window; check those with the `silent-workspace-test` skill. Focus and sizing work here: the page takes focus at the first `click` or `press`, after which `press Tab` draws focus rings. Plain `APP_TEST_MODE=hidden` is unfit for visual checks: CDP screenshots hang, and `webContents.capturePage` stops the window drawing afterwards.
