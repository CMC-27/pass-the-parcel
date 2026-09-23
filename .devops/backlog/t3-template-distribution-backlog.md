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
| T3-E1.03 | The deterministic CI gates stop at the template border | QUEUED | `validate.yml` is not portable and satellite CI is app-only (GRID-Link field finding 7), so the guardrails instrument is a local convention in the field and README's "on every push" claim is template-side only. Fix: a transportable machinery-gates surface — reusable workflow / composite action / documented wiring — the smallest a satellite can adopt without restructuring its own CI. | [plan](./t3-e1.03-ci-gate-transportability-backlog.md) |
| T3-E1.04 | CORE satellite profile — measured onboarding reduction | QUEUED | A declared manifest profile (`CORE` vs `FULL`) so a satellite installs the parcel core + guardrail scripts without the full 34-skill library; membership from the 2026-09-24 field audit's measured usage (~18 of 36 skills carry the pipeline in GRID-Link), not opinion; `FULL` stays the default so existing satellites are unchanged. | [plan](./t3-e1.04-core-satellite-profile-backlog.md) |

### Completed

| Code | Title | Resolved | Note | Archive |
|------|-------|----------|------|---------|
| T3-E1.02 | Satellite "parcel feedback" pathway | 2026-09-23 | `@sync-architecture` v9→v10 gains scoped Workflow step 5 "Report parcel feedback upstream": satellite agent drafts a parked-plan-shaped item into a satellite-local `feedback/` outbox (this template's committed-plan shape), operator hand-carries at next sync, template-side intake = `git mv` into `.devops/backlog/` + theme-register row via `@backlog`, "reviewed" = triaged tier. `gh` transport declined at Phase 3.5 (secret-free portable surface); skill-scoped section over a new skill (Managed Simplicity). Also repaired the stale `@sprint-close` §6→§8 citation inside its write set — the wave-1 finding closed. | [plan](../archive/t3-e1.02-parcel-feedback-pathway-plan.md) |
| T3-E1.01 | Template repo hygiene | 2026-09-11 | `LICENSE` (MIT) + `CONTRIBUTING`/`SECURITY`/CoC + root `CHANGELOG` + README product-page rewrite + `.github` templates/`CODEOWNERS`/`release.yml` + worked example in `.wiki/examples/`. | [plan](../archive/t3-e1.01-template-repo-hygiene-plan.md) |
