# Verify: 10 — External Integrations (Third-Party & API Connections)

**Why this doc matters to AI agents:**
Agents use this to map internal data to external systems. A wrong field mapping = data loss or corruption.

**Required sections (sanity check):**
- Integration endpoints (URL, method, auth)
- Data mapping tables (internal field → external field)
- Authentication flows
- Export / import column mappings
- Grouping / deduplication logic

## Questions to ask
1. Does each integration have a current field-mapping table? (Not a placeholder, not a stub.)
2. Are there new integrations in the code (new fetch calls, new SDKs) that aren't documented?
3. Are the auth flows still valid? (OAuth scopes, token refresh cadence — still match the code?)
4. Are the export/import column mappings still accurate to the current CSV/Excel format?
5. Has the dedup logic changed? (E.g., a new dedup key, a new grouping rule.)
6. Are the endpoint URLs and HTTP methods still current?

## What to verify against
- `src/services/integrations/`, `src/api/`, `functions/` — actual integration code
- `.env.example`, `.wiki/core/12-security-standards.md` — env-var names (no secrets)
- Third-party's official API docs — confirm field names and types
