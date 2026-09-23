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
| _(none)_ | | | | |

### Completed

| Code | Title | Resolved | Note | Archive |
|------|-------|----------|------|---------|
| T3-E1.02 | Satellite "parcel feedback" pathway | 2026-09-23 | `@sync-architecture` v9→v10 gains scoped Workflow step 5 "Report parcel feedback upstream": satellite agent drafts a parked-plan-shaped item into a satellite-local `feedback/` outbox (this template's committed-plan shape), operator hand-carries at next sync, template-side intake = `git mv` into `.devops/backlog/` + theme-register row via `@backlog`, "reviewed" = triaged tier. `gh` transport declined at Phase 3.5 (secret-free portable surface); skill-scoped section over a new skill (Managed Simplicity). Also repaired the stale `@sprint-close` §6→§8 citation inside its write set — the wave-1 finding closed. | [plan](../archive/t3-e1.02-parcel-feedback-pathway-plan.md) |
| T3-E1.01 | Template repo hygiene | 2026-09-11 | `LICENSE` (MIT) + `CONTRIBUTING`/`SECURITY`/CoC + root `CHANGELOG` + README product-page rewrite + `.github` templates/`CODEOWNERS`/`release.yml` + worked example in `.wiki/examples/`. | [plan](../archive/t3-e1.01-template-repo-hygiene-plan.md) |
