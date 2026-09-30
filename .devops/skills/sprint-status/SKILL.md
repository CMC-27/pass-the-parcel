---
name: sprint-status
description: Make sure to use this skill whenever the user asks "where are we", "sprint status", "how's the sprint going", "what's left in this sprint", "are we on track", /sprint-status, or wants a readout of the current sprint's progress. Reads the active sprint.md, the sprint queue, the active claims in .devops/plans/, and the archive, then produces a burn-up snapshot, flags at-risk or stale claims, and recommends what to work on next. This skill READS state — it writes no files and changes nothing.
version: 5
updated: 2026-09-30
---

# Sprint Status — Read-Only Status Readout

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
2. `.devops/plans/` contains the plan → read its claim front-matter: `claim_status` `CLAIMED` or `GATE_D_USER_APPROVAL` (or `COMPLETE` if wrap-up has run but the move has not), plus `owner` / `last_touch`, and the bottom `Status` phase (`PHASE_1`+). `GATE_D_USER_APPROVAL` means **executed, awaiting the Gate D verdict** — report it as awaiting sign-off, **not** as in-flight work. (Values and semantics: `.devops/rules/plan-lifecycle.md` § Claim Front-Matter — the canonical home.)
3. Still in the sprint folder with `claim_status: QUEUED` → `QUEUED` (not started).
4. Not found anywhere → `MISSING` — flag it; the queue and reality disagree.

Cross-reference recent `.devops/logs/agent-changelog.md` entries to confirm completions match reality. The archive is the machine signal for COMPLETE; `sprint.md`'s own status column is the human record — if they disagree, the archive wins and the sprint record needs updating.

## 4. Produce the Dashboard Readout

**The machine shape lives in the script; this section is the operator-facing example, cited to it.** Run `python scripts/sprint_dashboard.py` — its plain-text output IS the readout (one format, two entry points: the batch host prints the same shape at every transition, `@sprint-run` § 3; this skill prints it on demand). The pins (exact top-level keys, row fields, state tokens, rail ladders, degrade kinds) are owned by the script + the fixture suite (`scripts/tests/test_sprint_dashboard.py`) — this example is never edited ahead of them:

```
Sprint 14 — Queue Dashboard                                open
 ▶ sprint start — current
 ☐ user testing — pending
 ☐ sprint close — pending
 ✅ complete  T1-E3.20  preset overrule check
 ✅ complete  T1-E3.22  manual claim baseline
 ▶ running — batch  T1-E3.26  sprint queue dashboard
   ⟵ you are here (running — batch)
 ⏸ waiting on your call  T1-E1.06  subagent surface
 ⬜ queued — batch  T1-E5.03  plan-record lever
note: T1-E3.26 wrap-up done, archive move pending        (appears only when true)
```

**Kept alongside the shape (ride R6 — adoption never silently drops these):** Capacity / Plans / Points lines and the "On track?" read stay as the report's closing block, reading from `sprint.md`'s Capacity section as before. § 3's five-state machine maps onto the dashboard's badges 1:1: `COMPLETE` → `✅ complete`, awaiting the Gate D verdict → `⏳ awaiting gate D`, `CLAIMED` → `▶ running`, `QUEUED` (and its claimable subset) → `⬜ queued — batch`, blocked → `🚧 blocked — <the predicate's reason>` (from `compute()`'s `skipped` — § 5's Blocked-queue note renders from the same data), MISSING → `❔ missing`. One mapping home: this § 4; § 3's vocabulary points here, never re-rendered.

## 5. Flag Risk

- A large (L/XL) plan still `QUEUED` late in the sprint → at risk; recommend splitting or carrying forward.
- **Stale claims:** a plan in `.devops/plans/` whose `last_touch` is older than the newest changelog entry, or that carries a review flag, is stale — surface it for human review. Staleness is `last_touch` + review flag, **never** a time lease; human-gated phases pause legitimately.
- **Blocked queue:** a `QUEUED` plan whose `depends_on` codes are neither in `.devops/archive/` **nor** in `.devops/plans/` with `claim_status: GATE_D_USER_APPROVAL` is blocked — do not recommend claiming it. A dependency that is executed-but-unverified (`GATE_D_USER_APPROVAL`) **does** satisfy it.
- Delivered points far below pace → note it neutrally; do not editorialise.
- Any plan whose size estimate looks wrong vs the changelog effort → surface it so the retro can capture the calibration lesson.

## 6. Stop

Do not modify any file. End with the recommended next action for the user (claim the next eligible plan via the Claim Protocol and run `@pass-the-parcel`, or if all done — run `@sprint-close`).
