<!--
type: template
version: 5
updated: 2026-09-30

sprint.template.md — the CANONICAL seed for a single sprint record.
The @sprint-plan skill writes this to
.devops/sprints/sprint-{n}-<slug>/sprint.md when a sprint opens, and cites this
file as the single home of the record's shape (the skill carries no inline copy).
The @sprint-close skill appends the Retro section and flips status to "closed".
One file, open → close → retro. There is no separate retro.md.
At close, @sprint-close also writes sprint-report.md into the sprint folder
(a plain-language report for business stakeholders) and walks the operator
through user-testing.md (the sprint's manual tests, one-by-one) so both
artefacts are carried by the archive move; neither is present while the
sprint is open.
-->
---
type: "sprint"
sprint: 0
name: "{Sprint Name}"
slug: "{kebab-slug}"
status: "open"
capacity_points: 0
created: "{YYYY-MM-DD}"
closed: ""
---

# Sprint {n}: {Sprint Name}

## Goal
{One sentence: what will be true at the end of this sprint that isn't now.}

## Capacity
- Budget: {points} pts ({Small/Standard/Large})
- Committed: {points} pts across {count} plans
- Buffer: {remaining} pts held for spillover / discovery

## Committed Scope (queue)
| # | Code | Plan | Size | Source tier | Link |
|---|------|------|------|-------------|------|
| 1 | {T..} | {title} | {S/M/L} | 🔴 NOW | [{code}-{slug}-plan.md]({code}-{slug}-plan.md) |

## Delivery Model

The § 4c triage flags for the committed set, plus the eligibility predicate's own recorded output. **Never a hand-derived wave count.**

| Code | Size | Flag | Signals that fired |
|------|------|------|--------------------|
| {T..} | {S/M/L} | {`MULTI` / `—`} | {the signals that fired, or `none — all five low`} |

> **`Flag`** is the § 4c triage recommendation for that plan (`MULTI` / `—`), with the signals that fired named in the row. A `MULTI` row in a `@sprint-run` batch is surfaced as an **accept batch risk / defer to manual** fork before the first claim (`@sprint-run` § 1) — the batch's locked `AUTO` + `SINGLE` preset cannot honour the recommendation.

**Predicate snapshot** — recorded at commit time, once the committed plans are in this folder and before the sprint is registered in `SPRINTS.md`:

`python scripts/sprint_eligible.py --sprint-dir .devops/sprints/sprint-{n}-<slug>`

- `claim_order`: {the script's `claim_order` array, verbatim}
- `skipped`: {the script's `skipped` rows, verbatim}

> **Forecast, never a schedule:** the snapshot is exact at the moment it is taken and stale the moment the first claim lands. `@sprint-run` § 2 re-evaluates the predicate against the live `.devops/plans/` immediately before **each** claim, so the executed set may differ. A non-zero exit from the command above is a **stop** — fix the plan file it names; never re-derive the predicate by hand.

**Accepted cost:** one Gate D verdict and one wrap-up per wave — not one consolidated verdict; a committed plan holds its files from claim until its wrap-up archives it, and the number of waves is whatever the live predicate produces.

## Explicitly Out of Scope
{List the tempting-but-not-now items, each with a one-line reason. This is the anti-scope-creep contract.}

## Definition of Done (sprint-level)
- [ ] All committed parcel plans reach COMPLETE and are archived
- [ ] Full test suite green, lint clean, build exit 0
- [ ] Sprint closed via @sprint-close (retro appended to this file + spaghetti scan run)

## Risks / Unknowns
{Anything that could blow up a plan's estimate this sprint.}

## Retro
*Appended by `@sprint-close` when the sprint closes. Left empty while the sprint is open.*

### Goal — Met?
{Restate the goal. Yes / Partially / No, with one-line why.}

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
