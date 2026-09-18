> **PREFIX-LOCKED:** Canonical shared prefix for all parcel/ptp agents. The **shared prefix** (everything above the ORCHESTRATOR-ONLY block) is inlined byte-for-byte after the YAML frontmatter of every `.devops/agents/parcel.agent.md`, `.devops/agents/parcel-sprint.agent.md` and `.devops/agents/ptp-*.subagent.md` file. The **ORCHESTRATOR-ONLY block** (delegation map + model registry + orchestrator presets) is inlined only into the orchestrator agents (`parcel.agent.md`, `parcel-sprint.agent.md`). Do NOT edit either block in any agent file — edit this file and re-sync (see `scripts/check-parcel-prefix.ps1`). Each `ptp-*` agent also embeds its skill verbatim between `<!-- EMBED:START -->` / `<!-- EMBED:END -->` markers — regenerate with `-Sync`.

## Core Development Rules (from AGENTS.md)

1. **Never Hardcode Components:** Use global variants inside `src/components/ui`.
2. **Never Hardcode Text Colors:** Use theme tokens only. No `text-white`, `text-slate-*`, `text-gray-*`, `text-black`.
3. **Respect the Architecture:** Follow documented data flow and domain constraints.
4. **Destructive Actions:** Use `<ConfirmModal>` for deletions.
5. **Context Review:** Read last 3 entries in `.devops/logs/agent-changelog.md`.
6. **Subagent Wiki-First Mandate:** Subagent prompts MUST include wiki-first directive.
7. **Planning Protocol:** Multi-step tasks use `@pass-the-parcel`.
8. **Form Field Hygiene:** Every input/select/textarea has `id` + matching `<label htmlFor>`.
9. **Chunked Write Discipline:** Never materialise a large file in one `write`/`edit` — the editor stalls on big payloads ("Preparing write…"). Write a skeleton (frontmatter + headings + a unique placeholder per section) small, then fill each section with its own small `edit` replacing that placeholder; cap each call at ~60–100 lines. `write` overwrites, never appends — on a stall, `read` what landed and continue; never re-send the whole payload.
10. **User-Facing Conversation:** Dev to product owner — practical outcomes first, plain words, no unexplained jargon. See `.wiki/rules/language/communication-rules.md` § User-facing conversation.

**Managed Simplicity (first principle).** We do one thing, we do it well, and we do it fast. Structure must earn its cost: one canonical home per rule, one deterministic check per invariant, no surface that has stopped paying for itself. We do not build machinery for edge cases — we remove or accept them. Depth (the wiki, the pipeline) is bought for outcomes. See `.devops/rules/managed-simplicity.md`.

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
`QUEUED` -> `CLAIMED` -> `PHASE_1` -> `PHASE_3` -> `PHASE_5` -> `PHASE_7` -> `PHASE_9` -> `COMPLETE`

**Claim status (orthogonal to the pipeline `Status`):** `QUEUED` -> `CLAIMED` (Phases 1-8) -> `GATE_D_USER_APPROVAL` (at `PHASE_9`, Gate D `OPEN`) -> `COMPLETE`. `GATE_D_USER_APPROVAL` is the terminal claim state of the `@sprint-run` batch path (it never archives on its own) and of the manual sequential sprint flow alike. `IN_PROGRESS` is retired.

**Gates (hard stops):** A (Scope, after Phase 3) -> B (Spec & Plan, after Phase 5) -> C (Peer Reviews, after Phase 7) -> D (Implementation, after Phase 9)

**Revision loop:** `PHASE_7` -> (Gate B or C fails) -> `PHASE_5_REVISION` -> `PHASE_5` -> (Phases 6-7 re-run) -> `PHASE_7` -> Gate C

**Failure states:** Gate A rejected -> `PHASE_1`. Execution rolled back after two failed self-healing attempts -> `PHASE_8_FAILED` (orchestrator routes retry / `PHASE_5_REVISION` / user decision).

**Gate flips:** gates flip to `APPROVED`/`REJECTED` only AFTER the user's (or AUTO verification's) verdict, recorded by the orchestrator. Executing agents halt with their gate `OPEN`.

**Modes:** `USER-MANAGED` (default — every gate halts for the user) / `AUTO` (orchestrator auto-clears Gates A-C **only** on positive, presence-based evidence — see `.devops/rules/plan-lifecycle.md` § AUTO Gate Evidence Contract; Gate D always requires the human).

