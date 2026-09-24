---
type: "sprint"
sprint: 11
name: "Machinery Streamline"
slug: "machinery-streamline"
status: "open"
capacity_points: 30
created: "2026-09-24"
closed: ""
---

# Sprint 11: Machinery Streamline

## Goal
## Goal
Deliver the entire GRID-Link field-audit set in one three-wave sprint: honest tiered versioning with ordering-aware transport, a sanctioned MICRO path for small changes with the plan as the single record, and every guardrail the template advertises (CI gates, stories trace, preset acceptance, CORE profile, honest wave data) actually travelling to satellites.

## Capacity
- Budget: 30 pts (XL — expanded from the ~13-19 Large default at operator ruling 2026-09-24, after the scope selection totalled 30)
- Committed: 30 pts across 8 plans
- Buffer: 0 pts held — deliberately none; the carry-forward rule (an oversized plan carries forward rather than blowing up the sprint) is the valve

## Committed Scope (queue)
| # | Code | Plan | Size | Source tier | Link |
|---|------|------|------|-------------|------|
| 1 | T1-E2.08 | Tiered machinery versioning + ordering-aware transport | L (5) | 🟡 NEXT | [t1-e2.08-tiered-machinery-versioning-plan.md](t1-e2.08-tiered-machinery-versioning-plan.md) |
| 2 | T1-E3.18 | The `stories:` trace has no gate behind it | M (3) | 🟢 LATER (approved gate) | [t1-e3.18-stories-trace-ungated-plan.md](t1-e3.18-stories-trace-ungated-plan.md) |
| 3 | T1-E5.01 | MICRO topology — the sanctioned small-change pathway | L (5) | 🟡 NEXT | [t1-e5.01-micro-topology-plan.md](t1-e5.01-micro-topology-plan.md) |
| 4 | T3-E1.03 | The deterministic CI gates stop at the template border | M (3) | 🟡 NEXT | [t3-e1.03-ci-gate-transportability-plan.md](t3-e1.03-ci-gate-transportability-plan.md) |
| 5 | T1-E5.02 | The changelog becomes a generated index | M (3) | 🟢 LATER | [t1-e5.02-changelog-generated-index-plan.md](t1-e5.02-changelog-generated-index-plan.md) |
| 6 | T1-E3.19 | The wave-forecast table drifts from the live predicate | M (3) | 🟢 LATER (carry-over) | [t1-e3.19-wave-forecast-drift-plan.md](t1-e3.19-wave-forecast-drift-plan.md) |
| 7 | T1-E3.20 | The batch preset overrules a sprint's recorded Mode rulings | M (3) | 🟢 LATER (approved gate) | [t1-e3.20-batch-preset-overrule-check-plan.md](t1-e3.20-batch-preset-overrule-check-plan.md) |
| 8 | T3-E1.04 | CORE satellite profile — measured onboarding reduction | L (5) | 🟢 LATER | [t3-e1.04-core-satellite-profile-plan.md](t3-e1.04-core-satellite-profile-plan.md) |

> Queue order is the first claim order, not an execution dependency: blockers lead (T1-E2.08 opens waves 2-3), and `@sprint-run` re-evaluates eligibility immediately before each claim against the canonical predicate in `.devops/rules/plan-lifecycle.md` § Claim Protocol.

## Delivery Model
## Delivery Model

Wave decomposition predicted by the § 4b preflight — a prediction of the canonical Write-Set Overlap Predicate's fixpoint, never a replacement; `@sprint-run` re-evaluates the predicate live before each claim.

