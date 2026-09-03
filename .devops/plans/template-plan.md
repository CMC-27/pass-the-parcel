# Parcel Plan: T{theme}-E{epic}.{impl} - [Title]
## Theme-Epic: T{theme} - {Theme Name}, E{epic} - {Epic Name}

> **Skill Architecture:** This template is consumed by the `pass-the-parcel` skill. Each phase delegates to a specialized sub-skill. See the parcel skill's Skill Delegation Map.
>
> **RULES:**
> - Full skeleton required - ALL 10 phases + Wrap Up MUST be present.
> - Halt points are HARD STOPS - each gate blocks all subsequent phases.
> - Persona matches Status - use the State Lifecycle table in pass-the-parcel skill.
>
> **🔒 CACHE-ANCHORED:** State Dashboard + Gate Log live in the **last section** of this file (`## 📍 State & Gates`). Gate transitions update ONLY those bottom rows — do NOT edit content above once written. Byte-stable prefix = LLM prefix-cache hits for every downstream agent re-read.

---

## 1 Phase 1: Expansion & Scoping
**Skill Executed:** `ptp-context-hunter`

**Intent:**

**In Scope:**

**Out of Scope:**

**Perimeter Notes:**

---

## 2 Phase 2: Requirements & Context
**Skill Executed:** `ptp-context-hunter`

**Forensic Context Inventory:**
> [ ] Wiki core docs read (`.wiki/core/00-system-index.md` + drilled into relevant docs)
> [ ] Knowledge capture read (`.wiki/core/18-knowledge-capture.md`)
> [ ] Source code verified (components / utilities / hooks / types in blast radius)

**Relevant Existing Decisions (from knowledge capture):**

**Relevant Docs Found:**

**Relevant Code Found:**

---

## 3 Phase 3: User Clarification
**Skill Executed:** `ptp-context-hunter`

> [ ] Q1:
> [ ] Q2:
> [ ] Q3:
> [ ] Q4:
> [ ] Q5:
> [ ] Final validation: "Is this all the context required?" -> Yes

**Architectural Conflict Warnings Raised:**

---

> **NO HALT after Phase 3:** Phase 3 complete -> set Status -> `PHASE_3` and proceed directly to Phase 4. The human reviews the formalized requirements at Gate A (after Phase 4), not the raw scope.

---

## 4 Phase 4: Wiki Requirements & Acceptance Criteria
**Skill Executed:** `ptp-high-visionary` (spec-first directives) + `@wiki-writer`

> **Spec-First Rule:** The wiki is written BEFORE the code. Docs written here describe target behavior and are marked `status: in-progress` — a pre-code doc is a claim, not truth. Promotion to `stable` happens only at Wrap Up, after the executor verifies code matches spec.
>
> **Conditional Skip:** If the task changes no user-visible behavior or logic contract (bug-fix internals, copy tweaks, refactors), skip this phase and record: `No wiki delta — rationale: <why>`.

**Wiki Docs to Write/Update (as `in-progress`):**
| Doc | Change |
|---|---|
| | |

**Acceptance Criteria:**
| # | Criterion (behavior) | Test Target |
|---|---|---|
| 1 | | |

**Spec Notes:**
- Data flow / state changes:
- Edge cases the spec must cover:
- Docs consumed by this feature (read-first list):

---

> **NO HALT after Phase 4:** the spec is reviewed together with the implementation plan at Gate A (after Phase 5) — one decision, what it will do and what it will cost.

---

## 5 Phase 5: High-Visionary Standard Implementation Plan
**Skill Executed:** `ptp-high-visionary`

**Simplicity Gate:**
> [ ] Climbed the Simplicity Ladder (7 rungs)
> [ ] No speculative abstractions
> [ ] Reuse over reimpl - Reuse Log populated
> [ ] Deliberate simplifications marked with `ponytail:` comments
> [ ] Safety exceptions preserved

**Reuse Log:**
| Existing Asset | Where Reused | Ladder Rung |
|---|---|---|
| | | 2 |

