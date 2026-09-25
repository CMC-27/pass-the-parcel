---
type: "sprint"
sprint: 11
name: "Machinery Streamline"
slug: "machinery-streamline"
status: "closed"
capacity_points: 30
created: "2026-09-24"
closed: "2026-09-25"
---

# Sprint 11: Machinery Streamline

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
- **Kill List refactoring slice** — opt-in declined at planning; the `@sprint-close` scan still runs as normal and feeds REFACTORING.md
- **The GRID-Link pull + counter-rewind decision** — operator action, deliberately after T1-E2.08 lands; re-measure the counter first (the satellite was mid-parcel at audit time)
- **Satellite-side debris** (`.ptp-source`, `knowledge-changelog.md`, root `DESIGN.md` consolidation) — GRID-Link owner's call, not template work
- **MATURITY.md re-grade** — the field-audit report is the artefact the next Axis 3 / Axis 5 row cites; reassessment is its own trigger
- **Changing the batch preset itself** — T1-E3.20 adds the overrule *check* only; the locked preset stays locked
- **Any finding beyond the committed eight** — new work goes through `@backlog`, never mid-sprint scope

## Definition of Done (sprint-level)
- [x] All committed parcel plans reach COMPLETE and are archived
- [x] Full test suite green, lint clean, build exit 0
- [x] Sprint closed via @sprint-close (retro appended to this file + spaghetti scan run)

## Risks / Unknowns
- **T1-E2.08 is the riskiest** — the two-release parser migration plus the ordering-aware verdict change in the sync engine; a wrong comparator breaks satellite pulls, so `-SelfTest` must grow a target-ahead fixture in the same parcel
- **T1-E5.01 may prove XL at Phase 3** (4 open questions: micro-template vs markers, scripted vs asserted eligibility, Gate B evidence shape, ad-hoc-set calibration) — if so it carries forward at the retro; it does not expand mid-sprint
- **T3-E1.04's profile mechanism is design-open** (profile-aware `-Check` semantics + SelfTest fixture + which surface owns membership)
- **Waves are a prediction of the fixpoint** — the live predicate at run time is the contract; a zero-eligible pass between waves is normal, not a stall
- **First-ever `stories:` rows** — no archived plan carries one (Sprint 10 predated the feature), so these eight are the format's live debut; T1-E3.18, committed here, is the gate that will police them
- **Queue order vs wave order** — wave 1's T1-E3.18 overlaps wave 2's T1-E5.01 on `template-plan.md`, so it must fully archive before wave 2 begins; the runner resolves this, but a manual run must not claim past it

---

## Retro

### Goal — Met?
*"Deliver the entire GRID-Link field-audit set in one three-wave sprint: honest tiered versioning with ordering-aware transport, a sanctioned MICRO path for small changes with the plan as the single record, and every guardrail the template advertises (CI gates, stories trace, preset acceptance, CORE profile, honest wave data) actually travelling to satellites."*

**Yes.** All six named deliverables landed: tiered versioning + ordering-aware transport (`T1-E2.08`), the MICRO path (`T1-E5.01`), the CI gates travelling (`T3-E1.03`), the stories trace gated (`T1-E3.18`), preset acceptance named (`T1-E3.20`), the CORE profile (`T3-E1.04`) — plus the wave-forecast honesty fix (`T1-E3.19`) and the changelog-as-index (`T1-E5.02`). **8/8 plans, 30/30 pts.**

### What Shipped
| Code | Plan | Size | Effort accuracy | Notes |
|------|------|------|-----------------|-------|
| `T1-E2.08` | Tiered machinery versioning + ordering-aware transport | L (5) | L as estimated | Released as **release A** by design (value stays an integer); release B is a named follow-up. Wave 1 |
| `T1-E3.18` | The `stories:` trace has no gate behind it | M (3) | M as estimated | Ruled **presence-only** at the commit boundary — no script, no CI job. Wave 1 |
| `T1-E3.19` | The wave-forecast table drifts from the live predicate | M (3) | M as estimated | Hand-derived forecast deleted; template's two homes reconciled to one. Wave 2 |
| `T1-E3.20` | The batch preset overrules a sprint's recorded Mode rulings | M (3) | M as estimated | Advisory `mode_conflicts` key joins the single batch fork. Wave 2 |
| `T1-E5.02` | The changelog becomes a generated index | M (3) | M as estimated | Prospective only — 0 historical lines rewritten. Wave 2 |
| `T3-E1.03` | The deterministic CI gates stop at the template border | M (3) | M as estimated | One new portable workflow; invariant/template-identity split stated once. Wave 2 |
| `T1-E5.01` | MICRO topology — the sanctioned small-change pathway | L (5) | **L — the flagged XL risk did not materialise** | Prefix cascade fired (`-Sync` ×9, exit 0). Wave 3 |
| `T3-E1.04` | CORE satellite profile — measured onboarding reduction | L (5) | L as estimated | Membership as data (`core_skills:`, 18 measured skills); `FULL` unchanged. Wave 3 |

