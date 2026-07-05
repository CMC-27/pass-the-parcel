---
name: backlog
description: Make sure to use this skill whenever the user asks to add a feature, function, upgrade, idea, or task to the backlog. Use it to analyze the request, gather necessary codebase context, and create a comprehensive entry in the project's backlog-index.md and a separate backlog plan file. This skill creates PARKED items only — it does NOT execute or plan execution.
---

# Backlog Management

> **Boundary:** This skill creates backlog items only. It does not scope, plan, or execute. Backlog plans live in `docs/backlog/` with a `-backlog.md` suffix. When a backlog item is picked up for execution, the `pass-the-parcel` skill renames it to `-plan.md` and moves it to `docs/plans/`. See the `pass-the-parcel` skill's [Plan State Lifecycle table] for the canonical state machine.

## 1. Analyze and Gather Context
When the user requests to add an item to the backlog:
* Analyze the user's request to understand the core feature, function, or upgrade.
* Proactively explore the workspace to gather relevant context (e.g., related files, current architecture, existing patterns, or dependencies) that will be useful when implementing this in the future.
* Do not ask the user for information you can find yourself by reading the codebase.

## 2. Format the Backlog Entry
For each backlog item, create:
1. A brief entry line in `docs/backlog/backlog-index.md` containing a clickable link to the backlog plan.
2. A full early-prepared backlog plan file at `docs/backlog/<feature-slug>-backlog.md` using the canonical Pass-the-Parcel template (full scaffold: Phases 1-10 + Wrap Up). Per the [Lifecycle table]:
   - **Status** → `BACKLOG` (parked, not in flight)
   - **Active Persona** → `Planner` (prepares the scaffold)
   - **File suffix** → `-backlog.md` (signals this is a parked backlog item, not an active plan)
   - **Directory** → `docs/backlog/` (not `docs/plans/`)
   Populate with gathered context:
   - **Phase 1 (Expansion & Scoping):** Frame the intent, in-scope, and out-of-scope tasks.
   - **Phase 2 (Requirements & Context):** Relevant files, current implementation details, and architectural considerations discovered during research.
   - **Phase 3 (User Clarification):** Any edge cases, potential roadblocks, or design decisions that need to be resolved before implementation (left as open checklist items).
   - **Phase 4 (Detailed Execution Plan):** Any tentative steps, commands, or placeholder logic.

## 3. Update the Backlog
* Locate `docs/backlog/backlog-index.md` (create if missing).
* Add a bullet entry linking to `docs/backlog/<feature-slug>-backlog.md`.
* Create the backlog plan file at `docs/backlog/<feature-slug>-backlog.md`.

> **DO NOT** create plans in `docs/plans/` or use the `-plan.md` suffix — those are for active execution plans only. The `pass-the-parcel` skill handles the `-backlog` → `-plan` transition when the item is picked up.
