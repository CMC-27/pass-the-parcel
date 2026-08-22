# Verify: 16 — Glossary of Terms (The Lexicon)

**Why this doc matters to AI agents:**
Agents use this to interpret domain-specific language. A wrong definition = a misinterpreted requirement.

**Required sections (sanity check):**
- Application logic terms
- Design token names
- Industry / domain terminology
- Abbreviations and acronyms

## Questions to ask
1. Are there domain terms used in the code (variable names, comments, file names) that aren't defined here?
2. Are there any conflicting definitions in the glossary? (A term defined two different ways.)
3. Are the design token name definitions still consistent with `09-design-system.md`?
4. Are all abbreviations / acronyms used in the codebase listed here?
5. Has any term's meaning drifted between this doc and how it's actually used in the code?
6. Are there terms listed here that are no longer used anywhere in the codebase?

## What to verify against
- `src/` — variable names, file names, comments
- `.wiki/core/09-design-system.md` — design token semantics
- `.wiki/core/02-product-context.md` — domain context
- `.wiki/core/01-vision-north-star.md` — product language
