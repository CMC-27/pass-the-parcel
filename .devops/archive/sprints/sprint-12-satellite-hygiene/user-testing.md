---
type: "sprint-artifact"
sprint: 12
name: "Satellite Hygiene"
slug: "satellite-hygiene"
status: "complete"
---

# Sprint 12 — User Acceptance Walk

> Sprint-wide acceptance testing, walked with the owner at close (2026-09-27). Per-plan Gate D verified each parcel in isolation; this walk asks whether the **delivered outcomes** behave as promised for the person who owns them. Tests are grouped by theme, never by parcel code.

## Results

| # | Theme | What was tested | Verdict | Operator note |
|---|---|---|---|---|
| 1 | Governance & Transport Integrity | `agents-and-skills.md` § Sync Protocol tells a satellite **not** to bump the counter and points at the canonical ownership clause instead of restating it | ✅ Pass | — |
| 2 | Concurrency & Sprint Lifecycle | Phase 5 may declare partitioned test commands; Phase 9 evidence carries the `Suite scope` column recording what ran and what was excluded | ✅ Pass | — |
| 3 | Transport Integrity | `opencode.json` and its seed declare no field V2 ignores, state `skills` as the flat array, and the gates step still passes on a fresh pull | ✅ Pass | — |

## Summary

**3 of 3 tests passed — 0 failed, 0 blocked.** Every outcome the sprint promised was confirmed working in the owner's hands on the first pass: the counter instruction no longer contradicts itself for satellites, the test-batching vocabulary reaches both the declaration and the evidence surface, and the OpenCode V2 config declares only what V2 loads.

No follow-up rows were raised, so nothing carries into the theme registers from this walk.
