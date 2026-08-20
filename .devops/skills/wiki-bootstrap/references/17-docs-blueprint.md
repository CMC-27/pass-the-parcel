---
type: "core"
name: "Wiki Architecture Blueprint"
status: "stable"
dependencies: []
db_relations: []
description: "The universal blueprint for the @docs library architecture, establishing patterns for folder structures, naming conventions, and cross-linking strategies."
---

# ??? Wiki Architecture Blueprint

This document defines the **Documentation Standard** for the [APP_NAME] application. It is designed to turn a codebase from a "black box" into a transparent, agent-ready intelligence hub.

## 1. The Core Philosophy: "Agent-First Knowledge"
The documentation is not just for humans; it is the **source of truth** for AI Agents.
- **Predictability:** Every piece of logic has a dedicated home.
- **Traceability:** Code and documentation are linked via standardized paths.
- **Context over Code:** Docs explain *why* and *how* something connects, rather than just repeating the code.

---

## 2. Folder Taxonomy (The Library Structure)

The library is organized into **two top-level libraries** based on functional purpose:

### ?? wiki/ � Architecture Knowledge Base

| Directory | Role | Parent/Index File | Description |
| :--- | :--- | :--- | :--- |
| `wiki/core` | **The Brain** | `00-system-index.md` | Master index, design systems, state context, and global architecture. |
| `wiki/features` | **The Nervous System** | `features-index.md` | Screen-specific documentation, feature workflows, and view-logic. |
| `wiki/components` | **The Muscle** | `components-index.md` | Documentation for reusable UI atoms, molecules, and organisms. |
| `wiki/database` | **The Skeleton** | `database-index.md` | Schema breakdowns, table relationships, and data-layer logic. |
| `wiki/logic` | **The Internal Organs**| `logic-index.md` | Utility functions, custom hooks, and complex algorithmic explanations. |

### ?? docs/ � Operational Process Tooling

| Directory | Role | Index File | Description |
| :--- | :--- | :--- | :--- |
| `.devops/logs` | **The Memory** | `agent-changelog.md` | Chronological records of agent actions, audits, and hygiene checks. |
| `.devops/backlog` | **The Queue** | `backlog-index.md` | Project backlog index and individual backlog plan files. |
| `.devops/plans` | **The Vision** | *(User Managed)* | Implementation plans, architectural RFCs, and feature roadmaps. |
| `.devops/archive` | **The Archive** | `README.md` | Completed and closed implementation plans. |
| `docs/prompts` | **The Voice** | *(User Managed)* | Standardized LLM prompts and persona definitions for consistency. |

---

## 3. Naming Conventions (The Prefix Pattern)

To ensure high-speed lookup and clarity, files within subdirectories must follow specific prefix patterns:

- **Core:** `0x-name.md` (Numbered sequence for onboarding flow).
- **Features:** `feat-feature-name.md` (e.g., `feat-assembly-builder.md`).
- **Components:** `ui-component-name.md` (e.g., `ui-modal.md`).
- **Database:** `db-table-name.md` (e.g., `db-projects.md`).
- **Logic:** `util-logic-name.md` or `hook-name.md`.
- **Plans:** `.devops/plans/name-plan.md`.
- **Backlog:** `.devops/backlog/<feature-slug>-backlog.md`.

---

## 4. Standard Document Anatomy

Every `.md` file in the library should adhere to this structure:

### A. YAML Frontmatter
```yaml
---
type: "feature" | "component" | "database" | "logic" | "core"
name: "Human Readable Name"
status: "stable" | "in-progress" | "deprecated"
dependencies: ["feat-auth", "db-projects"]
db_relations: ["projects", "assemblies"]
description: "Brief summary of the document purpose."
---
```

### B. Header & Summary
A clear H1 followed by a 2-3 sentence overview of the subject.

### C. Technical Context (The "What")
- **Physical Path:** Explicit path to the code (`src/views/...`).
- **Data Shape:** JSON or TypeScript definitions of relevant state.
- **Mermaid Diagrams:** Use flowcharts or sequence diagrams to visualize logic.

### D. Relationships (The "How it Connects")
Links to related database tables, parent indices, or sibling features.

---

## 5. The "Hub & Spoke" Linking Strategy

- **The Hub:** `wiki/core/00-system-index.md` acts as the master router. It links to all **Category Indices** in the Wiki, and also cross-links to DevOps operational directories.
- **The Spokes:** Each Wiki category (`wiki/features/`, `wiki/database/`, `wiki/logic/`, `wiki/components/`) has its own `*-index.md` that lists its children.
- **DevOps Cross-Links:** The hub also links out to `.devops/backlog/`, `.devops/plans/`, `.devops/logs/`, and `.devops/archive/`.
- **Cross-Links:** Individual docs link directly to their database schemas or utility dependencies.

---

## 6. The Lifecycle of Documentation

1. **Planning:** A plan file is created in `.devops/plans/`.
2. **Execution:** The agent performs the work and logs it in `.devops/logs/agent-changelog.md`.
3. **Sync:** As code is committed, the corresponding wiki docs are updated to reflect the new truth.
4. **Archiving:** Deprecated features move to a `deprecated/` subfolder or are marked in frontmatter. Completed plans move from `.devops/plans/` to `.devops/archive/`.

---

## 7. Foundation Documents Checklist

Use this checklist to establish the core knowledge infrastructure. All 19 slots are defined below in their canonical numbered order.

### ?? Wiki Core Brain Documents (`wiki/core/`)

| Slot | Filename | Name | Status |
|:---|:---|:---|:---|
| 00 | `00-system-index.md` | System Index (The Hub) | Required |
| 01 | `01-vision-north-star.md` | Vision & North Star | Required |
| 02 | `02-product-context.md` | Product Context | Required |
| 03 | `08-user-journey.md` | User Journey | Required |
| 04 | `05-core-architecture.md` | Core Architecture | Required |
| 05 | `09-design-system.md` | Design System | Required |
| 06 | `06-directory-structure.md` | Directory Structure | Required |
| 07 | `07-app-structure.md` | App Shell Structure | Required |
| 08 | `04-state-context.md` | State & Context | Required |
| 09 | `15-ai-features.md` | AI Features & Pipelines | If applicable |
| 10 | `16-external-integrations.md` | External Integrations | If applicable |
| 11 | `10-validation-standards.md` | Validation Standards | Required |
| 12 | `11-utility-standards.md` | Utility Standards | Required |
| 13 | `12-security-standards.md` | Security Standards | Required |
| 14 | `13-performance-standards.md` | Performance Standards | Required |
| 15 | `15-theme-linguistics.md` | Theme & Linguistics | If applicable |
| 16 | `03-glossary-of-terms.md` | Glossary of Terms | Required |
| 17 | `17-docs-blueprint.md` | Docs Blueprint (This File) | Required |
| 18 | `18-knowledge-capture.md` | Knowledge Capture | Required |

---

> [!IMPORTANT]
> **The Golden Rule:** If a feature's behavior changes in code, the documentation MUST be updated in the same PR/Conversation. Outdated documentation is technical debt.
