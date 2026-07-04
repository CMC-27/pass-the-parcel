# Verify: 06 — Design System (UI/UX Standards)

**Why this doc matters to AI agents:**
Agents use this to pick the correct class names and tokens. A wrong token = a styling bug or visual regression.

**Required sections (sanity check):**
- Semantic color tokens (HSL values + usage rules)
- Typography scale
- Spacing and layout patterns
- Form element styles
- Interactive states (hover, focus, active, disabled)

## Questions to ask
1. Do the listed semantic color tokens match the actual `tailwind.config` and CSS variable definitions?
2. Are there tokens used in the code (custom CSS variables, Tailwind extensions) that aren't documented?
3. Are there documented tokens that are no longer used in the code? (Deprecation candidates.)
4. Does the typography scale match the actual `font-` classes / `text-` classes used in `src/components/ui/`?
5. Do the form element class names match what's actually in `src/components/ui/`?
6. Do the documented interactive states (hover, focus, active, disabled) match the actual class strings?

## What to verify against
- `tailwind.config.js`, `postcss.config.js` — Tailwind v4 / PostCSS config
- `src/index.css`, `src/styles/` — global styles, CSS variables
- `src/components/ui/` — base UI components
- `docs/wiki/core/12-utility-standards.md` — referenced (not duplicated)
