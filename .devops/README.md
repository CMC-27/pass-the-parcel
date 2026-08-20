---
title: Dev Ops
tags: [devops, operations, index]
status: active
owner: Wiki Owner
last-reviewed: 2026-08-19
related-to: [../AGENTS.md, ../.devrules/README.md, ../.wikirules/README.md]
---

# Dev Ops

> Operational state + the transportable machinery layer. Everything here is either **live state** (plans, backlog, archive, logs) or **reusable machinery** (skills, agents) — never reference knowledge. Reference knowledge lives in `docs/wiki/`; rules live in `.wikirules/`, `.languagerules/` and `.devrules/`.

## What Lives Here

| Path | Type | Contents |
|---|---|---|
| `.devops/skills/` | machinery | All skills (`<slug>/SKILL.md`), loaded via `opencode.json` `skills.paths` |
| `.devops/agents/` | machinery | All parcel agent runbooks (`parcel-*.md`, PREFIX-LOCKED pure body), loaded via `prompt: {file: ...}` in `opencode.json` |
| `.devops/plans/` | state | Active parcel plans + `template-plan.md` |
| `.devops/backlog/` | state | Roadmap, backlog items and pre-prepared plans |
| `.devops/archive/` | state | Completed / archived plans (moved via `git mv`, no stub) |
| `.devops/logs/` | state | Agent changelog, knowledge changelog, version history |

## Governance

- **Wiki content rules:** [.wikirules/](../.wikirules/README.md)
- **Language rules:** [.languagerules/](../.languagerules/README.md)
- **Dev rules:** [.devrules/](../.devrules/README.md)

## Transportability

This layer is the **transportable surface** of the repo. `.devops/skills/`, `.devops/agents/`, the rule layers and `scripts/` can be synced into any satellite repo via `scripts/sync-architecture.ps1` — the machinery is repo-agnostic and never embeds local state.

---

*Last reviewed 2026-08-19.*