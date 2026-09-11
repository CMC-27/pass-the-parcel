---
type: "backlog"
name: "Backlog Index"
status: "stable"
description: "Master queue of all pending, parked, and roadmap features."
---

# 📋 Backlog Index

This index serves as the master queue of all proposed, deferred, or future feature requests and roadmap items. Each item points to a detailed plan file containing scoping, requirements, and design context. **Parked** plans live in `.devops/backlog/<slug>-backlog.md`; pick-up renames the file to `.devops/plans/<slug>-plan.md` (the `git mv` is the signal that it is now in flight).

## T1 — Parcel Pipeline Machinery

### T1-E1: Model & Config Integrity

| Plan | Status | Description |
| :--- | :--- | :--- |
| ~~T1-E1.01-reconcile-model-registry-plan.md~~ | `COMPLETE` | Resolved 2026-09-03: Model Registry replaced with abstract capability slots (`planning` / `review-heavy` / `execution`); concrete model binding is now satellite configuration in `opencode.json`. Archived to `.devops/archive/`. |

### T1-E2: Governance & Transport Integrity

| Plan | Status | Description |
| :--- | :--- | :--- |
| _(queue clear)_ | — | T1-E2.01 completed 2026-09-11 and archived to `.devops/archive/t1-e2.01-machinery-hardening-plan.md`. |

## T2 — Wiki System & Knowledge Layer

> Close the gap between this repo's **curated** wiki and an OpenWiki-class **self-maintaining** wiki. Governance is the moat; generation is borrowed via OKF interop.

### T2-E1: Wiki Self-Maintenance & Interop

| Plan | Status | Description |
| :--- | :--- | :--- |
| ~~T2-E1.01-wiki-self-maintenance-parity-plan.md~~ | `COMPLETE` | Resolved 2026-09-11: unified `format-version: 1` schema, Grounded Claims layer + secret-free CI drift gate, `@wiki-update` / `@wiki-generate` (bootstrap demoted to verification), OKF v0.2 export, `docs/` visualizer. Archived to `.devops/archive/t2-e1.01-wiki-self-maintenance-parity-plan.md`. |
| ~~T2-E1.03-coverage-gate-symbol-evidence~~ | `COMPLETE` | Resolved 2026-09-11 (v0.5.0): `wiki_coverage_check.py` now uses a four-route evidence OR — filename, parent folder, index-cited exported symbol, and `claims: source` binding — with a stdlib regex export scan and a lazy `wiki_claims.py` import. Additive (no satellite regression). Archived to `.devops/archive/t2-e1.03-coverage-gate-symbol-evidence-plan.md`. |

## T3 — Template Distribution & Onboarding

> Make the repo credible and self-explanatory as a public GitHub template: legal + community files, a README that sells the parcel pipeline, a release/CHANGELOG surface, and one complete worked example.

### T3-E1: Repository Hygiene & Presentation

| Plan | Status | Description |
| :--- | :--- | :--- |
| ~~T3-E1.01-template-repo-hygiene~~ | `COMPLETE` | Resolved 2026-09-11 (v1.0.0): `LICENSE` (MIT) + `CONTRIBUTING`/`SECURITY`/CoC + root `CHANGELOG` + README product-page rewrite + `.github` issue/PR templates/`CODEOWNERS`/`release.yml` + worked example in `.wiki/examples/`. `v1.0.0` tag left to the owner. Archived to `.devops/archive/t3-e1.01-template-repo-hygiene-plan.md`. |
