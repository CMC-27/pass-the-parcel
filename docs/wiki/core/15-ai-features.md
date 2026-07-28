---
type: "core"
name: "AI Features & Pipelines"
status: "stable"
dependencies: []
db_relations: []
description: "Documents the in-app AI capabilities, model integrations, prompt architectures, and human-in-the-loop patterns."
---

# AI Integration & Agentic Workflows

**AI Engine:** [AI Provider & Model]

---

## 1. AI Design Philosophy

* **Human-in-the-Loop (HITL):** The AI acts as an advisor and drafter. All AI-generated outputs must be explicitly confirmed by a human before being saved.
* **[API Method]:** [Describe the integration method].
* **Structured Outputs:** Leverage JSON response schemas where possible.
* **Filtered Context:** Only inject contextually relevant subsets of data into AI prompts.

---

## 2. Core AI Workflows

### 2.1 [AI Workflow Name 1] — [Short Descriptor]

* **Objective:** [What problem this AI workflow solves].
* **Trigger:** [When this workflow is invoked].
* **Workflow:**
  1. [Step 1 description].
  2. [Step 2 description].
  3. [Step 3 description].
  4. [Step 4 description].
* **Function:** `[functionName]` in `src/utils/[aiClient].js`.

---

### 2.2 [AI Workflow Name 2] — [Short Descriptor]

* **Objective:** [What problem this AI workflow solves].
* **Trigger:** [When this workflow is invoked].
* **Workflow:**
  1. [Step 1].
  2. [Step 2].
  3. [Step 3].
* **Function:** `[functionName]` in `src/utils/[aiClient].js`.

---

### 2.3 [Fuzzy Matching / Resolution Workflow] — [Short Descriptor]

* **Objective:** Automatically match raw identifiers from imported data to correct system records.
* **Trigger:** Called during [import step] for any items with no direct DB match.
* **Workflow:**
  1. The import wizard extracts unique identifiers from mapped data columns.
  2. Direct DB lookup resolves exact matches first.
  3. Unresolved items are sent to [AI Model] with filtered candidate records.
  4. AI applies matching heuristics to return `{ code, record_id, confidence, reasoning }`.
  5. Results displayed in a review table. Users can accept or override.
* **Function:** `[resolveFunction]` in `src/utils/[aiClient].js`.

---

## 3. Prompt Engineering Standards

* **[Injection Pattern]:** [How relevant data is injected into prompts].
* **[Output Schema]:** [Expected JSON response structure].
* **[Fallback Behavior]:** [What happens if the AI returns invalid output].
* **[Safety / Injection Guard]:** [Input sanitization before passing to model].
