---
name: naming
type: rule
title: Naming Conventions
tags: [wiki, rules, naming, conventions]
status: stable
format-version: 1
owner: Wiki Owner
last-reviewed: 2026-09-13
related-to: [./numbering.md, ./frontmatter.md]
---
# Naming Conventions

> Consistent naming keeps the wiki navigable for humans and AI. Every file and folder name must follow these rules.

## Folder Names

- Numbered areas: `NN-name` per [numbering.md](numbering.md), e.g. `.wiki/core/`, `.wiki/components/`.
- Unnumbered meta directories use lowercase dot-prefix or plain lowercase: `.devops/`, `.opencode/`, `.wiki/rules/`, `scripts/`.

## File Names (documents)

| Pattern | Example | Used for |
|---|---|---|
| `kebab-case.md` | `data-flow.md` | Knowledge docs, work instructions |
| `NN-slug.md` | `09-design-system.md` | Indexed core docs, sequenced standards |
| `<slug>/SKILL.md` | `wiki-query/SKILL.md` | Skills (in `.devops/skills/`) |
| `<slug>.agent.md` | `parcel.agent.md`, `parcel-fast.agent.md`, `parcel-sprint.agent.md` | Selectable agents (in `.devops/agents/`) |
| `ptp-<slug>.subagent.md` | `ptp-context-hunter.subagent.md` | Subagents (in `.devops/agents/`) |

## Naming Rules

1. **Lowercase with hyphens** for kebab-case slugs — never camelCase or underscores in file names.
2. **Descriptive, not generic** — prefer `database-connection-pooling.md` over `db.md`.
3. **No version numbers in file names** — versioning lives in frontmatter and review history, not the filename.
4. **Acronyms** stay uppercase in names: `CSV.md`, `API.md`, `SKILL.md`.

## Index Files

- Every area has an index that lists all documents in it.
- The index filename is `<area>-index.md` (e.g. `components-index.md`, `conventions-index.md`), or `index.md`. Keep the existing name — do not rename an index after creation.

---

*Last reviewed 2026-09-13. Changes to these rules require human sign-off.*