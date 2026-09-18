---
type: "process"
name: "Code Quality & Refactoring Register"
status: "active"
description: "Living audit of code complexity, coupling, and test health. Process-driven — items enter here from end-of-cycle checks, not roadmap planning."
last_scan: "2026-09-18"
---
# 🔧 Pass the Parcel — Code Quality & Refactoring Register

> **What this is:** A living audit of complexity debt across the workspace. Items here are NOT backlog features — they are maintenance work triggered by a process. Feature work goes in [backlog-index.md](./backlog-index.md)'s Triage Panel; refactoring goes here.

> **Adopted 2026-09-16** from [`REFACTORING.template.md`](../templates/REFACTORING.template.md) at `T1-E3.06` G3 — the register had no live copy, so `@sprint-close`'s promotion step and `@sprint-plan`'s Kill List source both pointed at nothing. This repo has no `.devops/backlog/TRIAGE.md`; the Triage Panel lives in [backlog-index.md](./backlog-index.md).

---

## 🔄 The Process

Refactoring items enter this register through three triggers:

| Trigger | When | Who |
|---------|------|-----|
| **End-of-parcel check** | After each parcel wrap-up, scan the files it touched. If any exceeds the thresholds below, log an item here. | `@agent-wrap-up` skill |
| **Sprint-close scan** | At the end of every sprint, `@sprint-close` § 2 runs the scanner across the files touched that sprint and refreshes the Kill List. This is the primary rhythm. | `@sprint-close` skill |
| **CI signal** | A flaky gate, OOM, or lint regression is detected. Log as an infrastructure item. | Any session |

### Thresholds for Flagging

| Metric | Warning | Critical | Action |
|--------|---------|----------|--------|
| CCN (per function) | >15 | >25 | Extract a helper / split the function / consolidate branches |
| File lines | >400 | >800 | Decompose into focused modules |
| Import count (CBO proxy) | >12 | >20 | Reduce coupling, extract shared logic |
| Export count (god utility) | >8 | >15 | Split into focused modules |
| Test file mounts | >3 | >5 | Isolation-first refactor |

When a file crosses a threshold, add it to the Kill List below with a one-line note on *why* and *what changed*.

> **Scan scope is app source *and* machinery.** `scripts/spaghetti-monster-scan.cjs` walks `src/` plus `scripts/`, `.devops/skills/`, `.devops/agents/`, `.devops/templates/`. This workspace has **no `src/` tree** — that root prints a one-line skip and the machinery roots are scanned under these same thresholds. An absent root is a clean no-op, never a crash and never a silent skip.

---

## 📊 Current Scan Results

### First machinery scan — 2026-09-16 (all roots)

```
node scripts/spaghetti-monster-scan.cjs
no src/ tree in this workspace — skipping (nothing to scan there)
=== TOP 40 SOURCE+TEST RISK (unified kill list) ===
roots: src/ (app) + scripts/, .devops/skills/, .devops/agents/, .devops/templates/ (machinery)
non-ECMAScript rows (`imp`/`fn`/`CCN` shown as `-`) are ranked on line count only.

rank | source                                                  | lines | imp | fn | CCN(h) | test      | risk
   1 | scripts\spaghetti-monster-scan.cjs                      |   254 |   2 |   8 |     79 | (no test) | 49.0
   2 | scripts\sync-architecture.ps1                           |   995 |   - |   - |      - | (no test) | 13.9
   3 | .devops\skills\app-vision-north-star\SKILL.md           |   634 |   - |   - |      - | (no test) |  6.7
   4 | scripts\wiki_lint.py                                    |   486 |   - |   - |      - | (no test) |  3.7
   5 | scripts\check-parcel-prefix.ps1                         |   370 |   - |   - |      - | (no test) |  1.4
```

Two caveats, both load-bearing when reading this table:

- **`CCN(h)` is a regex heuristic, not an AST count.** It counts `if (`/`case`/`for (`/`&&`/`||`/`?`/`??` occurrences, including those *inside regex literals* — so it is inflated for regex-heavy files (rank 1 is the scanner itself). Treat line count as the reliable column and the CCN figure as a pointer, not a measurement.
- **`-` means "not measured", not "clean".** Non-ECMAScript files (`.ps1`/`.py`/`.md`) are ranked on line count only; the CCN/import/export regexes are ECMAScript-shaped and would report prose noise as complexity.

### Kill List (ranked by risk × effort)

