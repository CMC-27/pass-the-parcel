---
name: sprint-plan
description: Make sure to use this skill whenever the user mentions sprint planning, starting a sprint, "what's our next sprint", /sprint-plan, committing scope, scoping a development cycle, or wants to pull triaged backlog items into a time-boxed batch of plans. Reads the backlog Triage Panel + REFACTORING.md Kill List, confirms capacity with the user, and creates sprints/sprint-{n}/plan.md plus a SPRINTS.md row. This skill PLANS a sprint — it does NOT execute parcels (that is @pass-the-parcel) or close them (@sprint-close).
version: 1
updated: 2026-09-09
---

# Sprint Planning

> **Boundary:** This skill scopes and commits a sprint. It produces `sprints/sprint-{n}/plan.md` and registers it in `SPRINTS.md`. It does not run parcels, write code, or close sprints. Execution happens later via `@pass-the-parcel`, one plan at a time.

## Prerequisites — Read First

1. `.devops/backlog/SPRINTS.md` — confirm no other sprint is currently ACTIVE (one active sprint rule). If one is open, STOP and tell the user to close it with `@sprint-close` first.
2. `.devops/backlog/backlog-index.md` — the 🎯 Triage Panel (🔴 NOW / 🟡 NEXT / 🟢 LATER tiers).
3. `.devops/backlog/REFACTORING.md` — the Current Scan Results / Kill List (only if refactoring is in scope).
4. Last 3 entries of `.devops/logs/agent-changelog.md` — establish current project state.

## 1. Determine Sprint Number & Name

- Next number = highest existing `sprint-{n}` folder + 1 (or 1 if none).
- Propose a short human name from the dominant theme of the items being pulled (e.g. "Stabilise & Clean the Deck", "Import Hardening"). Confirm with the user.

## 2. Establish Capacity (question tool)

Ask the user for the sprint's capacity budget in effort points using `vscode_askQuestions`. Offer calibrated defaults:

- **Small** (~5 pts) — a focused week, few plans
- **Standard** (~8-10 pts) — typical cycle
- **Large** (~13+ pts) — big push / stabilisation sprint

If this is sprint 1, note that capacity is uncalibrated and recommend starting conservative. Future sprints read the last retro's "capacity accuracy" line to suggest a number.

## 3. Pull Candidate Scope

Present candidates grouped by source, each with its point size (estimate S=1/M=3/L=5/XL=8):

| Source | Rule |
|--------|------|
| 🔴 NOW items | Always offered first. Cannot be deferred without an explicit user ruling recorded in the plan. |
| 🟡 NEXT items | Offered next. These are the default body of a normal sprint. |
| Carry-forward | From previous retro's carry-forward list, if any. |
| 🟢 LATER / Kill List | Offered ONLY if capacity remains, or if the user declares this a stabilisation sprint. |

Let the user select which candidates commit (multi-select). Respect the capacity budget — warn if selected points exceed it and ask whether to trim or expand.

## 4. Apply the Boundary Check

For every candidate, confirm it belongs in a *feature* sprint vs *refactoring*:
- Changes user-visible behavior → feature sprint (this skill).
- Only changes internal structure → REFACTORING.md; include only as spare-capacity/stabilisation work.

Flag any misfiled item and ask the user before committing it.

## 5. Write the Sprint Plan

Create `.devops/backlog/sprints/sprint-{n}/plan.md` from the template below. Fill every placeholder. The out-of-scope section is mandatory — it is what prevents mid-sprint scope creep.

### Template: `sprints/sprint-{n}/plan.md`

```markdown
---
type: "sprint-plan"
sprint: {n}
name: "{Sprint Name}"
status: "committed"
capacity_points: {total}
created: "{YYYY-MM-DD}"
---
# Sprint {n}: {Sprint Name}

## Goal
{One sentence: what will be true at the end of this sprint that isn't now.}

## Capacity
- Budget: {points} pts ({Small/Standard/Large})
- Committed: {points} pts across {count} plans
- Buffer: {remaining} pts held for spillover / discovery

## Committed Scope
| # | Code | Plan | Size | Source tier | Link |
|---|------|------|------|-------------|------|
| 1 | {T..} | {title} | {S/M/L} | 🔴 NOW | [plan]({path}) |

## Explicitly Out of Scope
{List the tempting-but-not-now items, each with a one-line reason. This is the anti-scope-creep contract.}

## Definition of Done (sprint-level)
- [ ] All committed parcel plans reach COMPLETE and are archived
- [ ] Full test suite green, lint clean, build exit 0
- [ ] Sprint closed via @sprint-close (retro written + spaghetti scan run)

## Risks / Unknowns
{Anything that could blow up a plan's estimate this sprint.}
```

## 6. Register in SPRINTS.md

Add a row to the Sprint Index table in `SPRINTS.md`: number, name, goal, plan codes, status `🟢 ACTIVE`, retro link `—`. Update `last_sprint` frontmatter.

## 7. Hand Off

Tell the user the sprint is committed and how to start executing: pick the first plan from the Committed Scope table and run `@pass-the-parcel` on it. Remind them that completing all plans triggers `@sprint-close`.
