---
name: backlog
description: Make sure to use this skill whenever the user asks to add a feature, function, upgrade, idea, or task to the backlog. Use it to analyze the request, gather necessary codebase context, and create a comprehensive entry in the project's backlog-index.md and a separate plan file. This skill creates PARKED items only — it does NOT execute or plan execution.
version: 1
updated: 2026-09-03
---

# Backlog Management

> **Boundary:** This skill creates backlog items only. It does not scope, plan, or execute. All plan files (both backlog/parked and active) live in `.devops/plans/` with `-plan.md` suffix. Status is tracked in each plan's State Dashboard — `BACKLOG` means parked, `PHASE_1`+ means in flight. See the `pass-the-parcel` skill's [Plan State Lifecycle table] for the canonical state machine.

## Prefix Convention

Every plan file MUST use the prefix code format `T{theme}-E{epic}.{impl}`:

- **T{n}** — Theme (e.g. T1 = Access Control & Security, T2 = Master Data Management)
- **E{n}** — Epic within the theme (e.g. E1 = first epic)
- **.{impl}** — Implementation plan number within the epic (e.g. .01, .02)

The plan filename follows: `T{theme}-E{epic}.{impl}-{descriptive-slug}-plan.md`

Example: `T3-E1.01-import-modal-horizontal-scroll-plan.md`

## 1. Analyze and Gather Context
When the user requests to add an item to the backlog:
- Analyze the user's request to understand the core feature, function, or upgrade.
- Proactively explore the workspace to gather relevant context (e.g., related files, current architecture, existing patterns, or dependencies) that will be useful when implementing this in the future.
- Do not ask the user for information you can find yourself by reading the codebase.

## 2. Determine Placement in Hierarchy

1. **Read** `.devops/backlog/backlog-index.md` to understand the existing Theme/Epic structure.
2. **Determine** which Theme (T{n}) and Epic (E{n}) the new item belongs to.
3. **Determine** the next available implementation number. Scan `.devops/plans/` for existing plans with the same `T{n}-E{n}.` prefix to find the highest existing number, then increment by 1.
   - If this is the first plan in an epic, start at `.01`.
   - If a new epic is needed, add it to `.devops/backlog/backlog-index.md` under the appropriate theme.
   - If a new theme is needed, add it to `.devops/backlog/backlog-index.md` and assign the next T number.

## 3. Format the Backlog Entry
For each backlog item, create:

1. A new entry in `.devops/backlog/backlog-index.md` under the correct Theme > Epic section, linking to the plan file.
2. A full early-prepared plan file at `.devops/plans/{code}-{slug}-plan.md` using the canonical Pass-the-Parcel template (full scaffold: Phases 1-10 + Wrap Up). Per the [Lifecycle table]:
   - **Status** → `BACKLOG` (parked, not in flight)
   - **Active Persona** → `Planner` (prepares the scaffold)
   - **File suffix** → `-plan.md` (all plan files use this suffix)
   - **Directory** → `.devops/plans/` (all plan files live here)
   Populate with gathered context:
   - **Phase 1 (Expansion & Scoping):** Frame the intent, in-scope, and out-of-scope tasks.
   - **Phase 2 (Requirements & Context):** Relevant files, current implementation details, and architectural considerations discovered during research.
   - **Phase 3 (User Clarification):** Any edge cases, potential roadblocks, or design decisions that need to be resolved before implementation (left as open checklist items).
   - **Phase 4 (Detailed Execution Plan):** Any tentative steps, commands, or placeholder logic.

## 4. Update the Backlog Index
- Locate `.devops/backlog/backlog-index.md` (create if missing).
- Add a table entry under the correct Theme > Epic section linking to `.devops/plans/{code}-{slug}-plan.md`.
- If a new Theme or Epic was created, add the appropriate heading.

> **DO NOT** change the plan's Status from `BACKLOG` or move files between directories. The `pass-the-parcel` skill handles the BACKLOG → PHASE_1 transition when the item is picked up for execution.
