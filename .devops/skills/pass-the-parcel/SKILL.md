---
name: pass-the-parcel
description: Make sure to use this skill whenever the user mentions "pass the parcel", "parcel mode", "/parcel", "token saving planning", "multi-agent planning", "multi-agent mode", "single agent", "single-agent mode", "fast plan", "comprehensive plan", "stateless execution", "clear context", "independent reviewer", or wants to run a highly token-efficient, robust design-and-execution pipeline where state is passed entirely within a .md plan in .devops/plans/. Supports two topologies — `MULTI` (comprehensive plan) and `SINGLE` (fast plan) — chosen by task complexity.
version: 9
updated: 2026-09-13
---

# SKILL: Pass-the-Parcel (Low-Token Self-Contained Agent Orchestration)

Execute highly complex multi-agent engineering workflows with minimal token usage by maintaining the entire system state, goals, reviews, and execution checklists in a self-contained markdown "parcel" file at `.devops/plans/[plan-name].md`. Each agent session operates stateless, reading the plan, executing its specific role, editing the plan, and immediately exiting without carrying conversation history.

---

## Trigger Conditions

* User invokes the `/parcel` command or mentions "pass the parcel" or "parcel mode".
* User requests a complex feature that requires multiple design, review, coding, and testing steps, while demanding token-efficiency.
* Agent detects a long-running or multi-agent task and wants to structure it to avoid context inflation and conversation memory creep.
* User wants a **fast plan** (`SINGLE` topology) for a low-complexity task, or a **comprehensive plan** (`MULTI` topology) for a high-complexity one — see § Agent Topology for how the choice is made.

---

## Plan State Lifecycle (Canonical Reference)

Every plan file **MUST** have:
- The **claim front-matter** block at the very top — `code` / `sprint` / `claim_status` / `owner` / `claimed_at` / `last_touch` / `touches` / `depends_on`. See `.devops/rules/plan-lifecycle.md` § Claim Front-Matter.
- The full template scaffold with phases, gates, and checks.
- Its **Plan Settings** block (top of the file) recording `Mode` + `Agents`, set once at plan start and read before any phase.
- Its **State & Gates** section (bottom of the file) updated at each transition. 

Two fields locate a plan: its **physical location** (parked / sprint queue / active / archive) and the pipeline **Status** in the bottom State & Gates. Pre-pipeline plans carry `claim_status`; once claimed, they enter the pipeline at `PHASE_1` and the table below governs. The table defines the only valid states.

| Status | Active Persona | Directory | File Suffix | Gate | Meaning |
|---|---|---|---|---|---|
| `QUEUED` | `Planner` | `.devops/backlog/` or `.devops/sprints/sprint-{n}-<slug>/` | `-backlog.md` / `-plan.md` | — | Parked in the backlog, or committed to a sprint queue but not yet claimed (`claim_status: QUEUED`). Created by **backlog** / **sprint-plan**. |
| `CLAIMED` | `Scoper` | `.devops/plans/` | `-plan.md` | — | Claim written (`claim_status: CLAIMED`) on the trunk and a worktree created; the pipeline begins at `PHASE_1`. |
| `PHASE_1` | `Scoper` | `.devops/plans/` | `-plan.md` | — | Scoping & context gathering in progress. |
| `PHASE_3` | `Scoper` | `.devops/plans/` | `-plan.md` | Gate A | User clarifications complete (+ Phase 3.5 auto-resolutions in AUTO mode). Awaiting scope approval at Gate A. |
| `PHASE_5` | `High-Visionary` | `.devops/plans/` | `-plan.md` | Gate B | Wiki spec + standard implementation plan written. Awaiting spec & plan approval at Gate B. |
| `PHASE_5_REVISION` | `High-Visionary` | `.devops/plans/` | `-plan.md` | Gate B/C | Gate B or C rejected (review failed or user rejected). Plan returned to Group B for fixes. |
| `PHASE_7` | `Reviewer` | `.devops/plans/` | `-plan.md` | Gate C | Peer reviews complete. Awaiting approval to execute at Gate C. |
| `PHASE_8_FAILED` | `Executor` | `.devops/plans/` | `-plan.md` | Gate D | Execution rolled back after two failed self-healing attempts. Orchestrator routes: retry Phase 8 / revise (`PHASE_5_REVISION`) / user decision. |
| `PHASE_9` | `Executor` | `.devops/plans/` | `-plan.md` | Gate D | Implementation done, verified. Awaiting user sign-off at Gate D. |
| `COMPLETE` | — | `.devops/archive/` | `-plan.md` | — | Plan archived. No further action. All gates `APPROVED`. |

