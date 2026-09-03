---
name: pass-the-parcel
description: Make sure to use this skill whenever the user mentions "pass the parcel", "parcel mode", "/parcel", "token saving planning", "multi-agent planning", "stateless execution", "clear context", "independent reviewer", or wants to run a highly token-efficient, robust design-and-execution pipeline where state is passed entirely within a .md plan in .devops/plans/.
---

# SKILL: Pass-the-Parcel (Low-Token Self-Contained Agent Orchestration)

Execute highly complex multi-agent engineering workflows with minimal token usage by maintaining the entire system state, goals, reviews, and execution checklists in a self-contained markdown "parcel" file at `.devops/plans/[plan-name].md`. Each agent session operates stateless, reading the plan, executing its specific role, editing the plan, and immediately exiting without carrying conversation history.

---

## Trigger Conditions

* User invokes the `/parcel` command or mentions "pass the parcel" or "parcel mode".
* User requests a complex feature that requires multiple design, review, coding, and testing steps, while demanding token-efficiency.
* Agent detects a long-running or multi-agent task and wants to structure it to avoid context inflation and conversation memory creep.

---

## Plan State Lifecycle (Canonical Reference)

Every plan file **MUST** have:
- The full template scaffold with phases, gates, and checks.
- Its **State & Gates** section (bottom of the file) updated at each transition. 

The table below defines the only valid states. An AI agent reading the plan determines exactly where it is in the workflow from these two fields.

| Status | Active Persona | Directory | File Suffix | Gate | Meaning |
|---|---|---|---|---|---|
| `BACKLOG` | `Planner` | `.devops/backlog/` | `-backlog.md` | — | Early-prepared; not yet picked up for execution. Created by **backlog** skill. |
| `PHASE_1` | `Scoper` | `.devops/plans/` | `-plan.md` | — | Picked up from backlog. Scoping & context gathering in progress. |
| `PHASE_3` | `Scoper` | `.devops/plans/` | `-plan.md` | — | User clarifications complete. Proceeding directly to wiki spec (no halt). |
| `PHASE_4` | `High-Visionary` | `.devops/plans/` | `-plan.md` | — | Wiki requirements spec + acceptance criteria written (docs marked `in-progress`). Intermediate — no halt; reviewed with the plan at Gate A. |
| `PHASE_5` | `High-Visionary` | `.devops/plans/` | `-plan.md` | Gate A | Standard implementation plan written. Awaiting spec & plan approval. |
| `PHASE_5_REVISION` | `High-Visionary` | `.devops/plans/` | `-plan.md` | Gate A | Phase 6/7 review failed. Plan returned to Group B for fixes. |
| `PHASE_7` | `Reviewer` | `.devops/plans/` | `-plan.md` | Gate B | Peer reviews complete. Awaiting approval to execute. |
| `PHASE_9` | `Executor` | `.devops/plans/` | `-plan.md` | Gate B | Implementation done, verified. Awaiting user sign-off. |
| `COMPLETE` | — | `.devops/archive/` | `-plan.md` | — | Plan archived. No further action. |

**Lifecycle flow:** `BACKLOG` → *(pickup)* → `PHASE_1` → `PHASE_3` → `PHASE_4` → `PHASE_5` → `PHASE_7` → `PHASE_9` → `COMPLETE`

**Revision loop (deterministic rejection):** `PHASE_7` → *(Phase 6 or 7 fails)* → `PHASE_5_REVISION` → *(Group B fixes)* → `PHASE_5` → `PHASE_7` (re-evaluated at Gate B)

**Key rules:**
- **Status must match phase:** The `Status` field always reflects the highest completed phase. E.g., if Phases 1-5 are done, Status is `PHASE_5`, not `PHASE_3` or `PROPOSED`.
- **Persona changes with phase:** `Scoper` owns Phases 1-3, `High-Visionary` owns Phases 4-5 (+ `PHASE_5_REVISION` fixes), `Reviewer` owns Phases 6-7, `Executor` owns Phases 8-9.
- **DO NOT use `PROPOSED` or `Architect`** — these are legacy defaults from the raw template. Always overwrite them with a valid state from the table above.
- **No amount of urgency allows skipping gates:** Each gate is a hard stop. Agents **MUST** halt and wait for user approval before proceeding to the next phase grouping.

