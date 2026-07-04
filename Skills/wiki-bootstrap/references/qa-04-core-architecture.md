# Q&A: 08 — Core Architecture (The Logic Flow)

**Why this doc matters to AI agents:**
Agents use this to understand the "why" behind non-obvious technical decisions. Missing the why = an agent "simplifies" code that was actually load-bearing.

**Required sections:**
- Data lifecycle (create → read → update → delete; how each transition works)
- Core engines / algorithms (the named logic engines, their inputs and outputs)
- Calculated fields and derivation logic (what's computed, from what)
- Technical guardrails (soft-deletes, optimistic updates, idempotency, audit trails)

## Questions to ask
1. What is the end-to-end data lifecycle for the most important entity? (Create, read, update, soft-delete, hard-delete — what actually happens at each step?)
2. What are the named logic engines (e.g., `AssemblyEngine`, `ValidationEngine`, `ExportEngine`) and what does each one do?
3. What fields are calculated/derived rather than stored? What is the source of truth for each derived field?
4. What technical guardrails are in place? (Soft-delete, optimistic updates, idempotency keys, audit logs, RLS.)
5. Are there any "load-bearing" code patterns (e.g., debounce-then-save, eventually-consistent sync) that aren't explained here?
6. Are there any new engines or calculation paths in the code that aren't documented?

## Sources of truth
- `src/utils/`, `src/services/`, `*Engine.ts` — engines and algorithms
- `docs/wiki/core/08-state-context.md` — state shapes referenced by engines
- `docs/wiki/core/10-external-integrations.md` — external sync logic
- `docs/wiki/core/11-validation-standards.md` — validation guardrails
