---
type: "skill"
name: "wiki-generate"
status: "stable"
description: "Drafts wiki structure from the codebase: hub/spoke index rows, doc skeletons, and a linked catalog. Use when bootstrapping docs for new code, refreshing index rows after new files land, or ingesting an OpenWiki/OKF bundle. Drafts only — the wiki-bootstrap verification pass confirms accuracy before docs go stable. Native generation for structure; OpenWiki interop for prose."
references: "references/ — optional per-domain scaffolds. scripts/wiki_okf.py — OKF v0.2 export projection."
version: 1
updated: 2026-09-11
---

# wiki-generate

Generate wiki structure from reality, then hand it to `@wiki-bootstrap` to verify.

> **This skill drafts. It does not bless.** Every doc it writes stays `status: in-progress` until `@wiki-bootstrap` verifies it against the codebase and a human promotes it.

---

## 1. When This Skill Runs

| Situation | Action |
|---|---|
| New source files landed with no wiki docs | Draft doc skeletons + index rows |
| Index rows are missing for existing docs | Draft the rows; hand to `@wiki-lint` to confirm `[UNINDEXED]` clears |
| A satellite brings an `openwiki/` bundle | Ingest the bundle as draft docs (interop path) |
| A doc needs prose written/rewritten | **Not this skill** — use `@wiki-writer` |
| A doc needs its content verified | **Not this skill** — use `@wiki-bootstrap` |

---

## 2. Native Generation (structure)

Inputs: `.wiki/*-index.md` (the authoritative catalogs) and the source tree.

1. **Read the taxonomy.** Open `.wiki/core/17-docs-blueprint.md` for the doc naming and folder rules, and the relevant `.wiki/*-index.md` for the current rows.
2. **Inventory the gap.** For a domain with sources but no docs, list the source files and group them the way the index groups its siblings.
3. **Draft index rows.** One row per new doc, matching the index's existing column shape. Use the source file name for `[Title](path)` and a one-line `description`. Never invent a description that the code does not support.
4. **Draft doc skeletons.** Frontmatter uses the unified schema (`.wiki/rules/frontmatter.md`) with `status: in-progress` and `format-version: 1`. Body: H1, a 2-3 sentence overview, Technical Context (paths, data shapes), Relationships (cross-links), Rules & Constraints (if any). Follow `.wiki/core/17-docs-blueprint.md` and `@wiki-writer` discipline.
5. **Ground what you assert.** Where a draft states a material fact, add a `claims:` entry pointing at the real source (`path#symbol`) and run `python scripts/wiki_claims.py update`.
6. **Hand off.** Run `python scripts/wiki_lint.py`; then invoke `@wiki-bootstrap` to verify the drafts one doc at a time.

> **Never mark generated docs `stable`.** Generation produces a claim; verification produces truth.

---

## 3. OpenWiki / OKF Interop (prose)

A satellite may bring its own generator. When an `openwiki/` bundle is present:

1. Ingest the bundle's concept docs (`type:`-bearing Markdown files) as **drafts** under the matching `.wiki/` domain.
2. Preserve the bundle's `description`/`tags` when they map cleanly; otherwise fall back to the unified schema and record the gap.
3. Treat the bundle as a claim source, not as truth — run `@wiki-bootstrap` verification before promoting anything.
4. To go the other way, use `python scripts/wiki_okf.py export` to project this wiki into an OKF v0.2 bundle for an OKF-aware consumer.

The local schema stays authoritative. OKF is a projection; it is never the source of truth.

---

## 4. Boundaries

- **No content invention.** If the code does not tell you what a doc should say, write `[PLACEHOLDER: <reason>]` and flag it — never guess.
- **No prose rewriting.** Drafting only. Prose polish belongs to `@wiki-writer`.
- **No promotion.** `stable` is a human decision, recorded at wrap-up.
- **Structure only, by default.** Native generation drafts indexes and skeletons; it does not author deep prose from source.

---

> **The rule:** generate from reality, ground every claim, verify before you stable.
