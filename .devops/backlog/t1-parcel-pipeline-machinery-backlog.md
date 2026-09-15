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
| T1-E1.03 | Registry-canonical model bindings | 2026-09-13 | The `## Model Registry` in `base-context.md` becomes the **single source**; agent frontmatter `model:` and `opencode.json` `agent.<key>.model` are derived and **force-stamped** by sync (no preservation branch). Registry grows 10 → 12 rows (`wiki-writer`, `wiki-verifier`); the pre-v39 VS Code-only opt-out is retired. **Supersedes T1-E1.01.** Follow-up T1-E2.03 adds missing-row insertion so the growth reaches existing satellites. | [plan](../archive/t1-e1.03-model-binding-propagation-plan.md) |

## E2 — Governance & Transport Integrity

### Open

| Code | Title | Status | Description | Plan |
|------|-------|--------|-------------|------|
| T1-E2.02 | Split the `check-parcel-prefix.ps1` god-script | PARKED | Four unrelated concerns in one pass (registry, prefix integrity, skill embeds, binding integrity). Extract the binding checks to `scripts/check-model-bindings.ps1`; wire into `portable_files`, `validate.yml` and `-Verify`. Flagged by T1-E1.03's Phase 6 triage. | [parked](../t1-e2.02-check-parcel-prefix-split-backlog.md) |

### Completed

| Code | Title | Resolved | Note | Archive |
|------|-------|----------|------|---------|
| T1-E2.05 | Chunked Write Discipline | 2026-09-14 | A universal large-file authoring rule: skeleton `write` (frontmatter + section headings, one unique placeholder per section) then one small `edit` per section replacing its placeholder, ~60–100 lines per call — because `write` takes the whole file as one JSON `content` string and stalls the TUI on an oversized payload, and it **overwrites**, so a stall is resumed from `read` rather than by re-sending. Lands as shared-prefix rule 9 (re-inlined into all 10 locked agents, prefix PASS), `AGENTS.md` rule 10, both seeds v11→v12, and the `sprint-plan` §5 step that was the immediate offender. machinery 42. | — (no plan file) |
| T1-E2.03 | Pre-satellite-sync audit tidy-up (F1-F7) | 2026-09-13 | Seven pre-sync audit findings closed (machinery 40): sync **inserts** missing Model Registry rows (v39 growth reaches existing satellites); `parcel-compactor.md` pruned; UTF-8 guard covers `.devops/rules` + `.devops/templates`; T1/MATURITY/CHANGELOG registers backfilled; Gate-A-in-`AUTO` contradiction (CW2) reconciled — `AUTO` clears A-C, only Gate D halts. | [plan](../archive/t1-e2.03-audit-tidy-up-plan.md) |
| T1-E2.04 | Sync transport completeness (F8/F9) | 2026-09-13 | Sync now **inserts** a missing `agent.<key>` entry into a satellite's `opencode.json`, sliced from the target's own synced seed — retiring the `ponytail:` ceiling `T1-E1.03` recorded, while never restructuring an entry the satellite authored (only its `model` value is stamped). `.devops/plans/template-plan.md` joins `portable_files` (named by the shared prefix + five skills but never travelled). `-SelfTest` pins both with a satellite-shaped fixture that reads the reference, not the manifest. machinery 41. | [plan](../archive/t1-e2.04-sync-transport-completeness-plan.md) |
| — | Promote Plan Settings header | 2026-09-12 | `Mode`/`Agents` promoted from the cache-anchored bottom `State & Gates` table to a frozen top-of-file `## ⚙️ Plan Settings` block; bottom now holds only mutable state. | [plan](../archive/promote-plan-settings-header-plan.md) |
| T1-E2.01 | Machinery hardening | 2026-09-11 | Doc-truth sweep, canonical parked-plan location, rules-row reconciliation. | [plan](../archive/t1-e2.01-machinery-hardening-plan.md) |

## E3 — Concurrency & Sprint Lifecycle

### Open

| Code | Title | Status | Description | Plan |
|------|-------|--------|-------------|------|
| T1-E3.03 | `GATE_D_USER_APPROVAL` claim status + dependency predicate + fixpoint batch runner | QUEUED | Codifies the Sprint 7 dependency ruling: a first-class "executed to Gate D" claim status (replacing dead `IN_PROGRESS`) satisfies `depends_on`, and the batch runner iterates to a fixpoint so intra-queue chains execute. Mirrored across the prefix lock + `plan-lifecycle`. | [parked](./t1-e3.03-gate-d-user-approval-backlog.md) |
| T1-E3.04 | Batch sprint wrap-up for `parcel-sprint` | QUEUED | Gives the batch host a coalesced wrap-up: confirm each executed plan, mark complete, archive the batch in one pass via a new batch scope on `@agent-wrap-up`; host may spawn `wiki-writer`. Depends on T1-E3.03. | [parked](./t1-e3.04-sprint-batch-wrap-up-backlog.md) |
| T1-E3.05 | Retire the selectable `parcel-fast` orchestrator | QUEUED | Parcel Fast becomes subagent-only: delete `.devops/agents/parcel-fast.agent.md`, remove its Model Registry + Orchestrator Presets + `opencode.json` entries, re-inline the prefix into the 9 remaining locked agents, and prune the orphan from satellites. | [parked](./t1-e3.05-retire-parcel-fast-orchestrator-backlog.md) |

### Completed

| Code | Title | Resolved | Note | Archive |
|------|-------|----------|------|---------|
| T1-E3.01 | Concurrency & sprint lifecycle rewrite | 2026-09-13 | Worktree-per-plan + claim protocol; `.devops/sprints/sprint-{n}-<slug>/` with a single `sprint.md`; theme registers; shipped plans archive at root. Executed as a direct SINGLE session with the design locked interactively — see `.devops/logs/agent-changelog.md`. | — (no plan file) |
| T1-E3.02 | Sprint batch runner (`@sprint-run` + `parcel-sprint` + `ptp-parcel-fast`) | 2026-09-13 | Unattended batch execution of the committed sprint queue: new selectable host `parcel-sprint` spawning one hidden `ptp-parcel-fast` per plan (locked `AUTO`+`SINGLE`, fresh context), trunk-sequential claim, batched Gate D. Three deviations mirrored into the shared prefix + `plan-lifecycle.md`. | [plan](../archive/t1-e3.02-sprint-batch-runner-plan.md) |
