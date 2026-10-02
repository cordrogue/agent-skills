---
name: verify-electron
description: "Always load when checking a change in the real built Electron app instead of the browser dev view."
---

# Verify in the built Electron app

`scripts/verify-electron.mjs` launches the built app with
`APP_TEST_MODE=offscreen`. The real main window renders offscreen at
1440x900 on a fresh copy of the sample project, so no window reaches the
developer's screen. Each worktree has its own session in
`.tmp-vite/verify-electron/`, so parallel agents never collide.

1. Run `npm run build` after every source change. The script runs `dist/` and
   `dist-electron/`, never source.
2. Run `node scripts/verify-electron.mjs start`. It is ready when it prints
   `"ok":true` with an Overview screenshot path. A new `start` replaces the
   previous session.
3. Drive the change with `shot --route '#/people'`, `click '<css selector>'`,
   `press Escape`, and `eval '<expression>'` (`--help` lists them). Every
   command prints one JSON line with the route, viewport, any screenshot path,
   and the `rendererErrors` and `mainFailures` seen during that command.
   - Wait for UI by evaluating a promise that polls the condition, not by
     sleeping.
   - Open each screenshot and look at it after every visible step.
   - Resolve record ids through `window.app`; fixtures and routes are in
     `docs/agents/feature-verification.md`.
4. The check is done when screenshots show the change with sample project data
   and every command reported empty `rendererErrors` and `mainFailures`.
5. Run `node scripts/verify-electron.mjs stop`. Screenshots stay in
   `.tmp-vite/verify-electron/shots/` until the next `start`.

Offscreen mode renders at scale 1 and has no on-screen window. It cannot check
focus, window controls, native menus, or compositor behavior; for those, launch
a visible window with the `silent-workspace-test` skill. Plain
`APP_TEST_MODE=hidden` is unfit for visual checks: CDP screenshots hang,
and `webContents.capturePage` stops the window drawing afterwards.
