# Specialty checks

Checks for one kind of change each. The kill-recovery test, scenarios, and
smokes run the production build, so run `npm run build` first.

| Command | Run when |
| --- | --- |
| `npm run test:kill-recovery` | Changing scene recovery writes or crash recovery. It SIGKILLs Electron after and during a recovery write, then checks the relaunched draft. Failures leave evidence in `.tmp-vite/kill-recovery/`. |
| `node scripts/dev-vite-signal-check.mjs` | Changing dev-server startup or shutdown. It runs `npm run dev` with offscreen windows, sends SIGINT and SIGTERM to its process group, and checks that Electron main exits before Vite with no GPU abort or leftover process. Needs no build. |
| `npm run scenario -- dense-board` | Changing board rendering, panning, or saved positions. It seeds a 300-node board in a headed window, pans, zooms, drags a note, reloads, and checks the screen and saved position. Failures leave evidence in `.tmp-vite/scenario/`. |
| `node scripts/electron-smoke.mjs --headed`, `node scripts/mcp-smoke.mjs --headed` | Debugging a failing smoke in a visible window. |
| `npm run security:audit` | Dependency advisories. Separate from `verify` because advisories change without a source change. |

## Smoke windows

`npm run test:smoke` also runs `scripts/quit-signal-check.mjs`: it sends
SIGTERM to the hidden app's whole process group and fails on anything but a
clean exit. `--runs <n>` repeats it. A failure here is a real Chromium abort,
so run it with `ulimit -c 0` to skip the core dump and its desktop
notification.

The Electron and MCP smokes use temporary user data and a temporary project,
with hidden windows by default. Hidden smoke still needs a display server and
does not check visible-window or focus behavior. The dense-board scenario and
every `--headed` run open a visible window, so load the `silent-workspace-test`
skill first to keep it off the developer's workspace and drawing.

Keep detailed workflows in the renderer suite; the smokes cover integration
only.

## Production error gates

The development error backlog is off in production builds. Instead,
kill-recovery, electron-smoke, the profile scripts, and scenarios fail on
uncaught renderer exceptions, unexpected `console.error` calls captured over
CDP, and known main failure lines. mcp-smoke, startup-profile, and manual
production passes have no renderer gate; record what the window and terminal
show.
