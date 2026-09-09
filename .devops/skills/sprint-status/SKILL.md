---
name: sprint-status
description: Make sure to use this skill whenever the user asks "where are we", "sprint status", "how's the sprint going", "what's left in this sprint", "are we on track", /sprint-status, or wants a readout of the current sprint's progress. Reads the active sprint plan and the changelog, produces a burn-up snapshot, flags at-risk plans, and recommends what to work on next. This skill READS state — it writes no files and changes nothing.
version: 1
updated: 2026-09-09
---

# Sprint Status — Read-Only Burn-Up

> **Boundary:** Pure reporting. Writes nothing. If the user wants to change scope, that's `@sprint-plan` (new sprint) or editing the active `plan.md` directly with their agreement. This skill only answers "where are we right now."

## 1. Find the Active Sprint

Read `.devops/backlog/SPRINTS.md`. Locate the row with status `🟢 ACTIVE`.
- If none is active → report "No sprint open" and suggest `@sprint-plan`. Stop.
- If more than one is active → flag the violation of the one-active-sprint rule and ask the user which is real.

## 2. Read Committed Scope

Open `.devops/backlog/sprints/sprint-{n}/plan.md`. Extract the Committed Scope table (codes, sizes, links).

## 3. Determine Each Plan's State

For each committed plan, find its actual status by checking, in order:
1. Is it in `.devops/archive/`? → COMPLETE.
2. Is it in `.devops/plans/` with a State Dashboard Status ≥ `PHASE_1`? → IN PROGRESS (note the phase).
3. Still `BACKLOG` or not found? → NOT STARTED.

Cross-reference recent `.devops/logs/agent-changelog.md` entries to confirm completions match reality.

## 4. Produce the Burn-Up Readout

Present as a compact report:

```
Sprint {n}: {Name}   Goal: {one line}
Capacity: {delivered}/{committed} pts ({%})   Plans: {done}/{total}

| Code | Plan | Size | Status | Note |
|------|------|------|--------|------|
| T.. | ... | M | ✅ DONE | archived {date} |
| T.. | ... | L | 🔄 PHASE 8 | executing |
| T.. | ... | S | ⬜ NOT STARTED | — |

On track? {yes / at risk / behind} — {reason}
Recommended next: {the highest-priority not-started or in-progress plan, with why}
```

## 5. Flag Risk

- A large (L/XL) plan still NOT STARTED late in the sprint → at risk; recommend splitting or carrying forward.
- Delivered points far below pace → note it neutrally; do not editorialise.
- Any plan whose size estimate looks wrong vs the changelog effort → surface it so the retro can capture the calibration lesson.

## 6. Stop

Do not modify any file. End with the recommended next action for the user (continue a plan, start the next one, or if all done — run `@sprint-close`).
