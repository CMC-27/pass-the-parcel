# Verify: 05 — App Structure (The Shell)

**Why this doc matters to AI agents:**
Agents use this to understand the app's outermost layer. A wrong mental model = broken routing or broken layouts.

**Required sections (sanity check):**
- Main entry point
- Router configuration
- Global layout wrappers (and their props)
- Navigation / header / sidebar architecture
- Error boundaries and fallback UIs

## Questions to ask
1. Does the entry-point doc match the actual `main.tsx` / `App.tsx`?
2. Are the documented layout wrappers still mounted in the provider tree?
3. Is the router config still accurate? (Run `glob` for route files and compare to the doc.)
4. Does the navigation/header/sidebar architecture match the actual components?
5. Are error boundaries still in the documented locations? Do their fallback UIs match the doc?

## What to verify against
- `src/main.tsx`, `src/App.tsx` — entry points
- Router config (e.g., `src/routes/`, `src/router.tsx`)
- Layout components (e.g., `src/components/layout/`)
- Error boundary components and where they're mounted
