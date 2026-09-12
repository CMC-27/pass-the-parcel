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
| T1-E1.01 | Reconcile model registry | 2026-09-03 | Model Registry replaced with abstract capability slots (`planning` / `review-heavy` / `execution`); concrete model binding is satellite configuration in `opencode.json`. | [plan](../archive/t1-e1.01-reconcile-model-registry-plan.md) |

## E2 — Governance & Transport Integrity

### Open

| Code | Title | Status | Description | Plan |
|------|-------|--------|-------------|------|
| _(none)_ | | | | |

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
