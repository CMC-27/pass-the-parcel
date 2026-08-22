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

- **All parcel agent runbooks live in `.devops/agents/parcel-*.md`.** They are **pure body**: the PREFIX-LOCKED prefix followed by the agent-unique content, with no frontmatter.
- Agent config (description, mode, model, permissions) lives in `opencode.json`, which loads the runbook via `prompt: {file: .devops/agents/parcel-*.md}`.
- The runbook must start with the byte-identical PREFIX-LOCKED prefix from `.opencode/plans/base-context.md` — enforced by `scripts/check-parcel-prefix.ps1`.

## PREFIX-LOCKED Contract

1. `.opencode/plans/base-context.md` is the **canonical shared prefix** for all parcel-* agents.
2. Never edit the inline prefix inside a `.devops/agents/parcel-*.md` runbook directly — edit `base-context.md`, then run:
   ```
   powershell -File scripts\check-parcel-prefix.ps1 -Sync
   ```
3. Run `scripts\check-parcel-prefix.ps1` and `scripts\check-utf8-agents.ps1` before any push. Both exit non-zero on drift/encoding corruption.

## Naming

- Skills: `kebab-case` folder + matching frontmatter `name`, e.g. `.devops/skills/wiki-query/SKILL.md` with `name: wiki-query`.
- Agents: `parcel-<role>.md`, e.g. `.devops/agents/parcel-orchestrator.md`.
- Skill descriptions must state **when to trigger** the skill (the `description` frontmatter is what agents read).

## Sync Protocol

The machinery layer (`.wiki/rules/`, `.wiki/rules/language/`, `.devops/rules/`, `.devops/skills/`, `.devops/agents/`, `scripts/`) is the **transportable surface** of the repo. When the template updates, `scripts/sync-architecture.ps1` materialises it into satellite repos (see `.devops/rules/plan-lifecycle.md`).

---

*Last reviewed 2026-08-19. Changes to these rules require human sign-off.*