---
name: pass-the-parcel
description: Make sure to use this skill whenever the user mentions "pass the parcel", "parcel mode", "/parcel", "token saving planning", "multi-agent planning", "stateless execution", "clear context", "independent reviewer", or wants to run a highly token-efficient, robust design-and-execution pipeline where state is passed entirely within a .md plan in docs/plans/.
---

# SKILL: Pass-the-Parcel (Low-Token Self-Contained Agent Orchestration)

Execute highly complex multi-agent engineering workflows with minimal token usage by maintaining the entire system state, goals, reviews, and execution checklists in a self-contained markdown "parcel" file at `docs/plans/[plan-name].md`. Each agent session operates stateless, reading the plan, executing its specific role, editing the plan, and immediately exiting without carrying conversation history.

---

## Trigger Conditions

* User invokes the `/parcel` command or mentions "pass the parcel" or "parcel mode".
* User requests a complex feature that requires multiple design, review, coding, and testing steps, while demanding token-efficiency.
* Agent detects a long-running or multi-agent task and wants to structure it to avoid context inflation and conversation memory creep.

---

## Plan State Lifecycle (Canonical Reference)

Every plan file **MUST** have:
- The full template scaffold with phases, gates, and checks.
- Its State Dashboard updated at each transition. 

The table below defines the only valid states. An AI agent reading the plan determines exactly where it is in the workflow from these two fields.

| Status | Active Persona | Directory | File Suffix | Gate | Meaning |
|---|---|---|---|---|---|
| `BACKLOG` | `Planner` | `docs/backlog/` | `-backlog.md` | — | Early-prepared; not yet picked up for execution. Created by **backlog** skill. |
| `PHASE_1` | `Scoper` | `docs/plans/` | `-plan.md` | Gate A | Picked up from backlog. Scoping & context gathering in progress. |
| `PHASE_3` | `Scoper` | `docs/plans/` | `-plan.md` | Gate A | User clarifications complete. Awaiting scope approval. |
| `PHASE_4` | `Planner` | `docs/plans/` | `-plan.md` | Gate B | Detailed execution plan written. Awaiting review handoff. |
| `PHASE_6` | `Reviewer` | `docs/plans/` | `-plan.md` | Gate C | Peer reviews complete. Awaiting approval to execute. |
| `PHASE_8` | `Executor` | `docs/plans/` | `-plan.md` | Gate D | Implementation done, verified. Awaiting user sign-off. |
| `COMPLETE` | — | `docs/archive-plans/` | `-plan.md` | — | Plan archived. No further action. |

**Lifecycle flow:** `BACKLOG` → *(pickup)* → `PHASE_1` → `PHASE_3` → `PHASE_4` → `PHASE_6` → `PHASE_8` → `COMPLETE`

**Key rules:**
- **Status must match phase:** The `Status` field always reflects the highest completed phase. E.g., if Phases 1-4 are done, Status is `PHASE_4`, not `PHASE_3` or `PROPOSED`.
- **Persona changes with phase:** `Scoper` owns Phases 1-3, `Planner` owns Phase 4, `Reviewer` owns Phases 5-6, `Executor` owns Phases 7-8.
- **DO NOT use `PROPOSED` or `Architect`** — these are legacy defaults from the raw template. Always overwrite them with a valid state from the table above.
- **No amount of urgency allows skipping gates:** Each gate is a hard stop. Agents **MUST** halt and wait for user approval before proceeding to the next phase grouping.

---

## Skill Delegation Map (Persona → Sub-Skill)

Pass-the-parcel is a **thin orchestrator**. Each phase group delegates to a specialized sub-skill that owns the detailed directives. The `Active Persona` field in the State Dashboard identifies **who owns the work**; the delegated skill provides **how the work is done**.

| Group | Phase(s) | Active Persona | Delegated Skill | Scope | Gate |
|---|---|---|---|---|---|
| A | 1-3 | `Scoper` | `ptp-context-hunter` | ptp sub-skill | A |
| B | 4 | `Planner` | `ptp-razor-planner` | ptp sub-skill | B |
| C | 5 | `Reviewer` | `ptp-smooth-operator` | ptp sub-skill | C |
| C | 6 | `Reviewer` | `ptp-grumpy-architect` | ptp sub-skill | C |
| D | 7-8 | `Executor` | `ptp-code-surgeon` | ptp sub-skill | D |
| E | 9 | `Reviewer` | `knowledge-capture` (on demand) | global | — |
| F | 10 + Wrap Up | `Executor` | `agent-wrap-up` | global | — |

**Naming convention:**
* **`ptp-*` prefix** = pass-the-parcel sub-skill. Lives in `.opencode/skills/ptp-*/SKILL.md`. The full directive detail lives in these skills — pass-the-parcel only references them.
* **No prefix** = global skill. Used where the work is not pass-the-parcel-specific (e.g., project-wide wrap-up, knowledge capture).

