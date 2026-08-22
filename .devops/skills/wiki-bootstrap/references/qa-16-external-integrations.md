# Q&A: 10 — External Integrations (Third-Party & API Connections)

**Why this doc matters to AI agents:**
Agents use this to map internal data to external systems. A wrong field mapping = data loss or corruption in the external system. A missing auth flow = a security incident.

**Required sections:**
- Integration endpoints (URL, method, auth)
- Data mapping tables (internal field → external field, for every integration)
- Authentication flows (OAuth, API key, service account — how tokens are obtained and refreshed)
- Export / import column mappings (when the app imports or exports CSV/Excel/etc.)
- Grouping / deduplication logic (when the external system returns duplicates)

## Questions to ask
1. What external systems does the app integrate with? (Name, purpose, integration type.)
2. For each integration, where is the endpoint URL, the HTTP method(s), and the auth scheme documented?
3. For each integration, what is the field-mapping table? (Internal field name → external field name, with any transformations.)
4. For each integration, how is authentication handled? (OAuth flow, API key location, token refresh cadence.)
5. For any export or import (CSV, Excel, JSON), what are the column mappings? (User-facing label → internal field → external field.)
6. If the external system returns duplicates, what is the dedup key, and where is the logic that handles it?
7. Are there any integrations in the code (e.g., new fetch calls, new SDKs) that aren't documented here?

## Sources of truth
- `src/services/integrations/`, `src/api/`, `functions/` — actual integration code
- `.env.example`, `.wiki/core/12-security-standards.md` — env-var names (never secrets)
- The third-party's official API docs — confirm field names and types
