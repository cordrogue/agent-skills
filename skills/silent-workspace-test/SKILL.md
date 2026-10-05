---
name: silent-workspace-test
description: >
  Always load before launching a visible GUI window for testing (the app's
  Electron builds or any GUI binary). It keeps the window on Hyprland
  workspace 5 without switching the user's workspace or focus.
---

# Silent workspace testing

Never let a test window land on or focus the user's workspace. For app
checks that need no visible window, use the repo's `verify-electron` skill
instead: it renders offscreen and needs none of this.

Hyprland here uses Lua config: use `hyprctl eval`. `[workspace 5 silent]` exec
syntax and `hl.exec_cmd` rules do not work.

1. **One shared rule.** The app's window class is `app` (dev and installed
   builds); for another app, read its class from `hyprctl clients -j`. Check
   whether the rule is already installed:

   ```sh
   hyprctl eval 'error(tostring(_G.silent_test_rule ~= nil))'
   ```

   It prints `true` when installed. Otherwise the orchestrator installs it
   once for the whole run. A top-level session with no orchestrator above it
   is its own orchestrator; parallel agents and subagents never install it:

   ```sh
   hyprctl eval '_G.silent_test_rule = hl.window_rule({ name = "silent-test", match = { class = "^app$" }, workspace = "5 silent", focus_on_activate = false, no_initial_focus = true, render_unfocused = true, float = true, size = { 1440, 900 } })'
   ```

   - `focus_on_activate = false`: Electron activates its window on show, which
     otherwise switches the monitor to workspace 5.
   - `render_unfocused = true`: without it, a window on an unviewed workspace
     draws no frames, `requestAnimationFrame` never fires, and the app stalls.
     It draws at `misc:render_unfocused_fps` (15 by default).
   - `float = true, size = { 1440, 900 }`: tiling would otherwise split
     workspace 5 among every window on it and produce tall, narrow windows.
   - While the rule is installed, the user's own app launches also land on
     workspace 5.
   - The rule suppresses focus and fixes the window size, so a window under it
     cannot show focus or sizing behavior. Ask the user to check those.

2. **Launch** from the checkout after `npm run build`, on a throwaway copy of
   the sample. The Claude Code shell sets `ELECTRON_RUN_AS_NODE=1`, so unset it:

   ```sh
   (env -u ELECTRON_RUN_AS_NODE APP_USER_DATA=<tmp>/user-data APP_PROJECT_PATH=<tmp>/project setsid node_modules/.bin/electron . --remote-debugging-port=0 >"<tmp>/silent-test.log" 2>&1 </dev/null &)
   ```

3. **Verify placement.** Expect the window's workspace to be 5 and the
   monitor's active workspace unchanged:

   ```sh
   hyprctl clients -j | node -e 'for (const w of JSON.parse(require("fs").readFileSync(0))) if (w.class === "app") console.log(w.workspace.id, w.pid, w.size)'
   hyprctl monitors -j | node -pe 'JSON.parse(require("fs").readFileSync(0))[0].activeWorkspace.id'
   ```

4. **Clean up.** Kill only your own process group. Agents never add, remove, or
   reload rules. At the end of the run, the orchestrator disables the rule,
   even when the run failed:

   ```sh
   hyprctl eval '_G.silent_test_rule:set_enabled(false); _G.silent_test_rule = nil'
   ```

   Never run `hyprctl reload`: it can drop another run's rule and send windows
   to the user's workspace.

If a test window ever lands on the user's workspace, kill it right away and
tell the user. Do not switch workspaces for them.
