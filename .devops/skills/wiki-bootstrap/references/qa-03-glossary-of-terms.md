# Q&A: 16 — Glossary of Terms (The Lexicon)

**Why this doc matters to AI agents:**
Agents use this to interpret domain-specific language. A wrong definition = an agent misinterprets a requirement, a field name, or a user request.

**Required sections:**
- Application logic terms (e.g., "assembly," "scope," "tag" — what they mean in this app)
- Design token names (e.g., "primary," "surface," "muted" — what each is used for)
- Industry / domain terminology (e.g., ISO standards, regulatory terms)
- Abbreviations and acronyms

## Questions to ask
1. What are the application-specific terms that anyone reading the code or wiki should know? (E.g., "Assembly = a collection of documents grouped for a contract.")
2. For each design token name (referenced from `09-design-system.md`), what is its semantic meaning in this app?
3. What industry or domain terms are in use? (E.g., regulatory standards, technical specs.) Are they defined here?
4. What abbreviations or acronyms are used? (List each with its full form.)
5. Are there terms used in the code (variable names, comments, file names) that aren't defined here?
6. Are there any definitions in this doc that contradict each other or contradict the rest of the wiki?

## Sources of truth
- `src/` — variable names, file names, comments
- `.wiki/core/09-design-system.md` — design token semantics
- `.wiki/core/02-product-context.md` — domain context
- `.wiki/core/01-vision-north-star.md` — product language
