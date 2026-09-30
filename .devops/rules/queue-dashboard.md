---
title: Queue Dashboard
tags: [dev, rules, dashboards, batch, owner-facing]
status: stable
owner: Wiki Owner
last-reviewed: 2026-09-30
related-to: [./README.md, ../skills/sprint-run/SKILL.md, ../skills/sprint-status/SKILL.md]
---

# Queue Dashboard

> **The rule.** Any operator-facing surface that names the batch's position — the `@sprint-run` preview, the per-transition narration, a deferral halt, the consolidated report, the `@sprint-status` readout — opens with **the dashboard**: `python scripts/sprint_dashboard.py`, rendered from live state, printed at every transition. Machinery-facing prose (gate file text, agent-to-agent records, the plan files themselves) is exempt.

## Negative rules (what the dashboard is not)

- **A view, never a decision source.** It renders `claim_status` + the bottom `Status` row + `SPRINTS.md` + the sprint.md Committed Scope table. No agent reads *back* from the rendered dashboard to decide anything — a parser of the dashboard prose is a defect; the `--json` mode is the machine contract (`schema sprint-dashboard/1`, pinned by `scripts/tests/test_sprint_dashboard.py`).
- **Never the eligibility predicate, re-derived.** The renderer imports `sprint_eligible.compute()`; it never re-implements lanes, eligibility or the fixpoint. A row that disagrees with the predicate is a bug in the view, never an authority the view outranks.
- **Never owner jargon.** Owner-facing prints use plain words ("waiting on your call", "your move", "blocked — unmet dependency T1-E2.x"); the machinery vocabulary (fork, yield, fixpoint, lane readout) stays in the skills' own bodies under citations.
- **Never a gate.** A degraded render exits `0` and names reality; only a broken register (unreadable) exits `1`. Established gates already own the machinery checks; no new checker, no CI surface.

## Shape homes (one per *audience*, never three for one artifact)

- **Machine home:** `scripts/sprint_dashboard.py` + its fixture suite — the row regex, the state map's precedence, and the JSON contract live there; prose cites, never restates.
- **Operator-facing prose home:** `.devops/skills/sprint-status/SKILL.md` § 4 — an example block explicitly cited to the script; `@sprint-run` § 3 owns the *print cadence* (every transition) and the deferral halt's `your move` card.

## The `your move` card

A deferral is a pure pause at that plan's slot (canonical: `.devops/rules/plan-lifecycle.md` § Claim Protocol → *MULTI-worthy Yield*): the host prints the dashboard, and its halt line wraps the `waiting on your call` row with three fields — the plan's code, the resume path (run the plan in its own session via `@pass-the-parcel`, wrap it up so it archives, then re-invoke `@sprint-run`), and the dependents the deferral strands (`blocks`, from `compute()`'s `complexity`). When the operator returns, the fresh dashboard shows the row done and the marker advanced — nothing was ever persisted.

## Related surfaces

- `.devops/rules/plan-lifecycle.md` § Claim Protocol — the predicate, lanes, and the yield this view renders (cited, never re-implemented).
- `.devops/skills/sprint-run/SKILL.md`, `.devops/skills/sprint-status/SKILL.md` — the two citation faces (cadence + readout).
- `scripts/tests/test_sprint_dashboard.py` — the AC-per-fixture pins (13) that keep the shape honest.
