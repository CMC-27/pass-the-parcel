# Application Workspace — Agent Entry Point

**Welcome to the Application Workspace.**
This repository is configured with a structured documentation library in **`docs/`** designed to serve as the single source of truth for the codebase, architecture, state management, and user interfaces.

### Documentation Structure
- **`docs/wiki/`** — Architecture knowledge, design system, features, and technical specs
- **`docs/plans/`** — Active implementation plans (parcel format)
- **`docs/archive/`** — Completed plans
- **`docs/backlog/`** — Product roadmap and backlog items
- **`docs/logs/`** — Agent changelog, version history, knowledge changelog

Instead of searching the entire codebase to understand context, **STOP** and read the localized intelligence hub first.

---

## MANDATORY READING

Everything you need is mapped in `docs/wiki/`. Start at **`docs/wiki/core/00-system-index.md`** — it indexes the architecture flow and all feature-to-table mappings. For any specific task, use the lookup table below.

---

## TASK LOOKUP

| Task | Read first | Then drill into |
|------|------------|-----------------|
| Building or editing a UI component | `docs/wiki/components/components-index.md` | Specific component doc |
| Building or editing a screen / view | `docs/wiki/features/features-index.md` | Specific feature doc |
| Writing a database query | `docs/wiki/database/database-index.md` | Specific schema doc |
| Editing overall layout or workspace shell | `docs/wiki/core/07-app-structure.md` | Layout component docs |
| Understanding state shapes / context | `docs/wiki/core/04-state-context.md` | State management docs |
| Parsing or generating a CSV/XLSX import/export | `docs/wiki/logic/logic-index.md` | CSV Parser / xlsx utility |
| Extending a utility or custom hook | `docs/wiki/logic/logic-index.md` | Specific util/hook doc |
| Touching AI / agentic workflows | `docs/wiki/core/15-ai-features.md` | AI client utility |
| Checking backlog/roadmap or parked items | `docs/backlog/backlog-index.md` | Specific backlog plan doc |
| Viewing archived implementation plans | `docs/archive/README.md` | Specific archived plan |
| Adding or editing form fields | `docs/wiki/core/09-design-system.md` §5c | `docs/wiki/core/10-validation-standards.md` |
| Checking wiki health / link integrity | `@wiki-lint` skill | `docs/logs/knowledge-changelog.md` (soft-report) |
| Asking a question about the codebase | `@wiki-query` skill | Cites `[Title](path)` from `docs/wiki/` + `ref/` |
| Recording a knowledge-capture decision | `@knowledge-capture` skill | `docs/wiki/core/18-knowledge-capture.md` |
| Adding to the backlog | `@backlog` skill | `docs/backlog/backlog-index.md` |
| Auditing UI compliance | `@design-audit` skill | `docs/wiki/core/09-design-system.md` |
| Checking cross-view pattern consistency | `docs/wiki/core/18-knowledge-capture.md` (Domain Index) | `ptp-context-hunter` skill §2 + `ptp-grumpy-architect` skill §9 |
| Closing out a task | `@agent-wrap-up` skill | `docs/logs/agent-changelog.md` |
| Multi-step planning | `@pass-the-parcel` skill | Parcel template in skill refs |
| Pre-push validation (lint/test/build/push) | `@test-and-deploy` skill | `docs/logs/version-history.md` |
| Writing or editing code | `@karpathy-guidelines` skill | `docs/wiki/core/09-design-system.md` (if UI) |
| Reviewing agent operations history | `docs/logs/agent-changelog.md` | (distinct from `knowledge-changelog.md`) |

---

## Core Development Rules
1. **Never Hardcode Components:** Use the global variants inside `src/components/ui` (e.g., `<Button variant="primary">`).
2. **Never Hardcode Text Colors:** All text colors must use theme tokens (`text-primary-on` on `bg-primary`, `text-on_surface` for titles, `text-secondary` for labels). No `text-white`, `text-slate-*`, `text-gray-*`, or `text-black` in className strings. See `docs/wiki/core/09-design-system.md` §2, §5.
3. **Respect the Architecture:** Follow the project's data flow and domain constraints as documented in the wiki — do not bypass established patterns.
4. **Destructive Actions:** Use `<ConfirmModal>` for deletions. Ensure linked rows in dependent tables are properly managed.
5. **Context Review:** Before writing any code, review the last 3 entries in `docs/logs/agent-changelog.md` to establish current project state.
6. **Subagent Wiki-First Mandate:** Any agent spawning a subagent (via `task`) MUST explicitly instruct that subagent to follow the wiki-first directive — STOP and read `docs/wiki/` before searching the codebase. Subagents spawned without this instruction will default to raw codebase search and waste context. This applies to all subagents regardless of role (planner, reviewer, surgeon, etc.).
7. **Planning Protocol:** Multi-step tasks MUST use the `@pass-the-parcel` skill.
8. **Form Field Hygiene (id + name + autoComplete + htmlFor):** Every `<input>`, `<select>`, and `<textarea>` MUST have an `id` attribute, and its corresponding `<label>` MUST have `htmlFor` matching that `id`. Auth forms (login/registration) additionally require `name` + `autoComplete` attributes for password manager support. For fields inside `.map()` loops, use globally unique dynamic IDs (e.g., `id={`field-${parentKey}-${index}`}`) — never a bare local index. See `docs/wiki/core/09-design-system.md` §5c for the full standard and common pitfalls.

---

## Wrap-Up Protocol

Use the `@agent-wrap-up` skill when a task is complete.
