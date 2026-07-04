# Verify: 07 — State & Context (Data Shapes & State Management)

**Why this doc matters to AI agents:**
Agents use this to know the exact shape of state. A wrong shape = a runtime crash or silent bug.

**Required sections (sanity check):**
- Provider / store tree
- Global state schemas (full JSON or TypeScript)
- Context and hook APIs
- Persistence strategy

## Questions to ask
1. Does each documented context's shape match the actual TypeScript interface in `src/context/`?
2. Are there context providers in the code that aren't documented?
3. Are there documented contexts that have been removed or replaced?
4. Does the documented provider tree order match the actual order in `main.tsx`?
5. Are the documented persistence rules (localStorage, sessionStorage, server sync) still correct?
6. Do the exported hooks still match the documented APIs? (E.g., a hook that used to return `{user, login}` now returns `{user, login, logout}`.)

## What to verify against
- `src/context/` — actual context definitions
- `src/hooks/` — exported hooks
- `src/store/` or similar — state management code
- `src/main.tsx` — provider tree
