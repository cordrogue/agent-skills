# In-app agent

The app's agent panel starts a local Codex app-server for the project, signs the writer in with ChatGPT, and runs task conversations that can propose changes for the writer to accept or decline.

## Sub-features

- `agent-panel` opens and closes the panel from the top bar or the panel header.
- `agent-connect` starts the local app-server and reports Ready or a failure with Restart agent.
- `agent-sign-in` signs in to Codex with ChatGPT.
- `agent-tasks` creates and selects tasks.
- `agent-message` sends a message and shows the transcript.
- `agent-stop` interrupts an active turn.
- `agent-approval` accepts or declines a proposed project change.

## How to get to it (user POV)

- Top bar "Open App agent" on any page, which reads "Close App agent" while open. There is no agent route.
- At 1440 px the panel is a region "App agent" inside complementary "App agent lane", with header "App Agent" and button "Close agent".
- Before start it shows "Not started", "Sign in to Codex", and "Start agent". After start it shows "Ready" and "Sign in". Tasks, New task, Message, Send, Stop, Accept, and Decline appear only after sign-in.

## Driving it with verify-electron

Preconditions:

- The panel talks to `window.appAgent` (getSnapshot, start, restart, startLogin, logout, readThread, startThread, sendMessage, interruptTurn, resolveApproval, onEvent). Read state only with `eval 'window.appAgent.getSnapshot()'`.

- **Open.** Run `click --role button --name 'Open App agent'`, then `wait --role button --name 'Start agent'`. `snapshot --role region --name 'App agent'` shows "Not started", "Sign in to Codex", and "Start agent".
- **Close.** `click --role button --name 'Close agent'` removes the region and the top bar shows "Open App agent". Reopen it; `click --role button --name 'Close App agent'` closes it the same way.
- **Start.** `click --role button --name 'Start agent'` prints its JSON line at once with empty `rendererErrors` and `mainFailures`. Then `wait --until '(async () => (await window.appAgent.getSnapshot()).connection.kind === "ready")()'`. The panel reads "Ready", "Sign in with ChatGPT to use the App agent.", and "Sign in". `getSnapshot()` returns `account.kind: "signedOut"`, `threads: []`, and `activeTurn: null`.
- **Sign in, tasks, message, stop, approvals.** verified-unreachable. The prerequisite is a ChatGPT account signed in to Codex. Every later control needs that account.

## Gotchas

- Do not choose "Sign in" offscreen. Its ChatGPT login runs outside the app window, and only the developer can complete it.
- The panel slides in. A full `snapshot` right after opening can show the lane without the region. Wait for "Start agent" or "Sign in" first.
- "Restart agent" appears only after a failed start.

## Source and tests

- `src/renderer/features/agent/AgentPanel.tsx`, `AgentConversation.tsx`, `agentQueries.ts`; `src/renderer/components/app-shell/AppShellTopBar.tsx`.
- `src/preload/index.ts`, `src/shared/agent.ts`, `src/main/codex-agent-service.ts`.
- `npm test -- src/renderer/features/agent/AgentPanel.test.tsx src/renderer/features/agent/AgentConversation.test.tsx src/main/codex-agent-service.test.ts`.
