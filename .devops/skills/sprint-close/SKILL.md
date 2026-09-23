---
name: sprint-close
description: 'Make sure to use this skill whenever the user mentions closing a sprint, ending a sprint, sprint retrospective, "we finished the sprint", /sprint-close, wrap up the cycle, or when all committed parcel plans in the active sprint reach COMPLETE. Runs the end-of-sprint ritual: appends the retro into the single sprint.md, triggers a spaghetti-monster scan of everything touched this sprint to refresh REFACTORING.md, captures lessons, walks the operator one-by-one through the sprint''s manual user tests (user-testing.md), writes the business report, moves the sprint.md to .devops/archive/sprints/sprint-{n}-<slug>/, and updates SPRINTS.md. This skill CLOSES a sprint — it does not plan one (@sprint-plan) or execute parcels (@pass-the-parcel).'
version: 10
updated: 2026-09-23
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
- **A plan in `.devops/plans/` with `claim_status: GATE_D_USER_APPROVAL` is NOT complete.** It has been executed to `PHASE_9` but the Gate D verdict has not been recorded and the per-plan wrap-up has not archived it — closing over it would retire a sprint containing an unapproved plan. Treat it as unfinished: either get the Gate D verdict and run its wrap-up first, or record it as **carry-forward** in the retro (Section 4) alongside the plans still in the queue.
- If any plan is unfinished, do NOT silently drop it — record it as **carry-forward** in the retro (Section 4). A sprint can close with carry-forward; it just means capacity was over-committed. Unfinished plans still in the sprint queue stay parked for the next planning pass (move them back with `git mv` to `.devops/backlog/<code>-<slug>-backlog.md` and reset `claim_status: QUEUED`); an executed-but-unverified plan stays in `.devops/plans/` at `GATE_D_USER_APPROVAL` until its verdict lands.

Confirm the sprint-level Definition of Done from `sprint.md`: full suite green, lint clean, build exit 0. Run them if not already verified this session.

## 2. Run the Spaghetti Scan (the hygiene step)

This is the process trigger that keeps refactoring out of the feature backlog:

1. Determine the set of files touched this sprint (from changelog entries + `git diff --name-only {baseline}`).
2. Invoke `@spaghetti-monster` scoped to those touched areas (or run `scripts/spaghetti-monster-scan.cjs` directly for a quick metric pass).
3. For any file now crossing a threshold (CCN>15 warn / >25 critical, >400 lines, etc. per `.devops/backlog/REFACTORING.md` § Thresholds), add it to the REFACTORING.md Kill List with a note: *"Flagged at close of sprint {n} by {file change}."*
4. Update REFACTORING.md's "Completed Refactors" table for anything this sprint cleaned up.

**Scan scope — app source *and* machinery.** `scripts/spaghetti-monster-scan.cjs` walks `src/` (the app surface) **plus** the machinery roots `scripts/`, `.devops/skills/`, `.devops/agents/`, `.devops/templates/`, under the same thresholds. A missing root prints a one-line skip and exits `0` — never a crash, and never a silent skip. Rows whose `imp`/`fn`/`CCN` columns show `-` are non-ECMAScript files (`.ps1`/`.py`/`.md`): they are ranked on **line count only**, which is the load-bearing signal for the machinery pass. Read `-` as "not measured", never as "clean".

**The refactoring lane is opt-in per repo.** Step 3's promotion — and § 8's "Ensure REFACTORING.md reflects the scan results" — need `.devops/backlog/REFACTORING.md` to exist (adopted from `.devops/templates/REFACTORING.template.md`). If it does **not** exist, do not create it implicitly: run the scan anyway and write its findings into the retro's **New Refactoring Items** section, stating plainly that the register is absent, so the lane is dormant and the flags have nowhere to land. A skipped promotion is a *recorded* decision — never a silent one.

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
{Any durable insight worth promoting via @knowledge-capture — app-domain to `.wiki/core/18-knowledge-capture.md`, machinery/process/tooling to `.devops/rules/process-lessons.md`. Reference KC numbers if recorded.}

