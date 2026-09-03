<!--
type: template
version: 1
updated: 2026-09-03

SEED TEMPLATE — copy to <satellite root>/.opencode/plans/base-context.md and customize.

WARNING: this file is the canonical shared PREFIX for all parcel-* agents. It is inlined
byte-for-byte at the start of every .devops/agents/parcel-*.md runbook. Editing it requires
re-running `scripts/check-parcel-prefix.ps1 -Sync` AFTER opencode.json agent blocks exist,
otherwise agents run on a stale prefix and the cache-anchor contract breaks.

Sections marked CUSTOMIZE are workspace-specific. The delegation map + model registry are
MACHINERY — mirror them exactly from the pass-the-parcel skill or downstream agents will
normalize model aliases inconsistently.
-->

> **PREFIX-LOCKED:** Canonical shared prefix for all parcel-* agents. This block is inlined byte-for-byte at the start of every `.devops/agents/parcel-*.md` runbook (pure body — frontmatter lives in opencode.json). Do NOT edit this block in any agent file — edit this file and re-sync (see `scripts/check-parcel-prefix.ps1`).

## Core Development Rules (from AGENTS.md)

<!-- CUSTOMIZE: condense your AGENTS.md rules to one line each. Keep numbering identical
     between AGENTS.md and here so agents can cross-reference. -->
1.
2.
3.

## Task Lookup
<!-- CUSTOMIZE: the rows agents need mid-execution (a subset of AGENTS.md's table is fine). -->
| Task | Read first | Then drill into |
|---|---|---|
| Asking question about codebase | `@wiki-query` skill | Cites `[Title](path)` from `.wiki/` |

## PTP Delegation Map (canonical)
<!-- MACHINERY: keep verbatim unless the pass-the-parcel skill itself changes. -->
| Phase(s) | Sub-agent | Model |
|---|---|---|
| 1-3 | `parcel-context-hunter` | mimo-2.5 |
| 3.5 (AUTO) | `parcel-phase3-answerer` | mimo-2.5 |
| 4-5 (+ revision) | `parcel-high-visionary` | mimo-2.5 |
| 6 | `parcel-grumpy-architect` | v4-flash-max |
| 7 | `parcel-smooth-operator` | mimo-2.5 |
| 8-9 | `parcel-code-surgeon` | deepseek-v4-flash |

## Model Registry (canonical identifiers — no aliases)
- `mimo-2.5` — orchestrator + Phases 1-3, 4-5, 7 + Wrap Up
- `v4-flash-max` — Phase 6 (Grumpy Architect Spec & Logic Audit)
- `deepseek-v4-flash` — Phases 8-9 (Code Surgeon, single-pass direct-to-disk + QA)

## PTP Lifecycle
`BACKLOG` -> `PHASE_1` -> `PHASE_3` -> `PHASE_4` -> `PHASE_5` -> `PHASE_7` -> `PHASE_9` -> `COMPLETE`

**Revision loop:** `PHASE_7` -> (Phase 6/7 fail) -> `PHASE_5_REVISION` -> `PHASE_5` -> `PHASE_7`

**Gates:** A (Spec & Plan) -> B (Review) -> C (Implementation)

**Modes:** `BLIND`/`SINGLE` (agent delegation) x `USER-MANAGED`/`AUTO` (gate behavior)

## Workspace Layout
<!-- CUSTOMIZE: your plan/archive/run directories if they differ from the blueprint defaults. -->
- Active plans: `.devops/plans/[slug]-plan.md`
- Plan template: `.devops/plans/template-plan.md`
- Per-run workspace: `.opencode/plans/run-[slug]/`
- Reviews: `run-[slug]/reviews/product_review.md`, `run-[slug]/reviews/arch_review.md`
- Audit log: `run-[slug]/decision_log.md`
- Archived plans: `.devops/archive/`
