<!--
type: template
version: 1
updated: 2026-09-09

TRIAGE.template.md — seed for a satellite's backlog triage framework.
Copy to .devops/backlog/TRIAGE.md. This is process, not data — it rarely needs editing
per-project; the tiers and rules are universal. It governs how backlog-index.md's Triage
Panel is populated and how work flows into sprints.
-->
---
type: "process"
name: "Backlog Triage Framework"
status: "active"
description: "Rules for prioritising and ordering backlog items. Read this before updating the Triage Panel in backlog-index.md."
---
# 🎯 Backlog Triage Framework

This document defines how items get prioritised in the Triage Panel at the top of [backlog-index.md](./backlog-index.md). It exists so any agent or human can re-triage consistently without needing tribal knowledge.

---

## The Four Tiers

| Tier | Emoji | Meaning | Criteria (any one qualifies) |
|------|-------|---------|------------------------------|
| **NOW** | 🔴 | Must do immediately | Hard deadline · Security risk · User-facing bug · Blocks other work |
| **NEXT** | 🟡 | Should do soon | Closes standing exception · Small effort / high clarity · Unblocks iteration on a shipped feature |
| **LATER** | 🟢 | Worth doing, no urgency | Improves velocity · Code quality · Test infrastructure · Tooling |
| **PARKED** | ⚪ | Known but not scheduled | No deadline · No blocker · Would be nice · Depends on future decision |
| **DEFERRED** | ❄️ | Explicitly ruled out for now | User ruling · Post-MVP scope · Aspirational feature awaiting demand signal |

---

## Prioritisation Rules (apply in order)

1. **Deadline beats everything.** If an item has a hard external date, it's 🔴 NOW regardless of effort or impact.
2. **User-facing bugs are 🔴 NOW.** Anything that shows wrong data, blocks a workflow, or creates a security gap goes to the top.
3. **Standing exceptions are 🟡 NEXT.** When a completed plan records an "AC exception" or "deferred with note," that item is debt. It stays 🟡 until resolved or explicitly ruled "won't fix."
4. **Small + unblocks = higher priority.** A 30-minute task that lets you iterate cleanly outranks a 4-hour refactor nobody's waiting on.
5. **Infrastructure follows features.** Test migration, lint cleanup, CCN reduction — these are 🟢 LATER unless they're actively blocking CI or causing flaky builds.
6. **Deferred ≠ forgotten.** Items in ❄️ have a *reason* recorded. They only promote when the reason changes.
7. **When in doubt, ask.** If two items compete for the same tier, use the question tool to get a user ruling rather than guessing. Record the ruling in the item's detail block.

---

## How to Update the Triage Panel

