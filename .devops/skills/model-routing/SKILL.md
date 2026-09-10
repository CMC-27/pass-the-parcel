---
name: model-routing
description: Make sure to use this skill whenever the user mentions choosing a model, model selection, capability classes, binding models to agents or subagents, rebinding a ptp-* subagent, "which model for", or editing the Model Registry in base-context.md. Guides the per-subagent model choice for the parcel architecture and applies the binding edit safely (frontmatter + registry + prefix sync + validation).
version: 4
updated: 2026-09-11
---

# SKILL: Model Routing (per-subagent model binding)

The parcel architecture uses **declarative model routing**: each agent and subagent file carries its own `model:` line in YAML frontmatter, and the runtime mounts that file on that model. The orchestrator **never** selects models at spawn time — it delegates by subagent name only, and the model follows automatically from the subagent's frontmatter.

## 1. Binding architecture (how models are attached)

There are exactly two places a model binding lives, and they must always agree:

| Layer | File | Format | Example |
|---|---|---|---|
| **Runtime binding** | `.devops/agents/parcel.agent.md`, `ptp-*.subagent.md` (VS Code) | display name | `model: Qwen3.8 Flash` |
| **Runtime binding** | `opencode.json` → `agent.<key>.model` (opencode) | provider ID | `"opencode-go/qwen3.8-flash"` |
| **Canonical registry** | `.opencode/plans/base-context.md` → `## Model Registry` table | both columns | one row per agent |

Rules:

1. **One `model:` line per file.** Never share, inherit, or template model values between subagents — each is chosen independently per §2.
2. **The orchestrator never passes `model:` to `runSubagent`.** Passing a model imperatively violates the prefix's "no hardcoded model names" rule and creates a second source of truth.
3. **The registry is documentation + validation target**, not a runtime lookup. It exists so `scripts/check-parcel-prefix.ps1` can verify every frontmatter binding hasn't drifted.
4. **Naming convention:** VS Code frontmatter uses the model's display name (`Qwen3.8 Flash`); opencode mirrors use the provider-qualified ID (`opencode-go/qwen3.8-flash`). Both must reference the *same underlying model*.

## 2. Choosing a model for a subagent (decision matrix)

Ask four questions about the subagent's actual work, in order:

1. **Context volume** — does it read the whole plan + wiki + many code files, or a narrow slice?
2. **Reasoning depth** — does it need multi-step deduction (architecture flaws, edge cases) or mostly retrieval + formatting?
3. **Output fidelity** — does it write code to disk, or only markdown into the plan/review files?
4. **Cost sensitivity** — does it run once per plan, or in loops (revision rounds, re-reviews)?

Map the answers to a capability class, then pick the cheapest model that satisfies all four:

| Capability class | Profile | Typical fit in the parcel pipeline |
|---|---|---|
| **Orchestration** | Small context window usage, routing + gate-keeping, terse output, runs the whole session so cost compounds | `parcel` orchestrator |
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

To change the model for one agent/subagent, or the whole pipeline:

1. **Decide per subagent** using §2 — record the rationale (one line) in the plan's `decision_log.md` if this happens mid-parcel-run.
2. **Edit the frontmatter** of the agent file(s):
   - `.devops/agents/<name>.agent.md` or `<name>.subagent.md` → `model: <display name>`
   - `opencode.json` → `agent.<name>.model` (opencode runtime) → `"<provider>/<model>"`
   - Never touch the PREFIX-LOCKED body of these files.
3. **Update the `## Model Registry` table** in `.opencode/plans/base-context.md` so the row matches the new frontmatter value.
4. **Re-sync the prefix** so the updated registry is inlined byte-for-byte into every agent file:
   `powershell -File scripts\check-parcel-prefix.ps1 -Sync`
5. **Verify:** run `powershell -File scripts\check-parcel-prefix.ps1` — all files must PASS *and* report no model-binding mismatches. Non-zero exit = fix before commit.
6. **No orchestrator changes.** `parcel.agent.md`'s workflow text never mentions concrete models; if it does, that is drift — remove it.

## 4. Validation contract

`scripts/check-parcel-prefix.ps1` checks two things per agent file:

- **Prefix integrity** — the inlined prefix matches `base-context.md` byte-for-byte (existing check).
- **Model binding** — each agent's frontmatter `model:` (VS Code column) equals its registry row, **and** `opencode.json` `agent.<key>.model` equals the registry's opencode column. A present agent block fails on a missing key, a mismatch, or the unresolved `<your provider/model>` placeholder; an absent `opencode.json` or absent/empty agent block is a documented SKIP for VS Code-only satellites.

If validation fails after a manual edit, the registry row and the frontmatter disagree — fix whichever one reflects the intended binding (usually the frontmatter was edited without step 3, or `-Sync` was skipped).
