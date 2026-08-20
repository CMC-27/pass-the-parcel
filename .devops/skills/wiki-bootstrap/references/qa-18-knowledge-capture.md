# Q&A: 18 — Knowledge Capture (The Decision Log)

**Why this doc matters to AI agents:**
Agents use this to understand past decisions and avoid relitigating them. A missing decision = an agent re-asks the user. A stale decision = an agent follows a rule that's been reversed.

**Required sections:**
- Decision log entries (date, context, decision, rationale, impact)
- Format consistency (every entry follows the same template)
- Recency (entries are added in real time, not in batches weeks later)

## Questions to ask
1. What are the most recent 3–5 decision log entries? (Walk through the date, context, decision, rationale, and impact for each.)
2. Is the format consistent across all entries? (Same template for every entry.)
3. Is the log being kept up to date in real time, or are entries being added in batches?
4. Are there key architectural or product decisions in the code (recent refactors, schema changes, new dependencies) that should be captured but aren't?
5. Are there any open or unresolved decisions that the team is actively weighing?
6. Are there any decisions in the log that are now stale (the team has reversed course) and need a "superseded by" note?

## Sources of truth
- `.devops/logs/agent-changelog.md` — chronological action log
- `.devops/plans/` — active plans may surface in-flight decisions
- `docs/wiki/core/05-core-architecture.md` — technical guardrails (some may originate from decisions)
- `git log` — recent commits reveal unrecorded decisions
