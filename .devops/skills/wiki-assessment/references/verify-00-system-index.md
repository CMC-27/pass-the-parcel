# Verify: 00 — System Index (The Hub)

**Why this doc matters to AI agents:**
The hub is the first thing an agent reads to orient itself. Stale links or a missing core doc row = wasted context discovering what's already documented, or worse, decisions from outdated structure.

**Required sections (sanity check):**
- Project name + one-line description
- Mermaid data-flow diagram (UI → Logic → Data)
- Links to every category index in `wiki/` and `docs/`
- Summary table covering all 18 core docs (`01`–`18`) with a one-line description and "Last Verified" date

## Questions to ask
1. Does the hub's link list reflect the **current** set of category indices in `wiki/` and `docs/`? (Run `ls` on each.)
2. Is the Mermaid data-flow diagram still accurate to the codebase, or has the data path changed?
3. Does the summary table for slots `01`–`18` match the actual files in `.wiki/core/`? (Compare filenames row-by-row.)
4. Are there any "Last Verified" dates stale by more than 30 days?
5. Are there any orphan or dead links in the hub? (Click each one — do they resolve?)

## What to verify against
- `.wiki/core/` — actual file list
- `.wiki/features/`, `.wiki/components/`, `.wiki/database/`, `.wiki/logic/` — category indices
- `src/` — confirms the data-flow diagram still matches the codebase
