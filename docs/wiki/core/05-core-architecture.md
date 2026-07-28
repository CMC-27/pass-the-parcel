---
type: "core"
name: "Core Architecture Concepts"
status: "stable"
dependencies: []
db_relations: []
description: "Key architectural decisions, core engines, technical guardrails, and data management strategies."
---

# Core Architecture Concepts

**Application:** [APP_NAME]

## 1. Architecture Decisions

* **UI/UX:** [Framework] with [styling approach].
* **Authentication:** [Auth Provider].
* **Database:** [Database technology]. [Rationale].
* **AI Integrations:** [AI Provider & Model] via [API method].

---

## 2. The "[Calculated Truth / Core Engine]" Engine

To prevent data rot, specific fields are never manually entered. They are calculated dynamically:

* **[Calculated Field 1]:** `[Formula or derivation rule]`
* **[Calculated Field 2]:** `[Formula or derivation rule]`
* **[Calculated Field 3]:** `[Formula or derivation rule]`

---

## 3. Technical Guard Rails

* **[Auth-to-DB Bridge]:** [Describe how auth identity flows into database security].
* **[Historical Preservation]:** [Describe soft delete strategy].
* **[Lock Mechanism]:** [Describe any approval lock or finalization gate].

---

## 4. Client-Side Data Management & Caching

* **Persistent Storage:** `[Key entity]` is mirrored in `localStorage`.
* **Global Context (`[EntityContext]`):** A React Context provider manages [the key entity list] in memory.
* **Chunked Synchronization:** Data is fetched in background chunks of `[N]` records.
* **On-Demand Hydration:** Views only pull specific records for the actively viewed item.

---

## 5. Logic: Global vs. Local Architecture

### The "[Global / Shared]" Branch
* **Purpose:** [Describe global/shared data that applies across all instances].
* **Integration:** [Describe how this shared branch is integrated].

### The "[Guided Path / Constrained Selection]" Engine
* [Describe the constraint engine that prevents incompatible selections].

---

## 6. Bulk Ingestion & Intelligent Import

* **Standard Bulk Ingest:** In `[ImportModal].jsx`. Allows mapping CSV headers to entity metadata.
* **[Intelligent / AI-Assisted Import]:** In `[SmartImportModal].jsx`. [Describe AI-assisted pipeline].
* **Aggregation:** [Describe how selections are aggregated into a unified output].
* **Scaling:** [Describe how multipliers or scaling factors work].

---

## 7. The [Stamping / Snapshot] & [Variant / Override] Model

To ensure records remain stable even if global templates change, the system uses a **[Stamping / Snapshotting]** process during initialization:

### Stamping Process
1. **Metadata Mirroring:** The `[template_id]` is recorded for traceability.
2. **[Component / Slot] Snapshotting:** Every template slot is copied as a unique instance record.
3. **Constraint Freezing:** Valid constraints are saved into a `[options_snapshot]` field.

### The `[VARIANT / Override]` Slot
Every project [record] is automatically injected with a final slot named **`[VARIANT]`**.
* **Purpose:** Acts as a "Universal Slot" to capture site-specific overrides.
* **Logic:** No constraint snapshot, enabling full registry search.

---

## 8. Data Purge & Archival

The [main builder view] includes a high-stakes **[Archive / Delete]** action:
* **Manual Cascade:** Performs a manual purge in order: `[child_table_3]` → `[child_table_2]` → `[child_table_1]` → `[parent_table]`.
* **Verification:** Requires a dedicated confirmation modal.
