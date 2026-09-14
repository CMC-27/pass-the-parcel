---
type: "theme"
theme: T2
name: "Wiki System & Knowledge Layer"
status: "active"
description: "Close the gap between this repo's curated wiki and an OpenWiki-class self-maintaining wiki."
---

# T2 — Wiki System & Knowledge Layer

> Close the gap between this repo's **curated** wiki and an OpenWiki-class **self-maintaining** wiki. Governance is the moat; generation is borrowed via OKF interop.

## E1 — Wiki Self-Maintenance & Interop

### Open

| Code | Title | Status | Description | Plan |
|------|-------|--------|-------------|------|
| _(none)_ | | | | |

### Completed

| Code | Title | Resolved | Note | Archive |
|------|-------|----------|------|---------|
| T2-E1.01 | Wiki self-maintenance parity | 2026-09-11 | Unified `format-version: 1` schema, Grounded Claims layer + secret-free CI drift gate, `@wiki-update` / `@wiki-generate` (bootstrap demoted to verification), OKF v0.2 export, `docs/` visualizer. | [plan](../archive/t2-e1.01-wiki-self-maintenance-parity-plan.md) |
| T2-E1.03 | Coverage-gate symbol evidence | 2026-09-11 | `wiki_coverage_check.py` four-route evidence OR — filename, parent folder, index-cited exported symbol, `claims: source` binding. | [plan](../archive/t2-e1.03-coverage-gate-symbol-evidence-plan.md) |

## E2 — Grounding & Guard Hardening

### Open

| Code | Title | Status | Description | Plan |
|------|-------|--------|-------------|------|
| _(none)_ | | | | |

### Completed

| Code | Title | Resolved | Note | Archive |
|------|-------|----------|------|---------|
| T2-E2.03 | Knowledge Capture second destination + machinery register | 2026-09-14 | KC is routed by subject: app-domain → `.wiki/core/18-knowledge-capture.md`; machinery/process/tooling → the new `.devops/rules/process-lessons.md` register (`knowledge-capture` v7 §3 Destination Routing + `knowledge-consolidation` v8 Phase 6b `promote-machinery`). The size trigger moves from physical lines to a **25-entry ceiling**, since hard-wrapping inflated line counts without adding rules. `sprint-close` v4 reviews the register at close; KC's own scope note + Knowledge System rule reconciled and claims restamped (the `#hard 500-line ceiling` anchor was dead). machinery 43. | — (no plan file) |
| T2-E2.01 | Wiki grounding hardening | 2026-09-11 | Rules-index completeness gate (`[UNCATALOGUED]`), grounded claims across core slots, `UNRESOLVED-SYMBOL` `#symbol` resolution, visualizer freshness mode, UTF-8 guard extended. | [plan](../archive/t2-e2.01-wiki-grounding-hardening-plan.md) |
| T2-E2.02 | Wiki refresh automation | 2026-09-11 | `wiki_okf.py import` OKF v0.2 ingest; secret-free scheduled `wiki-refresh.yml` raises/closes a `wiki-drift` issue. | [plan](../archive/t2-e2.02-wiki-refresh-automation-plan.md) |
