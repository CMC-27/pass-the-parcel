---
name: q-and-a
description: Make sure to use this skill whenever the user mentions "Q&A", "gather requirements", "ask me questions", "requirements discovery", "interview me", or wants a new concept, template, pattern or process defined via a dedicated <slug>-QA.md log, one question at a time with the interactive question tool. Use it for Gate A discovery, when a new concept/template/pattern needs to be defined, or when you need to capture exactly what the SME needs before authoring. Companion to true-or-false (Q&A gathers, True/False confirms).
version: 3
updated: 2026-09-06
---

# Q&A — Requirements Gathering

**Invocation:** "Start a Q&A for [topic]", "Gather requirements for [concept/template]", "We need lots of questions before Gate A", "Q&A this process", "Create a QA.md and work through it"

## Purpose & Context

To gather requirements for a **new concept, template or pattern** where the shape is not yet known and the SME must define it. Where [true-or-false](../true-or-false/SKILL.md) **confirms** that existing knowledge matches intent, **Q&A gathers** the intent in the first place — one detailed question at a time, with full options, recorded in an independent `<slug>-QA.md` log that becomes the specification for a clear, actionable parcel plan.

This skill enforces:
- No batch assumptions — every requirement is explicitly asked and explicitly answered.
- No lost context — every answer is persisted immediately to the QA log.
- No hand-wavy specs — the QA log is the synthesis input for the parcel plan's Scope, Requirements and Change Items.

The final goal is a **robust, SME-owned understanding** of the requirement that can be re-baselined directly into `.devops/plans/<slug>-plan.md` and then into a v2 template or pattern spec for Gate A.

## Summary

- A dedicated `*-QA.md` is created from the Q&A log template (frontmatter + Progress table + Q&A Log + Synthesis).
- Each question is asked **one at a time** via the `question` tool (with full options, recommendation, and "type your own answer" always allowed).
- After each answer the QA log is **updated immediately** (Progress table + Q&A section + implication).
- The session ends with Q28-style **"have we got all context"** gate; synthesis is appended to the same file.
- The synthesis drives the **parcel plan re-baseline** (Scope, Requirements & Context, Change Items) and the **template/pattern draft** for Gate A — executed via [pass-the-parcel](../pass-the-parcel/SKILL.md).

---

## Phase 1: Initialization & Log Creation

1. **Confirm the topic & slug:** e.g. `pricing-process`, `plant-profiles`, `crew-refinement`. The slug becomes `<slug>-QA.md`.
2. **Create the QA log:** copy the template below to `.devops/audits/<slug>-QA-YYYY-MM-DD.md` (or `.opencode/plans/run-<slug>/QA.md` for transient runs):

```markdown
---
title: <Topic> Q&A — <Purpose>
tags: [<topic>, q-and-a, <phase>]
status: draft
owner: <SME role>
created: YYYY-MM-DD
last-reviewed: YYYY-MM-DD
related-to: [../backlog/product-roadmap.md, ./<slug>-plan.md, <relevant doc/template>]
---

# <Topic> Q&A — <Purpose>

> Purpose: collaborative discovery for [phase/item] — capture exactly what the SME needs before authoring. This file is the live log: each question asked via `question`, answer recorded here, synthesis becomes Pattern Spec + v2 template for Gate A.

## Progress

| # | Question | Status | Answer |
|---|---|---|---|
| Q1 | ... | ⬜ Pending | — |

## Q&A Log

### Q1 — <Title>
**Context:** Why this matters
**Options:** A/B/C/D with implication
**Answer:** _pending_

### Q2 ...
## Synthesis (to be completed after final Q)

_Synthesis will be appended after all questions answered_
```

3. **Generate the question set:** From the topic's source material (existing docs, templates, taxonomy, workflow, roadmap todo), draft **N detailed questions** (typical 15-30) grouped into themes. Each question must have:
   - **Context** — why it matters and what docs it touches.
   - **Options** — 2-4 concrete options with a 1-5 word label + one-line description; mark a recommendation where applicable.
   - **Implication** — what each option would mean for the plan/template.
   - "Type your own answer" is always available (via `question` tool custom).

4. **Populate the Progress table + Q&A Log skeleton** with all N questions in the log file before asking Q1.

---

## Phase 2: The Just-In-Time (JIT) Q&A Loop

Ask exactly **one question at a time**. It is strictly forbidden to ask Q[X+1] until the user has answered Q[X] **and the log has been updated**.

For each Q:

**Step 1 — Invoke the interactive question tool** (`question` in opencode; the ask-questions tool in VS Code Copilot):

```
header: "Q[X] — <Short Title>"  (max 30 chars)
question: "Q[X] — <Full question including context? A=..., B=..., C=... >"
options:
  - label: "A. <1-5 word label>"
    description: "<one-line implication>"
  - label: "B. ..."
  - ...
```

Set `multiple: true` (`multiSelect` in VS Code Copilot) only where the question explicitly asks to "select all that apply".

**Step 2 — Persist immediately:**

