---
title: "GRID-Link Field Audit (2026-09-24)"
tags: [devops, audits, field-audit, transport, satellite]
status: complete
owner: Wiki Owner
last-reviewed: 2026-09-24
related-to: [../backlog/backlog-index.md, ../backlog/t1-parcel-pipeline-machinery-backlog.md, ../backlog/t3-template-distribution-backlog.md, ../backlog/MATURITY.md, ../logs/agent-changelog.md]
---

# GRID-Link Field Audit (2026-09-24)

> **What this is.** The first audit of a production satellite operating the parcel machinery — GRID-Link (Firebase/Supabase/Vite app; 740 `src` files + 2,247 `functions` files; Sprint 14 in flight). Operator-directed and read-only throughout; it opens the evidence loop `MATURITY.md` Axis 3 had marked *"unproven in the field"*. Every finding is measured; the parcels it promoted are linked under **Promoted Work**. The satellite was **mid-parcel during measurement** (`plan: T19-E4.11` committed the same day), so counts are a snapshot.

## Method

| # | Measurement | How |
|---|---|---|
| 1 | Machinery fidelity + currency | `scripts/sync-architecture.ps1 -Check` — read-only verdict table, template → satellite |
| 2 | Scale of real use | `.devops/` inventory: archived plans, closed sprints, commits, changelog span |
| 3 | Claims gates vs real code | The satellite's own `wiki_claims.py coverage` + `check` |
| 4 | Counter discipline | Both `sync-manifest.yaml` values + both release logs + the `-Check` `meta` verdict |
| 5 | Skill usage | Simple-match grep of all 36 skill slugs over a 439-file corpus (archive + sprints + plans + logs) |
| 6 | Small-change demand | Archive greps: `N/A — SINGLE` markers, `ad-hoc`, `AUTO + SINGLE` |
| 7 | CI gate transport | `.github/workflows/ci.yml` inspection vs the template's `validate.yml` |
| 8 | Debris + deviations | Filesystem inspection (`.ptp-source`, logs, root files, wiki cross-references) |

## Findings

| # | Finding | Evidence |
|---|---|---|
| 1 | **Faithful carrier, ~5-6 releases behind.** Zero local drift on the portable surface; the satellite simply has not pulled since the ~machinery-63-66 era. | `-Check` 2026-09-24: **0 DRIFT** across 36 skills / 11 agents / rules / scripts; **13 skills UPGRADE** (`sprint-close` v8→v12, `pass-the-parcel` v24→v26, `agent-wrap-up` v16→v17 …); every `portable_dirs` entry UPGRADE on the version mismatch. |
| 2 | **Real production use at scale** — a heavier user of the machinery than the template itself. | **346 archived plans, 13 closed sprints, 639 commits, Sprint 14 in flight** (template: 10 sprints). |
| 3 | **Claims gates pass against a real app tree** — first live evidence for Axis 5. | `coverage`: **387 source files, all referenced in wiki indexes** (exit 0); `check`: **0 stale** (exit 0); 171 wiki docs. The template's own coverage gate is a no-op (no `src/`). |
| 4 | **Counter divergence + equality-blind transport.** The satellite's counter has left the template's lineage, and the sync tool cannot see it. | Satellite manifest `machinery-version: 78` vs template 72; **zero** `machinery-version:` rows in the satellite's release log; `-Check` reports `meta machinery-version UPGRADE target 78 -> source 72` — an equality-only comparison cannot tell *behind* from *ahead*, so the next pull silently rewinds the counter. |
| 5 | **Measured usage: ~18 of 36 skills carry the entire pipeline.** | 439-file corpus grep: all `ptp-*` personas, both orchestrators, `sprint-run`/`plan`/`close`, `agent-wrap-up`, `wiki-writer`, `spaghetti-monster`, `test-and-deploy`, `wiki-lint`, `knowledge-capture` dominate; the two locally-added skills (`update-global-skills`, `update-workspace-skills`) never appear; conversational skills are unmeasurable this way (see Limits). |
| 6 | **Small-change demand is field-proven, not hypothetical.** | **155 of 346 archived plans (~45%) record `N/A — SINGLE` skipped-phase markers; 35 explicit ad-hoc runs.** The template itself already lands direct fixes with recorded skips (e.g. `f4bd88b`) — the light path exists in practice, unsanctioned. |
| 7 | **The deterministic CI gates stop at the template border.** | Satellite `ci.yml` is app CI only (npm lint/test/build, bundle budget, functions tests, deploy) — no prefix / UTF-8 / wiki-lint / claims gates in satellite CI; `validate.yml` is not in `portable_files`. README's *"Deterministic CI gates … on every push"* is template-side only. |
| 8 | **Local debris + doctrine deviations** (satellite-owner choices, recorded not ruled). | `.ptp-source/` contains only a nested copy of itself; `knowledge-changelog.md` still present (retired upstream); root `DESIGN.md` with **0 wiki references** while `.wiki/core/09-design-system.md` exists — two design homes; `AGENT.md`/`CLAUDE.md`/`GEMINI.md` multi-runtime entry points (a legitimate adaptation the template does not ship); `lint-output.txt` at root. |

