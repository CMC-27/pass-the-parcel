# Verify: 11 — Validation Standards (Data Integrity & Error Handling)

**Why this doc matters to AI agents:**
Agents use this to know which validations block the user. Wrong tier = users get blocked on trivia, or they ship bad data.

**Required sections (sanity check):**
- Validation tiers (field, entity, cross-entity)
- Error classification (warning vs. critical stop)
- Error dashboard / aggregation pattern
- Guided resolution UX

## Questions to ask
1. Does the field-level validator list match the actual Zod/Yup schemas in `src/`?
2. Are any validation tiers deprecated or no longer used?
3. Are the blocking vs. non-blocking error categorizations still correct? (A "critical stop" was downgraded to a warning, or vice versa.)
4. Is the error dashboard / aggregation pattern still in the UI? (Not removed or hidden.)
5. Is the guided-resolution UX pattern still used? (Inline highlight, tooltip, fix button — still there?)
6. Are there new validation rules in the code that aren't captured here?

## What to verify against
- Zod / Yup / equivalent schema files in `src/`
- `src/components/forms/` — form-level error UI
- `.wiki/core/08-user-journey.md` — error-recovery flows
