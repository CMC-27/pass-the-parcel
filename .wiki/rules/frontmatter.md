---
title: Frontmatter Standard
tags: [wiki, rules, frontmatter, metadata]
status: approved
owner: Wiki Owner
last-reviewed: 2026-08-19
related-to: [./naming.md, ./document-structure.md]
---

# Frontmatter Standard

> Every document carries YAML frontmatter at the top. This enables consistent rendering, search and index integrity.

## Required Fields

```yaml
---
title: Document Title
name: document-name
type: reference
status: stable | in-progress | deprecated
dependencies: [path/to/dependency.md]
---
```

| Field | Required | Notes |
|---|---|---|
| `name` | Yes | Kebab-case slug matching the filename (skills + agents) or the doc's stable identifier |
| `title` | Yes | Human-readable title; displayed in indexes |
| `type` | Yes | Document type (e.g. `reference`, `standard`, `skill`, `agent`, `template`) |
| `status` | Yes | One of `stable`, `in-progress`, `deprecated` |
| `dependencies` | No | Relative paths to documents this one depends on; must resolve |

## Status Lifecycle

- **stable** — signed off; usable as authoritative.
- **in-progress** — in drafting, not ready for use.
- **deprecated** — superseded; retained for reference.

> **Rule:** Only a human can promote a document to `stable`. Agents may draft and request review, never self-approve.

## Frontmatter Rules

1. Frontmatter is the **first thing** in the file, delimited by `---` lines.
2. `dependencies` paths are relative and must resolve (see [link-hygiene.md](link-hygiene.md)).
3. Run `python .wikirules/wiki_lint.py` to validate frontmatter across the wiki.
4. When a document's `status` changes, update `last-reviewed` if the field is present.

## Convention Exemptions

Files under `.devops/agents/` deliberately use pure-body runbooks — frontmatter (name/description/mode/model/permission) lives in `opencode.json`, not the runbook file. These paths are exempt from the required-fields check in `wiki_lint.py`. `.opencode/` holds opencode config rather than wiki content and is exempt the same way.

---

*Last reviewed 2026-08-19. Changes to these rules require human sign-off.*