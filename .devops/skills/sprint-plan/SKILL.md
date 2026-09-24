---
name: sprint-plan
description: Make sure to use this skill whenever the user mentions sprint planning, starting a sprint, "what's our next sprint", /sprint-plan, committing scope, scoping a development cycle, or wants to pull triaged backlog items into a time-boxed batch of plans. Reads the backlog Triage Panel + REFACTORING.md Kill List, confirms capacity with the user, writes .devops/sprints/sprint-{n}-<slug>/sprint.md, moves committed plans into that folder as the sprint queue, and registers the row in SPRINTS.md. This skill PLANS a sprint — it does NOT execute parcels (that is @pass-the-parcel) or close them (@sprint-close).
version: 10
updated: 2026-09-25
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

### 4b. Wave preflight — mutual `touches` overlap (mandatory, before the sprint is registered)

Test the candidate set **against itself**, not only against the plans already in `.devops/plans/`. The predicate is canonical in `.devops/rules/plan-lifecycle.md` § Claim Protocol → *Write-Set Overlap Predicate* — the same definition `@sprint-run` § 2 re-evaluates immediately before each claim. **Cite it; do not restate it in a second dialect, and never relax it to make the queue look batchable.**

1. Take the candidates in intended queue order (the order they will appear in § 5's Committed Scope table).
2. **Run the predicate, do not hand-derive it.** Once § 6 has moved the plans into the sprint folder, run:
   `python scripts/sprint_eligible.py --sprint-dir .devops/sprints/sprint-{n}-<slug>`
   It is the predicate's executable embodiment and it is authoritative for `@sprint-run` § 2, so its output **is** the preflight answer — a hand-walk is a second dialect that drifts. `--sprint-dir` exists for exactly this window: it reads the queue before the sprint is ACTIVE. **A non-zero exit is a stop** — fix the plan file it names; never re-derive the predicate by hand.
3. **Record the snapshot in `sprint.md` § Delivery Model** — the script's `claim_order` and `skipped`, verbatim, labelled a **forecast**. Never present it as the schedule, and never record a wave count derived by hand.
4. **State the accepted cost in that same section, explicitly:** every wave means **one Gate D verdict and one wrap-up**, not one consolidated verdict — an executed plan stays in `.devops/plans/` at `claim_status: GATE_D_USER_APPROVAL` until its verdict plus wrap-up archives it, and it keeps blocking its overlaps until then. The number of waves is whatever the live predicate produces, not a number this section predicts.
5. If the snapshot shows a set that will not batch, fix it **here, while it is still cheap** — trim the set, reorder it, or split a plan's `touches` off the shared surface. The moves are reversible `git mv`s and § 7 has not registered the sprint yet. Do not commit on a promise of one batch pass. A queue that cannot batch itself is a planning fact, not a run-time surprise.

### 4c. Multi-worthy triage flag (mandatory, at commit)

Scoring a candidate's complexity is part of committing it. Run this in the same pass as § 4b:

1. **Score the canonical five signals** — blast radius, contract change, risk & reversibility, ambiguity, novelty. The table, its low/high bounds, and the "all low → `SINGLE`; any high → `MULTI`" rule live in `@pass-the-parcel` § Agent Topology → *Complexity Triage*: **cite them; never restate a second dialect here.** The recommendation is one of **three** values — `MULTI` / `SINGLE` / `MICRO` — where `MICRO` is the all-five-signals-low case that also stays inside the *Complexity Triage* LOW bound: its bounds, gate set and collapsed rendering are canonical in `.devops/rules/plan-lifecycle.md` § *Micro Lane* (cite it, never restate it).
2. **Record the recommendation in `sprint.md`** § Delivery Model — the `Flag` column (`MULTI` / `—`) plus the names of the signals that fired.
3. **Write it into the plan's claim front-matter** as `triage: MULTI`, `triage: SINGLE` or `triage: MICRO` (§ 6 step 2 does this on the moved file). It is a **recommendation**, not the plan's frozen `Plan Settings` `Agents` row — that row is written at plan start and is what the pipeline obeys. The manual path reads `triage` as the recommendation to confirm.
4. **Say what the flag buys.** A `MULTI` flag on a plan committed to a `@sprint-run` batch means the batch **cannot honour it** — its preset is locked `AUTO` + `SINGLE` — so the plan is presented for an **accept batch risk / defer to manual** fork before the first claim (`@sprint-run` § 1, `.devops/rules/plan-lifecycle.md` § Claim Protocol → *MULTI-worthy Yield*). Flag honestly: an under-scored plan is still caught by the mechanical backstop (`scripts/sprint_eligible.py`'s `complexity` key — a plan declaring more than 3 `touches`), but the *reason* is lost.
5. **`MICRO` is never a sprint-queue value.** A micro-eligible item is the **between-sprint** change path (`.devops/rules/plan-lifecycle.md` § *Micro Lane*) — record the `MICRO` recommendation on the parked plan and leave it out of the Committed Scope table. Committing one would make the batch run it as the full `SINGLE` parcel it already is, paying exactly the ceremony `MICRO` exists to avoid.

## 5. Write sprint.md

Create `.devops/sprints/sprint-{n}-<slug>/sprint.md` from the canonical seed at [`.devops/templates/sprint.template.md`](../../templates/sprint.template.md). Read that file before writing a sprint record — it is the single home of the record's shape; do not copy or restate it here. Fill every placeholder. The out-of-scope section is mandatory — it is what prevents mid-sprint scope creep. The Committed Scope table is the **queue**: it lists what is committed, and each row links to the plan file that now lives in this folder.

**Chunked write (mandatory):** `sprint.md` is large — do NOT send it in one `write`. Create it with a small skeleton `write` (frontmatter + the `##`/`###` section headings, each with a unique placeholder such as `<!-- FILL:goal -->`), then fill each placeholder with its own small `edit`. Cap each call at ~60–100 lines; split a long section with sub-placeholders if needed. `write` overwrites, so never re-issue the whole file — after a stall, `read` what landed and continue with the next section. See AGENTS.md, Chunked Write Discipline.

## 6. Move Committed Plans into the Queue

For each committed item:

1. `git mv` its parked plan from `.devops/backlog/<code>-<slug>-backlog.md` (legacy: `.devops/backlog/<slug>-backlog.md`) to `.devops/sprints/sprint-{n}-<slug>/{code}-{slug}-plan.md` — the move is the signal that it is committed.
2. Add/replace the claim front-matter at the top of the moved file (`code`, `sprint: sprint-{n}-<slug>`, `claim_status: QUEUED`, `touches`, `depends_on`, `triage` from § 4c). Leave `owner` / `claimed_at` / `last_touch` empty until claimed. See `.devops/rules/plan-lifecycle.md` § Claim Front-Matter.
3. **Draft the user story (stories).** For each committed plan, write one or more short user stories into the moved plan's front-matter as a `stories:` row — the "as the owner/user, I…" framing that what the plan delivers means to the person who owns it. Where the plan already carries acceptance criteria, derive the story from them (the criteria say what will be verifiable; the story says who it is for and why); otherwise draft it from the operator's intent line in the plan body. One story per line of the list; leave the row off only when the plan is pure machinery with no owner effect — a skipped story is a silent one, so record the reason in the plan body instead. **Then assert the legal state before this step closes:** every moved plan carries a `stories:` row **or** a `Story skip — rationale:` line in its body — a plan with neither is not committed. Presence is what is asserted; the reason's merits are the operator's to judge.
4. Remove the item from the Triage Panel in `backlog-index.md` (it is tracked by the sprint now).
5. **Record the predicate snapshot.** Now that the plans exist in this folder, run the § 4b step 2 command and paste its `claim_order` and `skipped` into `sprint.md` § Delivery Model, labelled a **forecast**. The sprint record is not complete without it, and § 4b step 5's trim/reorder call is made on it — the moves are reversible `git mv`s and § 7 has not registered the sprint yet.

> **Queue order is the first claim order, not an execution dependency.** Record the rows in the order you intend the runner to try them. `@sprint-run` evaluates eligibility immediately before **each** claim and iterates to a fixpoint (`.devops/skills/sprint-run/SKILL.md` § 2), so a plan listed *above* the dependency it needs is still reached once that dependency is satisfied — by archive (`claim_status: COMPLETE`) or by `GATE_D_USER_APPROVAL` (executed to `PHASE_9`, Gate D `OPEN`). Do **not** topologically sort the queue; state the intent and let the runner resolve it.
>
> **Mutual `touches` overlap serialises a queue — the predicate measures it in § 4b; the snapshot records it here.** Plans committed together whose `touches` overlap are admitted one at a time, so the sprint needs sequential waves rather than one batch pass. The § 4b snapshot records the predicate's own answer at commit time (`sprint.md` § Delivery Model) — a **forecast**, never a schedule; the live predicate at claim time is the contract (`.devops/rules/plan-lifecycle.md` § Claim Protocol).

If a committed item has no plan file yet, tell the user to create it with `@backlog` first — do not hand-write an empty plan.

## 7. Register in SPRINTS.md

Add a row to the Sprint Index table in `.devops/backlog/SPRINTS.md`: number, name, goal, status `🟢 ACTIVE`, sprint link `.devops/sprints/sprint-{n}-<slug>/sprint.md`, retro link `—`. Update `last_sprint`.

## 8. Hand Off

Tell the user the sprint is committed and how to start executing: the queue lives in the sprint folder; claim the next eligible plan per the Claim Protocol and run `@pass-the-parcel` on it. Remind them that completing all plans triggers `@sprint-close`.
