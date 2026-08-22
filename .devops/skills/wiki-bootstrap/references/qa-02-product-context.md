# Q&A: 02 — Product Context (The Strategy)

**Why this doc matters to AI agents:**
Agents use this to align implementation choices with the business domain. Wrong personas = wrong UX assumptions. Missing use cases = features that don't ship to the right people.

**Required sections:**
- 2–5 primary user personas (with name, role, goals, pain points)
- Top 3–7 core use cases (linked to feature docs)
- High-level product roadmap summary (now / next / later)
- Link to the Glossary (`03-glossary-of-terms.md`) for domain terminology

## Questions to ask
1. Who are the 2–5 primary user personas? (Name, role, primary goal, biggest pain.)
2. What are the top 3–7 use cases the product must serve to be viable?
3. Which features in `.wiki/features/` map to each use case?
4. What is the current roadmap — what's "now," "next," and "later"?
5. Are there any personas or use cases in the codebase (e.g., feature flags, route guards) that aren't represented in the doc?
6. Where is the glossary linked from, and is that link still live?

## Sources of truth
- `.wiki/features/` — actual feature docs
- `src/` — feature flags, route definitions, role-based access
- `.devops/backlog/backlog-index.md` — confirms priority ordering
- `.wiki/core/03-glossary-of-terms.md` — terminology source
