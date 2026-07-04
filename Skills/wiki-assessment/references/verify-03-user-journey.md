# Verify: 03 — User Journey (The Workflow)

**Why this doc matters to AI agents:**
Agents use this to predict what a user expects next. Wrong step ordering = a broken UX.

**Required sections (sanity check):**
- Onboarding path (numbered)
- Primary happy path (numbered steps)
- 2–4 important secondary flows
- Top 3–5 error recovery paths

## Questions to ask
1. Do the numbered happy-path steps still match the actual UI flow in the code?
2. Are there flows documented that no longer exist in the app? (Drift.)
3. Are there user-facing flows in the code (new wizards, new modals) that aren't documented? (Gap.)
4. Do the error-recovery paths reflect the actual error UI in the app?
5. Does the onboarding path still apply, or has the auth/signup flow changed?

## What to verify against
- `docs/wiki/features/` — feature docs
- `src/views/`, `src/routes/` — actual screens and routes
- `src/components/` — UI components that embody each step
