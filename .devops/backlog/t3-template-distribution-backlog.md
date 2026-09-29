---
type: "theme"
theme: T3
name: "Template Distribution & Onboarding"
status: "active"
description: "Make the repo credible and self-explanatory as a public GitHub template."
---

# T3 — Template Distribution & Onboarding

> Make the repo credible and self-explanatory as a public GitHub template: legal + community files, a README that sells the parcel pipeline, a release/CHANGELOG surface, and one complete worked example.

## E1 — Repository Hygiene & Presentation

### Open

| Code | Title | Status | Description | Plan |
|------|-------|--------|-------------|------|
| — | — | *(no open E1 items — `T3-E1.05` closes this epic's last parked row)* | Held last by `depends_on`, then executed 2026-09-29; nothing else is parked at E1. | — |

### Completed

| Code | Title | Resolved | Note | Archive |
|------|-------|----------|------|---------|
| T3-E1.05 | v1.1.0 release + measurement baseline | 2026-09-29 | Closes `[Unreleased]` as **v1.1.0** (operator ruling: minor — additive hardening since v1.0.0): sweep bullets under Keep-a-Changelog citing rows 73/74/75/78/79/83/87, plus machinery-86's tag obligation recorded verbatim as `carried as a deferred obligation to Release B`. `MATURITY.md` re-graded per its Method — Axis 1 **A− → A** (named lever discharged at machinery 73), all 7 evidence cells refreshed, history row + Scorecard + `last-reviewed` to 2026-09-29 — and it gains `## Cost Baseline (v1.1.0 — 2026-09-29)`, a **hand-read** table (no script, no gate) where every cell is a sourced number or an explicit `not available — no session export supplied` note: **14 gate wall-clock timings ≈ 92 s**, plan read cost **102,412 B / 705 lines**, token cells unsupplied (Q1(a) export requested, declined this session — per-metric fallback, no estimate). README/HOW-TO sweep was **verify-first** per Q5(a): all six README claims verified true (file left byte-unchanged), one false HOW-TO diagram node `Pre-Deployment Vibe Auditor` renamed to `App-facing hardening sweep`. Ran `AUTO` + **`MULTI`** on the manual path (`triage: MULTI` honoured — independent Group C reviewers, **one revision round at Gate C**, 4 gates). Tag `v1.1.0` + GitHub Release remain operator-only, gated on a green release-commit pass. | [plan](../archive/t3-e1.05-v110-release-baseline-plan.md) |
| T3-E1.04 | CORE satellite profile — measured onboarding reduction | 2026-09-25 | The transport contract gains a declared **skill tier**: the template publishes CORE membership as data (`core_skills:` — the **18** pipeline-carrying skills measured in the GRID-Link field audit, not opinion), a satellite declares `profile: CORE` in its **own** manifest (the one file a sync never overwrites), and the sync respects it. `FULL` stays the default, so an existing satellite is unchanged; a CORE target installs only its effective set, **never** reports a tiered-out skill as `MISSING`, reports a present one as `PRUNE` and sheds it on sync, and returns to `FULL` purely additively. A bad `profile` value halts at the trust boundary before anything is written. Directories, agents, rules and every guardrail script stay untiered. `SATELLITE-BOOTSTRAP.md` v15→16. Follow-ups (recorded, not fixed): `.devops/skills/sync-architecture/SKILL.md` § verdict table and `.devops/README.md` § portable-skill derivation both predate the tier. Wave 3 of Sprint 11. | [plan](../archive/t3-e1.04-core-satellite-profile-plan.md) |
| T3-E1.03 | The deterministic CI gates stop at the template border | 2026-09-25 | The machinery gates now **travel**: `.github/workflows/machinery-gates.yml` is a portable, self-contained workflow (the `wiki-refresh.yml` precedent) running the invariant subset — prefix integrity, UTF-8, wiki lint (guarded on `.wiki/core`), coverage, claims drift — in every satellite on every push, with no wiring step and no secret. The gate list splits **invariant everywhere** vs **template-identity** (transport `-SelfTest`, machinery-version discipline, `scripts/tests/` fixtures); the split rule has one home in the portable file's header, cited by `validate.yml` (its ten steps unchanged) and `.devops/templates/SATELLITE-BOOTSTRAP.md` (v14→15); `README.md` made truthful. Transported via `portable_files`; `sync-architecture -SelfTest` OK (18 → **19** files). Wave 2 of Sprint 11. | [plan](../archive/t3-e1.03-ci-gate-transportability-plan.md) |
| T3-E1.02 | Satellite "parcel feedback" pathway | 2026-09-23 | `@sync-architecture` v9→v10 gains scoped Workflow step 5 "Report parcel feedback upstream": satellite agent drafts a parked-plan-shaped item into a satellite-local `feedback/` outbox (this template's committed-plan shape), operator hand-carries at next sync, template-side intake = `git mv` into `.devops/backlog/` + theme-register row via `@backlog`, "reviewed" = triaged tier. `gh` transport declined at Phase 3.5 (secret-free portable surface); skill-scoped section over a new skill (Managed Simplicity). Also repaired the stale `@sprint-close` §6→§8 citation inside its write set — the wave-1 finding closed. | [plan](../archive/t3-e1.02-parcel-feedback-pathway-plan.md) |
| T3-E1.01 | Template repo hygiene | 2026-09-11 | `LICENSE` (MIT) + `CONTRIBUTING`/`SECURITY`/CoC + root `CHANGELOG` + README product-page rewrite + `.github` templates/`CODEOWNERS`/`release.yml` + worked example in `.wiki/examples/`. | [plan](../archive/t3-e1.01-template-repo-hygiene-plan.md) |
