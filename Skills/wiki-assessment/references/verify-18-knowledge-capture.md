# Verify: 18 — Knowledge Capture (The Decision Log)

**Why this doc matters to AI agents:**
Agents use this to understand past decisions and avoid relitigating them. A missing decision = an agent re-asks the user.

**Required sections (sanity check):**
- Decision log entries (date, context, decision, rationale, impact)
- Format consistency across entries
- Recency (added in real time)

## Questions to ask
1. Are decisions being recorded in real time, or are entries being added in batches weeks later?
2. Is the format consistent across all entries? (Same template for every entry — no missing fields.)
3. Are there recent architectural or product decisions in the code (recent refactors, schema changes, new dependencies) that should be captured but aren't?
4. Are there any decisions in the log that are now stale (the team reversed course) and need a "superseded by" note?
5. Are there open or unresolved decisions that the team is actively weighing?
6. Is the most recent entry within the last 7 days (assuming active development)?

## What to verify against
- `docs/logs/agent-changelog.md` — chronological action log
- `docs/plans/` — active plans may surface in-flight decisions
- `docs/wiki/core/05-core-architecture.md` — technical guardrails
- `git log` — recent commits reveal unrecorded decisions
