# 📦 Parcel Plan: [Plan Name]

> **State Lifecycle Reference:** See `pass-the-parcel` skill's [Plan State Lifecycle table] for valid Status/Persona transitions. Update these fields at every gate — do not leave them at template defaults.
>
> **🔒 CACHE-ANCHORED:** State Dashboard + Gate Log live in the **last section** of this file (`## 📍 State & Gates`). Gate transitions update ONLY those bottom rows — do NOT edit content above once written. Byte-stable prefix = LLM prefix-cache hits for every downstream agent re-read.

---

## 1️⃣ Phase 1: Expansion & Scoping
* **Skill Executed:** `ptp-context-hunter`
* **Intent:** [Terse description of user's core goal]
* **In Scope:**
  - [Item 1]
* **Out of Scope:**
  - [Item 1]

## 2️⃣ Phase 2: Requirements & Context
* **Skill Executed:** `ptp-context-hunter`
* **Forensic Context Inventory (Non-Negotiable):**
  - `[ ]` Wiki core docs read (`docs/wiki/core/00-system-index.md` + drilled)
  - `[ ]` Knowledge capture read (`docs/wiki/core/18-knowledge-capture.md`)
  - `[ ]` Source code verified (components / utilities / hooks / types in blast radius)
* **Relevant Docs Found:**
  - `[doc.md]` (file:///path/to/doc.md) -> [Why it's relevant]
* **Relevant Code Found:**
  - `[file.js]` (file:///path/to/file.js) -> [What needs to change]

## 3️⃣ Phase 3: User Clarification
* **Skill Executed:** `ptp-context-hunter`
* **Open Questions:**
  - `[ ]` [Question for user] -> **Answer:** [User's response]
* **Architectural Conflict Warnings Raised:**
  - [None / or list inline warnings flagged during interrogation]
* **Final Validation:**
  - `[ ]` Is this all the context required? -> **Answer:** [Yes / No + missing details]

---

## 4️⃣ Phase 4: High-Visionary Standard Implementation Plan
* **Skill Executed:** `ptp-high-visionary`
* **Prepared By:** `[Agent Persona]` | **Date:** `[YYYY-MM-DD HH:MM]`
* **Simplicity Gate:**
  - `[ ]` All proposed changes climbed the Simplicity Ladder (7 rungs)
  - `[ ]` No speculative abstractions — each new file/dep justified
  - `[ ]` Reuse over reimpl — logged what already exists in codebase
  - `[ ]` Deliberate simplifications marked with `ponytail:` comments (with ceiling + upgrade path)
  - `[ ]` Safety exceptions preserved (validation / error handling / security / a11y / explicit user requests)
* **Reuse Log:**
  - `[existing helper/util/type]` -> `[where reused]` `[rung: 2]`
* **Files to Create/Modify:**
  - `[path]` (file:///path) -> [change description]
* **Wiki Core References:**
  - `[doc.md]` -> [which blueprints derive from this doc]
* **Wiki Docs to Add/Edit:**
  - `[path]` (file:///path) -> [description of new/edited content]
* **Implementation Instructions (no code snippets unless absolutely necessary):**
  - [High-level instructions / exact code only where description is impossible without it]
* **To-Do List:**
  - `[ ]` [Task 1]
  - `[ ]` [Task 2]
* **Test Verification Plan:**
  - `[command]`
  - `[ ]` [Test case 1]
* **Revision Log (PHASE_4_REVISION rounds):**
  - **Round 1:** [date] — [reviewer] flagged: [issues] — [fixes applied]
* **🛑 HALT POINT (Gate B):** Phase 4 complete. Present plan. Next agent handles Phases 5-6 reviews. Update the **State & Gates** section at the bottom: Status → `PHASE_4`, Gate B → `APPROVED` + timestamp. If the plan arrives in `PHASE_4_REVISION`, apply all `REJECTED`/`BLOCK` fixes and set bottom Status → `PHASE_4` for re-review.

---

## 5️⃣ Phase 5: Grumpy Architect Spec & Logic Audit
* **Skill Executed:** `ptp-grumpy-architect`
* **Prepared By:** `[Agent Persona]` | **Date:** `[YYYY-MM-DD HH:MM]`
* **Status:** `PENDING`
* **Verdict:** `PASS` / `REJECTED`
* **Findings (spec-level audit — the plan contains no code, so no code-level scans):**
  - [✅/⚠️/🚫] **System Contracts Explicit** — function/component names, file paths, interface boundaries stated; no hand-wavy directives
  - [✅/⚠️/🚫] **File Boundary & Scope Collisions** — proposed paths checked against existing code; no overlapping ownership
  - [✅/⚠️/🚫] **Dependency Gaps** — all referenced utils/hooks/schemas/services accounted for; no missing prerequisites
  - [✅/⚠️/🚫] **YAGNI Bloat** — no speculative modules, placeholder files, empty scaffolding, single-implementation interfaces
  - [✅/⚠️/🚫] **Paranoid Security (Contract Level)** — secrets via env + `.gitignore`; input typed with `unknown`/Zod; RLS mandated for DB changes; client never trusted
  - [✅/⚠️/🚫] **Survivability (Error Handling)** — async/timeout/network covered for every flow; no silent/empty catches; Error Boundaries on volatile components
  - [✅/⚠️/🚫] **Edge Cases** — empty/null inputs, boundary/limit conditions, concurrency/race conditions, state transitions all explicit
  - [✅/⚠️/🚫] **Performance Trade-offs** — N+1, unbounded rendering, missing indexes, scaling ceiling + upgrade path named
  - [✅/⚠️/🚫] **Architectural Anti-Patterns** — god modules, spaghetti coupling, duplicate sources of truth, dead-end abstractions, feature bleed flagged
  - [✅/⚠️/🚫] **Endpoint Protection & Rate Limiting** — throttling + `429` handling + payload size restricted
  - [✅/⚠️/🚫] **Wiki Core Compliance & Instruction Density** — every blueprint cites a `docs/wiki/core/*` doc; surgical file paths + exact names + behavior contracts
* **Required Fixes:**
  - `[ ]` [Fix 1 — or mark "None"]

## 6️⃣ Phase 6: Smooth Operator Product Review
* **Skill Executed:** `ptp-smooth-operator`
* **Prepared By:** `[Agent Persona]` | **Date:** `[YYYY-MM-DD HH:MM]`
* **Status:** `PENDING`
* **Findings:**
  - [✅/⚠️/🚫] **Vision & Journey Integrity** — Vision Test + Journey Continuity + Cross-Feature/Downstream Impact (cross-check Phase 5 spec audit)
  - [✅/⚠️/🚫] **Scope Containment (No Gold Plating)** — items cross-referenced vs. Phase 1; unrequested scope cut
  - [✅/⚠️/🚫] **4 Core User States** — Loading / Empty / Error / Success all explicit in plan
  - [✅/⚠️/🚫] **Guardrails & Permissions** — role/tenant/tier restricted-state UI planned
  - [✅/⚠️/🚫] **Mobile / A11y / Telemetry** — responsive layout, keyboard nav, analytics hooks
  - [✅/⚠️/🚫] **Mandatory Decision Sync** — Phase 3 resolutions synced to `docs/wiki/core/18-knowledge-capture.md`
* **Required Fixes:**
  - `[ ]` [Fix 1 — or mark "None"]
* **🛑 HALT POINT (Gate C):** Reviews complete. Update the **State & Gates** section at the bottom:
  - **PASS:** Phase 5 log clean -> set bottom Status `PHASE_6`, Gate C → `APPROVED` -> present findings & required fixes. Wait for user approval before execution.
  - **FAIL:** Phase 5 or 6 flagged blocking flaws -> set bottom Status `PHASE_4_REVISION`, Gate C → `REJECTED` -> return to Group B (High-Visionary) for fixes -> re-run Phases 5-6. **Never advance an unapproved plan to execution.**

---

## 7️⃣ Phase 7: Implementation Checklist (Execution)
* **Skill Executed:** `ptp-code-surgeon`
* **Execution Isolation:** Phase 7 triggers ONLY after Gate C cleared by explicit user input.
* **Single-Pass Direct-to-Disk (Non-Negotiable):**
  - `[ ]` Implementation written DIRECTLY to source files — no intermediate Markdown code blocks, no drafting files
  - `[ ]` Touched only intended lines — no adjacent refactors
  - `[ ]` Cleaned up only owned orphans (imports/types/vars made unused by this change)
  - `[ ]` Pre-existing dead code left untouched (Phase 5 backlog route only)
* **Execution Trace:**
  - `[ ]` [Execution Step 1 from Phase 4]
  - `[ ]` [Execution Step 2 from Phase 4]

## 8️⃣ Phase 8: Verification Dashboard
* **Skill Executed:** `ptp-code-surgeon`
* **Verification Status:** `PENDING`
* **Build & Lint:**
  - `[ ]` Compilation check clean (`npm run build` / `tsc --noEmit`)
  - `[ ]` Lint clean (`npm run lint -- --fix` → exit `0`)
  - `[ ]` Type-generation re-run if schema/API changes (Directive 6)
* **Test Report:**
  - `[ ]` Test suite runs clean
  - `[ ]` Code matches exact plan specifications
  - `[ ]` No functional gaps identified
  - `[ ]` Terminal output captured in plan appendix
* **🛑 HALT POINT (Gate D):** Implementation & verification complete. Update the **State & Gates** section at the bottom: Status → `PHASE_8`, Gate D → `APPROVED` + timestamp. Present results for user testing.

---

## 9️⃣ Phase 9: User Review & Tweaks
* **Skills Executed:** `knowledge-capture` (global, on demand for any lesson worth preserving)
* **Status:** `IN_PROGRESS`
* **Tweak Log Location:** All raw tweaks are recorded inline in the `Back-and-Forth Log` below — one entry per round, captured at the moment the user gives feedback. **Any tweak meeting the capture bar** (recurring pattern / tribal-knowledge decision / significant one-off bug or fix) is promoted to `docs/wiki/core/18-knowledge-capture.md` via the `knowledge-capture` skill and consolidated in Phase 10 by `agent-wrap-up`. Default to capture; skip only cosmetic-only tweaks.
* **Back-and-Forth Log:**
  - **Round 1:**
    - **User Feedback:** [description]
    - **Tweaks Applied:** `[ ]` [Tweak 1]
    - **Capture Flag:** [None / `knowledge-capture` triggered — `Recurring` | `Tribal` | `One-off` | `Cosmetic-skip`]
    - **Result:** [PENDING / COMPLETE]
* **✅ Sign-Off:** [Date] — User approved.

---

## 🔟 Phase 10: Document Tweaks & Knowledge Capture
* **Skill Executed:** `agent-wrap-up` (global)
* **Tweaks Summary:**
  - [Tweak 1] — documented only (no theme)
  - [Tweak 2] — **Theme: [Theme Name]** — flagged for knowledge capture
* **Knowledge Capture:**
  - `[ ]` Read `docs/wiki/core/18-knowledge-capture.md` to check for existing related decisions
  - `[ ]` Themed tweaks synced to knowledge capture doc
  - `[ ]` Wiki docs updated per Phase 9 tweaks

---

## ✅ Wrap Up
* **Skill Executed:** `agent-wrap-up` (global)
* **Wiki Updates:** [List wiki docs updated]
* **Plan Archiving:** [Plan archived to `.devops/archive/[name].md`]
* **Backlog Review:** [Backlog items reviewed / updated]
* **Dead-Code Backlog Entries (from Phase 5):**
  - `[ ]` `[slug]-backlog.md` created at `.devops/backlog/` per flagged `file_path:line_number`

---

## 📍 State & Gates (CACHE-ANCHORED — update ONLY this section at gate transitions)

> **Cache rule:** This is the **last section** in the file. Gate transitions mutate ONLY the rows below — phase content above stays byte-stable to preserve LLM prefix-cache hits. Every "Update Status" instruction in the halt points above means "edit this section".

| Metric | Value |
| :--- | :--- |
| **Status** | `BACKLOG` |
| **Version** | `v1.0.0` |
| **Mode** | `USER-MANAGED` / `AUTO` |
| **Active Persona** | `High-Visionary` |
| **Last Updated** | YYYY-MM-DD HH:MM |
| **Depends On** | none |
| **Blocks** | none |

> Valid states: `BACKLOG`, `PHASE_1`, `PHASE_3`, `PHASE_4`, `PHASE_4_REVISION`, `PHASE_6`, `PHASE_8`, `COMPLETE`.

| Gate | Requirement | Status | Timestamp |
| :--- | :--- | :--- | :--- |
| A | Scope approved (Phases 1-3) | `OPEN` | — |
| B | Plan approved (Phase 4) | `OPEN` | — |
| C | Reviews passed (Phases 5-6) | `OPEN` | — |
| D | Implementation verified (Phases 7-8) | `OPEN` | — |

> On each gate: flip the row Status `OPEN` → `APPROVED` (or `REJECTED` → `PHASE_4_REVISION` for Gate C) and stamp Timestamp. Never edit rows above this section for gate bookkeeping.

> **This section is the LAST section in the file. All gate bookkeeping happens here.**