**Spaghetti Triage (See-Name-Route, Do Not Fix):**
- [ ] No smells noticed

| File | Function | Smell Type | Severity | Recommended Action |
|---|---|---|---|---|
| | | | | |

### To-Do List
- [ ]

### File-Level Steps
1.

### Implementation Instructions (no code snippets unless absolutely necessary)

### Wiki Core References
- `.wiki/core/[doc].md` -> [which blueprints derive from this doc]

### Wiki Docs to Add/Edit

---

> **HALT POINT (Gate A — Spec & Plan Review):** Phases 4-5 complete. Present the wiki requirements spec (with acceptance criteria) AND the execution plan together as one decision. Do not proceed to reviews until user approves. Update the **State & Gates** section at the bottom of this file: Status -> `PHASE_5`, Active Persona -> `High-Visionary`, Gate A -> `APPROVED`.

---

## 6 Phase 6: Grumpy Architect Spec & Logic Audit
**Skill Executed:** `ptp-grumpy-architect`

**Verdict:** `PASS` / `REJECTED`

> **Rejection Rule:** If plan does not make the app faster, safer, or easier to modify, do not check boxes. Reject and force rewrite via `PHASE_5_REVISION`.
>
> **Spec-level audit — the plan contains no code, so no code-level scans (DRY/WET, line checks).**

- **System Contracts Explicit:** (function/component names, file paths, interface boundaries)
- **File Boundary & Scope Collisions:** (proposed paths checked against existing code)
- **Dependency Gaps:** (all referenced utils/hooks/schemas/services accounted for)
- **YAGNI Bloat:** (no speculative modules, placeholder files, empty scaffolding)
- **Paranoid Security (Contract Level):** (secrets via env + .gitignore; input typed with Zod/unknown; RLS for DB)
- **Survivability:** (async/timeout/network covered for every flow; Error Boundaries)
- **Edge Cases:** (empty/null inputs; boundary/limit conditions; concurrency/races; state transitions)
- **Performance Trade-offs:** (N+1, unbounded rendering, missing indexes; scaling ceiling + upgrade path)
- **Architectural Anti-Patterns:** (god modules, spaghetti coupling, duplicate sources of truth, dead-end abstractions, feature bleed)
- **Endpoint Protection & Rate Limiting:**
- **Wiki Core Compliance:** (every blueprint cites a .wiki/core/ doc)

**Dead-Code / Orphan Flags (for Wrap Up backlog entry):**
| plan section / file_path:line_number | Reason |
|---|---|

**Required Fixes:**
> [ ] [Fix 1 - or mark "None"]

---

## 7 Phase 7: Smooth Operator Product Review
**Skill Executed:** `ptp-smooth-operator`

> **Rejection Rule:** If plan introduces unnecessary complexity or scope expansion, do not check boxes. Reject and force rewrite.

- **Vision & Journey Integrity:**
- **Scope Containment (No Gold Plating):**
- **4 Core User States:** (Loading / Empty / Error / Success)
- **Guardrails & Permissions:**
- **Mobile / A11y / Telemetry:**

**Required Fixes:**
> [ ] [Fix 1 - or mark "None"]

---

> **HALT POINT (Gate B):** Reviews complete. Present findings and required fixes. Update the **State & Gates** section at the bottom of this file:
> - **PASS:** Phase 6 log clean -> set Status `PHASE_7`, Active Persona `Reviewer`, Gate B -> `APPROVED`. Do not proceed to execution until user approves.
> - **FAIL:** Phase 6 or 7 flagged blocking flaws -> set Status `PHASE_5_REVISION`, Active Persona `High-Visionary`, Gate B -> `REJECTED`. Return to Group B for plan adjustments, then re-run Phases 6-7. **Never advance an unapproved plan to execution.**

---

## 8 Phase 8: Execute Changes
**Skill Executed:** `ptp-code-surgeon`

**Execution Isolation:** Phase 8 triggers ONLY after Gate B cleared by explicit user input.

