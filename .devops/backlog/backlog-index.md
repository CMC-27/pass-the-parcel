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

> **Sprint 13 active** — the 9 committed plans are tracked in `.devops/sprints/sprint-13-v1-hardening/sprint.md` (queue + Delivery Model + predicate snapshot). **3 of 9 are `COMPLETE` and archived** (`T1-E2.12`, `T1-E2.13`, `T1-E4.05`); the other 6 are still queued there. `T1-E2.10` stays parked below.
- ✅ **SHIPPED** · `T1-E4.05` — the regrown sync engine is split below threshold: `sync-architecture.ps1` **975 → 314**, `sync-bindings.ps1` **450 → 371**, four new `scripts/lib/` modules — the **Kill List top-priority OPEN** row is closed. Resolved 2026-09-28 by the Sprint 13 batch run (`@sprint-run`); the register row moved to E4's Completed table. [plan](../archive/t1-e4.05-sync-engine-split-plan.md)
- ✅ **SHIPPED** · `T1-E2.13` — a comment line inside a `touches` block-list no longer truncates it: one predicate widened in `wiki_lint_core.list_field`, three fixture cases, and the **pre-fix probe observed failing** in all three predicted shapes. Resolved 2026-09-28 by the Sprint 13 batch run (`@sprint-run`); the declared write set proved a **superset** (7 of 12 paths deliberately unwritten — the wrap-up must not read that as an omission). [plan](../archive/t1-e2.13-block-list-comment-truncation-plan.md)
- 🟡 **NEXT** · `T1-E2.14` — **Two claim-path integrity holes left by the W6 split** (parked 2026-09-28). `scripts/wiki_claims.py:73` ends a `claims:` block on any column-0 line, so a column-0 comment silently drops every later claim — the defect class `T1-E2.13` just fixed, in a different parser; and six claim `source` fragments bind the re-export surface `scripts/wiki_lint.py#<symbol>` while the implementation moved to `wiki_lint_core.py`, so an edit to the implementation leaves them green. [plan](./t1-e2.14-claim-path-split-holes-backlog.md)
- 🟡 **NEXT** · `T1-E1.06` — **No `ptp-*` subagent is reachable on the opencode surface.** `subagent` → `ptp-context-hunter` returns `Permission denied: subagent` on a tree where `opencode.json` explicitly grants `"ptp-*": "allow"`, while the non-hidden `wiki-writer` spawns fine — so the facility is live and the exclusion is specific to the `hidden: true` `mode: "subagent"` entries. Consequence: `MULTI` cannot run there, and `@sprint-run`'s `ptp-parcel-fast` (declared identically) is blocked by the same construction. Cost so far: `T1-E3.22` claimed, promoted and halted pre-Phase 1, then released. Pair with `T1-E3.22` — both are claim-time preflight gaps. Filed 2026-09-28 while executing Sprint 13; **epic corrected to E3** at the `T1-E2.12` wrap-up (agent registration/availability is E3's subject, not E1's). **Partially addressed 2026-09-28 (Sprint 13 batch run):** the batch-runner half is **disproven on the current surface** — a probe spawn of `ptp-parcel-fast` (declared identically: `hidden: true` + `mode: subagent`) returned `PROBE_OK`, and two live per-plan runs followed, so `@sprint-run` is **not** blocked here. **Remaining:** the `MULTI` half is untested and cannot be probed from `parcel-sprint`; it needs a `@parcel` run. [plan](./t1-e1.06-opencode-subagent-surface-backlog.md)
- ✅ **SHIPPED** · `T1-E2.12` — the close-out CI read has a checker, and the no-push window has a home. Resolved 2026-09-28 by the `T1-E2.12` parcel (Sprint 13, plan 1 of 9); its Triage Panel row was consumed at `@sprint-plan` commit time, and the theme-register row now sits in E2's Completed table. [plan](../archive/t1-e2.12-close-out-ci-read-checker-plan.md)
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
