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
* **Intent:** [Terse description of user's core goal]
* **In Scope:** 
  - [Item 1]
* **Out of Scope:**
  - [Item 1]

## 2️⃣ Phase 2: Requirements & Context
* **Relevant Docs Found:** 
  - `[doc.md]` (file:///path/to/doc.md) -> [Why it's relevant]
* **Relevant Code Found:** 
  - `[file.js]` (file:///path/to/file.js) -> [What needs to change]

## 3️⃣ Phase 3: User Clarification
* **Open Questions:**
  - `[ ]` [Question for user] -> **Answer:** [User's response]
* **Final Validation:**
  - `[ ]` Is this all the context required? -> **Answer:** [Yes / No + missing details]

---

## 4️⃣ Phase 4: Detailed Execution Plan
* **Prepared By:** `[Agent Persona]` | **Date:** `[YYYY-MM-DD HH:MM]`
* **Files to Create/Modify:**
  - `[path]` (file:///path) -> [change description]
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

## 5️⃣ Phase 5: Product Owner Review
* **Prepared By:** `[Agent Persona]` | **Date:** `[YYYY-MM-DD HH:MM]`
* **Status:** `PENDING`
* **Findings:**
  - [✅/⚠️/🚫] **Vision & Scope** — [brief note]
  - [✅/⚠️/🚫] **Business Logic & Edge Cases** — [brief note]
  - [✅/⚠️/🚫] **Dependency & Functional Risk** — [brief note]
  - [✅/⚠️/🚫] **Completeness & User Intent** — [brief note]
* **Required Fixes:**
  - `[ ]` [Fix 1 — or mark "None"]

## 6️⃣ Phase 6: Senior Dev Hygiene Review
* **Prepared By:** `[Agent Persona]` | **Date:** `[YYYY-MM-DD HH:MM]`
* **Status:** `PENDING`
* **Findings:**
  - [✅/⚠️/🚫] **DRY Scan** — [brief note on any duplicates found]
  - [✅/⚠️/🚫] **Abstraction & Architecture** — [brief note]
  - [✅/⚠️/🚫] **State Management & Data Flow** — [brief note]
  - [✅/⚠️/🚫] **Technical Debt & Deletion** — [brief note]
  - [✅/⚠️/🚫] **Secret Management** — [brief note]
  - [✅/⚠️/🚫] **Data Security (RLS)** — [brief note]
  - [✅/⚠️/🚫] **Rate Limiting** — [brief note]
  - [✅/⚠️/🚫] **Error Handling** — [brief note]
* **Required Fixes:**
  - `[ ]` [Fix 1 — or mark "None"]
* **🛑 HALT POINT (Gate C):** Reviews complete. Present findings & required fixes. Wait for approval before execution.

---

## 7️⃣ Phase 7: Implementation Checklist (Execution)
- `[ ]` [Execution Step 1 from Phase 4]
- `[ ]` [Execution Step 2 from Phase 4]

## 8️⃣ Phase 8: Verification Dashboard
* **Verification Status:** `PENDING`
* **Report:**
  - `[ ]` Test suite runs clean
  - `[ ]` Code matches exact plan specifications
  - `[ ]` No functional gaps identified
* **🛑 HALT POINT (Gate D):** Implementation & verification complete. Present results for user testing.

---

## 9️⃣ Phase 9: User Review & Tweaks
* **Status:** `IN_PROGRESS`
* **Back-and-Forth Log:**
  - **Round 1:**
    - **User Feedback:** [description]
    - **Tweaks Applied:** `[ ]` [Tweak 1]
    - **Result:** [PENDING / COMPLETE]
* **✅ Sign-Off:** [Date] — User approved.

---

## 🔟 Phase 10: Document Tweaks & Knowledge Capture
* **Tweaks Summary:**
  - [Tweak 1] — documented only (no theme)
  - [Tweak 2] — **Theme: [Theme Name]** — flagged for knowledge capture
* **Knowledge Capture:**
  - `[ ]` Themed tweaks synced to knowledge capture doc
  - `[ ]` Wiki docs updated per Phase 9 tweaks

---

## ✅ Wrap Up
* **Wiki Updates:** [List wiki docs updated]
* **Plan Archiving:** [Plan archived to `dev/archive-plans/[name].md`]
* **Backlog Review:** [Backlog items reviewed / updated]
* **Status:** `COMPLETE`
