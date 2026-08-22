# Q&A: 09 — AI Features & Pipelines

**Why this doc matters to AI agents:**
Agents use this to wire up new AI features correctly. A wrong prompt template = silent quality regression. A wrong response schema = a runtime parse failure. A wrong fallback = users see broken output.

**Required sections:**
- In-app AI features (user-facing AI capabilities, listed with their purpose)
- LLM / model integration architecture (which models, which proxy/function, which region)
- System prompt templates (the canonical structure, with placeholders)
- Prompt / response serialization schemas (Zod or similar, with example payloads)
- Fallback rules (what happens when the model errors, rate-limits, or returns malformed output)

## Questions to ask
1. What user-facing AI features exist in the app? (E.g., "auto-summarize a document," "suggest a tag.")
2. Which LLM and model is in use, and what is the integration path? (e.g., `geminiProxy` Cloud Function in `australia-southeast1`.)
3. What is the canonical structure of a system prompt for this app? (Show the template, the variable slots, and any "do not include" rules.)
4. What does the response schema look like? (Zod schema, or example JSON, with all fields spelled out.)
5. What fallback rules apply when the model errors, times out, rate-limits, or returns malformed output?
6. Are there any AI features in the code that aren't documented here, or any documented features that have been removed?

## Sources of truth
- The Cloud Function in `functions/` (or equivalent) — actual prompt assembly and response parsing
- `src/` — UI surfaces that call the AI
- `package.json` — model SDK dependencies
- `.wiki/core/12-security-standards.md` — secret handling for the proxy
