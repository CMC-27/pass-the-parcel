# Application Workspace — Agent Entry Point

**Welcome to the Application Workspace.**
This repository is configured with a structured documentation library in **`docs/`** designed to serve as the single source of truth for the codebase, architecture, state management, and user interfaces.

### Documentation Structure
- **`.wiki/`** — Architecture knowledge, design system, features, and technical specs
- **`.devops/plans/`** — Active implementation plans (parcel format)
- **`.devops/archive/`** — Completed plans
- **`.devops/backlog/`** — Product roadmap and backlog items
- **`.devops/logs/`** — Agent changelog, version history, knowledge changelog
- **`.devops/skills/`** — All skills (SKILL.md per folder), loaded via `opencode.json` `skills.paths`
- **`.devops/agents/`** — VS Code custom agents: `parcel.agent.md` + `wiki-writer.agent.md` (selectable), `ptp-*.subagent.md` + `wiki-verifier.subagent.md` (subagents)
- **`.wiki/rules/`** — Wiki governance layer — numbering, naming, frontmatter, doc-structure, link-hygiene, structure manifest + deterministic linter
- **`.wiki/rules/language/`** — Language governance layer — voice & tone, AI rules, publication rules
- **`.devops/rules/`** — Dev governance layer — agents & skills, plan lifecycle

Instead of searching the entire codebase to understand context, **STOP** and read the localized intelligence hub first.

---

## Design & Scope Notes

> [!NOTE]
> **This repo is the template, not an app.** The task-lookup rows that reference `src/components/ui`, screens, database queries, and CSV parsing are **satellite-facing examples** — they apply in workspaces that contain an application source tree. In this template they document the pattern satellites follow; there is no frontend or database here to edit.
>
> **Design lives in the wiki.** There is no separate `DESIGN.md` — `.wiki/core/09-design-system.md` is the single source of truth for visual design: creative North Star, core token table (`--color-surface`, `--color-primary`, …), typography, elevation, and component specs. Read it before creating or modifying any UI element, dashboard, or component.

---

## MANDATORY READING

Everything you need is mapped in `.wiki/`. Start at **`.wiki/core/00-system-index.md`** — it indexes the architecture flow and all feature-to-table mappings. For any specific task, use the lookup table below.

---

## TASK LOOKUP

| Task | Read first | Then drill into |
|------|------------|-----------------|
| Building or editing a UI component | `.wiki/components/components-index.md` | Specific component doc |
| Building or editing a screen / view | `.wiki/features/features-index.md` | Specific feature doc |
| Writing a database query | `.wiki/database/database-index.md` | Specific schema doc |
| Editing overall layout or workspace shell | `.wiki/core/07-app-structure.md` | Layout component docs |
| Understanding state shapes / context | `.wiki/core/04-state-context.md` | State management docs |
| Parsing or generating a CSV/XLSX import/export | `.wiki/logic/logic-index.md` | CSV Parser / xlsx utility |
| Extending a utility or custom hook | `.wiki/logic/logic-index.md` | Specific util/hook doc |
| Touching AI / agentic workflows | `.wiki/core/15-ai-features.md` | AI client utility |
| Checking backlog/roadmap or parked items | `.devops/backlog/backlog-index.md` | Specific backlog plan doc |
| Viewing archived implementation plans | `.devops/archive/README.md` | Specific archived plan |
| Viewing audit results (T/F, Q&A, UI inventories) | `.devops/audits/README.md` | Originating skill doc |
| Adding or editing form fields | `.wiki/core/09-design-system.md` §5c | `.wiki/core/10-validation-standards.md` |
| Checking wiki health / link integrity | `@wiki-lint` skill | `.devops/logs/knowledge-changelog.md` (soft-report) |
| Asking a question about the codebase | `@wiki-query` skill | Cites `[Title](path)` from `.wiki/` + `ref/` |
| Recording a knowledge-capture decision | `@knowledge-capture` skill | `.wiki/core/18-knowledge-capture.md` |
| Adding to the backlog | `@backlog` skill | `.devops/backlog/backlog-index.md` |
| Auditing UI compliance | `@design-audit` skill | `.wiki/core/09-design-system.md` |
| Checking cross-view pattern consistency | `.wiki/core/18-knowledge-capture.md` (Domain Index) | `ptp-context-hunter` skill §2 + `ptp-grumpy-architect` skill §11 |
| Closing out a task | `@agent-wrap-up` skill | `.devops/logs/agent-changelog.md` |
| Multi-step planning | `@pass-the-parcel` skill | Parcel template at `.devops/plans/template-plan.md` |
| Pre-push validation (lint/test/build/push) | `@test-and-deploy` skill | `.devops/logs/version-history.md` |
| Syncing machinery / pulling template updates | `@sync-architecture` skill | `.devops/README.md` (Transportability) + HOW-TO.md §6 |
| Writing or editing code | `@karpathy-guidelines` skill | `.wiki/core/09-design-system.md` (if UI) |
| Reviewing agent operations history | `.devops/logs/agent-changelog.md` | (distinct from `knowledge-changelog.md`) |

