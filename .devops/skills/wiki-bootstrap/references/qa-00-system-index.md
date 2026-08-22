# Q&A: 00 — System Index (The Hub)

**Why this doc matters to AI agents:**
The hub is the first thing an agent reads to orient itself. A stale hub means an agent wastes context discovering what's already documented, or worse, makes decisions from outdated section links.

**Required sections:**
- Project name + one-line description
- Mermaid data-flow diagram (UI → Logic → Data)
- Links to every category index in `.wiki/` and `docs/`
- Summary table covering all 18 core docs (`01`–`18`) with a one-line description and a "Last Verified" date

## Questions to ask
1. What is the project name and a single-sentence description of what it does?
2. What is the high-level data flow at a glance? (Where does the UI get data from, where does that data go?)
3. Which category indices currently exist in `.wiki/` and `docs/` that should be linked from the hub?
4. Which 18 core docs (slots `01`–`18`) are present in `.wiki/core/` right now? Confirm the list and the one-line description of each.
5. Is there a Mermaid diagram in the doc today, and does it still match the actual data flow in code?
6. Are there any "Last Verified" dates stale by more than 30 days that need a refresh?

## Sources of truth
- `.wiki/core/` — actual list of core docs
- `.wiki/features/`, `.wiki/components/`, `.wiki/database/`, `.wiki/logic/` — category indices
- `docs/{backlog,logs,plans,archive}/` — operational tooling dirs to cross-link
- `src/` — confirms the data-flow diagram still matches the codebase
