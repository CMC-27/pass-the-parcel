# Verify: 17 — Docs Blueprint (The Standard)

**Why this doc matters to AI agents:**
Agents use this as a quick in-repo reference for the wiki standard. Drift between this doc and the `wiki-bootstrap` skill = agents follow the wrong rules.

**Required sections (sanity check):**
- Core philosophy summary (one short paragraph)
- Folder taxonomy (compact reminder)
- Naming conventions (prefix patterns)
- A pointer to the full `wiki-bootstrap` skill (not a full duplicate)

## Questions to ask
1. Is this doc still aligned with the current `wiki-bootstrap` skill? (The skill is the source of truth.)
2. Is the doc kept concise (under ~150 lines), or has it drifted into a full duplication of the skill?
3. Does it link to the full `wiki-bootstrap` skill for the detailed checklist and Q&A workflows?
4. Has any new naming convention or folder been added in the skill that this doc doesn't reflect?
5. Are the "Last Verified" / date metadata in this doc still fresh?

## What to verify against
- `.devops/skills/wiki-bootstrap/SKILL.md` — the source of truth
- This doc should be a pointer, not a duplicate
