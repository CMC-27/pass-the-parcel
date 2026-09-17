---
title: Template Maturity
tags: [devops, maturity, assessment, roadmap, governance]
status: active
owner: Wiki Owner
last-reviewed: 2026-09-17
related-to: [./backlog-index.md, ../README.md, ../logs/version-history.md, ../../README.md, ../../AGENTS.md]
---

# Template Maturity

> A living, evidence-based scorecard for the template's **goal and the instruments that serve it** — the parcel planning/execution framework (the goal) and the agent-first wiki (its principal instrument). It is operational state, not reference knowledge, so it lives in `.devops/` (see [`.wiki/rules/company-scoping.md`](../../.wiki/rules/company-scoping.md)); the durable statement of *what this template is* lives in [`OPERATING-PRINCIPLES.md`](../../OPERATING-PRINCIPLES.md), [`README.md`](../../README.md) and [`AGENTS.md`](../../AGENTS.md).

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

## The North Star (The Goal and Its Instruments)

1. **The goal — Pass the Parcel** — one Markdown plan carries all state through a stateless, 10-phase, multi-agent pipeline with four hard gates and independent (context-isolated) review.
2. **The principal instrument — the agent-managed wiki** — a governed, grounded knowledge base (deterministic linter + Grounded Claims + drift automation) that keeps an agent's context cheap and honest, in the spirit of OpenWiki but differentiated by **governance**, not generation.

## Scorecard (Now — 2026-09-17)

| # | Axis | Grade | Evidence | Next lever |
|---|---|---|---|---|
| 1 | **Planning & execution** | A− | 10-phase parcel pipeline; Gates A–D; `MULTI`/`SINGLE` topology; `AUTO`/`USER-MANAGED` modes; **locked orchestrator presets** (`parcel` = `ask`; `parcel-sprint` = locked batch host, `task` narrowed to exactly its per-plan runner); a **batch host** (`parcel-sprint` / `@sprint-run` — trunk-sequential, batched Gate D, Strict Context Isolation exception) spawning the subagent-only `ptp-parcel-fast`; deterministic `PHASE_5_REVISION` loop; skill-enforced agent embeds | No known gap; keep. Any change is scope, not maturity. |
| 2 | **Deterministic governance** | A | `check-parcel-prefix` (PREFIX-LOCKED; live + seed registry, seed config, binding-file coverage), `check-utf8-agents` (agents, skills, rules, seeds, wiki, docs — **~32× faster** since W7 and no longer blind at EOF), `wiki_lint`, `wiki_claims` (symbol resolution + the moved `coverage` gate), machinery-version discipline, sync `-SelfTest` (now also proves `prune_dirs`), CI + a dependency-free `.wiki/**` frontmatter-YAML parse, `wiki-refresh` drift job. **Re-scored down from A+**: two assertions left with their subjects (see the 2026-09-17 history row) | Nothing known. The two removed assertions are recorded, not replaced — the invariants they guarded have no surviving subject. |
| 3 | **Transportability** | A | `sync-manifest.yaml` + push/pull + per-item `CURRENT`/`UPGRADE`/`DRIFT`/`MISSING`/`PRUNE` verdicts + `machinery-version`; model bindings force-stamp **and missing registry rows insert** into existing satellites; `prune_dirs` now retires a **folder** (a derived skill set could never delete one); `wiki-refresh.yml` is transportable | Satellite-side adoption is unproven in the field (no production satellite audited). |
| 4 | **Wiki structure & rules** | A− | Hub-and-spoke; unified `format-version: 1`; `.wiki/rules` governance (incl. `claims.md`); `[UNCATALOGUED]`/`[UNINDEXED]` gates | Ground the remaining core slots that describe real artefacts (`06-directory-structure`). The OKF bridge is gone; interop is prose now (a disclosed capability reduction, not a maturity claim). |
| 5 | **Wiki self-maintenance** | C | 16 Grounded Claims; `#symbol` resolution + drift semantics; secret-free scheduled `wiki-drift` issue; `wiki_claims.py coverage` keeps the code-graph gate alive. **Re-scored from B−**: its cited evidence was `wiki_okf.py import`, retired in W8.1 | **No auto-refresh PR** (deliberate no-secret trade-off — see T2-E2.02); per-symbol hashing still a `ponytail:` ceiling. |
| 6 | **Template hygiene** | B+ | `README` product page; `LICENSE` (MIT); `CHANGELOG` + track mapping; `CONTRIBUTING`/`SECURITY`/CoC; `.github` templates + `release.yml`; `v1.0.0` tag; worked example | History hygiene (commit/push cadence); optional GitHub Pages (the generated graph it would host is retired). |
| 7 | **Machinery surface budget** | B | **Measured and reported**: `scripts/rule_fanout.py` prints per registered rule the raw restatement count and the count that omits the canonical home, on one declared metric over the **machinery surface** (`.wiki/**`, `docs/**`, `.github/**` and history are outside the walk by construction); the registry is `.devops/rules/surface-budget.md`; the reduction is recorded below (59 unauthorised sites → 2, 4-5 authored homes per rule → 1 canon + cited surfaces); an optional `agreement:` section flags a declared token missing from a surface that must carry it. The residual two unauthorised `auto-clear` sites were reworded out of `parcel.agent.md` and `ptp-parcel-fast.subagent.md` (they cite the contract instead of restating it), so the report now reads **0 unauthorised**. Gate cost is baselined and trending flat: `check-utf8-agents.ps1` 18.4 s → 0.57 s, no gate over 5 s except the deliberate `-SelfTest` (~20 s). **Not acted on automatically** — the report is report-only by design and a human reads it | A recurring re-derivation job (the deferred W4) would move this to A−; so would a `version-history` length cap (W3). Until then the trend is re-derived by hand at this register's own trigger |

