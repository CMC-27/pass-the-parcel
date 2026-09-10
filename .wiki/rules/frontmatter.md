---
title: Frontmatter Standard
tags: [wiki, rules, frontmatter, metadata]
status: stable
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
status: stable | in-progress | deprecated | template | approved
dependencies: [path/to/dependency.md]
related-to: [./other.md]
---
```

| Field | Required | Notes |
|---|---|---|
| `name` | Yes | Kebab-case slug matching the filename (skills + agents) or the doc's stable identifier |
| `title` | Yes | Human-readable title; displayed in indexes |
| `type` | Yes | Document type (e.g. `reference`, `standard`, `skill`, `agent`, `template`) |
| `status` | Yes | One of `stable`, `in-progress`, `deprecated`, `template`, `approved` |
| `dependencies` | No | Relative paths to documents this one depends on; path-shaped values must resolve |
| `related-to` | No | Related documents; path-shaped values must resolve |

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
4. When a document's `status` changes, update `last-reviewed` if the field is present.

## Convention Exemptions

Files under `.devops/agents/` carry **in-file** YAML frontmatter (`description` / `tools` / `model` / `user-invocable` for VS Code; `description` / `mode` / `model` for opencode). They are exempt from the wiki required-fields check (`name` / `type` / `status`) — the exemption is for wiki *fields*, never for *links*: every `related-to` / `dependencies` path in `.devops/**` and `.wiki/rules/**` is still resolved. `.opencode/` holds opencode config rather than wiki content and is exempt the same way.

---

*Last reviewed 2026-08-19. Changes to these rules require human sign-off.*