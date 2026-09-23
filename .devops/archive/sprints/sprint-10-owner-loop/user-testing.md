# Sprint 10 (Owner Loop) — User Acceptance Walk

Walked by `@sprint-close` §5 on 2026-09-23. The sprint's manual-test menu is derived from the seven executed plans' acceptance criteria (no plan carries a `stories:` row yet — the row was introduced by `T1-E3.16` in this same sprint, so the documented criteria fallback is what ran; see `T1-E3.18`).

**Operator ruling:** unable to exercise the tests in this workspace; **all eight accepted on evidence, to be reported back on** if anything misbehaves in live use.

| # | Outcome / theme | What was tested | Verdict | Operator note |
|---|---|---|---|---|
| 1 | Trustworthy batches | One-shot, non-interactive test invocation named in `@test-and-deploy` §2 (`vitest run` / `--run` / `CI=true`); watch mode named as the failure to avoid | **ACCEPTED (untested)** | Cannot exercise here; accepted. Report back if a batch ever hangs again. |
| 2 | Trustworthy batches | Named interrupted-run resume contract in `plan-lifecycle.md` § Interrupted Run (Phase 9 only; never re-run 1–8; never fabricate evidence) | **ACCEPTED (untested)** | Accepted on the live proof this sprint (a runner died mid-plan and resumed cleanly). |
| 3 | Trustworthy batches | `@agent-wrap-up` Phase 7a is a three-gate hard stop (lint + coverage + claims check) with the named `update` repair path | **ACCEPTED (untested)** | Accepted; a red claims check now blocks the whole wrap-up. |
| 4 | Sprint ritual | This acceptance walk itself — sprint-wide queue, one-by-one, recorded to `user-testing.md` and carried by the archive | **ACCEPTED (untested)** | Judged by design, not experienced. Revisit after a live walk in a future sprint. |
| 5 | Sprint ritual | `@sprint-plan` §6 step 3 drafts one or more owner-voice stories per committed plan into a `stories:` row | **ACCEPTED (untested)** | Newest piece; no plan carries a row yet. The instruction is what was accepted. |
| 6 | Sprint ritual | `@sprint-close` §6 business report — six-section outline, benefit language, machinery vocabulary prohibited | **ACCEPTED (untested)** | The real report from this sprint is the first live example; accepted pending review of it. |
| 7 | Sprint ritual | `OPERATING-PRINCIPLES.md` role model — the user/operator is the product owner holding every verdict; the agent fleet is the dev team | **ACCEPTED (untested)** | Accepted. |
| 8 | Machinery homecoming | `@sync-architecture` step 5 parcel-feedback route — satellite-local `feedback/` outbox, operator hand-carry, template-side backlog intake, no secrets, nothing auto-pushed | **ACCEPTED (untested)** | Accepted; will be exercised at the next satellite sync. |

## Summary

- **Walked:** 8 of 8 tests presented (0 unanswered).
- **Verdicts:** 0 pass · 0 fail · 0 blocked · **8 accepted untested**.
- **Why untested:** the operator cannot exercise this machinery in the current workspace. Per §5.6, this is a *recorded* skip reason, not a silent one. It is the dry-run fidelity the sprint's own risks section named as the accepted test.
- **Disposition:** no failures to route. Nothing is added to the backlog or the business report's open items on account of this walk.
- **Follow-up:** the operator reports back if any of the eight misbehaves in live use. Sprint 10's close is the **first live exercise** of both §5 (this walk) and §6 (the business report); a later sprint's close will be the first walk that is genuinely *experienced* rather than accepted.
