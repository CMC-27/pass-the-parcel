# Changelog

Human-facing release notes for **Pass the Parcel**.

This file records **product/template** releases. The internal machinery log — `machinery-version` bumps and per-skill version discipline — lives separately in [`.devops/logs/version-history.md`](.devops/logs/version-history.md) and is kept there on purpose so there is exactly one source for each question.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and releases follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> **Track mapping.** Two versions move independently: the **product** line (this file) and the **machinery** line (`machinery-version` in `.devops/sync-manifest.yaml`). Product **v1.0.0** shipped on machinery-version **26**. Machinery releases continue after it, so the "Earlier releases" list below includes machinery versions newer than v1.0.0.

## [v1.0.0] — 2026-09-11

First public release of the template.

### Added
- `README.md` rewritten as a product page — pitch, CI badge, pipeline diagram, 5-minute quickstart, feature matrix, and repository map.
- `LICENSE` (MIT), `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`.
- GitHub furniture — `.github/ISSUE_TEMPLATE/` (bug report, feature request, chooser config), `.github/PULL_REQUEST_TEMPLATE.md`, `.github/CODEOWNERS`, `.github/release.yml`.
- Worked example — [`.wiki/examples/parcel-walkthrough-machinery-hardening.md`](.wiki/examples/parcel-walkthrough-machinery-hardening.md): a complete parcel run including a review rejection and a revision loop.

### Changed
- The public product name is **Pass the Parcel**; "Application Wiki" is retained only as the descriptor for the wiki knowledge layer.

## Earlier releases
- **v0.7.11** (2026-09-13) — Pre-satellite-sync audit tidy-up: sync now **inserts** Model Registry rows a satellite is missing, so a template-side registry growth reaches an already-bootstrapped satellite; `prune_files` gains the retired `parcel-compactor.md`; the UTF-8 guard covers `.devops/rules` + `.devops/templates`; the T1 / MATURITY / CHANGELOG registers are backfilled; and the Gate-A-in-`AUTO` contradiction is reconciled (`AUTO` auto-clears A–C; only Gate D always halts).
- **v0.7.10** (2026-09-13) — Model bindings become **registry-canonical and template-owned**: the `## Model Registry` is the single source, agent frontmatter + `opencode.json` are derived and force-stamped by sync, seeds ship concrete bindings, and the VS Code-only opt-out is retired.
- **v0.7.9** (2026-09-13) — Sprint batch runner: a selectable `parcel-sprint` host + `@sprint-run` walk the committed sprint queue and run each eligible plan Phases 1→9 in one unattended pass (fresh context per plan, trunk-sequential, batched Gate D).
- **v0.7.8** (2026-09-13) — Parcel-Fast locked preset: a second selectable orchestrator carrying `AUTO` + `SINGLE`, so the single-agent fast path needs no Mode/Topology questions; `task: deny` enforces it structurally.
- **v0.7.7** (2026-09-13) — Concurrency + sprint lifecycle rewrite: a plan is committed into `.devops/sprints/sprint-{n}-<slug>/` (single `sprint.md`, no `retro.md`), claimed via claim front-matter + `git mv` into `.devops/plans/` + a `git worktree` branch, and completed plans archive to `.devops/archive/` root. Backlog detail moves into `t{n}-<slug>-backlog.md` theme registers, making `backlog-index.md` a Triage Panel + Themes table. Shared files stay trunk-only.
- **v0.7.6** (2026-09-12) — `wiki-writer` can run as a subagent on demand: `opencode.json` rebinds it `mode: all`, so it stays user-selectable while any primary agent may invoke it via the Task tool.
- **v0.7.5** (2026-09-12) — Plan settings promoted to a frozen top-of-file `## ⚙️ Plan Settings` block: `Mode`/`Agents` move out of the cache-anchored bottom `State & Gates` table (where resumed sessions and narrowly-prompted subagents sometimes missed them), leaving the bottom with only mutable state. Moved, not copied, across the plan template, `base-context.md` (prefix re-inlined ×7), agent steps, the `pass-the-parcel` skill, `plan-lifecycle.md`, HOW-TO, and the satellite seed.
- **v0.7.4** (2026-09-11) — Encoding-hygiene fix: repaired CP437 mojibake in two portable skills (`app-vision-north-star`, `wiki-assessment`), quoted unquoted-colon skill descriptions and completed `caveman` frontmatter, and widened the UTF-8 guard (`check-utf8-agents.ps1`) to catch the CP437 corruption path it previously missed.
- **v0.7.3** (2026-09-11) — Sync `-Check` exit-code honesty: `PRUNE` now counts as out-of-sync, and a retired file no longer masquerades as a parent-directory `DRIFT` ("locally customized"); `-SelfTest` asserts both.
- **v0.7.2** (2026-09-11) — OKF round-trip parity: export skips navigation (`README`/`*-index`) exactly as import does, and CI asserts the two counts are equal.
- **v0.7.1** (2026-09-11) — OKF interop hardening: export/import now quote YAML scalars (titles containing `: ` were producing invalid YAML), CI parses the exported bundle with a real YAML parser, and import fails loudly if it leaves the wiki lint-dirty.
- **v0.7.0** (2026-09-11) — Wiki refresh automation: `wiki_okf.py import` ingests an OpenWiki/OKF v0.2 bundle as local `in-progress` drafts (index-registered, skip-on-collision), and a secret-free scheduled `wiki-refresh.yml` raises a `wiki-drift` issue when grounded claims go stale.
- **v0.6.1** (2026-09-11) — Residual hygiene: `wiki_claims.py` failure output now gives a per-class fix hint instead of always suggesting `update`; `CHANGELOG` track-mapping note; T2-E2.02 parked plan.
- **v0.6.0** (2026-09-11) — Wiki grounding & guard hardening: rules-index completeness gate (`[UNCATALOGUED]`), 12 grounded claims across core slots 00/09/12/14/17/18, `#symbol` resolution (`UNRESOLVED-SYMBOL`), `wiki_visualize.py --check` + CI freshness/OKF-smoke steps, UTF-8 guard extended to root/`docs/`/`.github/`.
- **v0.5.0** (2026-09-11) — Coverage gate upgraded to symbol/claims evidence.
- **v0.4.0** (2026-09-11) — Wiki self-maintenance: unified frontmatter, Grounded Claims, `@wiki-update` / `@wiki-generate`, OKF export, static visualizer.
- **v0.3.6** (2026-09-07) — Determinism overhaul: canonical 4-gate lifecycle, script-enforced agent embeds, one-question-at-a-time clarification.

Full machinery history: [`.devops/logs/version-history.md`](.devops/logs/version-history.md).