**Execution rule:** When a Group step says `CRITICAL: Initialize and execute the \`[skill-name]\` skill`, the agent **MUST** load and execute that skill. The persona's directives are not duplicated in pass-the-parcel; they are owned by the sub-skill. Pass-the-parcel handles lifecycle, gates, halt points, and state transitions only.

**Plan trace:** Every phase in the parcel template records the executed skill in its `Skill Executed` field for auditability.


---

## Review Gates & Context Isolation Protocol

To prevent context inflation and ensure complete control over design and execution, the agent **MUST** adhere to strict execution boundaries:

1. **Strict Context Isolation (Single Phase Rule):**
   - The agent is permitted to execute **ONLY ONE** phase grouping (e.g., scoping, planning, or executing) per conversation session.
   - Once a phase grouping is updated in the plan, the agent **MUST save the plan and immediately halt** (conclude the turn). It must never proceed to subsequent phases or touch code without the user explicitly initiating the next session.
   
2. **The Mandatory Review Gates:**
   - **Gate A (Scope & Context Review):** Stop after completing **Phases 1-3**. Present the expanded scope and clarification questions, then halt. Do not write a detailed technical plan or touch files.
   - **Gate B (Detailed Plan Review):** Stop after completing **Phase 4**. Present the detailed execution plan with to-do list, code snippets, and wiki doc notes, then halt. Next agent handles reviews in Phases 5-6.
   - **Gate C (Peer Reviews Complete):** Stop after completing **Phases 5-6** (Product Owner + Grumpy Architect reviews). Present findings and required fixes. Wait for approval before proceeding to execution.
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
1. Locate its early-prepared backlog plan file at `docs/backlog/<feature-slug>-backlog.md` (suffixed with `-backlog`, Status `BACKLOG`, Persona `Planner`).
2. Move (rename) this file to `docs/plans/<feature-slug>-plan.md` (suffixed with `-plan`). **This file rename is the signal that the item is now active — `-backlog` means parked, `-plan` means in flight.**
3. Update the State Dashboard per the [Lifecycle table](#plan-state-lifecycle-canonical-reference):
   - **Status** → `PHASE_1`
   - **Active Persona** → `Scoper`
   - **Last Updated** → current timestamp.
4. Remove the item from the active checklist in `docs/backlog/backlog-index.md`.
5. Proceed to **Group A** (Phases 1-3). The backlog plan contains pre-populated context — use it for Phases 1-2, but **Phase 3 MUST still be re-run interactively** per the [Fresh Context Rule](#fresh-context-rule). The pre-populated Phase 3 answers serve as reference only — they do not exempt the agent from asking questions.

### GROUP A: Scoping & Context (Phases 1-3)
* **Goal:** Understand intent, locate context, resolve ambiguities.
* **Pre-Step — Plan Initialization:** If this is a fresh feature, instantiate `docs/plans/<feature-slug>-plan.md` from the [canonical template](references/template-plan.md). This gives the plan the **full scaffold** (Phases 1-10 + Wrap Up) from the start — all downstream agents rely on this structure. If this item was picked up from the backlog, **do not overwrite it** — skip directly to executing the sub-skill to preserve the pre-populated context. Set initial State Dashboard: **Status** → `PHASE_1`, **Active Persona** → `Scoper`.
* **Steps:**
  * **Phase 1 (Expansion & Scoping):**
    * **CRITICAL:** Initialize and execute the **`ptp-context-hunter`** skill to hydrate the plan, expand the request, and lock the In-Scope / Out-of-Scope perimeter.
  * **Phase 2 (Requirements Gathering):**
    * **CRITICAL:** Continue executing the **`ptp-context-hunter`** skill to run the Forensic Context Inventory — wiki core docs, knowledge capture, and source code verification.
  * **Phase 3 (User Clarification):**
    * **CRITICAL:** Continue executing the **`ptp-context-hunter`** skill to interrogate the user interactively, surface architectural conflicts inline, and capture the final gate-A validation before advancing.
* **HALT POINT (Gate A):** Once the final validation question is answered Yes and Phase 3 is fully populated, update State Dashboard per the [Lifecycle table](#plan-state-lifecycle-canonical-reference): **Status** → `PHASE_3`, **Active Persona** → `Scoper`. Present the scoping summary and Phase 3 answers. **Stop execution immediately and wait for the user to approve the scope before proceeding to Group B.**

### GROUP B: Detailed Planning (Phase 4)
* **Goal:** Architect solution with exact file-level steps, to-do list, code snippets, and wiki doc notes.
* **Steps:**
  * **Phase 4 (Razor Planner Execution Plan):**
    * **CRITICAL:** Initialize and execute the **`ptp-razor-planner`** skill to convert the Phase 1-3 scope into a detailed execution plan. Climb the Simplicity Ladder on every proposed change, mark deliberate shortcuts with `ponytail:`, and produce a surgically dense plan with absolute file paths and wiki core citations. Reject on bloat or vagueness.
* **HALT POINT (Gate B):** Update State Dashboard per the [Lifecycle table](#plan-state-lifecycle-canonical-reference): **Status** → `PHASE_4`, **Active Persona** → `Planner`. Present the detailed execution plan. **Stop execution immediately. Next agent handles Phases 5-6 reviews.**

### GROUP C: Peer Reviews (Phases 5-6)
* **Goal:** Peer-review for quality, security, and standards utilizing specialized personas.
* **Steps:**
  * **Phase 5 (Smooth Operator Product Review):**
    * **CRITICAL:** Initialize and execute the **`ptp-smooth-operator`** skill to audit the Phase 4 plan. Ensure strict alignment with user journey, 4 core states, and scope containment. Reject on UX friction.
  * **Phase 6 (Grumpy Architect Hygiene Review):**
    * **CRITICAL:** Initialize and execute the **`ptp-grumpy-architect`** skill to forensically audit code quality. Run nuanced DRY/WET scans, security perimeter checks, and rate-limiting audits. Reject on bloat.
* **HALT POINT (Gate C):** Update State Dashboard per the [Lifecycle table](#plan-state-lifecycle-canonical-reference): **Status** → `PHASE_6`, **Active Persona** → `Reviewer`. Present the review findings and required fixes. **Stop execution immediately. Do NOT touch any codebase files or run commands yet. Wait for explicit user approval to execute.**

### GROUP D: Execution & Verification (Phases 7-8)
* **Goal:** Code features strictly to plan, run QA, prove stability.
* **Steps:**
  * **Phase 7 (Execute Changes):**
    * **CRITICAL:** Initialize and execute the **`ptp-code-surgeon`** skill to apply Phase 4 edits. Touch only intended lines, clean up only owned orphans, track execution incrementally, and halt on any unresolvable error.
  * **Phase 8 (Verify Changes):**
    * **CRITICAL:** Continue executing the **`ptp-code-surgeon`** skill to run compilation/tests/lint, log proof in the plan, and verify runtime stability before declaring the gate clear.
* **HALT POINT (Gate D):** Update State Dashboard per the [Lifecycle table](#plan-state-lifecycle-canonical-reference): **Status** → `PHASE_8`, **Active Persona** → `Executor`. Present completed work and QA verification report. **Stop execution immediately and wait for user to test and sign off.**

### GROUP E: User Review & Tweaks (Phase 9)
* **Goal:** User performs testing and provides feedback. Iterative back-and-forth with agent for tweaks, with important lessons captured to improve future outputs.
* **Steps:**
  * **Phase 9 (User Review & Tweaks):** User tests the implementation. Agent and user iterate on feedback. **All tweaks are logged inline in this plan's Phase 9 `Back-and-Forth Log`** (one entry per round: User Feedback → Tweaks Applied → Result). Phase complete when user signs off.
  * **Knowledge Capture Hook:** After *every* tweak, evaluate whether it carries a **lesson worth preserving** and, if so, initialize the **`knowledge-capture`** skill (global). The trigger is **not** "shared theme" alone — capture anything that would help the next agent. The qualifying categories are:
      * **Recurring pattern** — same correction needed twice or more across rounds.
      * **Tribal-knowledge decision** — non-obvious project rule, convention, or constraint (e.g., "we never mutate X in this codebase").
      * **Significant one-off** — a single bug, gotcha, clever fix, or surprising requirement that even a fresh agent would benefit from knowing.
    * **Data flow:** raw tweaks stay in the Phase 9 log. Any tweak that meets the bar above is promoted to `docs/wiki/core/18-knowledge-capture.md` via the `knowledge-capture` skill, then consolidated in Phase 10 by `agent-wrap-up`. **Default to capture; skip only when the tweak is purely cosmetic (typo, formatting) with no underlying lesson.**
* **COMPLETION:** Phase 9 done when user provides explicit sign-off.

### GROUP F: Document Tweaks & Wrap Up (Phase 10 + Wrap Up)
* **Goal:** Document all tweaks from Phase 9, promote captured lessons to the knowledge log, and close out the plan.
* **Steps:**
  * **Phase 10 (Document Tweaks & Knowledge Capture):**
    * **CRITICAL:** Initialize and execute the **`agent-wrap-up`** skill (global) to log Phase 9 tweaks, sync captured lessons (per Phase 9 `Capture Flag`) to the project's knowledge capture log, and confirm any open capture items are resolved.
  * **Wrap Up:**
    * **CRITICAL:** Continue executing the **`agent-wrap-up`** skill (global) to update wiki docs, archive the plan to `docs/archive-plans/`, review backlog items, and set State Dashboard → `COMPLETE`. **If Phase 6 flagged any dead code or orphans, create a backlog entry** at `docs/backlog/<slug>-backlog.md` with a terse description, affected file paths, and a reference to the original plan.
* **END:** All phases complete. Plan archived. Session ended.

---

## Parcel Markdown Template

> **Canonical Template Reference:** Always base new plan files on this skill's bundled template:
> [`references/template-plan.md`](references/template-plan.md)
> Read this file before creating any plan to ensure you use the latest structure. Do not copy or duplicate this structure in the main skill file.
