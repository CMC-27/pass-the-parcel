# Contributing to Pass the Parcel

Thanks for taking the time to contribute. This repository is the **template** for the Pass the Parcel pipeline — it ships the planning machinery, the wiki knowledge layer, and the deterministic gates. There is no application source tree here; your changes are to the machinery itself or to its documentation.

## Before you start

- Read [`AGENTS.md`](AGENTS.md) — it is the authoritative operating layer and maps every task to the docs that govern it.
- Read [`HOW-TO.md`](HOW-TO.md) for the lifecycle and the sync model.
- Check the [backlog index](.devops/backlog/backlog-index.md) and the [archive](.devops/archive/) so you don't duplicate in-flight work.

## What to change

| You want to… | Edit | Notes |
|---|---|---|
| Fix a doc, link, or typo | The doc itself | Run the wiki linter before pushing (below). |
| Change a skill's behaviour | `.devops/skills/<skill>/SKILL.md` | Bump the skill's `version:` + `updated:` frontmatter. |
| Change an agent's persona/wiring | `.devops/agents/**` | Agents are versioned as a set via `machinery-version:`. |
| Change the PREFIX-LOCKED prefix | `.opencode/plans/base-context.md` | **Never** edit the inlined copies directly — re-sync (below). |
| Change what transports to satellites | `.devops/sync-manifest.yaml` | Then bump `machinery-version:` and record it in `.devops/logs/version-history.md`. |
| Plan a non-trivial feature | A parcel plan | Use the `@pass-the-parcel` skill; plans live in `.devops/plans/`. |

## The PREFIX-LOCKED rule

Every parcel/ptp agent embeds a byte-for-byte copy of the shared prefix. Do **not** edit those copies. Edit `.opencode/plans/base-context.md`, then regenerate:

```powershell
powershell -NoProfile -File scripts\check-parcel-prefix.ps1 -Sync
```

## Run the gates locally before you push

Treat a green local run as the price of a pull request. All of these must exit `0`:

```powershell
powershell -NoProfile -File scripts\check-parcel-prefix.ps1
powershell -NoProfile -File scripts\check-utf8-agents.ps1
python scripts/wiki_lint.py --quiet
python scripts/wiki_coverage_check.py
python scripts/wiki_claims.py check
python -c "import json; json.load(open('opencode.json', encoding='utf-8'))"
```

If you touched the transport engine, also run the sync smoke test:

```powershell
powershell -NoProfile -File scripts/sync-architecture.ps1 -SelfTest
```

The same suite runs in CI on every push (`.github/workflows/validate.yml`).

## Pull request flow

1. Fork or branch from `main`.
2. Keep the change scoped — small, single-purpose PRs review faster.
3. Fill in the [pull request template](.github/PULL_REQUEST_TEMPLATE.md).
4. Make sure CI is green. A red gate is a blocker, not a note.

## Reporting bugs and requesting features

Use the [issue templates](.github/ISSUE_TEMPLATE/). For security issues, follow [`SECURITY.md`](SECURITY.md) instead of opening a public issue.

## Code of conduct

Participation is governed by [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).
