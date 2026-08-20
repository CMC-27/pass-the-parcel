---
name: knowledge-capture
description: Automates the recording of user decisions, feedback, and tribal knowledge to ensure project consistency and long-term learning across all development tasks.
version: "1.0"
author: "Antigravity Team"
---

# Knowledge Capture Skill

## Goal
Capture and persist key architectural or procedural decisions in a centralized log file.

## Workflow

### 1. Discovery & Initialization
*   The canonical knowledge capture file is **always** located at:
    ```
    docs/wiki/core/18-knowledge-capture.md
    ```
    Resolve the absolute path relative to the active workspace root. **Do not search for alternative filenames or locations.**
*   If the file **does not exist**, create it using the Initial Content Template below.
*   **Entry Format (Hybrid Attribution):**
    Each entry MUST follow the structure in `docs/wiki/templates/knowledge-capture-template.md`:
    - Category header (e.g. `## [Emoji] [Category]`)
    - `### [Decision Title]`
    - Optional `> **Sources:**` / `> **Raw:**` blockquote (only for any future local file refs)
    - `* **Decision Date:** YYYY-MM-DD`
    - `* **PR(s):** [list]` and `* **External Refs:** [list]` (inline link lists)
    - `* **Context:**` / `* **Action:**` / `* **Rationale:**` with sub-bullets
*   See `docs/wiki/examples/knowledge-capture-example.md` for a worked example.

### 2. Entry Capture
*   Accept a "Decision" or "Suggestion" from the user.
*   Determine the current project context and assign a **Theme** that best categorises the entry. Common themes include:
    - `UI/UX Preferences`, `Architecture & Patterns`, `Data & State Management`, `Tooling & DevOps`, `Business Logic & Rules`, `Performance & Constraints`, `Testing & QA`, `Naming Conventions & Style`
*   Append a new entry to the appropriate category section using the **hybrid format above**. Do NOT use the legacy 4-column table format for new entries. Old entries may remain in the table format.

### 3. Validation
*   Confirm to the user that the knowledge has been persisted.
*   Summarize the impact of the decision.

## Usage Guidelines
*   **Proactive Recording**: If a user says "I prefer X over Y" or "Always do Z in this project", activate this skill immediately.
*   **App Dev Universal**: This skill is NOT limited to estimation briefs; use it for all coding, architectural, and design decisions.
