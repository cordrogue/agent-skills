---
name: why
description: "Use for 'why does X work this way', 'why we picked Y', design rationale, regressions, postmortems, or data-backed thresholds. Searches git history, the project's docs, and any MCP evidence source present in parallel, then returns a cited read on decisions and tradeoffs. Use how for runtime behavior."
---

# Why

Investigate the motivation and intent behind code. The companion `how` skill answers what the code does and how it works. `why` answers what forces led to its shape.

Each spawn below names a role in [`models.md`](../poteto-mode/references/models.md). Both roles run on the parent's own model as native subagents, because investigators and the synthesizer need the parent's MCP tools and a cross-provider lane gets only its own provider's MCP servers. Tool names per harness are in [`harness-tools.md`](../poteto-mode/references/harness-tools.md).

## Operating Posture

Operate as a **careful, cautious, and precise investigator**. Be honest about what you know vs what you're inferring. Read `references/epistemics.md` for the full confidence framework and phrasing guide. The synthesizer must follow it.

## Step 1. Understand the Target and the Question

The **target** is usually a chunk of code, a pattern, a feature, or a named design decision. The **question** is usually a design rationale, a tradeoff, a motivating edge case, an external constraint, dead code, or a broad history sweep.

If the target is vague ("why do we do it this way?" with no clear referent), make your best guess from conversation context (open files, recent edits, cursor location, what was just discussed). State your interpretation briefly so the user can redirect if you're off, then proceed.

## Step 2. Establish the Code Anchor

Before spawning investigators, build the seed context inline: file paths and line ranges, key symbols (functions, classes, constants), the last few commits touching the target, and the merge that brought each commit into `main`, if any, with its branch name (pattern `Merge branch '<name>'` in the subject line). A target that is a merge is its own merge context.

```bash
# Blame target lines for last-touch commits
git blame -L <start>,<end> <file>

# Full file history, with patches, through renames
git log --follow -p -- <file>

# Last N commits touching the file
git log --oneline -20 -- <file>

# Candidate merge that brought a commit into main
git log --merges --first-parent --ancestry-path --reverse --format=%h <commit>..main | head -1

# Succeeds if <commit> was on main before this merge, so this merge did not bring it in
git merge-base --is-ancestor <commit> <merge>^1

# Full message of a substantive commit
git log -1 --format=%B <commit>

# Project docs that name the target
rg -l -i '<symbol or feature>' docs/
```

Add the docs that name the target. This anchor goes to every investigator and to the synthesizer.

## Step 3. Spawn Parallel Investigators

**Default to the full parallel investigation.** The goal is a complete coverage map, not a minimal one. Document the null, don't skip the search.

### Discovery

Before spawning investigators, list the MCP servers this session can use from its live tool list, tool search included. In Claude Code they appear as `mcp__<server>__<tool>`. In Codex, `codex mcp list` adds configured servers but not the ones T3 Code injects. Inspect each server's tools before classifying it. Record a configured server the session cannot use as unavailable.

Map each evidence source to one category:

1. Source control history
2. Project docs
3. MCP sources

Source control is always available through git. Project docs are always available in `docs/`. For each MCP server, decide from its name, server instructions, tool names, and resource descriptors whether it holds project history (tickets, docs, chat, error events, analytics). An MCP that only drives tools, such as a browser or desktop driver, holds no evidence. Record each MCP and its classification in the coverage map.

Spawn one investigator for source control, one for project docs, and one per MCP server that holds project history, all in one fan-out so they run concurrently, each owning exactly one source. Don't ask one agent to cover multiple MCPs. Each is role `why investigators`, a native subagent on the parent's model, with MCP access kept, because a cross-provider lane gets only its own provider's MCP servers. Investigators still shouldn't write anything, so say so in the prompt.

Each investigator's prompt is `references/investigator-prompt.md` filled in, plus:
- the category playbook `references/sources/<source>.md` from `references/source-playbook.md`. An MCP investigator gets no playbook. It adapts the investigator prompt to its MCP's tools
- `references/sources/incident-postmortem.md` **if the target code looks defensive** (null checks, retry logic, timeout handling, rate limiting, feature flags, egress guards, OOM handlers)
- the code anchor and the user's original question

### Investigator roster, one per available evidence source

Each source below is uniquely positioned to surface one shape of "why", shown after "Best at". Use it to know what to expect back, to name a gap when a source returns empty, and, only in the rare provably-irrelevant case, to justify a skip.

1. **Source control** (git history, code comments, tests). Always spawn, the only guaranteed source. Best at *implementation-time rationale captured in commit messages*. For a defensive target it also searches the local runtime-error log, per `references/sources/incident-postmortem.md`.
2. **Project docs** (`docs/agents/decisions/`, `docs/agents/contracts/`, `docs/work/`, `docs/BACKLOG.md`, and the rest of `docs/`). Always spawn. Best at *long-form design rationale*, written out before it becomes code.
3. **MCP source**, one per MCP server that holds project history (e.g. a ticket tracker, a docs space, team chat, error tracking, or analytics). Best at *whatever that source uniquely records*. Name the kind of evidence it holds in the coverage map.

### When to skip an investigator

Only with an **explicit, written justification** that goes in the final Sources Consulted. Two valid reasons:

- **No MCP is available for that kind of evidence** in this environment. Flag it as a gap, not a choice: "MCP sources skipped. No MCP present holds project history, so no ticket, chat, or error record was searchable."
- **The source is provably irrelevant**, not just "probably irrelevant." A high bar: "Project docs skipped. Target is a one-line typo fix with no design surface."

If your scope assessment suggests a single-commit trivial target where the commit message already contains the complete answer, you may answer inline **only after** confirming every available source search would be redundant. Say so explicitly. This should be rare.

## Step 4. Synthesize

Spawn one synthesizer, role `why synthesizer`, a native subagent on the parent's model. Keep its MCP access, because it spot-verifies citations. It does not write files. It gets:
1. The investigator findings, including any null results and any categories skipped with justification
2. The code anchor
3. The user's original question
4. The epistemics framework from `references/epistemics.md`
5. The synthesizer prompt template from `references/synthesizer-prompt.md`

## Step 5. Present

Present the synthesizer's output to the user. You may lightly edit for clarity or add context from the conversation, but **do not rewrite the confidence language**.

## Output Format

The structure is the one in `references/synthesizer-prompt.md`: The Question, The Code in Question, What We Found, What We Can Reasonably Infer, Competing Hypotheses, What We Don't Know, Sources Consulted, Confidence Summary. Adapt as needed, but keep the confidence separation intact, and keep Sources Consulted as one line per investigator, including the ones that returned nothing or were skipped, with the reason.

After Sources Consulted, if the user's `why` question is a precursor to changing this code, convert the lineage findings into a Preserve / Change / Avoid / Risk constraint set for planning the change.

## Common Failure Modes to Avoid

- **Recency bias**. Assuming the most recent commit is authoritative. The current shape is often the accretion of many earlier decisions. Trace back.