**Lifecycle flow:** `QUEUED` → *(claim)* → `CLAIMED`/`PHASE_1` → `PHASE_3` → `PHASE_5` → `PHASE_7` → `PHASE_9` → `COMPLETE`

**Revision loop (deterministic rejection):** `PHASE_7` → *(Phase 6 or 7 fails)* → `PHASE_5_REVISION` → *(Group B fixes)* → `PHASE_5` → *(Phases 6-7 re-run)* → `PHASE_7` → Gate C

**Gate A rejection path:** `PHASE_3` → *(user rejects scope)* → `PHASE_1`, Gate A → `REJECTED`; rejection reasons appended to the plan; Group A re-runs the affected questions.

**Execution failure path:** `PHASE_9` → *(rollback per surgeon §9)* → `PHASE_8_FAILED`; orchestrator routes retry / revision / user decision.

**Key rules:**
- **Status must match phase:** The `Status` field always reflects the highest completed phase. E.g., if Phases 1-5 are done, Status is `PHASE_5`, not `PHASE_3` or `PROPOSED`.
- **Persona changes with phase:** `Scoper` owns Phases 1-3 (+ 3.5 in AUTO), `High-Visionary` owns Phases 4-5 (+ `PHASE_5_REVISION` fixes), `Reviewer` owns Phases 6-7, `Executor` owns Phases 8-9.
- **DO NOT use `PROPOSED` or `Architect`** — these are legacy defaults from the raw template. Always overwrite them with a valid state from the table above.
- **No amount of urgency allows skipping gates:** Each gate is a hard stop. Agents **MUST** halt and wait for user approval before proceeding to the next phase grouping.
- **Gate flips only after a verdict:** gate rows flip to `APPROVED`/`REJECTED` only AFTER the user's (or AUTO-mode verification's) decision, recorded by the orchestrator. Executing agents halt with their gate `OPEN`.
- **Topology changes the gate set:** `MULTI` forces 4 hard stops (A-D). `SINGLE` merges B+C into one plan-approval at Gate B and records Gate C as `N/A`. Gate A and Gate D are topology-invariant. See § Agent Topology.
- **Claim before edits:** A plan may not execute until it is claimed (front-matter + worktree) with no `touches` overlap against active plans. See `.devops/rules/plan-lifecycle.md` § Claim Protocol.

> **🔒 Cache-anchor rule:** The **Plan Settings** block at the TOP of the plan file is frozen config (`Mode` + `Agents`, written once at plan start); the State Dashboard + Gate Log are the **last section** (`## 📍 State & Gates`) of every plan file. Gate transitions mutate ONLY those bottom rows; the frozen settings block and phase content above stay byte-stable to preserve LLM prefix-cache hits. Every instruction below that says "Update State Dashboard" means "update the bottom State & Gates section".

---

## Agent Topology (SINGLE vs MULTI — fast plan vs comprehensive plan)

Pass-the-parcel runs in **one of two topologies**, chosen by **task complexity** at plan start. Topology is the **second axis**, orthogonal to `Mode` (`USER-MANAGED`/`AUTO`). Both axes are recorded in the plan's **Plan Settings** block at the **TOP** of the plan file.

| | `MULTI` (default) — **comprehensive plan** | `SINGLE` — **fast plan** |
|---|---|---|
| Who works | Orchestrator delegates each phase group to its `ptp-*` sub-agent | Orchestrator executes each phase group inline, playing the persona itself |
| Sub-agent spawns | Yes (`task` per group) | None |
| Group C reviews | Independent, context-isolated reviewers (grumpy-architect + smooth-operator) | **Skipped** -> inline self-review checkpoint logged in the Phase 6 section |
| Phase 4 | Dedicated wiki spec | Folded into Phase 5 (or conditional skip) |
| Gates | A -> B -> C -> D (4 hard stops) | A -> B (spec + plan + self-review, one approval) -> D; Gate C `N/A` |
| Token cost | High (each sub-agent cold-starts and re-reads the plan) | Low (no sub-agent cold-starts) |
| Best for | Wide blast radius, contract/schema change, ambiguity, irreversibility, novel patterns | Local, low-risk, <= 3 files, existing patterns reused |
| Field value | `Agents: MULTI` | `Agents: SINGLE` |

