<!--
type: template
version: 7
updated: 2026-09-13

SEED TEMPLATE — copy to <satellite root>/.opencode/plans/base-context.md and customize.

WARNING: this file is the canonical shared PREFIX for all parcel/ptp agents. The shared
prefix (everything above the ORCHESTRATOR-ONLY block) is inlined byte-for-byte after the
YAML frontmatter of every .devops/agents/parcel.agent.md and .devops/agents/ptp-*.subagent.md
file. The ORCHESTRATOR-ONLY block (delegation map + model registry) is inlined only into
parcel.agent.md. Editing it requires re-running `scripts/check-parcel-prefix.ps1 -Sync`,
otherwise agents run on a stale prefix and the cache-anchor contract breaks. Each ptp-*
agent also embeds its skill verbatim between EMBED markers — regenerate with -Sync.

Sections marked CUSTOMIZE are workspace-specific. The delegation map + model registry are
MACHINERY — mirror them exactly from the pass-the-parcel skill or downstream agents will
normalize model aliases inconsistently.
-->

> **PREFIX-LOCKED:** Canonical shared prefix for all parcel/ptp agents. The **shared prefix** (everything above the ORCHESTRATOR-ONLY block) is inlined byte-for-byte after the YAML frontmatter of every `.devops/agents/parcel.agent.md` and `.devops/agents/ptp-*.subagent.md` file. The **ORCHESTRATOR-ONLY block** (delegation map + model registry) is inlined only into `parcel.agent.md`. Do NOT edit either block in any agent file — edit this file and re-sync (see `scripts/check-parcel-prefix.ps1`). Each `ptp-*` agent also embeds its skill verbatim between `<!-- EMBED:START -->` / `<!-- EMBED:END -->` markers — regenerate with `-Sync`.

## Core Development Rules (from AGENTS.md)

<!-- CUSTOMIZE: condense your AGENTS.md rules to one line each. Keep numbering identical
     between AGENTS.md and here so agents can cross-reference. -->
1.
2.
3.

## Task Lookup
<!-- CUSTOMIZE: the rows agents need mid-execution (a subset of AGENTS.md's table is fine). -->
| Task | Read first | Then drill into |
|---|---|---|
| Asking question about codebase | `@wiki-query` skill | Cites `[Title](path)` from `.wiki/` |

## PTP Lifecycle (canonical — 4 gates)
`QUEUED` -> `CLAIMED` -> `PHASE_1` -> `PHASE_3` -> `PHASE_5` -> `PHASE_7` -> `PHASE_9` -> `COMPLETE`

**Gates (hard stops):** A (Scope, after Phase 3) -> B (Spec & Plan, after Phase 5) -> C (Peer Reviews, after Phase 7) -> D (Implementation, after Phase 9)

**Revision loop:** `PHASE_7` -> (Gate B or C fails) -> `PHASE_5_REVISION` -> `PHASE_5` -> (Phases 6-7 re-run) -> `PHASE_7` -> Gate C

**Failure states:** Gate A rejected -> `PHASE_1`. Execution rolled back after two failed self-healing attempts -> `PHASE_8_FAILED` (orchestrator routes retry / `PHASE_5_REVISION` / user decision).

**Gate flips:** gates flip to `APPROVED`/`REJECTED` only AFTER the user's (or AUTO verification's) verdict, recorded by the orchestrator. Executing agents halt with their gate `OPEN`.

**Modes:** `USER-MANAGED` (default — every gate halts for the user) / `AUTO` (orchestrator auto-clears Gates A-C after mechanical verification; Gate D always requires the human).

**Agents (topology axis — the second, orthogonal axis):** `MULTI` (default) / `SINGLE`. This axis is **independent of `Mode`**:
- `MULTI` = **comprehensive plan** — orchestrator delegates each phase group to its `ptp-*` sub-agent; Groups C run as independent, context-isolated reviewers.
- `SINGLE` = **fast plan** — orchestrator executes each phase group's persona inline (no `task` spawns); Group C collapses to a self-review checkpoint. Same plan file, same lifecycle states, same one-phase-grouping-per-session bound, same Gate D human sign-off.