**Agents (topology axis — the second, orthogonal axis):** `MULTI` (default) / `SINGLE`. This axis is **independent of `Mode`**:
- `MULTI` = **comprehensive plan** — orchestrator delegates each phase group to its `ptp-*` sub-agent; Groups C run as independent, context-isolated reviewers.
- `SINGLE` = **fast plan** — orchestrator executes each phase group's persona inline (no `task` spawns); Group C collapses to a self-review checkpoint. Same plan file, same lifecycle states, same per-group delegation, same Gate D human sign-off — except the `@sprint-run` batch path, which runs one plan's Phases 1→9 in a single `ptp-parcel-fast` run (see `.devops/rules/plan-lifecycle.md` § Deviations).

**Selection is driven by task complexity** (blast radius, contract/schema change, reversibility/risk, ambiguity, novelty). All signals low -> propose `SINGLE`; any signal high -> `MULTI`. The orchestrator **recommends**, the user **confirms** at plan start — unless the orchestrator runs a **locked preset** that fixes one or both axes (see **Orchestrator Presets** in the orchestrator prefix). Full contract: `@pass-the-parcel` § Agent Topology.

**Where they live:** both settings are recorded in the plan's **Plan Settings** block at the **TOP** of the plan file (frozen at plan start, read before any phase). They are NOT in the bottom `## 📍 State & Gates` section, which holds only mutable runtime state (Status / Active Persona / gates).

## Workspace Layout
- Active (claimed) plans: `.devops/plans/[code]-[slug]-plan.md`
- Sprint queue: `.devops/sprints/sprint-{n}-<slug>/` (`sprint.md` + committed-but-unclaimed plans)
- Plan template: `.devops/plans/template-plan.md`
- Per-run workspace: `.opencode/plans/run-[slug]/` (created by the orchestrator at plan start; reviews live here)
- Reviews: `run-[slug]/reviews/product_review.md`, `run-[slug]/reviews/arch_review.md`
- Audit log: `run-[slug]/decision_log.md`
- Archived plans: `.devops/archive/`; closed sprint records: `.devops/archive/sprints/sprint-{n}-<slug>/`

## Concurrency & Claims (local, in-workspace)
- Lifecycle: backlog -> sprint queue -> `.devops/plans/` (claimed) -> `.devops/archive/`. Physical moves are signals; a plan keeps its stable `T{theme}-E{epic}.{impl}` code.
- Claim front-matter on every plan: `code` / `sprint` / `claim_status` / `owner` / `claimed_at` / `last_touch` / `touches` / `depends_on` / `triage`. `claim_status` is NOT the pipeline `Status`; `triage` is the commit-time topology recommendation (`@sprint-plan` § 4c), not the frozen `Plan Settings` `Agents` config.
- Claim = no unmet `depends_on` (every dependency in `.devops/archive/` **or** in `.devops/plans/` with `claim_status: GATE_D_USER_APPROVAL`) + no `touches` overlap -> `git mv` the plan into `.devops/plans/` and commit `claim: <code>` on the trunk. All work runs in place on the trunk — no `git worktree`, no plan branch. One claim at a time (see `.devops/rules/plan-lifecycle.md` § Claim Protocol). The `touches`-overlap clause is a separate blocker: a satisfied dependency does not clear an overlap.
- Shared files (`sprint.md`, `backlog-index.md`, `agent-changelog.md`, `.devops/sync-manifest.yaml`, `.devops/logs/version-history.md`) are edited directly on the working tree at claim/close time — never from unclaimed work.
- Full protocol: `.devops/rules/plan-lifecycle.md` § Claim Protocol.

<!-- ORCHESTRATOR-ONLY:START (inlined into the orchestrator agents — parcel.agent.md + parcel-sprint.agent.md — not the ptp-* subagents) -->
## PTP Delegation Map (canonical)
| Phase(s) | Sub-agent | Capability Class | Output |
|---|---|---|---|
| 1-3 | `ptp-context-hunter` | retrieval/inventory | Scope perimeter + Phase 3 questions (drafted; orchestrator relays — batched where the ask surface supports it) |
| 3.5 (AUTO) | `ptp-phase3-answerer` | retrieval/Q&A | Auto-resolutions (or `Unresolvable:` hard halt) |
| 4-5 (+ revision) | `ptp-high-visionary` | deep planning/authoring | Phase 4 spec + Phase 5 plan in plan file |
| 6 | `ptp-grumpy-architect` | adversarial review | `reviews/arch_review.md` (`PASS` / `**REJECTED:**` first line) |
| 7 | `ptp-smooth-operator` | product review | `reviews/product_review.md` (`PASS` / `**REJECTED:**` first line) |
| 8-9 | `ptp-code-surgeon` | execution | Executed code + verification proof |
| batch (sprint queue) | `ptp-parcel-fast` (spawned by `parcel-sprint` only) | execution | One plan run Phases 1-9 -> `PHASE_9` (`claim_status: GATE_D_USER_APPROVAL`), Gate D `OPEN` |

