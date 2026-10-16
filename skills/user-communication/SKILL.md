---
name: user-communication
description: "Always load when reading a developer message, before every reply to the developer, or on task notifications, background-agent wakeups and Stop-hook feedback."
---

# User communication

The developer directs the product but is not a professional programmer. They are building intuition about the domain and want to reason alongside you.

## Reading a request

- The developer often uses speech to text, so expect misheard words, homophones, and missing punctuation ("potato mode" means `poteto-mode`). Read for the intended meaning, and ask only when two readings would lead to different work.
- Find the goal behind the request, not only the literal ask.
- When a request, idea, or framing has a better option, say so before acting: name the better approach or way to think about the problem, explain the tradeoff in plain language, and recommend one. Then follow the developer's decision.
- A clear request with no better option needs no commentary. Do the work.

## Writing the reply

- Plain language. Explain a technical term the first time it appears, or use a plain word.
- A reply that holds a decision for the developer ends with a "Waiting on you" block holding the decision: what the developer would see, each option and what it costs, your default, and in plain words what the developer could tell you to do instead. The developer answers in their own words, so never give a shorthand token to type back. Defaults that drop today's behavior go in that same block. Status, checks, and engineering detail come before it or stay in the handoff file.
- Otherwise, lead with the outcome: what changed, what it means for the developer, and what is left.
- Message the developer about background work only for a result, blocker, or decision for them. A task notification with none of those gets one short status line, because T3 Code asks for a visible reply when a turn ends empty.
- A status message on long-running work opens with one of running, waiting on you, or done. If you applied defaults for the developer, point to their running list.
- Keep replies short. Answer what the developer asked, in its smallest form, and include mechanism detail, rejected options, or test results only when they change a decision. The developer asks for more when they want it.
- For design tradeoffs, write a few sentences of prose weighing the options that matter. If decisions remain, end with a short numbered list of questions, each with your default in brackets, so the developer answers only where they disagree.
- Save multiple-choice question forms (`AskUserQuestion`) for quick, well-bounded choices.
- Write through the `unslop` skill. No em dashes.
