# Verify: 13 — Security Standards (Security Perimeter & Agentic Governance)

**Why this doc matters to AI agents:**
Agents use this to know what's safe to do. A wrong RLS assumption = a data leak.

**Required sections (sanity check):**
- Strict security boundaries
- Zero-trust database principles (RLS schemas)
- Secret and environment-variable management
- Dependency pinning
- API abuse / rate-limiting controls

## Questions to ask
1. Do the documented RLS rules match the actual rules in `firestore.rules` (or equivalent)?
2. Are there new tables / collections / endpoints in the code that aren't protected by the documented RLS?
3. Are secrets still only in env vars? (Spot-check: any secrets hardcoded in code or committed to git?)
4. Is the dependency pinning policy still being followed? (Lockfile committed, audit cadence observed.)
5. Are the rate-limiting controls still in place? (E.g., Cloud Function rate limits still set.)
6. Are there any unpatched vulnerable dependencies? (Run `npm audit` or equivalent.)
7. Are there documented security policies that are no longer enforced?

## What to verify against
- `firestore.rules` (or equivalent) — actual RLS rules
- `functions/src/index.ts` — Cloud Function security / rate limiting
- `.env.example` — env-var names (no values)
- `package.json` + lockfile — dependency state
- `docs/wiki/core/10-external-integrations.md` — referenced for third-party auth
