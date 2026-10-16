# Wrap-up skill-edit attack task

Read-only: never edit tracked files, and start no other agents. Your answer is your final message.

You argue against every finding in the combined report whose Destination is `skill edit`. Another review checks the report's evidence and format; you look only for harm the edit could do. Skills are nondeterministic: one new sentence can change how agents weigh the rest of the skill, fire in sessions unlike the one that exposed the problem, or contradict another skill. The finding was written to fix one session, so its authors saw only the upside.

Upstream skills are those `this repo's `ATTRIBUTION.md`` lists, chiefly pstack (`poteto-mode`, every `principle-*`, and the rest of its list), Matt Pocock's, and Emil Kowalski's. Their wording was refined across many users and sessions, so presume the current text is well tested and the edit is the risk. An edit to one must show that the upstream text itself failed here, not merely that it lacks a rule. One session's mistake is weak evidence, and a local skill the agent reads at the same moment is usually the better home.

For each skill edit:

1. Read the whole skill it changes, and every skill that states a rule on the same subject.
2. Find the unintended consequences. For each, name a concrete session where the edited skill makes an agent act worse than today: the rule fires where it should not, it outweighs a rule the skill already ranks higher, it contradicts another skill, it narrows a rule that was general on purpose, or it adds load-time words for a rare case.
3. For an upstream skill, judge whether the finding's evidence beats the presumption above, and whether a local skill would hold the rule instead.

Reply per finding with its id, a verdict of `keep`, `change`, `move to <skill path>`, or `drop`, the strongest consequence as a concrete scenario, and the fix. End with the line `LANE DONE`.
