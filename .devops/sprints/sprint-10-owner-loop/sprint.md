---
type: "sprint"
sprint: 10
name: "Owner Loop"
slug: "owner-loop"
status: "open"
capacity_points: 13
created: "2026-09-23"
closed: ""
---

# Sprint 10: Owner Loop

## Goal
Defect-fix the batch pipeline's Phase 9 gate (one-shot test invocation, named resume state), gate the grounded-claims drift check, then close the owner loop end-to-end: a satellite-to-template parcel-feedback pathway, sprint-plan user stories, a sprint-close user-manual-testing step carried out question-by-question with the owner, the business report landing template-side, and a canonical product-owner framing — the user is the product owner, the agents are the dev team.

## Capacity
- Budget: 13 pts (Large)
- Committed: 11 pts across 7 plans
- Buffer: 2 pts held for spillover / discovery

## Committed Scope (queue)
| # | Code | Plan | Size | Source tier | Link |
|---|------|------|------|-------------|------|
| 1 | T1-E3.13 | Phase 9 gate invocation can hang the batch runner | M | 🟡 NEXT | [plan](./t1-e3.13-phase9-gate-invocation-hang-plan.md) |
| 2 | T1-E3.14 | `wiki_claims.py check` is gated nowhere | S | 🟡 NEXT | [plan](./t1-e3.14-wiki-claims-check-ungated-plan.md) |
| 3 | T3-E1.02 | Satellite parcel-feedback pathway | M | new — operator | [plan](./t3-e1.02-parcel-feedback-pathway-plan.md) |
| 4 | T1-E3.16 | Sprint-plan user stories | S | new — operator | [plan](./t1-e3.16-sprint-plan-user-stories-plan.md) |
| 5 | T1-E3.15 | Sprint-close user manual testing | S | new — operator | [plan](./t1-e3.15-sprint-close-user-testing-plan.md) |
| 6 | T1-E3.12 | Sprint-close business report (template-side) | S | 🟢 LATER | [plan](./t1-e3.12-sprint-close-business-report-plan.md) |
| 7 | T1-E3.17 | Product-owner framing | S | new — operator | [plan](./t1-e3.17-product-owner-framing-plan.md) |

## Delivery Model
Predicted by the § 4b wave preflight (canonical Write-Set Overlap Predicate, `.devops/rules/plan-lifecycle.md` § Claim Protocol):

| Wave | Plan | Size | Flag | Notes |
|------|------|------|------|-------|
| 1 | T1-E3.13 | M | MULTI (contract change: locked prefix; blast radius: 6 files) | serial lane |
| 1 | T3-E1.02 | M | — | disjoint from wave 1 |
| 1 | T1-E3.15 | S | — | disjoint from wave 1 |
| 2 | T1-E3.14 | S | — | overlaps `template-plan.md` (E3.13) |
| 2 | T1-E3.12 | S | — | overlaps `sprint-close/SKILL.md` (E3.15) |
| 2 | T1-E3.17 | S | MULTI (contract change: shared prefix; blast radius: 5 files) | overlaps `base-context.md` (E3.13) — serial lane |
| 3 | T1-E3.16 | S | — | overlaps `template-plan.md` + `sprint-close/SKILL.md` (both wave-2 deps) |

> **`Flag`** is the § 4c triage recommendation. A `MULTI` row in a `@sprint-run` batch is surfaced as an **accept batch risk / defer to manual** fork before the first claim — the batch's locked `AUTO` + `SINGLE` preset cannot honour the recommendation.

**Accepted cost:** 3 serial waves = 3 Gate D verdicts and 3 wrap-ups — not one consolidated verdict; committed plans hold their files from claim until wrap-up archives them.

Operator ruling on E3.13's test efficiency: the invocation fix targets *one-shot, non-interactive* gates (`--run` / `CI=true`) — safe without padding runtime with redundant over-verification.

## Explicitly Out of Scope
- **T1-E1.05** (opencode config defects, ⚪ parked) — cosmetic today, stays parked.
- **Refactoring lane / REFACTORING.md kill list** — not a feature sprint; refactoring rides only via sprint-close's scan.
- **t1-e3.13 F3 "HALT outcome" shape vs making the state impossible** — resolved *inside* that parcel's Phase 3, not as separate sprint work.
- **Real two-lane concurrent execution** (the unfinished half of T1-E3.11) — needs batch deviation 5; not this sprint.
- **Any wiki content authoring beyond what the seven plans name** — wiki work follows the parcels, not the reverse.

## Definition of Done (sprint-level)
- [ ] All committed parcel plans reach COMPLETE and are archived
- [ ] Full test suite green, lint clean, build exit 0
- [ ] Sprint closed via @sprint-close (retro appended to this file + spaghetti scan)

## Risks / Unknowns
- **E3.13 was a live hang at GRID-Link** — its fix touches the locked prefix; a `-Sync` re-inline across 9 agents is the blast-radius driver; estimate M on that basis.
- **E3.15/16/12 all touch `sprint-close/SKILL.md`** — the later plans must not land while an earlier one holds a verdict; wave order handles it, but renumbering drift is the historical failure mode (E3.12's satellite v7→v8).
- **T3-E1.02's delivery mechanism (gh PR vs local outbox) is an open Phase 3 question** — could expand if a real issue-transport integration is chosen.
- **Camera-ready business-report + user-testing content depends on having a live sprint's data** — dry-run fidelity is the accepted test only.