## Assessment History

| Date | Axis 1 Planning | Axis 2 Governance | Axis 3 Transport | Axis 4 Wiki rules | Axis 5 Self-maint. | Axis 6 Hygiene | Axis 7 Surface budget | Trigger |
|---|---|---|---|---|---|---|---|---|
| 2026-09-11 (baseline) | A− | A | A− | B+ | D | D | — | Initial template review |
| 2026-09-11 (after hygiene) | A− | A | A− | A− | C | B+ | — | T2-E1 / T3-E1 hygiene & wiki-parity work |
| 2026-09-11 | A− | A+ | A | A− | B− | B+ | — | T2-E2.01 grounding + T2-E2.02 refresh automation + OKF hardening (machinery 31) |
| 2026-09-13 | A− | A+ | A | A− | B− | B+ | — | Parcel-Fast locked preset — second orchestrator, structurally single-agent (machinery 37) |
| 2026-09-13 | A− | A+ | A | A− | B− | B+ | — | Sprint batch runner (38) + registry-canonical bindings (39) + pre-satellite-sync audit tidy-up: registry-row insertion, prune/UTF-8 guard coverage, gate-contract reconciliation (40) |
| 2026-09-14 | A− | A+ | A | A− | B− | B+ | — | Sync transport completeness: missing `agent.<key>` insertion + `template-plan.md` portability (41) + Chunked Write Discipline (42) + Knowledge Capture second destination & machinery/process lessons register (43) — grades reassessed, unchanged |
| 2026-09-17 (now) | A− | **A** | A | A− | **C** | B+ | **B** | `T1-E4.01` machinery surface budget (W0-W8; machinery 56). **Schema change:** Axis 7 added as a seventh column — earlier rows are backfilled `—` because the axis did not exist when they were graded; no earlier grade is altered. **Axis 2 re-scored A+ → A:** two assertions were removed with their subjects — the **OKF export/import round-trip parity** and the **visualizer freshness** check. The frontmatter-YAML assertion was **kept**, re-pointed at the live `.wiki/**` corpus as its own dependency-free step, so it survived the tooling. **Axis 5 re-scored B− → C:** its cited evidence was `wiki_okf.py import`, retired in W8.1. **Axis 7 baselined from the W1 report on the machinery surface:** unauthorised restatement sites per registered rule fell from **59 to 2** across the six registered rules (raw `sites` 5/21/15/12/6/6 → 5/20/14/11/6/5), the two god-scripts left the Kill List (995 → 485 and 485 → 60 lines), and gate cost went 18.4 s → 0.57 s on the default live-surface scan |

| 2026-09-17 (principles) | A− | A | A | A− | C | B+ | B | Operating Principles codified — new root `OPERATING-PRINCIPLES.md` (goal → principal instrument → supporting instruments), replacing the "Two jobs" peer framing; two surface-budget rows (`operating-principles`, `cache-first`) and a report-only `agreement:` section in `rule_fanout.py`, plus the `auto-clear` residual reworded to **0 unauthorised** (machinery 57). Grades unchanged; no axis graded differently. |

## Method

- **Trigger.** Reassess after any machinery release that changes an axis (see [`../logs/version-history.md`](../logs/version-history.md)), or on request.
- **Evidence rule.** A grade changes only when a referenced artefact changes — never on assertion.
- **Append, don't rewrite.** Add a dated row to the history; update the *Now* table in place (it is the only moving part).
- **Hand-off.** Any gap that becomes work is promoted to the backlog via [`backlog-index.md`](./backlog-index.md); this register tracks maturity, it does not queue work.

## See Also

- [`OPERATING-PRINCIPLES.md`](../../OPERATING-PRINCIPLES.md) — the goal and the instruments that serve it
- [`README.md`](../../README.md) — the product page and quickstart
- [`AGENTS.md`](../../AGENTS.md) — the agent entry point
- [`backlog-index.md`](./backlog-index.md) — the work queue
- [`../logs/version-history.md`](../logs/version-history.md) — machinery releases behind each grade

---

*Last reviewed 2026-09-17.*
