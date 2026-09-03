---
name: knowledge-capture
description: Automates the recording of user decisions, feedback, and tribal knowledge to ensure project consistency and long-term learning across all development tasks.
version: "1.1"
author: "Antigravity Team"
---

# Knowledge Capture Skill

## Goal
Capture and persist key architectural or procedural decisions in a centralized log file.

## File Format Reference

This skill adds entries to `.wiki/core/18-knowledge-capture.md`, which is periodically restructured by the **knowledge-consolidation** skill into a canonical 4-section layout. Write entries in the format that matches the section below — it matches what consolidation Phase 9 produces.

### Current file sections

```
## Quick Reference — Top 10 Rules
(compact table of highest-signal rules — updated by consolidation only, not by capture)

## Pitfalls to Avoid
_Mistakes that cost time or broke things._
- **[Short title]**: [One-line rule]. *Why:* [One-line consequence]. *Do instead:* [One-line fix].

## Rules & Constraints
_Stable rules derived from prior decisions. Grouped by theme._

### [Theme Name]
- **[Short title]**: [One-line rule]. *See also:* [wiki doc link if applicable].

## Decision Archive
_Full context for decisions that need historical rationale._

### [Decision Title]
- **Context**: [1–2 lines max]
- **Action**: [1–2 lines max]
- **Rationale**: [1–2 lines max]
- **Wiki ref**: [link]
```

## Workflow

### 1. Discovery & Initialization
*   The canonical knowledge capture file is **always** located at:
    ```
    .wiki/core/18-knowledge-capture.md
    ```
    Resolve the absolute path relative to the active workspace root. **Do not search for alternative filenames or locations.**
*   If the file **does not exist**, create it with the skeleton above.

### 2. Section Classification
Classify the decision into one of three sections based on its nature:

| Section | Use when | Format max |
|---------|----------|------------|
| **Pitfalls to Avoid** | A bug, config issue, or design mistake that cost time. Must have a clear "do instead" fix. | 3 lines |
| **Rules & Constraints** | A stable pattern, naming convention, or constraint. Actionable — tells future agents what to do or avoid. | 3 lines |
| **Decision Archive** | A decision with significant historical rationale behind it. Needs Context + Action + Rationale to explain *why* over other options. | 10 lines |

When in doubt between **Pitfall** and **Rule**: a Pitfall answers "what broke and how to fix it"; a Rule answers "how things work and what to follow."

### 3. Entry Capture
*   Accept a "Decision" or "Suggestion" from the user.
*   Assign a **Theme** that best categorises the entry (used as a grouping heading in Rules & Constraints). Common themes: `Architecture & Patterns`, `UI/UX & Design Aesthetic`, `Testing & QA`, `Tooling & Code Quality`, `Product & Process`
*   Append the new entry to the appropriate section using the exact format from §File Format Reference.
*   If adding to **Rules & Constraints**, place under the correct `### [Theme]` subsection. Create a new theme subsection if none fits.
*   If adding to **Pitfalls**, no theme subsection — entries are flat under the section header.
*   If adding to **Decision Archive**, use the `### [Title]` format with `- **Context:**` / `- **Action:**` / `- **Rationale:**` / `- **Wiki ref:**` bullet points.
*   **Do not** add or modify the Quick Reference table — it's maintained by the consolidation skill.

### 4. Validation
*   Confirm to the user that the knowledge has been persisted.
*   Summarize the impact of the decision.
*   Note if the entry is eligible for wiki promotion (stable, cross-cutting, survived multiple plans) — consolidation will handle the actual promotion.

## Usage Guidelines
*   **Proactive Recording**: If a user says "I prefer X over Y" or "Always do Z in this project", activate this skill immediately.
*   **App Dev Universal**: This skill is NOT limited to estimation briefs; use it for all coding, architectural, and design decisions.
*   **Consolidation boundary**: This skill captures raw knowledge. The `knowledge-consolidation` skill handles deduplication, tightening, promotion to wiki, and restructuring. Do not self-edit existing entries — leave reorganization to consolidation.
