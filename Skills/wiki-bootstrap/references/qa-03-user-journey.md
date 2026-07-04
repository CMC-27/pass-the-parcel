# Q&A: 03 — User Journey (The Workflow)

**Why this doc matters to AI agents:**
Agents use this to predict what a user expects to happen next when building or modifying a flow. A wrong step ordering = a broken UX.

**Required sections:**
- Onboarding path (sign-up to first value moment, numbered)
- Primary happy path (the main use case, end-to-end, numbered steps)
- 2–4 important secondary flows
- Top 3–5 error recovery / edge-case paths

## Questions to ask
1. What is the onboarding path from account creation to the first moment of value? (Number the steps.)
2. What is the primary happy path — the single most important user workflow, start to finish?
3. What are the 2–4 most important secondary flows? (E.g., "edit profile," "export data.")
4. What are the 3–5 most common error or edge-case paths? (E.g., "form validation failure," "network drop.")
5. For each step in the happy path, which screen / view / route handles it? (Cross-ref to `docs/wiki/features/`.)
6. Are there any user-facing flows in the code (e.g., new wizard steps, new modals) that aren't documented here?

## Sources of truth
- `docs/wiki/features/` — feature docs that describe each step
- `src/views/`, `src/routes/` — actual screen and route definitions
- `src/components/` — UI components that embody each step