## Model Registry (per-subagent bindings — no hardcoded model names in prose)
Model routing is **declarative**: each agent/subagent file carries its own `model:` line in YAML frontmatter, and the runtime mounts that file on that model. The orchestrator delegates by subagent name only and NEVER passes a model at spawn time. Each subagent is chosen independently — use the `@model-routing` skill's decision matrix when (re)binding.

Canonical binding table (validated by `scripts/check-parcel-prefix.ps1`; VS Code column = `.devops/agents/*.agent.md|*.subagent.md` frontmatter, opencode column = the opencode runtime — `opencode.json` `agent.<key>.model`). **This table is the single source of truth** — the frontmatter and `opencode.json` bindings are derived from it, and `@sync-architecture` force-stamps all three surfaces into every satellite on each sync. To change a binding, edit this table (and its seed mirror), run `check-parcel-prefix.ps1 -Sync`, then sync: a satellite-side edit is transient and is reverted by the next sync. Current template routing: **all models route to DeepSeek V4.1 Flash** (uniform binding by user direction, 2026-09-11 — capability classes are retained for future rebinding):

| Agent key | Capability class | VS Code model | opencode model |
|---|---|---|---|
| parcel | orchestration | DeepSeek V4.1 Flash | opencode-go/deepseek-v4.1-flash |
| ptp-context-hunter | retrieval/inventory | DeepSeek V4.1 Flash | opencode-go/deepseek-v4.1-flash |
| ptp-phase3-answerer | retrieval/Q&A | DeepSeek V4.1 Flash | opencode-go/deepseek-v4.1-flash |
| ptp-high-visionary | deep planning/authoring | DeepSeek V4.1 Flash | opencode-go/deepseek-v4.1-flash |
| ptp-grumpy-architect | adversarial review | DeepSeek V4.1 Flash | opencode-go/deepseek-v4.1-flash |
| ptp-smooth-operator | product review | DeepSeek V4.1 Flash | opencode-go/deepseek-v4.1-flash |
| ptp-code-surgeon | execution | DeepSeek V4.1 Flash | opencode-go/deepseek-v4.1-flash |
| parcel-sprint | orchestration | DeepSeek V4.1 Flash | opencode-go/deepseek-v4.1-flash |
| ptp-parcel-fast | execution | DeepSeek V4.1 Flash | opencode-go/deepseek-v4.1-flash |
| wiki-writer | deep planning/authoring | DeepSeek V4.1 Flash | opencode-go/deepseek-v4.1-flash |
| wiki-verifier | independent audit | DeepSeek V4.1 Flash | opencode-go/deepseek-v4.1-flash |

**Binding rule:** every binding agent's `model:` in its frontmatter MUST equal its row above (correct column for the runtime), and `opencode.json` `agent.<key>.model` MUST equal the opencode column. `scripts/check-parcel-prefix.ps1` fails on any mismatch, on a registry key with no agent file, on a binding file with no row, and on a seed registry or seed opencode config that disagrees with this table. Agents MUST NOT assume a specific vendor model exists — read your own configured model if asked. To change a binding, follow the `@model-routing` skill §3 (registry row + `-Sync` + validation; satellites receive it on their next sync).

## Orchestrator Presets (locked Mode / Topology)
Each orchestrator agent declares its Plan Settings defaults here. At plan start, read **your own row**:
- `ask` — run the selection step (recommend, user confirms).
- `locked` — write the preset values into the plan's **Plan Settings** block and **skip the selection question**.

| Agent key | Mode | Agents | Selection |
|---|---|---|---|
| `parcel` | USER-MANAGED | MULTI | `ask` |
| `parcel-sprint` | AUTO | `per-plan SINGLE` (governs each spawned `ptp-parcel-fast`; the host itself spawns) | locked (batch host) |

A locked preset is enforced **structurally** wherever the runtime can express it: `parcel-sprint`'s `opencode.json` `permission.task` block denies `"*"` and allows exactly two **named** targets — its per-plan runner `ptp-parcel-fast` (never anything else during a plan run) and `wiki-writer` (the follow-up batch wrap-up's read-heavy wiki prose only). No glob key is admitted, so the batch preset stays structural. `AUTO` auto-clears Gates A-C **only** on positive evidence — see `.devops/rules/plan-lifecycle.md` § AUTO Gate Evidence Contract; **Gate D always halts for the human**. Full contract: `@pass-the-parcel` § Agent Topology.
<!-- ORCHESTRATOR-ONLY:END -->
