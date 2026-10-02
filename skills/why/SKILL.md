---
name: why
description: "Use for 'why does X work this way', 'why we picked Y', design rationale, regressions, postmortems, or data-backed thresholds. Searches git history, the project's docs, and any MCP evidence source present in parallel, then returns a cited read on decisions and tradeoffs. Use how for runtime behavior."
---

# Why

Investigate the motivation and intent behind code.

Companion to the `how` skill. `how` answers what the code does and how it works. `why` answers what forces led to its shape.

Each spawn below names a role in [`models.md`](../poteto-mode/references/models.md). Both roles run on the parent's own model as native subagents, because investigators and the synthesizer need the parent's MCP tools and a cross-provider lane gets none. Tool names per harness are in [`harness-tools.md`](../poteto-mode/references/harness-tools.md).

## Operating Posture

Operate as a **careful, cautious, and precise investigator**. Be honest about what you know vs what you're inferring. Read `references/epistemics.md` for the full confidence framework and phrasing guide. The synthesizer must follow it.

## Step 1. Understand the Target and the Question

Parse what the user is asking. The **target** is usually a chunk of code, a pattern, a feature, or a named design decision. The **question** is usually a design rationale, a tradeoff, a motivating edge case, an external constraint, dead code, or a broad history sweep.

If the target is vague ("why do we do it this way?" with no clear referent), make your best guess from conversation context (open files, recent edits, cursor location, what was just discussed). State your interpretation briefly so the user can redirect if you're off, then proceed.

## Step 2. Establish the Code Anchor

Before spawning investigators, anchor the investigation in concrete code. You need:

- The relevant file path(s) and line range(s)
- The key symbols (function names, class names, constants)
- An initial commit list. The last few commits touching the target.
- Merge commits that brought those commits in, and their branch names (pattern `Merge branch '<name>'` in the subject line)

Build this inline.

```bash
# Blame target lines for last-touch commits
git blame -L <start>,<end> <file>

# Full file history, with patches, through renames
git log --follow -p -- <file>

# Last N commits touching the file
git log --oneline -20 -- <file>

# The merge that brought a commit into main
git log --merges --ancestry-path --oneline <commit>..main | tail -1

# Full message of a substantive commit
git log -1 --format=%B <commit>

# Project docs that name the target
rg -l -i '<symbol or feature>' docs/
```

Capture this as seed context (file paths, symbols, commits, merge branches, docs that name the target). Pass it to the investigators.

## Step 3. Spawn Parallel Investigators (default posture)

**Default to the full parallel investigation.**

### Discovery

Before spawning investigators, list the MCP servers present. In Claude Code, they appear in the tool list as `mcp__<server>__<tool>`. In Codex, run `codex mcp list`.

Map each evidence source to one category:

1. Source control history
2. Project docs
3. MCP sources

Source control is always available through git. Project docs are always available in `docs/`. For each MCP server, decide from its name, server instructions, tool names, and resource descriptors whether it holds project history (tickets, docs, chat, error events, analytics). An MCP that only drives tools, such as a browser or desktop driver, holds no evidence. Record each MCP and its classification in the coverage map.

Aim for a complete **coverage map**, not a minimal one. Document the null, don't skip the search.

Launch all matching investigators in one fan-out so they run concurrently. Don't ask one agent to cover multiple MCPs.

Subagent config (each):
- Role: `why investigators`, a native subagent on the parent's model.
- Keep MCP access. A cross-provider lane has no MCP tools. Investigators still shouldn't write anything, so say so in the prompt.

Each investigator gets:
1. The base prompt from `references/investigator-prompt.md`
2. The category playbook `references/sources/<source>.md` from `references/source-playbook.md`. An MCP investigator gets no playbook. It adapts the investigator prompt to its MCP's tools
3. The cross-cutting `references/sources/incident-postmortem.md` **if the target code looks defensive** (null checks, retry logic, timeout handling, rate limiting, feature flags, egress guards, OOM handlers)
4. The code anchor from Step 2 (file paths, symbols, commit hashes, merge branches, docs)
5. The user's original question

### Investigator roster. One per available evidence source

Spawn one investigator for source control, one for project docs, and one per MCP server that holds project history. Each owns exactly one source.

Each entry names the category and the kind of "why" it uniquely surfaces. Use it to know what to expect back, how to name a gap when a category returns empty, and (only in the rare provably-irrelevant case) to justify a skip.

1. **Source control investigator**. Git history, code comments, tests. Always spawn. The only guaranteed source. Best at surfacing *implementation-time rationale captured in commit messages*.

2. **Project docs investigator**. `docs/agents/decisions/`, `docs/agents/contracts/`, `docs/work/`, `docs/BACKLOG.md`, and the rest of `docs/`. Always spawn. Best at surfacing *long-form design rationale*. Where the why is written out before it becomes code.

3. **MCP source investigator**, one per MCP server that holds project history (e.g. a ticket tracker, a docs space, team chat, error tracking, or analytics). Best at surfacing *whatever that source uniquely records*. Name the kind of evidence it holds in the coverage map.

### When to skip an investigator

Only skip with an **explicit, written justification** that goes in the final "Sources Consulted" section. Two valid reasons:

- **No MCP is available for that kind of evidence** in this environment. Flag this as a gap, not a choice. Example: "MCP sources skipped. No MCP present holds project history, so no ticket, chat, or error record was searchable."
- **The source is provably irrelevant**, not just "probably irrelevant." A high bar. Example: "Project docs skipped. Target is a one-line typo fix with no design surface."

If your scope assessment suggests a single-commit trivial target where the commit message already contains the complete answer, you may answer inline **only after** confirming every available source search would be redundant. Say so explicitly. This should be rare.

## Step 4. Synthesize

Spawn one synthesizer subagent:

- Role: `why synthesizer`, a native subagent on the parent's model.
- Keep MCP access. The synthesizer's quality check spot-verifies citations, which can require MCP access. It does not write files.

The synthesizer gets:
1. The investigator findings, including any null results and any categories skipped with justification
2. The code anchor from Step 2 (file paths, symbols, commit hashes, merge branches, docs)
3. The user's original question
4. The epistemics framework from `references/epistemics.md`
5. The synthesizer prompt template from `references/synthesizer-prompt.md`

## Step 5. Present

Take the synthesizer's output and present it to the user. You may lightly edit for clarity or add context from the conversation, but **do not rewrite the confidence language**.

## Output Format

The output structure is the one in `references/synthesizer-prompt.md`: The Question, The Code in Question, What We Found, What We Can Reasonably Infer, Competing Hypotheses, What We Don't Know, Sources Consulted, Confidence Summary. Adapt as needed, but keep the confidence separation intact, and keep Sources Consulted as one line per investigator, including the ones that returned nothing or were skipped, with the reason.

After the Sources Consulted block, if the user's `why` question is a precursor to actually changing this code, convert the lineage findings into a Preserve / Change / Avoid / Risk constraint set suitable for planning the change.

## Common Failure Modes to Avoid

- **Recency bias**. Assuming the most recent commit is authoritative. The current shape is often the accretion of many earlier decisions. Trace back.

## Reference Files

- `references/epistemics.md`. Confidence tiers and phrasing guide. The synthesizer must follow it.
- `references/investigator-prompt.md`. Base prompt template for investigator subagents.
- `references/source-playbook.md`. Index pointing at the category playbooks below.
- `references/sources/*.md`. One playbook per always-present category, plus cross-cutting `incident-postmortem.md`. Give an investigator the single file that matches its category.
- `references/synthesizer-prompt.md`. Prompt template for the synthesizer subagent, including the output format.
