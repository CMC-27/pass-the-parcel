# Q&A: 15 — Theme & Linguistics (Theming & Content Localization)

**Why this doc matters to AI agents:**
Agents use this to pick the correct label, theme variant, and translation key. A hardcoded string = a missed translation. A wrong theme label = a confusing UI for white-label clients.

**Required sections:**
- Nomenclature mapping tables (functional area → display label per theme / locale / white-label)
- Translation key registry (the canonical list of keys and where each is used)
- Rules for avoiding hardcoded strings (where strings must be keyed, what counts as a "user-facing" string)

## Questions to ask
1. What themes / locales / white-label variants does the app support? (List each, with a one-line purpose.)
2. For each functional area (e.g., "Assembly," "Document," "Tag"), what is the display label under each theme/locale?
3. What is the translation key registry? (Show the canonical list of keys, organized by functional area.)
4. What are the rules for using a translation key vs. a hardcoded string? (E.g., "any user-facing label must be a key.")
5. Are there any hardcoded strings in the code (e.g., in JSX) that should be keys?
6. Are there any new theme variants or locales in the code that aren't documented here?

## Sources of truth
- `src/i18n/`, `src/locales/` — translation files
- Theme / white-label config (e.g., `src/theme/`, `src/config/`)
- `src/components/` — JSX where hardcoded strings may hide
- `docs/wiki/core/05-design-system.md` — referenced for token names (do not duplicate)
