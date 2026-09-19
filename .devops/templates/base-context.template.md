<!--
type: template
version: 20
updated: 2026-09-20

SEED TEMPLATE — copy to <satellite root>/.opencode/plans/base-context.md and customize.

WARNING: this file is the canonical shared PREFIX for all parcel/ptp agents. The shared
prefix (everything above the ORCHESTRATOR-ONLY block) is inlined byte-for-byte after the
YAML frontmatter of every .devops/agents/parcel.agent.md,
.devops/agents/parcel-sprint.agent.md
and .devops/agents/ptp-*.subagent.md file. The ORCHESTRATOR-ONLY block (delegation map +
model registry + orchestrator presets) is inlined only into the orchestrator agents
(parcel.agent.md, parcel-sprint.agent.md). Editing it requires re-running
`scripts/check-parcel-prefix.ps1 -Sync`, otherwise agents run on a stale prefix and the
cache-anchor contract breaks. Each ptp-* agent also embeds its skill verbatim between EMBED
markers — regenerate with -Sync.

Sections marked CUSTOMIZE are workspace-specific. The delegation map + model registry are
MACHINERY — mirror them exactly from the pass-the-parcel skill or downstream agents will
normalize model aliases inconsistently.
-->

> **PREFIX-LOCKED:** Canonical shared prefix for all parcel/ptp agents. The **shared prefix** (everything above the ORCHESTRATOR-ONLY block) is inlined byte-for-byte after the YAML frontmatter of every `.devops/agents/parcel.agent.md`, `.devops/agents/parcel-sprint.agent.md` and `.devops/agents/ptp-*.subagent.md` file. The **ORCHESTRATOR-ONLY block** (delegation map + model registry + orchestrator presets) is inlined only into the orchestrator agents (`parcel.agent.md`, `parcel-sprint.agent.md`). Do NOT edit either block in any agent file — edit this file and re-sync (see `scripts/check-parcel-prefix.ps1`). Each `ptp-*` agent also embeds its skill verbatim between `<!-- EMBED:START -->` / `<!-- EMBED:END -->` markers — regenerate with `-Sync`.

## Core Development Rules (from AGENTS.md)

<!-- CUSTOMIZE: condense your AGENTS.md rules to one line each. Keep numbering identical
     between AGENTS.md and here so agents can cross-reference. -->
1.
2.
3.
4. **Chunked Write Discipline:** Never materialise a large file in one `write`/`edit` — the editor stalls on big payloads ("Preparing write…"). Write a skeleton (frontmatter + headings + a unique placeholder per section) small, then fill each section with its own small `edit` replacing that placeholder; cap each call at ~60–100 lines. `write` overwrites, never appends — on a stall, `read` what landed and continue; never re-send the whole payload.
5. **User-Facing Conversation:** Dev to product owner — practical outcomes first, plain words, no unexplained jargon. See `.wiki/rules/language/communication-rules.md` § User-facing conversation.

**Managed Simplicity (first principle).** We do one thing, we do it well, and we do it fast. Structure must earn its cost: one canonical home per rule, one deterministic check per invariant, no surface that has stopped paying for itself. We do not build machinery for edge cases — we remove or accept them. Depth (the wiki, the pipeline) is bought for outcomes. See `.devops/rules/managed-simplicity.md`.

