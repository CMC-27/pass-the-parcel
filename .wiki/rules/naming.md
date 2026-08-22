---
title: Naming Conventions
tags: [wiki, rules, naming, conventions]
status: approved
owner: Wiki Owner
last-reviewed: 2026-08-19
related-to: [./numbering.md, ./frontmatter.md]
---

# Naming Conventions

> Consistent naming keeps the wiki navigable for humans and AI. Every file and folder name must follow these rules.

## Folder Names

- Numbered areas: `NN-name` per [numbering.md](numbering.md), e.g. `docs/wiki/core/`, `docs/wiki/components/`.
- Unnumbered meta directories use lowercase dot-prefix or plain lowercase: `.devops/`, `.opencode/`, `.wikirules/`, `scripts/`.

## File Names (documents)

| Pattern | Example | Used for |
|---|---|---|
| `kebab-case.md` | `data-flow.md` | Knowledge docs, work instructions |
| `NN-slug.md` | `09-design-system.md` | Indexed core docs, sequenced standards |
| `<slug>/SKILL.md` | `wiki-query/SKILL.md` | Skills (in `.devops/skills/`) |
| `<slug>.md` | `parcel-orchestrator.md` | Agent runbooks (in `.devops/agents/`) |

## Naming Rules

1. **Lowercase with hyphens** for kebab-case slugs — never camelCase or underscores in file names.
2. **Descriptive, not generic** — prefer `database-connection-pooling.md` over `db.md`.
3. **No version numbers in file names** — versioning lives in frontmatter and review history, not the filename.
4. **Acronyms** stay uppercase in names: `CSV.md`, `API.md`, `SKILL.md`.

## Index Files

- Every area has an `index.md` or `*index.md` that lists all documents in it.
- Index filenames are fixed: `index.md` — do not rename.

---

*Last reviewed 2026-08-19. Changes to these rules require human sign-off.*