<!--
type: template
version: 1
updated: 2026-09-13

sprint.template.md — seed for a single sprint record.
The @sprint-plan skill writes this to
.devops/sprints/sprint-{n}-<slug>/sprint.md when a sprint opens.
The @sprint-close skill appends the Retro section and flips status to "closed".
One file, open → close → retro. There is no separate retro.md.
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
