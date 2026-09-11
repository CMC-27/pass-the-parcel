---
name: parcel-walkthrough-machinery-hardening
type: examples
status: template
format-version: 1
title: "Worked Example: A Full Parcel Run (T1-E2.01)"
description: "End-to-end walkthrough of the T1-E2.01 machinery-hardening parcel — scoping, gates, an independent review rejection, a revision loop, and verification."
---
# Worked Example: A Full Parcel Run (T1-E2.01)

> **What this is.** A narrated transcript of one real parcel, from backlog pickup to archive. It exists so a newcomer can see what the ten phases actually produce — especially the parts that are easy to describe and hard to picture: what a gate looks like when it halts, what an independent review rejection looks like, and how a revision loop closes.

The run shown here is **T1-E2.01 — Machinery Integrity & Portability Hardening**. The archived plan is the primary artefact: [`t1-e2.01-machinery-hardening-plan.md`](../../.devops/archive/t1-e2.01-machinery-hardening-plan.md). Reviewers ran in isolated contexts; their verdicts are quoted below rather than linked, because per-run workspaces (`.opencode/plans/run-*/`) are gitignored and never published.

## The run at a glance

| Group | Phase | Produced | Outcome |
|---|---|---|---|
| — | Pickup | `git mv` backlog → plan; `run-*/` workspace created | `BACKLOG` → `PHASE_1` |
| A | 1–3 | Scope perimeter, context inventory, clarification Q&A | **Gate A** approved |
| A | 3.5 | AUTO auto-resolutions of the clarification questions | 1 resolved, rest relayed to the user |
| B | 4–5 | Wiki requirements spec + acceptance criteria; implementation plan | **Gate B** approved |
| C | 6 | Independent spec-and-logic audit | **`REJECTED`** → revision loop |
| B′ | 5-rev | Plan fixes applied over three rounds | Status → `PHASE_5` |
| C′ | 6–7 | Re-audit + product review | Architect **`REJECTED`** again (round 2); product **`PASS`** |
| D | 8–9 | Code written to disk; all gates run | Green |
| E/F | 10 + Wrap Up | Plan archived, versions bumped, knowledge captured | `COMPLETE` |

## Group A — scope, then stop

The context hunter read the wiki governance docs, inventoried the blast radius against disk, and drafted the clarification questions. The workflow then **halted at Gate A** and relayed the questions to the user one at a time. Nothing was planned before the scope was approved — that ordering is the whole point of the gate.

In `AUTO` mode the mechanical checks that clear Gates A–C are explicit: the phase output exists, no `**REJECTED:**` verdict line is present, and no `Unresolvable:` entries remain. A question that cannot be answered from a mapped source is a hard halt, not a guess.

## Group B — the spec comes before the plan

Phase 4 wrote the acceptance criteria **first** (16 numbered criteria, each with a test target), then Phase 5 built the implementation plan to satisfy them. The plan carries no implementation code — only exact string literals (commands, config keys) — so it can be reviewed as a contract before a single line is written.

## Group C — the review that actually rejected

This is the part worth reading closely. The independent architect did not rubber-stamp the plan. Its round-2 verdict opens with:

> **REJECTED:** B1 not fully resolved — T07's replacement grep rule cannot execute as written ... Route: `PHASE_5_REVISION`.

The finding, in plain terms: a validation command in the plan was written with the wrong escaping and would silently match nothing, while its acceptance condition ("zero remaining hits") was unsatisfiable. The plan would have *looked* verified and shipped a broken gate.

That rejection is the system working. Because the reviewer ran in a fresh context with no stake in the plan, it caught a defect the author was blind to. The product reviewer, reviewing the same plan from the user's side, returned `PASS`.

## The revision loop

A failed review sets the status to `PHASE_5_REVISION` and routes back to Group B — it does not proceed, and it does not patch forward. The planner re-ran on the same plan file for **three rounds** (R1, R2, R3), each time applying the flagged fixes verbatim:

1. **R1** — replaced a hand-maintained file-position list with a re-runnable command rule, and documented a previously undocumented migration path.
2. **R2** — the re-review found the *fix itself* was broken (the same command still didn't match). Round 2 also raised a second block about an unverified "parity-safe" claim.
3. **R3** — the command was corrected to its canonical form with a satisfiable acceptance test; the parity claim was adjudicated with a live CI run showing the guard scripts pass on Linux and scan a non-zero file count.

Only after the third round did the pipeline clear Gate C and move to execution. **Three rewrites of a plan is cheaper than one bad merge.**

## Group D — execute, then verify

With the gates clear, the code surgeon applied the plan single-pass, directly to disk, touching only the planned files. Phase 9 then ran the exact commands from the plan's test plan and recorded raw output — prefix integrity, UTF-8 scan, wiki lint, coverage no-op, transport self-test, JSON parse. One acceptance criterion was verified by deliberately tampering with a file (expect exit `1`) and restoring it (expect exit `0`).

## Wrap-up

The plan was archived with `git mv` (no stub left behind), the machinery version was bumped, a release row was recorded, wiki docs were promoted from `in-progress` to `stable`, the backlog row was updated, and the changelog was written. The final state read `COMPLETE`, all four gates `APPROVED`.

## What to copy from this example

- **Halt at the gates.** The value is in the stop, not the ceremony.
- **Let the review reject.** A reviewer that never rejects is not reviewing.
- **Fix in the plan, not in the code.** Revision happens in Group B before execution, never by patching a broken implementation forward.
- **Quote run artefacts, link archives.** Per-run workspaces are ephemeral; archived plans are permanent.

## See also

- [`../../.devops/archive/t1-e2.01-machinery-hardening-plan.md`](../../.devops/archive/t1-e2.01-machinery-hardening-plan.md) — the full archived plan
- [`.devops/logs/version-history.md`](../../.devops/logs/version-history.md) — the machinery release log (T1-E2.01 shipped as v0.3.13)
- [`../core/18-knowledge-capture.md`](../core/18-knowledge-capture.md) — the decision this run recorded
- [`../core/17-docs-blueprint.md`](../core/17-docs-blueprint.md) — the doc taxonomy this example follows
