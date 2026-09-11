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
- **v0.7.2** (2026-09-11) — OKF round-trip parity: export skips navigation (`README`/`*-index`) exactly as import does, and CI asserts the two counts are equal.
- **v0.7.1** (2026-09-11) — OKF interop hardening: export/import now quote YAML scalars (titles containing `: ` were producing invalid YAML), CI parses the exported bundle with a real YAML parser, and import fails loudly if it leaves the wiki lint-dirty.
- **v0.7.0** (2026-09-11) — Wiki refresh automation: `wiki_okf.py import` ingests an OpenWiki/OKF v0.2 bundle as local `in-progress` drafts (index-registered, skip-on-collision), and a secret-free scheduled `wiki-refresh.yml` raises a `wiki-drift` issue when grounded claims go stale.
- **v0.6.1** (2026-09-11) — Residual hygiene: `wiki_claims.py` failure output now gives a per-class fix hint instead of always suggesting `update`; `CHANGELOG` track-mapping note; T2-E2.02 parked plan.
- **v0.6.0** (2026-09-11) — Wiki grounding & guard hardening: rules-index completeness gate (`[UNCATALOGUED]`), 12 grounded claims across core slots 00/09/12/14/17/18, `#symbol` resolution (`UNRESOLVED-SYMBOL`), `wiki_visualize.py --check` + CI freshness/OKF-smoke steps, UTF-8 guard extended to root/`docs/`/`.github/`.
- **v0.5.0** (2026-09-11) — Coverage gate upgraded to symbol/claims evidence.
- **v0.4.0** (2026-09-11) — Wiki self-maintenance: unified frontmatter, Grounded Claims, `@wiki-update` / `@wiki-generate`, OKF export, static visualizer.
- **v0.3.6** (2026-09-07) — Determinism overhaul: canonical 4-gate lifecycle, script-enforced agent embeds, one-question-at-a-time clarification.

Full machinery history: [`.devops/logs/version-history.md`](.devops/logs/version-history.md).
