<!--
type: template
version: 5
updated: 2026-09-10

SEED TEMPLATE — copy to <satellite root>/AGENTS.md and customize.
Nothing executes this file; it is authored once per workspace.
Sections marked CUSTOMIZE are repo-specific. Sections marked MACHINERY are part of the
parcel blueprint and should stay verbatim so agents behave identically across workspaces.
-->

# Application Workspace — Agent Entry Point

**Welcome to the `<PROJECT NAME>` workspace.**
This repository is configured with a structured documentation library in **`.wiki/`** designed
to serve as the single source of truth for the codebase, architecture, state management, and
user interfaces.

### Documentation Structure
<!-- MACHINERY: keep verbatim -->
- **`.wiki/`** — Architecture knowledge, design system, features, and technical specs
- **`.devops/plans/`** — **Plans.** Every `*-plan.md`, parked (`BACKLOG`) or in flight (`PHASE_1`+); template at `template-plan.md`
- **`.devops/archive/`** — Completed plans
- **`.devops/backlog/`** — **Backlog.** Master queue `backlog-index.md` + roadmap, triage, refactoring registers
- **`.devops/backlog/SPRINTS.md`** — **Sprints.** Sprint register; per-sprint scope + retro in `.devops/backlog/sprints/sprint-{n}/`
- **`.devops/logs/`** — Agent changelog, version history
- **`.devops/skills/`** — All skills (SKILL.md per folder), loaded via `opencode.json` `skills.paths`
- **`.devops/agents/`** — VS Code custom agents: `parcel.agent.md` + `wiki-writer.agent.md` (selectable), `ptp-*.subagent.md` + `wiki-verifier.subagent.md` (subagents)
- **`.wiki/rules/`** — Wiki governance layer
- **`.devops/rules/`** — Dev governance layer

Instead of searching the entire codebase to understand context, **STOP** and read the localized
intelligence hub first.

---

## MANDATORY READING

Everything you need is mapped in `.wiki/`. Start at **`.wiki/core/00-system-index.md`**.

---

## TASK LOOKUP

<!-- CUSTOMIZE: replace every row with your app's real doc paths. Delete rows that do not
     apply (e.g. no DB, no CSV imports). Keep the skill-routing rows — they are machinery. -->

| Task | Read first | Then drill into |
|------|------------|-----------------|
| Building or editing a UI component | `<your components index>` | Specific component doc |
| Building or editing a screen / view | `<your features index>` | Specific feature doc |
| Writing a database query | `<your database index>` | Specific schema doc |
| Asking a question about the codebase | `@wiki-query` skill | Cites `[Title](path)` from `.wiki/` |
| Adding to the backlog | `@backlog` skill | `.devops/backlog/backlog-index.md` |
| Planning a sprint / starting a dev cycle | `@sprint-plan` skill | `.devops/backlog/SPRINTS.md` |
| Checking sprint progress / "where are we" | `@sprint-status` skill | Active `sprints/sprint-{n}/plan.md` |
| Closing a sprint / retrospective | `@sprint-close` skill | `sprints/sprint-{n}/retro.md` + REFACTORING.md scan |
| Multi-step planning | `@pass-the-parcel` skill | Template at `.devops/plans/template-plan.md` |
| Pre-push validation | `@test-and-deploy` skill | `.devops/logs/version-history.md` |
| Syncing machinery / pulling template updates | `@sync-architecture` skill | `.devops/templates/SATELLITE-BOOTSTRAP.md` |
| Closing out a task | `@agent-wrap-up` skill | `.devops/logs/agent-changelog.md` |

---

## Core Development Rules

1. <!-- CUSTOMIZE rules 1–4: your app-specific coding constraints (component variants, theme
       tokens, data-flow boundaries, destructive-action modals). -->
2.
3.
4.
5. **Context Review:** Before writing any code, review the last 3 entries in
   `.devops/logs/agent-changelog.md`. <!-- MACHINERY -->
6. **Subagent Wiki-First Mandate:** Any agent spawning a subagent MUST instruct it to read
   `.wiki/` before searching the codebase. <!-- MACHINERY -->
7. **Planning Protocol:** Multi-step tasks MUST use the `@pass-the-parcel` skill. <!-- MACHINERY -->
8. **Sprint Discipline (Agile Cycle):** Development runs in time-boxed sprints tracked in `.devops/backlog/SPRINTS.md`. Feature work is triaged in `backlog-index.md`, committed into a sprint via `@sprint-plan`, executed parcel-by-parcel via `@pass-the-parcel`, and closed via `@sprint-close` (retro + spaghetti scan). One active sprint at a time; do NOT pull ad-hoc items mid-sprint. Code-quality/refactoring lives OUTSIDE the roadmap in `REFACTORING.md`, triggered by the sprint-close scan, not the backlog. See `.devops/backlog/TRIAGE.md`. <!-- MACHINERY: optional — delete if you don't adopt the sprint cycle -->
9. <!-- CUSTOMIZE if your app has form-field/validation standards; otherwise delete. -->

---

## Governance Layers

<!-- MACHINERY: keep verbatim -->
- [`.wiki/rules/`](.wiki/rules/README.md) — how the wiki is structured, named, linked
- [`.devops/rules/`](.devops/rules/README.md) — how agents, skills, plans and operational state are governed
- [`.devops/`](.devops/README.md) — operational state + the transportable machinery layer

---

## Wrap-Up Protocol

Use the `@agent-wrap-up` skill when a task is complete. When the last committed plan of an active sprint finishes, follow with `@sprint-close`.
