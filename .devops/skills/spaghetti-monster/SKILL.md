---
name: spaghetti-monster
description: Make sure to use this skill whenever the user mentions "spaghetti", "spaghetti-monster", "god object", "find tangled code", "scan for complexity", "refactor opportunities", "codebase audit", "what needs refactoring", or asks to detect, untangle, or audit high-entropy, highly coupled, non-cohesive code. The monster is a Hunter — it scans the codebase, quantifies the spaghetti, and packages each high-value target into a backlog parcel plan with Phase 1 and Phase 2 pre-populated, ready for the user to pick up Phase 3 (user clarification) in a new conversation. It does NOT execute refactors from this skill — that work happens later via pass-the-parcel execution, with the monster optionally re-invoked as a Group D sub-skill.
---

# Spaghetti Monster — The Hunter

**One job: find the spaghetti, report it, package it for execution.**

The monster scans a target scope, quantifies the architectural debt against the Sensor Matrix, and produces two artifacts: a **ranked kill list** and one **backlog parcel plan per high-value target** with Phases 1 (Scope) and 2 (Context) fully pre-populated. The user then picks up Phase 3 (User Clarification) in a new conversation. Refactor execution is not in scope from this skill.

The monster is a **scoper, not a surgeon.** The surgery happens later, in a separate parcel-planned session.

---

## Pre-Run Checklist (Mandatory)

Before invoking the skill, both human and agent MUST verify their respective items. If any item is unchecked, halt and resolve before Stage 1.

**Human verifies:**
* [ ] I have a **specific scope to scan** ("`src/components/admin/`", "`src/views/estimator/`"), not a vague "find issues" request.
* [ ] I have a working tree I can snapshot if needed (`git status` clean or all changes intentional).
* [ ] I am willing to halt at Gate A (after the kill list) to confirm which targets become plans.
* [ ] I am ready to create one backlog parcel plan per accepted target, with a name and Theme-Epic code.
* [ ] I understand the monster does NOT execute refactors — execution happens later, one plan at a time.

**Agent verifies:**
* [ ] The project's `references/[project]-overrides.md` has been checked. If missing, warn and run hooks in default form (see §Hook D).
* [ ] `git` is available (required for the idempotency check on Stage 1 step 5).
* [ ] A real complexity analyzer is available (`eslint --rule complexity`, `complexity-report`, `ast-grep`, `lizard`, or `pmd`). If only the LLM fallback heuristic is available, halt and ask the user to confirm.
* [ ] The parcel-plan template is available at `.devops/plans/template-plan.md` for Stage 2.

---

## Invocation: How to Run

**Single invocation form:** `"spaghetti-monster on <target_scope>"`. The agent does the rest — scan, kill list, package into backlog plans, update the index.

**Examples:**
* `"Spaghetti-monster on src/components/admin/"` — scan the admin components directory.
* `"Spaghetti-monster on src/views/estimator/ProjectDashboard.jsx"` — scan a single file.
* `"Spaghetti-monster on src/hooks/"` — scan the hooks directory.

**What you get back:**
1. A ranked kill list of every function/module breaching the Sensor Matrix.
2. A backlog parcel plan per high-value target at `.devops/plans/<code>-<slug>-plan.md`, with Phases 1 + 2 fully pre-populated.
3. An entry added to `.devops/backlog/backlog-index.md` for each plan.

---

## When NOT to Use

This skill is **not** a general code-improvement tool. Do not invoke it for:

* **Performance optimization** — use targeted profiling and benchmarking.
* **Type-system migrations** (JS→TS, Flow→TS, CJS→ESM) — use a dedicated codemod.
* **Dependency upgrades** (React 17→18, Vite 4→5) — use upgrade tools and changelog audits.
* **New feature work** — any change that alters observable behavior is a feature, not a refactor.
* **Opportunistic metric-driven cleanup** — the monster only scans what the user asks it to scan.
* **Executing a refactor** — that's a separate concern, routed through the backlog parcel plan the monster created.

If the user wants both a scan AND an immediate refactor, do the scan first, then route the chosen target through normal parcel-plan execution. Do not collapse the two.

---

## Olfactory Sensor Matrix (Trigger Thresholds)

The monster flags **every** function/module breaching threshold. Clean code is not listed.

