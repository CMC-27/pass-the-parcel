---
name: pass-the-parcel-model-orchestrator
description: Load this skill when running pass-the-parcel to apply the project's model orchestration mapping. Assigns specific models to each phase group (A-F) for cost and capability optimization.
---

# SKILL: Pass-the-Parcel — Model Orchestrator

Applies the project's assigned AI models to each pass-the-parcel phase group. When executing a parcel plan, the agent MUST use the model specified for the **Active Persona** / phase group.

---

## Model Assignment Matrix

| Group | Phases | Persona | Assigned Model |
|-------|--------|---------|----------------|
| **A** | 1-3 (Scoping & Context) | Scoper | `deepseek-v4-flash` |
| **B** | 4 (Detailed Planning) | Architect | `deepseek-v4-pro` |
| **C** | 5-6 (Peer Reviews) | Product Owner + Senior Dev | `mimomax-m3` |
| **D** | 7-8 (Execution & Verification) | Executor | `deepseek-v4-flash` |
| **E** | 9 (User Review & Tweaks) | Executor | `deepseek-v4-flash` |
| **F** | 10 (Document & Wrap Up) | Architect | `deepseek-v4-flash` |

---

## Rationale

| Model | Applied To | Why |
|-------|-----------|-----|
| `deepseek-v4-flash` | Groups A, D, E, F | Fast, low-cost exploration & execution — ideal for scoping, iterative coding, and wrap-up tasks where speed matters more than depth. |
| `deepseek-v4-pro` | Group B | Stronger reasoning for architecture decisions, complexity analysis, and producing detailed execution plans with precise file-level instructions. |
| `mimomax-m3` | Group C | Used for the peer-review gate — audits product logic (PO lens) and code hygiene (Senior Dev lens) with a focus on catching regressions, security gaps, and architectural drift. |

---

## Orchestration Protocol

1. **Before starting any parcel session**, load this skill alongside `pass-the-parcel`.
2. Identify the **Active Persona** from the plan's State Dashboard.
3. Look up the assigned model from the matrix above.
4. If the current runtime does not support the assigned model, use the best available fallback and note it in the plan.
5. **Gate transitions trigger a model swap** — the next session must use the model assigned to the next phase group.
