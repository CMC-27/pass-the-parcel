---
name: sprint-close
description: 'Make sure to use this skill whenever the user mentions closing a sprint, ending a sprint, sprint retrospective, "we finished the sprint", /sprint-close, wrap up the cycle, or when all committed parcel plans in the active sprint reach COMPLETE. Runs the end-of-sprint ritual: appends the retro into the single sprint.md, triggers a spaghetti-monster scan of everything touched this sprint to refresh REFACTORING.md, captures lessons, moves the sprint.md to .devops/archive/sprints/sprint-{n}-<slug>/, and updates SPRINTS.md. This skill CLOSES a sprint — it does not plan one (@sprint-plan) or execute parcels (@pass-the-parcel).'
version: 3
updated: 2026-09-13
---

# Sprint Close — Retrospective & Hygiene Ritual

> **Boundary:** This skill closes the active sprint. It appends the retro to `sprint.md`, runs the code-quality scan that feeds the next cycle, archives the sprint record, and updates the registers. It does not start planning the next sprint (that's `@sprint-plan`, invoked separately once this is done).

## Prerequisites — Read First

1. `.devops/backlog/SPRINTS.md` — find the ACTIVE sprint row and its sprint link.
2. `.devops/sprints/sprint-{n}-<slug>/sprint.md` — the committed scope you're measuring against.
3. Last several entries of `.devops/logs/agent-changelog.md` — what actually shipped this sprint.

## 1. Verify Completion Before Closing

Check every plan in the Committed Scope (queue) table:
- Each should be COMPLETE (`claim_status: COMPLETE`) and present in `.devops/archive/` (root).
- If any plan is unfinished, do NOT silently drop it — record it as **carry-forward** in the retro (Section 4). A sprint can close with carry-forward; it just means capacity was over-committed. Unfinished plans still in the sprint queue stay parked for the next planning pass (move them back with `git mv` to `.devops/backlog/<code>-<slug>-backlog.md` and reset `claim_status: QUEUED`).

Confirm the sprint-level Definition of Done from `sprint.md`: full suite green, lint clean, build exit 0. Run them if not already verified this session.

## 2. Run the Spaghetti Scan (the hygiene step)

This is the process trigger that keeps refactoring out of the feature backlog:

1. Determine the set of files touched this sprint (from changelog entries + `git diff --name-only {baseline}`).
2. Invoke `@spaghetti-monster` scoped to those touched areas (or run `scripts/spaghetti-monster-scan.cjs` directly for a quick metric pass).
3. For any file now crossing a threshold (CCN>15 warn / >25 critical, >400 lines, etc. per `.devops/backlog/REFACTORING.md` § Thresholds), add it to the REFACTORING.md Kill List with a note: *"Flagged at close of sprint {n} by {file change}."*
4. Update REFACTORING.md's "Completed Refactors" table for anything this sprint cleaned up.

The scan output does NOT create new feature-backlog items. It only feeds REFACTORING.md.

## 3. Measure Capacity Accuracy

Compare committed points vs delivered points from `sprint.md`. Record in the retro. This number calibrates future `@sprint-plan` capacity suggestions — it's the single most useful line for making estimates honest over time.

## 4. Append the Retro to sprint.md

There is **no separate `retro.md`**. Append a `## Retro` section to the existing `.devops/sprints/sprint-{n}-<slug>/sprint.md`, and flip its front-matter `status` to `closed` and `closed:` to today. Fill every section — an empty section is a skipped lesson.

### Appended section template

```markdown
## Retro

### Goal — Met?
{Restate the goal from the top of this file. Did we achieve it? Yes / Partially / No, with one-line why.}

### What Shipped
| Code | Plan | Size | Effort accuracy | Notes |
|------|------|------|-----------------|-------|
| {T..} | {title} | {S/M/L} | {estimated vs actual} | {one line} |

### Carry-Forward
| Code | Why not done | New size | Next sprint? |
|------|--------------|----------|--------------|
| {T..} | {reason} | {size} | {Y/N} |

### Metrics: Before → After
- Hot spots (>CCN 15): {X} → {Y}
- Files >400 lines: {X} → {Y}
- Test count: {X} → {Y}
- Lint warnings: {X} → {Y}
- Capacity: committed {pts} / delivered {pts} = {accuracy %}

### Retro: Keep / Drop / Try
- **Keep** (worked, do again): {…}
- **Drop** (hurt, stop): {…}
- **Try** (next sprint experiment): {…}

### Lessons for the Wiki / Knowledge Capture
{Any durable insight worth promoting via @knowledge-capture. Reference KC numbers if recorded.}

### New Refactoring Items (→ REFACTORING.md)
{List files flagged by the close-of-sprint scan. Confirm they were added to the Kill List.}
```

## 5. Archive the Sprint Record

A closed sprint is a historical record: move the whole sprint folder to the archive.

1. `git mv .devops/sprints/sprint-{n}-<slug>/sprint.md .devops/archive/sprints/sprint-{n}-<slug>/sprint.md` (create the target folder).
2. Shipped plans are **not** moved here — they already archived to `.devops/archive/` root individually at wrap-up (see `.devops/rules/plan-lifecycle.md` rule 6). They are linked to the sprint by the `sprint:` front-matter field.
3. Remove the now-empty `.devops/sprints/sprint-{n}-<slug>/` directory.

## 6. Update the Registers

- In `SPRINTS.md`: change the sprint row status to `✅ CLOSED` and set the retro link to the archived `sprint.md` (`.devops/archive/sprints/sprint-{n}-<slug>/sprint.md#retro`). Update `last_sprint`.
- Ensure REFACTORING.md reflects the scan results (Step 2).
- Do NOT auto-open the next sprint. Tell the user the current one is closed and they can run `@sprint-plan` when ready, carrying forward the "capacity accuracy" line so the next plan suggests a better budget.

## 7. Hand Off

Summarise: goal met?, what carried forward, top refactoring flags, and the calibrated capacity number for next time. Point the user to `@sprint-plan` to open the next cycle.
