# Operating Principles

> Why this template exists and what serves it. Stated once; every other surface points here.

## The Goal — Pass the Parcel

**Pass the Parcel** is the template's purpose: turn a feature request into a reviewed, executed, verified change by passing one Markdown plan between specialised agents. A single plan file holds all state; every agent starts cold, does one job, writes its result back, and exits.

Its defining properties — what the goal *is*:

| Property | Meaning |
|---|---|
| **Stateless** | one plan, zero carried context |
| **Independently reviewed** | reviewers run in isolated contexts and never see the planner's reasoning |
| **Gated** | A → B → C → D; `AUTO` clears A–C only on positive evidence; Gate D is always human |
| **Deterministic** | every phase asserts a checkable next state; a gate is *moved, never removed* |

**The test.** Every tier below must state how it serves the goal. If it cannot, it is a feature, not an instrument.

## The Principal Instrument — the agent-managed wiki

The wiki is the principal instrument because it is the input every cold start consumes. Without it, each phase would re-derive the codebase and the loop would be expensive or wrong. It has two facets:

| Facet | What it is | Mechanism | Canonical home |
|---|---|---|---|
| **Canonical truth** | the source of truth; docs are written before code | docs-before-code (Phase 4), hub-and-spoke, Grounded Claims, deterministic linter, drift job | `.wiki/rules/README.md`, `.wiki/rules/claims.md` |
| **Stewardship** | the wiki is re-read and re-balanced, never appended to | Review → Re-outline → Re-balance; incremental `@wiki-update` | `.devops/skills/wiki-writer/SKILL.md` |

## The Supporting Instruments

| Instrument | Serves the goal by | Mechanism | Canonical home |
|---|---|---|---|
| **Cache-first, cheap and honest context** | making the stateless loop affordable at scale | byte-stable prefix, cache-anchored plans, small cited context | this document |
| **Managed Simplicity (first principle)** | keeping the machinery small enough to hold and harden | Simplicity Ladder (add) + surface-budget report (maintain) | `.devops/rules/managed-simplicity.md` |
| **Deterministic guardrails** | keeping every instrument's invariant a script, not a convention | the check suite in `.github/workflows/validate.yml`; a gate moves, never dies | this document, `.devops/rules/surface-budget.md` |

## Scope

This document states the template's own principles. It is not synced to satellites and is not inlined into the agent prefix. A satellite keeps its own principles and its own detail in `.wiki/core/`.

## See Also

- [`README.md`](README.md) — the product page and quickstart
- [`AGENTS.md`](AGENTS.md) — the agent entry point
- [`HOW-TO.md`](HOW-TO.md) — the lifecycle guide
- [`.devops/rules/managed-simplicity.md`](.devops/rules/managed-simplicity.md) — the first principle in full
- [`.devops/rules/surface-budget.md`](.devops/rules/surface-budget.md) — the maintenance instrument
