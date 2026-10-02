---
type: "core"
name: "Agent Changelog"
status: "stable"
description: "Chronological record of all AI agent actions, changes, and audits."
---

# Agent Changelog

All changes made by AI agents are tracked chronologically below.

> **This file is a thin index from 2026-09-25 forward.** One line per change, appended under `## Index` at the foot; the Why is authored once, in the plan — never re-authored here. The **pre-index narrative record** (2026-09-09 → 2026-09-25) was moved verbatim to [`../archive/agent-changelog-history.md`](../archive/agent-changelog-history.md) on 2026-09-30 so the live log stays under its 500-line guideline. `AGENTS.md` rule 5's *"last 3 entries"* are the Index's last lines.

---

## Index (2026-09-25 forward)

> **One line per change:** `- **YYYY-MM-DD** · \`CODE\` · <one-line summary> · [plan](<path relative to this file>)`. Written at wrap-up from the plan — never independently authored; the Why lives once, in the plan. Append at the end (oldest-first), so the last entries are the most recent changes (`AGENTS.md` rule 5). Entries written before 2026-09-25 live verbatim in the [pre-index narrative record](../archive/agent-changelog-history.md) — history, never retro-edited.

<!-- New index entries go here. -->
- **2026-09-25** · `T1-E3.19` · The sprint wave forecast becomes a labelled snapshot of the predicate that actually decides, not a hand-derived guess; the sprint template's two homes reconcile to one · [plan](../archive/t1-e3.19-wave-forecast-drift-plan.md)
- **2026-09-25** · `T1-E3.20` · The batch's single operator checkpoint now names mode overrules too — an advisory `mode_conflicts` key joins the MULTI-worthy fork · [plan](../archive/t1-e3.20-batch-preset-overrule-check-plan.md)
- **2026-09-25** · `T1-E5.02` · The changelog becomes a thin append-only index and the Why is authored once, in the plan · [plan](../archive/t1-e5.02-changelog-generated-index-plan.md)
- **2026-09-25** · `T3-E1.03` · The deterministic gates travel — a portable `machinery-gates.yml` runs the invariant subset in every satellite on every push · [plan](../archive/t3-e1.03-ci-gate-transportability-plan.md)
- **2026-09-25** · `T1-E5.01` · `MICRO` becomes the sanctioned third topology — a collapsed small-change record, manual-path only, with Gate B carrying the eligibility assertion · [plan](../archive/t1-e5.01-micro-topology-plan.md)
- **2026-09-25** · `T3-E1.04` · A satellite can declare `profile: CORE` and carry only the skills it uses; `FULL` stays the default, and a tiered-out skill is never reported `MISSING` · [plan](../archive/t3-e1.04-core-satellite-profile-plan.md)
- **2026-09-26** · `T1-E1.05` · `skills` is declared the V2-native flat array in the config and its seed; the sync migrates an already-bootstrapped satellite's own config to that shape, or refuses loudly rather than strip what it cannot migrate · [plan](../archive/t1-e1.05-opencode-v2-config-plan.md)
- **2026-09-27** · `T1-E2.09` · The counter's ownership carve-out (*a satellite never bumps it*) becomes the lead of its canonical home with cites on five more surfaces, the `AHEAD` halt names its commonest cause, and release row 77's missing CI trailer is repaired · [plan](../archive/t1-e2.09-machinery-counter-satellite-plan.md)
- **2026-09-27** · `T1-E3.21` · Phase 9 can declare its suite scope — partitioned commands, a `Suite scope` evidence column, the full suite consolidating at batch wrap-up / pre-push / sprint close; one canon sub-clause, seven citing surfaces · [plan](../archive/t1-e3.21-phase9-test-batching-plan.md)
- **2026-09-27** · `T1-E3.23` · Cheaper by Design — a claim-time write-set witness blocks a wrong `touches` before work starts, every new check must fail on the unfixed tree, four plan-record rules land, and review-riding becomes the default · [plan](../archive/t1-e3.23-cheaper-by-design-plan.md)
- **2026-09-27** · commit `8c21ec3` · Knowledge consolidation full audit — `18-knowledge-capture.md` halves 25 → 6 entries, `process-lessons.md` folds 13 matured rules and lands at 21, machinery 80 → 81; **resolves parked `T2-E2.04`**
- **2026-09-28** · `T1-E2.11` · The trunk goes green and the pipeline can see it — the write-guard stops trusting the host's lenient JSON parser, a failed harness child reports as failed, and wrap-up owns one honest read of the remote CI status · [plan](../archive/t1-e2.11-ci-red-on-trunk-plan.md)
- **2026-09-28** · `T1-E3.24` · Gate invocation frequency — a gate runs where its subject changes: the green stamp replaces pre-push's unconditional re-run, wrap-up machinery gates go conditional on `machinery-diff`; canon in `plan-lifecycle.md` § Gate Invocation Hygiene · [plan](../archive/t1-e3.24-gate-invocation-frequency-plan.md)
- **2026-09-28** · `T1-E2.12` · The close-out CI read gets an offline checker — `scripts/closeout_check.py` validates the three verdict literals from local git alone, the no-push window gets a recorded rule, and the Completion Note gains a `CI verdict:` field · [plan](../archive/t1-e2.12-close-out-ci-read-checker-plan.md)
- **2026-09-28** · `T1-E4.05` · The sync engine drops below the Kill List thresholds — `scripts/sync-architecture.ps1` **975 → 314** and `sync-bindings.ps1` **450 → 371** into four new `scripts/lib/` modules, behaviour proven against pre-split goldens · [plan](../archive/t1-e4.05-sync-engine-split-plan.md)
- **2026-09-28** · `T1-E2.13` · A comment line inside a `touches` block-list no longer truncates every declared path after it — reader fix plus three fixtures with the pre-fix probe observed failing · [plan](../archive/t1-e2.13-block-list-comment-truncation-plan.md)
- **2026-09-28** · `T2-E2.05` · The template wiki stops presenting app-facing seed text as curated truth — 14 core slots move to `status: template`, the hub gains a Status column and legend · [plan](../archive/t2-e2.05-wiki-v1-honesty-pass-plan.md)
- **2026-09-28** · `T1-E3.22` · The manual claim path gets the enumerated green baseline `plan-lifecycle.md` already claimed — definition sites 3 → 0, citing surfaces 0 → 5 · [plan](../archive/t1-e3.22-manual-claim-baseline-plan.md)
- **2026-09-29** · `T1-E3.25` · The green-stamp invariant gets its checker — `--stamp` assertion plus classifier, 27/27 fixtures with pre-fix probes observed failing · [plan](../archive/t1-e3.25-green-stamp-invariant-gate-plan.md)
- **2026-09-29** · `T1-E4.04` · The three hottest un-registered fan-outs become visible and single-sourced — Gate D human-halt, Mode vocabulary and topology axis registered in `surface-budget.md` (12 rules, 0 unauthorised) and collapsed to one operative line each · [plan](../archive/t1-e4.04-hot-prose-single-sourcing-plan.md)
- **2026-09-29** · `T1-E5.03` · The plan record's missing read-cost lever becomes a `ponytail:` **recorded ceiling** beside the four record rules rather than a new instrument; the numeric cap is declined on the record · [plan](../archive/t1-e5.03-plan-record-size-lever-plan.md)
- **2026-09-29** · `T3-E1.05` · **v1.1.0** closes [Unreleased] — MATURITY re-graded (Axis 1 **A− → A**) with the template's first hand-read, fully sourced **Cost Baseline**, plus a verify-first README/HOW-TO truth sweep · [plan](../archive/t3-e1.05-v110-release-baseline-plan.md)
- **2026-09-29** · commit `f7d4578` · Skills review — 26 of 34 skills re-outlined and rebalanced, six bloat/fan-out cuts, `ptp-*` embeds re-inlined via `-Sync`; parks `T1-E4.06`; machinery 90 → 91
- **2026-09-29** · commit `2cb23db` · New `@user-testing` skill generalises the sprint-close user-acceptance walk into a standalone discipline; `@sprint-close` §5 cites it as canonical (v15 → 16), HOW-TO gains one row
- **2026-09-29** · commit `d2166b5` · Spawn contract — the sub-agent handoff payload is contracted pointers-only, never status prose (`@pass-the-parcel` v31→32); machinery 91 → 92
- **2026-09-29** · commit `ad2f617` · Owner register sharpened — the owner sets direction and owns the vision, the agents own the technical and report in the owner's language; machinery 92 → 93
- **2026-09-29** · commit `ad2f617` · Wrap-up formal pass — one process lesson routed to `process-lessons.md` (verify on disk after every write), KC 1 of 1; machinery 93 → 94
- **2026-09-30** · commit `ec5c95a` · The close's report artefact is renamed `business-report` → `sprint-report` (`@sprint-close` §6, its template and HOW-TO); historical names kept so older links still resolve
- **2026-09-30** · `T1-E3.26` · The sprint queue dashboard ships — one plain-language view (`scripts/sprint_dashboard.py` + 13 fixtures) printed at every batch transition and adopted by `@sprint-status` § 4; re-proves two 2026-08-30/2026-09-29 process lessons (inline-Python shell mangling; concurrent-session edit reversal); machinery 95 → 96 (Minor) · [plan](../archive/t1-e3.26-queue-dashboard-plan.md)
- **2026-09-30** · planless direct fix · Product-owner framing wording harmonized in `AGENTS.md` rule 11 + seed ("User is the Product Owner, Agent is the Dev") with the canonical home in `communication-rules.md`; machinery 96 → 97 (Patch)
- **2026-09-30** · planless direct fix · Two retired `wiki-bootstrap` reference sheets (`15-theme-linguistics`, `qa-15-theme-linguistics`) get their `prune_files` rows, so satellites report `PRUNE` instead of a false parent-skill `DRIFT`; machinery 97 → 98 (Patch)
- **2026-10-01** · planless direct fix · The sprint dashboard script travels (cited by portable skills/agents but never in `portable_files`) with a `-SelfTest` F10 completeness guard, and `@sync-architecture` step 2b reconciles authored files against changed seeds; machinery 98 → 99 (Patch)
- **2026-10-02** — planless direct fix — The Managed Simplicity pointer states the actions, not the slogans: canon + compact form re-outlined (purchase sentence leads: climb the Ladder, measure with the surface-budget report, retire what stopped paying; drift gates move, never deleted), registry signature re-registered, 4 pointer surfaces re-worded, prefix re-inlined ×9; machinery 99 → 100 (Patch)
