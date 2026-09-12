---
title: "🗺️ @docs Architecture Blueprint"
type: "core"
name: "Documentation Architecture Blueprint"
status: "stable"
format-version: 1
dependencies: []
db_relations: []
description: "The universal blueprint for the @docs library architecture, establishing patterns for folder structures, naming conventions, and cross-linking strategies."
claims:
  - id: required-frontmatter-fields
    source: scripts/wiki_lint.py#REQUIRED_FIELDS
    hash: sha256:5381104562ff9e29c6314174491f28362210b52e5822ff793e67854312091287
  - id: visualizer-generates-docs
    source: scripts/wiki_visualize.py#main
    hash: sha256:57d2fa4d6991275cc809f5c3433f4d6032f29aafb043894eeee8c32a4d669d03
  - id: claims-drift-gate
    source: scripts/wiki_claims.py#cmd_check
    hash: sha256:bc7edd793b71fcfa3744730b9083eaab09d58f4ab4c3d4a3ac476cf0c5b21750
  - id: hub-spoke-enforced
    source: scripts/wiki_lint.py#category_indexes
    hash: sha256:5381104562ff9e29c6314174491f28362210b52e5822ff793e67854312091287
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

Three roots: **`.wiki/`** holds architecture knowledge, **`.devops/`** holds operational state, and **`docs/`** holds generated exports.

```
.wiki/          <- Architecture Knowledge Base
.devops/        <- Operational state (backlog / plans / archive / logs)
docs/           <- Generated visualizer export (not authored)
```

### .wiki/ - Architecture Knowledge Base

| Directory | Role | Index File | Description |
|---|---|---|---|
| `.wiki/core` | The Brain | `00-system-index.md` | Master index, design systems, state context, architecture. |
| `.wiki/features` | The Nervous System | `features-index.md` | Screen-specific docs, feature workflows, view logic. |
| `.wiki/components` | The Muscle | `components-index.md` | Reusable UI atoms, molecules, and organisms. |
| `.wiki/database` | The Skeleton | `database-index.md` | Schema breakdowns, table relationships. |
| `.wiki/logic` | The Internal Organs | `logic-index.md` | Utility functions, custom hooks, algorithmic explanations. |
| `.wiki/conventions` | The Rules | `conventions-index.md` | Naming conventions for all code artifacts. |
| `.wiki/integrations` | The Connections | `integrations-index.md` | External service and API integrations. |
| `.wiki/testing` | The Test Lab | `testing-index.md` | Test patterns, mocking, performance budgets. |

### .devops/ - Operational Process Tooling

| Directory | Role | Index File | Description |
|---|---|---|---|
| `.devops/logs` | The Memory | `agent-changelog.md` | Chronological agent actions, audits, hygiene. |
| `.devops/backlog` | The Queue | `backlog-index.md` | Triage Panel + Themes table, theme registers `t{n}-<slug>-backlog.md`, parked `<code>-<slug>-backlog.md` plans. |
| `.devops/sprints` | The Rhythm | `sprint-{n}-<slug>/sprint.md` | Active sprint records + committed plan queues. |
| `.devops/plans` | The Future | (User Managed) | Claimed implementation plans. |
| `.devops/archive` | The Archive | (User Managed) | Completed plans at root + closed sprint records under `sprints/`. |

### docs/ - Generated Visualizer Export

`docs/` is **generated**, never authored. `scripts/wiki_visualize.py` writes `docs/wiki-graph.md` — a mermaid hub-and-spoke graph plus a linked catalog. Regenerate with `python scripts/wiki_visualize.py`.

---

## 3. Naming Conventions (The Prefix Pattern)

| Directory | Prefix Pattern | Examples |
|---|---|---|
| `.wiki/core/` | `0x-name.md` (numbered) | `00-system-index.md`, `01-vision-north-star.md` |
| `.wiki/features/` | `feat-feature-name.md` | `feat-order-dashboard.md` |
| `.wiki/components/` | `ui-component-name.md` | `ui-button.md` |
| `.wiki/database/` | `db-table-name.md` | `db-projects.md` |
| `.wiki/logic/` | `util-name.md` or `hook-name.md` | `util-csv-parser.md`, `hook-use-auth.md` |
| `.wiki/conventions/` | `conv-category-name.md` | `conv-file-naming.md` |
| `.wiki/testing/` | `topic.md` | `pattern.md`, `mocking.md` |
| `.devops/logs/` | `agent-changelog.md` | (single file, append-only) |
| `.devops/backlog/` | `backlog-index.md`, `t{n}-<slug>-backlog.md`, or `<code>-<slug>-backlog.md` | `backlog-index.md`, `t1-parcel-pipeline-machinery-backlog.md` |
| `.devops/sprints/` | `sprint-{n}-<slug>/sprint.md` | `sprint-1-import-hardening/sprint.md` |
| `.devops/plans/` | `<code>-<slug>-plan.md` | `T1-E1.04-dashboard-plan.md` |
| `.devops/archive/` | `<code>-<slug>-plan.md` or `sprints/sprint-{n}-<slug>/sprint.md` | (moved when complete/closed) |

---

## 4. Standard Document Anatomy

Every `.md` file in the library opens with the same three front-loaded sections, then unlimited detail. The opening pattern and the frontmatter schema are canonical in [document-structure.md](../rules/document-structure.md) and [frontmatter.md](../rules/frontmatter.md) — reference them, never restate them in a document. A doc whose prose makes a material factual claim may also carry a `claims:` block binding the claim to its source (see [claims.md](../rules/claims.md)).

### A. Technical Context (The "What")
- **Physical Path:** Explicit path to the code (`src/views/...`).
- **Data Shape:** JSON or TypeScript definitions of relevant state.
- **Mermaid Diagrams:** Use flowcharts or sequence diagrams to visualize logic.

### B. Relationships (The "How it Connects")
Links to related database tables, parent indices, or sibling features.

---

## 5. The "Hub & Spoke" Linking Strategy

- **The Hub:** `.wiki/core/00-system-index.md` acts as the master router. It links to all **Category Indices**.
- **The Spokes:** Each category has its own `*-index.md` that lists its children.
- **Operational Cross-Links:** The hub also links to `.devops/backlog/`, `.devops/plans/`, `.devops/archive/`, and `.devops/logs/`.
- **Cross-Links:** Individual docs link directly to their database schemas or utility dependencies using relative paths.

---

## 6. The Lifecycle of Documentation

1. **Planning:** A `<slug>-plan.md` is created in `.devops/plans/`.
2. **Execution:** The agent performs the work and logs it in `.devops/logs/agent-changelog.md`.
3. **Generate:** `@wiki-generate` drafts index rows and doc skeletons from the codebase; `@wiki-bootstrap` verifies them question-by-question.
4. **Sync:** `@wiki-update` maps `git diff` since the last verified sha to the docs it invalidated, revises only those, and stamps `last-reviewed`.
5. **Drift:** `scripts/wiki_claims.py check` fails the build when a doc's grounded claim points at source that changed.
6. **Archiving:** Completed plans are moved from `.devops/plans/` to `.devops/archive/`. Deprecated features are marked with `status: "deprecated"` in frontmatter.

---

## 7. Foundation Documents Checklist

### Core Brain Documents (`.wiki/core/`)

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

### Test Lab Documents (`.wiki/testing/`)

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