| File | Lines | CCN(h) | Imports | Status | Plan | Flagged by |
|------|-------|--------|---------|--------|------|-----------|
| `scripts/sync-architecture.ps1` | 995 | — | — | ✅ RESOLVED | `T1-E4.01` W6 | First machinery scan, 2026-09-16 (`T1-E3.06` G3) — >800 critical: 2.5× the line threshold. Now **497** lines (485 at W6; +12 when W8.1 added the `prune_dirs` capability); the engine moved to five dot-sourced `scripts/lib/` modules |
| `scripts/spaghetti-monster-scan.cjs` | 254 | 79 | 2 | 🔴 OPEN | — | First machinery scan, 2026-09-16 — CCN(h) inflated by regex literals; the file is branch-dense regardless |
| `.devops/skills/app-vision-north-star/SKILL.md` | 634 | — | — | ✅ RESOLVED | `T1-E4.01` W8.1 | Retired — product/strategy authoring with no operational home; the skill folder is gone |
| `scripts/wiki_lint.py` | 486 | — | — | ✅ RESOLVED | `T1-E4.01` W6 | First machinery scan, 2026-09-16 — >400 warn. Now **60** lines; readers/primitives in `wiki_lint_core.py`, checks in `wiki_lint_checks.py` |
| `scripts/check-parcel-prefix.ps1` | 370 | — | — | 🟡 PLANNED | [`T1-E2.02`](./t1-e2.02-check-parcel-prefix-split-backlog.md) | Pre-existing (`T1-E2.02`); under the 400-line threshold, parked on branch-count grounds |
| `scripts/wiki_claims.py` | 484 | — | — | 🔴 OPEN | — | Sprint 9 close, 2026-09-18 — crossed >400 warn (coverage subcommand growth); was WATCH |
| `scripts/sprint_eligible.py` | 463 | — | — | 🔴 OPEN | — | Sprint 9 close, 2026-09-18 — new file above warn (predicate + lanes + complexity) |
| `scripts/wiki_lint_checks.py` | 423 | — | — | ⚪ WATCH | — | Sprint 9 close, 2026-09-18 — split product above warn; trend only |
| `scripts/tests/test_sprint_eligible.py` | 410 | — | — | ⚪ WATCH | — | Sprint 9 close, 2026-09-18 — fixture growth 18→29; test, not product |
| `scripts/sync-architecture.ps1` | 561 | — | — | ⚪ WATCH | `T1-E4.01` W6 | Sprint 9 close, 2026-09-18 — regrew 497→561 (+T1-E2.07 prune/mask/stamp); split precedent stands, trend only |

**Status legend:** 🔴 OPEN (flagged, no plan) · 🟡 PLANNED (plan file exists) · 🔄 IN PROGRESS · ✅ RESOLVED (move to the Completed table) · ⚪ WATCH (below threshold, tracked for trend).

> **Not a duplicate of the backlog.** Parked plan `T1-E2.02` (split the `check-parcel-prefix.ps1` god-script) is a *plan*, not a backlog feature, and is linked above as this row's disposition. No row here creates a feature-backlog item — per `@sprint-close` § 2, the scan's output feeds this register only.

---

## ✅ Completed Refactors

*Items that were flagged and resolved. Kept for trend visibility.*

| Date | File(s) | What was done | Source |
|------|---------|---------------|--------|
| 2026-09-17 | `scripts/sync-architecture.ps1` (995 → 485 at W6; 497 after W8.1) | Decomposed into five dot-sourced `scripts/lib/` modules (manifest, bindings, prune, prefix, verify). CLI, sync path and `-SelfTest` body unchanged; four CLI modes proven line-for-line against pre-split goldens | `T1-E4.01` W6 |
| 2026-09-17 | `scripts/wiki_lint.py` (485 → 60) | Split into `wiki_lint_core.py` (readers, primitives, constants) and `wiki_lint_checks.py` (the ten steps + `--fix`), over an explicit `LintContext`. Import surface and all eleven re-exported names preserved; `--fix` stdout **and** mutated-file bytes identical | `T1-E4.01` W6 |
| 2026-09-17 | `.devops/skills/app-vision-north-star/` (634) | Retired whole (with three sibling skills). No successor needed — the roadmap artefacts it produced are authored directly | `T1-E4.01` W8.1 |

---

## 🧪 Test Infrastructure Health

*Update at each sprint close.*

