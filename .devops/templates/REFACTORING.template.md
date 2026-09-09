<!--
type: template
version: 1
updated: 2026-09-09

REFACTORING.template.md — seed for a satellite's code-quality register.
Copy to .devops/backlog/REFACTORING.md. The scan tables start empty; they are populated
by @spaghetti-monster runs and @sprint-close scans. This register lives OUTSIDE the feature
backlog on purpose — refactoring is process-driven maintenance, not roadmap work.
-->
---
type: "process"
name: "Code Quality & Refactoring Register"
status: "active"
description: "Living audit of code complexity, coupling, and test health. Process-driven — items enter here from end-of-cycle checks, not roadmap planning."
last_scan: "none"
---
# 🔧 {Project} — Code Quality & Refactoring Register

> **What this is:** A living audit of technical debt in the codebase. Items here are NOT backlog features — they're maintenance work triggered by a process (see [TRIAGE.md § Refactoring Trigger](./TRIAGE.md#refactoring-trigger)). Feature work goes in [backlog-index.md](./backlog-index.md); refactoring goes here.

---

## 🔄 The Process

Refactoring items enter this register through three triggers:

| Trigger | When | Who |
|---------|------|-----|
| **End-of-parcel check** | After each parcel wrap-up (Phase 10), scan touched files. If any exceeds thresholds below, log an item here. | `@agent-wrap-up` skill |
| **Sprint-close scan** | At the end of every sprint, `@sprint-close` runs a spaghetti-monster scan across all files touched that sprint and refreshes the Kill List. This is the primary rhythm. | `@sprint-close` skill |
| **CI signal** | Vitest OOM, flaky tests, or lint regression detected. Log as infrastructure item. | Any session |

### Thresholds for Flagging

| Metric | Warning | Critical | Action |
|--------|---------|----------|--------|
| AST CCN (per function) | >15 | >25 | Extract hook / split render / consolidate branches |
| File lines | >400 | >800 | Decompose into sub-components + hooks |
| Import count (CBO proxy) | >12 | >20 | Reduce coupling, extract shared logic |
| Export count (god utility) | >8 | >15 | Split into focused modules |
| Test file mounts | >3 | >5 | Isolation-first refactor per T10 pattern |

When a file crosses a threshold, add it to the Kill List below with a one-line note on *why* and *what changed*.

---

## 📊 Current Scan Results

*Run `scripts/spaghetti-monster-scan.cjs` (or `@spaghetti-monster`) scoped to a target area, then paste the ranked results here. Empty until the first scan.*

### Kill List (ranked by risk × effort)

| File | Lines | AST CCN | Imports | Status | Plan | Flagged by |
|------|-------|---------|---------|--------|------|-----------|
| — | — | — | — | *(empty)* | — | — |

**Status legend:** 🔴 OPEN (flagged, no plan) · 🟡 PLANNED (plan file exists) · 🔄 IN PROGRESS · ✅ RESOLVED (move to Completed table).

---

## ✅ Completed Refactors

*Items that were flagged and resolved. Kept for trend visibility.*

| Date | File(s) | What was done | Source |
|------|---------|---------------|--------|
| — | — | *(empty)* | — |

---

## 🧪 Test Infrastructure Health

*Update at each sprint close from the full-suite run.*

| Metric | Value | Last Checked |
|--------|-------|-------------|
| Total test files | — | — |
| Total tests | — | — |
| Full suite pass rate | — | — |
| Lint errors | — | — |
| Lint warnings | — | — |

### Remaining Test Work

| Item | Status | Note |
|------|--------|------|
| — | — | *(empty)* |

---

## 🗑️ Dead Code Candidates

*Unwired but tested library code awaiting disposition.*

| File(s) | Orphaned by | Decision needed | Linked item |
|---------|------------|-----------------|-------------|
| — | — | *(empty)* | — |

---

## 📋 Stabilisation Sprint

*When the Kill List grows large enough to warrant a dedicated cycle, run it as a **stabilisation sprint** via the normal agile rhythm: `@sprint-plan` (declare it a stabilisation sprint so Kill-List items are allowed to drive scope) → execute the top-N refactors as parcels → `@sprint-close` (retro + re-scan). The sprint's `plan.md`/`retro.md` capture the before→after metrics. See [SPRINTS.md](./SPRINTS.md).*

---

## 📐 Structural Notes

- **This file is process-driven, not roadmap-driven.** Items appear here because code got complex, not because someone planned a feature.
- **Plans stay in `.devops/plans/`** until executed, then move to archive. This register tracks them but doesn't duplicate their content.
- **The Kill List is ranked by risk × effort.** High-risk files users touch daily get priority over rarely-touched internals.
- **Full scans run at sprint close** via `@sprint-close`, which invokes `scripts/spaghetti-monster-scan.cjs` across the sprint's touched scope. Output feeds directly into the Current Scan Results section.
- **When in doubt about whether something belongs here vs the backlog:** if it changes user-visible behavior, it's a feature (backlog). If it only changes internal structure, it's refactoring (here).
