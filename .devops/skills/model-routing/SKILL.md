---
name: model-routing
description: Make sure to use this skill whenever the user mentions choosing a model, model selection, capability classes, binding models to agents or subagents, rebinding a ptp-* subagent, "which model for", or editing the Model Registry in base-context.md. Guides the per-subagent model choice for the parcel architecture and applies the binding edit safely (frontmatter + registry + prefix sync + validation).
version: 7
updated: 2026-09-13
---

# SKILL: Model Routing (per-subagent model binding)

The parcel architecture uses **declarative model routing**: each agent and subagent file carries its own `model:` line in YAML frontmatter, and the runtime mounts that file on that model. The orchestrator **never** selects models at spawn time — it delegates by subagent name only, and the model follows automatically from the subagent's frontmatter.

## 1. Binding architecture (how models are attached)

There is exactly **one** source of a model binding, and **two derived runtime surfaces** that must always agree with it:

| Layer | File | Format | Example |
|---|---|---|---|
| **Canonical registry (the source)** | `.opencode/plans/base-context.md` → `## Model Registry` table | both columns | one row per binding file |
| *derived* Runtime binding | `.devops/agents/<key>.agent.md` / `<key>.subagent.md` (VS Code) | display name | `model: Qwen3.8 Flash` |
| *derived* Runtime binding | `opencode.json` → `agent.<key>.model` (opencode) | provider ID | `"opencode-go/qwen3.8-flash"` |
| *seed mirror* | `.devops/templates/base-context.template.md` + `.devops/templates/opencode.template.json` | same as the registry | cell-for-cell identical |

Rules:

1. **Binding files are `parcel*`, `ptp-*` and `wiki-*` agent files** in `.devops/agents/` (`wiki-writer.agent.md`, `wiki-verifier.subagent.md` included). Each needs a registry row; each registry row needs a file. Both directions are a hard failure when violated.
2. **Bindings are template-owned and force-propagated.** `@sync-architecture` stamps the source registry into every target's three surfaces on each sync — there is no preservation branch: existing rows are rewritten, and a registry row the target's `base-context.md` lacks is **inserted** (machinery v40+), so template-side registry growth reaches an existing satellite. A satellite-side edit is **transient**: the next sync reverts it. Rebind in the template (registry + seed mirror), not in the satellite.
3. **The orchestrator never passes `model:` to `runSubagent`.** Passing a model imperatively violates the prefix's "no hardcoded model names" rule and creates a second source of truth.
4. **The registry is the validation source**, not a runtime lookup: the runtimes read the two derived surfaces, and `scripts/check-parcel-prefix.ps1` proves all three agree (plus the seed mirror).
5. **Naming convention:** VS Code frontmatter uses the model's display name (`Qwen3.8 Flash`); opencode mirrors use the provider-qualified ID (`opencode-go/qwen3.8-flash`). Both must reference the *same underlying model*.

## 2. Choosing a model for a subagent (decision matrix)

Ask four questions about the subagent's actual work, in order:

1. **Context volume** — does it read the whole plan + wiki + many code files, or a narrow slice?
2. **Reasoning depth** — does it need multi-step deduction (architecture flaws, edge cases) or mostly retrieval + formatting?
3. **Output fidelity** — does it write code to disk, or only markdown into the plan/review files?
4. **Cost sensitivity** — does it run once per plan, or in loops (revision rounds, re-reviews)?

Map the answers to a capability class, then pick the cheapest model that satisfies all four:

| Capability class | Profile | Typical fit in the parcel pipeline |
|---|---|---|
| **Orchestration** | Small context window usage, routing + gate-keeping, terse output, runs the whole session so cost compounds | `parcel` / `parcel-fast` orchestrators |
| **Retrieval / inventory** | Large read volume, shallow synthesis per item, structured checklists out, high volume → cost-sensitive | `ptp-context-hunter` |
| **Retrieval / Q&A** | Reads only mapped sources, answers with citations, no re-discovery | `ptp-phase3-answerer` |
| **Deep planning / authoring** | Must hold the entire architecture in mind, produce long coherent structured markdown, no code output | `ptp-high-visionary` |
| **Adversarial review** | Needs the strongest reasoning available — finds flaws the planner's own model class would miss; runs once per pass so cost is tolerable | `ptp-grumpy-architect` |
| **Product review** | UX-journey audit of a text plan, medium context, binary verdicts | `ptp-smooth-operator` |
| **Execution** | Writes code directly to disk; code fidelity and instruction-following beat everything; build/test loop absorbs mistakes, but a strong model reduces QA rounds | `ptp-code-surgeon` |
| **Independent audit** | Fresh-eyes verification, report-only, wants a different model family than the workers it audits when possible | `wiki-verifier` |

