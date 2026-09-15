---
type: "sprint"
sprint: 8
name: "Sprint Lifecycle Hardening"
slug: "sprint-lifecycle-hardening"
status: "open"
capacity_points: 10
created: "2026-09-15"
closed: ""
---

# Sprint 8: Sprint Lifecycle Hardening

## Goal
By the end of Sprint 8, an executed plan sitting at `PHASE_9` with Gate D `OPEN` is a **first-class, machine-checkable claim status** (`GATE_D_USER_APPROVAL`) that satisfies a dependant's `depends_on` and unblocks intra-queue chains in `@sprint-run`; the batch host has a **coalesced wrap-up** that confirms, completes and archives a batch in one pass; and "Parcel Fast" exists as **one entity**, reachable only through `parcel-sprint` → `ptp-parcel-fast`.

## Capacity
- Budget: 10 pts (Standard)
- Committed: 9 pts across 3 plans
- Buffer: 1 pt held for spillover / discovery

> **Calibration note:** no prior `sprint.md` exists, so the retro's capacity-accuracy line is the first datapoint. The effective load is higher than 9 pts suggests — T1-E3.03 edits ~14 files plus regenerated agent copies, and each wave carries its own Gate D verdict and wrap-up (see Delivery Model).

## Committed Scope (queue)
| # | Code | Plan | Size | Source tier | Link |
|---|------|------|------|-------------|------|
| 1 | T1-E3.03 | `GATE_D_USER_APPROVAL` claim status + dependency predicate + fixpoint batch runner | M | 🟡 NEXT | [t1-e3.03-gate-d-user-approval-plan.md](t1-e3.03-gate-d-user-approval-plan.md) |
| 2 | T1-E3.04 | Batch sprint wrap-up for `parcel-sprint` | M | 🟢 LATER | [t1-e3.04-sprint-batch-wrap-up-plan.md](t1-e3.04-sprint-batch-wrap-up-plan.md) |
| 3 | T1-E3.05 | Retire the selectable `parcel-fast` orchestrator | M | ⚪ PARKED | [t1-e3.05-retire-parcel-fast-orchestrator-plan.md](t1-e3.05-retire-parcel-fast-orchestrator-plan.md) |

> **Queue order is load-bearing, not cosmetic.** The `#` column is the claim order. See Delivery Model.
>
> **T1-E3.05 triage gap (recorded, not fixed here).** T1-E3.05 was registered in the T1 theme register but never added to the Triage Panel in `backlog-index.md`, so it carried the ⚪ PARKED tier rather than a triaged one. It is committed here by operator instruction. Fixing the panel row is a `backlog-index.md` edit that no plan in this queue owns — routed to the sprint-close backlog sweep instead of being silently patched.

## Explicitly Out of Scope
- **The `parcel-sprint` batch wrap-up execution itself.** T1-E3.04 *specifies* the batch wrap-up; running it is post-Gate-D behaviour and is not exercised by this sprint's own delivery, which wraps each plan individually.
- **Gap 4 (blast-radius test scoping + where the full suite runs).** Named as out of scope by T1-E3.05; it is a separate parcel.
- **Retiring or narrowing per-plan `@agent-wrap-up`.** T1-E3.04 adds a batch *scope*; the per-plan path stays valid and composes.
- **Redesigning the preset mechanism, or introducing a replacement selectable fast orchestrator.** T1-E3.05 removes one; it must not add one.
- **Rewriting historical records** — `.devops/archive/**`, prior `CHANGELOG.md` rows, prior changelog entries.
- **T1-E2.02 (`check-parcel-prefix.ps1` split).** Still parked; it touches the same script as T1-E3.05 but is not committed here.
- **Relaxing the `touches` predicate, queue order, or worktree isolation** to make this sprint batch in one pass.

## Delivery Model (this sprint only)

This sprint **cannot** be delivered as one `@sprint-run` batch pass. The three plans declare mutually overlapping `touches` (all three edit `.devops/agents/**`, `base-context*`, `sync-manifest.yaml`, `version-history.md`, `HOW-TO.md`), and T1-E3.04 declares `depends_on: ["T1-E3.03"]` with a written requirement that E3.03 be **archived** — not merely at `PHASE_9` — before E3.04 may be claimed.

The claim protocol blocks a claim while any plan with an overlapping `touches` set sits in `.devops/plans/`, **including one already batched to `PHASE_9`**. So a single batch would claim T1-E3.03 and skip the other two with recorded reasons.

Delivery is therefore **three serial waves**, queue order:

| Wave | Plan | Steps |
|------|------|-------|
| 1 | T1-E3.03 | preflight preview → claim → spawn `ptp-parcel-fast` → `PHASE_9` → **operator Gate D verdict** → wrap-up/archive |
| 2 | T1-E3.04 | same, once E3.03 has left `.devops/plans/` |
| 3 | T1-E3.05 | same, once E3.04 has left `.devops/plans/` |

**Accepted cost:** three Gate D verdicts instead of the batch path's single consolidated one. The claim protocol's file-safety guarantee is not traded away for convenience — concurrent edits to `base-context.md` / `sync-manifest.yaml` would corrupt the prefix lock and the `machinery-version` bump.

## Definition of Done (sprint-level)
- [ ] All three committed parcel plans reach COMPLETE and are archived
- [ ] `check-parcel-prefix.ps1` exits 0 after the final prefix re-inline (the E3.03 then E3.05 pair both touch the prefix lock)
- [ ] `check-utf8-agents.ps1` exits 0
- [ ] `machinery-version` is strictly increasing across the three wrap-ups with a matching literal in `version-history.md` (CI gate)
- [ ] Wiki lint / claims / coverage all exit 0
- [ ] Sprint closed via `@sprint-close` (retro appended to this file + spaghetti scan run)

## Risks / Unknowns
- **`machinery-version` collision.** All three plans independently bump the version, and the parked plans state their bumps against a stale base: T1-E3.03 and T1-E3.05 *both* claim `43 → 44` (the live value is `43`, so they collide with each other), and T1-E3.04 claims `44 → 45`. Whichever wave runs second must read the **live** value and bump from there, not from the number written in its plan. Same hazard for the per-file `version:` in `pass-the-parcel` and other skills, whose recorded line numbers are already stale.
- **Overlap with T1-E3.03/E3.05 on `.devops/backlog/t1-parcel-pipeline-machinery-backlog.md`.** Neither plan declares it in `touches`; T1-E3.05's D8 does edit it. The register row updates therefore land in whichever wave owns them, and sprint close must reconcile rather than assume.
- **T1-E3.05 deletes a live agent file.** `.devops/agents/parcel-fast.agent.md` currently exists and passes `check-parcel-prefix.ps1`; the registry row, the agent file, and the `opencode.json` entry must be removed **together** or the prefix check fails hard.
- **T1-E3.05 Phase 3 Q&A is unrecorded.** Its five questions are still open (`[ ]`) rather than resolved; under the spawned `AUTO` preset they are auto-resolved at Phase 3.5, which is a weaker evidence bar than the interactive resolution E3.03/E3.04 received.

## Retro
*Appended by `@sprint-close` when the sprint closes. Left empty while the sprint is open.*
