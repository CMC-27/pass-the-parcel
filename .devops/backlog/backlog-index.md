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

- **🟡 NEXT — T1-E3.14 `wiki_claims.py check` is gated nowhere:** the drift gate ships with the machinery and **no gate invokes it** — Phase 7a hard-stops on `wiki_lint.py --quiet` + `wiki_claims.py coverage`, and the plan template's Phase 9 names no claims gate, so `coverage` green alongside `check` red reads as "verified". Live instance at GRID-Link 2026-09-22: a plan changed a claim-bound symbol and left **5 stale grounded claims** across five core docs, caught only because the wrap-up's wiki step ran `check` unprompted. One-line gate addition; open question is Phase 9 vs Phase 7a as its single home: [t1-e3.14](./t1-e3.14-wiki-claims-check-ungated-backlog.md).
- **🟡 NEXT — T1-E3.13 Phase 9 gate invocation can hang the batch runner:** a live `@sprint-run` (GRID-Link, 2026-09-22) hung on `npx vitest` — watch mode, because the satellite's `package.json` carries `"test": "vitest"`, the default shape for this machinery's own stated stack — and `@test-and-deploy` Step 4 prescribes exactly that form. The cancelled runner then left a state the lifecycle does not name and no rule can resume. Small, high-clarity fix (F1 is one invocation form; F2 adds the missing one-shot + timeout line to the batch path). Scope, three findings and the F3 resume hole: [t1-e3.13](./t1-e3.13-phase9-gate-invocation-hang-backlog.md).
- **🟢 LATER — T1-E3.12 Sprint-close business report:** the non-technical sprint summary was authored and proven at the GRID-Link satellite (`sprint-close` v8 + the Sprint 12 live example at `.devops/archive/sprints/sprint-12-showcase-slice/business-report.md`), but `.devops/skills/**` is portable — the satellite edit is overwritten on the next sync unless the improvement lands template-side here. Scope and reference implementation: [t1-e3.12](./t1-e3.12-sprint-close-business-report-backlog.md).

No other triaged items remain queued; next candidates surface via `@backlog` or sprint retro.

Tiers: 🔴 NOW · 🟡 NEXT · 🟢 LATER · ⚪ PARKED · ❄️ DEFERRED. Ordering rules live in [`TRIAGE.md`](./TRIAGE.md).

---

## Themes

| Theme | Name | Register |
|-------|------|----------|
| T1 | Parcel Pipeline Machinery | [t1-parcel-pipeline-machinery-backlog.md](./t1-parcel-pipeline-machinery-backlog.md) — epics E1–E4 (latest: **T1-E4.01** machinery surface budget & Managed Simplicity) |
| T2 | Wiki System & Knowledge Layer | [t2-wiki-system-backlog.md](./t2-wiki-system-backlog.md) |
| T3 | Template Distribution & Onboarding | [t3-template-distribution-backlog.md](./t3-template-distribution-backlog.md) |

A theme register (`t{n}-<slug>-backlog.md`, front-matter `type: theme`) is the stable home for that theme's epics and features, both open and completed. The register is created when a new theme is first needed.
