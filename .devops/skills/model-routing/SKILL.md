---
name: model-routing
description: Make sure to use this skill whenever the user mentions choosing a model, model selection, capability classes, binding models to agents or subagents, "which model for", or asking which model a run should use. Guides model choice for the parcel architecture under inherited routing — no agent declares a model, and the operator selects per gate or per batch at run time.
version: 10
updated: 2026-09-20
---

# SKILL: Model Routing (inherited routing + run-time selection)

The parcel architecture uses **inherited routing**. No agent or subagent declares a model; every agent runs on **the model selected in the CLI / picker**. Where a run actually spawns subagents, the **operator chooses** which model each gate uses, at run time.

This **supersedes registry-canonical binding** (`T1-E1.03`, 2026-09-13), which itself reversed `T1-E1.01` (2026-09-03, abstract capability slots). The lineage is recorded so the axis is never re-litigated blind: `.01` relocated the binding machinery and it kept growing; `.03` made the registry the single force-stamped source; this revision **deletes** the binding entirely rather than moving it again.

## 1. Model resolution (there is no binding surface)

| Layer | What it is | Where it lives |
|---|---|---|
| **Inherited default** | the model selected in the CLI / picker — the answer for every agent unless an override is passed | the runtime session |
| **Run-time override** | the operator's per-gate or per-batch choice for **one run** | the plan's frozen `Plan Settings.Models` row, or the batch report |
| **Capability class** | a *recommendation* label, not a binding — it shapes the question's guidance | `## Model Registry` in `.opencode/plans/base-context.md` (key + capability class, two cells) |

Rules:

1. **No agent declares a model.** Not agent frontmatter, not `opencode.json`/its seed, not the registry table. `scripts/check-parcel-prefix.ps1` asserts this by **absence** and reports `NOMODEL` per clean surface.
2. **A model is never hardcoded anywhere in the machinery.** The only place a model name appears is a plan's `Plan Settings.Models` row (and the batch report) — ephemeral, per-run, never synced, never stamped.
3. **The registry survives only as a capability-class reference.** It feeds the run-time question's guidance; it is not a source of truth for any model.
4. **Nothing propagates.** `@sync-architecture` reconciles the capability-class rows and **strips** any model it finds in a satellite; there is no stamping direction left.
5. **A model that cannot be honoured is never substituted silently.** Where a runtime cannot accept a spawn-time model, the run halts and says so (see §3).

## 2. Choosing a model (the recommendation matrix)

Ask four questions about the subagent's actual work, in order:

1. **Context volume** — does it read the whole plan + wiki + many code files, or a narrow slice?
2. **Reasoning depth** — does it need multi-step deduction (architecture flaws, edge cases) or mostly retrieval + formatting?
3. **Output fidelity** — does it write code to disk, or only markdown into the plan/review files?
4. **Cost sensitivity** — does it run once per plan, or in loops (revision rounds, re-reviews)?

Map the answers to a capability class — the label recorded in the registry — then recommend the cheapest model that satisfies all four. **This matrix produces a recommendation for a human, not a binding.**

| Capability class | Profile | Typical fit in the parcel pipeline |
|---|---|---|
| **Orchestration** | Small context window usage, routing + gate-keeping, terse output, runs the whole session so cost compounds | `parcel` / `parcel-sprint` orchestrators |
| **Retrieval / inventory** | Large read volume, shallow synthesis per item, structured checklists out, high volume → cost-sensitive | `ptp-context-hunter` |
| **Retrieval / Q&A** | Reads only mapped sources, answers with citations, no re-discovery | `ptp-phase3-answerer` |
| **Deep planning / authoring** | Must hold the entire architecture in mind, produce long coherent structured markdown, no code output | `ptp-high-visionary` |
| **Adversarial review** | Needs the strongest reasoning available — finds flaws the planner's own model class would miss; runs once per pass so cost is tolerable | `ptp-grumpy-architect` |
| **Product review** | UX-journey audit of a text plan, medium context, binary verdicts | `ptp-smooth-operator` |
| **Execution** | Writes code directly to disk; code fidelity and instruction-following beat everything; build/test loop absorbs mistakes, but a strong model reduces QA rounds | `ptp-code-surgeon` |
| **Independent audit** | Fresh-eyes verification, report-only, wants a different model family than the workers it audits when possible | `wiki-verifier` |

