---
title: Content-vs-State Principle
tags: [wiki, rules, scope, governance]
status: approved
owner: Wiki Owner
last-reviewed: 2026-08-19
related-to: [./README.md, ./link-hygiene.md, ../AGENTS.md]
---

# Content-vs-State Principle

> The wiki is **portable**. Everything under `.wiki/` is reference knowledge that could be lifted and shifted to another repo or team. Operational and development state — plans, backlog, archives, changelogs — lives in the unnumbered `.devops/` layer. Skills and agents live in `.devops/` too, so the whole machinery layer can be synced between repos without dragging local state.

## The Principle

- **Wiki content is reference knowledge.** Architecture, design system, features, database, logic and integration docs describe how the product works. They must not be written around a single person, a single session, or a live operational snapshot.
- **State lives in `.devops/`.** Active plans (`.devops/plans/`), planned work (`.devops/backlog/`), completed work (`.devops/archive/`), changelogs (`.devops/logs/`) and the runtime machinery (`.devops/skills/`, `.devops/agents/`) are operational, not reference knowledge.
- **Machinery is transportable.** Skills, agents, rule layers and scripts are the reusable surface of this repo — the thing you copy to bootstrap a new workspace. They stay tool-agnostic: no workspace-specific paths, names or session data baked in.

## What Goes Where

| Content | Location |
|---|---|
| Architecture, design system, features, schema, logic, integrations | `.wiki/` — reference knowledge |
| Skills (SKILL.md per folder) | `.devops/skills/` — machinery |
| Agent runbooks (parcel-*.md) | `.devops/agents/` — machinery |
| Active parcel plans + template | `.devops/plans/` — state |
| Roadmap + backlog items | `.devops/backlog/` — state |
| Completed / archived plans | `.devops/archive/` — state |
| Agent changelog, knowledge changelog, version history | `.devops/logs/` — state |

## Rules

1. **State never enters numbered wiki content.** No live status, plan progress or changelog inside `.wiki/`.
2. **Machinery never embeds local state.** Skills and agents reference paths and rules relative to the repo layout; they never hardcode a session, a date range or a person.
3. **Link, don't duplicate.** Wiki content links to `.devops/` where a process is described; it never copies the live state.
4. **When in doubt, ask.** If a fact is operational, it belongs in `.devops/`. If it is how the product works, it belongs in `.wiki/`.

## Applying to New Content

Before creating or editing any doc, skill or agent, ask: **"Would this survive being synced to a different repo?"** If not, it belongs in `.devops/` (state) or needs to be reworded to be repo-agnostic.

---

*Last reviewed 2026-08-19. Changes to these rules require human sign-off.*