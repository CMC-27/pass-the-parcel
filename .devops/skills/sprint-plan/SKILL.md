---
name: sprint-plan
description: Make sure to use this skill whenever the user mentions sprint planning, starting a sprint, "what's our next sprint", /sprint-plan, committing scope, scoping a development cycle, or wants to pull triaged backlog items into a time-boxed batch of plans. Reads the backlog Triage Panel + REFACTORING.md Kill List, confirms capacity with the user, writes .devops/sprints/sprint-{n}-<slug>/sprint.md, moves committed plans into that folder as the sprint queue, and registers the row in SPRINTS.md. This skill PLANS a sprint — it does NOT execute parcels (that is @pass-the-parcel) or close them (@sprint-close).
version: 5
updated: 2026-09-16
---

# Sprint Planning

> **Boundary:** This skill scopes and commits a sprint. It produces `.devops/sprints/sprint-{n}-<slug>/sprint.md` plus the committed plan files in that folder, and registers the sprint in `SPRINTS.md`. It does not run parcels, write code, or close sprints. Execution happens later via `@pass-the-parcel`, one claimed plan at a time.

## Prerequisites — Read First

1. `.devops/backlog/SPRINTS.md` — confirm no other sprint is currently ACTIVE (one active sprint rule). If one is open, STOP and tell the user to close it with `@sprint-close` first.
2. `.devops/backlog/backlog-index.md` — the 🎯 Triage Panel (🔴 NOW / 🟡 NEXT / 🟢 LATER tiers) and the Themes table linking the `t{n}-<slug>-backlog.md` registers.
3. `.devops/backlog/REFACTORING.md` — the Current Scan Results / Kill List (only if refactoring is in scope). The refactoring lane is **opt-in per repo**: if the register is absent, the Kill List source is empty — do not create it implicitly, and offer refactoring only as a spare-capacity/stabilisation choice a user explicitly asks for.
4. Last 3 entries of `.devops/logs/agent-changelog.md` — establish current project state.

## 1. Determine Sprint Number & Name

- Next number = highest existing `.devops/sprints/sprint-{n}-*` folder + 1 (or 1 if none). The integer is kept for tooling; the slug carries the theme.
- Propose a short human slug from the dominant theme of the items being pulled (e.g. `stabilise-and-clean`, `import-hardening`). The folder becomes `sprint-{n}-<slug>`. Confirm with the user.

## 2. Establish Capacity (question tool)

Ask the user for the sprint's capacity budget in effort points using the `question` tool. Offer calibrated defaults:

- **Small** (~5 pts) — a focused week, few plans
- **Standard** (~8-10 pts) — typical cycle
- **Large** (~13+ pts) — big push / stabilisation sprint

If this is sprint 1, note that capacity is uncalibrated and recommend starting conservative. Future sprints read the last `sprint.md` retro's "capacity accuracy" line to suggest a number.

## 3. Pull Candidate Scope

Present candidates grouped by source, each with its point size (estimate S=1/M=3/L=5/XL=8):

| Source | Rule |
|--------|------|
| 🔴 NOW items | Always offered first. Cannot be deferred without an explicit user ruling recorded in `sprint.md`. |
| 🟡 NEXT items | Offered next. These are the default body of a normal sprint. |
| Carry-forward | From the previous `sprint.md` retro's carry-forward list, if any. |
| 🟢 LATER / Kill List | Offered ONLY if capacity remains, or if the user declares this a stabilisation sprint. The Kill List half of this row exists only where `.devops/backlog/REFACTORING.md` has been adopted (see Prerequisites 3) — where it has not, the refactoring lane is dormant by design and there is nothing to pull. |

Let the user select which candidates commit (multi-select). Respect the capacity budget — warn if selected points exceed it and ask whether to trim or expand.

## 4. Apply the Boundary Check (scope **and** write-set)

### 4a. Feature vs refactoring

For every candidate, confirm it belongs in a *feature* sprint vs *refactoring*:
- Changes user-visible behavior → feature sprint (this skill).
- Only changes internal structure → REFACTORING.md; include only as spare-capacity/stabilisation work.

Flag any misfiled item and ask the user before committing it.

### 4b. Wave preflight — mutual `touches` overlap (mandatory, before anything moves)

Test the candidate set **against itself**, not only against the plans already in `.devops/plans/`. Use the canonical **Write-Set Overlap Predicate** in `.devops/rules/plan-lifecycle.md` § Claim Protocol — the same definition `@sprint-run` § 2 re-evaluates immediately before each claim. Cite it; do not restate it in a second dialect, and never relax it to make the queue look batchable.

