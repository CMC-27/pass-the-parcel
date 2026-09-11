# Changelog

Human-facing release notes for **Pass the Parcel**.

This file records **product/template** releases. The internal machinery log — `machinery-version` bumps and per-skill version discipline — lives separately in [`.devops/logs/version-history.md`](.devops/logs/version-history.md) and is kept there on purpose so there is exactly one source for each question.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and releases follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- **v0.5.0** (2026-09-11) — Coverage gate upgraded to symbol/claims evidence.
- **v0.4.0** (2026-09-11) — Wiki self-maintenance: unified frontmatter, Grounded Claims, `@wiki-update` / `@wiki-generate`, OKF export, static visualizer.
- **v0.3.6** (2026-09-07) — Determinism overhaul: canonical 4-gate lifecycle, script-enforced agent embeds, one-question-at-a-time clarification.

Full machinery history: [`.devops/logs/version-history.md`](.devops/logs/version-history.md).
