# Agent Entry Point

**Welcome to the Application Workspace.**
This repository is configured with a structured documentation library split into **`docs/wiki/`** (architecture knowledge) and **`docs/`** (operational process tooling), designed to serve as the single source of truth for the codebase, architecture, state management, and user interfaces.

Instead of searching the entire codebase to understand context, read the localized intelligence hub first.

## Mandatory Reading (The Docs Hub)

Everything you need to execute bug fixes or feature requests flawlessly is mapped out in the `docs/wiki/` directory.

### 1. Start Here: `docs/wiki/core/00-system-index.md`
This is the master directory containing the Architecture Flow and system index. It maps out how the codebase, modules, and data stores interact.

### 2. Need to build or edit a UI element?
**Read `docs/wiki/core/06-design-system.md` FIRST.**
- Do not guess CSS classes or component styles. The project uses a strict, predefined theme and design tokens.
- Review global layouts and layout wrappers defined here before implementing screens.

### 3. Need to interact with Application State?
**Read `docs/wiki/core/08-state-context.md` FIRST.**
- Provides the exact shapes of active contexts, store structures, or data models.

### 4. Database Schemas & API Integration
- Raw schema breakdowns, API specs, and endpoints are located in **`docs/wiki/database/`** or **`docs/wiki/api/`**. Always verify keys, types, and constraints before writing queries or integrations.

### 5. Editing an existing Screen or finding an Asset?
- Look up the feature-specific context in **`docs/wiki/features/`** or check the physical layout of the codebase via **`docs/wiki/core/06-directory-structure.md`**. It holds the exact file paths and dependencies.

---

## Task Lookup

| Task | Read first | Then drill into |
|---|---|---|
| Building or editing a UI component | [Components Index](docs/wiki/components/components-index.md) | Specific component doc |
| Building or editing a screen / view | [Features Index](docs/wiki/features/features-index.md) | Specific feature doc |
| Writing a database query / API request | [Database Index](docs/wiki/database/database-index.md) | Specific schema / endpoint doc |
| Editing overall layout or workspace shell | [App Shell Structure](docs/wiki/core/07-app-structure.md) | Core layout component docs |
| Understanding state shapes / context | [State & Context](docs/wiki/core/08-state-context.md) | State management docs |
| Extending a utility or custom helper | [Logic Index](docs/wiki/logic/logic-index.md) | Specific utility / helper doc |
| Checking backlog/roadmap or parked items | [Backlog Index](docs/backlog/backlog-index.md) | Specific backlog plan doc |
| Viewing archived implementation plans | [Plan Archive](docs/archive-plans/README.md) | Specific archived plan |

---

## Core Development Rules
1. **Never Hardcode Components:** Use the global variants inside the component library.
2. **Follow Design Specs:** Adhere strictly to the color palettes, fonts, and UI behaviors detailed in the Design System.
3. **Destructive Actions:** Require confirmation modals/prompts for any user actions that delete or destroy data.
4. **Context Review:** Before writing any code, review the last 3 entries in `docs/logs/agent-changelog.md` to establish current project state.
5. **Planning & Execution:** For multi-step tasks, create/update a plan file under `docs/plans/` using the [Template Plan](docs/plans/template-plan.md).
6. **Mandatory Wrap-Up Protocol:** Whenever a task or feature is complete — including when the user says anything like "wrap up", "we're done", "ship it", "that's it", or closes out a conversation — you **MUST** perform the following steps:

   **Part 1 - Audit Logging:** Document your actions by adding a row to `docs/logs/agent-changelog.md`:
   ```markdown
   ## [YYYY-MM-DD HH:MM] - [Task Name]
   **Agent:** [Application/Agent Name] ([Model Name])
   **Files Modified:**
   - `src/...`
   **Database/API Changes:** None | [describe if any]
   **Summary:** One sentence summary of changes.
   ```

   **Part 2 — Docs sync:** Update any wiki file whose described behavior changed.

   **Part 3 — Archiving Completed Plans:** Move the completed plan file from `docs/plans/[plan-name].md` to `docs/archive-plans/[plan-name].md`.
