# Q&A: 06 — Design System (UI/UX Standards)

**Why this doc matters to AI agents:**
Agents use this to pick the correct class names, tokens, and components. A wrong token = a styling bug that won't compile or a visual regression. A missing token = agents invent their own (inconsistent) values.

**Required sections:**
- Semantic color tokens (HSL values + usage rules)
- Typography scale (font families, sizes, weights, line heights)
- Spacing and layout patterns (4px grid, container widths)
- Form element styles (input, select, button variants)
- Interactive states (hover, focus, active, disabled) per component class

## Questions to ask
1. What are the semantic color tokens (e.g., `bg-primary`, `text-muted`, `border-danger`) and what HSL value backs each?
2. What is the typography scale — font families, sizes, weights, and line heights used across the app?
3. What spacing scale is in use (e.g., 4px grid, Tailwind defaults), and what container/max-width patterns apply?
4. For each form element (input, select, checkbox, button), what are the canonical class names and variants?
5. What are the interactive states (hover, focus-visible, active, disabled) for primary, secondary, and destructive actions?
6. Are there any tokens used in the code (e.g., custom CSS variables, Tailwind extensions) that aren't listed here?
7. Are there any documented tokens that are no longer used in the code?

## Sources of truth
- `tailwind.config.js`, `postcss.config.js` — Tailwind v4 / PostCSS config
- `src/index.css`, `src/styles/` — global styles, CSS variables
- `src/components/ui/` — base UI components embody the design tokens
- `docs/wiki/core/11-utility-standards.md` — micro-patterns (referenced, not duplicated)
