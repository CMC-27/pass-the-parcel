---
name: wiki-writer
description: "Write and rewrite wiki documents in plain, even, front-loaded prose. Make sure to use this skill whenever the user asks to write, edit, rewrite, clean up, rebalance, refresh or restructure any document in a codebase wiki (.wiki/ or knowledge base) — creating new docs, integrating new content into existing docs, consolidating sections, tightening stale prose, or fixing a doc that reads unevenly. Also invoke it when another skill is about to create or edit wiki prose (agent-wrap-up, knowledge-consolidation, wiki-bootstrap). Follows the Review → Re-outline → Re-balance discipline: read the whole document first, never append, and weight detail by relevance, not recency."
---

# Wiki Writer

## Purpose & Context

Portable, self-contained skill for writing and rewriting documents in a codebase wiki — the markdown knowledge base that lives in a repo (for example a `.wiki/` folder) beside the code, with its own governance (frontmatter, naming, document structure, link hygiene). It isolates the **Editing Discipline — Review → Re-outline → Re-balance** so every edit keeps the whole document even and readable, with detail weighted by relevance, never by recency. Use it wherever you write or edit wiki prose.

In this repo, the skill supplies only the **edit and prose method**. All structural and language rules are canonical in [`.wiki/rules/`](../../../.wiki/rules/README.md) and [`.wiki/rules/language/`](../../../.wiki/rules/language/README.md) — this skill defers to them everywhere they overlap (see Rule Ownership below).

## Summary

- **New docs:** front-load — `frontmatter` → `Purpose & Context` → `Summary` → `Detail`, per the wiki's own structure rule.
- **Edits:** read the full document first, never append, and re-outline and rebalance the entire affected section.
- **Even, not recency-biased:** weight detail by relevance to the reader, not recency. No wall-of-text, no last-paragraph dumps, no forced equal lengths.
- **Voice:** plain, active, evidence-anchored prose; apply the wiki's language rules, never restate them from memory.
- **Verify:** run the wiki linter and update indexes before declaring done.

## When to Use

| Scenario | Example |
|---|---|
| Create a new wiki document | "Document the state context in `.wiki/core/`" |
| Edit or rewrite an existing document | "Update the validation standards doc" |
| Integrate new content into an existing doc | "Add the new failure modes to the error handling page" |
| Consolidate overlapping sections | "The glossary and the architecture doc both cover this term — merge them" |
| Tighten stale or uneven prose | "This doc reads like it was appended to for months — even it out" |
| Another skill is about to write wiki prose | `agent-wrap-up` Phase 2/3, `knowledge-consolidation` Phase 6 promotion, `wiki-bootstrap` filling a stubbed slot |
| Any codebase wiki or knowledge base | `.wiki/`, `docs/`, a markdown knowledge base in any repo |

## Rule Ownership

The wiki's governance layer wins on every overlap. Consult the canonical rule instead of applying this skill's summary of it:

| Concern | Canonical rule (this repo) | This skill covers |
|---|---|---|
| Frontmatter fields and status lifecycle | [`.wiki/rules/frontmatter.md`](../../../.wiki/rules/frontmatter.md) | Defers entirely |
| Document opening (Purpose & Context → Summary → Detail) | [`.wiki/rules/document-structure.md`](../../../.wiki/rules/document-structure.md) | Defers entirely |
| Links, no-duplication, index maintenance | [`.wiki/rules/link-hygiene.md`](../../../.wiki/rules/link-hygiene.md) | Defers entirely |
| Voice, tone, prohibited words, AI guardrails | [`.wiki/rules/language/`](../../../.wiki/rules/language/README.md) | Method only: check the rules before writing |
| Structural validation | [`scripts/wiki_lint.py`](../../../scripts/wiki_lint.py) | Invokes it as the verify step |
| The edit discipline itself | — | **This skill is canonical**: Review → Re-outline → Re-balance |

Outside this repo, substitute whatever governance the target wiki defines (Step 1).

## The Method — Review → Re-outline → Re-balance

### Step 1: Orient to the wiki's own governance

- Read the target wiki's rules first: its frontmatter standard, naming conventions, document-structure rule and link hygiene, plus the area index for the document you are touching. **Follow the wiki's own rules over anything in this skill.** In this repo that means: [`.wiki/rules/README.md`](../../../.wiki/rules/README.md), the specific rule file for the concern at hand, and [`.wiki/rules/language/ai-rules.md`](../../../.wiki/rules/language/ai-rules.md) before drafting any prose. This skill supplies the language discipline and the edit discipline; the wiki supplies its own schema, headings and links.
- Read the **full target document**, its related documents, and the area index before touching a line. Understand existing themes, paragraph breaks, bullet completeness and section weight. Never edit a section in isolation.

### Step 2: Review — read the whole before you write the part

- Identify what is already there: themes per paragraph, bullet completeness, section weight, stale or duplicated content, and where the existing structure puts related material.
- Decide what is genuinely missing and where a reader would look for it. Note any detail that is overweight simply because it was added recently.

### Step 3: Re-outline — rewrite, never append

- **Do not append at the end.** Integrate new material at its semantically correct subsection — the place a reader would search for it — and re-outline the entire affected section around it.
- Re-level headings and bullets to a clean hierarchy. De-duplicate to **one idea per sentence, one theme and one purpose per paragraph**.
- **Bullets are for actions — list every item.** One actionable item per bullet, every item listed. No `etc.`, `various`, `and so on`, `xxx, oh and this…`. If a list cannot be completed, state what is missing and when it will be confirmed.
- When topics or purposes change, start a new paragraph. Do not mix themes or jobs in one block.

