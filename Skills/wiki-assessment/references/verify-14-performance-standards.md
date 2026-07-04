# Verify: 14 — Performance Standards (The Guardrails)

**Why this doc matters to AI agents:**
Agents use this to know what "fast enough" means. A heavy dep added without lazy-loading = a bundle bloat regression.

**Required sections (sanity check):**
- Bundle / build architecture
- Framework-specific configuration
- Code patterns (lazy-loading, memoization, virtual lists)
- Dependency approval protocol
- Performance budgets (max bundle size, max TTI, max LCP)

## Questions to ask
1. Is the current bundle size still within the documented budget?
2. Are all new routes lazy-loaded via `React.lazy` (or equivalent)?
3. Are there heavy dependencies added recently without a tree-shaking or dynamic-import strategy?
4. Is the performance budget still being measured? (Lighthouse, Vercel Analytics, or similar.)
5. Are the framework-specific configurations (e.g., React 19 concurrent features) still in use as documented?
6. Are there any documented performance rules that are no longer being followed?

## What to verify against
- `vite.config.ts` — build config
- `src/main.tsx`, route files — `React.lazy` usage
- Lighthouse / Vercel Analytics — actual perf metrics
- `package.json` — dependency size audit