| Metric | Scent | Default Threshold | Signal |
|---|---|---|---|
| Cyclomatic Complexity (M) | Branchy logic paths | M >= 10 per function | Poor readability, high test friction |
| Coupling Between Objects (CBO) | Tangled import graph | CBO >= 8 per module | Shotgun-surgery risk |
| Lack of Cohesion (LCOM4) | Mixed concerns | LCOM4 >= 2 | God object |
| Cognitive Load Index | Arrow anti-pattern | >= 4 nested control structures | Exceeds working memory |

### Measurement (Required)

**A real complexity analyzer is mandatory for the primary score.** The LLM fallback heuristic is a sanity check, not a primary tool. If only the heuristic is available, halt and ask the user to explicitly accept heuristic-only measurement.

**If the heuristic and a real analyzer disagree by > 30% on any target, halt and ask the user which to trust.** Do not silently average, pick one, or pick the lower number.

**Preferred toolchain:** `eslint --rule 'complexity: ["error", { max: 10 }]' src/`, `npx complexity-report src/`, `ast-grep`, `lizard`, `pmd`. **LLM fallback heuristic** (with explicit user waiver): `1 +` count of `if`, `else if`, `case`, `for`, `while`, `catch`, `&&`, `||`, `?:`, `??`. CBO = distinct `import` paths. LCOM4 = distinct method-instance-variable clusters. Cognitive Load = max nesting depth.

---

## The Two-Stage Pipeline

Execute in order. **Stage 1 is non-negotiable.** A kill list without a real analyzer is noise.

### Stage 1 — The Hunt (Scan)

1. Walk `target_directory` and build a dependency graph of imports/exports.
2. Score every function/module against the Sensor Matrix using the **primary tool**.
3. Produce a ranked **kill list** with this schema:

| # | File | Lines | Peak M | CBO | Domain? | Top Offender(s) |
|---|---|---|---|---|---|---|

4. **Idempotency check:** for each kill-list target, search `.devops/logs/agent-changelog.md` for refactor entries on the same file in the last 90 days. If found, surface the prior entry; the user decides whether to create a new plan.
5. **Duplication check:** flag pairs of files that share > 50% of import paths AND have functions with overlapping names. Use `git diff --stat <fileA> <fileB>` to confirm. Cross-file duplicates are likely one extraction, not N flattenings — the kill list should recommend the single extraction target.
6. **Hook classification:** for each target, mark which Extension Hooks (A/B/C/D) apply. This becomes the hook requirements in Phase 2 of each plan.
7. **Halt at Gate A.** Present the kill list to the user. The user selects which targets become backlog parcel plans. Without this gate, the monster creates plans indiscriminately.

### Stage 2 — The Report (Backlog Packaging)

For each target the user accepts at Gate A:

1. **Assign a plan code** following the project's Theme-Epic numbering. If the project uses `T{theme}-E{epic}.{impl}` (e.g., `T7-E1.01`), assign the next number. If a new theme/epic is needed, propose one and ask the user to confirm.
2. **Create the plan file** at `.devops/plans/<code>-<slug>-plan.md` using the canonical template at `.devops/plans/template-plan.md`.
3. **Pre-populate Phase 1 (Expansion & Scoping):**
   * Target: file path, function name, line range
   * Metric breached: which sensor, value, threshold
   * In-Scope: the specific functions/modules the refactor will touch
   * Out-of-Scope: explicit perimeter
   * Perimeter Notes: key observations (e.g., "shared import set with 3 other modals")
4. **Pre-populate Phase 2 (Requirements & Context):**
   * Forensic Context Inventory checklist (all items to be marked done by the monster since the context is already gathered)
   * Relevant Existing Decisions pulled from `.wiki/core/18-knowledge-capture.md`
   * Relevant Docs Found (which wiki docs apply, with paths)
   * Relevant Code Found table (file, lines, peak M, what it does)
   * Common pattern (if duplication: show the shared structure)
   * Hook Requirements (which Extension Hooks apply and why)
 5. **Pre-populate Phase 3 (User Clarification)** with the **Default-And-Justify Question Protocol**:
    * Every question MUST include a recommended answer marked with `[★]` and a 1-line rationale.
    * Questions MUST be framed as: `[★] Q{N}: [question]? <recommendation: answer>`
    * The user must explicitly override to choose differently — reducing the cognitive load of blank questions.
    * Example format:
      > [★] Q1: Should X be extracted to Y or stay in Z? <recommendation: Y — already has precedent in csvParser.js >
 6. **State & Gates (bottom):** Status `BACKLOG`, Active Persona `Planner`, Gate A `OPEN`.
 7. **Append to `.devops/backlog/backlog-index.md`** under the appropriate theme/epic, with a one-line Goal statement.
 8. **Append a changelog entry** to `.devops/logs/agent-changelog.md` describing the scan: scope, kill list size, number of plans created.