| Metric | Value | Last Checked |
|--------|-------|-------------|
| Total test files | 0 — no application test suite (no `package.json` in this template repo) | 2026-09-16 |
| Total tests | 0 | 2026-09-16 |
| Full suite pass rate | n/a — see the deterministic gate set below | 2026-09-16 |
| Lint errors | 0 (`python scripts/wiki_lint.py --quiet`) | 2026-09-16 |
| Lint warnings | 0 | 2026-09-16 |

The workspace's executable contract is its **deterministic gate set**, not a unit-test suite: `scripts/check-parcel-prefix.ps1`, `scripts/check-utf8-agents.ps1`, `scripts/wiki_lint.py`, `scripts/wiki_claims.py check`, `scripts/sync-architecture.ps1 -SelfTest` (all wired into `.github/workflows/validate.yml`). A red gate is this register's **CI signal** trigger.

### Gate cost (dated rows — no deterministic gate > 5 s at template scale)

| Gate | Wall clock | Files | Note | Date |
|------|-----------|-------|------|------|
| `check-utf8-agents.ps1` (default) | **0.57 s** | 208 | The figure is the **default live-surface scan**; `.devops/archive` is excluded (immutable history, ~half the scanned bytes, unactionable verdict). `-All` is a **manual escape hatch with no scheduled run** — nothing in `validate.yml`, no hook and no job invokes it — so the default figure is *not* full-surface coverage. | 2026-09-17 |
| `check-utf8-agents.ps1` (`-All`) | **0.58 s** | 231 | Reproduces the former whole-tree scan on demand; its stdout is byte-identical to the pre-W7 capture at the 231-file count. | 2026-09-17 |
| `check-parcel-prefix.ps1` | ~1 s | 11 agents | Model-registry + prefix + seed parity. | 2026-09-17 |
| `wiki_lint.py --quiet` | ~1 s | .wiki tree | Exit `0`. | 2026-09-17 |
| `wiki_claims.py check` | ~1 s | .wiki tree | `0 stale, all grounded sources present`. | 2026-09-17 |
| `sync-architecture.ps1 -SelfTest` | ~20 s | full portable surface | Deliberately heavy: it materialises a throwaway satellite end-to-end and asserts the manifest mirror. The one gate above the 5 s target, by design and by construction — recorded rather than hidden. | 2026-09-17 |

> **Pre-W7 baseline (2026-09-16, 231 files): 13.8 s**, rising past 3 minutes at a satellite's 701 files, because the guard was a hand-rolled interpreted per-byte loop with the loop bound `$i -lt $bytes.Length - 2`. It is now one Latin-1 decode plus one compiled regex alternation per file (T1-E4.01, W7) — **~32× faster** — and the bound is gone, which also fixed a false negative: a file whose last two bytes were `C3 A2` was never scanned.

### Remaining Test Work

| Item | Status | Note |
|------|--------|------|
| Machinery fixture tests | 🟡 PARTIAL | **Closed for four scripts** by T1-E4.01: `scripts/tests/test_sprint_eligible.py` (29 tests), `test_rule_fanout.py` (13), `test_check_utf8_agents.py` (10), `test_wiki_claims_coverage.py` — all stdlib `unittest`, driving the real CLI over temp trees. Still open for `scripts/sync-architecture.ps1` beyond `-SelfTest`, `scripts/wiki_lint.py` and `scripts/check-parcel-prefix.ps1`. |

---

## 🗑️ Dead Code Candidates

*Unwired but tested library code awaiting disposition.*

| File(s) | Orphaned by | Decision needed | Linked item |
|---------|------------|-----------------|-------------|
| — | — | *(none — this scan is metrics-only; dead-code detection is `@spaghetti-monster`'s job, run on demand)* | — |

---

## 📐 Structural Notes

- **This file is process-driven, not roadmap-driven.** Items appear here because code got complex, not because someone planned a feature.
- **Plans move backlog → sprint queue → `.devops/plans/` → archive.** This register tracks them but does not duplicate their content.
- **The Kill List is ranked by risk × effort.** High-risk files touched often get priority over rarely-touched internals.
- **Full scans run at sprint close** via `@sprint-close` § 2, which invokes `scripts/spaghetti-monster-scan.cjs` across the sprint's touched scope; its output feeds the Current Scan Results section above.
- **When in doubt about whether something belongs here vs the backlog:** if it changes user-visible behavior, it is a feature (backlog). If it only changes internal structure, it is refactoring (here).
- **The lane is opt-in per repo.** A satellite without this file is not broken — `@sprint-close` § 2 records the scan findings in the retro instead of promoting them, and says so. See `.devops/templates/SATELLITE-BOOTSTRAP.md` for the seed.
