# 📦 Parcel Plan: [Plan Name]

> **State Lifecycle Reference:** See `pass-the-parcel` skill's [Plan State Lifecycle table] for valid Status/Persona transitions. Update these fields at every gate — do not leave them at template defaults.

## 📊 State Dashboard
| Metric | Value |
| :--- | :--- |
| **Status** | `BACKLOG` |
| **Version** | `v1.0.0` |
| **Active Persona** | `Planner` |
| **Last Updated** | YYYY-MM-DD HH:MM |

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

## 4️⃣ Phase 4: Detailed Execution Plan
* **Skill Executed:** `ptp-razor-planner`
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
* **Code Snippets & Instructions:**
  - [Exact code / detailed instructions]
* **To-Do List:**
  - `[ ]` [Task 1]
  - `[ ]` [Task 2]
* **Test Verification Plan:**
  - `[command]`
  - `[ ]` [Test case 1]
* **🛑 HALT POINT (Gate B):** Phase 4 complete. Present plan. Next agent handles Phases 5-6 reviews.

---

## 5️⃣ Phase 5: Smooth Operator Product Review
* **Skill Executed:** `ptp-smooth-operator`
* **Prepared By:** `[Agent Persona]` | **Date:** `[YYYY-MM-DD HH:MM]`
* **Status:** `PENDING`
* **Findings:**
  - [✅/⚠️/🚫] **Vision & Journey Integrity** — Vision Test + Journey Continuity + Cross-Feature/Downstream Impact handoff to Phase 6
  - [✅/⚠️/🚫] **Scope Containment (No Gold Plating)** — items cross-referenced vs. Phase 1; unrequested scope cut
  - [✅/⚠️/🚫] **4 Core User States** — Loading / Empty / Error / Success all explicit in plan
  - [✅/⚠️/🚫] **Guardrails & Permissions** — role/tenant/tier restricted-state UI planned
  - [✅/⚠️/🚫] **Mobile / A11y / Telemetry** — responsive layout, keyboard nav, analytics hooks
  - [✅/⚠️/🚫] **Mandatory Decision Sync** — Phase 3 resolutions synced to `docs/wiki/core/18-knowledge-capture.md`
* **Required Fixes:**
  - `[ ]` [Fix 1 — or mark "None"]

## 6️⃣ Phase 6: Grumpy Architect Hygiene Review
* **Skill Executed:** `ptp-grumpy-architect`
* **Prepared By:** `[Agent Persona]` | **Date:** `[YYYY-MM-DD HH:MM]`
* **Status:** `PENDING`
* **Findings:**
  - [✅/⚠️/🚫] **No Vibes-Based Engineering** — types/signatures/contracts explicit; no untested side effects
  - [✅/⚠️/🚫] **Nuanced DRY/WET Scan** — Primitive Rule (DRY) + Domain Rule (WET, Rule of Three) applied
  - [✅/⚠️/🚫] **Bloat & Dead Code** — deps blocked if native/stdlib covers; ghost state hunted; orphans flagged `file_path:line_number`
  - [✅/⚠️/🚫] **Paranoid Security** — secrets via env + `.gitignore`; input typed with `unknown`/Zod; RLS mandated for DB changes; client never trusted
  - [✅/⚠️/🚫] **Survivability (Error Handling)** — async/timeout/network covered; no silent/empty catches; Error Boundaries on volatile components
  - [✅/⚠️/🚫] **Endpoint Protection & Rate Limiting** — throttling + `429` handling + payload size restricted
  - [✅/⚠️/🚫] **Wiki Core Compliance & Instruction Density** — every blueprint cites a `docs/wiki/core/*` doc; surgical file paths + exact names + diffs
* **Required Fixes:**
  - `[ ]` [Fix 1 — or mark "None"]
* **🛑 HALT POINT (Gate C):** Reviews complete. Present findings & required fixes. Wait for approval before execution.

---

## 7️⃣ Phase 7: Implementation Checklist (Execution)
* **Skill Executed:** `ptp-code-surgeon`
* **Surgical Constraints (Non-Negotiable):**
  - `[ ]` Touched only intended lines — no adjacent refactors
  - `[ ]` Cleaned up only owned orphans (imports/types/vars made unused by this change)
  - `[ ]` Pre-existing dead code left untouched (Phase 6 backlog route only)
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
* **🛑 HALT POINT (Gate D):** Implementation & verification complete. Present results for user testing.

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
* **Plan Archiving:** [Plan archived to `docs/archive/[name].md`]
* **Backlog Review:** [Backlog items reviewed / updated]
* **Dead-Code Backlog Entries (from Phase 6):**
  - `[ ]` `[slug]-backlog.md` created at `docs/backlog/` per flagged `file_path:line_number`
* **Status:** `COMPLETE`