The user can now open any plan file in a fresh conversation, review Phases 1-2, and proceed to Phase 3 (User Clarification) — the rest is normal pass-the-parcel execution.

---

## Extension Hooks

The hooks inform what context goes into Phase 2 of each generated plan. They are not enforced by this skill — enforcement happens later when the plan is executed.

### Hook A — Domain Context Gate

**Activates when:** the target function is domain-touching (references glossary terms, calls domain-specific services, or mutates domain entities with non-typed invariants).
**Effect on the plan:** Phase 2 includes a list of domain invariants, a "hydrated from" list of wiki docs, and a "tribal knowledge" section pulled from `18-knowledge-capture.md`.

### Hook B — Performance Budget Check

**Activates when:** the project has declared performance budgets.
**Effect on the plan:** Phase 2 includes the relevant budget, the measurement command, and the cap value.

### Hook C — External Dependency Guard

**Activates when:** the target calls a rate-limited, cost-incurring, or contract-bound external service.
**Effect on the plan:** Phase 2 includes the call-pattern constraints (batching, retry, auth) that the refactor must preserve.

### Hook D — Idempotency Guard

**Activates when:** the target file was refactored within the last 90 days.
**Effect on the plan:** Phase 2 includes the prior refactor entry and the user's decision rationale for re-targeting.

If a project has no overrides file, the hooks run in their default form. See `references/[project]-overrides.md` for project-specific implementations.

---

## Exit Criteria (Hunter Victory Gate)

The monster is done when every item is checked:

* [ ] Pre-Run Checklist completed at the start of the run
* [ ] Real complexity analyzer used as primary score (or user explicitly accepted heuristic)
* [ ] Kill list produced with all six columns (File, Lines, Peak M, CBO, Domain?, Top Offender)
* [ ] Idempotency check completed for every target
* [ ] Duplication check completed (cross-file candidates flagged)
* [ ] Hook classification completed for every target
* [ ] Gate A (kill list review) completed with user sign-off on which targets become plans
 * [ ] One backlog parcel plan created per accepted target, with Phases 1 and 2 fully pre-populated
 * [ ] Every Phase 3 question uses the Default-And-Justify format (`[★] recommended answer` + rationale)
  * [ ] State & Gates (bottom) on every plan set to `BACKLOG` with `Planner` persona, Gate A `OPEN`
* [ ] `.devops/backlog/backlog-index.md` updated with one row per new plan
* [ ] Changelog entry written to `.devops/logs/agent-changelog.md`
* [ ] User briefed on the next-step workflow ("open a plan in a new conversation, review Phases 1-2, proceed to Phase 3")

Any unchecked item means the run is incomplete. Do not declare victory.

---

## Reference: Execution Engine (Secondary Use)

This is the **secondary** use of the monster. It is invoked inside a parcel plan during Phases 7-8 of pass-the-parcel execution, never standalone from the initial skill invocation.

When called as a Group D sub-skill, the monster:
1. Receives a single, scoped target from the parcel plan's Phase 4 execution list.
2. Skips Stage 1 (already done) and the plan-creation step of Stage 2 (plan already exists).
3. Runs the **execution pipeline**: snapshot commit → regression harness → refactor → verify.
4. Uses `git checkout <sha> -- <files>` for rollback (never `git reset --hard`).
5. Honors the same Extension Hooks, but as hard gates, not just context providers.

**Do not invoke the monster in execution mode from a fresh conversation without a parcel plan.** The Hunter mode is the only first-class invocation. Execution mode is a follow-up that happens inside an existing plan.