> **🔒 Cache-anchor rule:** The State Dashboard + Gate Log are the **last section** (`## 📍 State & Gates`) of every plan file. Gate transitions mutate ONLY those bottom rows; phase content above stays byte-stable to preserve LLM prefix-cache hits. Every instruction below that says "Update State Dashboard" means "update the bottom State & Gates section".

---

## Skill Delegation Map (Persona → Sub-Skill)

Pass-the-parcel is a **thin orchestrator**. Each phase group delegates to a specialized sub-skill that owns the detailed directives. The `Active Persona` field in the **State & Gates** section (bottom of the plan) identifies **who owns the work**; the delegated skill provides **how the work is done**.

| Group | Phase(s) | Active Persona | Delegated Skill | Model Assignment | Scope | Gate |
|---|---|---|---|---|---|---|
| A | 1-3 | `Scoper` | `ptp-context-hunter` | mimo-2.5 | ptp sub-skill | A |
| B | 4 | `High-Visionary` | `ptp-high-visionary` (+ `wiki-writer` for spec prose) | mimo-2.5 | ptp sub-skill | B |
| B | 5 | `High-Visionary` | `ptp-high-visionary` | mimo-2.5 | ptp sub-skill | B |
| B | 5 (revision) | `High-Visionary` | `ptp-high-visionary` | mimo-2.5 | ptp sub-skill | B |
| C | 6 | `Reviewer` | `ptp-grumpy-architect` | v4-flash-max | ptp sub-skill | C |
| C | 7 | `Reviewer` | `ptp-smooth-operator` | mimo-2.5 | ptp sub-skill | C |
| D | 8 | `Executor` | `ptp-code-surgeon` | deepseek-v4-flash | ptp sub-skill | D |
| D | 9 | `Executor` | `ptp-code-surgeon` | deepseek-v4-flash | ptp sub-skill | D |
| E | 10 | `Reviewer` | `knowledge-capture` (on demand) | — | global | — |
| F | Wrap Up | `Lead Context Architect` | `agent-wrap-up` | mimo-2.5 | global | — |

**Model Registry (canonical identifiers — use these EXACTLY, no aliases):**
- **`mimo-2.5`**: Orchestrator model. Handles planning, context gathering, product review, and wrap-up. Balanced capability across all tasks.
- **`v4-flash-max`**: Assigned to Phase 6 (Grumpy Architect / Spec & Logic Audit) for rigorous architectural review.
- **`deepseek-v4-flash`**: Assigned to Phases 8-9 (Code Surgeon execution + QA tweaks) with ponytail coding.

**Ambiguity rule:** The identifiers above are the ONLY valid strings. `v4 flash`, `deepseek v4 flash`, `v4 flash max`, `flash-max` are deprecated aliases and MUST be normalized to `mimo-2.5`, `v4-flash-max`, or `deepseek-v4-flash`.

> **Canonical copy:** This delegation map + model registry is inlined into every parcel-* agent via the PREFIX-LOCKED header (`.opencode/plans/base-context.md`). When editing the map, update `base-context.md` and run `scripts\check-parcel-prefix.ps1 -Sync` to re-inline it — then mirror the change here.

**Naming convention:**
* **`ptp-*` prefix** = pass-the-parcel sub-skill. Lives in `.devops/skills/ptp-*/SKILL.md`. The full directive detail lives in these skills — pass-the-parcel only references them.
* **No prefix** = global skill. Used where the work is not pass-the-parcel-specific (e.g., project-wide wrap-up, knowledge capture).

**Execution rule:** When a Group step says `CRITICAL: Initialize and execute the \`[skill-name]\` skill`, the agent **MUST** load and execute that skill. The persona's directives are not duplicated in pass-the-parcel; they are owned by the sub-skill. Pass-the-parcel handles lifecycle, gates, halt points, and state transitions only.


**Plan trace:** Every phase in the parcel template records the executed skill and model in its `Skill Executed` field for auditability.


---

## Review Gates & Context Isolation Protocol

To prevent context inflation and ensure complete control over design and execution, the agent **MUST** adhere to strict execution boundaries:

1. **Strict Context Isolation (Single Phase Rule):**
   - The agent is permitted to execute **ONLY ONE** phase grouping (e.g., scoping, planning, or executing) per conversation session.
   - Once a phase grouping is updated in the plan, the agent **MUST save the plan and immediately halt** (conclude the turn). It must never proceed to subsequent phases or touch code without the user explicitly initiating the next session.
   
