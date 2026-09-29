---
title: Template Maturity
tags: [devops, maturity, assessment, roadmap, governance]
status: active
owner: Wiki Owner
last-reviewed: 2026-09-29
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

## Scorecard (Now — 2026-09-29)

| # | Axis | Grade | Evidence | Next lever |
|---|---|---|---|---|
| 1 | **Planning & execution** | A | 10-phase parcel pipeline; Gates A–D; `MULTI`/`SINGLE` topology; `AUTO`/`USER-MANAGED` modes; **locked orchestrator presets** (`parcel` = `ask`; `parcel-sprint` = locked batch host, `task` narrowed to exactly its per-plan runner); a **batch host** (`parcel-sprint` / `@sprint-run` — in-place serial execution, batched Gate D, Strict Context Isolation exception) spawning the subagent-only `ptp-parcel-fast`; deterministic `PHASE_5_REVISION` loop; skill-enforced agent embeds; Sprint 10's **owner loop** (owner-voice `stories:` row → criteria trace, user-acceptance walk at close, stakeholder business report); **Post-2026-09-23 evidence:** the `stories:` row's commit-boundary gate (machinery 73 — this axis's named lever, discharged), `MICRO` topology (row 75, Sprint 11), Phase 9 suite-scope discipline (row 79, Sprint 12), Sprint 13's completions (rows 84-89), gate-invocation hygiene plus the close-out/green-stamp checkers (rows 83, 84, 87) | Nothing known — the named gap (the unguarded `stories:` row) closed at machinery 73; any further change is scope, not maturity. |
| 2 | **Deterministic governance** | A | `check-parcel-prefix` (PREFIX-LOCKED; live + seed registry, seed config, binding-file coverage), `check-utf8-agents` (agents, skills, rules, seeds, wiki, docs — **~32× faster** since W7 and no longer blind at EOF), `wiki_lint`, `wiki_claims` (symbol resolution + the moved `coverage` gate), machinery-version discipline, sync `-SelfTest` (now also proves `prune_dirs`), CI + a dependency-free `.wiki/**` frontmatter-YAML parse, `wiki-refresh` drift job. **Re-scored down from A+**: two assertions left with their subjects (see the 2026-09-17 history row); post-2026-09-23 the prose-only invariants gained checkers — the claim-time write-set witness (row 80), the enumerated manual green baseline (86), gate-invocation hygiene (83), the close-out CI-read checker (84) and `closeout_check.py --stamp` (87) | Nothing known. The two removed assertions are recorded, not replaced — the invariants they guarded have no surviving subject. |
| 3 | **Transportability** | A | `sync-manifest.yaml` + push/pull + per-item `CURRENT`/`UPGRADE`/`DRIFT`/`MISSING`/`PRUNE` verdicts + `machinery-version`; missing registry rows **and** missing `agent` entries insert into existing satellites; any model a satellite carries is **stripped** (no agent declares a model since machinery 67 — the earlier "force-stamp" wording here was retired by the 2026-09-23 audit); `prune_dirs` now retires a **folder** (a derived skill set could never delete one); `wiki-refresh.yml` is transportable; ordering-aware transport + the CORE profile shipped (rows 73, 75), the sync engine split (85), and the **2026-09-24 GRID-Link field audit** — first production-satellite evidence: zero DRIFT across the portable surface | The one production satellite (GRID-Link) is audited but 5-6 releases behind — 13 skills, counter divergence, CI gates not transported; a pull onto this release is the next field proof. |
| 4 | **Wiki structure & rules** | A− | Hub-and-spoke; unified `format-version: 1`; `.wiki/rules` governance (incl. `claims.md`); `[UNCATALOGUED]`/`[UNINDEXED]` gates; the **wiki honesty pass** (row 86, `T2-E2.05`) — 14 app-facing core slots disclosed as `status: template`, a hub `Status` column + legend, four indexes trimmed — so seed text is never presented as curated truth | Ground the remaining core slots that describe real artefacts (`06-directory-structure`). The OKF bridge is gone; interop is prose now (a disclosed capability reduction, not a maturity claim). |
| 5 | **Wiki self-maintenance** | C | 16 Grounded Claims; `#symbol` resolution + drift semantics; secret-free scheduled `wiki-drift` issue; `wiki_claims.py coverage` keeps the code-graph gate alive; first live field evidence — the 2026-09-24 GRID-Link audit ran the claims gates green against a real 387-file src tree (coverage 387/387, check 0 stale). **Re-scored from B−**: its cited evidence was `wiki_okf.py import`, retired in W8.1 | **No auto-refresh PR** (deliberate no-secret trade-off — see T2-E2.02); per-symbol hashing still a `ponytail:` ceiling. |
| 6 | **Template hygiene** | B+ | `README` product page; `LICENSE` (MIT); `CHANGELOG` + track mapping; `CONTRIBUTING`/`SECURITY`/CoC; `.github` templates + `release.yml`; `v1.0.0` tag; worked example; **v1.1.0 release line closed** (`CHANGELOG.md` `[Unreleased]` → `[v1.1.0]`; the tag itself is operator-executed after the release-commit gate pass) plus the README/HOW-TO truth sweep | History hygiene (commit/push cadence); optional GitHub Pages (the generated graph it would host is retired). |
| 7 | **Machinery surface budget** | B | **Measured and reported**: `scripts/rule_fanout.py` prints per registered rule the raw restatement count and the count that omits the canonical home, on one declared metric over the **machinery surface** (`.wiki/**`, `docs/**`, `.github/**` and history are outside the walk by construction); the registry is `.devops/rules/surface-budget.md`; the reduction is recorded below (59 unauthorised sites → 2, 4-5 authored homes per rule → 1 canon + cited surfaces); an optional `agreement:` section flags a declared token missing from a surface that must carry it. The residual two unauthorised `auto-clear` sites were reworded out of `parcel.agent.md` and `ptp-parcel-fast.subagent.md` (they cite the contract instead of restating it), so the report now reads **0 unauthorised**. Gate cost is baselined and trending flat: `check-utf8-agents.ps1` 18.4 s → 0.57 s, no gate over 5 s except the deliberate `-SelfTest` (~20 s); **first measured run baseline** recorded in § *Cost Baseline (v1.1.0 — 2026-09-29)* below — per-gate wall-clock and plan-file read cost measured from real runs, token cells carrying explicit unavailability notes (never estimates) — re-derived by hand at this release per this register's trigger. **Not acted on automatically** — the report is report-only by design and a human reads it | A recurring re-derivation job (the deferred W4) would move this to A−; so would a `version-history` length cap (W3). Until then the trend is re-derived by hand at this register's own trigger |

## Cost Baseline (v1.1.0 — 2026-09-29)

First measured cost baseline for running the template — hand-recorded from each metric's named source: **no script, no dashboard, no gate**. Every cell is a sourced number or a durable `not available — <named missing source>` note; never an estimate (`process-lessons.md` 2026-09-03 / 2026-09-16; Q1(a) per-metric fallback). Canonical pair: this run (manual `MULTI`) and the `T1-E5.03` batch run (`AUTO` + `SINGLE`). This run's wall-clock and token cells were closed by the Phase 9 second touch (2026-09-29).

| Metric | This run (manual `MULTI`) | `T1-E5.03` run (`AUTO` + `SINGLE`) | Source |
|---|---|---|---|
| Tokens per phase-group | not available — no session export supplied | not available — no session export supplied | Operator runtime session export — requested at Group D 2026-09-29 and not supplied this session; Q1(a) fallback, never an estimate. This run's own column is collected by the orchestrator at Gate D. |
| Plan-file read cost per cold start | 102,412 bytes / 705 lines (measured at Phase 8, 2026-09-29) | 85,127 bytes / 585 lines | `(Get-Item <path>).Length` + `(Get-Content <path>).Count` on this tree: this plan vs `.devops/archive/t1-e5.03-plan-record-size-lever-plan.md` |
| Gate wall-clock per gate | All 14 `validate.yml` gates timed once at Phase 9 (2026-09-29), total ≈ 92 s: prefix 0.49 s · utf8 0.36 s · wiki_lint 0.28 s · coverage 0.10 s · claims 0.12 s · frontmatter-YAML 0.16 s · JSON 0.08 s · sync `-SelfTest` 55.44 s · sprint-eligible 4.38 s (35 tests) · write-set 1.93 s (14) · closeout 18.76 s (27) · utf8 fixtures 9.26 s (14) · coverage fixtures 0.63 s (5) · version-discipline 0.13 s | `test_sprint_eligible.py` 4.0 s; `test_write_set_check.py` 1.7 s (2 of 13 Phase 9 evidence rows); other 11 gates — not available — run records hold no gate timings | This run's Phase 9 evidence table (each command wrapped in `Measure-Command`, one-shot); `.devops/archive/t1-e5.03-plan-record-size-lever-plan.md:459-460` (partial). The run reports (`.opencode/plans/run-sprint-13/sprint_run_report*.md`) carry step counts and exit codes only |

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

| 2026-09-23 (core audit) | A− | A | A | A− | C | B+ | B | Core functionality + core principle audit, post–Sprint 10: every `validate.yml` gate green (prefix PASS×9 / NOMODEL×11, utf8 182 clean, lint 0, claims 0 stale, 62 fixtures OK, sync `-SelfTest` OK). **Truth corrections, not grade changes:** the Axis 3 "force-stamp" evidence and the same wording in `README.md` / `.devops/templates/SATELLITE-BOOTSTRAP.md` were live leftovers of the machinery-67 inversion — swept by concept vocabulary, not one spelling (`process-lessons.md`: reversal sweeps must match the idea); the `claim_status` registry gained its `sync-architecture` surface + pointer, so the report reads **0 unauthorised across 8 rules** again; Axis 1 now names `T1-E3.18` as its lever. Grades unchanged; machinery 57 → 72 since the last row (14 releases, `version-history.md`). |

| 2026-09-29 (v1.1.0 release) | **A** | A | A | A− | C | B+ | B | Trigger: machinery 73 → 89 plus the v1.1.0 release (`T3-E1.05` — Sprint 13's closing parcel; `@sprint-close` next). **Axis 1 re-scored A− → A:** its named lever (the unguarded `stories:` row) shipped at machinery 73 (row 73); evidence refreshed across Sprint 11 close (rows 73-76 — `MICRO` topology is row 75), Sprint 12 close (rows 77-79 — test batching is row 79), Sprint 13's eight batch completions (rows 84-89: close-out checker, sync split + block-list fix, manual claim baseline, wiki honesty, green-stamp checker, hot-prose single-sourcing, record-size lever — this release closes the sprint's ninth plan), and the 2026-09-24 GRID-Link field audit (Axis 3/5 evidence). Axes 2-7: evidence cells refreshed, grades unchanged; Axis 3's field-adoption lever replaced (audited, now behind). **Baseline recorded** in § Cost Baseline — cited here, never copied (Q2(a)): wall-clock and plan-file read cost measured; token cells carry explicit `not available — no session export supplied` notes (export requested, declined this session — never an estimate). |

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

*Last reviewed 2026-09-29.*
