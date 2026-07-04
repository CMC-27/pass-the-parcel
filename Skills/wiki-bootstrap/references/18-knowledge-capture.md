---
type: "core"
name: "Knowledge Capture"
status: "stable"
dependencies: []
db_relations: []
description: "Canonical log of core engineering decisions, tribal knowledge, and architectural strategies for [APP_NAME]."
---

# Knowledge Capture & Decision Log 🧠

This document is the canonical, living repository for key architectural decisions, engineering compromises, and critical business rules governing **[APP_NAME]**. It preserves tribal knowledge and design rationales to guide future development.

---

## How to Add an Entry

Each entry should follow this format:

```markdown
## 🏷️ [Category Emoji] [Category Name]

### [Decision Title]
* **Decision Date**: YYYY-MM-DD
* **Context**: [What was the situation or problem that led to this decision?]
* **Action**: [What was decided and/or implemented?]
* **Rationale**:
    * **[Rationale Point 1]**: [Explanation].
    * **[Rationale Point 2]**: [Explanation].
```

---

## 🗃️ [First Decision Category — e.g., Data Model]

### [First Decision Title — e.g., Why We Split Coordinates into Lat/Long]
* **Decision Date**: YYYY-MM-DD
* **Context**: [Describe the original state — e.g., "Previously, coordinates were stored as a single combined text field."]
* **Action**: [Describe what was changed — e.g., "Replaced the combined field with two independent `latitude` and `longitude` float columns."]
* **Rationale**:
    * **[Point 1]**: [Explanation — e.g., "Splitting the fields allows database-level range validation and simplifies GIS integrations."]
    * **[Point 2]**: [Explanation — e.g., "Enables numerical bounding-box queries directly in SQL without string parsing."]

---

## 🔄 [Second Decision Category — e.g., Import / Ingestion]

### [Second Decision Title — e.g., Conflict Strategy: Skip vs. Replace]
* **Decision Date**: YYYY-MM-DD
* **Context**: [Describe the problem — e.g., "Bulk CSV imports frequently ran into identifier collisions."]
* **Action**: [Describe the solution — e.g., "Implemented an explicit Conflict Strategy Selector (Skip vs Replace) in the Import Modal."]
* **Rationale**:
    * **[Skip Strategy]**: [Explanation — e.g., "Leaves existing records untouched. Perfect for non-destructive incremental updates."]
    * **[Replace Strategy]**: [Explanation — e.g., "Overwrites existing records. Ensures the CSV acts as the Single Source of Truth."]

---

## 🎨 [Third Decision Category — e.g., UI/UX Design]

### [Third Decision Title — e.g., Why We Use Background Color Shifts Instead of Borders]
* **Decision Date**: YYYY-MM-DD
* **Context**: [Describe the situation — e.g., "Early designs used 1px borders to separate sections, creating visual clutter."]
* **Action**: [Describe the change — e.g., "Adopted the 'No-Line Rule': all section boundaries defined through surface color tiers."]
* **Rationale**:
    * **[Point 1]**: [Explanation — e.g., "Eliminating hard borders creates a more sophisticated, layered feel matching the design theme."]
    * **[Point 2]**: [Explanation — e.g., "Reduces visual noise for power users who spend hours in the interface."]

---

## 🔒 [Fourth Decision Category — e.g., Data Integrity / Locks]

### [Fourth Decision Title — e.g., The Budget Lock: Why Approved Records are Immutable]
* **Decision Date**: YYYY-MM-DD
* **Context**: [Describe the problem — e.g., "Without a lock, estimators could modify quantities after PM approval, causing logistics discrepancies."]
* **Action**: [Describe the implementation — e.g., "Implemented a server-side and client-side read-only lock that activates when status reaches `Approved`."]
* **Rationale**:
    * **[Point 1]**: [Explanation — e.g., "Protects financial and operational integrity once a commitment has been made."]
    * **[Point 2]**: [Explanation — e.g., "Ensures warehouse picks and field packs match exactly what was engineered."]
