---
type: "core"
name: "Documentation Architecture Blueprint"
status: "stable"
dependencies: []
db_relations: []
description: "The universal blueprint for the @docs library architecture, establishing patterns for folder structures, naming conventions, and cross-linking strategies."
---

# Documentation Architecture Blueprint

This document defines the **Documentation Standard** for the application. It is designed to turn a codebase from a "black box" into a transparent, agent-ready intelligence hub.

## 1. The Core Philosophy: "Agent-First Knowledge"
The documentation is not just for humans; it is the **source of truth** for AI Agents.
- **Predictability:** Every piece of logic has a dedicated home.
- **Traceability:** Code and documentation are linked via standardized paths.
- **Context over Code:** Docs explain *why* and *how* something connects, rather than just repeating the code.

---

## 2. Folder Taxonomy (The Library Structure)

All documentation lives under a **`docs/`** root:

```
docs/
+-- wiki/       <- Architecture Knowledge Base
+-- backlog/    <- Product backlog
+-- plans/      <- Active implementation plans
+-- archive/    <- Completed plans
+-- logs/       <- Development history
```

### docs/wiki/ - Architecture Knowledge Base

| Directory | Role | Index File | Description |
|---|---|---|---|
| `docs/wiki/core` | The Brain | `00-system-index.md` | Master index, design systems, state context, architecture. |
| `docs/wiki/features` | The Nervous System | `features-index.md` | Screen-specific docs, feature workflows, view logic. |
| `docs/wiki/components` | The Muscle | `components-index.md` | Reusable UI atoms, molecules, and organisms. |
| `docs/wiki/database` | The Skeleton | `database-index.md` | Schema breakdowns, table relationships. |
| `docs/wiki/logic` | The Internal Organs | `logic-index.md` | Utility functions, custom hooks, algorithmic explanations. |
| `docs/wiki/conventions` | The Rules | `conventions-index.md` | Naming conventions for all code artifacts. |
| `docs/wiki/integrations` | The Connections | `integrations-index.md` | External service and API integrations. |
| `docs/wiki/testing` | The Test Lab | `testing-index.md` | Test patterns, mocking, performance budgets. |

### docs/ - Operational Process Tooling

| Directory | Role | Index File | Description |
|---|---|---|---|
| `docs/logs` | The Memory | `agent-changelog.md` | Chronological agent actions, audits, hygiene. |
| `docs/backlog` | The Queue | `backlog-index.md` | Backlog index and individual plan files. |
| `docs/plans` | The Future | (User Managed) | Active implementation plans. |
| `docs/archive` | The Archive | (User Managed) | Completed plans moved from `plans/`. |

---

## 3. Naming Conventions (The Prefix Pattern)

| Directory | Prefix Pattern | Examples |
|---|---|---|
| `docs/wiki/core/` | `0x-name.md` (numbered) | `00-system-index.md`, `01-vision-north-star.md` |
| `docs/wiki/features/` | `feat-feature-name.md` | `feat-assembly-builder.md` |
| `docs/wiki/components/` | `ui-component-name.md` | `ui-button.md` |
| `docs/wiki/database/` | `db-table-name.md` | `db-projects.md` |
| `docs/wiki/logic/` | `util-name.md` or `hook-name.md` | `util-csv-parser.md`, `hook-use-auth.md` |
| `docs/wiki/conventions/` | `conv-category-name.md` | `conv-file-naming.md` |
| `docs/wiki/testing/` | `topic.md` | `pattern.md`, `mocking.md` |
| `docs/logs/` | `agent-changelog.md` | (single file, append-only) |
| `docs/backlog/` | `backlog-index.md` or `<slug>-backlog.md` | `backlog-index.md` |
| `docs/plans/` | `<slug>-plan.md` | `feat-dashboard-plan.md` |
| `docs/archive/` | `<slug>-plan.md` | (moved from docs/plans/ when complete) |

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

- **The Hub:** `docs/wiki/core/00-system-index.md` acts as the master router. It links to all **Category Indices**.
- **The Spokes:** Each category has its own `*-index.md` that lists its children.
- **Operational Cross-Links:** The hub also links to `docs/backlog/`, `docs/plans/`, `docs/archive/`, and `docs/logs/`.
- **Cross-Links:** Individual docs link directly to their database schemas or utility dependencies using relative paths.

---

## 6. The Lifecycle of Documentation

1. **Planning:** A `<slug>-plan.md` is created in `docs/plans/`.
2. **Execution:** The agent performs the work and logs it in `docs/logs/agent-changelog.md`.
3. **Sync:** As code is committed, corresponding wiki docs are updated to reflect the new truth.
4. **Archiving:** Completed plans are moved from `docs/plans/` to `docs/archive/`. Deprecated features are marked with `status: "deprecated"` in frontmatter.

---

## 7. Foundation Documents Checklist

### Core Brain Documents (`docs/wiki/core/`)

| Slot | Doc | Theme | Status |
|---|---|---|---|
| 00 | System Index | Hub | Required |
| 01 | Vision & North Star | Strategy | Required |
| 02 | Product Context | Strategy | Required |
| 03 | Glossary of Terms | Strategy | Required |
| 04 | State & Context | Architecture | Required |
| 05 | Core Architecture | Architecture | Required |
| 06 | Directory Structure | Architecture | Required |
| 07 | App Structure | Architecture | Required |
| 08 | User Journey | Workflow | Required |
| 09 | Design System | Design | Required |
| 10 | Validation Standards | Standards | Required |
| 11 | Utility Standards | Standards | Required |
| 12 | Security Standards | Standards | Required |
| 13 | Performance Standards | Standards | Required |
| 14 | Testing Standards | Standards | Required |
| 15 | AI Features | Features | If applicable |
| 16 | External Integrations | Features | If applicable |
| 17 | Docs Blueprint | Meta | Required |
| 18 | Knowledge Capture | Meta | Required |

### Test Lab Documents (`docs/wiki/testing/`)

- `testing-index.md` - Hub for testing docs
- `pattern.md` - Test taxonomy, naming, what-to-test
- `mocking.md` - Shared mock conventions
- `performance.md` - Test performance budgets
- `checklist.md` - PR review checklist

### Subfolder Parent Indices

- `features-index.md` - Group features by business module
- `components-index.md` - List physical path for every reusable component
- `database-index.md` - Include "When to Read Which Doc" table
- `logic-index.md` - Summarize the "truth" held by each utility
- `conventions-index.md` - Catalog naming conventions
- `testing-index.md` - Gateway to testing standards

---

## See Also
- [00-system-index.md](./00-system-index.md) - Master system index
- [18-knowledge-capture.md](./18-knowledge-capture.md) - Knowledge capture and decisions
