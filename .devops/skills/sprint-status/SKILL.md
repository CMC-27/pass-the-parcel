---
name: sprint-status
description: Make sure to use this skill whenever the user asks "where are we", "sprint status", "how's the sprint going", "what's left in this sprint", "are we on track", /sprint-status, or wants a readout of the current sprint's progress. Reads the active sprint.md, the sprint queue, the active claims in .devops/plans/, and the archive, then produces a burn-up snapshot, flags at-risk or stale claims, and recommends what to work on next. This skill READS state — it writes no files and changes nothing.
version: 2
updated: 2026-09-13
---

# Sprint Status — Read-Only Burn-Up

> **Boundary:** Pure reporting. Writes nothing. If the user wants to change scope, that's `@sprint-plan` (new sprint) or editing the active `sprint.md` directly with their agreement. This skill only answers "where are we right now."

## 1. Find the Active Sprint

Read `.devops/backlog/SPRINTS.md`. Locate the row with status `🟢 ACTIVE`.
- If none is active → report "No sprint open" and suggest `@sprint-plan`. Stop.
- If more than one is active → flag the violation of the one-active-sprint rule and ask the user which is real.
- Resolve the sprint folder `.devops/sprints/sprint-{n}-<slug>/` from that row.

## 2. Read Committed Scope

Open `.devops/sprints/sprint-{n}-<slug>/sprint.md`. Extract the **Committed Scope (queue)** table (codes, sizes, plan links). The queue is the authoritative committed scope.

## 3. Determine Each Plan's State

For each committed code, find its actual state by checking, in order:

1. `.devops/archive/` contains the plan → `COMPLETE` (archived).
2. `.devops/plans/` contains the plan → read its claim front-matter: `claim_status` `CLAIMED` or `IN_PROGRESS`, plus `owner` / `last_touch`, and the bottom `Status` phase (`PHASE_1`+).
3. Still in the sprint folder with `claim_status: QUEUED` → `QUEUED` (not started).
4. Not found anywhere → `MISSING` — flag it; the queue and reality disagree.

Cross-reference recent `.devops/logs/agent-changelog.md` entries to confirm completions match reality. The archive is the machine signal for COMPLETE; `sprint.md`'s own status column is the human record — if they disagree, the archive wins and the sprint record needs updating.

## 4. Produce the Burn-Up Readout

Present as a compact report:

```
Sprint {n}: {Name}   Goal: {one line}
Capacity: {delivered}/{committed} pts ({%})   Plans: {done}/{total}

| Code | Plan | Size | State | Owner | Last touch | Note |
|------|------|------|-------|-------|------------|------|
| T.. | ... | M | ✅ DONE | — | — | archived {date} |
| T.. | ... | L | 🔄 CLAIMED | {owner} | {date} | PHASE 8 executing |
| T.. | ... | S | 🟡 QUEUED | — | — | claimable |
| T.. | ... | S | ⬜ BLOCKED | — | — | depends on {code} |

On track? {yes / at risk / behind} — {reason}
Recommended next: {the highest-priority claimable plan, with why}
```

## 5. Flag Risk

- A large (L/XL) plan still `QUEUED` late in the sprint → at risk; recommend splitting or carrying forward.
- **Stale claims:** a plan in `.devops/plans/` whose `last_touch` is older than the newest changelog entry, or that carries a review flag, is stale — surface it for human review. Staleness is `last_touch` + review flag, **never** a time lease; human-gated phases pause legitimately.
- **Blocked queue:** a `QUEUED` plan whose `depends_on` codes are not yet in `.devops/archive/` is blocked — do not recommend claiming it.
- Delivered points far below pace → note it neutrally; do not editorialise.
- Any plan whose size estimate looks wrong vs the changelog effort → surface it so the retro can capture the calibration lesson.

## 6. Stop

Do not modify any file. End with the recommended next action for the user (claim the next eligible plan via the Claim Protocol and run `@pass-the-parcel`, or if all done — run `@sprint-close`).
