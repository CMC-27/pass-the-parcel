---
type: "backlog"
name: "Backlog Index"
status: "stable"
description: "Master queue of all pending, parked, and roadmap features. Triage Panel + Themes table."
---

# 📋 Backlog Index

This index is the master queue of all proposed, deferred, or future work. It holds two things: the **Triage Panel** (what to do next) and the **Themes** table (where each theme's detail lives). Item detail — epics, features, completed rows — lives in the per-theme registers `t{n}-<slug>-backlog.md`; this index links out rather than duplicating it.

**Parked** plans live at `.devops/backlog/<code>-<slug>-backlog.md` (`type: backlog`, `claim_status: QUEUED`). Commitment into a sprint is `@sprint-plan`; the claim protocol in [`.devops/rules/plan-lifecycle.md`](../rules/plan-lifecycle.md) § Claim Protocol moves a committed plan into `.devops/plans/`. The `-backlog.md` suffix is shared with the theme registers — the front-matter `type` (`theme` vs `backlog`) is the discriminator.

> **Maturity, not queue.** Per-axis template maturity and next levers live in [`MATURITY.md`](MATURITY.md) — this index tracks work items; that register tracks how healthy each axis is.

> **Code quality is a separate lane.** Complexity/debt items live in [`REFACTORING.md`](./REFACTORING.md) — process-driven maintenance fed by the sprint-close scan, not roadmap work. Refactoring never enters the Triage Panel below.

---

## Triage Panel

- 🟢 **LATER** · `T1-E3.22` — The manual claim path has no enumerated green baseline (`.devops/rules/plan-lifecycle.md:116` names the preflight; no surface defines it for the manual path, and the batch's two-script version misses ten of the workflow's twelve steps). Parked 2026-09-27 at the `T1-E2.09` wrap-up — observed cost: the trunk was red on `Machinery version discipline` and the claim proceeded anyway. [plan](./t1-e3.22-manual-claim-baseline-backlog.md)
- 🟢 **LATER** · `T1-E2.10` — The counter contract's two seams (the level rule is saturated as written; the ownership invariant has no machine failure signal). Both readings are recorded; parked rather than fixed so they are not re-litigated. [plan](./t1-e2.10-counter-contract-seams-backlog.md)

> Sprint 12 `satellite-hygiene` took the 2026-09-25 intake on 2026-09-26 (3 plans / 5 pts, [sprint.md](../sprints/sprint-12-satellite-hygiene/sprint.md)); **`T1-E1.05` completed 2026-09-26, `T1-E2.09` completed 2026-09-27 and `T1-E3.21` completed 2026-09-27 — 3/3 delivered, sprint ready for `@sprint-close`.** The two LATER rows above were parked by the `T1-E2.09` wrap-up.

Tiers: 🔴 NOW · 🟡 NEXT · 🟢 LATER · ⚪ PARKED · ❄️ DEFERRED. Ordering rules live in [`TRIAGE.md`](./TRIAGE.md).

---

## Themes

| Theme | Name | Register |
|-------|------|----------|
| T1 | Parcel Pipeline Machinery | [t1-parcel-pipeline-machinery-backlog.md](./t1-parcel-pipeline-machinery-backlog.md) — epics E1–E5 (latest: **T1-E3.22** The manual claim path has no enumerated green baseline) |
| T2 | Wiki System & Knowledge Layer | [t2-wiki-system-backlog.md](./t2-wiki-system-backlog.md) |
| T3 | Template Distribution & Onboarding | [t3-template-distribution-backlog.md](./t3-template-distribution-backlog.md) |

A theme register (`t{n}-<slug>-backlog.md`, front-matter `type: theme`) is the stable home for that theme's epics and features, both open and completed. The register is created when a new theme is first needed.
