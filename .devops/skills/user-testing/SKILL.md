---
name: user-testing
description: Make sure to use this skill whenever the user mentions "user testing", "user tests", "test sheet", "acceptance walk", "walk the tests", "manual testing", "UAT", "test it with me", "test the release with me", "does it behave as promised", or wants to exercise delivered work in the operator's hands one test at a time via the ask-questions tool - build a test queue, record a user-testing sheet live, walk each test one-by-one, and finish with a clean documented test sheet that drives bug fixes / tweaks and/or is archived as evidence. Use it for a shipped feature, a plan's Phase 10 checklist, a release, or any work batch the operator must experience. Companion to q-and-a (gathers intent) and true-or-false (confirms documents) - user-testing exercises delivered behaviour.
version: 1
updated: 2026-09-29
---

# User Testing — Acceptance Walk

**Invocation:** "User-test the <feature>", "Walk me through the tests", "Test sheet for <slug>", "Do the acceptance walk", "UAT the release before we ship".

## Purpose & Context

To exercise delivered work in the owner's hands — **acceptance, not verification**. The test suite and a Gate D sign-off prove the implementation passed its battery of checks (the executor's question); this walk asks whether the delivered outcomes actually **behave as promised** for the person who owns them (the operator's question). Different subject, different evidence — the pattern was established as `@sprint-close` § 5's user-acceptance walk and is generalized here as the standalone discipline for any scope.

This skill enforces:
- **No unprepared testing** — the full test queue is drafted and written to the sheet before test 1 is presented; an improvised walk is a drift risk.
- **No batch verdicts** — one test at a time, verdict recorded before the next is presented.
- **No silent failures** — every fail or blocked becomes a Fix Item that drives the tweaks / bug fixes; when nothing failed, an explicit "none owed" is recorded.
- **No lost evidence** — the sheet is the record: every verdict carries the operator's answer, and the completed sheet stands as evidence of acceptance.

The final goal is a **clean, documented test sheet** the operator can point at — accepted outcomes, fix rows for anything that misbehaved — that can drive a tweak / bug-fix cycle or be archived as evidence.

## Summary

- A dedicated `user-testing-<slug>-YYYY-MM-DD.md` sheet is created **before T1** (frontmatter + Progress table + Test Queue + Fix Items + Sheet Summary placeholder) — the same live-.md pattern as [q-and-a](../q-and-a/SKILL.md) and [true-or-false](../true-or-false/SKILL.md). Default home is `.devops/audits/`; a sprint close's walk writes `user-testing.md` into its sprint folder instead (its own convention).
- Every test is presented **one at a time** via the `question` tool: the card (what to do, what to expect) is printed first, then one ask-call carries the verdict — **Pass / Fail / Blocked**.
- After each answer the sheet is **updated immediately** (Progress row + test card + Fix Item row on fail/blocked) before the next test is presented — no lost context.
- The session ends with a single "all tests walked" confirmation asked **on its own**, then the Sheet Summary is appended to the same file.
- Fix Items are dispositioned — a parcel plan's Change Items, backlog rows, or straight tweaks — and never evaporate; the finished sheet is linked from its record and archived as evidence.

---

## Phase 1: Initialization, Queue & Sheet Creation

Before any test is presented, establish what is being tested and persist the whole queue to the sheet.

1. **Confirm the scope and the test source.** The queue can be drawn from any of:
   * a parcel plan's acceptance criteria plus its Phase 10 user-testing checklist (and its `stories:` row when the plan carries one — the story is what the test presents first);
   * a set of completed plans or sprint outcomes (as at a sprint close);
   * a checklist the operator dictates;
   * a feature doc's promised behaviour.
2. **Confirm the slug and the venue.** `<slug>` becomes `user-testing-<slug>-YYYY-MM-DD.md`. Venues:
   * **Default:** `.devops/audits/user-testing-<slug>-YYYY-MM-DD.md` (companion home of the pattern skills' logs).
   * **Sprint close:** `user-testing.md` written into the sprint folder (`.devops/sprints/sprint-{n}-<slug>/`) — when the caller is `@sprint-close` § 5, its naming convention and COMPLETE-only scoping win for its own artifact.
   * **Transient run:** `.opencode/plans/run-<slug>/user-testing.md` for throwaway walk-runs.
3. **Build the test queue** — N tests (typical 5–15) **grouped per outcome/theme, never per parcel code or per file**. Each test must have:
   * **Theme** — the user-facing outcome the test belongs to;
   * **Source** — the story id / AC row / "operator dictated" trace, so a failure traces back through it;
   * **Test** — what to do: steps the owner performs in the product (no file paths, no machinery jargon);
   * **Expected** — what should happen when it works (observable, outcome language).
   A test that can only be described with internal vocabulary is a smell: reframe it in outcome language or drop it with a recorded scope note.
4. **Create the sheet** from the template below and **populate the Progress table and all N test cards before asking T1.**

### Sheet Template

Copy to the venue chosen in step 2; every section is live from the first write.

```markdown
---
title: User Testing — <Topic> Test Sheet
tags: [user-testing, <topic>, acceptance]
status: draft
owner: <operator / product-owner role>
created: YYYY-MM-DD
last-reviewed: YYYY-MM-DD
related-to: [<plan / sprint.md / feature doc the tests came from>]
---

# User Testing — <Topic> Test Sheet (YYYY-MM-DD)

> Purpose: exercise <what was delivered> in the operator's hands — one test at a time, verdicts recorded here live (Pass / Fail / Blocked). Fails and blocks become Fix Items that drive tweaks or bug fixes; completed verdicts stand as evidence. Live-log pattern of <slug>-QA.md / true-or-false.

**Scope:** <the feature / plan / sprint outcomes / dictated list being tested>
**Source of the tests:** <stories: row / plan ACs + Phase 10 checklist / operator dictation>
**Venue:** <path/to/sheet.md> (this file)

## Progress

| # | Test | Theme | Status | Verdict |
|---|------|-------|--------|---------|
| T1 | ... | ... | ⬜ Pending | — |
| T2 | ... | ... | ⬜ Pending | — |

## Test Queue

### T1 — <Short Title>
**Theme:** <outcome / theme group — never per parcel code>
**Source:** <story id / AC row / "operator dictated">
**Test:** <what to do — user-facing steps in the product>
**Expected:** <what should happen when it works>
**Verdict:** _pending_
**Operator note:** —

### T2 — <Short Title>
...

---

## Fix Items (accumulates during session)

| ID | Test | What actually happened | Suggested fix | Size | Status |
|----|------|------------------------|---------------|------|--------|
| F1 | T3 | "[operator's exact words]" | <tweak / bug fix implied> | S/M/L | ☐ To do |

## Sheet Summary — _to be completed after the final test_

_Summary (metrics + per-test detail + outcome) is appended here after the "all tests walked" confirm._
```

---

## Phase 2: The Just-In-Time (JIT) Walk Loop

Present exactly **one test at a time**. It is strictly forbidden to present T[X+1] until the operator has answered T[X] **and the sheet has been updated**.

For each T:

### Step 1 — Print the card, then invoke the ask tool

Print the T[X] card from the sheet verbatim as chat text — title, theme, test, expected — then invoke the interactive question tool (`question` in opencode; the ask-questions tool in VS Code Copilot):

```
header: "T[X] Verdict"  (max 30 chars)
question: "T[X] — did <one-line what the operator does> behave as expected? (<what to expect, one line>)"
options:
  - label: "Pass"
    description: "Behaves as expected."
  - label: "Fail"
    description: "Something is wrong — describe what actually happened (free text)."
  - label: "Blocked"
    description: "Could not complete — say why (free text)."
```

Single select (`multiple: false`); free text is always allowed and is how most failure detail arrives.

**Interaction shape:** one call per test where the ask surface is single-question, one batched call where the tool accepts a question array; the final "all tests walked" confirmation is **always asked on its own**, never inside the queue (batched-clarification pattern, T1-E3.08).

### Step 2 — Persist immediately

After each answer, **update the sheet before presenting the next test**:

- **Progress row:** `⬜ Pending → ✅ Pass / 🔴 Fail / 🟠 Blocked` + date + short note.
- **Test card:** replace `_pending_` with the verdict + the operator's exact words (quoted) as the operator note.
- **Fail or Blocked:** append a **Fix Item** row immediately (what was tested, what actually happened, the implied tweak / bug fix, S/M/L) — the failure is on the record before the walk continues.
- Save / commit the sheet before presenting T[X+1].

### Step 3 — Carry context forward

Use answers to reframe later tests: a fail may reveal that the *expectation*, not the behaviour, was wrong; absorb the operator's correction as the new source of truth. If a correction changes any later tests, print **[Queue Updated]** with the adjusted path and present the corrected card — same dynamic pivot as [true-or-false](../true-or-false/SKILL.md).

---

## Phase 3: Response Routing

Route each verdict as it lands (applies to the chat presentation and the persisted sheet state alike):

### 1. Pass
Mark the test **[Confirmed]** in the Progress row and card; advance to T[X+1].

### 2. Fail
Mark **[Failed]**. The Fix Item was already appended in Phase 2 Step 2 — do **not** fix anything mid-session. If the failure invalidates later tests, apply the Phase 2 **[Queue Updated]** pivot instead of asking tests you know to be stale.

### 3. Blocked
A blocked test is **recorded, not retried**, and is dispositioned with the other failures at the end. Where the operator cannot exercise a test and rules it acceptable on evidence (an "accepted untested" ruling), record the verdict as **Blocked** with the ruling quoted in the note — the honest representation, so the sheet never reads as exercised sign-off when it was not.

### 4. Other / nuance (free text)
If the nuance means the expectation was wrong, treat it as a Fail with a corrected-expected Fix Item and adapt the wording of later tests. If it confirms the behaviour with nuance, record **Pass** with the nuance quoted as the operator note.

### Session-end discipline
If the session ends before every test is walked, keep exactly what was answered: completed verdicts stay recorded, unanswered tests stay open and are marked in the Sheet Summary — never a silent skip, never a re-ask of answered tests. A resumed walk continues from the first open row.

### Skip discipline
If the walk is skipped entirely (nothing testable, operator unavailable), the Sheet Summary records **why** — never a silent skip. An empty queue still writes a zero-test sheet — an empty artifact, not silence.

---

## Phase 4: Sheet Conclusion & Disposition

When the "all tests walked" confirmation (asked on its own) is answered — or the walk is halted / ends early — append to the **same file** (never a separate one) and disposition the results.

### Sheet Summary (append to the sheet)

```markdown
## Sheet Summary — W/N walked (YYYY-MM-DD)

| Metric | Value |
|--------|-------|
| Tests in queue | N |
| Walked | W |
| Pass | X |
| Fail | Y |
| Blocked | Z |
| Unanswered | N - W (why, or "none") |
| Fix items raised | Y + Z (or "0") |
| Sheet | `user-testing-<slug>-YYYY-MM-DD.md` |

**Outcome:** <one paragraph — what is accepted, what needs a fix, what stays blocked>

**Detail per test:**
- **T1 ✅ Pass** — <summary>
- **T2 🔴 Fail** — <what happened> (Fix Item F1)
- **T3 🟠 Blocked** — <ruling / reason>
...
```

Flip the frontmatter `status:` to `complete` — `partial` when unanswered tests remain.

### Disposition the Fix Items — never evaporate

Every fail and blocked must end as an owned next step, or the summary states explicitly that none were raised ("0 failed, 0 blocked — no rows owed", stated, never silent):

1. **Live parcel plan** — merge the Fix Items into its Change Items table ([pass-the-parcel](../pass-the-parcel/SKILL.md) handles the execution).
2. **No live plan** — register actionable rows via [backlog](../backlog/SKILL.md) in the owning theme register.
3. **Trivial tweak** — a one-line, no-scope-question fix may be applied directly now, with the Fix Item marked done and the edit named in the sheet.

At a sprint close the caller owns this step's venue: `@sprint-close` § 8 routes the walk's failures into the theme registers.

### Evidence & archival

Link the finished sheet from the record it belongs to (the plan's Phase 10 checklist, `sprint.md`, or the feature doc). The completed sheet **is** the archived evidence of acceptance: at a sprint close it travels with the sprint folder into `.devops/archive/sprints/` per `@sprint-close` § 7; otherwise it stands in `.devops/audits/` as a linkable acceptance record.

---

## Relationship to the Pattern Skills

| Dimension | [Q&A](../q-and-a/SKILL.md) (gathers) | [True or False](../true-or-false/SKILL.md) (confirms) | User Testing (this skill — exercises) |
|---|---|---|---|
| **Purpose** | Gather requirements for a new concept | Confirm documents match intent | Confirm delivered work behaves as promised for the owner |
| **Unit** | A question | A statement + document proof | A test performed in the product |
| **Answer vocabulary** | Options A/B/C/D | True / False / Skip Branch / Other | Pass / Fail / Blocked |
| **Persistence** | Progress + QA Log, JIT | Same + Change Plan Items | Progress + Test cards + Fix Items, JIT |
| **Ending** | Synthesis + re-baselined plan | Verification Summary + change plan | Sheet Summary + disposition (fix rows → plan / backlog) |
| **Evidence for** | Gate A scope | Wiki / doc alignment | Acceptance — "works for the person who owns it" |

All three record in an independent `.md`, all three ask one question at a time and persist immediately, all three end with an actionable output. Use Q&A before the work, True/False on the documents, User Testing on the delivered behaviour.

### Relationship to sprint-close

`@sprint-close` § 5 scopes this walk to a completed sprint: plans scoped to `claim_status: COMPLETE` only, the queue built from executed plans' acceptance criteria + Phase 10 tweak notes grouped per outcome/theme, the sheet named `user-testing.md` in the sprint folder, and failures routed to the theme registers by its § 8. When the caller is sprint-close, **its scope rules win** on queue building and disposition venue; this skill owns the walk loop and the sheet discipline (cited by sprint-close since its v16).

---

## Outputs

| Output | Description |
|---|---|
| `user-testing-<slug>-YYYY-MM-DD.md` (or the sprint folder's `user-testing.md`) | Live sheet: frontmatter + Progress + Test Queue (verdicts with quoted operator notes) + Fix Items + Sheet Summary |
| Fix Items dispositioned | Tweak / bug rows routed into a parcel plan's Change Items or the owning theme register — or an explicit "0 failed, 0 blocked — no rows owed" |
| Acceptance evidence | The completed sheet linked from its record; carried into the archive at a sprint close, otherwise standing in `.devops/audits/` |

## Example

**Request:** "The suite is green — walk me through the settings screen before we ship."

1. **Scope:** one executed plan; source = its `stories:` row (3 stories, 9 tests) + Phase 10 checklist. Venue: `.devops/audits/user-testing-settings-screen-2026-09-29.md`.
2. **Sheet populated before T1:** 9 cards across 3 themes (Profile editing, Avatar upload, Notifications); each Test is steps in the product, each Expected observable.
3. **Walked JIT:** T1 card printed → operator performs it → Pass → row + card updated immediately before T2. T4 fails with "the crop cuts faces off small photos" → Fix Item F1 (S — widen the crop rect minimum) lands before T5 is presented.
4. **T6 blocked:** no notification permission on the device — recorded with the ruling, not retried.
5. **Final "all tests walked" confirm on its own** → Sheet Summary appended (9 walked: 7 pass, 1 fail, 1 blocked), `status:` → `complete`.
6. **Disposition:** F1 merged into the plan's Change Items; the blocked row's ruling stands quoted in the summary; sheet linked from the plan's Phase 10 checklist and cited in the release note.

---

## See Also

- [Q&A](../q-and-a/SKILL.md) — gathers the intent before the work (companion)
- [True or False](../true-or-false/SKILL.md) — confirms documents against reality (companion)
- [Sprint Close](../sprint-close/SKILL.md) — scopes this walk to a completed sprint (§ 5 user-acceptance walk)
- [Pass-the-Parcel](../pass-the-parcel/SKILL.md) — executes the fixes this walk raises
- [Backlog](../backlog/SKILL.md) — registers fix rows when there is no live plan
- [Plan template](../../plans/template-plan.md) — Phase 10 owns the per-plan checklist this walk consumes
- [AI Rules](../../../.wiki/rules/language/ai-rules.md) — evidence ladder and no-fabrication guardrails
