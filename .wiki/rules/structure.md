---
title: Structure Manifest
tags: [wiki, rules, structure, anchors, governance]
status: approved
owner: Wiki Owner
last-reviewed: 2026-08-19
related-to: [./naming.md, ./numbering.md, ./link-hygiene.md, ../../scripts/wiki_lint.py]
---

# Structure Manifest

> Machine-readable registry of every **immutable anchor path** in the wiki. Loaded by the `wiki-lint` skill and enforced by `wiki_lint.py` — a missing anchor is a hard failure (exit 1), not a lint warning.

## Purpose & Context

Direct relative links keep the wiki portable, but they break the moment an anchor path changes. The numbered `NN-name` areas, their numbered sub-areas and the canonical-authority files below are declared **immutable** — renaming, moving or deleting one is a structural event that must be registered **before** it propagates.

`wiki_lint.py` compares the live tree against this manifest on every run:

- **Anchor missing → hard failure** (exit 1) with guidance to register the move.
- **Numbered folder present but not registered → advisory** — add a row before the folder accumulates inbound links.

## Summary

- Every numbered area, numbered sub-area and canonical file the wiki depends on has exactly one row here.
- A renamed anchor is caught the first time `wiki_lint.py` runs after the change, with a clear instruction to register the old path in the redirect log.
- Adding a numbered folder means adding one row here **before** the folder is linked from anywhere.
- No anchor row is pruned — the manifest records the current structural contract, not history.
- The linter exits 0 only when no links are broken **and** no anchor is missing.

## Schema

| Column | Meaning |
|---|---|
| Anchor | Human-readable name |
| Type | `area` (top-level), `sub-area` (numbered folder under an area), `file` (canonical document) |
| Path | Repo-relative path (folder or file) — exactly as it must exist on disk |
| Note | Why this path is immutable |

## Immutable Anchors

### Wiki Content Areas (type: `area`)

| # | Anchor | Type | Path | Note |
|---|---|---|---|---|
| 1 | Core Standards | area | `.wiki/core/` | Cross-cutting standards — read before acting |
| 2 | Components | area | `.wiki/components/` | Reusable UI components |
| 3 | Features | area | `.wiki/features/` | User-facing screens and views |
| 4 | Database | area | `.wiki/database/` | Schema, queries, data flow |
| 5 | Logic | area | `.wiki/logic/` | Utilities, hooks, business logic |
| 6 | Integrations | area | `.wiki/integrations/` | External systems and APIs |

### Unnumbered Meta / Tooling Directories (type: `area`)

| # | Anchor | Type | Path | Note |
|---|---|---|---|---|
| 7 | Wiki Rules | area | `.wiki/rules/` | Governance layer, sits above all content |
| 8 | Language Rules | area | `.wiki/rules/language/` | Language and writing governance |
| 9 | Dev Rules | area | `.devops/rules/` | Dev governance layer — agents, skills, plans |
| 10 | Dev Ops State | area | `.devops/` | Operational state — skills, agents, plans, backlog, archive, logs |
| 11 | Opencode Config | area | `.opencode/` | opencode configuration |

### Canonical Authority Files (type: `file`)

| # | Anchor | Type | Path | Note |
|---|---|---|---|---|
| 12 | Repository README | file | `README.md` | Human entry point |
| 13 | Operating Rules | file | `AGENTS.md` | Authoritative operating layer |
| 14 | System Index | file | `.wiki/core/00-system-index.md` | Wiki entry point |
| 15 | Knowledge Capture | file | `.wiki/core/18-knowledge-capture.md` | Decision log |
| 16 | Structure Manifest | file | `.wiki/rules/structure.md` | This file — loaded by the linter |
| 17 | Wiki Linter | file | `scripts/wiki_lint.py` | Deterministic enforcer — hardcoded dependency |
| 18 | Base Context | file | `.opencode/plans/base-context.md` | PREFIX-LOCKED canonical header |

## See Also

- [link-hygiene.md](link-hygiene.md) — structural change protocol
- [numbering.md](numbering.md) — lifecycle numbering scheme this manifest enforces
- [naming.md](naming.md) — naming conventions

---

*Last reviewed 2026-08-19. Changes to these rules require human sign-off.*