---
title: Agents & Skills
tags: [dev, rules, agents, skills, governance]
status: approved
owner: Wiki Owner
last-reviewed: 2026-08-19
related-to: [./README.md, ../../.opencode/plans/base-context.md, ../../scripts/check-parcel-prefix.ps1]
---

# Agents & Skills

> How agents and skills are defined, named, published and synced in this repository. This is the contract that makes the machinery layer transportable between repos.

## Skill Home

- **All skills live in `.devops/skills/<slug>/SKILL.md`.** Loaded by opencode via `opencode.json` → `skills.paths: [".devops/skills"]`.
- One folder per skill; the folder name matches the frontmatter `name` (kebab-case).
- Skills are **not** stored in `.github/` — that directory is GitHub-specific and coupled to GitHub Copilot. The `.devops/` home is tool-agnostic.

## Agent Home

- **All parcel/ptp agents live in `.devops/agents/` as VS Code custom agent files:** `parcel.agent.md` + `parcel-fast.agent.md` (orchestrators — the latter a locked `AUTO`+`SINGLE` preset) + `parcel-sprint.agent.md` (the batch host for `@sprint-run`, a locked batch preset that spawns one per-plan subagent) + `wiki-writer.agent.md` (selectable) and `ptp-*.subagent.md` + `wiki-verifier.subagent.md` (subagents; `ptp-parcel-fast` is the hidden per-plan runner spawned only by `parcel-sprint` — one prefix apart from the selectable `parcel-fast` orchestrator). On the opencode surface, `wiki-writer` is additionally bound `mode: all` in `opencode.json`, so a primary agent may invoke it as a subagent via the Task tool while users retain direct selection.
- Each file carries YAML frontmatter (description, tools, model, user-invocable) followed by the PREFIX-LOCKED prefix and the agent-unique content.
- The PREFIX-LOCKED prefix must be byte-identical to `.opencode/plans/base-context.md` — enforced by `scripts/check-parcel-prefix.ps1`.
- **Binding files** are `parcel*`, `ptp-*` and `wiki-*` agent files. Each one requires a row in the `## Model Registry` table of `base-context.md`, and each registry row requires a file — both directions are validated. The registry is the single source; the frontmatter `model:` line and `opencode.json` `agent.<key>.model` are derived and force-stamped by sync, so a satellite-side rebind is transient. The `wiki-*` files carry no PREFIX-LOCKED prefix and are validated by the binding pass only.

## PREFIX-LOCKED Contract

1. `.opencode/plans/base-context.md` is the **canonical shared prefix** for all parcel/ptp agents.
2. Never edit the inline prefix inside a `.devops/agents/parcel.agent.md` or `.devops/agents/ptp-*.subagent.md` file directly — edit `base-context.md`, then run:
   ```
   powershell -File scripts\check-parcel-prefix.ps1 -Sync
   ```
3. Run `scripts\check-parcel-prefix.ps1` and `scripts\check-utf8-agents.ps1` before any push. Both exit non-zero on drift/encoding corruption.

## Naming

- Skills: `kebab-case` folder + matching frontmatter `name`, e.g. `.devops/skills/wiki-query/SKILL.md` with `name: wiki-query`.
- Agents: `<slug>.agent.md` for selectable agents (e.g. `.devops/agents/parcel.agent.md`, `parcel-fast.agent.md`, `parcel-sprint.agent.md`, `wiki-writer.agent.md`); `ptp-<slug>.subagent.md` for subagents (e.g. `.devops/agents/ptp-context-hunter.subagent.md`, `ptp-parcel-fast.subagent.md`); `wiki-verifier.subagent.md` for the wiki auditor subagent. Mark an orchestrator's locked preset in the `## Orchestrator Presets` table of `base-context.md` (Mode/Agents), never in a plan file.
- Skill descriptions must state **when to trigger** the skill (the `description` frontmatter is what agents read).

