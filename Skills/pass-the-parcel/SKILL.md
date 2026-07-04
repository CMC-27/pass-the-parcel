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

Every plan file **MUST** have its State Dashboard updated at each transition. The table below defines the only valid states. An AI agent reading the plan determines exactly where it is in the workflow from these two fields.

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
- **Backlog → Active:** When a backlog item is picked up, the file is renamed from `<slug>-backlog.md` to `<slug>-plan.md` and moved from `docs/backlog/` to `docs/plans/`. Status changes `BACKLOG` → `PHASE_1`.
- **Status must match phase:** The `Status` field always reflects the highest completed phase. E.g., if Phases 1-4 are done, Status is `PHASE_4`, not `PHASE_3` or `PROPOSED`.
- **Persona changes with phase:** `Scoper` owns Phases 1-3, `Planner` owns Phase 4, `Reviewer` owns Phases 5-6, `Executor` owns Phases 7-8.
- **DO NOT use `PROPOSED` or `Architect`** — these are legacy defaults from the raw template. Always overwrite them with a valid state from the table above.
- **Phase 3 is NEVER skippable:** Every fresh conversation session **MUST** re-run Phase 3 (User Clarification) — even if the plan already has Phase 3 entries pre-populated from a previous session. The previous session's context is lost; the user's current intent must be re-validated. Pre-populated answers from backlog serve as *reference material* only — they are NOT a substitute for asking the questions interactively. See the [Fresh Context Rule](#fresh-context-rule) in Group A.

---

## Review Gates & Context Isolation Protocol

To prevent context inflation and ensure complete control over design and execution, the agent **MUST** adhere to strict execution boundaries:

1. **Strict Context Isolation (Single Phase Rule):**
   - The agent is permitted to execute **ONLY ONE** phase grouping (e.g., scoping, planning, or executing) per conversation session.
   - Once a phase grouping is updated in the plan, the agent **MUST save the plan and immediately halt** (conclude the turn). It must never proceed to subsequent phases or touch code without the user explicitly initiating the next session.
   
2. **The Mandatory Review Gates:**
   - **Gate A (Scope & Context Review):** Stop after completing **Phases 1-3**. Present the expanded scope and clarification questions, then halt. Do not write a detailed technical plan or touch files.
   - **Gate B (Detailed Plan Review):** Stop after completing **Phase 4**. Present the detailed execution plan with to-do list, code snippets, and wiki doc notes, then halt. Next agent handles reviews in Phases 5-6.
   - **Gate C (Peer Reviews Complete):** Stop after completing **Phases 5-6** (Product Owner + Senior Dev Hygiene reviews). Present findings and required fixes. Wait for approval before proceeding to execution.
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
* **Steps:**
  * **Phase 1 (Expansion & Scoping):** Expand request. Define in-scope and out-of-scope in `docs/plans/[plan-name].md`.
  * **Phase 2 (Requirements Gathering):** Search codebase and docs. Link exact files and context.
    * **MANDATORY: Context Inventory** — Before proceeding to Phase 3 questions, complete the following three lookups. Log all findings in the plan's Phase 2 section.
       1. **Wiki Docs:** Start with `docs/wiki/core/00-system-index.md` to identify relevant core docs (design system, architecture, security, validation, etc.), read those core docs, then drill into feature, component, database, and design-system docs as needed.
      2. **Knowledge Capture:** Read `docs/wiki/core/18-knowledge-capture.md` to surface existing decisions, past rationale, and tribal knowledge that may answer questions or constrain the solution.
      3. **Source Code:** Identify and read all key source files — components, contexts, utilities, hooks, and types the task touches.
  * **Phase 3 (User Clarification):**
       - **Fresh Context Rule (CRITICAL):** This session operates in a **fresh context window**. You have zero memory of any prior conversations that produced this plan. The pre-populated Phase 3 answers in the plan (if any) came from a different session with a different user state. **You MUST re-ask all Phase 3 questions interactively.** Do not treat pre-populated answers as "already answered."
       - **What you CAN rely on:** The Phase 1 (Scoping) and Phase 2 (Context) sections serve as your reference. Read these to understand what the previous session established, then formulate your Phase 3 questions based on that context.
       - **What you CANNOT do:** Skip Phase 3, mark answers as `[x]` without asking, or treat backlog pre-populated content as user-validated in this session.
       - Formulate concise clarifying questions for any remaining ambiguity. **You MUST use the `question` tool — one question at a time — to collect answers interactively before updating the plan.** For each question, offer 2–4 selectable options with your recommended answer listed first (prefixed `(Recommended)`). Ask **at least 5 questions**, and continue until you have full context. Once all contextual questions have been answered, present a final validation question: `"Is this all the context required?"` with options: `"Yes, all context captured — proceed"` (Recommended) and `"No, something is missing — I'll describe what's needed"`.
    - If **Yes**, write the resolved Q&A into Phase 3 of the plan as `[x]` checked items (including the validation question).
    - If **No**, the user will describe what's missing. Analyse their input and determine if further clarification questions are required. If yes, ask them iteratively. Once resolved, re-ask the final validation question. Repeat until answered Yes.
* **HALT POINT (Gate A):** Once the final validation question is answered Yes and Phase 3 is fully populated, update State Dashboard per the [Lifecycle table](#plan-state-lifecycle-canonical-reference): **Status** → `PHASE_3`, **Active Persona** → `Scoper`. Present the scoping summary and Phase 3 answers. **Stop execution immediately and wait for the user to approve the scope before proceeding to Group B.**

### GROUP B: Detailed Planning (Phase 4)
* **Goal:** Architect solution with exact file-level steps, to-do list, code snippets, and wiki doc notes.
* **Steps:**
  * **Phase 4 (Detailed Execution Plan):** Before writing any plan step, every proposed change **MUST** pass through the **Simplicity Ladder**. Then re-read relevant wiki/core docs (from Phase 2 context inventory) and write exact file-level steps, code blueprints with **wiki core references**, to-do list, test verification plan, and key wiki docs to add/edit.
    * **The Simplicity Ladder** (stop at first rung that holds):
      1. **Does this need to exist at all?** Speculative need = skip it, note "skipped: YAGNI" in plan.
      2. **Already in codebase?** Reuse existing helper/util/type/pattern. Log what was reused.
      3. **Stdlib does it?** Use it. No custom code.
      4. **Native platform feature?** Prefer `<input type="date">` over picker lib, CSS over JS, DB constraint over app code.
      5. **Already-installed dep?** Use it. Never add a new dep for what a few lines can do.
      6. **Can it be one line?** Make it one line.
      7. **Only then:** minimum code that works.
     * **Simplicity Rules:** No unrequested abstractions (interface w/ one impl, factory for one product, config for unchanging value). No scaffolding "for later". Deletion over addition. Boring over clever. Fewest files possible. Shortest working diff wins. **Refactor for brevity:** Before finalizing, review your code and compress — e.g., 200 lines → 50 if the logic allows. If a senior engineer would call it bloated, simplify.
    * **Deliberate Simplifications:** Mark with `// ponytail: [reason]` comment in plan code snippets. If shortcut has known ceiling (global lock, O(n²), naive heuristic), name ceiling + upgrade path.
    * **Safety Exceptions:** Never simplify away — input validation at trust boundaries, error handling preventing data loss, security measures, accessibility basics, or anything explicitly requested. User insists on full version → build it.
* **HALT POINT (Gate B):** Update State Dashboard per the [Lifecycle table](#plan-state-lifecycle-canonical-reference): **Status** → `PHASE_4`, **Active Persona** → `Planner`. Present the detailed execution plan. **Stop execution immediately. Next agent handles Phases 5-6 reviews.**

### GROUP C: Peer Reviews (Phases 5-6)
* **Goal:** Peer-review for quality, security, and standards utilising various personas.
* **Steps:**
  * **Phase 5 (Product Owner Review):** Audit the proposed changes using the **Senior Product Owner Lens**:
    * **Vision & Scope Integrity:** Verify the plan solves the *right* problem, respects defined scope boundaries, and lists UX flow details.
    * **Business Logic & Edge Cases:** Ensure empty states, loading indicators, error boundary strategies, and user-scoped data restrictions are planned.
    * **Dependency & Functional Risk:** Flag any downstream impacts or modifications to shared systems.
    * **Mandatory Decision Sync:** If any user clarifications occurred in Phase 3, you **MUST** sync these resolved product decisions to the project's knowledge capture log (`docs/wiki/core/18-knowledge-capture.md`) before completing this phase.
  * **Phase 6 (Senior Dev Hygiene Review):** Audit and harden the execution plan using the **Senior Full-Stack Architect Lens**:
    * **Active DRY Scan (Non-Negotiable):** Run `grep` and `ls` to actively hunt for duplicate components, utility hooks, type definitions, constant declarations, or state shapes in the codebase *before* accepting any "new" additions. Rewrite the plan to reuse existing assets where possible.
    * **Dead Code & Orphan Detection:** Scan for unresolved imports, unused variables, and orphaned functions/styles in the files this plan touches. **DO NOT delete them** — flag each finding with exact file paths and line numbers in the review notes. Reported dead code is handled during Wrap Up (backlog entry), not here.
    * **Strict Secret Management:** Ensure that environment variable usage is planned for all keys/tokens, and check that `.env` files are in `.gitignore`.
    * **Explicit Data Security:** Ensure Row Level Security (RLS) policies are defined for any new/modified database schemas or tables.
    * **Endpoint Protection & Rate Limiting:** Mandate request throttling and `429 Too Many Requests` handling on all new/modified endpoints.
    * **Robust Error Handling:** Wrap all async operations in error catching, forbid silent failures/empty catch blocks, and plan graceful client-facing fallbacks.
    * **Wiki Core Compliance:** Verify every code blueprint cites a relevant wiki/core doc and cross-check against it. Flag uncited UI/data/security blueprints.
    * **Zero-Knowledge Instruction Density:** Harden the Phase 4 instructions so they contain absolute file paths, exact function/component names, and precise diff plans.
* **HALT POINT (Gate C):** Update State Dashboard per the [Lifecycle table](#plan-state-lifecycle-canonical-reference): **Status** → `PHASE_6`, **Active Persona** → `Reviewer`. Present the review findings and required fixes. **Stop execution immediately. Do NOT touch any codebase files or run commands yet. Wait for explicit user approval to execute.**

### GROUP D: Execution & Verification (Phases 7-8)
* **Goal:** Code features strictly to plan, run QA, prove stability.
* **Steps:**
  * **Phase 7 (Execute Changes):** In a clean context, read the approved plan and edit codebase files exactly as designed. Mark off items.
    * **Surgical Execution Rules (Non-Negotiable):**
      1. **Touch only intended lines:** Edit the exact lines specified in the plan. Leave adjacent code, comments, and formatting intact — even if you spot minor issues nearby.
      2. **Clean up owned orphans:** Remove any imports, variables, types, or functions that your own changes made unused. Do NOT touch orphans that existed before your changes.
      3. **Leave pre-existing dead code untouched:** If Phase 6 flagged dead code, do not delete it here. It will be handled via backlog entry during Wrap Up. Your only job is the approved plan.
  * **Phase 8 (Verify Changes):** Run test suites, verify against plan specifications, and log status.
* **HALT POINT (Gate D):** Update State Dashboard per the [Lifecycle table](#plan-state-lifecycle-canonical-reference): **Status** → `PHASE_8`, **Active Persona** → `Executor`. Present completed work and QA verification report. **Stop execution immediately and wait for user to test and sign off.**

### GROUP E: User Review & Tweaks (Phase 9)
* **Goal:** User performs testing and provides feedback. Iterative back-and-forth with agent for tweaks.
* **Steps:**
  * **Phase 9 (User Review & Tweaks):** User tests the implementation. Agent and user iterate on feedback. Each round of feedback and tweaks is logged. Phase complete when user signs off.
* **COMPLETION:** Phase 9 done when user provides explicit sign-off.

### GROUP F: Document Tweaks & Wrap Up (Phase 10 + Wrap Up)
* **Goal:** Document all tweaks from Phase 9, capture themed tweaks for knowledge, and close out the plan.
* **Steps:**
  * **Phase 10 (Document Tweaks & Knowledge Capture):** Log all tweaks made during Phase 9. Flag tweaks with a shared theme for knowledge capture. Sync themed tweaks to the project's knowledge capture log.
  * **Wrap Up:** Update wiki docs as needed. Archive the plan to `docs/archive-plans/`. Review and update backlog items. **If Phase 6 flagged any dead code or orphans, create a backlog entry** at `docs/backlog/<slug>-backlog.md` with a terse description, affected file paths, and a reference to the original plan. Set State Dashboard per the [Lifecycle table](#plan-state-lifecycle-canonical-reference): **Status** → `COMPLETE`.
* **END:** All phases complete. Plan archived. Session ended.

---

## Parcel Markdown Template

> **Canonical Template Reference:** Always base new plan files on this skill's bundled template:
> [`references/template-plan.md`](references/template-plan.md)
> Read this file before creating any plan to ensure you use the latest structure. Do not copy or duplicate this structure in the main skill file.
