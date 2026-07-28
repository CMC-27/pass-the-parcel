---
type: "core"
name: "Validation Standards"
status: "in-progress"
dependencies: []
db_relations: ["[primary_table]", "[secondary_table]"]
description: "Core validation engine specification, data integrity tiers, and finalization guardrails for [APP_NAME]."
---

# Validation Standards

This document defines the validation tiers and data integrity rules governing [APP_NAME].

---

## 1. System Validation Tiers

### Tier 1: Field-Level Validation
* Managed inline via React views and form hook bindings.
* Applied at the input level, before the user can submit a form.
* **Examples:**
  * Strict format constraints on identifiers (e.g., `[Entity] ID` must match `^[A-Z]{3}-\d{4}$`).
  * Non-empty validation on required fields (`[required_field_1]`, `[required_field_2]`).
  * Range validation on numeric fields (e.g., quantity must be `> 0`).

### Tier 2: Entity-Level Integrity
* Validated at the entity (record) level before saving to the database.
* **Examples:**
  * **[Entity] Quantities:** Must be positive numbers (`quantity > 0`). Negative values only permitted for [exception case — e.g., "credit/deductive items in VARIANT slots"].
  * **[Lookup Binding]:** An entity must be associated with a registered [classification / category] before it can be assigned to [parent entity].
  * **[Uniqueness Constraint]:** `[field]` must be unique within the scope of `[parent_scope]`.

### Tier 3: Cross-Entity / System-Level Integrity
* Validated across related records before [finalization / export / approval].
* **Examples:**
  * [Cross-reference rule — e.g., "All component slots must have at least one selection before an assembly can be approved."]
  * [Dependency check — e.g., "A project cannot be archived while it has assemblies in `In Stores` status."]

---

## 2. The [Budget Lock / Finalization] Guardrail (Strict Constraint)

Once a [record]'s status moves to `[Approved]` or `[In Stores / Finalized]`:
* **Read-Only Enforcement:** Both server-side and client-side locks prevent any field modification.
* **[BLAST Boundary]:** No modification of [quantities / selections / multipliers] is permitted.
* **Override Policy:** Reverting to `[Draft]` status requires [role] permission and [describe audit trail — e.g., "registers an entry in `agent-changelog.md`"].

---

## 3. Error Classification

| Error Type | Behavior | User Impact |
|---|---|---|
| **Warning** | Non-blocking. Shows an alert, allows user to proceed. | [Example: "This quantity seems unusually high."] |
| **Validation Error** | Blocking at field level. Input highlighted red. | [Example: "Material ID format is invalid."] |
| **Critical Stop** | Blocks form submission or status transition. | [Example: "Cannot approve — 3 slots have no selection."] |
| **System Error** | Caught in `try/catch`. Shows a toast notification. | [Example: "Failed to save. Please try again."] |

---

## 4. UX Error Patterns

* **Inline Validation:** Field-level errors appear immediately below the input on blur or submit attempt.
* **Error Summary:** For bulk operations (imports, batch approvals), surface an aggregated error list rather than stopping at the first failure.
* **Toast Notifications:** Use for async operation results (save success, import complete, API errors).
* **Confirmation Modals:** Required for all destructive actions (delete, archive, bulk replace). Must display a count or list of affected records.
