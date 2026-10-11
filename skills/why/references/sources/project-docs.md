# Project Docs

## What this source contains

- Accepted architecture decisions in `docs/agents/decisions/`, one file per subject
- Binding contracts in `docs/agents/contracts/`
- Plans, specs, reviews, and remediation papers in `docs/work/`
- Out-of-scope problems in `docs/BACKLOG.md`
- Domain vocabulary and terms to avoid in `docs/GLOSSARY.md`
- Product intent in `docs/PRODUCT.md`, `docs/FEATURES.md`, `docs/IDEAS.md`, and `docs/TODO.md`
- The index of all of these in `docs/README.md`

Here, `docs/` is where "why" lives in long form before it becomes code. A significant change usually has a plan or a decision file.

## How to search it

Use the shell.

1. **Keyword searches.** `rg -n -i '<term>' docs/`. Try:
   - The feature name
   - Key symbols / class names from the target code
   - Error strings or user-visible terms
   - The target's file path
2. **Read candidate files in full.** Rationale is often buried mid-document.
3. **Follow links.** Decision files link work papers, and work papers link specs and reviews.
4. **Read the docs' own history.** `git log --follow -p -- <doc>` shows when a decision or plan changed and which code commits landed beside it.
5. **Check removed docs.** `git log --diff-filter=D --name-only -- docs/` lists deleted plans that may hold the original reasoning.

## What good evidence looks like here

- A decision file whose context and decision sections match the target code's purpose
- An "Alternatives rejected" or similar section in a plan
- A review finding that names the target code and the fix it asked for
- A backlog entry that records a known problem the target works around
- A plan whose dates and commits line up with the target's commits

## Common pitfalls

- **Outdated docs.** Plans are written before implementation and not always updated. The doc may describe a plan that changed. Cross-check against the commits.
- **Doc vs. reality drift.** A plan may say "we'll do X" but the code actually does Y. Flag the divergence. The synthesizer will surface the contradiction.
- **Decisions do not prove behavior.** `docs/README.md` says decision files preserve rationale and do not prove current behavior. Cite them for intent, not for what the code does.
- **Finished work papers.** A plan in `docs/work/` may be complete and kept only for its record. Check its status line and dates.
- **Drafts.** A finished plan can still hold a proposal nobody accepted. When versions compete, cite the one current at the target's change, and report later revisions separately.

## What to return

For each relevant doc:
- Path and section heading
- The commit that added or last changed the section, with its date
- The motivation text (verbatim quote), with `file:line`
- Linked docs (so the synthesizer can cite them)
- Whether the doc is a decision, a contract, a plan, or a backlog entry
- Whether its proposal was draft, accepted, rejected, superseded, or unknown, apart from whether the work is complete
