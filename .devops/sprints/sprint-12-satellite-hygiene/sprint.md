---
type: "sprint"
sprint: 12
name: "Satellite Hygiene"
slug: "satellite-hygiene"
status: "open"
capacity_points: 8
created: "2026-09-26"
closed: ""
---

# Sprint 12: Satellite Hygiene

## Goal
Every portable surface a satellite obeys says the same true thing about the machinery counter — the bump instruction cites the template-ownership carve-out instead of contradicting it — Phase 5 and Phase 9 gain targeted-suite declaration with the full suite consolidated per batch/push/sprint (expanded 2026-09-26 from Shape A only, on the operator's field report), and the OpenCode V2 config declares only what V2 actually loads.

## Capacity
- Budget: 8 pts (extended from the ~5 Small default at operator ruling 2026-09-26, to open room for the third parked plan)
- Committed: 5 pts across 3 plans
- Buffer: 3 pts held for spillover / discovery

## Committed Scope (queue)
| # | Code | Plan | Size | Source tier | Link |
|---|------|------|------|-------------|------|
| 1 | T1-E2.09 | Satellites are told to bump a counter they do not own | M (3) | 🟡 NEXT | [t1-e2.09-machinery-counter-satellite-plan.md](t1-e2.09-machinery-counter-satellite-plan.md) |
| 2 | T1-E3.21 | Phase 9 test execution has no batching pattern | S (1) | 🟢 LATER (operator promotion ruling 2026-09-26, Shape A only; **same-day expansion ruling** — field report + Phase 3 Q&A recorded, write set 3→8) | [t1-e3.21-phase9-test-batching-plan.md](t1-e3.21-phase9-test-batching-plan.md) |
| 3 | T1-E1.05 | OpenCode V2 config drift in `opencode.json` | S (1) | 🟢 LATER (operator promotion ruling 2026-09-26) | [t1-e1.05-opencode-v2-config-plan.md](t1-e1.05-opencode-v2-config-plan.md) |

> Queue order is the first claim order, not an execution dependency: `T1-E2.09`'s dependency (`T1-E2.08`) is satisfied in `.devops/archive/`, and the predicate holds `T1-E2.09` out of the first claim order on `touches` overlap alone (via `HOW-TO.md` against T1-E1.05 and `.devops/rules/plan-lifecycle.md` against T1-E3.21) until its overlaps archive. The lanes are advisory classifications — every path runs in place serially.

> **Re-scope 2026-09-26 (external claim in flight):** `T1-E3.21` is being claimed into `.devops/plans/` by a **separate session** — it is the operator-rescope constraint this row records; nothing else about its scope or sizing changed. Consequences, in claim order: **T1-E1.05 is the next claim this side** (it shares no `touches` with the Shape-A write set, so it may run alongside the external parcel); **T1-E2.09 stays blocked by the predicate** — twice over, once the external claim lands — until T1-E1.05's wrap-up archives it (the `HOW-TO.md` overlap) and T1-E3.21's wrap-up archives it (the `version-history.md` overlap). The snapshot below was recorded **before** the external claim; the live predicate at each claim boundary is the contract. Re-snapshot the queue once the external claim lands.

## Delivery Model

The § 4c triage flags for the committed set, plus the eligibility predicate's own recorded output. **Never a hand-derived wave count.**

| Code | Size | Flag | Signals that fired |
|------|------|------|--------------------|
| T1-E2.09 | M (3) | `MULTI` | blast radius (10 files across rules, skills, a script and the manifest) + contract change (the sync-protocol bump instruction every satellite obeys) |
| T1-E3.21 | S (1) | `MULTI` | blast radius (8 files: the canon rule, both execution-surface skills, the plan template, three orchestration skills) — fired at the 2026-09-26 expansion ruling; size holds S (wording only, no code) |
| T1-E1.05 | S (1) | `MULTI` | blast radius (the onboarding seed `opencode.template.json` ships to every satellite via sync; mechanical backstop also fires on 4 touches) |

> **`Flag`** is the § 4c triage recommendation for that plan (`MULTI` / `—`), with the signals that fired named in the row. A `MULTI` row in a `@sprint-run` batch is surfaced as an **accept batch risk / defer to manual** fork before the first claim (`@sprint-run` § 1) — the batch's locked `AUTO` + `SINGLE` preset cannot honour the recommendation. Three rows carry it: T1-E2.09, T1-E3.21 (the 2026-09-26 expansion) and T1-E1.05.

**Predicate snapshot** — recorded at commit time, once the committed plans are in this folder and before the sprint is registered in `SPRINTS.md`; **re-run 2026-09-26 at the T1-E3.21 expansion ruling**:

`python scripts/sprint_eligible.py --sprint-dir .devops/sprints/sprint-12-satellite-hygiene`

- `claim_order`: ["T1-E1.05", "T1-E3.21"]
- `skipped`: [{"code": "T1-E2.09", "reasons": ["touches overlap: T1-E1.05 via how-to.md", "touches overlap: T1-E3.21 via .devops/rules/plan-lifecycle.md"]}]
- `multi_worthy`: 3/3 (T1-E3.21 added at the expansion — blast-radius backstop, >3 declared `touches`)

> **Forecast, never a schedule:** the snapshot is exact at the moment it is taken and stale the moment the first claim lands. `@sprint-run` § 2 re-evaluates the predicate against the live `.devops/plans/` immediately before **each** claim, so the executed set may differ. A non-zero exit from the command above is a **stop** — fix the plan file it names; never re-derive the predicate by hand.

**Accepted cost:** one Gate D verdict and one wrap-up per wave — not one consolidated verdict; a committed plan holds its files from claim until its wrap-up archives it, and the number of waves is whatever the live predicate produces. The wrap-ups bump `machinery-version` per the manual per-plan path — one increment per wrap-up, read from the live value at that moment (three increments across this sprint, never consolidated into one).

## Explicitly Out of Scope
- **T1-E3.21 Shape B's scriptable half** — the batch-host targeted-suite hint + the AUTO evidence-contract amendment: ruled out at intake (2026-09-26); the reopen clause fired same day on the operator's field report (heavy loads and delays, suite **and** build/compile), recorded in the plan file. The expansion took the **declaration/execution/record chain** (8 surfaces) — B's scriptable machinery stays out until a batch-path report demands it
- **Release B** (the dotted flip to `1.0.73`, the named T1-E2.08 follow-up with no parked plan) — not folded into T1-E2.09; a major's pull-milestone ceremony (release row + `CHANGELOG.md` entry + tag) is a release decision, not a text-parcel rider
- **The Kill List refactoring slice** — opt-in declined at planning; the `@sprint-close` scan still runs as normal and feeds REFACTORING.md
- **T1-E1.05's broad migration-guide prose sweep** — the write set is bounded to the config flip plus the prose the flip actually invalidates (`HOW-TO.md` § Binding note, `SATELLITE-BOOTSTRAP.md` § 2); anything wider returns to the plan's Phase-3 open question
- **MATURITY.md re-grade** — this sprint's completions are rows the next grade cites, not a trigger

## Definition of Done (sprint-level)
- [ ] All committed parcel plans reach COMPLETE and are archived
- [ ] Full test suite green, lint clean, build exit 0
- [ ] Sprint closed via @sprint-close (retro appended to this file + spaghetti scan run)

## Risks / Unknowns
- **T1-E2.09 is self-referential** — it rewrites the bump instruction (`agents-and-skills.md`, `@agent-wrap-up`, `SPRINTS.template.md`) that its own wrap-up will obey; run it `MULTI` with per-phase review, and land the ownership carve-out before any later phase touches the release row
- **Stale counter anchors** — the plan was drafted against counter `73`; the live value at commit is `76` and every wrap-up reads live, so no plan phase may pin a number it does not read
- **T1-E3.21's expanded `touches`** — trimmed to three at commit per the Shape A ruling, then expanded back to eight same day on the operator's field-report ruling (the mechanism this note named, arriving early — at commit-revision time, not Phase 1). The blast-radius backstop fires `MULTI`; the plan stays on the serial lane (skill-embed cascade + `version-history.md`), and the predicate re-runs at each claim
- **Reserved-surface waves** — the wrap-up surfaces (`version-history.md`, manifest, rules) sit in multiple write sets; a red repo gate between waves is a stop-the-line, and the T1-E2.09 ↔ T1-E1.05 `HOW-TO.md` overlap means the counter parcel and the config parcel can never cycle in one pass
- **E1.05 conversion timing** — the "convert to native V2 shape now, or wait" decision is its Phase-3 open question; the operator default at commit is convert now, bounded to the four named files
- **External claim coordination** — T1-E3.21 sits with a separate session that owns its claim end-to-end; this side re-runs the live predicate before each claim and leaves that plan's file untouched. Trunk discipline (`.devops/rules/plan-lifecycle.md` § Claim Protocol) already says one claim covers one file — two sessions and two wrap-ups are fine, interleaved edits to the same reserved surface are not

## Retro
*Appended by `@sprint-close` when the sprint closes. Left empty while the sprint is open.*

### Goal — Met?
*Appended by `@sprint-close`.*

### What Shipped
*Appended by `@sprint-close`.*

### Carry-Forward
*Appended by `@sprint-close`.*

### Metrics: Before → After
*Appended by `@sprint-close`.*

### Retro: Keep / Drop / Try
*Appended by `@sprint-close`.*

### Lessons for the Wiki / Knowledge Capture
*Appended by `@sprint-close`.*

### New Refactoring Items (→ REFACTORING.md)
*Appended by `@sprint-close`.*
