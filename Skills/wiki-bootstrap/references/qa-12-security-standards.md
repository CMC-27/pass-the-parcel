# Q&A: 13 — Security Standards (Security Perimeter & Agentic Governance)

**Why this doc matters to AI agents:**
Agents use this to know what's safe to do and what requires elevation. A wrong RLS assumption = a data leak. A wrong env-var assumption = a secret in a commit.

**Required sections:**
- Strict security boundaries (what data is public, what is authenticated, what is role-gated)
- Zero-trust database principles (RLS schemas, deny-by-default, role-based reads/writes)
- Secret and environment-variable management (where they live, how they're loaded, how they're rotated)
- Dependency pinning (lockfile policy, audit cadence, allowed-versions policy)
- API abuse / rate-limiting controls (where they live, what triggers a block)

## Questions to ask
1. What are the security boundaries? (Public, authenticated, role-gated — what data is in each tier?)
2. What RLS rules are in place? Which tables/collections are protected, and what roles can read/write each?
3. Where do secrets and env vars live? (E.g., `.env.local` is gitignored; production uses Firebase Functions config.) How are they loaded?
4. What is the dependency pinning policy? (Lockfile committed? Audit cadence? Allowed major-version jumps.)
5. What API abuse / rate-limiting controls are in place? (Cloud Function rate limits, Firestore security rules, client-side debounce.)
6. Are there any new endpoints, tables, or env vars in the code that aren't documented here?
7. Are there any documented security policies that are no longer enforced in the code?

## Sources of truth
- `firestore.rules` (or equivalent) — actual RLS rules
- `functions/src/index.ts` — Cloud Function security / rate limiting
- `.env.example` — env-var names (no values)
- `package.json` + lockfile — dependency state
- `docs/wiki/core/16-external-integrations.md` — referenced for third-party auth
