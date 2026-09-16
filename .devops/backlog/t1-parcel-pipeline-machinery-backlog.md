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
| T1-E2.06 | Portable-surface fold review | QUEUED | The `@sprint-close` § 6 fold review cannot be executed in a satellite: both homes for a folded rule (`.devops/rules/**`, `.devops/skills/**`) are on the portable surface, so a local delete is restored and a local fold reverted by the next pull. Five findings — F1 a satellite's only locally-authored lesson is erased by the next pull (measured: this repo 18 entries, the satellite 15, exactly one satellite-unique); F2 two register entries have matured and should be deleted; F3 one rule is genuinely unfolded (`ptp-high-visionary` Phase 4 directive 3); F4 `@agent-wrap-up` Phase 7b orders satellites to bump `machinery-version`, which the sync then stamps away; F5 pull semantics are a merge by name, undocumented. Routed from GRID-Link's Sprint 8 close, 2026-09-16. | [parked](./t1-e2.06-portable-surface-fold-review-backlog.md) |

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
| T1-E3.09 | Eligibility predicate: script + fixture test + canonicalization | QUEUED | Extract the batch eligibility predicate into `scripts/sprint_eligible.py` + a stdlib fixture test in CI, and make `parcel-sprint` authoritative on its output — killing the four-place prose duplication that produced the G2 class of defect. Wave 3. | [sprint-9](../sprints/sprint-9-batch-hardening/t1-e3.09-eligibility-predicate-script-plan.md) |
| T1-E3.10 | MULTI-worthy triage flag + batch pause/yield | QUEUED | Flag MULTI-worthy plans at `@sprint-run` initiation; the operator accepts the batch risk or defers, and a deferred plan pauses the batch until delivered independently via `@pass-the-parcel` MULTI. Wave 4. | [sprint-9](../sprints/sprint-9-batch-hardening/t1-e3.10-multi-triage-flag-batch-yield-plan.md) |
| T1-E3.11 | Two-lane concurrent batch + version-bump ownership | QUEUED | Add two-lane concurrency (parallel worktree runs for disjoint plans, serial for shared-machinery surfaces) and move the `machinery-version` bump + prefix `-Sync` to the host/wrap-up so machinery plans stop colliding on shared counters. Wave 5. | [sprint-9](../sprints/sprint-9-batch-hardening/t1-e3.11-two-lane-concurrent-batch-plan.md) |

### Completed

