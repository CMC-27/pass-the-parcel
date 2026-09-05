---
title: Dev Ops
tags: [devops, operations, index]
status: active
owner: Wiki Owner
last-reviewed: 2026-08-19
related-to: [../AGENTS.md, ../.devops/rules/README.md, ../.wiki/rules/README.md]
---

# Dev Ops

> Operational state + the transportable machinery layer. Everything here is either **live state** (plans, backlog, archive, logs) or **reusable machinery** (skills, agents) — never reference knowledge. Reference knowledge lives in `.wiki/`; rules live in `.wiki/rules/`, `.wiki/rules/language/` and `.devops/rules/`.

## What Lives Here

| Path | Type | Contents |
|---|---|---|
| `.devops/skills/` | machinery | All skills (`<slug>/SKILL.md`), loaded via `opencode.json` `skills.paths` |
| `.devops/agents/` | machinery | VS Code custom agents: `parcel.agent.md` + `wiki-writer.agent.md` (selectable), `ptp-*.subagent.md` + `wiki-verifier.subagent.md` (subagents) |
| `.devops/plans/` | state | Active parcel plans + `template-plan.md` |
| `.devops/backlog/` | state | Roadmap, backlog items and pre-prepared plans |
| `.devops/archive/` | state | Completed / archived plans (moved via `git mv`, no stub) |
| `.devops/logs/` | state | Agent changelog, knowledge changelog, version history |

## Governance

- **Wiki content rules:** [.wiki/rules/](../.wiki/rules/README.md)
- **Language rules:** [.wiki/rules/language/](../.wiki/rules/language/README.md)
- **Dev rules:** [.devops/rules/](../.devops/rules/README.md)

## Transportability

This layer is the **transportable surface** of the repo. `.devops/skills/`, `.devops/agents/`, `.devops/templates/`, the rule layers, `scripts/` and `.vscode/` can be synced into any satellite repo — the machinery is repo-agnostic and never embeds local state.

- **Bootstrap:** one-time push via `scripts/sync-architecture.ps1 -Target <satellite>` (the pull script doesn't exist in the satellite yet).
- **Ongoing:** `scripts/pull-architecture.ps1` (or the `@sync-architecture` skill) pulls from the source remembered in `.ptp-source`; `-Check` prints a per-item drift table without writing; `-Verify` re-runs the full verification stack (satellite-authored surface + machinery gates) without writing.
- **Versioning:** per-skill integer `version:`/`updated:` frontmatter + one `machinery-version:` in `sync-manifest.yaml` for the agents/rules/scripts/templates set. Portable skills are *derived* (all skills minus `excluded_skills:`), so adding a skill needs no manifest edit.
- **Pruning:** `prune_files:` in `sync-manifest.yaml` lists files deleted from satellites when present (retired upstream), so renames/removals propagate instead of leaving orphans.
- **Seeds:** `.devops/templates/` holds the repo-specific files a satellite authors itself (`AGENTS`, `opencode.json`, `base-context`) plus `SATELLITE-BOOTSTRAP.md`.

---

*Last reviewed 2026-09-03.*