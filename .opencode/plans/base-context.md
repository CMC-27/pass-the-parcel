# PTP Canonical Context Header

> **PREFIX-LOCKED:** This file is the canonical prefix for all parcel-* sub-agents. Byte-for-byte identical across every agent invocation.

## Core Development Rules (from AGENTS.md)

1. **Never Hardcode Components:** Use global variants inside `src/components/ui`.
2. **Never Hardcode Text Colors:** Use theme tokens only. No `text-white`, `text-slate-*`, `text-gray-*`, `text-black`.
3. **Respect the Architecture:** Follow documented data flow and domain constraints.
4. **Destructive Actions:** Use `<ConfirmModal>` for deletions.
5. **Context Review:** Read last 3 entries in `docs/logs/agent-changelog.md`.
6. **Subagent Wiki-First Mandate:** Subagent prompts MUST include wiki-first directive.
7. **Planning Protocol:** Multi-step tasks use `@pass-the-parcel`.
8. **Form Field Hygiene:** Every input/select/textarea has `id` + matching `<label htmlFor>`.

## Task Lookup
| Task | Read first | Then drill into |
|---|---|---|
| Building/editing UI component | `docs/wiki/components/components-index.md` | Specific component doc |
| Building/editing screen/view | `docs/wiki/features/features-index.md` | Specific feature doc |
| Writing database query | `docs/wiki/database/database-index.md` | Specific schema doc |
| Editing layout/workspace shell | `docs/wiki/core/07-app-structure.md` | Layout component docs |
| Understanding state/context | `docs/wiki/core/04-state-context.md` | State management docs |
| Extending utility/hook | `docs/wiki/logic/logic-index.md` | Specific util/hook doc |
| Touching AI/agentic workflows | `docs/wiki/core/15-ai-features.md` | AI client utility |
| Adding/editing form fields | `docs/wiki/core/09-design-system.md` S5c | `docs/wiki/core/10-validation-standards.md` |
| Asking question about codebase | `@wiki-query` skill | Cites from `docs/wiki/` |
| Recording knowledge-capture | `@knowledge-capture` skill | `docs/wiki/core/18-knowledge-capture.md` |

## PTP Parcel Agents
- `parcel-orchestrator` -- Primary coordinator (user-facing)
- `parcel-context-hunter` -- Phases 1-3: scoping + context + clarification
- `parcel-phase3-answerer` -- Phase 3.5: AUTO mode question resolution
- `parcel-razor-planner` -- Phase 4: detailed execution plan
- `parcel-smooth-operator` -- Phase 5: UX/product review
- `parcel-grumpy-architect` -- Phase 6: code quality/security review
- `parcel-compactor` -- Phase 6.5: strip debate, produce clean execution spec
- `parcel-code-surgeon` -- Phases 7-8: surgical execution + verification

## PTP Lifecycle States
`BACKLOG` -> `PHASE_1` -> `PHASE_3` -> `PHASE_4` -> `PHASE_6` -> `PHASE_8` -> `COMPLETE`

**Gates:** A (Scope) -> B (Plan) -> C (Review) -> D (Implementation)

**Modes:** `BLIND`/`SINGLE` (agent delegation) x `USER-MANAGED`/`AUTO` (gate behavior)

## Workspace Layout
- Active plans: `docs/plans/[slug]-plan.md`
- Per-run workspace: `.opencode/plans/run-[slug]/`
- Reviews: `run-[slug]/reviews/product_review.md`, `run-[slug]/reviews/arch_review.md`
- Versions: `run-[slug]/versions/v1.0_draft.md`, `run-[slug]/versions/v1.1_merged.md`, `run-[slug]/versions/v2.0_approved.md`
- Audit log: `run-[slug]/decision_log.md`
