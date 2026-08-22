# Q&A: 12 — Utility Standards (Calculation & Formatting Conventions)

**Why this doc matters to AI agents:**
Agents use this for consistent precision, formatting, and visual micro-patterns. Inconsistent rounding = financial miscalculations. Inconsistent IDs = referential breakage.

**Required sections:**
- Rounding rules (financial, aggregation, percentages — precision requirements)
- Number / date / currency formatters (the canonical function calls and their defaults)
- ID generation strategy (format, prefix, monotonicity, collision avoidance)
- Visual styling micro-patterns (e.g., metallic edges, tinted shadows, glassmorphism configs) — reference `09-design-system.md` for tokens, keep logic here

## Questions to ask
1. What are the rounding rules for financial values, for aggregated totals, and for percentages? (How many decimal places, which rounding mode.)
2. Which formatter functions are canonical for numbers, dates, and currencies? (Name, default locale, default options.)
3. What is the ID generation strategy? (Format like `asm_01H...`, `doc_2026_0001`, or UUIDv7.) Where is the generator function?
4. What visual micro-patterns are reusable across the app? (E.g., "frosted card," "tinted shadow for danger rows.") Which token names back them?
5. Are there formatters used inconsistently across the codebase (e.g., some places use `Intl.NumberFormat`, some use a custom function)?
6. Are there rounding or ID-generation rules in the code that aren't documented here?

## Sources of truth
- `src/utils/format.ts` (or equivalent) — formatters
- `src/utils/id.ts` (or equivalent) — ID generator
- `src/utils/round.ts` (or equivalent) — rounding helpers
- `.wiki/core/09-design-system.md` — referenced for tokens (do not duplicate)
