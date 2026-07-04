# Q&A: 14 — Performance Standards (The Guardrails)

**Why this doc matters to AI agents:**
Agents use this to know what "fast enough" means for the app. A heavy dep added without lazy-loading = a bundle bloat regression. A new route not lazy-loaded = a slower TTI.

**Required sections:**
- Bundle / build architecture (Vite config, code-splitting strategy, vendor chunking)
- Framework-specific configuration (e.g., React 19 concurrent features, Vite chunk strategy)
- Code patterns (lazy-loading via `React.lazy`, memoization, virtual list usage)
- Dependency approval protocol (what counts as a "heavy" dep, what requires a tree-shaking strategy)
- Performance budgets (max bundle size, max TTI, max LCP)

## Questions to ask
1. What is the bundle and build architecture? (Vite config highlights: code-splitting, vendor chunking, asset hashing.)
2. What framework-specific configurations are in use? (E.g., React 19 concurrent features, suspense boundaries.)
3. What code patterns are required for performance? (Lazy-loading via `React.lazy`, memoization rules, virtual list usage.)
4. What counts as a "heavy" dependency that requires a dynamic import or tree-shaking strategy before approval?
5. What are the performance budgets? (Max initial bundle size, max TTI, max LCP — and how are they measured?)
6. Are there new routes, components, or dependencies in the code that aren't reflected in the budgets?
7. Are there any documented performance rules that are no longer being followed?

## Sources of truth
- `vite.config.ts` — build config
- `src/main.tsx`, route files — `React.lazy` usage
- Lighthouse / Vercel Analytics — actual perf metrics
- `package.json` — dependency size audit (`npm run build -- --report` or similar)
