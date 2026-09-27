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

- 🟡 **NEXT** · `T1-E4.04` — Single-source the hot prose: the three largest rule fan-outs the surface-budget report does not yet register — **"Gate D always halts"** (the #1 safety invariant; CW2/F7 needed a seven-file fix), the **Mode vocabulary**, and the **topology definitions** (inside the PREFIX-LOCKED per-run token floor). Report-only instrument already exists (`scripts/rule_fanout.py`); the work is register + collapse-to-canon, the `T1-E4.01` W2 pattern. Filed 2026-09-27 from the operator's "streamline the template" review. [plan](./t1-e4.04-hot-prose-single-sourcing-backlog.md)
- 🟢 **LATER** · `T1-E2.12` — F2's close-out CI read has no checker (and the no-push window has no home). `T1-E2.11` shipped the first *remote* close-out read this template has had; `Q5` rejected a checker because a network read must not enter the portable surface, so presence proves the instruction exists, never that it ran. Carries the `Q8` cadence question and the Windows-local-last-gate note. Parked at the `T1-E2.11` wrap-up. [plan](./t1-e2.12-close-out-ci-read-checker-backlog.md)
- 🟢 **LATER** · `T1-E2.13` — A comment inside a `touches` block-list silently truncates it (finding **GB1**). Read **11 paths of 16** on a real declaration; `write_set_check.py` reported `exit 0` on the truncated set — a false green — and `sprint_eligible.py` saw zero reserved surfaces where three existed. Parked at the `T1-E2.11` wrap-up, operator-ruled out of that parcel. [plan](./t1-e2.13-block-list-comment-truncation-backlog.md)
- 🟢 **LATER** · `T1-E3.25` — **The green-stamp invariant has no checker.** `T1-E3.24`'s canon ships the closing-commit order, skip/hit recording and recorded==located as prose with no deterministic check (§ 5a.4); parked at that wrap-up after Phase 6 found Q6's discharge pointing at `T1-E2.12` (the wrong item). Realistic shape: a wrap-up-time assertion, not a new script. [plan](./t1-e3.25-green-stamp-invariant-gate-backlog.md)
- 🟢 **LATER** · `T1-E3.22` — The manual claim path has no enumerated green baseline (`.devops/rules/plan-lifecycle.md:116` names the preflight; no surface defines it for the manual path, and the batch's two-script version misses ten of the workflow's twelve steps). Parked 2026-09-27 at the `T1-E2.09` wrap-up — observed cost: the trunk was red on `Machinery version discipline` and the claim proceeded anyway. [plan](./t1-e3.22-manual-claim-baseline-backlog.md)
- 🟢 **LATER** · `T1-E2.10` — The counter contract's two seams (the level rule is saturated as written; the ownership invariant has no machine failure signal). Both readings are recorded; parked rather than fixed so they are not re-litigated. [plan](./t1-e2.10-counter-contract-seams-backlog.md)
- 🟢 **LATER** · `T1-E5.03` — No quantitative read-cost lever remains on the plan record: `T1-E3.23` landed four structural record rules but dropped the scoped cell-length cap as unverifiable prose, so record-cell **size** is unmeasured. Parked at the `T1-E3.23` wrap-up (Phase 7 `P8`). [plan](./t1-e5.03-plan-record-size-lever-backlog.md)

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
