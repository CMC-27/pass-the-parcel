---
title: Dev Rules
tags: [dev, rules, governance, index]
status: approved
owner: Wiki Owner
last-reviewed: 2026-08-19
related-to: [../.wikirules/README.md, ../.languagerules/README.md, ../AGENTS.md]
---

# Dev Rules

> The dev governance layer — how agents, skills, plans and operational state are created, changed and retired in this repository. Sits alongside `.wikirules/` (wiki content) and `.languagerules/` (writing) and governs the `.devops/` machinery layer.

## What This Layer Governs

| Layer | Governs | Applies when |
|---|---|---|
| [.wikirules/](../.wikirules/README.md) | Wiki content structure, naming, links | Creating/moving/editing wiki content |
| [.languagerules/](../.languagerules/README.md) | How we write | Drafting any document or prompt |
| [.devrules/](README.md) | Agents, skills, plans, operational state | Creating/changing any machinery or dev process |

## Rule Files

| File | Covers |
|---|---|
| [agents-and-skills.md](agents-and-skills.md) | How agents and skills are defined, named, published and synced |
| [plan-lifecycle.md](plan-lifecycle.md) | Parcel plan lifecycle — backlog to archive, gates, single-flight |

## Core Principles

1. **Machinery is transportable.** Skills, agents and scripts are the reusable surface of this repo. They stay repo-agnostic and syncable (see `.wikirules/company-scoping.md`).
2. **Rules live here, not scattered.** If a dev convention is worth following, document it in `.devrules/` and reference it — never duplicate the rule into content.
3. **Deterministic checks beat conventions.** If a rule can be enforced by a script, it is (`scripts/check-parcel-prefix.ps1`, `scripts/check-utf8-agents.ps1`, `.wikirules/wiki_lint.py`). Conventions are for what a script cannot check.
4. **No bypassing the layer.** Creating, moving or renaming machinery goes through `.devrules/` — never around it.

---

*Last reviewed 2026-08-19. Changes to these rules require human sign-off.*