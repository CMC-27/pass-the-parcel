# Verify: 12 — Utility Standards (Calculation & Formatting Conventions)

**Why this doc matters to AI agents:**
Agents use this for consistent precision, formatting, and IDs. Inconsistent rounding = financial miscalculations.

**Required sections (sanity check):**
- Rounding rules (financial, aggregation, percentages)
- Number / date / currency formatters
- ID generation strategy
- Visual styling micro-patterns (referenced, not duplicated from `09-design-system.md`)

## Questions to ask
1. Are the rounding rules still followed in the code? (Spot-check 3–5 financial calculations.)
2. Are the formatters used consistently, or has some code drifted to ad-hoc formatting?
3. Is the ID generation strategy still consistent across the app? (Some places use a different scheme.)
4. Are the visual micro-patterns (e.g., "frosted card," "tinted shadow for danger rows") still used and still backed by the documented tokens?
5. Are there new rounding, formatting, or ID rules in the code that aren't captured here?
6. Does the doc correctly reference `09-design-system.md` instead of duplicating token names?

## What to verify against
- `src/utils/format.ts` (or equivalent) — formatters
- `src/utils/id.ts` (or equivalent) — ID generator
- `src/utils/round.ts` (or equivalent) — rounding helpers
- `docs/wiki/core/09-design-system.md` — referenced (not duplicated)