| Code | Title | Resolved | Note | Archive |
|------|-------|----------|------|---------|
| T1-E3.01 | Concurrency & sprint lifecycle rewrite | 2026-09-13 | Worktree-per-plan + claim protocol; `.devops/sprints/sprint-{n}-<slug>/` with a single `sprint.md`; theme registers; shipped plans archive at root. Executed as a direct SINGLE session with the design locked interactively — see `.devops/logs/agent-changelog.md`. | — (no plan file) |
| T1-E3.02 | Sprint batch runner (`@sprint-run` + `parcel-sprint` + `ptp-parcel-fast`) | 2026-09-13 | Unattended batch execution of the committed sprint queue: new selectable host `parcel-sprint` spawning one hidden `ptp-parcel-fast` per plan (locked `AUTO`+`SINGLE`, fresh context), trunk-sequential claim, batched Gate D. Three deviations mirrored into the shared prefix + `plan-lifecycle.md`. | [plan](../archive/t1-e3.02-sprint-batch-runner-plan.md) |
| T1-E3.03 | `GATE_D_USER_APPROVAL` claim status + dependency predicate + fixpoint batch runner | 2026-09-16 | Makes "executed to Gate D, verdict pending" first-class: `GATE_D_USER_APPROVAL` joins the claim-status enum (dead `IN_PROGRESS` retired), `depends_on` is satisfied by archive **or** by a plan in `.devops/plans/` carrying that status, and `@sprint-run` iterates to a fixpoint with a dependency-cycle preflight. Mirrored across the prefix lock + `plan-lifecycle`. The plan introduced the state and terminated in it, and the live queue then proved the clause separation: `T1-E3.04`'s dependency flipped to satisfied while its `touches` overlap still skipped. Wave 2 of Sprint 8. | [plan](../archive/t1-e3.03-gate-d-user-approval-plan.md) |
| T1-E3.04 | Batch sprint wrap-up for `parcel-sprint` | 2026-09-16 | Gives the batch host a coalesced wrap-up: a **batch scope** on `@agent-wrap-up` (input list; every phase once except Phase 4, which iterates), a five-assertion per-plan confirmation gate that makes a failing plan **carry-forward** rather than complete, repo gates run once per batch, and retirement named as `@sprint-run`'s fourth deviation. `parcel-sprint` may spawn exactly one additional target, `wiki-writer` (no glob). Wave 3 of Sprint 8 — and the first live exercise of the scope it defines. | [plan](../archive/t1-e3.04-sprint-batch-wrap-up-plan.md) |
| T1-E3.05 | Retire the selectable `parcel-fast` orchestrator | 2026-09-16 | Parcel Fast becomes subagent-only: deleted `.devops/agents/parcel-fast.agent.md`, removed its Model Registry + Orchestrator Presets + `opencode.json`/seed entries **together** (the prefix check validates registry↔file↔config bidirectionally, so a partial removal is a hard FAIL), re-inlined the prefix into the 9 remaining locked agents (10→9), and added a load-bearing `prune_files` entry so an already-synced satellite deletes the orphan instead of failing its own prefix check. `machinery-version 43→44`. Wave 1 of Sprint 8. | [plan](../archive/t1-e3.05-retire-parcel-fast-orchestrator-plan.md) |
| T1-E3.06 | Sprint 8 gate & preflight coverage gaps | 2026-09-16 | Closes the three coverage gaps Sprint 8's own execution surfaced. **G1:** `.devops/sprints` joins `check-utf8-agents.ps1`'s scan (222 → 228 files). **G2:** one canonical *Write-Set Overlap Predicate* in `plan-lifecycle.md` § Claim Protocol, cited by `sprint-run` § 2 and `sprint-plan` § 4b so no second dialect exists, plus a mandatory commit-time N-wave preflight in `@sprint-plan` and the matured `touches-overlap` lesson folded and deleted. **G3:** the scanner no-ops on a missing root instead of crashing, now scans the machinery roots, and the refactoring register is **adopted** as `.devops/backlog/REFACTORING.md`. `machinery-version 47→48`. Wave 1 of Sprint 9. | [plan](../archive/t1-e3.06-sprint-8-gate-preflight-gaps-plan.md) |
| T1-E3.07 | Positive-evidence auto-clear for AUTO gates | 2026-09-16 | AUTO gates now clear only on a **positive-evidence contract**, stated once in `plan-lifecycle.md` § *AUTO Gate Evidence Contract* and **cited** by `pass-the-parcel`, `ptp-parcel-fast` and `sprint-run` — the negative "no `REJECTED` line" test that let an empty or vague self-review pass by omission is gone, and an unproven gate is a stop-the-line. The shared prefix + seed now point at the contract instead of paraphrasing it (re-inlined byte-for-byte across 11 surfaces); `template-plan.md` gains the Phase 6/9 evidence shapes a plan must carry. Three self-identified design flaws were fixed pre-verdict rather than papered over. `machinery-version 48→49`. Wave 2 of Sprint 9. | [plan](../archive/t1-e3.07-positive-evidence-auto-clear-plan.md) |
| T1-E3.08 | Batched clarification questionnaire | 2026-09-16 | Phase 3's "one question at a time (non-negotiable)" becomes a **mode**: the whole decision surface is relayed in one batched questionnaire where the ask tool accepts a question **array**, and one call per question where it accepts a single question — the tool's own **signature** is the capability test, so no probe and no hard-coded surface list, and the design degrades to today's sequential UX by construction. The final "Is this all the context required?" confirm is always asked **on its own**; the 5-8 budget is unchanged; the `AUTO`/batch path still asks nothing (the runner never calls an ask tool). The rule lived in **seven** live places — a partial flip would have been indistinguishable from drift. `machinery-version 50→51`. Wave 3 of Sprint 9. | [plan](../archive/t1-e3.08-batched-clarification-questionnaire-plan.md) |
