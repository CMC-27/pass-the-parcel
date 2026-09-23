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

- *(Sprint 10 "owner-loop" holds all seven previously-triaged items plus four new operator items; next candidates surface via `@backlog` or sprint retro.)*
- 🟢 **LATER** · **T1-E3.18** — The `stories:` trace has no gate behind it (surfaced closing `T1-E3.16`; gate it or measure compliance first). [plan](./t1-e3.18-stories-trace-ungated-backlog.md)
- 🟢 **LATER** · **T1-E3.19** — The wave-forecast table drifts from the live eligibility predicate (Sprint 10 retro Drop; also surfaces the sprint template's two disagreeing homes). [plan](./t1-e3.19-wave-forecast-drift-backlog.md)

Tiers: 🔴 NOW · 🟡 NEXT · 🟢 LATER · ⚪ PARKED · ❄️ DEFERRED. Ordering rules live in [`TRIAGE.md`](./TRIAGE.md).

---

## Themes

| Theme | Name | Register |
|-------|------|----------|
| T1 | Parcel Pipeline Machinery | [t1-parcel-pipeline-machinery-backlog.md](./t1-parcel-pipeline-machinery-backlog.md) — epics E1–E4 (latest: **T1-E4.01** machinery surface budget & Managed Simplicity) |
| T2 | Wiki System & Knowledge Layer | [t2-wiki-system-backlog.md](./t2-wiki-system-backlog.md) |
| T3 | Template Distribution & Onboarding | [t3-template-distribution-backlog.md](./t3-template-distribution-backlog.md) |

A theme register (`t{n}-<slug>-backlog.md`, front-matter `type: theme`) is the stable home for that theme's epics and features, both open and completed. The register is created when a new theme is first needed.