## Field Evidence for the Design Decisions

The operator's 2026-09-24 design session (operating-principles analysis + four rulings) gains field-derived requirements from these findings:

1. **The versioning redesign gains two requirements.** (a) An **ordering-aware sync check**: target-ahead must halt-and-reconcile, never read as `UPGRADE` — finding 4 is the live instance. (b) **Separated identities**: the transport set version (template-owned, sync-stamped) vs the satellite's own app release version (never stamped by sync) — the single integer conflates them, and 78-with-zero-rows is the proof.
2. **MICRO eligibility can be calibrated from measurement** — the 35 ad-hoc runs and 155 SINGLE runs are the empirical bounds, not a guessed file-count limit (finding 6).
3. **A new gap: CI transportability** — the "deterministic guardrails" instrument is a local convention in the field; it needs a transportable form (finding 7).
4. **A new gap: pull cadence** — GRID-Link originated the Phase 9 gate-hang lesson (E3.13), the template fixed it, and the satellite is **still carrying the bug** because fixes flow downhill only on a manual pull. The feedback pathway works uphill; nothing closes the downhill side.
5. **CORE profile membership is measured** — ~18 pipeline-carrying skills vs the 34 shipped; the onboarding surface could halve with evidence, not opinion (finding 5).

## Promoted Work

Six parcels parked at intake (operator rulings locked during the 2026-09-24 design session; each plan file records them). `T1-E3.18` (the `stories:` gate) was already parked from Sprint 10 and is referenced, not duplicated.

| Code | Title | Tier | Plan |
|---|---|---|---|
| T1-E2.08 | Tiered machinery versioning + ordering-aware transport | 🟡 NEXT | [t1-e2.08-tiered-machinery-versioning-backlog.md](../backlog/t1-e2.08-tiered-machinery-versioning-backlog.md) |
| T1-E5.01 | MICRO topology — the sanctioned small-change pathway | 🟡 NEXT | [t1-e5.01-micro-topology-backlog.md](../backlog/t1-e5.01-micro-topology-backlog.md) |
| T3-E1.03 | The deterministic CI gates stop at the template border | 🟡 NEXT | [t3-e1.03-ci-gate-transportability-backlog.md](../backlog/t3-e1.03-ci-gate-transportability-backlog.md) |
| T1-E5.02 | The changelog becomes a generated index; plans are the source of truth | 🟢 LATER | [t1-e5.02-changelog-generated-index-backlog.md](../backlog/t1-e5.02-changelog-generated-index-backlog.md) |
| T1-E3.20 | The batch preset silently overrules a sprint's recorded Mode rulings | 🟢 LATER | [t1-e3.20-batch-preset-overrule-check-backlog.md](../backlog/t1-e3.20-batch-preset-overrule-check-backlog.md) |
| T3-E1.04 | CORE satellite profile — measured onboarding reduction | 🟢 LATER | [t3-e1.04-core-satellite-profile-backlog.md](../backlog/t3-e1.04-core-satellite-profile-backlog.md) |

## Operational Recommendations

1. **Pull GRID-Link before Sprint 15.** The pull delivers the claims 3-gate wrap-up (E3.14), the interrupted-run contract and the gate-hang fix (E3.13 — a bug GRID-Link itself originated), and the owner-loop surfaces. The counter rewind (78 → 72) is the cheap risk today — the satellite has no rows 73-78 to orphan — so accepting it consciously is reasonable; holding the pull until T1-E2.08's ordering check lands is the conservative alternative. Operator choice.
2. **Re-measure the counter at a quiet boundary** — the satellite was mid-parcel during this audit.
3. **Satellite-side tidy candidates** (GRID-Link owner's call, not template work): `.ptp-source` self-nested debris; `knowledge-changelog.md` (retired upstream); consolidating root `DESIGN.md` into the wiki's design home (`.wiki/core/09-design-system.md` — two homes, zero cross-links); `lint-output.txt`.
4. **MATURITY.md was not re-graded here** (method: a grade changes only when a referenced artefact changes, and reassessment is its own trigger). The next row can cite this audit as artefact evidence for **Axis 3** (first field evidence: fidelity + drift verdicts at scale) and **Axis 5** (claims gates green against a real 387-file tree).

## Measurement Limits

- **Conversational skills are unmeasurable from artifacts.** `wiki-query`, `model-routing`, `karpathy-guidelines` and the like leave no record in plans or logs; only the operator can judge them. Their CORE-profile membership stays a judgement call (T3-E1.04 open question).
- **Word contamination:** `backlog` and `knowledge-capture` mention counts are inflated by generic word use — the distinctive-slug skills are the reliable signal.
- **Usage counts measure participation in the plan record, not runtime invocations.** A skill invoked live but never named in a plan undercounts.
- **Snapshot bias:** the satellite was mid-parcel; one plan file moved between listing and scan.
- **Read-only throughout:** no satellite file was modified; the drift check is the template's own `-Check`, which writes nothing.

---

*Last reviewed 2026-09-24. Read-only audit; no satellite file was modified — the drift check is the template's own `-Check`, which writes nothing.*