- Update the **Progress table** row: `⬜ Pending → ✅ Done YYYY-MM-DD` + concise answer summary.
- Update the **Q&A Log** section: replace `_pending_` with the user's exact words (quoted) + interpreted option + implication.
- Commit or save the log file before asking the next question.

**Step 3 — Carry context forward:**

Use the answer to inform later questions (e.g. if Q4 = "Per Work Category", Q5's batch list should assume categories).

---

## Phase 3: Synthesis & Parcel Plan Re-baseline

When the final "have we got all context" question is answered `A. We are good`:

1. **Append Synthesis to the same QA.md:**

```markdown
## Synthesis — <Topic> Pattern Summary (YYYY-MM-DD, all N answered)

**Identity:** ...
**Granularity & scope:** ...
**Template structure:** ...
**Governance & delivery:** ...
**Next actions for Gate A:**
1. Re-baseline `<slug>-plan.md` with above pattern
2. Draft `.wiki/templates/...` v2 + worked example
3. Draft checklists / supporting artifacts
```

2. **Re-baseline the parcel plan:** update `.devops/plans/<slug>-plan.md`:
   - **Purpose / Scope** — per QA answers (in/out)
   - **Background / Rationale** — why now + link to QA log
   - **Requirements & Context** — check the spokes/INDEXes read
   - **User Clarification** — collapse QA answers into Gate A Qs, mark Gate A approved
   - **Change Items + Item detail** — per QA pattern (template v2, worked example, checklists, etc.)

3. **Draft the template/pattern** (e.g. `.wiki/templates/<pattern>.md` v2) for Gate A review — front-loaded per [document-structure](../../../.wiki/rules/document-structure.md), link-not-copy, company-agnostic.

4. **Handoff to pass-the-parcel:** the plan carries state via its State Dashboard; execution waits for Gate A/B/C per the [pass-the-parcel](../pass-the-parcel/SKILL.md) lifecycle (one phase-group per session).

---

## Relationship to True or False

| Dimension | Q&A (this skill) | True or False |
|---|---|---|
| **Purpose** | **Gather** requirements for a new concept/template | **Confirm** existing knowledge matches intent |
| **Timing** | Before authoring (Phase 3 discovery / Gate A) | After authoring or before approval |
| **Questions** | "What should it be? Pick A/B/C or tell me" | "Does this doc match reality? True/False/Skip/Other" |
| **Artifact** | `<slug>-QA.md` → synthesis → parcel plan | `<slug>-plan.md` change items |
| **Ending** | Synthesis + re-baselined plan + v2 template for Gate A | Verification Summary + change plan for parcel execution |
| **Style** | Many detailed options, collaborative | Plain SME question + Knowledge Proof (file/lines) |

Both record in an independent `.md`, both have many questions, both produce a clear, actionable parcel plan. Use Q&A first, then True/False to validate the result.

---

## Outputs

| Output | Description |
|---|---|
| `<slug>-QA.md` | Live Q&A log with Progress table, all Q&A sections, and Synthesis appendix |
| Re-baselined parcel plan | `<slug>-plan.md` with Gate A scope approved |
| Pattern spec / v2 template | Draft template + worked example ready for Gate A review |

## Example

**Request:** "Pricing process is new — lots of collaboration, lots of questions. We want a robust template and pattern before Gate A."

1. Created `.devops/audits/pricing-process-QA-2026-08-21.md` with 28 questions grouped: Identity & Boundary (Q1-3), Granularity & Taxonomy (Q4-7), Structure (Q8-13), Build-up & Blocks (Q14-17), Supply Chain & Commercial (Q18-20), Tribal & Checklists (Q21-23), Governance & Mechanics (Q24-28).
2. Asked Q1 via `question`: "Pricing Process Identity — A/B/C/D?" → User: "Estimator Playbook per Work Category, step-by-step guide, ready for peer+tender review, guides new estimators, feedback loop" → updated log immediately.
3. Repeated JIT for Q2-Q28; final Q28 = "We are good".
4. Appended Synthesis: per-category playbooks, stay-in-lane, simple tick+comment, bespoke P&G, traceable Tribal table, 1 generic + 1 per work type checklists, etc.
5. Re-baselined `pricing-process-library-plan.md` and drafted `.wiki/templates/pricing-process.md` v2 for Gate A.

---

> **Related:** [True or False](../true-or-false/SKILL.md) | [Pass-the-Parcel](../pass-the-parcel/SKILL.md) | [Wiki Writer](../wiki-writer/SKILL.md) | [Plan template](../../plans/template-plan.md) | [Wiki Lint](../wiki-lint/SKILL.md) | [AI Rules](../../../.wiki/rules/language/ai-rules.md)

## See Also

- [True or False](../true-or-false/SKILL.md) — confirming knowledge matches intent
- [Pass-the-Parcel](../pass-the-parcel/SKILL.md) — executing the plan this discovery produces
- [Wiki Writer](../wiki-writer/SKILL.md) — writing the docs this discovery specifies
