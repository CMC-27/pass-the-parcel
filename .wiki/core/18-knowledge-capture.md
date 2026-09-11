---
title: "Knowledge Capture & Decision Log 🧠"
type: "core"
name: "Knowledge Capture"
status: "stable"
dependencies: []
db_relations: []
description: "Canonical log of core engineering decisions, tribal knowledge, and architectural strategies."
---

# Knowledge Capture & Decision Log

> Tribal knowledge only: edge cases with future practical use that the wiki cannot hold. Agents read the wiki first — anything the wiki covers is deleted here, never pointed at. Hard cap 500 lines; entries ≤3 lines (Rules/Pitfalls), ≤10 lines (Archive, max 5). Capture via `knowledge-capture`; pruning via `knowledge-consolidation` (tidy after every plan).

## Quick Reference — Top 10 Rules
| # | Rule | Theme | Pitfall? |
|---|------|-------|----------|
| 1 | State & Gates live at the BOTTOM of a plan; everything above stays byte-stable (LLM prefix cache) | Parcel | ❌ |
| 2 | SKILL.md is canonical; agents embed it verbatim — regenerate with `check-parcel-prefix.ps1 -Sync`, never hand-edit | Parcel | ❌ |
| 3 | Machinery evolves in the farthest-evolved consumer; the template absorbs what survived production | Sync | ❌ |
| 4 | Portable machinery carries no absolute paths or machine-specific config | Sync | ✅ |
| 5 | Normalize CRLF→LF before hashing files across git boundaries on Windows | Sync | ✅ |
| 6 | Versioning = integer counters only; portable skills are derived (all minus `excluded_skills:`), never declared | Sync | ❌ |
| 7 | Never edit PREFIX-LOCKED surfaces directly — edit `base-context.md`, then run `check-parcel-prefix.ps1 -Sync` | Parcel | ✅ |
| 8 | Phase 3 clarification questions go to the user one at a time | Parcel | ❌ |
| 9 | Measure a gate's actual cost before optimizing agent token spend around it | Process | ✅ |
| 10 | KC entries land ≤3 lines at capture; superseded entries are cut, never struck through | Knowledge | ✅ |

## Pitfalls to Avoid
_(Mistakes that cost time or broke things. Read these first when starting similar work.)_

- **UTF-8 mojibake in machinery files**: corruption propagates through sync and silently degrades every agent that reads the file. *Do instead:* repair to clean UTF-8 (no BOM); never re-copy a corrupted file wholesale.
- **Editing a truncated line**: `read_file` truncates long lines (~2000 chars); an edit that trusts the tail writes literal `[truncated]` text mid-file. *Do instead:* re-read or rewrite the whole entry; for giant-line appends, write a temp file and append via `[IO.File]::AppendAllText` with UTF8-no-BOM (PowerShell `Set-Content -Encoding UTF8` writes a BOM and breaks `wiki_lint.py` frontmatter checks).


## Rules & Constraints
_(Stable rules derived from prior decisions. Grouped by theme.)_

### Sync & Versioning
- **Farthest-evolved consumer wins**: when template and satellite diverge, port the satellite's battle-tested machinery back; app-specific content stays in the consumer. *(2026-09-03)*
- **Post-sync bookkeeping self-heals**: sync stamps the target manifest's `machinery-version:` in place; `-Check` hashes only agent-unique content (frontmatter stripped), so per-repo prefix regeneration never reports phantom DRIFT. *(2026-09-06)*

### Parcel Pipeline
- **Cache-anchored plans**: the State & Gates section sits last and holds the only mutable state rows; content above stays byte-stable across the whole lifecycle. *(2026-08-19)*
- **Single execution source**: the plan file is the only thing the code-surgeon reads — no versioned snapshots (the `v1.0 → v2.0_approved` pipeline is retired). *(2026-09-06)*
- **One state machine, five mirrors**: the 4-gate model (A Scope / B Spec & Plan / C Peer Reviews / D Implementation) is stated identically in the orchestrator skill, base-context, parcel agent, template, and rules doc. *(2026-09-07)*

### Agents & Models
- **Dual-surface agent binding**: agents live once in `.devops/agents/*.agent.md`; VS Code reads per-file frontmatter, opencode reads `opencode.json`. Per-file binding means the orchestrator cannot mis-spawn a model; use the provider's exact picker casing. *(2026-09-06)*
- **Set-level agent versioning**: agents are versioned as a coordinated set via `machinery-version:` — no per-file `version:`; only skills carry per-file versions, because the sync drift checker reads those from `SKILL.md`. *(2026-09-04)*

### Product & Process
- **Measure, then optimize**: measure a gate's real cost/output before restructuring around an estimated token claim. *(2026-09-03)*

### Knowledge System
- **Consolidation closes the loop**: `agent-wrap-up` Phase 6 captures AND runs `@knowledge-consolidation` (tidy mode). Capture is append-lean (≤3 lines); tidy prunes. Full audit fires only on its own triggers or when this file exceeds 200 lines. *(2026-09-09)*

## Decision Archive
_(Only decisions whose full story prevents a specific repeat mistake. Most recent 5 max.)_

### Parcel Machinery Determinism Overhaul — 4 Gates, Script-Enforced Embeds, One Question At A Time *(2026-09-07)*
- **Context**: The pipeline's state machine was stated three different ways across five surfaces; each ptp agent embedded a drifted condensed copy of its skill; gate-affecting decisions leaned on judgment words ("feels like a bolt-on").
- **Action**: Canonicalized the 4-gate model (A Scope / B Spec & Plan / C Peer Reviews / D Implementation), stated identically in orchestrator skill, base-context, parcel agent, template, and rules doc. Agent files now embed SKILL.md verbatim between `<!-- EMBED:START:<key> -->` markers, byte-checked and regenerated by `check-parcel-prefix.ps1 -Sync`. Judgment hedges replaced with operational tests (Bolt-on Test, binary telemetry rule, 20-file blast-radius bound). Phase 3 questions one-at-a-time; reviewers read-only with Findings Output Contracts (`**REJECTED:**` first line). Supersedes the capability-slot registry (2026-09-03) and the 2026-08-17 phase→model mapping.
- **Rationale**: Conflicting definitions let each surface silently redefine the protocol; verbatim embeds make drift a build failure; determinism means mechanical verification of structure while judgment stays on product decisions.
