---
type: "core"
name: "User Journey & Data Hierarchy"
status: "stable"
dependencies: []
db_relations: []
description: "End-to-end user journey across all roles, with the definitive data hierarchy reference for [APP_NAME]."
---

# User Journey & Data Hierarchy

**Application:** [APP_NAME]
**Summary:** [One-sentence summary of the application's operational purpose and what this document covers].

---

## Part 1: The Data Hierarchy (Source of Truth)

Understanding this hierarchy is mandatory before understanding any user journey. Every action in [APP_NAME] either reads from or writes to one of these levels.

```
MASTER DATA (Global — Admin-owned, stable reference data)
│
├── [top_level_entity]        ← [Description: e.g., classification dictionary]
│   ├── [CATEGORY_A]          (Level 1 — e.g., "Category A")
│   ├── [CATEGORY_B]          (Level 2 — e.g., "Category B")
│   └── [CATEGORY_C]          (Level 3 — e.g., "Category C")
│
├── [atomic_entity]           ← [Description: e.g., inventory items, base records]
│   └── e.g., "[Example record identifier]"
│
└── [template_entity]         ← [Description: e.g., grouping templates]
    └── [junction_entity]     ← [Description: bill of materials / child records]

────────────────────────────────────────────────────────────────────
PROJECT DATA (Project-scoped — user-managed, per engagement)
│
└── [project_entity]          ← Root container for an engagement
    └── [child_entity]        ← Physical units/nodes (e.g., a specific item/job)
        ├── [slot_entity]     ← Structural slots / component placeholders
        │   └── [selection_entity] ← Actual BoM: what fills each slot
        │       ├── → [template_entity] (resolved to [junction_entity] → [atomic_entity])
        │       └── → [atomic_entity] (direct assignment)
        └── [feedback_entity] ← Field shortfall/surplus logs after execution
```

### Core Calculation Logic
> **[Output] = [Input A] × [Input B] × [Input C]**

[Explain in plain language how the multipliers or aggregation logic stacks. Describe what each variable represents and what the output is used for.]

---

## Part 2: Master Data Setup ([Admin Role Name])

Before any project work is possible, an [Admin] must build the reference library. This is the foundation everything else depends on.

### Step 1 — Build the Classification Dictionary (`[LookupRegistry View]`)
**View:** `src/views/admin/[LookupRegistryView].jsx`

[Describe what the classification dictionary is, how many levels it has, and give example entries for each level. Explain why this dictionary exists — what business constraint does it enforce?]

### Step 2 — Import [Base Entity] (`[Library View]`)
**View:** `src/views/admin/[EntityLibraryView].jsx`

[Describe how the base atomic data (e.g., raw materials, products, SKUs) is ingested. Is it via CSV? Manual entry? What key fields are required? Is there a global context cache?]

### Step 3 — Build [Template Entity] (`[Template Library View]`)
**View:** `src/views/admin/[TemplateLibraryView].jsx`

[Describe what a template entity is — a grouping of base entities. How is it tagged or classified? What rules govern soft deletes or archival?]

**Soft delete rule:** [Describe the soft delete strategy — e.g., `is_active` flag preserves historical integrity].

### Step 4 — Define [Blueprint/Structure Templates] (`[Blueprint View]`)
**View:** `src/views/admin/[BlueprintView].jsx`

[Describe what blueprints are — they define which structural slots are required for a given deliverable type. What are the mandatory slots? Is there a universal "escape hatch" slot (like a VARIANT)?]

---

## Part 3: Project Lifecycle ([Role A] → [Role B] → [Role C] → [Role D])

### Phase 1: [Initiation Phase Name] ([Role])
**View:** `[ViewName]` — `src/views/[folder]/[ViewName].jsx`

[Describe how a project or engagement is created. What is the first record written to the database? What metadata is required?]

### Phase 2: [Population Phase Name] ([Role])
**View:** `[ViewName]`

[Describe how the main units of work (e.g., assemblies, jobs, tasks) are added to the project. Are there multiple creation pathways — manual, bulk import, AI-assisted? Describe each pathway briefly.]

### Phase 3: [Specification / Configuration Phase Name] ([Role])
**View:** `[ViewName]` — `src/views/[folder]/[ViewName].jsx`

[Describe the core daily-use screen. What does the user do here? How do they fill in the structural slots? What is the interaction flow — is there a guided path, a search/select pattern, keyboard navigation?]

### Phase 4: [Review & Approval Phase Name] ([Role])
**View:** `[ViewName]`

[Describe the approval or review step. What status transition happens? Does a lock or freeze activate? Who has permission to approve?]

### Phase 5: [Fulfillment / Execution Phase Name] ([Role])
**View:** `[ViewName]` — `src/views/[folder]/[ViewName].jsx`

[Describe the operational execution phase — e.g., warehouse picking, physical delivery, field installation. What view do they use? What status progression occurs?]

### Phase 6: [Feedback / Completion Phase Name] ([Role])
**View:** `[ViewName]` — `src/views/[folder]/[ViewName].jsx`

[Describe any feedback or reconciliation loop — e.g., field crew logging shortfalls, reporting overages. How does this data flow back into the system?]

### Phase 7: [Reporting Phase Name] (Admin / [Role])
**View:** `[ViewName]` — `src/views/[folder]/[ViewName].jsx`

[Describe the read-only reporting or analytics view. What aggregations or metrics are shown?]

---

## Part 4: Role Reference

| Role | Primary Views | What They Own |
|---|---|---|
| **[Role 1]** | [View names] | [Data they control] |
| **[Role 2]** | [View names] | [Data they control] |
| **[Role 3]** | [View names] | [Data they control] |
| **[Role 4]** | [View names] | [Data they control] |
| **[Role 5]** | [View names] | [Data they control] |

---

## Part 5: Key Architectural Rules

1. **[Rule 1 Name]:** [Describe the invariant — e.g., stamping is irreversible, templates cannot be modified after a unit is created from them].
2. **[Rule 2 Name]:** [Describe the invariant — e.g., a lock activates after approval, preventing field edits].
3. **[Rule 3 Name]:** [Describe the invariant — e.g., no hard deletes on master data; use `is_active` flags].
4. **[Rule 4 Name]:** [Describe the invariant — e.g., manual cascade order on deletion to preserve referential integrity].
5. **[Rule 5 Name]:** [Describe the escape hatch or override mechanism — e.g., VARIANT slot bypasses classification constraints].
6. **[Rule 6 Name]:** [Describe a stacking/compounding rule — e.g., all quantities are the product of three multiplier levels].