**Single-Pass Direct-to-Disk:**
> [ ] Implementation written DIRECTLY to source files - no intermediate Markdown code blocks, no drafting files
> [ ] Touched only intended lines - no adjacent refactors
> [ ] Cleaned up only owned orphans
> [ ] Pre-existing dead code left untouched

> [ ] Step 1:
> [ ] Step 2:

---

## 9 Phase 9: Verify Changes
**Skill Executed:** `ptp-code-surgeon`

**Build & Lint:**
> [ ] Compilation check clean
> [ ] Lint clean (exit 0)
> [ ] Type-generation re-run if schema/API changes

**Test Report:**
- [ ] Lint pass
- [ ] Tests pass
- [ ] Build pass
- [ ] Code matches exact plan specifications
- [ ] No functional gaps identified

---

> **HALT POINT (Gate B):** Implementation and verification complete. Present completed work to user. Do not proceed to user review until user signs off. Update the **State & Gates** section at the bottom of this file: Status -> `PHASE_9`, Active Persona -> `Executor`, Gate B -> `APPROVED`.

---

## 10 Phase 10: User Review & Tweaks
**Skill Executed:** `knowledge-capture`

**Tweak Discipline:**
> Tweaks are surgical, not architectural. `expansion` and `refactor` are HALT conditions.

- [ ] Tweak classified: `fix` / `expansion` / `refactor`
- [ ] `expansion` and `refactor` routed to new parcel
- [ ] `fix` touches <= 3 files
- [ ] `fix` introduces no new abstraction absent from original plan

**Capture Categories:** Recurring / Tribal / One-off / Cosmetic-skip

| Round | Feedback | Action Taken | Capture Flag | Result |
|---|---|---|---|---|
| 1 | | | | PENDING / COMPLETE |

**Sign-Off:** [Date] - User approved.

---

## Completion Note (Wrap Up)
**Skill Executed:** `agent-wrap-up`

> [ ] Read `.wiki/core/18-knowledge-capture.md` for existing related decisions
> [ ] Themed tweaks synced to knowledge capture doc
> [ ] Wiki docs updated per Phase 10 tweaks
> [ ] Code reconciled against Phase 4 spec — deviations logged
> [ ] `status: in-progress` wiki docs promoted to `stable` (or deviation logged)

**Themed Tweaks:**

**Knowledge Capture Entries:**

**Spec Reconciliation:** [code-vs-spec deviations, or "None — implementation matches Phase 4 spec"]

**In-Progress Promotions:** [docs promoted to `stable`, or "None"]

**Dead-Code Backlog Entries (from Phase 6):**

**Wiki Updates:** [List wiki docs updated]

**Plan Archiving:** Plan archived to `.devops/archive/{code}-{slug}-plan.md`

**Backlog Review:** [Backlog items reviewed / updated]

---

## 📍 State & Gates (CACHE-ANCHORED — update ONLY this section at gate transitions)

> **Cache rule:** This is the **last section** in the file. Gate transitions mutate ONLY the rows below — phase content above stays byte-stable to preserve LLM prefix-cache hits. Every "Update Status" instruction in the halt points above means "edit this section".

| Metric | Value |
|---|---|
| **Status** | `BACKLOG` |
| **Version** | `v0.1.0` |
| **Mode** | `USER-MANAGED` / `AUTO` |
| **Active Persona** | `High-Visionary` |
| **Depends On** | none |
| **Blocks** | none |

> Valid states: `BACKLOG`, `PHASE_1`, `PHASE_3`, `PHASE_5`, `PHASE_5_REVISION`, `PHASE_7`, `PHASE_9`, `COMPLETE`.

| Gate | Requirement | Status |
|---|---|---|
| A | Spec & plan approved (Phases 4-5) | `OPEN` |
| B | Reviews passed (Phases 6-7) | `OPEN` |
| C | Implementation verified (Phases 8-9) | `OPEN` |

> On each gate: flip the row Status `OPEN` → `APPROVED` (or `REJECTED` → `PHASE_5_REVISION` for Gate B). Never edit rows above this section for gate bookkeeping.

> **This section is the LAST section in the file. All gate bookkeeping happens here.**
