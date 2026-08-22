# Verify: 08 — Core Architecture (The Logic Flow)

**Why this doc matters to AI agents:**
Agents use this to understand the "why" behind non-obvious decisions. Missing the why = an agent "simplifies" load-bearing code.

**Required sections (sanity check):**
- Data lifecycle
- Core engines / algorithms
- Calculated fields and derivation logic
- Technical guardrails (soft-delete, optimistic updates, idempotency)

## Questions to ask
1. Are the documented invariants (e.g., "soft-delete on `archivedAt`") still enforced in the code?
2. Are there new engines or calculation paths in the code that aren't documented?
3. Are there documented engines that have been removed or replaced?
4. Do the derivation rules (e.g., "total = sum of line items, recalculated on every save") still hold?
5. Are any documented guardrails silently removed? (E.g., the optimistic-update pattern was dropped.)
6. Does the data lifecycle (create → read → update → delete) match the actual flows in `src/services/`?

## What to verify against
- `src/utils/`, `src/services/`, `*Engine.ts` — engines and algorithms
- `.wiki/core/04-state-context.md` — state shapes
- `.wiki/core/16-external-integrations.md` — external sync logic
- `.wiki/core/10-validation-standards.md` — validation guardrails
