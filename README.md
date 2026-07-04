# Application Wiki

Welcome to the **Application Wiki** repository. This workspace serves as a standardized, app-agnostic scaffold designed to facilitate seamless agentic development, structured planning, and comprehensive documentation management for any codebase.

---

## Repository Structure

Below is an overview of the core entry points and directories in this workspace:

*   **[`AGENT.md`](AGENT.md)**: The mandatory landing page and instructions for AI agents. It maps tasks to documentation files, defines development rules, and outlines the mandatory wrap-up protocol.
*   **[`HOW-TO.md`](HOW-TO.md)**: A guide detailing the agentic development lifecycle, covering setup/bootstrapping, planning methodologies, and pre-deployment validation.
*   **[`DESIGN.md`](DESIGN.md)**: Standard frontend design rules and CSS token references to ensure consistent, premium UI development.
*   **`/wiki`**: The application architecture knowledge base — stable, long-lived reference documentation:
    *   `core/`: Core architecture, vision, design systems, and state context.
    *   `features/`: Feature-specific logic, layouts, and components.
    *   `components/`: Catalog of design system component specifications.
    *   `database/` & `logic/`: Schema definitions and core utility standards.
*   **`/dev`**: Operational process tooling — volatile, workflow-driven assets:
    *   `backlog/`: Project backlog index and individual backlog plan files.
    *   `plans/`: Active implementation plans and the plan template.
    *   `archive-plans/`: Completed and closed implementation plans.
    *   `logs/`: Development history records, including the [`agent-changelog.md`](dev/logs/agent-changelog.md).

---

## How to Use This Template

1.  **Configure the Vision**: Edit [`wiki/core/01-vision-north-star.md`](wiki/core/01-vision-north-star.md) to define the application's core goals.
2.  **Define the Structure**: Build out the schemas, routes, and features in the `/wiki` directory to establish a clear architectural layout before writing code.
3.  **Coordinate with AI Agents**: Direct incoming agents to read [`AGENT.md`](AGENT.md) first to ensure they adhere to the project's styling tokens, code hygiene rules, and validation pipelines.
