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
| `PHASE_1` | `Scoper` | `.devops/plans/` | `-plan.md` | Gate A | Picked up from backlog. Scoping & context gathering in progress. |
| `PHASE_3` | `Scoper` | `.devops/plans/` | `-plan.md` | Gate A | User clarifications complete. Awaiting scope approval. |
| `PHASE_4` | `High-Visionary` | `.devops/plans/` | `-plan.md` | Gate B | Standard implementation plan written. Awaiting review handoff. |
| `PHASE_4_REVISION` | `High-Visionary` | `.devops/plans/` | `-plan.md` | Gate B | Phase 5/6 review failed. Plan returned to Group B for fixes. |
| `PHASE_6` | `Reviewer` | `.devops/plans/` | `-plan.md` | Gate C | Peer reviews complete. Awaiting approval to execute. |
| `PHASE_8` | `Executor` | `.devops/plans/` | `-plan.md` | Gate D | Implementation done, verified. Awaiting user sign-off. |
| `COMPLETE` | — | `.devops/archive/` | `-plan.md` | — | Plan archived. No further action. |

**Lifecycle flow:** `BACKLOG` → *(pickup)* → `PHASE_1` → `PHASE_3` → `PHASE_4` → `PHASE_6` → `PHASE_8` → `COMPLETE`

**Revision loop (deterministic rejection):** `PHASE_6` → *(Phase 5 or 6 fails)* → `PHASE_4_REVISION` → *(Group B fixes)* → `PHASE_4` → `PHASE_6` (re-evaluated at Gate C)

**Key rules:**
- **Status must match phase:** The `Status` field always reflects the highest completed phase. E.g., if Phases 1-4 are done, Status is `PHASE_4`, not `PHASE_3` or `PROPOSED`.
- **Persona changes with phase:** `Scoper` owns Phases 1-3, `High-Visionary` owns Phase 4 (+ `PHASE_4_REVISION` fixes), `Reviewer` owns Phases 5-6, `Executor` owns Phases 7-8.
- **DO NOT use `PROPOSED` or `Architect`** — these are legacy defaults from the raw template. Always overwrite them with a valid state from the table above.
- **No amount of urgency allows skipping gates:** Each gate is a hard stop. Agents **MUST** halt and wait for user approval before proceeding to the next phase grouping.

> **🔒 Cache-anchor rule:** The State Dashboard + Gate Log are the **last section** (`## 📍 State & Gates`) of every plan file. Gate transitions mutate ONLY those bottom rows; phase content above stays byte-stable to preserve LLM prefix-cache hits. Every instruction below that says "Update State Dashboard" means "update the bottom State & Gates section".

---

## Skill Delegation Map (Persona → Sub-Skill)

Pass-the-parcel is a **thin orchestrator**. Each phase group delegates to a specialized sub-skill that owns the detailed directives. The `Active Persona` field in the **State & Gates** section (bottom of the plan) identifies **who owns the work**; the delegated skill provides **how the work is done**.

| Group | Phase(s) | Active Persona | Delegated Skill | Model Assignment | Scope | Gate |
|---|---|---|---|---|---|---|
| A | 1-3 | `Scoper` | `ptp-context-hunter` | mimo-2.5 | ptp sub-skill | A |
| B | 4 | `High-Visionary` | `ptp-high-visionary` | mimo-2.5 | ptp sub-skill | B |
| B | 4 (revision) | `High-Visionary` | `ptp-high-visionary` | mimo-2.5 | ptp sub-skill | B |
| C | 5 | `Reviewer` | `ptp-grumpy-architect` | v4-flash-max | ptp sub-skill | C |
| C | 6 | `Reviewer` | `ptp-smooth-operator` | mimo-2.5 | ptp sub-skill | C |
| D | 7 | `Executor` | `ptp-code-surgeon` | deepseek-v4-flash | ptp sub-skill | D |
| D | 8 | `Executor` | `ptp-code-surgeon` | deepseek-v4-flash | ptp sub-skill | D |
| E | 9 | `Reviewer` | `knowledge-capture` (on demand) | — | global | — |
| F | 10 + Wrap Up | `Lead Context Architect` | `agent-wrap-up` | mimo-2.5 | global | — |

