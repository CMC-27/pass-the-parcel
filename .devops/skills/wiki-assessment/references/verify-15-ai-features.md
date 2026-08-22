# Verify: 09 — AI Features & Pipelines

**Why this doc matters to AI agents:**
Agents use this to wire up new AI features. A wrong prompt template = silent quality regression.

**Required sections (sanity check):**
- In-app AI features
- LLM / model integration architecture
- System prompt templates
- Prompt / response serialization schemas
- Fallback rules

## Questions to ask
1. Do the documented system prompts match the actual prompts being sent to the model?
2. Are the response schemas still valid? (Run them through the Zod parser; do they parse actual responses?)
3. Have the fallback rules drifted? (E.g., a documented "show error toast" is now a "retry 3 times, then toast.")
4. Are there new AI features in the code that aren't documented here?
5. Are there documented AI features that have been removed or disabled?
6. Is the model and integration path (e.g., `geminiProxy` Cloud Function in `australia-southeast1`) still the one in use?

## What to verify against
- The Cloud Function in `functions/` (or equivalent) — actual prompt assembly and response parsing
- `src/` — UI surfaces that call the AI
- `package.json` — model SDK dependencies
- `.wiki/core/12-security-standards.md` — secret handling for the proxy
