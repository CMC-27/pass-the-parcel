---
name: ptp-parcel-fast
description: 'Activate this skill to run ONE committed parcel plan end-to-end under the locked AUTO + SINGLE preset — Phases 1-9 in a single fresh context per plan, Gates A/B auto-cleared, Gate C N/A, terminating at PHASE_9 with Gate D OPEN. Invoked only by the `parcel-sprint` batch host (through the `ptp-parcel-fast` subagent); never user-selectable.'
version: 1
updated: 2026-09-13
---

# SKILL: Per-Plan Fast Runner (`ptp-parcel-fast`)

> **Boundary:** This skill owns exactly **one** plan's Phases 1-9. It is spawned by the `parcel-sprint` batch host (through the `ptp-parcel-fast` subagent) with a single plan path. It never walks the queue, never spawns anything, and never asks the Mode/Topology questions.

## Activation

- Owns one plan's Phases 1-9 in a single fresh context.
- Locked preset: `Mode = AUTO`, `Agents = SINGLE`. **Never ask** the Mode or Topology selection questions.
- The lifecycle, gate set, and phase content are owned by `@pass-the-parcel`; this skill only fixes *how* they are sequenced for the batch path. Do not restate the pipeline.

## Per-plan chain (exact order)

1. Play `ptp-context-hunter` **inline** (Phases 1-3).
2. Play `ptp-phase3-answerer` **inline** (Phase 3.5).
3. Auto-clear Gate A (see *Auto-clear test*).
4. Play `ptp-high-visionary` **inline** (Phases 4-5 — wiki spec + implementation plan + inline self-review).
5. Auto-clear Gate B; record Gate C `N/A`.
6. Play `ptp-code-surgeon` **inline** (Phases 8-9).
7. Commit the work with the exact message literal `plan: <code>`.
8. Set bottom **Status** `PHASE_9`, **Active Persona** `Executor`, leave **Gate D** `OPEN`.

## Plan Settings writer (frozen preset)

The chain's **first** action — at claim time, before Phase 1 — writes the plan's `## ⚙️ Plan Settings` block as the locked preset: `Mode=AUTO`, `Agents=SINGLE`. This closes the gap where plan-start config had no assigned writer under the batch path. The host (`parcel-sprint`) never authors it, and it is frozen thereafter.

## Auto-clear test

A gate auto-clears only when its outputs exist **and** contain no `REJECTED` verdict line and no `Unresolvable:` entry (mirrors `@pass-the-parcel` § Review Gates, `AUTO` clause). Otherwise halt with the failure outcome below.

## Named exception

This single-context Phases 1→9 run is the **explicit, machine-enforced Strict Context Isolation exception** (see Deviations). Every other run keeps the one-phase-group-per-session bound.

## Per-plan outcome map (halt vs skip)

- `PHASE_8_FAILED` (rollback after two failed self-healing attempts) → return `HALT <code>: PHASE_8_FAILED`.
- A self-review `**REJECTED:**` at the inline Phase 6 checkpoint, or a Phase 3.5 `Unresolvable:` → return `HALT <code>: <cause>`. **Never** start an inline `PHASE_5_REVISION` loop — revision belongs to a fresh Group B run, not this locked chain.
- A plan whose bottom `Status` is already `PHASE_9` at entry → return `SKIP <code>: already PHASE_9` without re-running.
- A plan whose `depends_on` is unmet at entry → return `SKIP <code>: unmet depends_on`.

## Output contract

Return exactly one terse line:

- `DONE <code>` — terminal `Status` `PHASE_9`, plus the touched-file list.
- `SKIP <code>: <reason>` — nothing written.
- `HALT <code>: <cause>` — nothing further attempted.

Never advance past `PHASE_9`, never flip Gate D, never reorder or re-run a skipped plan.

## Safety

Validation at trust boundaries, error handling, and the Gate D human sign-off are **not** simplifiable. The batch defers Gate D — it never skips it.