Anti-patterns:

- **Don't default everything to the strongest model.** Context-hunter reads far more tokens than it reasons about; a heavyweight model there multiplies cost for no quality gain.
- **Don't bind the adversarial reviewer to the same concrete model as the planner without checking §2 question 2.** Review value comes from reasoning-capability asymmetry — if both bindings resolve to the same model, confirm the planner's model is genuinely the stronger reasoner, or rebind one. (Sharing a model is permitted; sharing a *blind spot* is what costs you.)
- **Don't bind by vendor loyalty.** Bind by the capability class the subagent's phase actually demands, and re-evaluate when a phase's scope changes.

When every agent is deliberately routed to a single model (e.g., one provider model is available across the whole pipeline), the matrix collapses: apply the same binding to all rows of the registry and note the uniform routing in the registry prose, so reviewers don't mistake it for drift.

## 3. Editing a binding (the only safe procedure)

Bindings are edited **in the template**, never in a satellite — a satellite-side edit is reverted by the next sync (§1 rule 2).

1. **Decide per subagent** using §2 — record the rationale (one line) in the plan's `decision_log.md` if this happens mid-parcel-run.
2. **Edit the source registry** — `.opencode/plans/base-context.md` → the `## Model Registry` row (VS Code column + opencode column). Then mirror it in `.devops/templates/base-context.template.md` and `.devops/templates/opencode.template.json`; `check-parcel-prefix.ps1` fails if the seed mirror disagrees.
3. **Never** hand-edit the binding surfaces in a satellite. In the template workspace the derived files are updated by the two commands below.
4. **Re-sync the prefix** so the updated registry is inlined byte-for-byte into every orchestrator agent file:
   `powershell -File scripts\check-parcel-prefix.ps1 -Sync`
5. **Verify:** run `powershell -File scripts\check-parcel-prefix.ps1` — all files must PASS *and* report a `MODEL` line for every binding file (12 today) plus `SEED-OC-MODEL` for every registry key. Non-zero exit = fix before commit.
6. **Propagate:** `powershell -File scripts\sync-architecture.ps1 -Target <satellite>` (or `pull-architecture.ps1` from the satellite) stamps the registry, the agent frontmatter and `opencode.json` in the target; registry rows the target lacks are **inserted** (machinery v40+). Keys absent from the target's `agent` block are reported as `BINDING-SKIP` and fail that target's own check — sync never restructures the repo-specific `opencode.json`.
7. **No orchestrator changes.** `parcel.agent.md`'s workflow text never mentions concrete models; if it does, that is drift — remove it.

## 4. Validation contract

`scripts/check-parcel-prefix.ps1` validates **six surfaces**: the live registry, the seed registry, each binding file's frontmatter, `opencode.json`, the seed opencode config, and (separately) prefix integrity for the PREFIX-LOCKED agents.

- **Prefix integrity** — the inlined prefix matches `base-context.md` byte-for-byte, and each `ptp-*` agent's embedded skill matches its `SKILL.md`. `wiki-*` files carry no prefix and never enter this pass.
- **Model binding** — every registry key resolves to an agent file and vice versa; each file's frontmatter `model:` equals the registry VS Code column; `opencode.json` `agent.<key>.model` equals the registry opencode column; the seed registry agrees cell-for-cell with the live registry; the seed opencode config carries the same models. A missing/empty `agent` block (or a missing `opencode.json`) is a **FAIL**, not a SKIP — the pre-v20 VS Code-only opt-out is retired.
- **Placeholders are fatal** — `<your provider/model>` anywhere in a seed or live config fails the check. There is no legal unbound state.

If validation fails after a manual edit, the registry row and a derived surface disagree — fix whichever one reflects the intended binding (usually the derived file was edited instead of the registry, or `-Sync` was skipped).
