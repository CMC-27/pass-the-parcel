---
name: sync-architecture
description: "Use when the user mentions syncing architecture, pulling template updates, updating parcel machinery, 'sync tools', 'pull latest skills/agents', or wants this workspace's .devops machinery refreshed from the template repo. Runs scripts/pull-architecture.ps1 against the current workspace root and reports drift."
version: 1
updated: 2026-09-03
---

# SKILL: Sync Architecture (`sync-architecture`)

Refresh this satellite workspace's transportable machinery (skills, agents, rules, templates,
scripts) from the template repo recorded in `.ptp-source`. Thin wrapper over
`scripts/pull-architecture.ps1`, which delegates to the template's `sync-architecture.ps1`.

## Workflow

1. **Identify the workspace root** (cwd). Refuse if no `.devops/` directory exists there —
   that is the wrong kind of workspace; tell the user to bootstrap from the template first
   (see `.devops/templates/SATELLITE-BOOTSTRAP.md`).

2. **Run the pull script** with the switch matching the user's intent:

   | User asks | Command |
   |---|---|
   | "what's new" / "check" / "is anything outdated" | `powershell -NoProfile -File scripts\pull-architecture.ps1 -Check` |
   | "preview" / "show me what would change" | `powershell -NoProfile -File scripts\pull-architecture.ps1 -DryRun` |
   | "sync" / "update machinery" / "pull latest" | `powershell -NoProfile -File scripts\pull-architecture.ps1` |

   Never pass `-Source` unless the user explicitly supplies one — `.ptp-source` remembers it.
   If no `.ptp-source` exists, relay the script's hint: run once with `-Source <path-or-git-url>`.

3. **Interpret the verdict table** (`-Check` output) in plain language:

   | Verdict | Meaning | Action |
   |---|---|---|
   | `CURRENT` | identical | none |
   | `UPGRADE` | newer version upstream | safe to pull |
   | `DRIFT` | same version, different bytes | **locally customized copy — do not blindly overwrite; ask the user.** Offer to show the diff before re-running without `-Check` |
   | `MISSING` | never installed here | will be created by a sync |
   | `SOURCE-ABSENT` | manifest bug in the template | report to the template repo owner |

   Summarize counts + the IN SYNC / OUT OF SYNC line. Exit code 1 = out of sync.

4. **First-time satellite** (many `MISSING` rows): after syncing, tell the user which
   repo-specific files still need authoring from the seed templates in `.devops/templates/`:
   `AGENTS.md`, `opencode.json`, `.opencode/plans/base-context.md` — then
   `scripts\check-parcel-prefix.ps1 -Sync` once parcel agents exist.

## Rules

- `-Check` never writes; it is always safe to run first. Prefer starting any sync request with
  `-Check` and presenting findings before mutating.
- A real sync regenerates PREFIX-LOCKED agent prefixes from *this* workspace's `base-context.md`
  and runs the verification gates (prefix, UTF-8, wiki lint). Report gate failures verbatim —
  never suppress them with `-NoVerify` unless the user insists.
- After any machinery edit in the template repo itself, the wrap-up discipline bumps per-skill
  `version` / `machinery-version`; this skill only consumes those numbers, never edits them.
