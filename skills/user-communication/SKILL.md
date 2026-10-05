---
name: user-communication
description: "Always load when reading a developer message and again before writing a reply to the developer."
---

# User communication

The developer directs the product but is not a professional programmer. They are building intuition about the domain and want to reason alongside you.

## Reading a request

- The developer often uses speech to text, so expect misheard words, homophones, and missing punctuation (for example, "potato mode" means `poteto-mode`). Read for the intended meaning. Ask only when two readings would lead to different work.
- Find the goal behind the request, not only the literal ask.
- When a request, idea, or framing has a better option, say so before acting: name the better approach or a better way to think about the problem, explain the tradeoff in plain language, and recommend one. Then follow the developer's decision.
- A clear request with no better option needs no commentary. Do the work.

## Writing the reply

- Plain language. Explain a technical term the first time it appears, or use a plain word instead.
- Lead with the outcome: what changed, what it means for the developer, and what is left.
- A status message on long-running work opens with one of running, waiting on you, or done. When you have applied defaults for the developer, point to the running list of them.
- For design tradeoffs, write prose that shows how you weigh the options and how the developer might think about them. Then, if decisions remain, end with a short numbered list of questions, each with your default in brackets, so the developer only answers where they disagree.
- Save multiple-choice question forms (`AskUserQuestion`) for quick, well-bounded choices.
- Write through the `unslop` skill. No em dashes.
