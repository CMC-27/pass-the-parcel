> **PREFIX-LOCKED:** Canonical shared prefix for all parcel/ptp agents. The **shared prefix** (everything above the ORCHESTRATOR-ONLY block) is inlined byte-for-byte after the YAML frontmatter of every `.devops/agents/parcel.agent.md` and `.devops/agents/ptp-*.subagent.md` file. The **ORCHESTRATOR-ONLY block** (delegation map + model registry) is inlined only into `parcel.agent.md`. Do NOT edit either block in any agent file — edit this file and re-sync (see `scripts/check-parcel-prefix.ps1`). Each `ptp-*` agent also embeds its skill verbatim between `<!-- EMBED:START -->` / `<!-- EMBED:END -->` markers — regenerate with `-Sync`.

## Core Development Rules (from AGENTS.md)

1. **Never Hardcode Components:** Use global variants inside `src/components/ui`.
2. **Never Hardcode Text Colors:** Use theme tokens only. No `text-white`, `text-slate-*`, `text-gray-*`, `text-black`.
3. **Respect the Architecture:** Follow documented data flow and domain constraints.
4. **Destructive Actions:** Use `<ConfirmModal>` for deletions.
5. **Context Review:** Read last 3 entries in `.devops/logs/agent-changelog.md`.
6. **Subagent Wiki-First Mandate:** Subagent prompts MUST include wiki-first directive.
7. **Planning Protocol:** Multi-step tasks use `@pass-the-parcel`.
8. **Form Field Hygiene:** Every input/select/textarea has `id` + matching `<label htmlFor>`.

## Task Lookup
| Task | Read first | Then drill into |
|---|---|---|
| Building/editing UI component | `.wiki/components/components-index.md` | Specific component doc |
| Building/editing screen/view | `.wiki/features/features-index.md` | Specific feature doc |
| Writing a database query | `.wiki/database/database-index.md` | Specific schema doc |
| Editing overall layout/workspace shell | `.wiki/core/07-app-structure.md` | Layout component docs |
| Understanding state/context | `.wiki/core/04-state-context.md` | State management docs |
| Parsing CSV/XLSX import/export | `.wiki/logic/logic-index.md` | CSV Parser / xlsx utility |
| Extending utility/custom hook | `.wiki/logic/logic-index.md` | Specific util/hook doc |
| Touching AI/agentic workflows | `.wiki/core/15-ai-features.md` | AI client utility |
| Adding/editing form fields | `.wiki/core/09-design-system.md` S5c | `.wiki/core/10-validation-standards.md` |
| Asking question about codebase | `@wiki-query` skill | Cites `[Title](path)` from `.wiki/` |
| Recording knowledge-capture | `@knowledge-capture` skill | `.wiki/core/18-knowledge-capture.md` |

## PTP Lifecycle (canonical — 4 gates)
`BACKLOG` -> `PHASE_1` -> `PHASE_3` -> `PHASE_5` -> `PHASE_7` -> `PHASE_9` -> `COMPLETE`

**Gates (hard stops):** A (Scope, after Phase 3) -> B (Spec & Plan, after Phase 5) -> C (Peer Reviews, after Phase 7) -> D (Implementation, after Phase 9)

**Revision loop:** `PHASE_7` -> (Gate B or C fails) -> `PHASE_5_REVISION` -> `PHASE_5` -> (Phases 6-7 re-run) -> `PHASE_7` -> Gate C

**Failure states:** Gate A rejected -> `PHASE_1`. Execution rolled back after two failed self-healing attempts -> `PHASE_8_FAILED` (orchestrator routes retry / `PHASE_5_REVISION` / user decision).

**Gate flips:** gates flip to `APPROVED`/`REJECTED` only AFTER the user's (or AUTO verification's) verdict, recorded by the orchestrator. Executing agents halt with their gate `OPEN`.

**Modes:** `USER-MANAGED` (default — every gate halts for the user) / `AUTO` (orchestrator auto-clears Gates A-C after mechanical verification; Gate D always requires the human).

**Agents (topology axis — the second, orthogonal axis):** `MULTI` (default) / `SINGLE`. This axis is **independent of `Mode`**:
- `MULTI` = **comprehensive plan** — orchestrator delegates each phase group to its `ptp-*` sub-agent; Groups C run as independent, context-isolated reviewers.
- `SINGLE` = **fast plan** — orchestrator executes each phase group's persona inline (no `task` spawns); Group C collapses to a self-review checkpoint. Same plan file, same lifecycle states, same one-phase-grouping-per-session bound, same Gate D human sign-off.