### Carry-Forward
**None — all 8 committed plans delivered and archived.** Recorded follow-ups (not committed work; each has a durable home):
| Item | Why not done | New size | Next sprint? |
|------|--------------|----------|--------------|
| `T1-E2.08` **release B** — flip the counter to `1.0.73` | Deliberately staged: a satellite's *old* `(\d+)` stamp would corrupt a dotted value mid-pull | S (1) | Y |
| `T1-E2.08` **CW1** — `@test-and-deploy`'s `v0.7.x` label writer | Outside that plan's `touches`; reconcile now that release A landed | S (1) | Y |
| `T1-E2.09` **satellite counter-bump drift** (parked, `f0c0241`) | New intake filed mid-sprint by the operator; `depends_on: [T1-E2.08]` now satisfied | M (3) | Y |
| `T1-E5.01` — the `triage` vocabulary's five-mirror fan-out | Route, do not fix (the plan's own Phase 6 ruling) | S (1) | N — fold opportunistically |
| `T3-E1.04` — `sync-architecture/SKILL.md` § verdict table + `.devops/README.md` § derivation pre-date the tier | Outside `touches` | S (1) | N — fold opportunistically |

### Metrics: Before → After
- Hot spots (>CCN 15): **1 → 1** (the scanner itself; `CCN(h)` is a regex heuristic and ECMAScript-only, so it reads as a pointer, not a measurement)
- Files >400 lines: **5 → 5** (composition shifted: `sync-architecture.ps1` **572 → 757**, `sprint_eligible.py` **463 → 549**, `test_sprint_eligible.py` **410 → 473**; `wiki_claims.py` 484 and `wiki_lint_checks.py` 423 unchanged)
- Test count: **0 → 0** application tests (no `package.json` by design); **machinery fixtures 62 → 67** (`test_sprint_eligible` 29 → 34)
- Lint warnings: **0 → 0**
- Capacity: committed **30** / delivered **30** = **100%**

### Retro: Keep / Drop / Try
- **Keep** — the **3-wave batch cadence**: a plan holds its files from claim until its wrap-up archives it, so the wrap-up *is* the scheduler. Four Gate D verdicts and four wrap-ups is the honest price of an overlap-heavy self-referential queue, and every wave unblocked the next without a reorder. Also keep: the **one batch-model question per wave** (`CLI default` all three times) and **`-Sync` at the claim boundary** as the host's standing invariant.
- **Drop** — **presenting a hand-derived wave forecast as fact** (now deleted by `T1-E3.19`; the live predicate JSON is the contract), and **`git add -A` at claim time**: a foreign write landing mid-run nearly got swept into a claim commit this sprint. Claims and wrap-ups should stage **explicit paths**.
- **Try** — a **`sync-architecture.ps1` split plan** (it is the top OPEN flag and now only 43 lines from the >800 critical), and a **process-lessons fold pass** to bring the staging register back under its ~25-entry target.

### Lessons for the Wiki / Knowledge Capture
Three machinery lessons were captured this sprint (all in `.devops/rules/process-lessons.md`):
1. **A shape-changing transport migration must ship the reader one release before the value** — the code that runs during a pull is the *target's own old* code.
2. **A template's CI gates travel as a self-contained workflow file** — never `workflow_call`, a composite action, or "documented wiring".
3. **PS 5.1 makes a native command's stderr uncatchable under `Stop`** — a `try/catch` negative fixture gives a **false pass**; assert via `Start-Process -RedirectStandardError`.
Plus the sprint's biggest finding, parked as `T1-E2.09`: **the portable surface is the instruction surface** — a carve-out written only on non-portable files never reaches a satellite that follows the rule it was sent.

### User Acceptance Walk
**8 tests · 8 passed · 0 failed · 0 blocked.** The walk was **self-validated by the agent at the operator's direction** — not hand-walked by the operator, and recorded as such in [`user-testing.md`](./user-testing.md). Because nothing failed or was blocked, **no theme-register rows are owed**; that is stated here rather than left silent. One honest scope note: the transport and CI outcomes were exercised against fixtures and throwaway trees, not a live satellite pull.

### New Refactoring Items (→ REFACTORING.md)
One **new Kill List row**, promoted: **`scripts/sync-architecture.ps1` — 757 lines, 🔴 OPEN** (was ⚪ WATCH at 561; +196 from `T1-E2.08` and `T3-E1.04`, now 43 lines below the >800 critical). Two already-flagged rows refreshed with new counts (`sprint_eligible.py` 549, `test_sprint_eligible.py` 473). No file was decomposed this sprint, so the Completed Refactors table gains no row. Scan block and `last_scan` updated; see [REFACTORING.md](../backlog/REFACTORING.md) § Current Scan Results.
