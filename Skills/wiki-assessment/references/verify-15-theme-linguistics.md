# Verify: 15 — Theme & Linguistics (Theming & Content Localization)

**Why this doc matters to AI agents:**
Agents use this to pick the correct label and translation key. A hardcoded string = a missed translation.

**Required sections (sanity check):**
- Nomenclature mapping tables (functional area → display label per theme/locale)
- Translation key registry
- Rules for avoiding hardcoded strings

## Questions to ask
1. Are all new UI strings using translation keys, or are there hardcoded strings in the JSX?
2. Do the theme variants / locales still match what the code supports? (No new theme added without being documented.)
3. Is the translation key registry up to date with all keys actually used in the code?
4. Are the nomenclature mapping tables still accurate for each functional area?
5. Are there any hardcoded strings that should be keys but aren't?
6. Does the doc correctly reference `05-design-system.md` for token names (not duplicating them)?

## What to verify against
- `src/i18n/`, `src/locales/` — translation files
- Theme / white-label config (e.g., `src/theme/`, `src/config/`)
- `src/components/` — JSX where hardcoded strings may hide
- `docs/wiki/core/05-design-system.md` — referenced (not duplicated)