---

## Core Development Rules
1. **Never Hardcode Components:** Use the global variants inside `src/components/ui` (e.g., `<Button variant="primary">`).
2. **Never Hardcode Text Colors:** All text colors must use theme tokens (`text-primary-on` on `bg-primary`, `text-on_surface` for titles, `text-secondary` for labels). No `text-white`, `text-slate-*`, `text-gray-*`, or `text-black` in className strings. See `.wiki/core/09-design-system.md` §2, §5.
3. **Respect the Architecture:** Follow the project's data flow and domain constraints as documented in the wiki — do not bypass established patterns.
4. **Destructive Actions:** Use `<ConfirmModal>` for deletions. Ensure linked rows in dependent tables are properly managed.
5. **Context Review:** Before writing any code, review the last 3 entries in `.devops/logs/agent-changelog.md` to establish current project state.
6. **Subagent Wiki-First Mandate:** Any agent spawning a subagent (via `task`) MUST explicitly instruct that subagent to follow the wiki-first directive — STOP and read `.wiki/` before searching the codebase. Subagents spawned without this instruction will default to raw codebase search and waste context. This applies to all subagents regardless of role (planner, reviewer, surgeon, etc.).
7. **Planning Protocol:** Multi-step tasks MUST use the `@pass-the-parcel` skill.
8. **Form Field Hygiene (id + name + autoComplete + htmlFor):** Every `<input>`, `<select>`, and `<textarea>` MUST have an `id` attribute, and its corresponding `<label>` MUST have `htmlFor` matching that `id`. Auth forms (login/registration) additionally require `name` + `autoComplete` attributes for password manager support. For fields inside `.map()` loops, use globally unique dynamic IDs (e.g., `id={`field-${parentKey}-${index}`}`) — never a bare local index. See `.wiki/core/09-design-system.md` §5c for the full standard and common pitfalls.
9. **PREFIX-LOCKED Integrity:** `.opencode/plans/base-context.md` is the canonical shared prefix for all parcel/ptp agents. NEVER edit the inline prefix inside `.devops/agents/parcel.agent.md` or `.devops/agents/ptp-*.subagent.md` directly — edit `base-context.md`, then run `scripts\check-parcel-prefix.ps1 -Sync` to re-inline it byte-for-byte into every agent. Run `scripts\check-parcel-prefix.ps1` (and `scripts\check-utf8-agents.ps1`) before any push to verify no drift or encoding corruption. See `.opencode/plans/base-context.md`.

---

## Governance Layers

- [`.wiki/rules/`](.wiki/rules/README.md) — how the wiki is structured, named, linked (`python scripts/wiki_lint.py` enforces it deterministically)
- [`.wiki/rules/language/`](.wiki/rules/language/README.md) — how we write — voice, tone, evidence, audience
- [`.devops/rules/`](.devops/rules/README.md) — how agents, skills, plans and operational state are governed
- [`.devops/`](.devops/README.md) — operational state + the transportable machinery layer (skills, agents, plans, logs)

---

## Wrap-Up Protocol

Use the `@agent-wrap-up` skill when a task is complete.