2. **The Mandatory Review Gates:**
   - **Gate A (Spec & Plan Review):** Stop after completing **Phases 4-5** (or a `PHASE_5_REVISION` fix round). Present the wiki requirements spec with acceptance criteria AND the standard implementation plan together as one decision — what it will do and what it will cost — then halt. Next agent handles Phases 6-7 reviews.
   - **Gate B (Peer Reviews Complete):** Stop after completing **Phases 6-7** (Grumpy Architect Spec & Logic Audit + Product Owner review). Present findings and required fixes. **If a review failed, set `PHASE_5_REVISION` and return to Group B — do not proceed to execution.** Wait for approval before proceeding to execution.
   - **Gate B (Implementation Complete):** Stop after completing **Phases 8-9** (Execution & QA verification). Present the verification results and file changes. Wait for user testing and sign-off.

---

## Linguistic Rules (Caveman Integration)

To maximize token-savings during interaction and within the plan updates, agents must adhere to strict **Linguistic Token Compression**:
* **Terse Communication:** Drop pleasantries ("sure", "happy to help"), articles ("a", "an", "the"), fillers ("just", "actually"), and hedging.
* **Fragments & Arrows:** Write in fragments and use arrows for causality (`X -> Y`). Keep sentences short.
* **Abbreviate:** Use standard shorthand (e.g., `impl`, `spec`, `req`, `fn`, `test`, `auth`, `DB`).
* **Brevity first:** Only include exact, necessary code blocks or errors. Let the plan file speak for itself.

---

## Execution Steps

