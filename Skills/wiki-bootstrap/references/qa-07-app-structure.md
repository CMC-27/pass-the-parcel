# Q&A: 05 — App Structure (The Shell)

**Why this doc matters to AI agents:**
Agents use this to understand the app's outermost structural layer before adding pages, layouts, or navigation. A wrong mental model of the shell = broken routing or broken layouts.

**Required sections:**
- Main entry point (file path, what it does)
- Router configuration (library, route table summary)
- Global layout wrappers (and their props)
- Navigation / header / sidebar architecture
- Error boundaries and fallback UIs

## Questions to ask
1. What is the main entry point file (e.g., `main.tsx`, `App.tsx`) and what does it do on boot?
2. Which router library is in use, and where is its config? (e.g., React Router, file-based routing.)
3. What are the global layout wrappers (e.g., `AppShell`, `AuthGate`) and what props do they accept?
4. How is the header / sidebar / nav composed, and where do nav items come from?
5. Where are error boundaries mounted, and what do they render on crash?
6. Is the documented root component tree still the actual tree in the code today?

## Sources of truth
- `src/main.tsx`, `src/App.tsx` — entry points
- Router config (e.g., `src/routes/`, `src/router.tsx`)
- Layout components (e.g., `src/components/layout/`)
- `docs/wiki/features/` — page-level docs that hang off the shell
