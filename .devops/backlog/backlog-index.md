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