**Non-negotiables in BOTH topologies:**
- Same plan file (`.devops/plans/[code]-[slug]-plan.md`), same lifecycle states, same State & Gates section.
- **Gate A (Scope) and Gate D (Implementation) always halt for the human.** `Mode`/`AUTO` never bypasses these.
- One phase grouping per session still applies (Strict Context Isolation) — topology changes **who executes**, not how sessions are bounded.
- `SINGLE` is **not** "skip rigor" — it swaps *independent* review for *sequential* review in a single context.

### Complexity Triage (topology selection)

Score these signals; **all low -> `SINGLE`; any high -> `MULTI`**:

| Signal | Low (-> SINGLE) | High (-> MULTI) |
|---|---|---|
| Blast radius | <= 3 files, one domain | cross-cutting, multi-domain |
| Contract change | none | schema / API / wiki-facing behavior |
| Risk & reversibility | easy to undo | destructive, migrational, irreversible |
| Ambiguity | intent clear | unknowns needing deep Q&A |
| Novelty | reuse existing pattern | new pattern / new subsystem |

The orchestrator **recommends** a topology from these signals; the **user confirms** (or overrides) at plan start, exactly like `Mode`.

### Per-topology phase flow

- **`MULTI`:** `Group A (ptp-context-hunter)` -> Gate A -> `Group B (ptp-high-visionary)` -> Gate B -> `Group C (ptp-grumpy-architect + ptp-smooth-operator)` -> Gate C -> `Group D (ptp-code-surgeon)` -> Gate D -> Group E/F.
- **`SINGLE`:** `Group A (orchestrator as Scoper)` -> Gate A -> `Group B (orchestrator as High-Visionary)` -> **Gate B** (spec + plan + inline self-review, one approval) -> `Group D (orchestrator as Executor)` -> Gate D -> Group E/F. Phase 4 folds into Phase 5 unless a wiki delta applies; Phases 6-7 render as `N/A — SINGLE topology; self-review logged`.

Record the chosen topology in the plan's **Plan Settings** `Agents` row at the **TOP** of the plan file (frozen config — never the bottom State & Gates).

---

## Skill Delegation Map (Persona → Sub-Skill)

Pass-the-parcel is a **thin orchestrator**. Each phase group delegates to a specialized sub-skill that owns the detailed directives. The `Active Persona` field in the **State & Gates** section (bottom of the plan) identifies **who owns the work**; the delegated skill provides **how the work is done**.

| Group | Phase(s) | Active Persona | Delegated Skill | Capability Class | Scope | Gate |
|---|---|---|---|---|---|---|
| A | 1-3 | `Scoper` | `ptp-context-hunter` | retrieval/inventory | ptp sub-skill | A |
| A | 3.5 (AUTO) | `Answerer` | `ptp-phase3-answerer` | retrieval/Q&A | ptp sub-skill | A |
| B | 4 | `High-Visionary` | `ptp-high-visionary` (+ `wiki-writer` for spec prose) | deep planning/authoring | ptp sub-skill | B |
| B | 5 | `High-Visionary` | `ptp-high-visionary` | deep planning/authoring | ptp sub-skill | B |
| B | 5 (revision) | `High-Visionary` | `ptp-high-visionary` | deep planning/authoring | ptp sub-skill | B |
| C | 6 | `Reviewer` | `ptp-grumpy-architect` | adversarial review | ptp sub-skill | C |
| C | 7 | `Reviewer` | `ptp-smooth-operator` | product review | ptp sub-skill | C |
| D | 8 | `Executor` | `ptp-code-surgeon` | execution | ptp sub-skill | D |
| D | 9 | `Executor` | `ptp-code-surgeon` | execution | ptp sub-skill | D |
| E | 10 | `Reviewer` | `knowledge-capture` (on demand) | — | global | — |
| F | Wrap Up | `Lead Context Architect` | `agent-wrap-up` | orchestration | global | — |

