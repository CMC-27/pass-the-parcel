---
title: Document Structure Pattern
tags: [wiki, rules, structure, front-loading]
status: stable
owner: Wiki Owner
last-reviewed: 2026-08-19
related-to: [./frontmatter.md, ./naming.md, ../AGENTS.md]
---

# Document Structure Pattern

> Every knowledge and reference document opens with the same three front-loaded sections — document info, purpose & context, and a summary — before any procedural detail. The opening is a **human-facing abstract**: a reader familiar with the product gets everything they need in the first page, while the detail sections carry the step-by-step for the agent and deeper investigation.

## The Pattern

The opening of every document is fixed. Order matters.

| # | Section | Answers |
|---|---|---|
| 1 | YAML frontmatter | Document info — name, title, type, status, dependencies (see [frontmatter.md](frontmatter.md)) |
| 2 | Purpose & Context | What this document is, why it exists, who it is for, when to use it |
| 3 | Summary | The finished result / end-state — shown before the how-to |
| 4+ | Detail | Step-by-step instructions, prerequisites, troubleshooting, references |

Sections 1–3 are the required opening and must stand alone: a reader who stops after section 3 knows what the document is, why it exists and what the outcome looks like. Everything after is supporting detail.

## Purpose & Context

- One to three sentences: what the document covers, why it exists, who it is for, and the outcome it enables.

## Summary

This section is the **human-facing abstract** — the finished outcome at a glance.

- Show the end-state **before** the how-to.
- Workflow or process: state what and why, then give the whole flow as **bullet points** — never bury the flow in a prose paragraph.
- Knowledge: state the conclusion or result first, then the reasoning and nuance.

## Detail Sections

- Step-by-step instructions, prerequisites, edge cases, troubleshooting and cross-references.
- Depth is unlimited here — the rule governs only the opening three sections.

## Applying the Rule

- Write the first three sections first; they are the contract a reader and an agent use to decide whether to read on.
- Keep sections 2 and 3 tight and skimmable — full detail belongs in section 4+.
- Run `python scripts/wiki_lint.py` to validate frontmatter and links after creating a document.

---

*Last reviewed 2026-08-19. Changes to these rules require human sign-off.*