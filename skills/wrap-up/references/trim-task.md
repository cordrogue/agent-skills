# Wrap-up trim task

Read-only. Your answer is your final message.

Agents load skills in every session, so each extra word in one costs tokens again and again. For each finding in the combined report whose Destination is `skill edit`:

1. Read the section the edit changes.
2. Rewrite the added text in the fewest words that keep the rule. Cut what the skill already says, examples and reasons the agent does not need to act, and hedges. Keep every trigger, exception, path, and command. Write whole sentences, per `unslop` rule 33.
3. Propose deleting existing text the edit makes redundant.

Reply per finding with its id, the words added before and after, and the trimmed `diff` block, or "already minimal". End with the line `LANE DONE`.
