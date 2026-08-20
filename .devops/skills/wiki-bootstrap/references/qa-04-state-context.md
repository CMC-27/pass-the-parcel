# Q&A: 07 — State & Context (Data Shapes & State Management)

**Why this doc matters to AI agents:**
Agents use this to know the exact shape of state before reading or writing it. A wrong shape = a runtime crash or a silent bug. A missing context = an agent invents its own (and they drift apart).

**Required sections:**
- Provider / store tree (the full hierarchy of context providers)
- Global state schemas (full JSON or TypeScript definitions of every context value)
- Context and hook APIs (the exported `useXxx()` hooks, their inputs and returns)
- Persistence strategy (localStorage, sessionStorage, server sync, optimistic updates)

## Questions to ask
1. What is the full provider / store tree? (Order matters — list every `XxxProvider` and what's inside it.)
2. For each context, what is the exact shape of its value? (Show the full TypeScript interface or JSON shape, with nested objects spelled out.)
3. What hooks are exported from each context? (e.g., `useAuth()`, `useTheme()` — what do they return, what do they accept?)
4. What is persisted to localStorage, sessionStorage, or the server, and what's the sync strategy?
5. Are there any optimistic-update patterns in use? Which flows?
6. Are there any context providers or stores in the code that aren't documented here?
7. Are there any documented contexts that have been removed or replaced in the code?

## Sources of truth
- `src/context/` — actual context definitions
- `src/hooks/` — exported hooks
- `src/store/` or similar — state management code
- `package.json` — state management library (Zustand, Redux, Jotai, etc.)
