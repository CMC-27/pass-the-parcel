# Sprint 11 (Machinery Streamline) — User Acceptance Walk

> **How this walk was run.** The operator **delegated** the walk to the agent ("self validate, then close the sprint") rather than answering each test interactively. Every verdict below is therefore an **agent self-validation against the repository's own evidence** — commands, fixtures and file content — *not* an operator sign-off. Recorded plainly so the distinction is never lost; the operator retains the option to re-walk any row. The interactive walk was **not** skipped silently.

**Date:** 2026-09-25 · **Plans in scope:** all 8 at `claim_status: COMPLETE` (a `GATE_D_USER_APPROVAL` plan would have been excluded)

| # | Theme | What was tested | Verdict | Note (agent evidence) |
|---|-------|-----------------|---------|-----------------------|
| 1 | Transport safety | *"one honest version number that cannot be silently rewound"* — a target ahead of the source halts-and-reconciles instead of being stamped over, and the CI check no longer lets `72` match `721` | ✅ **Pass** | `-SelfTest` exit `0` (`5 dirs, 34 skills, 19 files`); `AHEAD`/`MIGRATION` verdicts present in `sync-architecture.ps1`; extracted CI check verified over crafted literals — `machinery-version: 75` matches, `751` and `7` do **not** |
| 2 | The guardrails travel | *"the machinery gates running in every satellite's CI on every push"* | ✅ **Pass** | `.github/workflows/machinery-gates.yml` — no `workflow_call`, no cross-repo `uses:`, no secrets (line 27 states it), `permissions: contents: read`, all five invariant gates present, invariant/template-identity split stated in the header |
| 3 | Carry only what you use | *"a satellite carries only the machinery it uses"* | ✅ **Pass** | `profile: FULL` (default unchanged); `core_skills:` carries exactly **18** slugs — the pipeline-carrying set measured in the GRID-Link audit |
| 4 | A sanctioned path for small changes | *"small changes stop paying full-parcel overhead or drifting outside the pipeline"* | ✅ **Pass** | One canonical `### Micro Lane` section in `.devops/rules/plan-lifecycle.md:74`, stated once and cited; `triage` enum gains `MICRO` (`.devops/rules/plan-lifecycle.md:38`, `sprint_eligible.py`) |
| 5 | One home for the Why | *"the Why is recorded once, in the plan; the changelog is a cheap one-line index"* | ✅ **Pass** | `## Index (2026-09-25 forward)` block at `.devops/logs/agent-changelog.md:502`; six 2026-09-25 lines (one per plan) as the most recent entries; nothing above the boundary rewritten |
| 6 | Every plan traces to a story | *"your acceptance loop never skips a story without a recorded reason"* | ✅ **Pass** | `template-plan.md` scaffolds the `stories:` row with the recorded-skip escape; `@sprint-plan` § 6 step 3 asserts presence at commit time |
| 7 | Your recorded decisions hold | *"an unattended batch asks before overruling a gate mode you recorded"* | ✅ **Pass** | Advisory `mode_conflicts` key in `scripts/sprint_eligible.py` (documented as reporting, never blocking) and presented in `@sprint-run` § 1 step 7 alongside the MULTI-worthy fork |
| 8 | Honest wave data | *"the sprint's wave forecast stops presenting a hand-derived guess as fact"* | ✅ **Pass** | `sprint.template.md` carries `## Delivery Model` with the Flag table, a **Predicate snapshot** and a *"Forecast, never a schedule"* label; `@sprint-plan` § 4b runs `scripts/sprint_eligible.py --sprint-dir` at commit time |

## Summary

**8 tests · 8 passed · 0 failed · 0 blocked.**

Every sprint outcome is present in the repository and behaves as the sprint promised: the machinery counter can no longer be silently rewound, the guardrails travel to satellites, a satellite can carry only the machinery it uses, small changes have a sanctioned lightweight path, the changelog keeps one home for the Why, every plan traces to a story, an unattended batch asks before overruling a recorded decision, and the wave forecast stopped presenting a guess as fact.

**One honest caveat, stated once:** these verdicts are the agent's own checks, not the operator's hands-on sign-off. Where a test's real proof lives (the transport fixtures, the satellite gates) it was exercised locally against fixtures and throwaway trees — no live satellite pull was performed, and the GRID-Link pull remains a deliberate operator action.
