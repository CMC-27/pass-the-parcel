---
name: write-wiki
description: "Write and rewrite wiki documents in plain, even, front-loaded prose. Make sure to use this skill whenever the user asks to write, edit, rewrite, clean up, rebalance, refresh or restructure any document in a codebase wiki (.wiki/ or knowledge base) — creating new docs, integrating new content into existing docs, consolidating sections, tightening stale prose, or fixing a doc that reads unevenly. Follows the Review → Re-outline → Re-balance discipline: read the whole document first, never append, and weight detail by relevance to the reader, not recency."
---

# Write Wiki

## Purpose & Context

Portable, self-contained skill for writing and rewriting documents in a codebase wiki — the markdown knowledge base that lives in a repo (for example a `.wiki/` folder) beside the code, with its own governance (frontmatter, naming, document structure, link hygiene). It isolates the **Editing Discipline — Review → Re-outline → Re-balance** so every edit keeps the whole document even and readable, with detail weighted by relevance, never by recency. Use it wherever you write or edit wiki prose.

## Summary

- **New docs:** front-load — `frontmatter` → `Purpose & Context` → `Summary` → `Detail`.
- **Edits:** read the full document first, never append, and re-outline and rebalance the entire affected section.
- **Even, not recency-biased:** weight detail by relevance to the reader, not recency. No wall-of-text, no last-paragraph dumps, no forced equal lengths.
- **Voice:** plain, active, UK-English prose; no AI-voice tell-tales; no gobbledygook; never fabricate.
- **Verify:** check links, frontmatter and indexes before declaring done.

## When to Use

| Scenario | Example |
|---|---|
| Create a new wiki document | "Document the state context in `.wiki/core/`" |
| Edit or rewrite an existing document | "Update the validation standards doc" |
| Integrate new content into an existing doc | "Add the new failure modes to the error handling page" |
| Consolidate overlapping sections | "The glossary and the architecture doc both cover this term — merge them" |
| Tighten stale or uneven prose | "This doc reads like it was appended to for months — even it out" |
| Any codebase wiki or knowledge base | `.wiki/`, `docs/`, a markdown knowledge base in any repo |

## The Method — Review → Re-outline → Re-balance

### Step 1: Orient to the wiki's own governance

- Read the target wiki's rules first: its frontmatter standard, naming conventions, document-structure rule and link hygiene, plus the area index for the document you are touching. **Follow the wiki's own rules over anything in this skill.** This skill supplies the language discipline and the edit discipline; the wiki supplies its own schema, headings and links.
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

### Step 5: Voice & language (baked in)

- **Plain everyday words. One idea per sentence. Active voice. Present tense where possible.** Write for a busy reader who needs to act on the first read.
- **UK English:** `organise` not `organize`, `programme` not `program`, `behaviour`, `modelling`. Grep for `-ize/-ization` drift and correct. Dates `14 June 2026`, amounts `GBP 12,500 (excl. VAT)` / `£75`, `per cent` with `%` and number, measurements spelt at first mention. Punctuate bulleted lists consistently — all bullets end the same way (full sentences with full stops, or phrases without).
- **No AI-voice tell-tales.** Do not use `delve`, `tapestry`, `landscape` as metaphor, `testament`, `beacon`, `interplay`, `foster`, `elevate`, `realm` as metaphor, `milestone` as metaphor, `pivotal`, `crucial`, `robust`, `game-changing`, `seamless`, `seamlessly`, `vibrant`, `profound`. Keep a term only when it is a literal technical, product, legal or project term, a required heading, or quoted source text.
- **No stock transitions or formulaic syntax.** Do not use `moreover`, `furthermore`, `in addition`, `it is worth noting`, `importantly`. Do not use negative parallelism (`It is not just X — it is Y`). Do not end a sentence with a dangling present-participle clause (`..., ensuring ...`, `..., reflecting ...`).
- **End when the point is made.** No generic wrap-ups beginning `Overall`, `In summary` or `In conclusion`.
- **Strip gobbledygook:** `leverage`, `synergy`, `holistic`, `going forward`, `please be advised`; use `use`, not `utilise` or `facilitate`.
- **Human mechanics, used selectively.** Contractions (`don't`, `can't`) and occasional fragments are allowed when they suit the audience and improve directness, especially in notes, bullets and internal docs. Keep formal, regulatory and contractual prose precise.
- **Take a defensible position.** For a recommendation or choice, state the evidence-backed action first, then the reason and material caveat. Do not manufacture a balanced "on one hand / on the other hand" discussion when the sources support a clear position.
- **Anchor abstract claims.** Name the source, file, function, person, date, quantity or example behind an abstract claim. Replace "many users report…" with the named evidence or state that the point is unverified.
- **Confident without overclaim.** Numbers, dates and names over adjectives. Unknown → mark `{to-confirm: description}` and raise an RFI.

### Step 6: Structure — front-loaded

For new documents, and wherever the wiki's own structure rule does not override it, open every doc the same way:

1. **YAML frontmatter** — per the wiki's standard (title, status, type, dependencies, description).
2. **Purpose & Context** — one to three sentences: what the document covers, why it exists, who it is for, and the outcome it enables.
3. **Summary** — the finished result shown **before** the how-to; must stand alone. A reader who stops after the Summary knows what the doc is, why it exists and what the outcome looks like.
4. **Detail** — the body: step-by-step, prerequisites, edge cases, troubleshooting, references.

Index and catalog documents are exempt — they are navigation hubs, not prose docs.

### Step 7: Non-negotiable rules

- **Never fabricate.** No invented facts, code behaviour, dates, figures or outcomes. Unknown → `{to-confirm: description}` + RFI.
- **No duplication.** Link to the canonical document; never copy content into a second file.
- **Respect status.** Never promote `draft` → `approved` (or `stable`) without human sign-off.

### Step 8: Verify

- Re-read the edited section as a reader: does it flow? Is the most important point first? Are bullets complete?
- Check links, frontmatter and the area index per the wiki's own tooling (linter, index update). Update the area index for every document you touch.
- Self-check against the Operational Law below. Report pass/fail and any advisory findings.

## Operational Law

**Natural flow = Pass.** Recency-biased append, mixed-theme or mixed-purpose paragraph, wall-of-text, vague bulleted trailing, US-English drift, stock AI phrasing, or gobbledygook = **Fail**. No exceptions.

## Before / After

| ❌ Before | ✅ After |
|---|---|
| "This section was added in the v0.9 refactor and covers the new token flow, then we also fixed the grid layout (see the changelog) and oh the header buttons got the loading state etc." (one paragraph, three themes, vague trailing) | "**Token flow.** v0.9 added the token refresh flow; the changelog records the change.<br><br>**Grid layout.** The grid layout fix shipped in the same release.<br><br>**Header buttons.** Header buttons now show a loading state during async actions." |
| "We are excited to leverage our comprehensive suite of industry-leading features to deliver a seamless, robust, game-changing experience." | "The workspace loads projects from the project registry and lets you switch with the header dropdown. Unknown export limits are marked `{to-confirm}`." |
| "Recently added features: dark mode, keyboard shortcuts and other improvements etc." | "**Keyboard shortcuts.** Added in v0.10 — see the shortcut map.<br>**Dark mode.** Follows the theme tokens in the design system.<br>**Export.** Exports the active assembly to CSV; limits are pending confirmation." |

---

**Related:** `knowledge-capture` · `knowledge-consolidation` · `wiki-lint` · `wiki-bootstrap`