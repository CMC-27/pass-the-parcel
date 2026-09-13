<!--
type: template
version: 10
updated: 2026-09-13

SATELLITE-BOOTSTRAP — one-time checklist to turn any workspace into a parcel blueprint
satellite of the template repo. After step 4, ongoing updates are pulls, not bootstraps.
-->

# Satellite Bootstrap Checklist

You are in a NEW (satellite) workspace that wants the parcel machinery. The template repo is
the single source of truth for `.devops/skills`, `.devops/agents`, `.wiki/rules`,
`.devops/rules`, `.devops/templates`, `.vscode`, and the sync scripts.

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

## 2. Author the repo-specific files from the seeds

Copy and customize (the sync never overwrites these):

| Seed (in `.devops/templates/`) | Copy to | Then |
|---|---|---|
| `AGENTS.template.md` | `AGENTS.md` | fill task-lookup rows + app rules 1–4 |
| `opencode.template.json` | `opencode.json` | delete the `_comment` array; **keep the `agent` block** — it ships pre-bound and `@sync-architecture` re-stamps the model values on every pull (a missing/empty block fails `check-parcel-prefix.ps1`) |
| `base-context.template.md` | `.opencode/plans/base-context.md` | fill core rules / task lookup |
| `SPRINTS.template.md` | `.devops/backlog/SPRINTS.md` | sprint register — leave index empty until first `@sprint-plan` |
| `sprint.template.md` | *(no copy)* | reference seed for the single `sprint.md`; `@sprint-plan` writes it into `.devops/sprints/sprint-{n}-<slug>/` |
| `TRIAGE.template.md` | `.devops/backlog/TRIAGE.md` | triage framework — process doc, edit only if your tiers differ |
| `REFACTORING.template.md` | `.devops/backlog/REFACTORING.md` | code-quality register — scan tables populate via `@spaghetti-monster` / `@sprint-close` |

> The three backlog seeds (`SPRINTS` / `TRIAGE` / `REFACTORING`) are optional but recommended — they wire up the agile cycle that the `@sprint-*` skills drive. A satellite without them still gets the parcel pipeline; it just plans work ad-hoc instead of in sprints.
>
> **Migration (opencode.json):** satellites created before machinery v39 may have deleted the
> `agent` block (the old seed told them to). That layout is **no longer supported** —
> `check-parcel-prefix.ps1` fails with `opencode.json: no 'agent' block`. Restore it by
> re-copying `.devops/templates/opencode.template.json` to `opencode.json`, keeping your own
> `permission` blocks, then delete the `_comment` array. Model values are re-stamped by sync,
> so never hand-bind them here (`@model-routing` §3).

If you adopted the parcel pipeline (agents in `.devops/agents/`), lock the prefixes:

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

Then confirm the authored surface is wired correctly:

```powershell
powershell -NoProfile -File scripts\pull-architecture.ps1 -Verify
```

Expect `VERIFIED` (exit 0). `[FAIL]` rows name exactly what is missing or mis-wired
(`AGENTS.md` machinery markers, `opencode.json` keys, `base-context.md`, the wiki anchor,
missing machinery); `[WARN]` rows are advisory (e.g. `.ptp-source` not yet recorded).

> **Your CI is yours to wire.** `.github/workflows/validate.yml` is not on the portable surface —
> only the template repo runs it. Copy its steps (or an equivalent subset) into a satellite
> workflow; the checks themselves ride in the synced `scripts/check-parcel-prefix.ps1`, so
> `powershell -NoProfile -File scripts\check-parcel-prefix.ps1` is the minimum gate to run on
> every push. It now also validates the seed surfaces and fails on a missing `agent` block.

## 5. Wiki evidence layer (optional)

The wiki surface ships four portable scripts beyond the linter:

| Script | Purpose |
|---|---|
| `scripts/wiki_claims.py` | `check` grounded claims for drift, `affected <sha>` for docs a diff hit, `update` to re-stamp |
| `scripts/wiki_okf.py` | `export` the wiki as an OpenWiki/OKF v0.2 bundle, `import` one back as `in-progress` drafts (index-registered, existing docs skipped) |
| `scripts/wiki_visualize.py` | Write the static hub-spoke graph + catalog into `docs/` |
| `scripts/wiki_coverage_check.py` | Coverage gate — a non-test source file is evidenced by an index-cited exported symbol, a `claims: source:` binding, or the retained filename/folder match; no-op until `src/` exists |

`check` runs in CI with no secret. Two skills scaffold the workflow: `@wiki-generate` drafts
structure, `@wiki-bootstrap` verifies it, `@wiki-update` refreshes incrementally. A scheduled
`.github/workflows/wiki-refresh.yml` (synced as a portable file) runs `check` weekly and raises a
`wiki-drift` issue when claims go stale, closing it once clean. Nothing here requires a model API key.

## Done

Ongoing updates: say "sync architecture" (the `@sync-architecture` skill) or run
`scripts\pull-architecture.ps1` directly. Use `-Check` first — it never writes.
