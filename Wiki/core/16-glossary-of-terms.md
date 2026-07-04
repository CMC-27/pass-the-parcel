---
type: "core"
name: "Glossary of Terms"
status: "stable"
dependencies: []
db_relations: []
description: "A definitive reference for business logic terms, technical hierarchy, UI concepts, and domain abbreviations."
---

# Glossary of Terms

This document defines the terminology used across the application, database, and documentation. It ensures that users and AI agents maintain a consistent understanding of business and functional concepts.

---

## The Data Hierarchy

| Term | Level | Definition |
| :--- | :--- | :--- |
| **[Level 1 Name]** | 1 | [Definition — e.g., "The highest classification category."] |
| **[Level 2 Name]** | 2 | [Definition — e.g., "The major build category or deliverable type."] |
| **[Level 3 Name]** | 3 | [Definition — e.g., "A functional section or subsystem."] |
| **[Level 4 Name]** | 4 | [Definition — e.g., "A specific design variation or type."] |
| **[Atomic Entity]** | Atomic | [Definition — e.g., "A single inventory item or SKU."] |
| **[Template Entity]** | Template | [Definition — e.g., "A reusable group of items with standard quantities."] |

---

## Alphabetical Glossary

### A
- **[Term A1]:** [Definition. Include which database tables or UI elements this relates to.]
- **[Term A2]:** [Definition.]

### B
- **[Term B1]:** [Definition.]
- **[BoM / Bill of Materials]:** The final, calculated list of every [item/material] required for a [record], [unit], or [project].
- **[Budget Lock / Approval Lock]:** A critical state triggered when a record is set to `[Approved]` or `[Finalized]`. All fields become read-only.

### C
- **[Term C1]:** [Definition.]

### D
- **[Term D1]:** [Definition.]

### E
- **[External ID]:** A user-defined identifier from an external source.

### F
- **[Feedback / Field Log]:** Records created after execution to log shortfalls or surpluses.

### G
- **[Guided Path]:** Structural constraints enforced by the classification dictionary.

### I
- **[Import / Ingestion]:** The process of loading data from an external source.

### L
- **[Lookup Data / Registry]:** The classification tree defining relationships between hierarchy levels.

### M
- **[Multiplier / Calculation Logic]:** The calculation engine: `[Input A] × [Input B] × [Input C] = [Total Output]`.

### O
- **[Options Snapshot]:** A frozen copy of valid constraints saved at record creation time (Stamping).

### P
- **[Pick & Pack / Core Lifecycle]:** [Describe the core operational lifecycle.]

### S
- **[Stamping]:** The process of initializing a new record by copying a template structure.
- **[Status Lifecycle]:** [List status states — e.g., `Draft` → `Approved` → `Installed`.]

### V
- **[VARIANT / Universal Slot]:** A special catch-all slot with no structural constraints.

---

> When prompting an AI agent, use these specific terms to ensure the agent targets the correct database tables and UI logic.
