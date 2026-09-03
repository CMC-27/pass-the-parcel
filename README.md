# Application Wiki

Welcome to the **Application Wiki** repository. This workspace serves as a standardized, app-agnostic scaffold designed to facilitate seamless agentic development, structured planning, and comprehensive documentation management for any codebase.

---

## Repository Structure

Below is an overview of the core entry points and directories in this workspace:

*   **[`AGENTS.md`](AGENTS.md)**: The mandatory landing page and instructions for AI agents. It maps tasks to documentation files, defines development rules, and outlines the mandatory wrap-up protocol.
*   **[`HOW-TO.md`](HOW-TO.md)**: A guide detailing the agentic development lifecycle, covering setup/bootstrapping, planning methodologies, and pre-deployment validation.
*   **[`DESIGN.md`](DESIGN.md)**: Standard frontend design rules and CSS token references to ensure consistent, premium UI development.
*   **`.opencode/`**: Agent configuration, command definitions, and the canonical PREFIX-LOCKED parcel prefix (`.opencode/plans/base-context.md`).
*   **`.devops/skills/`**: Reusable agent skills (SKILL.md files) for the opencode ecosystem.
*   **`.wiki`**: The application architecture knowledge base — stable, long-lived reference documentation:
    *   `core/`: Core architecture, vision, design systems, and state context.
    *   `features/`: Feature-specific logic, layouts, and components.
    *   `components/`: Catalog of design system component specifications.
    *   `database/`: Schema definitions and data layer documentation.
    *   `logic/`: Utility functions, custom hooks, and complex algorithmic docs.
    *   `conventions/`: Naming conventions for files, components, CSS, JS, database, tests.
    *   `integrations/`: External service and API integration documentation.
    *   `testing/`: Test patterns, mocking, performance budgets, and PR checklist.
*   **`.devops/`**: Operational process tooling — volatile, workflow-driven assets + the transportable machinery layer:
    *   `agents/`: Parcel-* agent runbooks (PREFIX-LOCKED pure body, loaded via `prompt: {file: ...}`).
    *   `plans/`: Active implementation plans and the plan template.
    *   `backlog/`: Project backlog index and individual backlog plan files.
    *   `archive/`: Completed and closed implementation plans.
    *   `logs/`: Development history records, including `agent-changelog.md`, `version-history.md`, and `knowledge-changelog.md`.
*   **`.wiki/rules/`**: Wiki governance layer (structure, naming, numbering, frontmatter, link hygiene) + `wiki_lint.py`.

---

## How to Use This Template

1.  **Configure the Vision**: Edit `.wiki/core/01-vision-north-star.md` to define the application's core goals.
2.  **Define the Structure**: Build out the schemas, routes, and features in `.wiki/` to establish a clear architectural layout before writing code.
3.  **Coordinate with AI Agents**: Direct incoming agents to read `AGENTS.md` first to ensure they adhere to the project's styling tokens, code hygiene rules, and validation pipelines.
4.  **Sync Into Satellites**: The portable machinery (skills, agents, rule layers, scripts) pulls into any other workspace via `scripts/pull-architecture.ps1` after a one-time push bootstrap — see [HOW-TO.md §6](HOW-TO.md#6-syncing-machinery-into-a-satellite-workspace) and the checklist at `.devops/templates/SATELLITE-BOOTSTRAP.md`.