## The "Batch Host" Pattern

A **batch host** is a primary agent whose whole job is to run a *series* of per-plan runs unattended. It is the one legitimate case where a `SINGLE`-style orchestrator **does** spawn — and its `task` allow-list is narrowed to exactly one target.

- **Bounded spawning.** `parcel-sprint`'s `opencode.json` `permission.task` maps `"*"` → `"deny"` and `"ptp-parcel-fast"` → `"allow"` — nothing else. The host can spawn its per-plan runner and nothing more.
- **Deny-after-glob in a plain orchestrator.** `parcel`'s `task` block allows the `"ptp-*"` glob, which would also admit the batch runner; an exact `"ptp-parcel-fast": "deny"` placed **after** the glob overrides it (an exact key is the most specific match and, placed last, also the last match).
- **One fresh context per plan.** Each spawned `ptp-parcel-fast` owns one plan's Phases 1→9 and returns a terse `DONE`/`SKIP`/`HALT`. The host writes no code itself.

Presets for a batch host are declared in the `## Orchestrator Presets` table of `base-context.md`, with the key **backticked** so the Model Registry parser does not mis-read it as a model binding. The same constraint applies to any table added to the ORCHESTRATOR-ONLY block: a bare 4-cell row whose first cell matches `parcel*` / `ptp-*` / `wiki-*` is parsed as a binding row, so wrap such a cell in backticks or avoid the 4-cell shape.

## Sync Protocol

The machinery layer (`.wiki/rules/`, `.wiki/rules/language/`, `.devops/rules/`, `.devops/skills/`, `.devops/agents/`, `.devops/templates/`, `scripts/`) is the **transportable surface** of the repo. When the template updates, satellites pull it: `scripts/pull-architecture.ps1` (or the `@sync-architecture` skill) wraps `scripts/sync-architecture.ps1`, which materialises the surface and regenerates PREFIX-LOCKED agent prefixes from the target's own `base-context.md` (see `.devops/rules/plan-lifecycle.md`).

- **Derived portable list.** Portable skills = every folder in `.devops/skills/` minus the manifest's `excluded_skills:`. Adding a skill requires no manifest edit; only exclusions do.
- **`prune_files`.** Files listed here are deleted from the target if present — used when a portable file is renamed/retired upstream (e.g. the `parcel-*.md` → `.agent.md` migration) so satellites don't accumulate orphaned runbooks.
- **`machinery-version`.** One integer in `sync-manifest.yaml` covering agents/rules/scripts/templates as a coordinated set. Drives UPGRADE-vs-DRIFT classification for non-skill items in `-Check`.
- **Model binding propagation.** Sync force-stamps the source's `## Model Registry` into the target's three surfaces — registry rows in `base-context.md`, each binding file's frontmatter `model:` line, and each `opencode.json` `agent.<key>.model` — **before** regenerating PREFIX-LOCKED prefixes, so the regenerated orchestrator prefixes inline the stamped registry. There is no preservation branch: a satellite-side rebind is reverted on the next sync, and a registry row the target's `base-context.md` lacks is **inserted** (machinery v40+), so template-side registry growth reaches an existing satellite. A key missing from the target's `agent` block is reported as `BINDING-SKIP` and fails that target's own `check-parcel-prefix.ps1` run — sync never adds or restructures the repo-specific `opencode.json`.
- **Per-skill frontmatter.** Every `SKILL.md` must carry `version: <int>` and `updated: <date>` alongside `name`/`description`. Skill frontmatter without them is treated as version `0` by the drift checker.
- **Wrap-up bump step.** `@agent-wrap-up` bumps the affected `version` (skills/templates) and `machinery-version` (scripts/agents/rules) whenever a portable file changes, then refreshes `updated`. No bump → satellites see DRIFT instead of UPGRADE.

---

*Last reviewed 2026-08-19. Changes to these rules require human sign-off.*