# Verify: 04 — Directory Structure (The Map)

**Why this doc matters to AI agents:**
Agents use this to decide where to put new files. A wrong folder = a code-review failure.

**Required sections (sanity check):**
- Root layout
- `src/` tree with each subfolder's purpose
- Logic directory conventions
- Component library structure
- File naming rules per folder

## Questions to ask
1. Does the documented tree match the actual `ls` output of the project?
2. Are any new folders in the codebase not documented here?
3. Are any documented folders now empty or removed?
4. Are the file naming rules still followed? (Spot-check 3–5 files per rule.)
5. Are the documented folder purposes still accurate? (E.g., a folder labeled "utils" that now contains components.)

## What to verify against
- `src/` — actual tree (run `ls` and `glob`)
- `package.json` — scripts reveal how folders are used
- `tsconfig.json` — path aliases reveal logical grouping
