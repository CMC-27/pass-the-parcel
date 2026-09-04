---
title: Agents & Skills
tags: [dev, rules, agents, skills, governance]
status: approved
owner: Wiki Owner
last-reviewed: 2026-08-19
related-to: [./README.md, ../.opencode/plans/base-context.md, ../scripts/check-parcel-prefix.ps1]
---

# Agents & Skills

> How agents and skills are defined, named, published and synced in this repository. This is the contract that makes the machinery layer transportable between repos.

## Skill Home

- **All skills live in `.devops/skills/<slug>/SKILL.md`.** Loaded by opencode via `opencode.json` → `skills.paths: [".devops/skills"]`.
- One folder per skill; the folder name matches the frontmatter `name` (kebab-case).
- Skills are **not** stored in `.github/` — that directory is GitHub-specific and coupled to GitHub Copilot. The `.devops/` home is tool-agnostic.

## Agent Home

- **All parcel/ptp agents live in `.devops/agents/` as VS Code custom agent files:** `parcel.agent.md` + `wiki-writer.agent.md` (selectable) and `ptp-*.subagent.md` + `wiki-verifier.subagent.md` (subagents).
- Each file carries YAML frontmatter (description, tools, model, user-invocable) followed by the PREFIX-LOCKED prefix and the agent-unique content.
- The PREFIX-LOCKED prefix must be byte-identical to `.opencode/plans/base-context.md` — enforced by `scripts/check-parcel-prefix.ps1`.

## PREFIX-LOCKED Contract

1. `.opencode/plans/base-context.md` is the **canonical shared prefix** for all parcel/ptp agents.
2. Never edit the inline prefix inside a `.devops/agents/parcel.agent.md` or `.devops/agents/ptp-*.subagent.md` file directly — edit `base-context.md`, then run:
   ```
   powershell -File scripts\check-parcel-prefix.ps1 -Sync
   ```
3. Run `scripts\check-parcel-prefix.ps1` and `scripts\check-utf8-agents.ps1` before any push. Both exit non-zero on drift/encoding corruption.

## Naming

- Skills: `kebab-case` folder + matching frontmatter `name`, e.g. `.devops/skills/wiki-query/SKILL.md` with `name: wiki-query`.
- Agents: `<slug>.agent.md` for selectable agents (e.g. `.devops/agents/parcel.agent.md`, `wiki-writer.agent.md`); `ptp-<slug>.subagent.md` for subagents (e.g. `.devops/agents/ptp-context-hunter.subagent.md`); `wiki-verifier.subagent.md` for the wiki auditor subagent.
- Skill descriptions must state **when to trigger** the skill (the `description` frontmatter is what agents read).

## Sync Protocol

The machinery layer (`.wiki/rules/`, `.wiki/rules/language/`, `.devops/rules/`, `.devops/skills/`, `.devops/agents/`, `.devops/templates/`, `scripts/`) is the **transportable surface** of the repo. When the template updates, satellites pull it: `scripts/pull-architecture.ps1` (or the `@sync-architecture` skill) wraps `scripts/sync-architecture.ps1`, which materialises the surface and regenerates PREFIX-LOCKED agent prefixes from the target's own `base-context.md` (see `.devops/rules/plan-lifecycle.md`).

- **Derived portable list.** Portable skills = every folder in `.devops/skills/` minus the manifest's `excluded_skills:`. Adding a skill requires no manifest edit; only exclusions do.
- **`prune_files`.** Files listed here are deleted from the target if present — used when a portable file is renamed/retired upstream (e.g. the `parcel-*.md` → `.agent.md` migration) so satellites don't accumulate orphaned runbooks.
- **`machinery-version`.** One integer in `sync-manifest.yaml` covering agents/rules/scripts/templates as a coordinated set. Drives UPGRADE-vs-DRIFT classification for non-skill items in `-Check`.
- **Per-skill frontmatter.** Every `SKILL.md` must carry `version: <int>` and `updated: <date>` alongside `name`/`description`. Skill frontmatter without them is treated as version `0` by the drift checker.
- **Wrap-up bump step.** `@agent-wrap-up` bumps the affected `version` (skills/templates) and `machinery-version` (scripts/agents/rules) whenever a portable file changes, then refreshes `updated`. No bump → satellites see DRIFT instead of UPGRADE.

---

*Last reviewed 2026-08-19. Changes to these rules require human sign-off.*