### At session start (pickup)
1. Read the Triage Panel and check `SPRINTS.md` for an active sprint.
2. **If a sprint is active:** run `@sprint-status` to see what's committed, then continue executing a committed plan via `@pass-the-parcel`. Do NOT pull new items ad-hoc — that's scope creep.
3. **If no sprint is active:** run `@sprint-plan` to commit a batch of triaged items into a sprint first, THEN execute.
4. Once an item is committed to a sprint, remove it from the Triage Panel (it's tracked by the sprint now).

### At session end (wrap-up)
1. If the last committed sprint plan just finished, run `@sprint-close` (retro + spaghetti scan). It handles moving completed items to ✅ Recently Completed and refreshing REFACTORING.md.
2. Otherwise, leave the active sprint's scope untouched — individual parcel completions are logged in `agent-changelog.md`.
3. Update `last_triaged` in the frontmatter only if you changed tier assignments.

### When adding new items
1. Determine tier using the rules above.
2. Insert into the Triage Panel at the correct position within its tier.
3. Add a detail block in the appropriate section below.
4. If the item has a plan file already, link it. If not, note "Plan: Not yet created."

---

## Effort Sizing (for ordering within a tier)

| Size | Meaning | Examples |
|------|---------|----------|
| **S** | Single session, <1 hour | Drop a table, bump a dep, fix a race condition |
| **M** | One focused parcel, 1-3 hours | Schema migration + code update + tests |
| **L** | Multi-session or multi-file | Component decomposition, test migration tranche |
| **XL** | Epic-level, needs planning | New pillar MVP, full refactor wave |

Within a tier, prefer S→M→L→XL unless dependencies force otherwise. Quick wins build momentum and reduce surface area for larger work.

---

## Anti-Patterns to Avoid

- **❌ Hoarding detail in the index.** This file is a register, not a spec. Keep descriptions to one-liners. Full context lives in plan files or wiki docs.
- **❌ Status drift.** An item marked COMPLETE here must have a matching entry in `agent-changelog.md`. If they disagree, the changelog wins.
- **❌ Silent promotion.** Don't move something from ❄️ DEFERRED to 🟡 NEXT without recording *why* the deferral reason changed.
- **❌ Duplicate tracking.** If an item has a plan file in `.devops/plans/`, it should NOT also appear in the Triage Panel. Active work is tracked by its plan, not here.
- **❌ Stale deadlines.** If a deadline passes without action, escalate the item to 🔴 NOW immediately and flag it in the next session.

---

## Relationship to Other Documents

| Document | Role |
|----------|------|
| [product-roadmap.md](./product-roadmap.md) | Defines themes and epics (*what*). Doesn't schedule. |
| [backlog-index.md](./backlog-index.md) | Registers all open items with triage (*when*). |
| [SPRINTS.md](./SPRINTS.md) | The agile rhythm — time-boxed cycles that consume triaged backlog. |
| [REFACTORING.md](./REFACTORING.md) | Code quality register. Process-driven maintenance, not feature work. |
| `.devops/plans/` | Active implementation plans (in-progress work). |
| `.devops/archive/` | Completed plans (historical record). |
| `.devops/logs/agent-changelog.md` | Session-by-session log of what shipped. |
| `.wiki/core/00-system-index.md` | Architecture truth. Backlog items reference wiki docs, not vice versa. |

---

## How Triage Feeds Sprints

The Triage Panel is the **input** to sprint planning. The flow:

1. Items live in the Triage Panel at their tier (🔴 NOW / 🟡 NEXT / 🟢 LATER / ⚪ PARKED / ❄️ DEFERRED).
2. `@sprint-plan` pulls 🔴 + 🟡 (plus carry-forward, plus Kill-List top-N if capacity allows) into a committed sprint.
3. Once an item is committed to a sprint, it moves OUT of the Triage Panel into the sprint's `plan.md` — active work is tracked by its sprint + plan, not here (see Anti-Pattern: Duplicate tracking).
4. If a sprint carries an item forward, it re-enters the Triage Panel at its original tier for the next planning pass.

**Rule:** An item should never appear in BOTH the Triage Panel and an ACTIVE sprint's committed scope simultaneously. When you commit it, remove it from the panel; when it carries forward, put it back.

---

## Refactoring Trigger

Code-quality work does NOT go through the Triage Panel. It lives in [REFACTORING.md](./REFACTORING.md) and enters through a process:

### When items enter REFACTORING.md

| Trigger | Rule |
|---------|------|
| **End-of-parcel** | After wrap-up, if any touched file exceeds CCN>15 or grew >20% in lines, log it in REFACTORING.md's Kill List. Do NOT add to backlog triage. |
| **Sprint close** | At every `@sprint-close`, a spaghetti-monster scan runs across all files touched that sprint and refreshes the Kill List. This is the primary rhythm. |
| **CI signal** | Vitest OOM, flaky tests, lint regression → infrastructure item in REFACTORING.md. |
| **Dead code discovered** | Unwired-but-tested code found during feature work → Dead Code Candidates table. Link to a backlog item ONLY if disposition requires a user ruling. |

### The boundary rule

> **If it changes user-visible behavior → backlog (feature).**
> **If it only changes internal structure → REFACTORING.md (maintenance).**

Examples:
- Splitting a view into sub-components → REFACTORING.md (no behavior change)
- Adding a new column users can see → backlog (user sees it)
- Migrating tests to isolation-first pattern → REFACTORING.md (infrastructure)
- Fixing a user-facing auth bug → backlog 🔴 NOW

### When refactoring becomes urgent enough for the triage panel

Rarely, accumulated debt starts blocking feature work (e.g., CI is unusable due to OOM, or a file is so tangled that a bug fix would take longer than a refactor). In that case:

1. Promote the specific item from REFACTORING.md into the Triage Panel at 🟢 LATER or 🟡 NEXT.
2. Add a note: *"Promoted from REFACTORING.md — [reason]."*
3. Once resolved, remove from triage and update REFACTORING.md's completed table.

This keeps the default flow process-driven while allowing genuine emergencies to surface.