**Model Registry (declarative, per-agent):**
Model routing is declarative and owned by the **Model Registry** in `.opencode/plans/base-context.md` (inlined into every parcel/ptp agent via the PREFIX-LOCKED prefix). Capability classes: `orchestration`, `retrieval/inventory`, `retrieval/Q&A`, `deep planning/authoring`, `adversarial review`, `product review`, `execution`. Each agent's `model:` binding lives in its own frontmatter and MUST equal its registry row — use the `@model-routing` skill to (re)bind. Agents MUST NOT assume a specific vendor model exists — when asked which model you run on, read your own configured model.

> **Canonical copy:** This delegation map + model registry is inlined into every parcel/ptp agent via the PREFIX-LOCKED header (`.opencode/plans/base-context.md`). When editing the map, update `base-context.md` and run `scripts\check-parcel-prefix.ps1 -Sync` to re-inline it — then mirror the change here.

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
   
2. **The Mandatory Review Gates (A-D):**
   - **Gate A (Scope):** Stop after completing **Phases 1-3** (+ Phase 3.5 in AUTO mode). Present the scope perimeter (In-Scope/Out-of-Scope), the Phase 3 Q&A record, and any conflict warnings. **If rejected:** set Status → `PHASE_1`, Gate A → `REJECTED`, append rejection reasons to the plan, re-run Group A on the affected questions.
   - **Gate B (Spec & Plan):** Stop after completing **Phases 4-5** (or a `PHASE_5_REVISION` fix round). Present the wiki requirements spec with acceptance criteria AND the standard implementation plan together as one decision — what it will do and what it will cost. **If rejected:** set Status → `PHASE_5_REVISION`, Gate B → `REJECTED`, return to Group B.
   - **Gate C (Peer Reviews):** Stop after completing **Phases 6-7** (Grumpy Architect Spec & Logic Audit + Product Owner review). Present findings and required fixes. **If a review failed, set `PHASE_5_REVISION` and return to Group B — do not proceed to execution.** Wait for approval before proceeding to execution.
   - **Gate D (Implementation):** Stop after completing **Phases 8-9** (Execution & QA verification). Present the verification results and file changes. Wait for user testing and sign-off. **On rollback:** Status → `PHASE_8_FAILED`; the orchestrator routes retry / revision / user decision.
   - **AUTO mode:** the orchestrator auto-clears Gates A-C after mechanical verification (outputs present, no `REJECTED` verdict line, no `Unresolvable:` entries). **Gate D always requires the human.**
   - **Topology:** In `SINGLE` topology, Group C (Phases 6-7) is replaced by an inline self-review checkpoint logged in the Phase 6 section, and Gates B+C merge into a single plan-approval at Gate B (Gate C recorded `N/A`). Gate A and Gate D still halt for the human. See § Agent Topology.

---

## Linguistic Rules (Caveman Integration)

To maximize token-savings during interaction and within the plan updates, agents must adhere to strict **Linguistic Token Compression**:
* **Terse Communication:** Drop pleasantries ("sure", "happy to help"), articles ("a", "an", "the"), fillers ("just", "actually"), and hedging.
* **Fragments & Arrows:** Write in fragments and use arrows for causality (`X -> Y`). Keep sentences short.
* **Abbreviate:** Use standard shorthand (e.g., `impl`, `spec`, `req`, `fn`, `test`, `auth`, `DB`).
* **Brevity first:** Only include exact, necessary code blocks or errors. Let the plan file speak for itself.

---

## Execution Steps

> **Topology dispatch:** The steps below describe `MULTI` (sub-agent delegation). In `SINGLE`, the orchestrator plays each group's persona inline instead of spawning the sub-agent — the phases, gates, and halt points are otherwise identical, except that Group C is skipped and Gates B+C merge into one approval (§ Agent Topology).

### Claim & Pick-up Flow (Pre-Phase 1)
Work enters the pipeline from a sprint queue. Do not start a plan that is neither committed to a sprint nor claimed.

