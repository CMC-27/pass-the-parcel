# Q&A: 11 — Validation Standards (Data Integrity & Error Handling)

**Why this doc matters to AI agents:**
Agents use this to know which validations block the user and which are soft warnings. Wrong tier = either users get blocked on trivia, or they ship bad data.

**Required sections:**
- Validation tiers (field-level, entity-level, cross-entity) — what each tier covers
- Error classification (warning vs. critical stop) — what blocks progression
- Error dashboard / aggregation pattern — how errors are surfaced
- Guided resolution UX — how the user fixes a blocking error

## Questions to ask
1. What validation tiers are in use? (Field-level: single field. Entity-level: one record. Cross-entity: multiple records.) What does each tier cover?
2. How are validation errors classified? What's the difference between a warning and a critical stop?
3. Which validation failures block user progression? (E.g., before finalization, before submission, before export.)
4. Is there an error dashboard or aggregation pattern? (E.g., a sidebar that lists all errors for a record.)
5. What is the guided-resolution UX pattern when the user has a blocking error? (E.g., inline highlight + tooltip + "fix" button.)
6. Are the field-level validators in the doc (e.g., Zod schemas, Yup schemas) the same as those in the code?
7. Are there validation rules in the code (e.g., `validateXxx()` functions) that aren't captured here?

## Sources of truth
- Zod / Yup / equivalent schema files in `src/`
- `src/components/forms/` — form-level error UI
- `docs/wiki/core/08-user-journey.md` — error-recovery flows
