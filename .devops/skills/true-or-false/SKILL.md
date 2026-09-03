---
name: true-or-false
description: Make sure to use this skill whenever you need to align codebase reality with stated requirements, validate a user or data journey step-by-step, eliminate batch-generation hallucinations, or surface hidden bugs/dead code via a structured True/False evaluation loop.
version: 1
updated: 2026-09-03
---

# True or False — Dynamic Codebase Alignment Workflow

## Purpose
To align human intent, product design, and architectural reality by validating the codebase one step at a time against **two audiences**: the Product Owner (who validates intended behavior in plain language) and the Senior Architect (who verifies code proof). This dual-lens approach eliminates batch-generation hallucinations, accommodates dynamic branching, and surfaces hidden bugs or dead code early — without requiring the PO to read a single line of code.

The final goal is to reach **100% Alignment (All True)** for a specified user or data journey.

---

## Phase 1: Initialization & Scope Definition

Before generating any validation statements, establish strict boundaries to prevent context drift and state amnesia.

1. **Prompt for Scope:** The user must explicitly define, or the agent must read from context, the following constraints:
   * **User Persona:** (e.g., Guest User, Admin, Premium Subscriber, New Zealand Region User)
   * **Target Workflow:** (e.g., "First-time launch through completed checkout")
2. **Generate Initial Journey Map:** Perform an initial crawl of the codebase (routing, entry points, state managers) and output a high-level, skeletal index of the journey (minimum 10 checkpoints).
   * *Note: This is an overview map of titles only, not the detailed statements.*
   * Frame the titles in user-facing language (e.g., "User submits the form" not "POST handler validates payload") so the Product Owner can orient themselves from the start.

---

## Phase 2: The Just-In-Time (JIT) Evaluation Loop

Evaluate exactly **one statement at a time**. It is strictly forbidden to generate Statement [X+1] until the user has responded to Statement [X].

### Statement Presentment Format (Two-Tier)

Each statement has **two layers**: a **Product Owner Question** (plain language, no code) and an **Architect Reference** (live code proof). The PO answers based on intended behavior; the architect reference lets a technical reader verify the claim.

For the current step, first print the step header and metadata as text, then use the `question` tool to prompt the user with selectable answers:

**Printed text:**
```
### Step [X] / [Estimated Total]: [Step Title]
* **Current Scope:** `[Persona]` -> `[Active Workflow Segment]`

**Product Owner Question:**
[Ask what *should* happen from a user or business perspective. Use plain language — no implementation details, no file paths, no technical jargon. Frame it like: "When a user does X, they see Y, right?" or "The system should handle Z this way — is that correct?"]

**Architect Reference (Code Proof):**
* **File:** `path/to/file.ext` (Lines X-Y)
```typescript
// CRITICAL: Extract and print the exact live code snippet
// being referenced to prevent lazy line-number hallucinations.
```
```

**Then invoke the `question` tool with these options:**
* **Question:** "Does the behavior described above match your expectations?"
* **Header:** "Step [X] Response"
* **Options:**
  * **True** — Yes, this is correct as-is.
  * **False** — No, this is wrong. (You can describe the correction via free-text.)
  * **Skip Branch** — This feature path is deprecated / irrelevant; skip all subsequent steps in this branch.
  * **Other** — Clarification or nuance needed. (Describe via free-text.)

---

#### Example (AccordionSection)

**Printed text:**
### Step 3 / 15: Content Accordion Reveals Details
* **Current Scope:** `Guest User` -> `Browsing submission guidelines`

**Product Owner Question:**
When a user clicks the section header in the accordion, the hidden content underneath slides open and the arrow icon flips direction. If they click it again, it closes. Does this match the expected behavior?

**Architect Reference (Code Proof):**
* **File:** `src/components/ui/AccordionSection.tsx` (Lines 10-38)
```tsx
const [isOpen, setIsOpen] = useState(defaultOpen);
// ...
<button onClick={() => setIsOpen(o => !o)}>
  {isOpen ? <ChevronUp /> : <ChevronDown />}
</button>
{isOpen && <div>{children}</div>}
```

**Then call `question` with:**
* **Question:** "Does the behavior described above match your expectations?"
* **Header:** "Step 3 Response"
* **Options:**
  * **True** — Yes, this is correct as-is.
  * **False** — No, this is wrong.
  * **Skip Branch** — This feature path is deprecated / irrelevant; skip all subsequent steps in this branch.
  * **Other** — Clarification or nuance needed.

---

## Phase 3: Response Processing & State Machine Logic

Route the next action dynamically based on the user's explicit input:

### 1. If User Responds True
* Mark step as **[Aligned]**.
* Advance directly to the next logical step in the Journey Map.

### 2. If User Responds False (with or without correction)
* Mark step as **[Misaligned]**.
* **Log Backlog Item:** Delegate to the `backlog` skill to create a structured backlog entry (see Phase 4 for the template). Pass the code location, the misconception, and the user's correction as context.
* **Recalibrate Internal State:** Re-read the affected files using the user's correction as the new source of truth.
* **Dynamic Pivot:** If the correction changes subsequent steps, print a brief **[Journey Map Updated]** alert showing the adjusted path, then present the new, corrected Step [X+1].

### 3. If User Responds Other (Clarification or Nuance)
* If the nuance requires a codebase modification, treat it as **False** and delegate a backlog item to the `backlog` skill.
* If the nuance clarifies an architectural branch (e.g., "This only happens if the DB flag is local"), absorb the logic and adapt the next question accordingly.

### 4. Global Override Commands
* **Skip Branch / Deprecated:** If the user notes that a feature block is dead code or being removed, delegate a backlog item to the `backlog` skill labeled "Prune/Clean Codebase" and completely skip all subsequent steps associated with that feature module.

---

## Phase 4: Session Conclusion & Artifact Output

When the journey is complete (or manually halted by the user), output a final compilation block.

### Verification Summary
| Metric | Value |
|--------|-------|
| **Target Workflow Evaluated** | [Workflow Name] |
| **Total Steps Checked** | [Total N] |
| **Total Aligned (True)** | [Count X] |
| **Total Misaligned (False)** | [Count Y] |

### Dynamic Backlog Tasks
For every non-True path encountered during the session, delegate the following to the `backlog` skill, which will create a full `-plan.md` file in `.devops/plans/` and an entry in `.devops/backlog/backlog-index.md`:

```
#### Backlog Item [ID] - Misalignment in [Feature/Component Name]
* **Target Location:** `path/to/file.ext`
* **Faulty Assumption:** [What the agent thought the code did]
* **User Ground Truth:** "[User's exact feedback]"
* **Remediation Action:** [Technical description of what needs to be added, changed, or deleted in the codebase to align reality with human intent.]
```

> Delegation to the `backlog` skill ensures all misalignments are captured as properly scaffolded, parked backlog entries ready for future execution — consistent with the project's existing backlog workflow.