### Backlog Pick-up Flow (Pre-Phase 1)
If the requested feature exists as a backlog item:
1. Locate its early-prepared backlog plan file at `.devops/backlog/<feature-slug>-backlog.md` (suffixed with `-backlog`, Status `BACKLOG`, Persona `Planner`).
2. Move (rename) this file to `.devops/plans/<feature-slug>-plan.md` (suffixed with `-plan`). **This file rename is the signal that the item is now active — `-backlog` means parked, `-plan` means in flight.**
3. Update the **State & Gates** section (bottom of the plan) per the [Lifecycle table](#plan-state-lifecycle-canonical-reference):
   - **Status** → `PHASE_1`
   - **Active Persona** → `Scoper`
   - **Gate A** → `OPEN`.
4. Remove the item from the active checklist in `.devops/backlog/backlog-index.md`.
5. Proceed to **Group A** (Phases 1-3). The backlog plan contains pre-populated context — use it for Phases 1-2, but **Phase 3 MUST still be re-run interactively** per the [Fresh Context Rule](#fresh-context-rule). The pre-populated Phase 3 answers serve as reference only — they do not exempt the agent from asking questions.

### GROUP A: Scoping & Context (Phases 1-3)
* **Model:** mimo-2.5
* **Goal:** Understand intent, locate context, resolve ambiguities.
* **Pre-Step — Plan Initialization:** If this is a fresh feature, instantiate `.devops/plans/<feature-slug>-plan.md` from the [canonical template](../../../plans/template-plan.md). This gives the plan the **full scaffold** (Phases 1-10 + State & Gates at bottom) from the start — all downstream agents rely on this structure. If this item was picked up from the backlog, **do not overwrite it** — skip directly to executing the sub-skill to preserve the pre-populated context. Set initial **State & Gates** section (bottom): **Status** → `PHASE_1`, **Active Persona** → `Scoper`.
* **Steps:**
  * **Phase 1 (Expansion & Scoping):**
    * **CRITICAL:** Initialize and execute the **`ptp-context-hunter`** skill to hydrate the plan, expand the request, and lock the In-Scope / Out-of-Scope perimeter.
  * **Phase 2 (Requirements Gathering):**
    * **CRITICAL:** Continue executing the **`ptp-context-hunter`** skill to run the Forensic Context Inventory — wiki core docs, knowledge capture, and source code verification.
  * **Phase 3 (User Clarification):**
    * **CRITICAL:** Continue executing the **`ptp-context-hunter`** skill to interrogate the user interactively, surface architectural conflicts inline, and capture the final gate-A validation before advancing.
* **NO HALT after Phase 3:** Once the final validation question is answered Yes and Phase 3 is fully populated, set **Status** → `PHASE_3` and proceed **directly into Group B** — the human reviews the *formalized* requirements at Gate A (after Phase 4), not the raw scope.

### GROUP B: Wiki Spec & Implementation Planning (Phases 4-5)
* **Model:** mimo-2.5
* **Goal:** Write the wiki requirements spec FIRST (Phase 4), then build the implementation plan to meet it (Phase 5). No code snippets unless absolutely necessary.
* **Steps:**
  * **Phase 4 (Wiki Requirements & Acceptance Criteria):**
    * **CRITICAL:** Continue executing the **`ptp-high-visionary`** skill — its Phase 4 directives mandate the **`@wiki-writer`** discipline for all spec prose. Write/update the wiki docs that describe the target behavior (marked `status: in-progress` — a pre-code doc is a claim, not truth), define acceptance criteria, and name test targets. **Conditional:** skip only when the task changes no user-visible behavior or logic contract — record "no wiki delta — rationale: …" in the plan.
  * **Phase 5 (High-Visionary Execution Plan):**
    * **CRITICAL:** Initialize and execute the **`ptp-high-visionary`** skill to convert the Phase 1-3 scope + Phase 4 spec into a standard implementation plan. Focus on **what needs to happen** rather than exact code. Include file paths, component names, and architectural decisions, but **no code snippets** unless the task is impossible to describe without them (e.g., complex type definitions, API contracts). Reject on bloat or vagueness.
  * **Phase 5 Revision (PHASE_5_REVISION):**
    * When a plan returns in state `PHASE_5_REVISION` (Phase 6 or 7 review failed), the High-Visionary re-executes on the SAME plan file to apply the flagged fixes. Address every `BLOCK`/`REJECTED` item from the review, update the plan, and set Status → `PHASE_5` for re-review. Do not treat the review comments as optional.
* **HALT POINT (Gate A — Spec & Plan Review):** Update the **State & Gates** section (bottom of the plan) per the [Lifecycle table](#plan-state-lifecycle-canonical-reference): **Status** → `PHASE_5`, **Active Persona** → `High-Visionary`, **Gate A** → `APPROVED`. Present the wiki requirements spec (with acceptance criteria) AND the implementation plan together as one decision. **Stop execution immediately. Next agent handles Phases 6-7 reviews.**

### GROUP C: Peer Reviews (Phases 6-7)
* **Goal:** Peer-review the text-based architecture for logical completeness, edge cases, and UX alignment. **Phase 6 audits the SPEC — the plan contains no code, so no code-level scans (DRY/WET, line checks) are performed.**
* **Steps:**
  * **Phase 6 (Grumpy Architect Spec & Logic Audit):**
    * **Model:** v4-flash-max
    * **CRITICAL:** Initialize and execute the **`ptp-grumpy-architect`** skill as a **Spec & Logic Audit** of the text-based architecture produced in Phase 5. Evaluate: system contracts, edge cases, file boundary collisions, dependency gaps, YAGNI bloat, performance trade-offs, logical completeness, security perimeter, and architectural anti-patterns. **Do not expect or demand source code snippets in the plan file.** Reject on logical gaps or bloat.
  * **Phase 7 (Smooth Operator Product Review):**
    * **Model:** mimo-2.5
    * **CRITICAL:** Initialize and execute the **`ptp-smooth-operator`** skill to audit the Phase 5 plan. Ensure strict alignment with user journey, 4 core states, and scope containment. Reject on UX friction.
* **Deterministic Rejection State (Gate B):**
  * **Pass:** Phase 6 log clean → proceed to Phase 7 (PO Intent Check) → set `PHASE_7` → halt at Gate B for user sign-off.
  * **Fail:** Phase 6 or 7 logs blocking architectural flaws → set `PHASE_5_REVISION` → return to Group B (High-Visionary) for plan adjustments → re-run Phase 6/7 → re-evaluate Gate B. **Never advance an unapproved plan toward execution.**
* **HALT POINT (Gate B):** Update the **State & Gates** section (bottom of the plan) per the [Lifecycle table](#plan-state-lifecycle-canonical-reference): **Status** → `PHASE_7` (pass) or `PHASE_5_REVISION` (fail), **Active Persona** → `Reviewer` (pass) or `High-Visionary` (fail), **Gate B** → `APPROVED` (pass) or `REJECTED` (fail). Present the review findings and required fixes. **Stop execution immediately. Do NOT touch any codebase files or run commands yet. Wait for explicit user approval to execute.**

### GROUP D: Execution & Verification (Phases 8-9)
* **Goal:** Code features strictly to plan, run QA, prove stability.
* **Execution Isolation:** Phase 8 **only triggers after Gate B is cleared by explicit user input.** No execution before explicit approval.
* **Steps:**
  * **Phase 8 (Execute Changes):**
    * **Model:** deepseek-v4-flash
    * **CRITICAL:** Initialize and execute the **`ptp-code-surgeon`** skill to apply Phase 5 edits. **Single-pass direct-to-disk execution:** ingest the text spec and write implementation code DIRECTLY to workspace source files — no multi-pass drafting inside intermediate Markdown files, no staging code blocks in the plan. Use **ponytail coding** style — surgical, minimal, efficient edits that respect existing patterns. Touch only intended lines, clean up only owned orphans, track execution incrementally, and halt on any unresolvable error.
  * **Phase 9 (Verify Changes):**
    * **Model:** deepseek-v4-flash
    * **CRITICAL:** Continue executing the **`ptp-code-surgeon`** skill to run compilation/tests/lint, log proof in the plan, and verify runtime stability before declaring the gate clear. Apply any necessary tweaks identified during QA.
* **HALT POINT (Gate B):** Update the **State & Gates** section (bottom of the plan) per the [Lifecycle table](#plan-state-lifecycle-canonical-reference): **Status** → `PHASE_9`, **Active Persona** → `Executor`, **Gate B** → `APPROVED`. Present completed work and QA verification report. **Stop execution immediately and wait for user to test and sign off.**

### GROUP E: User Review & Tweaks (Phase 10)
* **Goal:** User performs testing and provides feedback. Iterative back-and-forth with agent for tweaks, with important lessons captured to improve future outputs.
* **Steps:**
  * **Phase 10 (User Review & Tweaks):** User tests the implementation. Agent and user iterate on feedback. **All tweaks are logged inline in this plan's Phase 10 `Back-and-Forth Log`** (one entry per round: User Feedback → Tweaks Applied → Result). Phase complete when user signs off.
  * **Knowledge Capture Hook:** After *every* tweak, evaluate whether it carries a **lesson worth preserving** and, if so, initialize the **`knowledge-capture`** skill (global). The trigger is **not** "shared theme" alone — capture anything that would help the next agent. The qualifying categories are:
      * **Recurring pattern** — same correction needed twice or more across rounds.
      * **Tribal-knowledge decision** — non-obvious project rule, convention, or constraint (e.g., "we never mutate X in this codebase").
      * **Significant one-off** — a single bug, gotcha, clever fix, or surprising requirement that even a fresh agent would benefit from knowing.
    * **Data flow:** raw tweaks stay in the Phase 10 log. Any tweak that meets the bar above is promoted to `.wiki/core/18-knowledge-capture.md` via the `knowledge-capture` skill, then consolidated in Wrap Up by `agent-wrap-up`. **Default to capture; skip only when the tweak is purely cosmetic (typo, formatting) with no underlying lesson.**
* **COMPLETION:** Phase 10 done when user provides explicit sign-off.

### GROUP F: Wrap Up (Document Tweaks, Spec Reconciliation & Close-Out)
* **Model:** mimo-2.5
* **Goal:** Document all tweaks from Phase 10, promote captured lessons to the knowledge log, reconcile the wiki against what was actually built, and close out the plan.
* **Steps:**
  * **Wrap Up:**
     * **CRITICAL:** Initialize and execute the **`agent-wrap-up`** skill (global) to log Phase 10 tweaks, sync captured lessons (per Phase 10 `Capture Flag`) to the project's knowledge capture log, reconcile code against the Phase 4 spec, **promote `status: in-progress` wiki docs to `stable`** (or log the deviation), update wiki docs, archive the plan to `.devops/archive/`, review backlog items, and set the **State & Gates** section (bottom) → `COMPLETE` (all gates `APPROVED`). **If Phase 6 flagged any dead code or orphans, create a backlog entry** at `.devops/backlog/<slug>-backlog.md` with a terse description, affected file paths, and a reference to the original plan.
* **END:** All phases complete. Plan archived. Session ended.

---

## Parcel Markdown Template

> **Canonical Template Reference:** Always base new plan files on the canonical template at
> [`.devops/plans/template-plan.md`](../../../plans/template-plan.md)
> Read this file before creating any plan to ensure you use the latest structure. Do not copy or duplicate this structure in the main skill file.