**Model Registry (canonical identifiers — use these EXACTLY, no aliases):**
- **`mimo-2.5`**: Orchestrator model. Handles planning, context gathering, product review, and wrap-up. Balanced capability across all tasks.
- **`v4-flash-max`**: Assigned to Phase 5 (Grumpy Architect / Spec & Logic Audit) for rigorous architectural review.
- **`deepseek-v4-flash`**: Assigned to Phases 7-8 (Code Surgeon execution + QA tweaks) with ponytail coding.

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
   - **Gate A (Scope & Context Review):** Stop after completing **Phases 1-3**. Present the expanded scope and clarification questions, then halt. Do not write a detailed technical plan or touch files.
   - **Gate B (Plan Review):** Stop after completing **Phase 4** (or a `PHASE_4_REVISION` fix round). Present the standard implementation plan with to-do list and wiki doc notes, then halt. Next agent handles Phases 5-6 reviews.
   - **Gate C (Peer Reviews Complete):** Stop after completing **Phases 5-6** (Grumpy Architect Spec & Logic Audit + Product Owner review). Present findings and required fixes. **If a review failed, set `PHASE_4_REVISION` and return to Group B — do not proceed to execution.** Wait for approval before proceeding to execution.
   - **Gate D (Implementation Complete):** Stop after completing **Phases 7-8** (Execution & QA verification). Present the verification results and file changes. Wait for user testing and sign-off.

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
* **HALT POINT (Gate A):** Once the final validation question is answered Yes and Phase 3 is fully populated, update the **State & Gates** section (bottom of the plan) per the [Lifecycle table](#plan-state-lifecycle-canonical-reference): **Status** → `PHASE_3`, **Active Persona** → `Scoper`, **Gate A** → `APPROVED`. Present the scoping summary and Phase 3 answers. **Stop execution immediately and wait for the user to approve the scope before proceeding to Group B.**

### GROUP B: High-Visionary Planning (Phase 4)
* **Model:** mimo-2.5
* **Goal:** Produce a standard implementation plan based on gathered context. No code snippets unless absolutely necessary.
* **Steps:**
  * **Phase 4 (High-Visionary Execution Plan):**
    * **CRITICAL:** Initialize and execute the **`ptp-high-visionary`** skill to convert the Phase 1-3 scope into a standard implementation plan. Focus on **what needs to happen** rather than exact code. Include file paths, component names, and architectural decisions, but **no code snippets** unless the task is impossible to describe without them (e.g., complex type definitions, API contracts). Reject on bloat or vagueness.
  * **Phase 4 Revision (PHASE_4_REVISION):**
    * When a plan returns in state `PHASE_4_REVISION` (Phase 5 or 6 review failed), the High-Visionary re-executes on the SAME plan file to apply the flagged fixes. Address every `BLOCK`/`REJECTED` item from the review, update the plan, and set Status → `PHASE_4` for re-review. Do not treat the review comments as optional.
* **HALT POINT (Gate B):** Update the **State & Gates** section (bottom of the plan) per the [Lifecycle table](#plan-state-lifecycle-canonical-reference): **Status** → `PHASE_4`, **Active Persona** → `High-Visionary`, **Gate B** → `APPROVED`. Present the standard implementation plan. **Stop execution immediately. Next agent handles Phases 5-6 reviews.**

### GROUP C: Peer Reviews (Phases 5-6)
* **Goal:** Peer-review the text-based architecture for logical completeness, edge cases, and UX alignment. **Phase 5 audits the SPEC — the plan contains no code, so no code-level scans (DRY/WET, line checks) are performed.**
* **Steps:**
  * **Phase 5 (Grumpy Architect Spec & Logic Audit):**
    * **Model:** v4-flash-max
    * **CRITICAL:** Initialize and execute the **`ptp-grumpy-architect`** skill as a **Spec & Logic Audit** of the text-based architecture produced in Phase 4. Evaluate: system contracts, edge cases, file boundary collisions, dependency gaps, YAGNI bloat, performance trade-offs, logical completeness, security perimeter, and architectural anti-patterns. **Do not expect or demand source code snippets in the plan file.** Reject on logical gaps or bloat.
  * **Phase 6 (Smooth Operator Product Review):**
    * **Model:** mimo-2.5
    * **CRITICAL:** Initialize and execute the **`ptp-smooth-operator`** skill to audit the Phase 4 plan. Ensure strict alignment with user journey, 4 core states, and scope containment. Reject on UX friction.
* **Deterministic Rejection State (Gate C):**
  * **Pass:** Phase 5 log clean → proceed to Phase 6 (PO Intent Check) → set `PHASE_6` → halt at Gate C for user sign-off.
  * **Fail:** Phase 5 or 6 logs blocking architectural flaws → set `PHASE_4_REVISION` → return to Group B (High-Visionary) for plan adjustments → re-run Phase 5/6 → re-evaluate Gate C. **Never advance an unapproved plan toward execution.**
* **HALT POINT (Gate C):** Update the **State & Gates** section (bottom of the plan) per the [Lifecycle table](#plan-state-lifecycle-canonical-reference): **Status** → `PHASE_6` (pass) or `PHASE_4_REVISION` (fail), **Active Persona** → `Reviewer` (pass) or `High-Visionary` (fail), **Gate C** → `APPROVED` (pass) or `REJECTED` (fail). Present the review findings and required fixes. **Stop execution immediately. Do NOT touch any codebase files or run commands yet. Wait for explicit user approval to execute.**

### GROUP D: Execution & Verification (Phases 7-8)
* **Goal:** Code features strictly to plan, run QA, prove stability.
* **Execution Isolation:** Phase 7 **only triggers after Gate C is cleared by explicit user input.** No execution before explicit approval.
* **Steps:**
  * **Phase 7 (Execute Changes):**
    * **Model:** deepseek-v4-flash
    * **CRITICAL:** Initialize and execute the **`ptp-code-surgeon`** skill to apply Phase 4 edits. **Single-pass direct-to-disk execution:** ingest the text spec and write implementation code DIRECTLY to workspace source files — no multi-pass drafting inside intermediate Markdown files, no staging code blocks in the plan. Use **ponytail coding** style — surgical, minimal, efficient edits that respect existing patterns. Touch only intended lines, clean up only owned orphans, track execution incrementally, and halt on any unresolvable error.
  * **Phase 8 (Verify Changes):**
    * **Model:** deepseek-v4-flash
    * **CRITICAL:** Continue executing the **`ptp-code-surgeon`** skill to run compilation/tests/lint, log proof in the plan, and verify runtime stability before declaring the gate clear. Apply any necessary tweaks identified during QA.
* **HALT POINT (Gate D):** Update the **State & Gates** section (bottom of the plan) per the [Lifecycle table](#plan-state-lifecycle-canonical-reference): **Status** → `PHASE_8`, **Active Persona** → `Executor`, **Gate D** → `APPROVED`. Present completed work and QA verification report. **Stop execution immediately and wait for user to test and sign off.**

### GROUP E: User Review & Tweaks (Phase 9)
* **Goal:** User performs testing and provides feedback. Iterative back-and-forth with agent for tweaks, with important lessons captured to improve future outputs.
* **Steps:**
  * **Phase 9 (User Review & Tweaks):** User tests the implementation. Agent and user iterate on feedback. **All tweaks are logged inline in this plan's Phase 9 `Back-and-Forth Log`** (one entry per round: User Feedback → Tweaks Applied → Result). Phase complete when user signs off.
  * **Knowledge Capture Hook:** After *every* tweak, evaluate whether it carries a **lesson worth preserving** and, if so, initialize the **`knowledge-capture`** skill (global). The trigger is **not** "shared theme" alone — capture anything that would help the next agent. The qualifying categories are:
      * **Recurring pattern** — same correction needed twice or more across rounds.
      * **Tribal-knowledge decision** — non-obvious project rule, convention, or constraint (e.g., "we never mutate X in this codebase").
      * **Significant one-off** — a single bug, gotcha, clever fix, or surprising requirement that even a fresh agent would benefit from knowing.
    * **Data flow:** raw tweaks stay in the Phase 9 log. Any tweak that meets the bar above is promoted to `.wiki/core/18-knowledge-capture.md` via the `knowledge-capture` skill, then consolidated in Phase 10 by `agent-wrap-up`. **Default to capture; skip only when the tweak is purely cosmetic (typo, formatting) with no underlying lesson.**
* **COMPLETION:** Phase 9 done when user provides explicit sign-off.

### GROUP F: Document Tweaks & Wrap Up (Phase 10 + Wrap Up)
* **Model:** mimo-2.5
* **Goal:** Document all tweaks from Phase 9, promote captured lessons to the knowledge log, and close out the plan.
* **Steps:**
  * **Phase 10 (Document Tweaks & Knowledge Capture):**
    * **CRITICAL:** Initialize and execute the **`agent-wrap-up`** skill (global) to log Phase 9 tweaks, sync captured lessons (per Phase 9 `Capture Flag`) to the project's knowledge capture log, and confirm any open capture items are resolved.
  * **Wrap Up:**
     * **CRITICAL:** Continue executing the **`agent-wrap-up`** skill (global) to update wiki docs, archive the plan to `.devops/archive/`, review backlog items, and set the **State & Gates** section (bottom) → `COMPLETE` (all gates `APPROVED`). **If Phase 5 flagged any dead code or orphans, create a backlog entry** at `.devops/backlog/<slug>-backlog.md` with a terse description, affected file paths, and a reference to the original plan.
* **END:** All phases complete. Plan archived. Session ended.

---

## Parcel Markdown Template

> **Canonical Template Reference:** Always base new plan files on the canonical template at
> [`.devops/plans/template-plan.md`](../../../plans/template-plan.md)
> Read this file before creating any plan to ensure you use the latest structure. Do not copy or duplicate this structure in the main skill file.
