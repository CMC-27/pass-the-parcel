---
type: "backlog"
name: "Backlog Index"
status: "stable"
description: "Master queue of all pending, parked, and roadmap features."
---

# 📋 Backlog Index

This index serves as the master queue of all proposed, deferred, or future feature requests and roadmap items. Each item points to a detailed plan file containing scoping, requirements, and design context. Plan files live in `.devops/plans/` using the `T{theme}-E{epic}.{impl}` prefix convention (see the `backlog` and `build-roadmap` skills).

## T1 — Parcel Pipeline Machinery

### T1-E1: Model & Config Integrity

| Plan | Status | Description |
| :--- | :--- | :--- |
| ~~T1-E1.01-reconcile-model-registry-plan.md~~ | `COMPLETE` | Resolved 2026-09-03: Model Registry replaced with abstract capability slots (`planning` / `review-heavy` / `execution`); concrete model binding is now satellite configuration in `opencode.json`. Archived to `.devops/archive/`. |