1. Locate the plan in the active sprint folder `.devops/sprints/sprint-{n}-<slug>/<code>-<slug>-plan.md` (`claim_status: QUEUED`). If the item is still parked at `.devops/backlog/<code>-<slug>-backlog.md`, it is **not committed** — run `@sprint-plan` first.
2. **Check eligibility:** no unmet `depends_on` (every dependency present in `.devops/archive/`) and no `touches` overlap with any plan in `.devops/plans/`. If either fails, STOP and report the blocker.
3. **Claim on the trunk:** fill `claim_status: CLAIMED`, `owner`, `claimed_at`, `last_touch`; `git mv` the plan from the sprint folder to `.devops/plans/<code>-<slug>-plan.md`; commit `claim: <code>`.
4. **Isolate:** `git worktree add <path> -b plan/<code>-<slug>` from the claim commit.
5. Update the **State & Gates** section (bottom of the plan) per the [Lifecycle table](#plan-state-lifecycle-canonical-reference):
   - **Status** → `PHASE_1`
   - **Active Persona** → `Scoper`
   - **Gate A** → `OPEN`.
6. Proceed to **Group A** (Phases 1-3). A committed plan may carry pre-populated context — use it for Phases 1-2, but **Phase 3 MUST still be re-run interactively** per the Fresh Context Rule in the `ptp-context-hunter` skill. The pre-populated Phase 3 answers serve as reference only — they do not exempt the agent from asking questions.

### GROUP A: Scoping & Context (Phases 1-3)
* **Capability class:** per delegation map row (Model Registry in base-context)
* **Goal:** Understand intent, locate context, resolve ambiguities.
* **Pre-Step — Plan Initialization:** If this is a fresh feature, instantiate `.devops/plans/<code>-<slug>-plan.md` from the [canonical template](../../plans/template-plan.md) and add the claim front-matter block (`.devops/rules/plan-lifecycle.md` § Claim Front-Matter). This gives the plan the **full scaffold** (Phases 1-10 + State & Gates at bottom) from the start — all downstream agents rely on this structure. If this item was committed to a sprint, **do not overwrite it** — skip directly to executing the sub-skill to preserve the pre-populated context. Set initial **State & Gates** section (bottom): **Status** → `PHASE_1`, **Active Persona** → `Scoper`.
* **Steps:**
  * **Phase 1 (Expansion & Scoping):**
    * **CRITICAL:** Initialize and execute the **`ptp-context-hunter`** skill to hydrate the plan, expand the request, and lock the In-Scope / Out-of-Scope perimeter.
  * **Phase 2 (Requirements Gathering):**
    * **CRITICAL:** Continue executing the **`ptp-context-hunter`** skill to run the Forensic Context Inventory — wiki core docs, knowledge capture, and source code verification.
  * **Phase 3 (User Clarification):**
    * **CRITICAL:** Continue executing the **`ptp-context-hunter`** skill to interrogate the user — **one question at a time** via the ask-questions tool (`vscode_askQuestions` / `question`), never batched — surface architectural conflicts inline, and capture the final validation before halting at Gate A.
  * **Phase 3.5 (AUTO mode only):**
    * Initialize and execute the **`ptp-phase3-answerer`** skill to auto-resolve the pending questions from the Research Map. Any `Unresolvable:` entry is a hard halt — fall back to asking the user directly, one question at a time.
* **HALT POINT (Gate A — Scope):** Once the final validation question is answered Yes and Phase 3 is fully populated, set **Status** → `PHASE_3`, **Active Persona** → `Scoper`, and halt. Present the scope perimeter + Phase 3 Q&A record at **Gate A**. The user approves the scope before planning begins. On rejection: Status → `PHASE_1`, Gate A → `REJECTED`, re-run the affected questions.

### GROUP B: Wiki Spec & Implementation Planning (Phases 4-5)
* **Capability class:** per delegation map row (Model Registry in base-context)
* **Goal:** Write the wiki requirements spec FIRST (Phase 4), then build the implementation plan to meet it (Phase 5). No code snippets except exact string literals.
* **Steps:**
  * **Phase 4 (Wiki Requirements & Acceptance Criteria):**
    * **CRITICAL:** Continue executing the **`ptp-high-visionary`** skill — its Phase 4 directives mandate the **`@wiki-writer`** discipline for all spec prose. Write/update the wiki docs that describe the target behavior (marked `status: in-progress` — a pre-code doc is a claim, not truth), define acceptance criteria, and name test targets. **Conditional skip (checklist):** skip only when NONE of the Phase 4 checklist conditions applies (no user-visible change, no contract change, no wiki-facing behavior change) — record "no wiki delta — rationale: …" in the plan (full checklist: `ptp-high-visionary` Phase 4 directives).
  * **Phase 5 (High-Visionary Execution Plan):**
    * **CRITICAL:** Initialize and execute the **`ptp-high-visionary`** skill to convert the Phase 1-3 scope + Phase 4 spec into a standard implementation plan. Focus on **what needs to happen** rather than exact code. Include file paths, component names, and architectural decisions, but **no code snippets except exact string literals** (regex, SQL migration, CLI command, config key, error message). Reject on bloat or vagueness.
  * **Phase 5 Revision (PHASE_5_REVISION):**
    * When a plan returns in state `PHASE_5_REVISION` (Gate B rejected, or Phase 6/7 review failed), the High-Visionary re-executes on the SAME plan file to apply the flagged fixes. Address every `BLOCK`/`REJECTED` item from the review, update the plan, and set Status → `PHASE_5` for re-review (Phases 6-7 re-run; Gate C is re-presented). Do not treat the review comments as optional.
* **HALT POINT (Gate B — Spec & Plan Review):** Update the **State & Gates** section (bottom of the plan): **Status** → `PHASE_5`, **Active Persona** → `High-Visionary` — leave **Gate B** `OPEN` for the user's verdict. Present the wiki requirements spec (with acceptance criteria) AND the implementation plan together as one decision. **Stop execution immediately. Next agent handles Phases 6-7 reviews.**

### GROUP C: Peer Reviews (Phases 6-7)
* **Goal:** Peer-review the text-based architecture for logical completeness, edge cases, and UX alignment. **Phase 6 audits the SPEC — the plan contains no code, so no code-level scans (DRY/WET, line checks) are performed.**
* **Topology gate:** `MULTI` only. In `SINGLE`, skip the independent reviewers — the orchestrator performs an inline self-review after Group B and presents it together with the spec + plan at the single Gate B approval (Gate C recorded `N/A`). See § Agent Topology.
* **Steps:**
  * **Phase 6 (Grumpy Architect Spec & Logic Audit):**
    * **Capability class:** adversarial review (see Model Registry)
    * **CRITICAL:** Initialize and execute the **`ptp-grumpy-architect`** skill as a **Spec & Logic Audit** of the text-based architecture produced in Phase 5. Evaluate: system contracts, edge cases, file boundary collisions, dependency gaps, YAGNI bloat, performance trade-offs, logical completeness, security perimeter, and architectural anti-patterns. **Do not expect or demand source code snippets in the plan file.** Reject on logical gaps or bloat.
  * **Phase 7 (Smooth Operator Product Review):**
    * **Capability class:** per delegation map row (Model Registry in base-context)
    * **CRITICAL:** Initialize and execute the **`ptp-smooth-operator`** skill to audit the Phase 5 plan. Ensure strict alignment with user journey, 4 core states, and scope containment. Reject on UX friction.
* **Deterministic Rejection State (Gate C):**
  * **Pass:** Phase 6 log clean → proceed to Phase 7 (PO Intent Check) → set `PHASE_7` → halt at Gate C for user sign-off.
  * **Fail:** Phase 6 or 7 logs blocking architectural flaws → set `PHASE_5_REVISION` → return to Group B (High-Visionary) for plan adjustments → re-run Phase 6/7 → re-evaluate Gate C. **Never advance an unapproved plan toward execution.**
* **HALT POINT (Gate C — Peer Reviews):** Update the **State & Gates** section (bottom of the plan): **Status** → `PHASE_7` (pass) or `PHASE_5_REVISION` (fail), **Active Persona** → `Reviewer` (pass) or `High-Visionary` (fail). The orchestrator records **Gate C** → `APPROVED`/`REJECTED` only after the user's verdict. Present the review findings and required fixes. **Stop execution immediately. Do NOT touch any codebase files or run commands yet. Wait for explicit user approval to execute.**

### GROUP D: Execution & Verification (Phases 8-9)
* **Goal:** Code features strictly to plan, run QA, prove stability.
* **Execution Isolation:** Phase 8 **only triggers after Gate C is cleared by explicit user input.** No execution before explicit approval.
* **Steps:**
  * **Phase 8 (Execute Changes):**
    * **Capability class:** execution (see Model Registry)
    * **CRITICAL:** Initialize and execute the **`ptp-code-surgeon`** skill to apply Phase 5 edits. **Single-pass direct-to-disk execution:** ingest the text spec and write implementation code DIRECTLY to workspace source files — no multi-pass drafting inside intermediate Markdown files, no staging code blocks in the plan. Use **ponytail coding** style — surgical, minimal, efficient edits that respect existing patterns. Touch only intended lines, clean up only owned orphans, track execution incrementally, and halt on any unresolvable error.
  * **Phase 9 (Verify Changes):**
    * **Capability class:** execution (see Model Registry)
    * **CRITICAL:** Continue executing the **`ptp-code-surgeon`** skill to run compilation/tests/lint, log proof in the plan, and verify runtime stability before declaring the gate clear. Apply any necessary tweaks identified during QA.
* **HALT POINT (Gate D — Implementation):** Update the **State & Gates** section (bottom of the plan): **Status** → `PHASE_9`, **Active Persona** → `Executor` — leave **Gate D** `OPEN` for the user's verdict. Present completed work and QA verification report. **Stop execution immediately and wait for user to test and sign off.** On rollback: Status → `PHASE_8_FAILED` — route retry / revision / user decision.

### GROUP E: User Review & Tweaks (Phase 10)
* **Goal:** User performs testing and provides feedback. Iterative back-and-forth with agent for tweaks, with important lessons captured to improve future outputs.
* **Steps:**
  * **Phase 10 (User Review & Tweaks):** User tests the implementation. Agent and user iterate on feedback. **All tweaks are logged inline in this plan's Phase 10 `Back-and-Forth Log`** (one entry per round: User Feedback → Tweaks Applied → Result). Phase complete when user signs off.
  * **Knowledge Capture Hook:** After *every* tweak, evaluate it against the **`knowledge-capture` Admission Gate** (canonical — defined once in that skill). Only real deviations and valuable tribal knowledge qualify; plan-conformity tweaks, accident fixes, full-change rewrites without an extractable lesson, and one-time preferences are rejected and stay in the Phase 10 log. **Default to skip.**
    * **Data flow:** raw tweaks stay in the Phase 10 log. Qualifying items are promoted to `.wiki/core/18-knowledge-capture.md` via the `knowledge-capture` skill, then consolidated in Wrap Up by `agent-wrap-up`. Flag each captured item with a `Capture Flag` in its Phase 10 log entry so Wrap Up can sync them.
* **COMPLETION:** Phase 10 done when user provides explicit sign-off.

### GROUP F: Wrap Up (Document Tweaks, Spec Reconciliation & Close-Out)
* **Capability class:** per delegation map row (Model Registry in base-context)
* **Goal:** Document all tweaks from Phase 10, promote captured lessons to the knowledge log, reconcile the wiki against what was actually built, and close out the plan.
* **Steps:**
  * **Wrap Up:**
     * **CRITICAL:** Initialize and execute the **`agent-wrap-up`** skill (global) to log Phase 10 tweaks, sync captured lessons (per Phase 10 `Capture Flag`, strict-admission only) to the project's knowledge capture log, reconcile code against the Phase 4 spec, **promote `status: in-progress` wiki docs to `stable`** (or log the deviation), update wiki docs, archive the plan to `.devops/archive/`, review backlog items, and set the **State & Gates** section (bottom) → `COMPLETE` (all gates `APPROVED`). **If Phase 6 flagged any dead code or orphans, create a backlog entry** at `.devops/backlog/<code>-<slug>-backlog.md` with a terse description, affected file paths, and a reference to the original plan.
* **END:** All phases complete. Plan archived. Session ended.

---

## Parcel Markdown Template

> **Canonical Template Reference:** Always base new plan files on the canonical template at
> [`.devops/plans/template-plan.md`](../../plans/template-plan.md)
> Read this file before creating any plan to ensure you use the latest structure. Do not copy or duplicate this structure in the main skill file.
