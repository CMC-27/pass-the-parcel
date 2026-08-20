---
type: "core"
name: "Glossary of Terms"
status: "stable"
description: "A definitive reference for business logic terms, technical hierarchy, UI concepts, and domain abbreviations in [APP_NAME]."
---

# 📖 Glossary of Terms: [APP_NAME]

This document defines the terminology used across the application, database, and documentation. It ensures that users and AI agents maintain a consistent understanding of business and functional concepts.

---

## 🏗️ The Data Hierarchy

| Term | Level | Definition |
| :--- | :--- | :--- |
| **[Level 1 Name]** | 1 | [Definition — e.g., "The highest classification category."] |
| **[Level 2 Name]** | 2 | [Definition — e.g., "The major build category or deliverable type."] |
| **[Level 3 Name]** | 3 | [Definition — e.g., "A functional section or subsystem of a deliverable."] |
| **[Level 4 Name]** | 4 | [Definition — e.g., "A specific design variation or type."] |
| **[Atomic Entity]** | Atomic | [Definition — e.g., "A single inventory item or ERP SKU."] |
| **[Template Entity]** | Template | [Definition — e.g., "A reusable group of atomic items with standard quantities, tagged to a classification path."] |

---

## 🔤 Alphabetical Glossary

### A
- **[Term A1]:** [Definition. Include which database tables or UI elements this term relates to.]
- **[Term A2]:** [Definition.]

### B
- **[Term B1]:** [Definition.]
- **[Term B2]:** [Definition.]
- **[BoM / Bill of Materials]:** The final, calculated list of every [item/material] required for a [record], [unit], or [project].
- **[Budget Lock / Approval Lock]:** A critical state triggered when a [record] is set to `[Approved]` or `[Finalized]`. All [quantities/selections] become read-only to prevent [financial/logistics] drift.

### C
- **[Term C1]:** [Definition.]

### D
- **[Term D1]:** [Definition.]

### E
- **[External ID]:** A user-defined identifier from an external source (e.g., an engineering drawing reference number, a GIS asset ID, or an ERP record number).

### F
- **[Feedback / Field Log]:** Records created [after execution/installation] to log shortfalls (more [item] used than [packed/planned]) or surpluses ([item] returned to [store/inventory]).

### G
- **[Guided Path]:** The structural constraints enforced by the classification dictionary. It prevents a user from selecting an incompatible [item] for a given [slot/component].

### I
- **[Import / Ingestion]:** The process of loading [data/records] from an external source (e.g., CSV, API) into the application.

### L
- **[Lookup Data / Registry]:** The [N]-level classification tree that defines relationships between [Level 1], [Level 2], [Level 3], and [Level 4] entries.

### M
- **[Multiplier / Calculation Logic]:** The calculation engine: `[Input A] × [Input B] × [Input C] = [Total Output]`.

### O
- **[Options Snapshot]:** A frozen copy of valid [item] constraints saved inside a [record] at the moment of creation (Stamping). Ensures that if an Admin changes a template later, existing project records remain stable.

### P
- **[Pick & Pack / Core Lifecycle]:** [Describe the core operational lifecycle — e.g., "Picking materials from the warehouse and packing them for field deployment."]

### S
- **[Stamping]:** The process of initializing a new [record] by copying the structure of a [Template/Blueprint].
- **[Status Lifecycle]:** [List the status states — e.g., `Draft` → `Approved` → `In Stores` → `Installed`].

### V
- **[VARIANT / Universal Slot]:** A special "catch-all" slot added to every [record]. It has no structural constraints, allowing for site-specific overrides or direct selection of [atomic items] (bypassing the [template/block] system).

---
> [!TIP]
> When prompting an AI agent, use these specific terms (e.g., "[Term]" instead of a generic word like "row" or "item") to ensure the agent targets the correct database tables and UI logic.
