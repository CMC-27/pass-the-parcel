---
title: Dev Ops
tags: [devops, operations, index]
status: active
owner: Wiki Owner
last-reviewed: 2026-09-09
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
| `.devops/backlog/` | state | Roadmap, backlog items, the maturity register (`MATURITY.md`) and pre-prepared plans |
| `.devops/archive/` | state | Completed / archived plans (moved via `git mv`, no stub) |
| `.devops/audits/` | state | Audit session artifacts: true-or-false logs, Q&A logs, UI inventory reports |
| `.devops/logs/` | state | Agent changelog, version history |

## Governance

- **Wiki content rules:** [.wiki/rules/](../.wiki/rules/README.md)
- **Language rules:** [.wiki/rules/language/](../.wiki/rules/language/README.md)
- **Dev rules:** [.devops/rules/](../.devops/rules/README.md)

## Transportability

This layer is the **transportable surface** of the repo. `.devops/skills/`, `.devops/agents/`, `.devops/templates/`, the rule layers, `scripts/` and `.vscode/` can be synced into any satellite repo — the machinery is repo-agnostic and never embeds local state.

- **Bootstrap:** one-time push via `scripts/sync-architecture.ps1 -Target <satellite>` (the pull script doesn't exist in the satellite yet).
- **Ongoing:** `scripts/pull-architecture.ps1` (or the `@sync-architecture` skill) pulls from the source remembered in `.ptp-source`; `-Check` prints a per-item drift table without writing; `-Verify` re-runs the full verification stack (satellite-authored surface + machinery gates) without writing.
- **Versioning:** per-skill integer `version:`/`updated:` frontmatter + one `machinery-version:` in `sync-manifest.yaml` for the agents/rules/scripts/templates set. Portable skills are *derived* (all skills minus `excluded_skills:`), so adding a skill needs no manifest edit.
- **Pruning:** `prune_files:` in `sync-manifest.yaml` lists files deleted from satellites when present (retired upstream), so renames/removals propagate instead of leaving orphans. A lingering prune file reports `PRUNE` and counts as out of sync in `-Check` (exit 1); it is excluded from its parent directory's comparison so it never reads as a parent-dir `DRIFT`.
- **Portable means no absolute paths:** committed machinery never carries machine-specific values (`git.path`, PATH overrides, folder-open side effects) — those live in user-level config (VS Code user settings, terminal profiles). Anything machine-specific in the portable surface silently breaks every other machine that opens the repo.
- **Compare semantics, not encoding artifacts:** any tool that hashes or diffs files across git boundaries must normalize CRLF→LF first — `core.autocrlf=true` plus `eol=lf` materialize LF blobs as CRLF in the Windows working tree, so raw hashes false-report DRIFT. Same rule for encoding: never re-copy a mojibake file through sync; repair it to clean UTF-8 (no BOM) at the source.
- **Gates must be reproducible from a fresh clone:** any check referencing a path outside `git ls-files` is a latent false failure — local-green is not CI-green. Assert tracked files only.
- **Seeds:** `.devops/templates/` holds the repo-specific files a satellite authors itself (`AGENTS`, `opencode.json`, `base-context`) plus `SATELLITE-BOOTSTRAP.md`.

---

*Last reviewed 2026-09-09.*