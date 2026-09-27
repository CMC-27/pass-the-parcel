---
type: "sprint-artifact"
sprint: 12
name: "Satellite Hygiene"
slug: "satellite-hygiene"
status: "complete"
---

# Sprint 12 (Satellite Hygiene): Business Report

## What this sprint set out to do

Make the portable machinery tell every satellite the truth it needs to run cleanly — about who owns the version counter, about how much test work a plan actually owes, and about which configuration the current tooling really reads.

## What was delivered

**Version counter ownership.** Satellites were being told to increase a version number they do not own, which created drift and confusing "upgrade" warnings on every sync. The instruction now says clearly that the counter belongs to the template and that a satellite should leave it alone — and every health check tells the same story. A related red build step that had been quietly failing was repaired in the same pass.

**Smarter test runs.** A plan can now declare that it only needs the tests relevant to its change, plus a quick type-check, instead of re-running an entire large test suite. The full suite still runs — once per batch, once before a push, once per sprint close — so nothing ships unchecked. The verification record now shows exactly what was tested and what was skipped, which makes the final approval a real decision rather than a rubber stamp.

**Configuration honesty.** The workspace configuration no longer declares a setting the current tooling silently ignores, which removes a class of confusing "why isn't this applied?" questions.

## Wins

- **Satellite pulls converge instead of halting.** The most common cause of a sync conflict is designed out rather than explained away each time it happens.
- **Large test suites stop dominating the workday.** Plans pay for the tests their change actually affects; the full sweep happens at the points where it matters.
- **A failing build step was caught and fixed.** The trunk is green again for the first time since a prior release row lost a required line.
- **Evidence you can read.** Approvals now show test scope in plain terms, not just a wall of green ticks.

## Quality

Three of three planned changes were delivered and archived. This workspace ships no application source code by design, so its own test count remains zero; the machinery's own fixture suites — 34 sprint-eligibility tests plus the tooling checks — all pass, the documentation lint is clean, and no tracked claim has gone stale. One change came in five times larger than estimated and was re-scoped and re-run to land properly; that cost is recorded honestly rather than hidden. All three delivered outcomes passed the owner's own acceptance walk on the first attempt — 3 passed, 0 failed, 0 blocked.

## Open items for the owner

- Nothing is outstanding from this sprint. The queue drained; no item carried forward.
- The close-of-sprint code-quality scan flagged two machinery files as larger than their size guideline — one past its critical threshold. Both are logged for a future cleanup pass; no action is needed from you.
- The process-lessons register is over its soft target (31 entries against a ~25 guideline). It is a staging area, not an archive; folding matured rules into their owning documents is the next close's housekeeping.

## What's next

Sprint 12 is closed and archived. The next cycle opens with `@sprint-plan`, which reads the triage list and suggests capacity from this sprint's accuracy figure. Two machinery follow-ups were parked during the sprint and remain available: the manual claim path has no enumerated pre-flight checklist, and the version counter contract's two open seams.

**Sprint record:** [sprint.md](./sprint.md) · **Retrospective:** [retro](./sprint.md#retro) · **Acceptance walk:** [user-testing.md](./user-testing.md)
