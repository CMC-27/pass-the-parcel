---
type: "core"
name: "System Index"
status: "stable"
dependencies: []
db_relations: []
description: "Master entry point and developer onboarding hub for [APP_NAME]."
---

# System Index: [APP_NAME] Developer Onboarding Hub

This document is the master gateway into the documentation library. Start here to understand product philosophy, structural patterns, and data infrastructure.

---

## 1. Product & Principles
- [Vision & North Star](./01-vision-north-star.md)
- [Product Context & Strategy](./02-product-context.md)
- [Glossary of Terms](./03-glossary-of-terms.md)
- [UI/UX Design System](./09-design-system.md)
- [Knowledge Capture & Decisions](./18-knowledge-capture.md)
- [Agent Changelog](../../logs/agent-changelog.md)

## 2. Core Architecture & Logic
- [User Journey & Data Hierarchy](./08-user-journey.md)
- [Physical Directory Structure](./06-directory-structure.md)
- [App Shell Structure](./07-app-structure.md)
- [Core Architecture Concepts](./05-core-architecture.md)
- [State & Context Data Shapes](./04-state-context.md)
- [AI Features & Workflows](./15-ai-features.md)
- [External Integrations](./16-external-integrations.md)
- [Validation Standards](./10-validation-standards.md)
- [Utility Standards](./11-utility-standards.md)
- [Security Standards](./12-security-standards.md)
- [Performance Standards](./13-performance-standards.md)
- [Theme & Linguistics](./15-theme-linguistics.md)

## 3. Component & View Code

**Codebase Navigation**
- [Physical Directory Structure](./06-directory-structure.md)

**Component Systems** → [Components Index](../components/components-index.md)
<!-- List key reusable UI components here -->

**Views & Routing** → [Features Index](../features/features-index.md)
<!-- List primary screens/routes here -->

## 4. Visual Architecture Flow

Add a Mermaid diagram here showing how UI routes map to data layer tables/APIs:

```mermaid
flowchart TD
    subgraph UI [Screen / View Layer]
        V1[HomeView]
        V2[FeatureView]
    end

    subgraph Core [Global Components & Context]
        Auth[AuthContext]
        State[GlobalState]
    end

    subgraph DB [Data Layer]
        T1[primary_table]
        T2[secondary_table]
    end

    V1 --> Auth
    V2 --> State
    State --> T1
    State --> T2
```

## 5. Core Logic & Utilities
→ [Logic & Utilities Index](../logic/logic-index.md)

**Utility Functions**
<!-- List key utility files here, e.g.: -->
<!-- - [CSV Parser](../logic/util-csv-parser.md) → `src/utils/csvParser.js` -->

**Custom Hooks**
<!-- List key hooks here, e.g.: -->
<!-- - [useDataFetch](../logic/hook-data-fetch.md) → `src/hooks/useDataFetch.js` -->

## 6. Database Schema Signatures
<!-- List each data table/collection doc here, e.g.: -->
<!-- - [Users Schema](../database/db-users.md) -->
<!-- - [Projects Schema](../database/db-projects.md) -->

## 7. Strategic & Operational Docs
- [Backlog Index](../../backlog/backlog-index.md)
- [Active Plans](../../plans/)
- [Wiki Architecture Blueprint](./17-docs-blueprint.md)
