---
title: Numbering Scheme
tags: [wiki, rules, numbering, lifecycle]
status: stable
owner: Wiki Owner
last-reviewed: 2026-09-11
related-to: [./structure.md, ./naming.md]
---

# Numbering Scheme

> The single ordering principle for every numbered folder in this wiki. Numbering reflects **lifecycle + relevance** — the order in which content is produced and consumed by the product team.

## Top-Level Areas

| Prefix | Area | Lifecycle role |
|---|---|---|
| `.wiki/core/` | FOUNDATION | Cross-cutting standards — read before acting |
| `.wiki/components/` | UI | Reusable UI components and variants |
| `.wiki/features/` | FEATURES | User-facing screens and views |
| `.wiki/database/` | DATA | Schema, queries, data flow |
| `.wiki/logic/` | LOGIC | Utilities, hooks, business logic |
| `.wiki/integrations/` | CONNECTIONS | External systems and APIs |
| `.wiki/conventions/` | CONVENTIONS | Naming and coding standards |
| `.wiki/testing/` | TESTING | Test patterns, mocking, performance budgets |

> **Numbered folders are wiki-only.** Operational and development state — completed plans, archived briefs and changelogs (`.devops/archive/`, `.devops/logs/`), and planned work and active change plans (`.devops/backlog/`, `.devops/plans/`) — lives in the unnumbered [`.devops/`](../../.devops/README.md) layer, never in a numbered area.

> **Rule:** A new top-level area is added at the end of the sequence, unless it genuinely belongs earlier in the lifecycle. Renumbering existing areas requires human sign-off.

> **Manifest enforcement:** every numbered area and sub-area below is declared in the [Structure Manifest](structure.md), which `wiki_lint.py` enforces — a renamed or deleted numbered folder is a hard failure. New numbered folders must be added to the manifest before they are linked from anywhere.

## Sub-Area Numbering

Each area's sub-folders are numbered — where a numbering exists — **by their own internal lifecycle**:

| Area | Sub-area numbering |
|---|---|
| `.wiki/core/` | `00`–`18` — numeric (`NN-slug.md`), ordered by lifecycle |
| `.wiki/components/` | none — flat docs (`ui-*.md`), catalogued in `components-index.md` |
| `.wiki/features/` | none — flat docs (`feat-*.md`), catalogued in `features-index.md` |
| `.wiki/database/` | none — flat docs (`db-*.md`), catalogued in `database-index.md` |
| `.wiki/logic/` | none — flat docs (`util-*` / `hook-*` / `schemas-*.md`), catalogued in `logic-index.md` |
| `.wiki/integrations/` | none — flat docs, catalogued in `integrations-index.md` |
| `.wiki/conventions/` | none — flat docs (`conv-*.md`), catalogued in `conventions-index.md` |
| `.wiki/testing/` | none — flat docs (`pattern.md`, `mocking.md`, …), catalogued in `testing-index.md` |

## Unnumbered Directories (Meta / Tooling)

These sit **above** the numbered areas and are never numbered:

| Directory | Role |
|---|---|
| `.wiki/rules/` | Wiki governance layer — rules + the deterministic `wiki_lint.py` enforcer |
| `.wiki/rules/language/` | Language & writing governance |
| `.devops/rules/` | Dev governance layer — agents, skills, plan lifecycle |
| `.devops/` | Operational state — skills, agents, plans, backlog, archive, logs |
| `.opencode/` | opencode configuration |
| `scripts/` | Deterministic check/sync scripts |

## Numbering Rules

1. **Format:** `NN-Name` where `NN` is a two-digit sequence (`00`, `01`, ... `99`) and `Name` is a short lowercase-hyphenated label.
2. **Order by use:** place folders in the order they appear in the workflow, not alphabetically.
3. **Relevance over symmetry:** a folder used constantly gets a low number even if "later" in the formal process.
4. **Renumbering is a structural event:** when renumbering, update the row in the [Structure Manifest](structure.md), update every link that pointed at the old paths, run `wiki_lint.py --fix`, and update all spoke indexes.
5. **Never break the sequence silently:** gaps are acceptable only with a documented reason.

---

*Last reviewed 2026-09-11. Changes to these rules require human sign-off.*