## Task Lookup
<!-- CUSTOMIZE: the rows agents need mid-execution (a subset of AGENTS.md's table is fine). -->
| Task | Read first | Then drill into |
|---|---|---|
| Asking question about codebase | `@wiki-query` skill | Cites `[Title](path)` from `.wiki/` |

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
- `SINGLE` = **fast plan** — orchestrator executes each phase group's persona inline **in the same session** (no `task` spawns); Group C collapses to a self-review checkpoint. Same plan file, same lifecycle states, same per-group delegation, same Gate D human sign-off — except the `@sprint-run` batch path, which runs one plan's Phases 1→9 in a single `ptp-parcel-fast` run (see `.devops/rules/plan-lifecycle.md` § Deviations).

**One session, one plan.** The orchestrator stays in the session it started in and advances group to group there — spawning the next `ptp-*` subagent (`MULTI`) or running the next persona inline (`SINGLE`); a new session is **never** requested of the operator, and a handoff note is **never** written into a plan. See `@pass-the-parcel` § Review Gates.

**Selection is driven by task complexity** (blast radius, contract/schema change, reversibility/risk, ambiguity, novelty). All signals low -> propose `SINGLE`; any signal high -> `MULTI`. The orchestrator **recommends**, the user **confirms** at plan start — unless the orchestrator runs a **locked preset** that fixes one or both axes (see **Orchestrator Presets** in the orchestrator prefix). Full contract: `@pass-the-parcel` § Agent Topology.

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
- Claim front-matter on every plan: `code` / `sprint` / `claim_status` / `owner` / `claimed_at` / `last_touch` / `touches` / `depends_on` / `triage`. `claim_status` is NOT the pipeline `Status`; `triage` is the commit-time topology recommendation (`@sprint-plan` § 4c), not the frozen `Plan Settings` `Agents` config.
- Claim = no unmet `depends_on` (every dependency in `.devops/archive/` **or** in `.devops/plans/` with `claim_status: GATE_D_USER_APPROVAL`) + no `touches` overlap -> `git mv` the plan into `.devops/plans/` and commit `claim: <code>` on the trunk. All work runs in place on the trunk — no `git worktree`, no plan branch. One claim at a time (see `.devops/rules/plan-lifecycle.md` § Claim Protocol). The `touches`-overlap clause is a separate blocker: a satisfied dependency does not clear an overlap.
- Shared files (`sprint.md`, `backlog-index.md`, `agent-changelog.md`, `.devops/sync-manifest.yaml`, `.devops/logs/version-history.md`) are edited directly on the working tree at claim/close time — never from unclaimed work.
- Full protocol: `.devops/rules/plan-lifecycle.md` § Claim Protocol.

<!-- ORCHESTRATOR-ONLY:START (inlined into the orchestrator agents — parcel.agent.md + parcel-sprint.agent.md — not the ptp-* subagents) -->
## PTP Delegation Map (canonical)
<!-- MACHINERY: keep verbatim unless the pass-the-parcel skill itself changes. -->
| Phase(s) | Sub-agent | Capability Class | Output |
|---|---|---|---|
| 1-3 | `ptp-context-hunter` | retrieval/inventory | Scope perimeter + Phase 3 questions (drafted; orchestrator relays — batched where the ask surface supports it) |
| 3.5 (AUTO) | `ptp-phase3-answerer` | retrieval/Q&A | Auto-resolutions (or `Unresolvable:` hard halt) |
| 4-5 (+ revision) | `ptp-high-visionary` | deep planning/authoring | Phase 4 spec + Phase 5 plan in plan file |
| 6 | `ptp-grumpy-architect` | adversarial review | `reviews/arch_review.md` (`PASS` / `**REJECTED:**` first line) |
| 7 | `ptp-smooth-operator` | product review | `reviews/product_review.md` (`PASS` / `**REJECTED:**` first line) |
| 8-9 | `ptp-code-surgeon` | execution | Executed code + verification proof |
| batch (sprint queue) | `ptp-parcel-fast` (spawned by `parcel-sprint` only) | execution | One plan run Phases 1-9 -> `PHASE_9` (`claim_status: GATE_D_USER_APPROVAL`), Gate D `OPEN` |

## Model Registry (capability classes — no agent declares a model)
Model routing is **inherited**: no agent or subagent carries a `model:` line in its frontmatter, and no `opencode.json` carries an `agent.<key>.model`. Every agent runs on **the model selected in the CLI / picker**. Where a run spawns subagents, the orchestrator asks the operator which model each gate should use and passes it at spawn time **on runtimes that support it**; where the runtime cannot honour the choice, the run halts explicitly rather than substituting silently.

This table survives as a **capability-class reference only** — it is the recommendation input for that run-time question, never a binding. `scripts/check-parcel-prefix.ps1` validates its **shape and coverage**: exactly two cells per row, every registry key resolving to a binding file and every binding file to a row.

| Agent key | Capability class |
|---|---|
| parcel | orchestration |
| ptp-context-hunter | retrieval/inventory |
| ptp-phase3-answerer | retrieval/Q&A |
| ptp-high-visionary | deep planning/authoring |
| ptp-grumpy-architect | adversarial review |
| ptp-smooth-operator | product review |
| ptp-code-surgeon | execution |
| parcel-sprint | orchestration |
| ptp-parcel-fast | execution |
| wiki-writer | deep planning/authoring |
| wiki-verifier | independent audit |

**Binding rule (inverted).** No binding surface may declare a model — not agent frontmatter, not `opencode.json` or its seed, not this table. A `model:` line in any binding file, an `agent.<key>.model` in either config, or a third cell in any row above is a **hard failure** of `scripts/check-parcel-prefix.ps1`, which reports `NOMODEL` per clean surface. Agents MUST NOT assume a specific vendor model exists — read your own inherited model if asked. To choose models for a run, follow the `@model-routing` skill §3 (the run-time selection step); to change an agent's **capability class**, see §2 of the same skill.

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