**Selection is driven by task complexity** (blast radius, contract/schema change, reversibility/risk, ambiguity, novelty). All signals low -> propose `SINGLE`; any signal high -> `MULTI`. The orchestrator **recommends**, the user **confirms** at plan start. Full contract: `@pass-the-parcel` § Agent Topology.

## Workspace Layout
- Active plans: `.devops/plans/[slug]-plan.md`
- Plan template: `.devops/plans/template-plan.md`
- Per-run workspace: `.opencode/plans/run-[slug]/` (created by the orchestrator at plan start; reviews live here)
- Reviews: `run-[slug]/reviews/product_review.md`, `run-[slug]/reviews/arch_review.md`
- Audit log: `run-[slug]/decision_log.md`
- Archived plans: `.devops/archive/`

<!-- ORCHESTRATOR-ONLY:START (inlined into parcel.agent.md only — not the ptp-* subagents) -->
## PTP Delegation Map (canonical)
| Phase(s) | Sub-agent | Capability Class | Output |
|---|---|---|---|
| 1-3 | `ptp-context-hunter` | retrieval/inventory | Scope perimeter + Phase 3 questions (drafted; orchestrator asks one at a time) |
| 3.5 (AUTO) | `ptp-phase3-answerer` | retrieval/Q&A | Auto-resolutions (or `Unresolvable:` hard halt) |
| 4-5 (+ revision) | `ptp-high-visionary` | deep planning/authoring | Phase 4 spec + Phase 5 plan in plan file |
| 6 | `ptp-grumpy-architect` | adversarial review | `reviews/arch_review.md` (`PASS` / `**REJECTED:**` first line) |
| 7 | `ptp-smooth-operator` | product review | `reviews/product_review.md` (`PASS` / `**REJECTED:**` first line) |
| 8-9 | `ptp-code-surgeon` | execution | Executed code + verification proof |

## Model Registry (per-subagent bindings — no hardcoded model names in prose)
Model routing is **declarative**: each agent/subagent file carries its own `model:` line in YAML frontmatter, and the runtime mounts that file on that model. The orchestrator delegates by subagent name only and NEVER passes a model at spawn time. Each subagent is chosen independently — use the `@model-routing` skill's decision matrix when (re)binding.

Canonical binding table (validated by `scripts/check-parcel-prefix.ps1`; VS Code column = `.devops/agents/*.agent.md|*.subagent.md` frontmatter, opencode column = the opencode runtime — `opencode.json` `agent.<key>.model`). **This seed table is an example binding, not a mandate** — each satellite authors its own `base-context.md` and rebinds per its available models. Current template routing: **all models route to DeepSeek V4.1 Flash** (uniform binding by user direction, 2026-09-11 — capability classes are retained for future rebinding):

| Agent key | Capability class | VS Code model | opencode model |
|---|---|---|---|
| parcel | orchestration | DeepSeek V4.1 Flash | opencode-go/deepseek-v4.1-flash |
| ptp-context-hunter | retrieval/inventory | DeepSeek V4.1 Flash | opencode-go/deepseek-v4.1-flash |
| ptp-phase3-answerer | retrieval/Q&A | DeepSeek V4.1 Flash | opencode-go/deepseek-v4.1-flash |
| ptp-high-visionary | deep planning/authoring | DeepSeek V4.1 Flash | opencode-go/deepseek-v4.1-flash |
| ptp-grumpy-architect | adversarial review | DeepSeek V4.1 Flash | opencode-go/deepseek-v4.1-flash |
| ptp-smooth-operator | product review | DeepSeek V4.1 Flash | opencode-go/deepseek-v4.1-flash |
| ptp-code-surgeon | execution | DeepSeek V4.1 Flash | opencode-go/deepseek-v4.1-flash |

**Binding rule:** every parcel/ptp agent's `model:` in its frontmatter MUST equal its row above (correct column for the runtime). Agents MUST NOT assume a specific vendor model exists — read your own configured model if asked. To change a binding, follow the `@model-routing` skill §3 (frontmatter + registry row + `-Sync` + validation).
<!-- ORCHESTRATOR-ONLY:END -->