For the full execution pipeline, see the prior v3.1 SKILL.md archived in `.devops/archive/`, or the `ptp-code-surgeon` skill which is the canonical execution persona.

---

## Spaghetti-Specific Rules

Editing discipline (surgical edits, no scope creep, no orphaned cleanup) is owned by `karpathy-guidelines`. The monster adds these constraints on top, scoped to the Hunter role:

* **Never trigger from metric opportunism.** The user must ask. The monster does not offer to scan unprompted.
* **Never execute a refactor from this skill.** Output is a kill list and plans, never a code change.
* **Never offer the user options at invocation time.** "Dry-run or full run?" is forbidden. There is one mode: Hunter.
* **One scope per invocation.** Do not scan `src/` then scan `src/components/admin/` in the same run. One target, one kill list, one packaging.
* **Never silently average** heuristic and analyzer scores when they disagree by > 30%. Ask the user.
* **Plans must pre-populate Phases 1 AND 2, not just 1.** A plan without context is a plan the next agent has to rebuild from scratch. That defeats the parcel pattern.

---

## Human Guard Rails

You are responsible for:

1. **Scope specificity.** Invoke with a specific scope (directory or file), not "scan the codebase."
2. **Kill list review at Gate A.** Manually review every target. Accept or reject each one. The monster identifies; you decide.
3. **Hook classification sanity check.** When the monster marks a target as domain-touching or external-service-touching, verify the classification.
4. **Plan code assignment.** Confirm or adjust the Theme-Epic numbering the monster proposes. The next agent reads the code first.
5. **Plan content review.** Spot-check one or two generated plans before relying on the batch. Catch any that look thin.
6. **Pickup workflow.** Open each plan in a fresh conversation, review Phases 1-2, then proceed to Phase 3 (User Clarification). The monster is done; the parcel plan takes over.

---

## Agent Guard Rails

You MUST:

1. **Verify the Pre-Run Checklist** at the start of every run. Halt if any item is unchecked.
2. **Load `references/[project]-overrides.md`** before Stage 1. If it doesn't exist, warn the user and run hooks in their default form.
3. **Use a real complexity analyzer** as the primary score. The LLM heuristic is a sanity check only.
4. **Halt at Gate A** after the kill list. Do not create plans without user sign-off.
5. **One plan per accepted target, no batching.** No plan that covers two unrelated targets.
 6. **Pre-populate Phases 1 AND 2** on every plan. Use `.devops/plans/template-plan.md` as the canonical scaffold.
 7. **Apply Default-And-Justify to Phase 3** on every plan. Every question MUST have a `[★] recommended answer` with rationale. Never leave a question bare.
 8. **Use the project's existing Theme-Epic numbering** when assigning plan codes. Propose a new theme/epic only if needed.
8. **Update `.devops/backlog/backlog-index.md`** with a row per new plan.
9. **Do not execute a refactor.** Output is a kill list and plans, never a code change.
10. **Do not offer execution options** at invocation time. There is one mode: Hunter.
11. **Never silently average** heuristic and analyzer scores when they disagree by > 30%. Ask the user.

---

## Invocation Parameters (Reference)

Documented for cross-framework compatibility. In opencode, these are expressed as plain-language flags in the user's request.

```json
{
  "target_scope": "<absolute or relative path>",
  "max_complexity_threshold": 10,
  "plan_code_prefix": "T{theme}-E{epic}"
}
```

* `target_scope` — required. Directory or single file.
* `max_complexity_threshold` — optional. Override Sensor Matrix defaults for parsers, state machines, generated code.
* `plan_code_prefix` — optional. Defaults to the project's existing Theme-Epic prefix (e.g., `T1-E1`). Override only for a new theme/epic.

---

## Project Overrides

The Extension Hooks ship in their **general form** above. To make them project-specific, create a `references/[project]-overrides.md` file in this skill's directory. The override file should define:

* **Hook A — Glossary:** domain terms, where documented, which modules are domain-touching.
* **Hook B — Budgets:** declared performance budgets and how to measure them.
* **Hook C — External services:** rate-limited / cost-incurring / contract-bound services and their call-pattern constraints.
* **Hook D — Idempotency window:** the "too recent to refactor" threshold (default 90 days).

If the override file does not exist, the hooks run in their default form. See `references/template-overrides.md` for a fill-in template.
