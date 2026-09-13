---
title: Template Maturity
tags: [devops, maturity, assessment, roadmap, governance]
status: active
owner: Wiki Owner
last-reviewed: 2026-09-11
related-to: [./backlog-index.md, ../README.md, ../logs/version-history.md, ../../README.md, ../../AGENTS.md]
---

# Template Maturity

> A living, evidence-based scorecard for the **two jobs** this template does — the parcel planning/execution framework and the agent-first wiki system. It is operational state, not reference knowledge, so it lives in `.devops/` (see [`.wiki/rules/company-scoping.md`](../../.wiki/rules/company-scoping.md)); the durable statement of *what this template is* lives in [`README.md`](../../README.md) and [`AGENTS.md`](../../AGENTS.md).

## Purpose & Context

This register answers one question on demand: **how mature is each axis of the template right now, and what is the next lever?** It exists so a later session does not have to re-derive the assessment from scratch — the previous review's grades, evidence and open gaps are recorded here, and each new reassessment appends a dated row to the history.

It is deliberately not a wishlist. Every grade cites the artefact that earns it and the single next move that would raise it.

## How to Read This

| Grade | Meaning |
|---|---|
| **A+** | Best-in-class; deterministic and self-enforcing; nothing known to add. |
| **A** / **A−** | Strong and complete; minor gaps only. |
| **B+** / **B** / **B−** | Sound with a known shortfall; the next lever is identified. |
| **C** | Works but materially incomplete; adoption or automation missing. |
| **D** | Present but nominal; the mechanism is not yet carrying its weight. |

Grades are judgement, not measurement — but every one is accountable to the **Evidence** column, and the **Next lever** is the honest admission of what is not done.

## The North Star (Dual Purpose)

1. **A premier planning & execution framework** — one Markdown plan carries all state through a stateless, 10-phase, multi-agent pipeline with four hard gates and independent (context-isolated) review.
2. **An inbuilt, agent-first wiki system** — a governed, grounded knowledge base (deterministic linter + Grounded Claims + drift automation) that keeps an agent's context cheap and honest, in the spirit of OpenWiki but differentiated by **governance**, not generation.

## Scorecard (Now — 2026-09-11)

| # | Axis | Grade | Evidence | Next lever |
|---|---|---|---|---|
| 1 | **Planning & execution** | A− | 10-phase parcel pipeline; Gates A–D; `MULTI`/`SINGLE` topology; `AUTO`/`USER-MANAGED` modes; **locked orchestrator presets** (`parcel-fast` = `AUTO`+`SINGLE`, `task: deny`); deterministic `PHASE_5_REVISION` loop; skill-enforced agent embeds | No known gap; keep. Any change is scope, not maturity. |
| 2 | **Deterministic governance** | A+ | `check-parcel-prefix` (PREFIX-LOCKED), `check-utf8-agents`, `wiki_lint`, `wiki_claims` (symbol resolution), `wiki_coverage_check`, `wiki_visualize --check`, machinery-version discipline, sync `-SelfTest`, CI + OKF PyYAML parse, `wiki-refresh` drift job | Nothing known. |
| 3 | **Transportability** | A | `sync-manifest.yaml` + push/pull + per-item `CURRENT`/`UPGRADE`/`DRIFT`/`MISSING`/`PRUNE` verdicts + `machinery-version`; `wiki-refresh.yml` is transportable | Satellite-side adoption is unproven in the field. |
| 4 | **Wiki structure & rules** | A− | Hub-and-spoke; unified `format-version: 1`; `.wiki/rules` governance (incl. `claims.md`); `[UNCATALOGUED]`/`[UNINDEXED]` gates; OKF v0.2 export/import | Ground the remaining core slots that describe real artefacts (`06-directory-structure`). |
| 5 | **Wiki self-maintenance** | B− | 16 Grounded Claims; `#symbol` resolution + drift semantics; `wiki_okf.py` import; secret-free scheduled `wiki-drift` issue | **No auto-refresh PR** (deliberate no-secret trade-off — see T2-E2.02); per-symbol hashing still a `ponytail:` ceiling. |
| 6 | **Template hygiene** | B+ | `README` product page; `LICENSE` (MIT); `CHANGELOG` + track mapping; `CONTRIBUTING`/`SECURITY`/CoC; `.github` templates + `release.yml`; `v1.0.0` tag; worked example | History hygiene (commit/push cadence); optional GitHub Pages for the generated graph. |

## Assessment History

| Date | Axis 1 Planning | Axis 2 Governance | Axis 3 Transport | Axis 4 Wiki rules | Axis 5 Self-maint. | Axis 6 Hygiene | Trigger |
|---|---|---|---|---|---|---|---|
| 2026-09-11 (baseline) | A− | A | A− | B+ | D | D | Initial template review |
| 2026-09-11 (after hygiene) | A− | A | A− | A− | C | B+ | T2-E1 / T3-E1 hygiene & wiki-parity work |
| 2026-09-11 (now) | A− | A+ | A | A− | B− | B+ | T2-E2.01 grounding + T2-E2.02 refresh automation + OKF hardening (machinery 31) |
| 2026-09-13 (now) | A− | A+ | A | A− | B− | B+ | Parcel-Fast locked preset — second orchestrator, structurally single-agent (machinery 37) |

## Method

- **Trigger.** Reassess after any machinery release that changes an axis (see [`../logs/version-history.md`](../logs/version-history.md)), or on request.
- **Evidence rule.** A grade changes only when a referenced artefact changes — never on assertion.
- **Append, don't rewrite.** Add a dated row to the history; update the *Now* table in place (it is the only moving part).
- **Hand-off.** Any gap that becomes work is promoted to the backlog via [`backlog-index.md`](./backlog-index.md); this register tracks maturity, it does not queue work.

## See Also

- [`README.md`](../../README.md) — the dual-purpose statement and quickstart
- [`AGENTS.md`](../../AGENTS.md) — the agent entry point
- [`backlog-index.md`](./backlog-index.md) — the work queue
- [`../logs/version-history.md`](../logs/version-history.md) — machinery releases behind each grade

---

*Last reviewed 2026-09-11.*
