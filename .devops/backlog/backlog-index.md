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

- *(Sprint 10 closed 2026-09-23 — 7/7 delivered, archived. The 2026-09-24 GRID-Link field audit parked six new items below; T1-E3.18/E3.19 carry over.)*
- 🟡 **NEXT** · **T3-E1.03** — The deterministic CI gates stop at the template border (field finding 7: satellite CI is app-only; the README claim is template-side). [plan](./t3-e1.03-ci-gate-transportability-backlog.md)
- 🟡 **NEXT** · **T1-E2.08** — Tiered machinery versioning + ordering-aware transport (field finding 4: counter divergence 78 vs 72; equality-only sync cannot tell behind from ahead). [plan](./t1-e2.08-tiered-machinery-versioning-backlog.md)
- 🟡 **NEXT** · **T1-E5.01** — MICRO topology — the sanctioned small-change pathway (operator priority; field-calibrated: ~45% SINGLE + 35 ad-hoc runs). [plan](./t1-e5.01-micro-topology-backlog.md)
- 🟢 **LATER** · **T1-E3.18** — The `stories:` trace has no gate behind it (surfaced closing `T1-E3.16`; gate it or measure compliance first). [plan](./t1-e3.18-stories-trace-ungated-backlog.md)
- 🟢 **LATER** · **T1-E3.19** — The wave-forecast table drifts from the live eligibility predicate (Sprint 10 retro Drop; also surfaces the sprint template's two disagreeing homes). [plan](./t1-e3.19-wave-forecast-drift-backlog.md)
- 🟢 **LATER** · **T1-E5.02** — The changelog becomes a generated index; plans are the source of truth (operator ruling; GRID-Link field evidence: changelog spans 8 days, plans span months). [plan](./t1-e5.02-changelog-generated-index-backlog.md)
- 🟢 **LATER** · **T1-E3.20** — The batch preset silently overrules a sprint's recorded Mode rulings (2026-09-13 lesson; promoted by the field audit). [plan](./t1-e3.20-batch-preset-overrule-check-backlog.md)
- 🟢 **LATER** · **T3-E1.04** — CORE satellite profile — measured onboarding reduction (~18 of 36 skills carry the pipeline in the field). [plan](./t3-e1.04-core-satellite-profile-backlog.md)

Tiers: 🔴 NOW · 🟡 NEXT · 🟢 LATER · ⚪ PARKED · ❄️ DEFERRED. Ordering rules live in [`TRIAGE.md`](./TRIAGE.md).

---

## Themes

| Theme | Name | Register |
|-------|------|----------|
| T1 | Parcel Pipeline Machinery | [t1-parcel-pipeline-machinery-backlog.md](./t1-parcel-pipeline-machinery-backlog.md) — epics E1–E4 (latest: **T1-E4.01** machinery surface budget & Managed Simplicity) |
| T2 | Wiki System & Knowledge Layer | [t2-wiki-system-backlog.md](./t2-wiki-system-backlog.md) |
| T3 | Template Distribution & Onboarding | [t3-template-distribution-backlog.md](./t3-template-distribution-backlog.md) |

A theme register (`t{n}-<slug>-backlog.md`, front-matter `type: theme`) is the stable home for that theme's epics and features, both open and completed. The register is created when a new theme is first needed.
