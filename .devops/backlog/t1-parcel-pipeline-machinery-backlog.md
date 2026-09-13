---
type: "theme"
theme: T1
name: "Parcel Pipeline Machinery"
status: "active"
description: "The stateless multi-agent parcel pipeline: model/config integrity, governance, and transport."
---

# T1 — Parcel Pipeline Machinery

> The parcel pipeline is the repo's execution engine: a self-contained markdown plan, a 10-phase workflow, four hard gates, and independent review. This theme keeps that machinery correct, coherent, and transportable to satellites.

## E1 — Model & Config Integrity

### Open

| Code | Title | Status | Description | Plan |
|------|-------|--------|-------------|------|
| _(none)_ | | | | |

### Completed

| Code | Title | Resolved | Note | Archive |
|------|-------|----------|------|---------|
| T1-E1.01 | Reconcile model registry | 2026-09-03 | Model Registry replaced with abstract capability slots (`planning` / `review-heavy` / `execution`); concrete model binding is satellite configuration in `opencode.json`. **Reversed 2026-09-13 by T1-E1.03** — the registry is now the single source and sync force-stamps the fleet. | [plan](../archive/t1-e1.01-reconcile-model-registry-plan.md) |
| T1-E1.02 | Parcel-Fast locked preset | 2026-09-13 | New selectable orchestrator `parcel-fast` ships a **locked preset** (`Mode=AUTO`, `Agents=SINGLE`): it skips the Mode/Topology questions, runs inline personas, and is bound `task: deny` so `SINGLE` is enforced structurally. Preset declared in the `## Orchestrator Presets` table of `base-context.md`; executed as a direct machinery session. | — (no plan file) |

## E2 — Governance & Transport Integrity

### Open

| Code | Title | Status | Description | Plan |
|------|-------|--------|-------------|------|
| T1-E2.02 | Split the `check-parcel-prefix.ps1` god-script | PARKED | Four unrelated concerns in one pass (registry, prefix integrity, skill embeds, binding integrity). Extract the binding checks to `scripts/check-model-bindings.ps1`; wire into `portable_files`, `validate.yml` and `-Verify`. Flagged by T1-E1.03's Phase 6 triage. | [parked](../t1-e2.02-check-parcel-prefix-split-backlog.md) |

### Completed

| Code | Title | Resolved | Note | Archive |
|------|-------|----------|------|---------|
| — | Promote Plan Settings header | 2026-09-12 | `Mode`/`Agents` promoted from the cache-anchored bottom `State & Gates` table to a frozen top-of-file `## ⚙️ Plan Settings` block; bottom now holds only mutable state. | [plan](../archive/promote-plan-settings-header-plan.md) |
| T1-E2.01 | Machinery hardening | 2026-09-11 | Doc-truth sweep, canonical parked-plan location, rules-row reconciliation. | [plan](../archive/t1-e2.01-machinery-hardening-plan.md) |

## E3 — Concurrency & Sprint Lifecycle

### Open

| Code | Title | Status | Description | Plan |
|------|-------|--------|-------------|------|
| _(none)_ | | | | |

### Completed

| Code | Title | Resolved | Note | Archive |
|------|-------|----------|------|---------|
| T1-E3.01 | Concurrency & sprint lifecycle rewrite | 2026-09-13 | Worktree-per-plan + claim protocol; `.devops/sprints/sprint-{n}-<slug>/` with a single `sprint.md`; theme registers; shipped plans archive at root. Executed as a direct SINGLE session with the design locked interactively — see `.devops/logs/agent-changelog.md`. | — (no plan file) |
| T1-E3.02 | Sprint batch runner (`@sprint-run` + `parcel-sprint` + `ptp-parcel-fast`) | 2026-09-13 | Unattended batch execution of the committed sprint queue: new selectable host `parcel-sprint` spawning one hidden `ptp-parcel-fast` per plan (locked `AUTO`+`SINGLE`, fresh context), trunk-sequential claim, batched Gate D. Three deviations mirrored into the shared prefix + `plan-lifecycle.md`. | [plan](../archive/t1-e3.02-sprint-batch-runner-plan.md) |