**Selection is driven by task complexity** (blast radius, contract/schema change, reversibility/risk, ambiguity, novelty). All signals low -> propose `SINGLE`; any signal high -> `MULTI`. The orchestrator **recommends**, the user **confirms** at plan start. Full contract: `@pass-the-parcel` § Agent Topology.

**Where they live:** both settings are recorded in the plan's **Plan Settings** block at the **TOP** of the plan file (frozen at plan start, read before any phase). They are NOT in the bottom `## 📍 State & Gates` section, which holds only mutable runtime state (Status / Active Persona / gates).

## Workspace Layout
<!-- CUSTOMIZE: your plan/archive/run directories if they differ from the blueprint defaults. -->
- Active (claimed) plans: `.devops/plans/[code]-[slug]-plan.md`
- Sprint queue: `.devops/sprints/sprint-{n}-<slug>/` (`sprint.md` + committed-but-unclaimed plans)
- Plan template: `.devops/plans/template-plan.md`
- Per-run workspace: `.opencode/plans/run-[slug]/` (created by the orchestrator at plan start; reviews live here)
- Reviews: `run-[slug]/reviews/product_review.md`, `run-[slug]/reviews/arch_review.md`
- Audit log: `run-[slug]/decision_log.md`
- Archived plans: `.devops/archive/`; closed sprint records: `.devops/archive/sprints/sprint-{n}-<slug>/`

## Concurrency & Claims (local, in-workspace)
- Lifecycle: backlog -> sprint queue -> `.devops/plans/` (claimed) -> `.devops/archive/`. Physical moves are signals; a plan keeps its stable `T{theme}-E{epic}.{impl}` code.
- Claim front-matter on every plan: `code` / `sprint` / `claim_status` / `owner` / `claimed_at` / `last_touch` / `touches` / `depends_on`. `claim_status` is NOT the pipeline `Status`.
- Claim = no unmet `depends_on` + no `touches` overlap -> `git mv` the plan into `.devops/plans/` and commit `claim: <code>` on the trunk -> `git worktree add` on branch `plan/<code>-<slug>`.
- Shared files (`sprint.md`, `backlog-index.md`, `agent-changelog.md`, `.devops/sync-manifest.yaml`) are edited ONLY on the trunk, never inside a plan branch.
- Full protocol: `.devops/rules/plan-lifecycle.md` § Claim Protocol.

<!-- ORCHESTRATOR-ONLY:START (inlined into parcel.agent.md only — not the ptp-* subagents) -->
## PTP Delegation Map (canonical)
<!-- MACHINERY: keep verbatim unless the pass-the-parcel skill itself changes. -->
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

Canonical binding table (validated by `scripts/check-parcel-prefix.ps1`; VS Code column = `.devops/agents/*.agent.md|*.subagent.md` frontmatter, opencode column = the opencode runtime — `opencode.json` `agent.<key>.model`). **This seed table is an example binding, not a mandate** — each satellite authors its own `base-context.md` and rebinds per its available models:

| Agent key | Capability class | VS Code model | opencode model |
|---|---|---|---|
| parcel | orchestration | | |
| ptp-context-hunter | retrieval/inventory | | |
| ptp-phase3-answerer | retrieval/Q&A | | |
| ptp-high-visionary | deep planning/authoring | | |
| ptp-grumpy-architect | adversarial review | | |
| ptp-smooth-operator | product review | | |
| ptp-code-surgeon | execution | | |

**Binding rule:** every parcel/ptp agent's `model:` in its frontmatter MUST equal its row above (correct column for the runtime). Agents MUST NOT assume a specific vendor model exists — read your own configured model if asked. To change a binding, follow the `@model-routing` skill §3 (frontmatter + registry row + `-Sync` + validation).
<!-- ORCHESTRATOR-ONLY:END -->
