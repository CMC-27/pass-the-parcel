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

> **Sprint 13 active** — the 9 committed plans are tracked in `.devops/sprints/sprint-13-v1-hardening/sprint.md` (queue + Delivery Model + predicate snapshot). `T1-E2.10` stays parked below; everything else in this panel shipped into the sprint.
- 🟢 **LATER** · `T1-E2.10` — The counter contract's two seams (the level rule is saturated as written; the ownership invariant has no machine failure signal). Both readings are recorded; parked rather than fixed so they are not re-litigated. [plan](./t1-e2.10-counter-contract-seams-backlog.md)

> **Discharged 2026-09-27** — `T2-E2.04` (KC's machinery boundary contradicted its own Parcel Pipeline section) was resolved by the operator-requested knowledge-consolidation **full audit** (direction 2: the machinery rules moved to their canonical `.devops/` homes). The same run discharged the `process-lessons.md` **fold pass** maintenance obligation: 13 matured rules folded into owning skills/rules docs, 9 KC machinery lessons promoted in — the register landed at **21** (was 25, then 26). No active sprint; `@sprint-plan` opens Sprint 13. The two LATER rows above were parked by the `T1-E2.09` / `T1-E3.23` wrap-ups.

Tiers: 🔴 NOW · 🟡 NEXT · 🟢 LATER · ⚪ PARKED · ❄️ DEFERRED. Ordering rules live in [`TRIAGE.md`](./TRIAGE.md).

---

## Themes

| Theme | Name | Register |
|-------|------|----------|
| T1 | Parcel Pipeline Machinery | [t1-parcel-pipeline-machinery-backlog.md](./t1-parcel-pipeline-machinery-backlog.md) — epics E1–E5 (latest: **T1-E3.25** The green-stamp invariant has no checker) |
| T2 | Wiki System & Knowledge Layer | [t2-wiki-system-backlog.md](./t2-wiki-system-backlog.md) — epics E1–E2 (latest: **T2-E2.04** KC's machinery boundary contradicts its own Parcel Pipeline section) |
| T3 | Template Distribution & Onboarding | [t3-template-distribution-backlog.md](./t3-template-distribution-backlog.md) |

A theme register (`t{n}-<slug>-backlog.md`, front-matter `type: theme`) is the stable home for that theme's epics and features, both open and completed. The register is created when a new theme is first needed.
