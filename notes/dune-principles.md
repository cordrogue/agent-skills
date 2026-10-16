# Dune's principles

Dune is Lauren Tan's in-house React framework for Grok Bot, a desktop app built mostly by agents. It is not open source. She describes it as "more of a collection of ideas and principles" and invites people to screenshot the talk and have an agent build something like it.

This note keeps only what was checked against her own words: text read off her slides and documents, her spoken talk, and her posts on X. It leaves out guesses about how Dune is built. The research was done on 2026-10-02.

## The premise: agents take shortcuts

The key principle her team landed on is that agents love taking shortcuts. So design the codebase so that the shortcut is the right path. "The shortest path is the best path." A codebase locked down this tightly can be annoying for humans, but it suits agents with little context, and suits contributors who are not engineers.

Dune's design came from looking at where agents tripped up: what caused performance problems and regressions in the first prototype and in the Cursor codebase, and what made code hard to understand and maintain. She wrote the tutorial and guide for building a Dune app before building Dune ("readme driven design").

## The five rules

Shown verbatim on the framework document in her workshops:

1. The conventional path requires fewer decisions than a shortcut.
2. Forbidden dependencies fail mechanically.
3. Every durable value has one obvious writer.
4. New product work adds isolated files rather than branches in shared roots.
5. Exceptions are narrow, explicit, and reviewed as architecture changes.

## Three habits behind them

From the talk:

- Delete the tech debt you already have.
- Keep a single paved path for each blessed pattern, so agents never have to guess, with enough guidance in the code, CI, and lint rules to keep them on it.
- When you see a bad pattern, write a lint rule against it first. That stops it spreading even before anyone cleans it up. Then have agents clean it up.

Her posts add that she reads what agents and teammates land, watches for code smells, and either refactors the problem away or adds a lint. Over time, landing code is safe as long as CI passes.

## Where a rule lives

Her slide ranks the places to put a rule, strongest first:

1. The codebase itself (its structure).
2. Static analysis: lint, the compiler, CI.
3. Rules and Bugbot (an automated code reviewer).
4. Skills.
5. A "style guide".

A rule written as prose is the weakest kind. Encode it as high on this list as it will go.

## Catch the shortcut early

Slide title: "Guardrails catch shortcuts before review. The same mistake becomes cheaper when the system rejects it earlier." Dune checks at each stage:

| Stage | What it checks |
| --- | --- |
| Edit time | exports, target projects, branded links, typed contracts |
| Build | reserved-file discovery, the Host peer graph, React Compiler |
| Renderer start | duplicate ids, missing views, invalid card paths |
| Lint | wrong imports, raw RPC, timers, effects, file growth |
| Test | public contract suites, and tests that can fail |

Every failure's message names the expected owner or API, so the agent learns the right path from the error.

## The structure that carries the rules

- **Feature:** each feature creates its own folder.
- **Entrypoints and Transcript cards** are discovered from reserved file names, not registered in shared lists. Adding a feature adds files and edits nothing shared.
- **Client:** durable local state has one writer, behind named hooks and commands.
- **Host:** backend behavior stays behind one typed contract between processes.
- **Package boundary:** the framework never imports application code.

A feature's component never handles IPC channels, Host peer lookup, retry ordering, or process startup. The framework does.

## React and effects

Grok Bot is 100% React on Dune. Dune bans `useEffect` outright and exposes it only through hooks the framework provides. She compares `useEffect` to Rust's `unsafe {}`: it shows at a glance where the problems are. React Compiler handles most over-rendering.

## Not verified

None of this shows Dune's code. Its APIs, full import rules, file layout, how discovery works, and what its client and host protocol guarantees (delivery, ordering, retry, recovery) are all unknown. Build those from your own design.

## Sources

- The talk, original upload on X, 2026-09-21: <https://x.com/poteto/status/2102050467505430555>. The process-boundary and blueprint slides were checked against this upload. The five rules, the rule ranking, and the guardrails slide were read from reuploads of the same talk and from recordings of her team workshops.
- React and `useEffect` post, 2026-08-17: <https://x.com/poteto/status/2089227731305464150>
- Design-process reply, 2026-08-26: <https://x.com/poteto/status/2092512896408592713>
- Article, 2026-09-09: <https://x.com/poteto/status/2097732320606507506>
