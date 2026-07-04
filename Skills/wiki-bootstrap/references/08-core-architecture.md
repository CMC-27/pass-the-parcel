---
type: "core"
name: "Core Architecture Concepts"
status: "stable"
dependencies: []
db_relations: []
description: "Key architectural decisions, core engines, technical guardrails, and data management strategies for [APP_NAME]."
---

# Core Architecture Concepts

**Application:** [APP_NAME]

## 1. Architecture Decisions

* **UI/UX:** [Framework] with [styling approach]. Supports [key data-entry patterns — e.g., high-density data grids, CSV ingestion, keyboard navigation].
* **Authentication:** [Auth Provider — e.g., Firebase Auth (Google Sign-In), Supabase Auth, Auth0].
* **Database:** [Database — e.g., Supabase (PostgreSQL), Firebase Firestore, PlanetScale]. [Rationale — e.g., "Chosen to leverage relational capabilities and complex aggregations."]
* **AI Integrations:** [AI Provider & Model] via [API method] for [use cases — e.g., semantic search, fuzzy matching, content generation].

---

## 2. The "[Calculated Truth / Core Engine]" Engine

To prevent data rot, specific fields are never manually entered. They are calculated dynamically on the frontend during rendering and before exports:

* **[Calculated Field 1]:** `[Formula or derivation rule]`
* **[Calculated Field 2]:** `[Formula or derivation rule]`
* **[Calculated Field 3]:** `[Formula or derivation rule]`

---

## 3. Technical Guard Rails

To ensure enterprise-grade stability and data integrity, the following guard rails are implemented:

* **[Auth-to-DB Bridge]:** [Describe how auth identity flows into database security — e.g., "Firebase UID is passed into Supabase client requests to enable Row Level Security (RLS) policies."]
* **[Historical Preservation]:** [Describe soft delete strategy — e.g., "ON DELETE CASCADE is intentionally avoided on Master Data. Use `is_active` boolean flags to preserve historical records."]
* **[Lock Mechanism]:** [Describe any approval lock or finalization gate — e.g., "Once an entity reaches `Approved` status, all fields become read-only."]

---

## 4. Client-Side Data Management & Caching

To handle high data throughput without constant network latency:

* **Persistent Storage:** `[Key entity]` is mirrored in `localStorage`. This allows for zero-latency application starts and persists across browser sessions.
* **Global Context (`[EntityContext]`):** A React Context provider manages [the key entity list] in memory. Components consume this global state instead of performing independent fetches.
* **Chunked Synchronization:** Data is fetched from the backend in background chunks of `[N]` records. This prevents massive single-request payloads.
* **On-Demand Hydration:** Views like `[FeatureBuilder]` only pull specific records for the actively viewed item rather than loading all project data upfront.

---

## 5. Logic: Global vs. Local Architecture

The system operates on a dual-track taxonomy to balance [goal A] with [goal B]:

### The "[Global / Shared]" Branch
* **Purpose:** [Describe global/shared data that applies across all instances — e.g., "Stores agnostic materials used universally across different work types."]
* **Integration:** [Describe how this shared branch is integrated into project-level workflows].

### The "[Guided Path / Constrained Selection]" Engine
* [Describe the constraint engine — e.g., "Estimators are no longer forced to search through 10,000 items. The system automatically filters the inventory to show only items tagged with the specific classification for the current slot."]

---

## 6. Bulk Ingestion & Intelligent Import

To support high-density workflows, the application uses multiple ingestion models:

* **Standard Bulk Ingest:** In `[ImportModal].jsx`. Allows mapping CSV headers to entity metadata for mass-creating shells.
* **[Intelligent / AI-Assisted Import]:** In `[SmartImportModal].jsx`. [Describe AI-assisted pipeline — e.g., routes specific data columns to structural components and uses AI Resolution to match field codes to database records.]
* **Aggregation:** [Describe how the builder aggregates selections from across components into a unified output — e.g., BoM, report, summary].
* **Scaling:** [Describe how multipliers or scaling factors work — e.g., "Applying a Global Multiplier to a record scales all resulting quantities."]

---

## 7. The [Stamping / Snapshot] & [Variant / Override] Model

To ensure project records remain stable even if Global Templates change, the system uses a **[Stamping / Snapshotting]** process during initialization:

### Stamping Process
1. **Metadata Mirroring:** The `[template_id]` is recorded in the `[records]` table for traceability.
2. **[Component / Slot] Snapshotting:** Every template slot is copied as a unique instance record.
3. **Constraint Freezing:** The valid [item/block] constraints from the template are saved into a `[options_snapshot]` (JSONB or equivalent) field, freezing the guided path at creation time.

### The `[VARIANT / Override]` Slot
Every project [record] is automatically injected with a final slot named **`[VARIANT]`**.
* **Purpose:** Acts as a "Universal Slot" to capture site-specific overrides or manual item injections.
* **Logic:** Unlike template-driven slots, the `[VARIANT]` slot has no constraint snapshot, enabling Full Registry Search.
* **Architecture:** This unifies the BoM logic into a single component-based stream, eliminating the need for a separate variations/overrides table.

---

## 8. Data Purge & Archival

The [main builder view] includes a high-stakes **[Archive / Delete]** action:
* **Manual Cascade:** To preserve referential integrity without DB-level cascades, the application performs a manual purge in order: `[child_table_3]` → `[child_table_2]` → `[child_table_1]` → `[parent_table]`.
* **Verification:** Requires a dedicated confirmation modal to prevent accidental data loss.
