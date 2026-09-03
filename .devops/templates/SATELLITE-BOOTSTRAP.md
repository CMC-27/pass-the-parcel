<!--
type: template
version: 1
updated: 2026-09-03

SATELLITE-BOOTSTRAP — one-time checklist to turn any workspace into a parcel blueprint
satellite of the template repo. After step 4, ongoing updates are pulls, not bootstraps.
-->

# Satellite Bootstrap Checklist

You are in a NEW (satellite) workspace that wants the parcel machinery. The template repo is
the single source of truth for `.devops/skills`, `.devops/agents`, `.wiki/rules`,
`.devops/rules`, `.devops/templates`, and the sync scripts.

## 1. One-time bootstrap (push — the pull script doesn't exist here yet)

From the satellite root, either:

```powershell
# local clone of the template repo:
powershell -NoProfile -File <path-to-template>\scripts\sync-architecture.ps1 -Target .
```

or straight from git:

```powershell
git clone <template-url> $env:TEMP\ptp
powershell -NoProfile -File $env:TEMP\ptp\scripts\sync-architecture.ps1 -Target .
```

This materialises the portable surface (skills, agents, rules, templates, scripts) into this
workspace. It will SKIP prefix regeneration — you haven't authored `base-context.md` yet. That's
expected; continue.

## 2. Author the three repo-specific files from the seeds

Copy and customize (the sync never overwrites these):

| Seed (in `.devops/templates/`) | Copy to | Then |
|---|---|---|
| `AGENTS.template.md` | `AGENTS.md` | fill task-lookup rows + app rules 1–4 |
| `opencode.template.json` | `opencode.json` | set models; add parcel-* agent blocks if adopting parcels |
| `base-context.template.md` | `.opencode/plans/base-context.md` | fill core rules / task lookup |

If you adopted the parcel pipeline (parcel-* agents in `opencode.json` + runbooks in
`.devops/agents/`), lock the prefixes:

```powershell
powershell -NoProfile -File scripts\check-parcel-prefix.ps1 -Sync
```

## 3. Record the template source for future pulls

```powershell
powershell -NoProfile -File scripts\pull-architecture.ps1 -Source <template-path-or-git-url>
```

Writes `.ptp-source` (gitignored). From now on, "sync architecture" needs no arguments.

## 4. Verify

```powershell
powershell -NoProfile -File scripts\pull-architecture.ps1 -Check
```

Expect every row `CURRENT` and `IN SYNC` (exit 0). Any `DRIFT` = you customized a portable
file locally — diff it before overwriting. Any `MISSING` = re-run step 1.

## Done

Ongoing updates: say "sync architecture" (the `@sync-architecture` skill) or run
`scripts\pull-architecture.ps1` directly. Use `-Check` first — it never writes.
