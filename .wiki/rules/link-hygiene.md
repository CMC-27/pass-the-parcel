---
name: link-hygiene
type: rule
title: Link Hygiene
tags: [wiki, rules, links, cross-referencing]
status: stable
format-version: 1
owner: Wiki Owner
last-reviewed: 2026-09-27
related-to: [./naming.md, ./frontmatter.md, ./structure.md, ../../AGENTS.md]
---
# Link Hygiene

> The wiki is a connected web, not isolated pages. These rules keep every link resolvable, every claim sourced, and every document in its canonical location.

## Cross-Referencing

1. **Cite sources** with relative links: `[Title](path)` — every claim about architecture, behaviour or decisions must link to its source.
2. **Never make unsourced claims** — if unknown, say so; use the `wiki-query` skill before asserting.
3. **Don't fabricate** — if a fact isn't in the wiki, don't invent it. Flag it for capture instead.
4. **Link down, not up** — content links to reference docs; indexes link to content. Avoid linking content → index in the body.

## No Duplication

1. **Single canonical source** — each fact, pattern or decision lives in exactly one place.
2. **Link, don't copy** — never paste content into a second file. Point to the canonical document instead.
3. **Register moves, never stub** — when moving a document, update every link that pointed at the old path, and update the [Structure Manifest](structure.md) if the path is an anchor. Do **not** leave a physical "Moved to …" stub at the old location. Git records the move; there is no separate redirect artifact to maintain. Archived history stays in `.devops/archive/` as content.
4. **Immutable anchors are declared, not assumed** — every numbered area, numbered sub-area and canonical file is registered in the [Structure Manifest](structure.md). A missing anchor is a hard lint failure, so a rename surfaces at move-time, not after links break.

## Link Types

| Link | Form | Example |
|---|---|---|
| Within same folder | `./file.md` or `file.md` | `[Naming](./naming.md)` |
| Up one level | `../folder/file.md` | `[Index](../index.md)` |
| Cross-area | relative `../` chain | `[Design System](../core/09-design-system.md)` |
| External | full URL | `https://...` |

> **Relative-depth rule:** after any directory move, recompute `../` depth — a flatten by one level breaks every skill/agent link.

## Structural Change Protocol

When adding, renaming, moving or deleting a document:

1. **Update every link to the old path** — a move is not complete until `wiki_lint.py` reports 0 broken links. Never leave a physical stub.
2. **If the path is an anchor** (numbered area, numbered sub-area or canonical file), update its row in the [Structure Manifest](structure.md) — a missing anchor is a hard lint failure.
3. Update the area index (add/remove the entry).
4. Run `python scripts/wiki_lint.py --fix` to catch broken links, structure drift, orphans and frontmatter violations.
5. Fix every `dependencies` and inline link that points at the old path; re-verify with the linter until broken links = 0 and structure drift = 0.

## Maintenance Rules

1. **Orphans are allowed only for templates and READMEs** — every content doc should have at least one inbound link.
2. **No dead links** — a link to a missing target is a bug, not a TODO. If the target moved, register it; if it was deleted, remove the link.
3. **Archive is historical** — never rewrite archived content after the fact; leave the record intact.
4. **Never link a transient path.** A plan's physical location moves — sprint queue → `.devops/plans/` → `.devops/archive/` — so link it at its **permanent** home or not at all. When a plan moves, treat every document that referenced it as a dangling-link candidate: its `sprint.md` queue row, any `related-to` naming a sprint folder, and any audit that cited the sprint-queue path. `wiki_lint.py --quiet` is a **gating** CI step (no `continue-on-error`), so one stale link reddens a whole build. A link into a **gitignored** run workspace (`.opencode/plans/run-*/`) breaks for every clone — quote the run artefact inline instead. *(process-lessons, 2026-09-26)*
5. **Anchor fragments bind to header text, not file names.** Retargeting a path (`05-design-system.md` → `09-design-system.md`) leaves `#5c-form-field-hygiene` pointing at a renamed slug. After any retarget, validate every anchor against the target's header slugs, or run `@wiki-lint`. *(process-lessons, 2026-07-26)*
6. **Renumbering leaves stale agent paths.** A core-file renumbering renames files but not the doc paths inside `.devops/agents/*.md`, breaking subagent spawns. After any renumbering, grep the agent files for doc paths — and never retro-edit historical records in `.devops/logs/` or `.devops/archive/`. *(process-lessons, 2026-07-26)*
4. **Every document is catalogued** — a new or moved doc must appear in its category index (`features-index.md`, `logic-index.md`, etc.), and every index entry must point at an existing file. The linter reports gaps as `[UNINDEXED]` / `[MISSING]` warnings; run `python scripts/wiki_lint.py --fix` to add or remove index rows automatically. An unlisted doc is invisible to agents routing from the hub.

---

*Last reviewed 2026-08-19. Changes to these rules require human sign-off.*