### Step 4: Re-balance — even, not recency-biased

- **Weight detail by relevance to the reader and the document's purpose, not recency.** Do not keep the newest addition merely because it is new, and do not let the latest edit become the longest section.
- Vary paragraph length and sentence rhythm deliberately. Do not force equal subsection lengths, matching paragraph lengths, or a repeated cadence. A paragraph may be one sentence or several — vary the pace where the content calls for it.
- Prevent wall-of-text blocks and last-paragraph dumps. Split a block when it carries more than one idea, not at an arbitrary line or sentence count.
- **Inverted pyramid at every level:** most important point first, then detail, then background — in the document, each section, each paragraph, and each sentence.
- **Adjacent rebalance is required, not freelancing:** when you edit one part, adjust neighbouring paragraphs, bullets and headings in the same section so the whole reads as if written at once. For code, config and reference files that are not prose, stay surgical — minimal diff.

### Step 5: Voice & language — apply the rules, don't restate them

- Before drafting, open the wiki's language rules and follow them: in this repo, [voice-and-tone.md](../../../.wiki/rules/language/voice-and-tone.md), [ai-rules.md](../../../.wiki/rules/language/ai-rules.md), and the term list in [prohibited-language.md](../../../.wiki/rules/language/prohibited-language.md). Those files are canonical — if this summary ever disagrees with them, they win.
- Baseline expectations (mirrored from the rules, verified against them on each use): plain everyday words, one idea per sentence, active voice, present tense where possible; UK English (grep your own output for `-ize/-ization` drift); no AI-voice tell-tales or stock transitions; no gobbledygook.
- **Take a defensible position.** For a recommendation or choice, state the evidence-backed action first, then the reason and material caveat. Do not manufacture a balanced "on one hand / on the other hand" discussion when the sources support a clear position.
- **Anchor abstract claims.** Name the source, file, function, person, date, quantity or example behind an abstract claim. Replace "many users report…" with the named evidence or state that the point is unverified.
- **Confident without overclaim.** Numbers, dates and names over adjectives. Unknown → mark `{to-confirm: description}` and raise an RFI.

### Step 6: Structure — front-loaded

For new documents, follow the wiki's own structure rule — in this repo [`.wiki/rules/document-structure.md`](../../../.wiki/rules/document-structure.md) — which fixes the opening as: YAML frontmatter (fields per [`frontmatter.md`](../../../.wiki/rules/frontmatter.md)), Purpose & Context, Summary, then Detail. Sections 1–3 must stand alone: a reader who stops after the Summary knows what the document is, why it exists and what the outcome looks like. Index and catalog documents are exempt — they are navigation hubs, not prose docs.

### Step 7: Non-negotiable rules

- **Never fabricate.** No invented facts, code behaviour, dates, figures or outcomes. Unknown → `{to-confirm: description}` + RFI.
- **No duplication.** Link to the canonical document; never copy content into a second file.
- **Respect status.** Only a human promotes a document to `stable` (see the status lifecycle in [`frontmatter.md`](../../../.wiki/rules/frontmatter.md)). Agents may draft at `in-progress` and request review, never self-approve.

### Step 8: Verify

- Re-read the edited section as a reader: does it flow? Is the most important point first? Are bullets complete?
- Run the linter and fix what it reports: `python scripts/wiki_lint.py` (add `--fix` to auto-repair). Report pass/fail and any advisory findings.
- Update the area index for every document you touch (e.g. `.wiki/core/00-system-index.md`, `.wiki/features/features-index.md`) so the doc stays discoverable, and bump `last-reviewed` in the frontmatter when the edit is substantive.
- Self-check against the Operational Law below. Report pass/fail and any advisory findings.

## Operational Law

**Natural flow = Pass.** Recency-biased append, mixed-theme or mixed-purpose paragraph, wall-of-text, vague bulleted trailing, US-English drift, stock AI phrasing, or gobbledygook = **Fail**. No exceptions.

## Before / After

| ❌ Before | ✅ After |
|---|---|
| "This section was added in the T15 refactor and covers the new project status flow, then we also fixed the sidebar search (see the changelog) and oh the hub cards got reordered etc." (one paragraph, three themes, vague trailing) | "**Project status flow.** T15 added `status` and `target_completion_date` to the projects registry — see `05-core-architecture.md`.<br><br>**Sidebar search.** The shared search term now lives in `ProjectContext` and persists across page navigation.<br><br>**Hub cards.** Hub cards render in a fixed order: Assemblies, Cost Elements, Tender Review, Proposals." |
| "We are excited to leverage our comprehensive suite of industry-leading features to deliver a seamless, robust, game-changing experience." | "The workspace loads projects from the project registry and lets you switch with the header dropdown. Unknown export limits are marked `{to-confirm}`." |
| "Recently added features: dark mode, keyboard shortcuts and other improvements etc." | "**Keyboard shortcuts.** Added in v0.10 — see the shortcut map.<br>**Dark mode.** Follows the theme tokens in the design system.<br>**Export.** Exports the active assembly to CSV; limits are pending confirmation." |

---

**Related skills:** [`knowledge-capture`](../knowledge-capture/SKILL.md) · [`knowledge-consolidation`](../knowledge-consolidation/SKILL.md) · [`wiki-lint`](../wiki-lint/SKILL.md) · [`wiki-bootstrap`](../wiki-bootstrap/SKILL.md) · [`agent-wrap-up`](../agent-wrap-up/SKILL.md)