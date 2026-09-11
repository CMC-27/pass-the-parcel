---
name: frontmatter
type: rule
title: Frontmatter Standard
status: stable
format-version: 1
tags: [wiki, rules, frontmatter, metadata]
owner: Wiki Owner
last-reviewed: 2026-09-11
related-to: [./naming.md, ./document-structure.md, ./claims.md]
claims:
  - id: lint-required-fields
    source: scripts/wiki_lint.py#REQUIRED_FIELDS
    hash: sha256:ac2f6280180c50edb1998b6d1134831f56c5863d902613e820c70d0dd6dec91e
---

# Frontmatter Standard

> Every document carries YAML frontmatter at the top. This enables consistent rendering, search and index integrity.

## One Schema

The wiki carries **one** frontmatter schema. It replaced two incompatible predecessors (a `name`/`type`/`dependencies` shape and a `title`/`tags`/`owner` shape) in 2026-09.

```yaml
---
name: document-name
type: core | feature | component | database | logic | rule | convention | testing | integration | examples | ref | template
status: stable | in-progress | deprecated | template | approved
format-version: 1
title: Document Title
description: One-line summary
dependencies: [path/to/dependency.md]
related-to: [./other.md]
tags: [tag, tag]
owner: Wiki Owner
last-reviewed: 2026-09-11
db_relations: [table-name]
---
```

## Field Reference

| Field | Required | Notes |
|---|---|---|
| `name` | Yes | Kebab-case slug matching the filename (skills + agents) or the doc's stable identifier |
| `type` | Yes | Document type (see the value list above). Free-form today; the linter does not restrict it |
| `status` | Yes | One of `stable`, `in-progress`, `deprecated`, `template`, `approved` |
| `format-version` | Yes | Schema generation of this frontmatter. Current value: `1`. Bump only on a breaking schema change |
| `title` | No | Human-readable title; displayed in indexes. Recommended on every doc |
| `description` | No | One-line summary for index rows and generated catalogs |
| `dependencies` | No | Relative paths to documents this one depends on; path-shaped values must resolve |
| `related-to` | No | Related documents; path-shaped values must resolve |
| `tags` | No | Free-form keywords for search |
| `owner` | No | Accountable owner of the document |
| `last-reviewed` | No | Date this document's content was last verified against reality |
| `db_relations` | No | Data tables this document describes |

## format-version Changelog

- **1** (2026-09-11) — one schema across all sections. Required set narrowed to `name`/`type`/`status`/`format-version`; every earlier field retained as optional.

## Status Lifecycle

- **stable** — signed off; usable as authoritative.
- **in-progress** — in drafting, not ready for use.
- **deprecated** — superseded; retained for reference.
- **template** — a pattern/example doc, not live repo reality (used by seeds and genericised examples).
- **approved** — governance docs (`.devops/rules/**`) that are active but not wiki "stable".

> **Rule:** Only a human can promote a document to `stable`. Agents may draft and request review, never self-approve.

## Frontmatter Rules

1. Frontmatter is the **first thing** in the file, delimited by `---` lines.
2. `dependencies` and `related-to` paths are relative and must resolve (see [link-hygiene.md](link-hygiene.md)). Path-shaped values — anything containing `/` or ending `.md` — are resolved and a missing target is a **hard** lint failure. Other tokens (component names, table names, `[placeholders]`) are informational.
3. Run `python scripts/wiki_lint.py` to validate frontmatter across the wiki.
4. When a document's `status` changes, update `last-reviewed`.
5. Grounded evidence for a document's material claims lives in the `claims:` field — see [claims.md](claims.md).

## Convention Exemptions

Files under `.devops/agents/` carry **in-file** YAML frontmatter (`description` / `tools` / `model` / `user-invocable` for VS Code; `description` / `mode` / `model` for opencode). They are exempt from the wiki required-fields check (`name` / `type` / `status` / `format-version`) — the exemption is for wiki *fields*, never for *links*: every `related-to` / `dependencies` path in `.devops/**` and `.wiki/rules/**` is still resolved. `.opencode/` holds opencode config rather than wiki content and is exempt the same way. README and `*-index.md` files are exempt — they are navigation surfaces, not content docs.

---

*Last reviewed 2026-09-11. Changes to these rules require human sign-off.*
