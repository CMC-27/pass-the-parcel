---
type: "sprint-artifact"
name: "Sprint 13 User Testing Sheet"
status: "stable"
sprint: 13
created: "2026-09-29"
---

# Sprint 13 (V1 Hardening) — User Testing Sheet

Acceptance walk for the whole sprint, run by `@sprint-close` § 5 under the
`@user-testing` walk discipline (one test at a time, verdict recorded after each
answer, never a silent skip). Grouped **per outcome, never per parcel code**;
each test leads with the story it traces to.

Scope: plans at `claim_status: COMPLETE` only — 9 of 9. No plan was left at
`GATE_D_USER_APPROVAL`, so the whole committed set contributes its criteria.

| # | Theme | Story it presents | What was tested | Verdict | Operator note |
|---|-------|-------------------|-----------------|---------|---------------|
| 1 | A claim starts from a provably green base | As the operator, I want a claim to start from a provably green trunk, so a red gate is found before the work is planned against a broken base | The manual claim path names one enumerated green baseline and a red trunk stops the claim | **Pass** | Operator ran the probe: canonical `### Green Baseline` heading at `plan-lifecycle.md:106`, claim step 3 ordering the preflight ahead of the claim with a red step meaning *"the claim is not taken"*. Matches expectation; no accept-branch present. |
| 2 | A claim starts from a provably green base | As the operator, I want a plan's declared write set read exactly as written, so a comment cannot silently shrink what the pipeline believes the plan will touch | A full-line comment inside a `touches` / `depends_on` block-list no longer truncates the list | **Pass** | Operator ran the live reader: `['a', 'b']` with a comment between items, `['a']` when the comment ends the list. Pre-fix the first case read `['a']`. |
| 3 | Close-out is a measurement, not a memory | As the operator, I want the close-out CI read to have a checker behind it, so "the trunk was green at close-out" is a measurement rather than a step somebody remembered | The close-out verdict records one of three canonical literals with an honest reason, and an unbacked green is rejected | **Pass** | Operator ran the checker against `T3-E1.05`'s record: `OK: unreadable - not pushed @ de1c5f9…`, exit `0`. Literals measured in their one home (`@agent-wrap-up` § 7a: 4 hits) and **absent** from `@sprint-close` and `@test-and-deploy` (0 / 0) — citation only. |
| 4 | Close-out is a measurement, not a memory | As the operator, I want the green-stamp invariants enforced by something other than prose | The stamp-vs-worktree classifier prints a verbatim outcome line and halts on record drift | **Pass** | Agent-executed (operator instruction). Before the ruling: `FAIL: recorded == located violated — locator a2bedbd is recorded nowhere (records: …)`, exit `1` — the gate halts rather than waving a push through. After the ruling's record landed: `OK: recorded == located — stamp a2bedbd recorded in 1 plan(s)` + `suite invoked — real-file delta: .devops/backlog/REFACTORING.md`, exit `0`. Never a silent pass. |
| 5 | Rules live once | As the template maintainer, I want each high-fan-out rule written once and cited everywhere, so changing a rule costs one edit and no agent can act on a stale copy | The topology axis is stated once in the canon and cited everywhere; `HOW-TO` names all three topologies | **Pass** | Agent-executed. `HOW-TO.md` "two topologies" drift: **0 hits**; its `topology axis` line names `MULTI` / `SINGLE` / `MICRO`. Canon carries 2 hits, the shared prefix 1, the plan template 1. `rule_fanout.py` reports **12 registered rules, 0 unauthorised on every one**, exit `0`. |
| 6 | The transport stays reviewable | As the template maintainer, I want the sync engine back below the complexity thresholds, so the transport I depend on every sprint stays reviewable | The sync engine runs its own end-to-end self-test green after the split | **Pass** | Agent-executed. `sync-architecture.ps1 -SelfTest` → `SELFTEST OK: 5 dirs, 35 skills, 25 files materialised correctly`, exit `0` (~56 s). Engine is 314 lines post-split, 119 under the warn. |
| 7 | The wiki tells the truth about itself | As the operator, I want every wiki page to say something true about this template, so an agent that reads it cold gets honest context | The hub exposes a `Status` column and app-facing slots read `template`, not `stable` | **Pass** | Agent-executed. `.wiki/core/` frontmatter reads **14 `template` / 4 `stable` / 1 `in-progress`** — matching `T2-E2.05`'s declared classification exactly — and the hub's Quick Reference carries the `Slot | Doc | Theme | Description | Status | Last Verified` header. |
| 8 | Plan records stay readable | As the product owner, I want a record cell that has grown unreadable to be caught by something | The plan template carries the `ponytail:` ceiling beside the four record rules, counting as none of them | **Pass** | Agent-executed. `.devops/plans/template-plan.md` carries the `ponytail:` ceiling blockquote stating the four rules *bound duplication, not size*, that an unreadable cell is caught by **no** check, and why the numeric cap stays declined. |
| 9 | V1 shipped as a clean, measured release | As the product owner, I want V1 shipped as a clean, measured release, with the numbers to prove what it costs to run | `CHANGELOG` closes `[Unreleased]` as `v1.1.0`, and `MATURITY` carries a hand-read cost baseline with no estimated cells | **Pass** | Agent-executed. `CHANGELOG.md` `[Unreleased]` is empty with `## [v1.1.0] — 2026-09-29` beneath it; `MATURITY.md` carries `## Cost Baseline (v1.1.0 — 2026-09-29)` with **4 `not available — no session export supplied` cells and 0 estimated ones** (the 3 "estimate" hits are the prose refusing to estimate), 14 gate timings totalling ≈92 s, plan read cost 102,412 B / 705 lines. |

**Summary:** **9 of 9 walked · 9 pass · 0 fail · 0 blocked.**

**Execution note (never a silent skip):** tests 1-3 were walked by the operator through the question tool, one at a time. The operator then instructed *"please carry out this tests yourself"*, so **tests 4-9 were executed by the agent** — the commands and measured outputs above are real, but the verdicts are the agent's reading of them, not a second pair of eyes. Acceptance in the owner's own hands therefore covers tests 1-3 in full and tests 4-9 as delegated verification. No test was blocked, retried or skipped.