Anti-patterns:

- **Don't set every gate to the strongest model.** Context-hunter reads far more tokens than it reasons about; a heavyweight model there multiplies cost for no quality gain.
- **Don't pick the adversarial reviewer on the same model as the planner without checking §2 question 2.** Review value comes from reasoning-capability asymmetry. Sharing a model is permitted; sharing a *blind spot* is what costs you.
- **Don't choose by vendor loyalty.** Choose by the capability class the gate's work actually demands.

## 3. Selecting models for a run (the only procedure)

Models are chosen **per run**, by the operator, through the ask tool. There is no file to edit.

| Path | Who asks | Granularity |
|---|---|---|
| `parcel` in `MULTI` | the orchestrator, at plan start, after `Mode`/`Agents` are confirmed | **per gate** — A / B / C / D, four questions at most |
| `parcel` in `SINGLE` | nobody — `SINGLE` spawns no subagents | recorded `N/A — no subagent spawns` |
| `@sprint-run` | the batch host, in the informed preview, **before** the single yes/no | **one answer for the whole batch** — each `ptp-parcel-fast` runs Phases 1→9 inline on a single model |

1. **Enumerate the available models from the provider**, never from a hardcoded list:
   `https://opencode.ai/zen/go/v1/models` returns an OpenAI-shaped payload —
   `{"object":"list","data":[{"id":"deepseek-v4.1-flash","object":"model",...}]}`. Offer `CLI default` first (the recommended answer), then the ids.
2. **Map gates to their subagents** using the delegation map — **A** = `ptp-context-hunter` (+ `ptp-phase3-answerer` in `AUTO`), **B** = `ptp-high-visionary`, **C** = `ptp-grumpy-architect` + `ptp-smooth-operator`, **D** = `ptp-code-surgeon`. Four gate questions, never one per subagent.
3. **Record the answer** in the plan's frozen `Plan Settings.Models` row — `CLI default` or `per-gate: A=<model>, B=<model>, C=<model>, D=<model>` — or, on the batch path, in `sprint_run_report.md` and then in each runner's `Plan Settings` (the runner records what it was handed; it never chooses).
4. **Pass the model at spawn time only where the runtime supports it.** Runtime capability differs and must not be blurred:

| Runtime | Spawn-time model | Behaviour |
|---|---|---|
| **VS Code** | **supported** — `runSubagent` gained an optional `model` parameter in **1.116.0** (vscode issue #298380, closed) | pass the operator's choice per gate |
| **opencode** | **not supported** — issue **#6651** and PR **#11377** are both open; the subagent tool exposes no model parameter | on a concrete override, **halt**; on `CLI default`, proceed normally |

5. **Halt loudly on an unhonourable override.** Never a silent no-op and never a silent downgrade: name the limitation, and offer *proceed with inherit* or *run on the supporting runtime*. This is the edge case **accepted out loud** rather than engineered around — deliberately **not** solved by duplicating agent files per model, which would reintroduce exactly the hardcoding this design removes.

## 4. Validation contract

`scripts/check-parcel-prefix.ps1` asserts the invariant by **absence**, and also proves the prefix invariant is untouched:

- **No model declared** — reports `NOMODEL` for each clean binding surface and fails on: a `model:` line in any binding file's frontmatter (11 files); an `agent.<key>.model` in `opencode.json` or its seed; a registry row carrying anything other than exactly two cells.
- **Coverage retained** — every registry key must resolve to a binding file and every binding file to a registry row; both directions still fail loudly.
- **Seed parity retained** — the seed registry and seed config are still compared against the live surfaces, now for *absence* and the 2-cell shape rather than for matching values.
- **Prefix integrity unchanged** — the inlined prefix must match `base-context.md` byte-for-byte, and each `ptp-*` agent's embedded skill must match its `SKILL.md`. `wiki-*` files carry no prefix and never enter this pass.
- **Sync strips, never stamps** — `sync-architecture.ps1` removes any model it finds in a satellite and re-validates the resulting JSON, reverting rather than shipping an unparsable config. Its `-SelfTest` proves the absence contract.

If validation fails after a manual edit, something declared a model that must not. Remove the declaration; do not "fix" the check.