| Wave | Plan | Size | Flag (signals that fired) | Steps |
|------|------|------|------|-------|
| 1 | T1-E2.08 | L (5) | `MULTI` — blast radius (9 files) + contract change (manifest format) | claim → parcel run → `PHASE_9` → verdict + wrap-up |
| 1 | T1-E3.18 | M (3) | `—` (all five signals low: ≤3 files, additive gate, reversible) | claim → parcel run → `PHASE_9` → verdict + wrap-up |
| 2 | T1-E5.01 | L (5) | `MULTI` — blast radius (prefix cascade) + contract change (topology) + novelty (new topology) | claim → parcel run → `PHASE_9` → verdict + wrap-up |
| 2 | T3-E1.03 | M (3) | `MULTI` — blast radius (4 files, two domains; mechanical backstop fires) | claim → parcel run → `PHASE_9` → verdict + wrap-up |
| 2 | T1-E5.02 | M (3) | `—` (≤3 files, local format change) | claim → parcel run → `PHASE_9` → verdict + wrap-up |
| 3 | T1-E3.19 | M (3) | `—` (2 files, local edit) | claim → parcel run → `PHASE_9` → verdict + wrap-up |
| 3 | T1-E3.20 | M (3) | `—` (≤3 files, advisory key addition) | claim → parcel run → `PHASE_9` → verdict + wrap-up |
| 3 | T3-E1.04 | L (5) | `MULTI` — contract change (new manifest key) + backstop (5 touches) | claim → parcel run → `PHASE_9` → verdict + wrap-up |

> **`Flag`** is the § 4c triage recommendation for that plan (`MULTI` / `—`), with the signals that fired named in the row. A `MULTI` row in a `@sprint-run` batch is surfaced as an **accept batch risk / defer to manual** fork before the first claim (`@sprint-run` § 1) — the batch's locked `AUTO` + `SINGLE` preset cannot honour the recommendation. Four rows carry it: T1-E2.08, T1-E5.01, T3-E1.03, T3-E1.04.

**Accepted cost:** 3 serial waves = **3 Gate D verdicts and 3 wrap-ups** — not one consolidated verdict; a committed plan holds its files from claim until its wrap-up archives it, so wave 2 stays blocked until wave 1 archives (and wave 3 until wave 2). A zero-eligible pass between waves is a normal terminal state, not a stall — the wrap-up cadence unblocks the next wave.

## Explicitly Out of Scope
## Explicitly Out of Scope
- **Kill List refactoring slice** — opt-in declined at planning; the `@sprint-close` scan still runs as normal and feeds REFACTORING.md
- **The GRID-Link pull + counter-rewind decision** — operator action, deliberately after T1-E2.08 lands; re-measure the counter first (the satellite was mid-parcel at audit time)
- **Satellite-side debris** (`.ptp-source`, `knowledge-changelog.md`, root `DESIGN.md` consolidation) — GRID-Link owner's call, not template work
- **MATURITY.md re-grade** — the field-audit report is the artefact the next Axis 3 / Axis 5 row cites; reassessment is its own trigger
- **Changing the batch preset itself** — T1-E3.20 adds the overrule *check* only; the locked preset stays locked
- **Any finding beyond the committed eight** — new work goes through `@backlog`, never mid-sprint scope

## Definition of Done (sprint-level)
- [ ] All committed parcel plans reach COMPLETE and are archived
- [ ] Full test suite green, lint clean, build exit 0
- [ ] Sprint closed via @sprint-close (retro appended to this file + spaghetti scan run)

## Risks / Unknowns
- **T1-E2.08 is the riskiest** — the two-release parser migration plus the ordering-aware verdict change in the sync engine; a wrong comparator breaks satellite pulls, so `-SelfTest` must grow a target-ahead fixture in the same parcel
- **T1-E5.01 may prove XL at Phase 3** (4 open questions: micro-template vs markers, scripted vs asserted eligibility, Gate B evidence shape, ad-hoc-set calibration) — if so it carries forward at the retro; it does not expand mid-sprint
- **T3-E1.04's profile mechanism is design-open** (profile-aware `-Check` semantics + SelfTest fixture + which surface owns membership)
- **Waves are a prediction of the fixpoint** — the live predicate at run time is the contract; a zero-eligible pass between waves is normal, not a stall
- **First-ever `stories:` rows** — no archived plan carries one (Sprint 10 predated the feature), so these eight are the format's live debut; T1-E3.18, committed here, is the gate that will police them
- **Queue order vs wave order** — wave 1's T1-E3.18 overlaps wave 2's T1-E5.01 on `template-plan.md`, so it must fully archive before wave 2 begins; the runner resolves this, but a manual run must not claim past it
