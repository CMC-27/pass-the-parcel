# Verify: 02 — Product Context (The Strategy)

**Why this doc matters to AI agents:**
Agents use this to align implementation choices with the business domain. Wrong personas = wrong UX assumptions.

**Required sections (sanity check):**
- 2–5 primary user personas
- Top 3–7 core use cases (linked to feature docs)
- High-level product roadmap summary
- Link to the Glossary

## Questions to ask
1. Are the personas still accurate to today's actual user base? (Or have user segments shifted?)
2. Do the listed use cases match what's actually built? (Cross-ref each against `.wiki/features/`.)
3. Are there personas or use cases reflected in the code (feature flags, route guards, role-based UI) that aren't listed?
4. Is the roadmap summary up to date (now / next / later), or is it stale?
5. Does the glossary link still resolve?

## What to verify against
- `.wiki/features/` — actual feature docs
- `src/` — feature flags, route definitions, role-based access
- `.devops/backlog/backlog-index.md` — priority ordering
- `.wiki/core/03-glossary-of-terms.md` — link target
