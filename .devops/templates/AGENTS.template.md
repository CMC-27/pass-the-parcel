<!--
type: template
version: 16
updated: 2026-09-18

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
- **`.devops/plans/`** — **Plans.** Claimed / in-flight `*-plan.md` only (`PHASE_1`+); template at `template-plan.md`
- **`.devops/sprints/`** — **Sprints (optional).** Active `sprint-{n}-<slug>/sprint.md` + the committed plan queue; seeds ship in `.devops/templates/`; a satellite adopts the cycle by running `@sprint-plan`
- **`.devops/archive/`** — Completed plans (`*-plan.md` at root) + closed sprint records (`sprints/sprint-{n}-<slug>/sprint.md`)
- **`.devops/backlog/`** — **Backlog.** Master queue `backlog-index.md` (Themes table + Triage Panel), theme registers `t{n}-<slug>-backlog.md`, and parked `<code>-<slug>-backlog.md` plans (`claim_status: QUEUED`). Commit via `@sprint-plan`; claim into `.devops/plans/`
- **`.devops/backlog/SPRINTS.md`** — Sprint register (index of every sprint); created from `SPRINTS.template.md` when the cycle is adopted
- **`.devops/logs/`** — Agent changelog, version history
- **`.devops/skills/`** — All skills (SKILL.md per folder), loaded via `opencode.json` `skills.paths`
- **`.devops/agents/`** — VS Code custom agents: `parcel.agent.md` + `parcel-sprint.agent.md` (orchestrators; `parcel-sprint` is the locked batch host) + `wiki-writer.agent.md` (selectable; `wiki-writer` is also subagent-invocable), `ptp-*.subagent.md` + `wiki-verifier.subagent.md` (subagents; `ptp-parcel-fast` is the hidden per-plan fast runner, spawned only by `parcel-sprint`)
- **`.wiki/rules/`** — Wiki governance layer
- **`.devops/rules/`** — Dev governance layer

Instead of searching the entire codebase to understand context, **STOP** and read the localized
intelligence hub first.

---

## Managed Simplicity
<!-- MACHINERY: keep verbatim -->

> **Managed Simplicity.** We do one thing, we do it well, and we do it fast. Structure must earn its cost: one canonical home per rule, one deterministic check per invariant, no surface that has stopped paying for itself. We do not build machinery for edge cases — we remove or accept them. Depth (the wiki, the pipeline) is bought for outcomes. See `.devops/rules/managed-simplicity.md`.

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
| Checking sprint progress / "where are we" | `@sprint-status` skill | Active `sprints/sprint-{n}-<slug>/sprint.md` + claims in `.devops/plans/` |
| Closing a sprint / retrospective | `@sprint-close` skill | `sprints/sprint-{n}-<slug>/sprint.md` (retro) + REFACTORING.md scan |
| Multi-step planning | `@pass-the-parcel` skill | Template at `.devops/plans/template-plan.md` |
| Running a whole sprint queue | `@sprint-run` skill | `.devops/skills/sprint-run/SKILL.md` |
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
8. <!-- CUSTOMIZE if your app has form-field/validation standards; otherwise delete. -->
9. **PREFIX-LOCKED Integrity:** `.opencode/plans/base-context.md` is the canonical shared prefix for all parcel/ptp agents. NEVER edit the inline prefix inside `.devops/agents/parcel.agent.md` or `.devops/agents/ptp-*.subagent.md` directly — edit `base-context.md`, then run `scripts/check-parcel-prefix.ps1 -Sync` to re-inline it byte-for-byte into every agent. Run `scripts/check-parcel-prefix.ps1` (and `scripts/check-utf8-agents.ps1`) before any push to verify no drift or encoding corruption. See `.opencode/plans/base-context.md`. **No agent declares a model:** every agent inherits the model selected in the CLI / picker, and the operator chooses subagent models at run time (`@model-routing` §3). The `## Model Registry` table is a **capability-class reference**, not a binding — a `model:` line in any agent frontmatter, an `agent.<key>.model` in `opencode.json`, or a third cell in a registry row fails the check. `@sync-architecture` reconciles the capability-class rows and **strips** any model it finds; it never stamps one. The check also fails on a registry key with no agent file, a binding file with no row, and a missing or empty `opencode.json` `agent` block. <!-- MACHINERY: keep verbatim -->
10. **Chunked Write Discipline (large files):** Never materialise a large file in a single `write`/`edit` call — the editor runs a synchronous diff over the whole payload before the permission prompt and the TUI stalls on "Preparing write…". Create a skeleton first (frontmatter + section headings, each with a unique placeholder such as `<!-- FILL:goal -->`) in one small `write`; then fill each section with its own small `edit` that replaces that placeholder. Cap each call at roughly 60–100 lines and split larger sections beneath a sub-placeholder. `write` overwrites — it does not append — so never re-issue the whole payload; after a stall, `read` what landed and continue with the next section. This applies to every agent and subagent, including plan/sprint/doc authoring. <!-- MACHINERY: keep verbatim -->
11. **Sprint Discipline (Agile Cycle, optional):** Development runs in time-boxed sprints tracked in `.devops/backlog/SPRINTS.md`. Feature work is triaged in the `backlog-index.md` Triage Panel and theme registers, committed into a sprint queue via `@sprint-plan`, claimed in place via the claim protocol, executed parcel-by-parcel via `@pass-the-parcel`, and closed via `@sprint-close` (retro appended to `sprint.md`). One active sprint at a time, one claim at a time; do NOT pull ad-hoc items mid-sprint. Code-quality/refactoring lives in `REFACTORING.md` (sprint-close scan), not the backlog. Claim protocol: `.devops/rules/plan-lifecycle.md`. <!-- MACHINERY: optional — delete if you don't adopt the sprint cycle -->
12. <!-- CUSTOMIZE if your app has additional repo-specific rules; otherwise delete. -->
13. **User-Facing Conversation:** Dev to product owner — practical outcomes first, plain words, no unexplained jargon. See `.wiki/rules/language/communication-rules.md` § User-facing conversation. <!-- MACHINERY: keep verbatim -->

---

## Governance Layers

<!-- MACHINERY: keep verbatim -->
- [`.wiki/rules/`](.wiki/rules/README.md) — how the wiki is structured, named, linked
- [`.devops/rules/`](.devops/rules/README.md) — how agents, skills, plans and operational state are governed
- [`.devops/`](.devops/README.md) — operational state + the transportable machinery layer

---

## Wrap-Up Protocol

Use the `@agent-wrap-up` skill when a task is complete. When the last committed plan of an active sprint finishes, follow with `@sprint-close`.