1. Take the candidates in intended queue order (the order they will appear in § 5's Committed Scope table).
2. **Simulate the claim fixpoint.** Walk the set in order; a plan is claimable on a pass only if its `touches` overlap **neither** a plan already in `.devops/plans/` **nor** a plan claimed on an earlier pass. Claim the first claimable plan and continue the walk; when the walk ends, start a new pass over the still-unclaimed set. Repeat until nothing is claimable. This mirrors `@sprint-run` § 2 exactly — a prediction of it, never a replacement.
3. **Each pass is one wave.** Record the decomposition in `sprint.md` § Delivery Model: wave number, code, size.
4. **State the accepted cost in that same section, explicitly:** N waves means **N Gate D verdicts and N wrap-ups**, not one consolidated verdict — an executed plan stays in `.devops/plans/` at `claim_status: GATE_D_USER_APPROVAL` until its verdict plus wrap-up archives it, and it keeps blocking its overlaps until then.
5. If the wave count is unacceptable, fix it **here, while it is still cheap** — trim the set, reorder it, or split a plan's `touches` off the shared surface. Do not commit on a promise of one batch pass. A queue that cannot batch itself is a planning fact, not a run-time surprise.

## 5. Write sprint.md

Create `.devops/sprints/sprint-{n}-<slug>/sprint.md` from the template below. Fill every placeholder. The out-of-scope section is mandatory — it is what prevents mid-sprint scope creep. The Committed Scope table is the **queue**: it lists what is committed, and each row links to the plan file that now lives in this folder.

**Chunked write (mandatory):** `sprint.md` is large — do NOT send it in one `write`. Create it with a small skeleton `write` (frontmatter + the `##`/`###` section headings, each with a unique placeholder such as `<!-- FILL:goal -->`), then fill each placeholder with its own small `edit`. Cap each call at ~60–100 lines; split a long section with sub-placeholders if needed. `write` overwrites, so never re-issue the whole file — after a stall, `read` what landed and continue with the next section. See AGENTS.md, Chunked Write Discipline.

### Template: `.devops/sprints/sprint-{n}-<slug>/sprint.md`

```markdown
---
type: "sprint"
sprint: {n}
name: "{Sprint Name}"
slug: "{kebab-slug}"
status: "open"
capacity_points: {total}
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
{Wave decomposition predicted by the § 4b preflight — one row per wave. Write a single wave / "one batch pass" only when the set is mutually disjoint.}

| Wave | Plan | Size | Steps |
|------|------|------|-------|
| 1 | {T..} | {S/M/L} | preview → claim → spawn `ptp-parcel-fast` → `PHASE_9` → verdict + wrap-up |

**Accepted cost:** {N} serial waves = {N} Gate D verdicts and {N} wrap-ups — not one consolidated verdict; a committed plan holds its files from claim until its wrap-up archives it.

## Explicitly Out of Scope
{List the tempting-but-not-now items, each with a one-line reason. This is the anti-scope-creep contract.}

## Definition of Done (sprint-level)
- [ ] All committed parcel plans reach COMPLETE and are archived
- [ ] Full test suite green, lint clean, build exit 0
- [ ] Sprint closed via @sprint-close (retro appended to this file + spaghetti scan run)

## Risks / Unknowns
{Anything that could blow up a plan's estimate this sprint.}
```

## 6. Move Committed Plans into the Queue

For each committed item:

1. `git mv` its parked plan from `.devops/backlog/<code>-<slug>-backlog.md` (legacy: `.devops/backlog/<slug>-backlog.md`) to `.devops/sprints/sprint-{n}-<slug>/{code}-{slug}-plan.md` — the move is the signal that it is committed.
2. Add/replace the claim front-matter at the top of the moved file (`code`, `sprint: sprint-{n}-<slug>`, `claim_status: QUEUED`, `touches`, `depends_on`). Leave `owner` / `claimed_at` / `last_touch` empty until claimed. See `.devops/rules/plan-lifecycle.md` § Claim Front-Matter.
3. Remove the item from the Triage Panel in `backlog-index.md` (it is tracked by the sprint now).

> **Queue order is the first claim order, not an execution dependency.** Record the rows in the order you intend the runner to try them. `@sprint-run` evaluates eligibility immediately before **each** claim and iterates to a fixpoint (`.devops/skills/sprint-run/SKILL.md` § 2), so a plan listed *above* the dependency it needs is still reached once that dependency is satisfied — by archive (`claim_status: COMPLETE`) or by `GATE_D_USER_APPROVAL` (executed to `PHASE_9`, Gate D `OPEN`). Do **not** topologically sort the queue; state the intent and let the runner resolve it.
>
> **Mutual `touches` overlap serialises a queue — measure it in § 4b, then say so here.** Plans committed together whose `touches` overlap are admitted one at a time, so the sprint needs N sequential waves rather than one batch pass. The § 4b preflight predicts N at commit time (recorded in `sprint.md` § Delivery Model) using the canonical predicate in `.devops/rules/plan-lifecycle.md` § Claim Protocol.

If a committed item has no plan file yet, tell the user to create it with `@backlog` first — do not hand-write an empty plan.

## 7. Register in SPRINTS.md

Add a row to the Sprint Index table in `.devops/backlog/SPRINTS.md`: number, name, goal, status `🟢 ACTIVE`, sprint link `.devops/sprints/sprint-{n}-<slug>/sprint.md`, retro link `—`. Update `last_sprint`.

## 8. Hand Off

Tell the user the sprint is committed and how to start executing: the queue lives in the sprint folder; claim the next eligible plan per the Claim Protocol and run `@pass-the-parcel` on it. Remind them that completing all plans triggers `@sprint-close`.