### New Refactoring Items (→ REFACTORING.md)
{List files flagged by the close-of-sprint scan. Confirm they were added to the Kill List.}
```

## 5. Run the User Acceptance Walk

Per-plan Gate D verified the parcels; this step verifies the **sprint** in the operator's hands — acceptance, not verification (they are different questions: Gate D proves the implementation passed its battery; this step asks whether the delivered outcomes actually behave as promised for the person who owns them). The walk is the close ritual's one interactive step.

1. **Scope.** Run the walk only on plans at `claim_status: COMPLETE` — a `GATE_D_USER_APPROVAL` plan is still unapproved (§1) and its tests are not yet trustworthy; carry-forward plans contribute nothing. A plan whose Gate D sign-off recorded a failed manual check contributes that failure to the queue.
2. **Build the queue.** From each executed plan's acceptance criteria plus its Phase 10 tweak notes — the same sources Gate D sign-off reads — consolidate a sprint-wide testing menu, grouped per outcome/theme, never per parcel code. Where a plan's acceptance criteria trace to user stories (see `@sprint-plan`'s commit-time story drafting), the story is what the test presents first: take it from the plan's `stories:` front-matter row; a plan without the row falls back to the criteria as before.
3. **Walk it one-by-one.** Present each test with the ask-questions tool: what to do, what to expect; the operator answers pass / fail / blocked (a blocked test is recorded, not retried — it is dispositioned with the other failures in §8). Follow the exact interaction shape of [q-and-a](../q-and-a/SKILL.md) and [true-or-false](../true-or-false/SKILL.md) — one call per question where the ask surface is single-question, one batched call where it accepts an array; the final "all tests walked" confirmation is always asked on its own (batched-clarification pattern, T1-E3.08). Do not restate those skills' rules here — cite and follow them.
4. **Record it.** Write `user-testing.md` into the sprint folder (`.devops/sprints/sprint-{n}-<slug>/`) as you walk — one row per test (theme, what was tested, verdict, operator note), followed by a short plain-language summary. Update after each answer, per the just-in-time loop of the pattern skills. The file is sprint-folder debris, not a plan.
5. **Session-end discipline.** If the session ends before every test is walked, keep exactly what was answered: completed rows stay recorded, unanswered rows stay open and are marked in the summary — never a silent skip, never a re-ask of answered tests.
6. **Skip discipline.** If the walk is skipped entirely (no testable criteria, operator unavailable), the retro records why - never a silent skip, same rule as the business report's. An empty queue still writes a zero-test `user-testing.md` - an empty artifact, not silence.

## 6. Write the Business Report

Before archiving (§7), write a plain-language business report for business stakeholders: the people the sprint served, not the dev team. This is the one close-ritual output that speaks to users, sponsors, and practitioners outside the pipeline.

1. **Where and when.** Write `business-report.md` into the sprint folder (`.devops/sprints/sprint-{n}-<slug>/`) BEFORE the §7 archive move, so the same move carries it into `.devops/archive/sprints/sprint-{n}-<slug>/` automatically. The report is sprint-folder debris, not a plan: no plan-lifecycle rule applies to it.
2. **Audience and grouping.** Business users and practitioners, never developers. Group the report per outcome/epic/theme - never per parcel code. A stakeholder must be able to read it with zero pipeline knowledge.
3. **Reusable outline.** Fill every section; skip nothing silently:

   ```markdown
   # Sprint {n} ({Name}): Business Report

   ## What this sprint set out to do
   {One sentence: the sprint goal in plain language.}

   ## What was delivered
   {Per theme/epic: what changed and who benefits. No parcel codes.}

   ## Wins
   {2-4 concrete improvements, stated as benefits.}

   ## Quality
   {One short paragraph: delivered totals, test counts, capacity accuracy - the trust-building numbers only. No machinery thresholds. Credit the user-acceptance walk here: which outcomes passed the operator's own testing.}

   ## Open items for the owner
   {Non-development actions the operator still owns, each with its ask. Failed or blocked user-acceptance tests surface here as concrete asks.}

   ## What's next
   {Where the work goes next; link the sprint record and retro.}
   ```

4. **Tone rules.** Benefit language throughout. Only trust-building numbers: delivered totals, test counts, capacity percentage. Machinery thresholds and machinery vocabulary - parcel, Gate D, Kill List, spaghetti scan - stay out of the report entirely.
5. **Show-and-tell before archiving.** Present the report to the operator and get a nod before §7 moves the folder; §8 then links it from the sprint's register row. If the report is skipped, the retro records why - never a silent skip.

## 7. Archive the Sprint Record

A closed sprint is a historical record: move the whole sprint folder to the archive.

1. `git mv .devops/sprints/sprint-{n}-<slug>/sprint.md .devops/archive/sprints/sprint-{n}-<slug>/sprint.md` (create the target folder).
2. Move §5's `business-report.md` alongside it: `git mv .devops/sprints/sprint-{n}-<slug>/business-report.md .devops/archive/sprints/sprint-{n}-<slug>/business-report.md`. If the report was skipped, the retro records why (Step 5) - never a silent skip.
3. Move §5's `user-testing.md` alongside them the same way: `git mv .devops/sprints/sprint-{n}-<slug>/user-testing.md .devops/archive/sprints/sprint-{n}-<slug>/user-testing.md`. If the walk never ran, the retro records why (Step 5) - never a silent skip — same rule as the report's.
4. Shipped plans are **not** moved here — they already archived to `.devops/archive/` root individually at wrap-up (see `.devops/rules/plan-lifecycle.md` rule 6). They are linked to the sprint by the `sprint:` front-matter field.
5. Remove the now-empty `.devops/sprints/sprint-{n}-<slug>/` directory.

## 8. Update the Registers

- In `SPRINTS.md`: change the sprint row status to `✅ CLOSED` and set the retro link to the archived `sprint.md` (`.devops/archive/sprints/sprint-{n}-<slug>/sprint.md#retro`). Link §6's business report and §5's `user-testing.md` in the same row's Retro cell, next to the retro link (`[business report](business-report.md)` / `[user testing](user-testing.md)`). Update `last_sprint`.
- Disposition the walk's failures: for each failed or blocked user-acceptance test, add an actionable row to the owning theme register in `.devops/backlog/` (or record explicitly that none failed — never silent). The retro records the count; the register rows carry the fix.
- Ensure REFACTORING.md reflects the scan results (Step 2) — when the register exists; otherwise the retro's **New Refactoring Items** section carries them, with the register's absence stated.
- Review `.devops/rules/process-lessons.md`: fold each matured machinery rule into its owning skill or `plan-lifecycle.md` and delete it from the register, so the staging register stays small (~25 entries) instead of becoming a second KC. **Template-side step:** both homes (`.devops/rules/**`, `.devops/skills/**`) are on the portable surface, so a pull replaces them wholesale — a satellite **reports** fold candidates upward and does not attempt the edit locally.
- Do NOT auto-open the next sprint. Tell the user the current one is closed and they can run `@sprint-plan` when ready, carrying forward the "capacity accuracy" line so the next plan suggests a better budget.

## 9. Hand Off

Summarise: goal met?, the user-acceptance walk's outcome (passed / failed / blocked counts), what carried forward, top refactoring flags, and the calibrated capacity number for next time. Point the user to `@sprint-plan` to open the next cycle.
