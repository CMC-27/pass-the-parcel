---
name: true-or-false
description: Make sure to use this skill whenever the user mentions "true or false", "validate the wiki", "does the knowledge base match", "is this accurate", "step-by-step validation", "check against reality", or wants to validate knowledge-base/process docs against human intent one step at a time with a dual SME (plain language) + Knowledge Curator (document proof) lens. Use it to eliminate AI-fabricated or unsourced content, surface stale, wrong or dead knowledge, validate a workflow or journey step-by-step, or check a process document against live practice.
version: 4
updated: 2026-09-06
---

# True or False — Knowledge Base Alignment Workflow

**Invocation:** "Validate the <workflow> step-by-step", "Does the knowledge base match how we actually work?", "Is [process / journey / rule] accurate?", "Check my new draft against the brief".

## Purpose & Context

To align human intent, intended process design and knowledge base reality by validating the wiki one step at a time against **two audiences**: the **Subject Matter Expert (SME)** — the domain owner who validates intended behaviour in plain language — and the **Knowledge Curator**, who verifies document proof against live content in the knowledge base (`.wiki/` in this repo; the satellite's knowledge areas).

This dual-lens approach eliminates batch-generation hallucinations (fabricated claims, unsourced rates, invented precedents), accommodates dynamic branching, and surfaces stale, wrong, duplicated or dead knowledge early — without requiring the SME to read a single file. It enforces the [AI Rules](../../../.wiki/rules/language/ai-rules.md) evidence ladder at the document level.

The final goal is to reach **100% Alignment (All True)** for a specified knowledge journey — meaning the wiki accurately and completely reflects the intended workflow, with every claim traceable to a source.

## Summary

- A dedicated `true-or-false-<slug>-YYYY-MM-DD.md` log is created before Q1 (frontmatter + Progress table + Journey Map + Q&A Log skeleton + Change Plan Items) — same live-.md pattern as [Q&A](../q-and-a/SKILL.md).
- Every step of the journey is checked against live document proof, **one step at a time** via the `question` tool — no batch of unverified statements.
- Each step is presented as a plain-language SME question with an exact, quoted document reference (file, heading, line).
- After each answer the log is **updated immediately** (Progress table + Q&A section + Change Item row if non-True) before the next question — no lost context.
- Every non-True step is recorded as a change-plan item with the faulty assumption, the user's ground truth and a remediation action — never silently fixed mid-session.
- The session ends with a verification summary appended to the same file and a single, owned change plan ready for [pass-the-parcel](../pass-the-parcel/SKILL.md) execution.
- No document status is promoted and no substantive edit is made without the SME's explicit instruction.

---

## Phase 1: Initialization & Scope Definition & Log Creation

Before generating any validation statements, establish strict boundaries to prevent context drift and state amnesia, then create the live log.

1. **Prompt for Scope:** The user must explicitly define, or the agent must read from context, the following constraints:
   * **Journey / Workflow:** (e.g., "Inquiry through submitted estimate", "Change-order pricing", "Handover to delivery")
   * **Knowledge area to validate against:** (e.g., `.wiki/core/`, a spoke INDEX, or a single document)
   * **SME Persona:** who validates intent (e.g., the domain owner, team lead, process owner)

2. **Generate Initial Journey Map:** Perform an initial crawl of the knowledge base (spoke `INDEX.md` files, process/workflow docs, relevant feature areas, handoff chain in `AGENTS.md`) and output a high-level, skeletal index of the journey (minimum 10 checkpoints).
   * *Note: This is an overview map of titles only, not the detailed statements.*
   * Frame the titles in user-facing language (e.g., "The estimator issues a brief" not "Brief builder agent creates brief skeleton") so the SME can orient themselves from the start.

3. **Confirm the topic & slug:** e.g. `core-standards`, `pricing-basis`, `core-workflow`. The slug becomes `true-or-false-<slug>-YYYY-MM-DD.md`.

4. **Create the True-or-False log:** copy the template below to `.devops/audits/true-or-false-<slug>-YYYY-MM-DD.md` (or `.opencode/plans/run-<slug>/true-or-false.md` for transient runs):

```markdown
---
title: True-or-False — <Topic> Validation
tags: [true-or-false, <topic>, validation]
status: draft
owner: <SME role>
created: YYYY-MM-DD
last-reviewed: YYYY-MM-DD
related-to: [<knowledge area INDEX>, <relevant README>]
---

# True-or-False — <Topic> Validation (YYYY-MM-DD)

> Purpose: dual-lens validation of <knowledge area> for <purpose> — SME intent vs wiki proof, one step at a time. Each step has an SME Question (plain language, no file paths) and a Knowledge Proof (exact file + heading + lines + quoted passage). Answer True / False / Skip Branch / Other directly in this file. Gaps and misalignments become change-plan items for `pass-the-parcel` execution. This file is the live log — mirrors `<slug>-QA.md` pattern.

**Journey:** `<Journey Name>`
**Knowledge area:** `<path/to/area>` (N docs + index)
**SME Persona:** <SME role> (owner per frontmatter)
**Estimated steps:** N

## Progress

| # | Step Title | Status | Answer |
|---|---|---|---|
| Q1 | ... | ⬜ Pending | — |
| Q2 | ... | ⬜ Pending | — |

## Journey Map (skeletal index — titles only, user-facing)

1. **First step title** — user-facing description
2. **Second step title** — user-facing description
...

---

## Q&A Log

### Q1 — <Step Title>

**Current Scope:** `<Journey>` -> `<Active Segment>`

**SME Question:**
<plain-language question — no file paths, no wiki jargon>

**Knowledge Proof:**
* **File:** `path/to/document.md` (Heading / Lines X-Y)
> Exact live passage being referenced

**Options:**
- **A. True** — Yes, this is correct as-is.
- **B. False** — No, this is wrong. (Describe correction)
- **C. Skip Branch** — This segment irrelevant/deprecated; skip remaining branch.
- **D. Other** — Clarification or nuance needed. (Describe via free-text)

**Answer:** _pending_

**Implication if True:** Q1 marked **[Aligned]**; advance to Q2.

**Implication if False/Other:** Record Change Item → `path/to/document.md`, faulty assumption, user ground truth, remediation.

### Q2 — <Step Title>
...

---

## Change Plan Items (accumulates during session)

| ID | Target Location | Faulty Assumption | User Ground Truth | Remediation | Status |
|---|---|---|---|---|---|
| 1 | `path/to/doc.md:lines` | What agent thought | "[User's exact words]" | What must change | ☐ To do |

## Session Conclusion — _to be completed after final Q_

_Verification Summary + outcome will be appended here after all steps answered_
```

5. **Populate the Progress table + Q&A Log skeleton** with all N steps in the log file before asking Q1. Each step must have:
   - **SME Question** — why it matters, framed as "When the SME does X, they get Y, right?"
   - **Knowledge Proof** — exact file + heading + lines + quoted passage
   - **Options** — True / False / Skip Branch / Other with one-line implication
   - "Type your own answer" is always available via the `question` tool custom field.

---

## Phase 2: The Just-In-Time (JIT) Evaluation Loop

Evaluate exactly **one statement at a time**. It is strictly forbidden to ask Q[X+1] until the user has answered Q[X] **and the log has been updated**.

For each Q:

### Step 1 — Present and invoke `question` tool

First print the step header and metadata as text, then use the interactive question tool to prompt the user (`question` in opencode; the ask-questions tool in VS Code Copilot):

**Printed text:**
```
### Step [X] / [Estimated Total]: [Step Title]
* **Current Scope:** `[Journey]` -> `[Active Segment]`

**SME Question:**
[Ask what *should* happen from a business or domain perspective. Use plain language — no file paths, no technical wiki jargon. Frame it like: "When an estimator does X, they get Y, right?" or "The process should handle Z this way — is that correct?"]

**Knowledge Proof:**
* **File:** `path/to/document.md` (Heading / Lines X-Y)
> CRITICAL: Extract and print the exact live passage being
> referenced to prevent lazy line-number hallucinations.
```

**Then invoke the `question` tool with:**
* **Question:** "Does the behaviour described above match your expectations?"
* **Header:** "Step [X] Response" (max 30 chars)
* **Options:**
  * **True** — Yes, this is correct as-is.
  * **False** — No, this is wrong. (You can describe the correction via free-text.)
  * **Skip Branch** — This step/segment is irrelevant or deprecated; skip all subsequent steps in this branch.
  * **Other** — Clarification or nuance needed. (Describe via free-text.)

Set `multiple: false` (single selection). Custom free-text is always allowed.

#### Example (Core Estimating Workflow)

**Printed text:**
### Step 3 / 12: Estimator Assigned and Brief Issued
* **Current Scope:** `Inquiry → Submitted estimate` -> `Intake and go/no-go`

**SME Question:**
Once the go/no-go decision is "Go", the estimator is assigned and a formal brief is issued before any pricing work starts. Is that correct?

**Knowledge Proof:**
* **File:** `.wiki/features/estimating-workflow.md` (Workflow Map / Step 3, Line 53)
> Assign the estimating team and issue the brief — confirm the lead estimator, QS, technical input, required outputs, due dates and delivery level.

The workflow map also shows `C -->|Go| D[Assign estimator and issue brief]`.

**Then call `question` with:**
* **Question:** "Does the behaviour described above match your expectations?"
* **Header:** "Step 3 Response"
* **Options:**
  * **True** — Yes, this is correct as-is.
  * **False** — No, this is wrong.
  * **Skip Branch** — This step/segment is irrelevant or deprecated.
  * **Other** — Clarification or nuance needed.

### Step 2 — Persist immediately

After the user answers, **update the log file before asking the next question**:

- Update the **Progress table** row: `⬜ Pending → ✅ Done YYYY-MM-DD` + concise answer summary (`True` / `False — <summary>` / `Other — <summary>` / `Skip Branch`).
- Update the **Q&A Log** section for Q[X]: replace `_pending_` with the user's exact words (quoted) + interpreted option + date + `question` tool attribution.
- If `False`/`Other` requiring a change (or `Skip Branch`), **append a row** to **Change Plan Items** table immediately:

```
| ID | Target Location | Faulty Assumption | User Ground Truth | Remediation | Status |
| N | `path/to/doc.md:lines` | What wiki claims | "[User's exact feedback]" | What must be added/corrected/linked/archived per [.wiki/rules/](../../../.wiki/rules/README.md); company-specific facts stay in the satellite's company knowledge area | ☐ To do |
```

- Save/commit the log file before presenting Q[X+1].

### Step 3 — Carry context forward & dynamic pivot

Use the answer to inform later questions (e.g. if Q2 redefines "pre-costed" as "assemblies", downstream Q3/Q4/Q7 wording should use the corrected term). If the correction changes subsequent steps, print a brief **[Journey Map Updated]** alert showing the adjusted path, then present the new, corrected Q[X+1].

---

## Phase 3: Response Processing & State Machine Logic

Route the next action dynamically based on the user's explicit input (applies both to printed logic and to the persisted log state):

### 1. If User Responds True
* Mark step as **[Aligned]** in log (Progress + Q&A Log `Implication` line).
* Advance directly to the next logical step in the Journey Map.

### 2. If User Responds False (with or without correction)
* Mark step as **[Misaligned]**.
* **Record Change Item:** already appended in Phase 2 Step 2 — pass the document location, the faulty assumption, and the user's correction as context. Do not edit the document yet.
* **Recalibrate Internal State:** Re-read the affected files using the user's correction as the new source of truth.
* **Dynamic Pivot:** If the correction changes subsequent steps, print **[Journey Map Updated]** and present the new, corrected Q[X+1] (also update any not-yet-asked skeleton sections in the log to reflect the pivot).

### 3. If User Responds Other (Clarification or Nuance)
* If the nuance requires a knowledge-base change, treat it as **False** and ensure a change item is recorded.
* If the nuance clarifies a conditional branch (e.g., "This only happens for priced tenders, not quotations"), absorb the logic and adapt the next question accordingly (update skeleton wording in log and note the branch condition).

### 4. Global Override Commands
* **Skip Branch / Deprecated:** If the user notes that a step, process or document is dead or superseded, record a change item labelled "Prune/Archive Content" (flag for `archive` status and inbound-link reconciliation) and completely skip all subsequent steps in that branch — mark them `⏭️ Skipped` in Progress table.

---

## Phase 4: Session Conclusion & Artifact Output

When the journey is complete (or manually halted by the user), **append to the same log file** (do not create a separate file) and produce the parcel plan.

### Verification Summary (append to log)

```markdown
## Session Conclusion — N/N Complete (YYYY-MM-DD)

**Verification Summary**

| Metric | Value |
|--------|-------|
| **Journey Evaluated** | [Journey Name] |
| **Knowledge area validated** | [Area / INDEX] |
| **Total Steps Checked** | [Total N] |
| **Total Aligned (True)** | [Count X] |
| **Total Misaligned (False)** | [Count Y] |
| **Total Other / Needs Enhancement** | [Count Z] |
| **Total Skipped** | [Count S] |
| **Alignment Rate** | X% True as-is → 100% after Y enhancements |
| **Session File** | `true-or-false-<slug>-YYYY-MM-DD.md` |

**Outcome:** <one-paragraph outcome — what is release-ready, what needs enhancement>

**Alignment Detail per Q:**
- **Q1 ✅ True** — <summary>
- **Q2 🔴 False** — <misalignment> (Change Item N)
- **Q3 🟡 Other** — <enhancement> (Change Item N)
...

## See Also
...
```

### Promote to Change Plan

- If the journey maps to an existing active plan in `.devops/plans/`, copy/merge the **Change Plan Items** table rows into its Change Items table and add a link back to this session log.
- Otherwise the session log **is** the change plan — instantiate `.devops/plans/<slug>-plan.md` from the [plan template](../../../.devops/plans/template-plan.md), or keep the `true-or-false-<slug>-YYYY-MM-DD.md` name as the plan and register it in its State Dashboard. Ensure `Purpose`, `Scope`, `Background / Rationale` and `Requirements & Context` are filled from the session header, and list the items in its Change Items table with full detail:

```
#### Change Item [ID] - Misalignment in [Process / Document]
* **Target Location:** `path/to/document.md`
* **Faulty Assumption:** [What the agent thought the knowledge base said]
* **User Ground Truth:** "[User's exact feedback]"
* **Remediation Action:** [What must be added, corrected, linked or archived in the wiki to align reality with human intent.]
* **Governance check:** numbering / naming / frontmatter / link hygiene per [.wiki/rules/](../../../.wiki/rules/README.md); company-specific facts stay in the satellite's company knowledge area.
```

> The plan is then executed under the [pass-the-parcel](../pass-the-parcel/SKILL.md) workflow (one phase-group per session, human gates A–D) and archived via [agent-wrap-up](../agent-wrap-up/SKILL.md) when complete. Structural issues found during the session (broken links, orphans, frontmatter defects) are re-checked with [wiki-lint](../wiki-lint/SKILL.md). Notable, reusable findings should be offered to [knowledge-capture](../knowledge-capture/SKILL.md).

---

## Relationship to Q&A

| Dimension | Q&A (gather) | True or False (this skill — confirm) |
|---|---|---|
| **Purpose** | **Gather** requirements for a new concept/template | **Confirm** existing knowledge matches intent |
| **Timing** | Before authoring (Phase 3 discovery / Gate A) | After authoring or before approval |
| **Questions** | "What should it be? Pick A/B/C or tell me" | "Does this doc match reality? True/False/Skip/Other" |
| **Artifact** | `<slug>-QA.md` → synthesis → parcel plan | `true-or-false-<slug>-YYYY-MM-DD.md` (live log) → verification summary + change plan |
| **Loop** | Many detailed options, collaborative | Plain SME question + Knowledge Proof (file/lines) |
| **Persistence** | Progress + Q&A Log updated JIT after each answer | **Same** — Progress + Q&A Log + Change Items updated JIT after each answer |
| **Ending** | Synthesis + re-baselined plan + v2 template for Gate A | Verification Summary + change plan for parcel execution |

Both record in an independent `.md`, both have many questions, both produce a clear, actionable parcel plan. Use Q&A first, then True/False to validate the result.

---

## Outputs

| Output | Description |
|---|---|
| `true-or-false-<slug>-YYYY-MM-DD.md` | Live True-or-False log with Progress table, all Q&A sections (SME Question + Knowledge Proof + Answer), Change Plan Items accumulating, and Verification Summary appendix |
| Re-baselined / new parcel plan | `<slug>-plan.md` (or the same log promoted) with Change Items ready for Gate A/B/C |
| Verification Summary | Metrics (Total / Aligned / Misaligned / Other / Skipped) + Alignment Detail per Q + Outcome paragraph |

## Example

**Request:** "Validate Core Standards for release readiness"

1. Created `.devops/audits/true-or-false-core-standards-2026-08-23.md` with 15 questions grouped: Philosophy & Hierarchy (Q1-3), Blocks (Q4), Margin (Q5-7), Classifications (Q8-9), Taxonomies (Q10-11), etc.
2. Asked Q1 via `question`: "5-Level Hierarchy is the backbone — True/False/Other?" → User: "True" → updated Progress row to `✅ Done True` and Q1 Answer to `"True" — SME confirms...` before asking Q2.
3. Repeated JIT for Q2-Q15; Q2 = `Other — nuance, needs reword` → appended Change Item 1 (soften "pre-costed" + "Custom Block" formalism) before Q3; Q4 = `Other — True + general principle` → appended Change Item 2, printed `[Journey Map Updated]`.
4. After Q15 appended `Session Conclusion` — Verification Summary (15 checked, 8 True, 7 Other) + Alignment Detail per Q.
5. Promoted Change Plan Items (7 items) to `core-standards-release-plan.md` for `pass-the-parcel` Gate A.

---

## Related

- [Q&A](../q-and-a/SKILL.md) — requirements gathering with same live-.md JIT pattern (companion skill)
- [Wiki Lint](../wiki-lint/SKILL.md) — structural link/frontmatter health
- [Wiki Assessment](../wiki-assessment/SKILL.md) — document-level health and authority review
- [AI Rules](../../../.wiki/rules/language/ai-rules.md) — evidence ladder and no-fabrication guardrails
- [Plan template](../../../.devops/plans/template-plan.md) and [Pass-the-Parcel](../pass-the-parcel/SKILL.md) — change execution
- [Agent Wrap-Up](../agent-wrap-up/SKILL.md) — end-of-run summary

## See Also

- [Q&A](../q-and-a/SKILL.md) — gathering requirements before this confirmation step
- [Wiki Assessment](../wiki-assessment/SKILL.md) — document-level health and authority review
- [Wiki Lint](../wiki-lint/SKILL.md) — structural link/frontmatter health
- [Pass-the-Parcel](../pass-the-parcel/SKILL.md) — executing the changes this validation identifies
- [AI Rules](../../../.wiki/rules/language/ai-rules.md) — evidence ladder and no-fabrication guardrails
