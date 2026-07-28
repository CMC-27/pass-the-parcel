---
type: "core"
name: "AI Features & Pipelines"
status: "stable"
dependencies: []
db_relations: []
description: "Documents the in-app AI capabilities, model integrations, prompt architectures, and human-in-the-loop patterns for [APP_NAME]."
---

# AI Integration & Agentic Workflows

**AI Engine:** [AI Provider & Model — e.g., Gemini 2.5 Flash via Gemini Developer REST API]

---

## 1. AI Design Philosophy

* **Human-in-the-Loop (HITL):** The AI acts as an advisor and drafter. All AI-generated outputs must be explicitly confirmed by a human user before being saved or acted upon.
* **[API Method]:** [Describe the integration method — e.g., "Direct REST calls to `generativelanguage.googleapis.com` using `VITE_GEMINI_API_KEY`. No proxy layer required."]
* **Structured Outputs:** Leverage JSON response schemas where possible to ensure the frontend can render AI output into predictable UI elements.
* **Filtered Context:** To prevent token limit issues, only inject contextually relevant subsets of data into AI prompts. [Describe the cap — e.g., "Capped at 200 items for resolution tasks."]

---

## 2. Core AI Workflows

### 2.1 [AI Workflow Name 1] — [Short Descriptor]

* **Objective:** [Describe what problem this AI workflow solves — e.g., "Build complex assemblies without hallucinating internal part numbers."]
* **Trigger:** [Describe when this workflow is invoked — e.g., "User provides a natural language prompt or pastes structured data."]
* **Workflow:**
  1. [Step 1 description — user input or trigger].
  2. [Step 2 description — AI processing / model call].
  3. [Step 3 description — UI presentation of AI output].
  4. [Step 4 description — human confirmation / override].
* **Function:** `[functionName]` in `src/utils/[aiClient].js`.

---

### 2.2 [AI Workflow Name 2] — [Short Descriptor]

* **Objective:** [Describe what problem this AI workflow solves].
* **Trigger:** [Describe when this workflow is invoked].
* **Workflow:**
  1. [Step 1].
  2. [Step 2].
  3. [Step 3].
* **Function:** `[functionName]` in `src/utils/[aiClient].js`.

---

### 2.3 [AI Workflow Name 3] — [Short Descriptor] *(Optional)*

* **Objective:** [Describe what problem this AI workflow solves].
* **Workflow:** [Brief description of the pipeline].
* **Function:** `[functionName]` in `src/utils/[aiClient].js`.

---

### 2.4 [Fuzzy Matching / Resolution Workflow] — [Short Descriptor]

* **Objective:** Automatically match raw [codes / strings / identifiers] from imported data to their correct system records, without requiring the user to manually identify each one.
* **Trigger:** Called during [import step] of `[ImportModal]` for any [items] that had no direct DB match.
* **Workflow:**
  1. The import wizard extracts unique [identifiers / codes] from mapped data columns.
  2. Direct DB lookup resolves exact matches first.
  3. Unresolved items are sent to [AI Model] with a filtered list of candidate records.
  4. AI applies [domain-specific matching heuristics] to return `{ code, record_id, confidence, reasoning }` for each match.
  5. Results are displayed in a review table. Users can accept AI suggestions or apply manual overrides before deployment.
* **Function:** `[resolveAmbiguousCodes]` in `src/utils/[aiClient].js`.
* **Parser Support:** `src/utils/[parser].js` — handles extraction and payload synthesis.

---

## 3. Prompt Engineering Standards

* **[Injection Pattern]:** [Describe how relevant data is injected into prompts — e.g., "Pass a filtered JSON array of candidate records directly into the system prompt."]
* **[Output Schema]:** [Describe the expected JSON response structure from the model].
* **[Fallback Behavior]:** [Describe what happens if the AI returns invalid output — e.g., "If the model cannot determine a match, return `confidence: 0` and surface the item for manual review."]
* **[Safety / Injection Guard]:** [Describe any input sanitization applied before passing user input to the model].
