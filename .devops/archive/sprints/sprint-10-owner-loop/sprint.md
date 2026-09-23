---
type: "sprint"
sprint: 10
name: "Owner Loop"
slug: "owner-loop"
status: "closed"
capacity_points: 13
created: "2026-09-23"
closed: "2026-09-23"
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
- [x] All committed parcel plans reach COMPLETE and are archived
- [x] Full test suite green, lint clean, build exit 0
- [x] Sprint closed via @sprint-close (retro appended to this file + spaghetti scan)

## Risks / Unknowns
- **E3.13 was a live hang at GRID-Link** — its fix touches the locked prefix; a `-Sync` re-inline across 9 agents is the blast-radius driver; estimate M on that basis.
- **E3.15/16/12 all touch `sprint-close/SKILL.md`** — the later plans must not land while an earlier one holds a verdict; wave order handles it, but renumbering drift is the historical failure mode (E3.12's satellite v7→v8).
- **T3-E1.02's delivery mechanism (gh PR vs local outbox) is an open Phase 3 question** — could expand if a real issue-transport integration is chosen.
- **Camera-ready business-report + user-testing content depends on having a live sprint's data** — dry-run fidelity is the accepted test only.

---

## Retro

### Goal — Met?
**Yes.** Defect-fixed the batch pipeline's Phase 9 gate, gated the knowledge-drift check, and closed the owner loop end-to-end: story → dev → user test → report. All seven committed items shipped, and this close is the first live exercise of both the acceptance walk (§5) and the business report (§6).

**One honesty caveat.** The walk was **accepted, not exercised** — the operator cannot run this machinery in the current workspace and will report back. **Counts: 8 presented · 0 pass · 0 fail · 0 blocked · 8 accepted untested**; no failures to disposition (§8 records none). The loop's final beat is therefore proven by design and dry run, not by live use: exactly the risk this sprint's own Risks section recorded. A future close in a runnable workspace is the real test.

### What Shipped

| Code | Plan | Size | Effort accuracy | Notes |
|------|------|------|-----------------|-------|
| T1-E3.13 | Phase 9 gate invocation hang | M | **Over-estimated** | The M was driven by an assumed prefix `-Sync` across 9 agents; `base-context.md` needed no prose edit, so the blast radius never materialised. The fix itself was small. |
| T1-E3.14 | Claims-drift check ungated | S | On size | Write set shrank as designed — one home. |
| T1-E3.12 | Sprint-close business report | S | On size | First live exercise at this close. |
| T1-E3.15 | Sprint-close user manual testing | S | On size | First live exercise at this close. |
| T1-E3.16 | Sprint-plan user stories | S | On size | Ran alone in wave 3 once its overlap blockers archived; the pre-built consumer anchor made it a one-clause edit. |
| T1-E3.17 | Product-owner framing | S (flagged MULTI) | On size | The MULTI flag was right — the `-Sync` ×9 did happen. |
| T3-E1.02 | Satellite parcel-feedback pathway | M | On size | The open Phase 3 question (local outbox vs `gh`) resolved to the smaller option; no expansion. |

### Carry-Forward

| Code | Why not done | New size | Next sprint? |
|------|--------------|----------|--------------|
| — | *(none — 7 of 7 delivered)* | — | — |

### Metrics: Before → After

- Hot spots (>CCN 15): **1 → 1** — unchanged; the single flagged file (`scripts/spaghetti-monster-scan.cjs`) was not touched this sprint
- Files >400 lines: **5 → 5** — machinery code unchanged. `agent-changelog.md` (478) and two archived plans (404/420) are a log and historical records, outside the refactoring lane
- Test count: **0 → 0** — no application suite in this template repo; machinery fixture tests unchanged this sprint
- Lint warnings: **0 → 0**
- Capacity: committed **11** / delivered **11** = **100%**

### Retro: Keep / Drop / Try

- **Keep** (worked, do again):
  - **The wrap-up cadence, not the wave forecast, is what unblocks the queue.** Third sprint running: a zero-eligible fixpoint is a normal terminal state, and archiving is what frees the next wave.
  - **The per-plan confirmation gate.** 5/5 assertions on all seven plans, checked from file/git evidence rather than the batch report — it caught nothing, and that is the point.
  - **The interrupted-run contract.** Proved live: a runner died after writing its settings block and resumed cleanly with nothing fabricated.
  - **A pre-built consumer anchor.** E3.15 left the exact sentence E3.16 needed, so the later plan was a one-clause edit with zero renumbering. Deliberate cross-plan hand-offs of this shape pay off.
- **Drop** (hurt, stop):
  - **The wave-forecast table in `sprint.md`.** It predicted a 3-wave delivery; the live predicate produced 2 → 4 → 1. It is wrong every time and reads as authoritative. Stop writing it; the eligibility script's live output is the contract. **Parked for review as `T1-E3.19`** — which also surfaced a larger find: the sprint template has **two homes that already disagree** (`sprint-plan/SKILL.md` embeds one with `## Delivery Model`; `.devops/templates/sprint.template.md` v3 omits it).
- **Try** (next sprint experiment):
  - **Run one close in a workspace that can actually execute the machinery**, so the acceptance walk stops being dry-run-accepted.
  - **Settle the `stories:` row** — enforce it or measure compliance first (`T1-E3.18`).
  - **Clear the two standing 🔴 OPEN refactoring rows** (`spaghetti-monster-scan.cjs`, `wiki_claims.py`) — now two sprints old with no plan.

### Lessons for the Wiki / Knowledge Capture

- **Machinery lesson captured** during the wave-3 wrap-up: *a parcel that adds a contract surface without a check must name the missing gate and park it in the same wrap-up* (`.devops/rules/process-lessons.md`, 2026-09-23) — applied here as `T1-E3.18`.
- **One-line staleness is this sprint's recurring defect class.** `sprint-close` §8's artifact links were bare filenames that resolve to dead paths from the register — repaired at this close (v10 → v11, first fix applied before the close ran). Two more of the same class remain recorded and unfixed: `sync-architecture/SKILL.md:83` (stale §6 → §7 citation) and `wiki-verifier.subagent.md:17` (one gate behind the three-gate hard stop). Worth one small parcel.

### New Refactoring Items (→ REFACTORING.md)

**None.** The close-of-sprint scan across all roots found no file in sprint 10's touched scope crossing a threshold — the touched surface (47 paths) was machinery markdown and prose. The register's *Current Scan Results*, *Kill List* status and *Test Infrastructure Health* were refreshed at this close; the two standing 🔴 OPEN rows are unchanged and were not in scope.

