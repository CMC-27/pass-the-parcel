---
title: Wiki Rules & Patterns
tags: [wiki, rules, governance, index]
status: stable
owner: Wiki Owner
last-reviewed: 2026-08-19
related-to: [../../AGENTS.md, ../../.devops/rules/README.md, ../../scripts/wiki_lint.py]
---

# Wiki Rules & Patterns

> The canonical rules that govern how this wiki is structured, named, linked and maintained. Sits **above** all numbered content areas. Both humans and AI agents consult these rules before creating, moving or renaming anything.

## When to Consult

| Trigger | Read |
|---|---|
| Creating a new folder or area | [numbering.md](numbering.md) |
| Naming a new file or document | [naming.md](naming.md) |
| Adding frontmatter to a document | [frontmatter.md](frontmatter.md) |
| Structuring a document's sections | [document-structure.md](document-structure.md) |
| Linking documents, moving content | [link-hygiene.md](link-hygiene.md) |
| Adding a doc and cataloguing it in an index | [link-hygiene.md](link-hygiene.md) §Maintenance Rules |
| Declaring an immutable anchor / numbered folder | [structure.md](structure.md) — the structure manifest, enforced by the linter |
| Deciding what belongs in wiki content vs operational state | [company-scoping.md](company-scoping.md) — the content-vs-state split |
| Agents, skills, plan lifecycle, dev/ops state | [.devops/rules/](../../.devops/rules/README.md) — the dev governance layer |
| Any structural change | [AGENTS.md](../../AGENTS.md) — the operating rules |

## Rule Files

| File | Covers |
|---|---|
| [numbering.md](numbering.md) | Lifecycle numbering scheme for all areas and sub-areas |
| [naming.md](naming.md) | File, folder and slug naming conventions |
| [frontmatter.md](frontmatter.md) | YAML frontmatter standard for every document |
| [document-structure.md](document-structure.md) | Front-loaded document pattern — purpose & context, summary, then detail |
| [link-hygiene.md](link-hygiene.md) | Cross-referencing, no-duplication and link maintenance |
| [structure.md](structure.md) | Structure manifest — machine-readable registry of every immutable anchor path (numbered areas, sub-areas, canonical files); a missing anchor is a hard lint failure |
| [company-scoping.md](company-scoping.md) | Content-vs-state principle — what lives in wiki content vs the unnumbered operational layer |
| [wiki_lint.py](../../scripts/wiki_lint.py) | Deterministic linter that enforces the rules above — structure drift, broken links, index drift, frontmatter, orphans. Run `python scripts/wiki_lint.py --fix` (wrapped by the `wiki-lint` skill). |

---

## Core Principles

1. **One ordering principle** — every numbered folder reflects its position in the consumer journey (see [numbering.md](numbering.md)).
2. **Rules live here, not scattered** — if a convention is worth following, document it in `.wiki/rules/` and reference it; never duplicate the rule into content.
3. **Numbering is lifecycle + relevance** — order by when the content is consumed, not by creation date or alphabetical order.
4. **Meta sits above content** — `.wiki/rules/`, `.wiki/rules/language/`, `.devops/rules/`, `.devops/`, `.opencode/` and `scripts/` are unnumbered governance/tooling directories that govern the numbered content under `.wiki/`. Wiki content is numbered; operational/dev state is not.
5. **Portable by default** — all knowledge and machinery is tool-agnostic and transferable between repos except where explicitly scoped to the local workspace (see [company-scoping.md](company-scoping.md)).

---

*Last reviewed 2026-08-19. Changes to these rules require human sign-off.*