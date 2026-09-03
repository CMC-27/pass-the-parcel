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
| [T1-E1.01-reconcile-model-registry-plan.md](../plans/T1-E1.01-reconcile-model-registry-plan.md) | `BACKLOG` | `base-context.md` Model Registry documents `mimo-2.5` for phases 1-5/7 while `opencode.json` runtime assigns `deepseek-v4-flash` to every agent. Pick the canonical mapping and sync one side. |
