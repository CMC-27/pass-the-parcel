---
name: sprint-run
description: 'Make sure to use this skill whenever the user says "@sprint-run", "run the sprint", "batch the sprint queue", "run all the sprint plans", or wants the committed sprint queue executed unattended. Walks the ACTIVE sprint queue, computes the eligible set per claim, claims each eligible plan on the trunk, spawns one ptp-parcel-fast per plan (locked AUTO + SINGLE, fresh context each), and emits one consolidated Gate D report. Stops the line on any hard failure. Distinct from @sprint-plan (opens a sprint) and @sprint-close (retires it).'
version: 8
updated: 2026-09-16
---

# Sprint Run — Batch Queue Runner

> **Boundary:** This skill owns the **batch loop** that sits on top of `@pass-the-parcel`. It never restates the plan lifecycle, gates, or topology — those stay canonical in `@pass-the-parcel`. It computes eligibility, claims on the trunk, spawns one per-plan runner, and reports. It writes no implementation code itself.

## 1. Preflight (hard-halt)

Run in order; any failure halts the batch **before** the first claim.

1. **Resolve the ACTIVE sprint** from `.devops/backlog/SPRINTS.md`, mirroring `@sprint-status` § 1 (locate the row with status `🟢 ACTIVE`). No ACTIVE row → halt and suggest `@sprint-plan`. More than one ACTIVE row → flag the one-active-sprint violation and ask which is real.
2. **Clean trunk.** Require an empty `git status --porcelain`. A dirty tree is **never** auto-cleaned.
3. **Green baseline.** Require `check-parcel-prefix.ps1` and `check-utf8-agents.ps1` to both exit `0`.
4. **Reconcile orphans.** A plan that is `CLAIMED` in `.devops/plans/`, is in the ACTIVE sprint's queue set, and has **never reached `PHASE_9`** is an *orphan* (claimed, then the spawn died). Re-adopt it — resume its per-plan chain from its recorded `Status` — rather than excluding it forever just because it is no longer `QUEUED`.
5. **Offer a resume after a dirty HALT.** A prior HALT can leave the tree dirty, which would otherwise brick every later run. Surface the dirty set, then require the user to either commit/stash it or explicitly abandon the orphan's claim (`git mv` back to the queue + `claim_status: QUEUED`) before continuing.
6. **Dependency preflight.** Two mechanical checks over the still-unresolved queue set (the `QUEUED` plans plus any unarchived dependency they name):
   - **Cycle check.** Build the `depends_on` graph over that set. A cycle leaves *every* member permanently ineligible — it is a **queue defect**, not a transient block: terminate with the cycle members named and record it in the report's skip table. Never enter a loop, never reorder.
   - **Resolution forecast.** Run `python scripts/sprint_eligible.py` — § 2's authority, never a hand-derivation — and present its `claim_order` plus its terminal skip set with each skip's `reasons`. A forecast, not a contract: the predicate is re-evaluated per claim, so the executed set may differ. A non-zero exit is the § 5 stop-the-line, never a prose recomputation.
7. **Present the informed run preview**, then take **one** yes/no:
   - eligible plans, each with `code` + `title`;
   - the skip list, each entry with its reason;
   - the orphan re-adoption list, if any (surfaced for confirmation — the heuristic cannot tell a dead-batch orphan from a live concurrent claim);
   - the forecast claim order from step 6, and any flagged dependency cycle;
   - the **MULTI-worthy fork** — every plan the script flags in its advisory `complexity` key (`multi_worthy: true`), each with its declared `triage`, the mechanical `signals` that fired, and the dependents it would strand (`blocks`), for a per-plan answer of **accept batch risk** (`AUTO` + `SINGLE`, no independent reviewer) or **defer to manual**. One answer may cover all flagged plans, so acceptance keeps the run unattended — **the pause is opt-in**. Semantics: `.devops/rules/plan-lifecycle.md` § Claim Protocol → *MULTI-worthy Yield*;
   - a plain-language blast radius — *N plans → N×2 commits on your trunk (**no worktree isolation**), source edits, one Gate D at the end.*
   - the **lane readout** from the same JSON (`lanes`, `reserved_surfaces`): which plans are on the **serial** lane (a reserved surface `touches` hit, or the prefix-embed cascade — `.devops/rules/plan-lifecycle.md` § Claim Protocol → *Reserved Surfaces & the Lane Model*) and which are lane-B eligible. Present it as a **classification, not a promise of concurrency**: this loop is trunk-sequential and executes both lanes serially, so an empty lane B is the honest common case.
   Label the preview a **forecast**: the predicate is re-evaluated per claim, so the executed set may differ from it. Record the operator's approval. Decline → no claims, no writes.

## 2. Eligible set (per claim)

**Immediately before each claim**, re-apply the predicate against the **live** `.devops/plans/` — not once across the queue. That is what makes the batched-`PHASE_9` protection live rather than dead text.

**Computed, not reasoned.** Run `python scripts/sprint_eligible.py` from the workspace root; its JSON is authoritative for this section — `queue`, `eligible`, `claim_order`, `parallel_groups`, `skipped` (per-plan `reasons`), `in_flight`, `orphans`, `already_phased`, and the advisory `complexity` (`{triage, signals, multi_worthy, blocks}` per queued plan, consumed by § 1 step 7). Exit `0` means computed; **any non-zero exit is a stop-the-line (§ 5)** — the host does not re-derive eligibility from these clauses, and a missing or partial output is never a partial run. The clauses below are the definition that script implements (canonical: `.devops/rules/plan-lifecycle.md` § Claim Protocol → *Write-Set Overlap Predicate*, plus § Claim Front-Matter) and the reference a human reads; when the two could disagree, the script's exit code decides.

A queued plan is **eligible** iff all three hold:

1. It sits in the ACTIVE sprint folder with `claim_status: QUEUED`, **or** it is a preflight-reconciled orphan (rule 1.4).
2. Every code in its `depends_on` is **satisfied** — present in `.devops/archive/` (wrapped up and archived), **or** present in `.devops/plans/` with `claim_status: GATE_D_USER_APPROVAL` (executed through `PHASE_9` in this batch or a prior wave, Gate D `OPEN`, awaiting the human verdict). Any other state is **unmet**: still `QUEUED` in the sprint folder, or `CLAIMED` in `.devops/plans/` below `PHASE_9` (in flight). This is the **dependency** clause only — see clause 3 for the independent write-set clause.
3. **No overlap** between its `touches` and the `touches` of **any** plan file currently in `.devops/plans/` (the template excluded) — **including plans already batched to `PHASE_9`**.

**Normalization + overlap rule.** Canonical in `.devops/rules/plan-lifecycle.md` § Claim Protocol → *Write-Set Overlap Predicate*: normalize each entry (forward slashes, lowercase, strip a trailing `/**` or `/*`); A overlaps B when either normalized stem is a path-prefix of, or equal to, the other. Cite that definition — never restate a second dialect here.

**Queue-pairwise check (still-`QUEUED` set).** Before the first claim, run the same overlap test across every queued plan's `touches` pair. Two queued plans that overlap each other are ordered by **queue order**: the first is claimed, the later one is **skipped with its reason recorded**. If the overlap is only discovered at claim time, the outcome is the same — a recorded skip, never a silent drop and never a halt.

**Within-batch `depends_on`.** A dependency claimed earlier in this batch that has since reached `PHASE_9` (`claim_status: GATE_D_USER_APPROVAL`) is **satisfied** by clause 2 — the dependent becomes eligible and is reached by the fixpoint loop below. A dependency that is still **in flight** (`CLAIMED`, below `PHASE_9`) is **unmet**: its dependent is skipped with its reason recorded, never reordered. Clause 3 still applies independently: a satisfied dependency whose plan occupies overlapping files in `.devops/plans/` keeps blocking the dependent until it is archived.

**Fixpoint loop (applies to every pass of § 2).** The runner does not claim once and stop, and it does not topologically sort the queue. It **iterates**: apply clauses 1-3 to the remaining `QUEUED` set, claim the first eligible plan in **queue order**, run it to its terminal state, then re-apply clauses 1-3 to what remains — repeat until no remaining plan is eligible. Properties:
- **Bounded** — each pass claims exactly one plan or stops, so ≤ N passes for N queued plans.
- **Deterministic** — queue order decides ties; the loop never reorders the queue.
- **Cycle-safe** — a mutual `depends_on` leaves neither member eligible, so the loop terminates and the cycle is flagged per § 1 step 6.
- **Progress-correct** — a dependent whose dependency was just executed to `GATE_D_USER_APPROVAL` is picked up on a later pass, because the predicate reads the **live** `.devops/plans/`.

**Pre-existing `PHASE_9`.** A plan already at `PHASE_9` when the batch starts is skipped (already batched), not re-run.

Anything failing 1-3 is **skipped with its reason recorded**; a skip never halts the batch.

**Lanes are advisory (do not re-derive them).** The same JSON carries `lanes` (`{code: "serial"|"parallel"}` over the queued set) and `reserved_surfaces` (the set the script used). They classify *writability*, not *order*: this loop stays trunk-sequential, so `claim_order` remains the only ordering and both lanes are executed serially. A serial-lane plan is never packed into `parallel_groups` — but `parallel_groups` schedules nothing, so nothing about the fixpoint, the skip table or the claim loop changes. Never hard-code the reserved surfaces here: the definition is `.devops/rules/plan-lifecycle.md` § Claim Protocol → *Reserved Surfaces & the Lane Model*, and the script is its executable embodiment.

## 3. Per plan (serial)

Narrate one line before each spawn: `plan k/N: <code> claimed → running`. Then:

1. `git mv` the plan into `.devops/plans/`, fill the claim front-matter (`claim_status: CLAIMED`, `owner`, `claimed_at`, `last_touch`), and commit with the exact literal `claim: <code>` on the trunk. **No `git worktree add`** — this batch path is trunk-sequential.
2. Spawn **one** `ptp-parcel-fast` for that plan path. The spawned runner writes the plan's `## ⚙️ Plan Settings` block at claim time as its **first** action (frozen `Mode=AUTO` + `Agents=SINGLE`); the host never authors it. On return, the plan sits at `PHASE_9` + `claim_status: GATE_D_USER_APPROVAL`. **The runner never touches `machinery-version`** — the counter has one writer per batch (§ 6 and `.devops/rules/plan-lifecycle.md` § Claim Protocol → *Counter Ownership*), and N runners bumping from one shared base is the collision that rule exists to remove. The runner **does** still re-inline the prefix (`-Sync`) when its plan edits a reserved prefix surface, because a red `check-parcel-prefix.ps1` would fail the next claim's green baseline; the host owns that **invariant** — see § 1 step 3 — not the repair.
3. **Re-apply § 2 to the remaining `QUEUED` set before the next claim** — that is the fixpoint loop, and it is what lets a dependent follow its dependency inside one batch. A `SKIP` continues the batch; a `HALT` stops it (§ 5).
4. **Deferred plans (the MULTI-worthy yield).** If the operator deferred a flagged plan at § 1 step 7, that plan is a **hole in the line**. Keep claiming and running in `claim_order` as normal, but **never claim past the hole**: on reaching the deferred plan's position, halt and emit the partial report (§ 6) with a `DEFERRED-MANUAL` row carrying the plan's code, the topology it needs (`MULTI`), its `blocks` from the script's `complexity` output, and the resume path. Nothing is persisted — the next invocation recomputes the fork from live state, which is the resume contract. Full semantics: `.devops/rules/plan-lifecycle.md` § Claim Protocol → *MULTI-worthy Yield*.

## 4. Terminal state

Leave each run plan at `Status: PHASE_9`, `claim_status: GATE_D_USER_APPROVAL`, still in `.devops/plans/`, **Gate D `OPEN`**. Never archive a plan. Never advance one past `PHASE_9`. Never flip a gate. `GATE_D_USER_APPROVAL` — not `CLAIMED` — is what marks a plan as executed-but-unverified, and it is exactly the state that satisfies a dependent's clause 2. **Retirement is not this skill's job:** a plan leaves this state only after the human verdict plus the follow-up wrap-up (§ 6).

## 5. Stop-the-line

Halt the batch immediately and report; already-completed plans keep their terminal `PHASE_9` state.

- Preflight: no ACTIVE sprint in `.devops/backlog/SPRINTS.md`.
- Preflight: non-empty `git status --porcelain` and no accepted resume path.
- Preflight: red baseline (`check-parcel-prefix.ps1` or `check-utf8-agents.ps1` exit ≠ `0`).
- Per plan: a Phase 3.5 `Unresolvable:` entry.
- Per plan: an `AUTO` gate whose outputs exist but fail the canonical **AUTO Gate Evidence Contract** (`.devops/rules/plan-lifecycle.md`) — a gate-critical section carrying a line-leading unchecked box or a bare `TBD`/`TODO`/`FIXME`, a Phase 4 acceptance-criteria table with no criterion + `Test Target` row, or a Phase 6 self-review with no acceptance-criterion row. **An unproven gate is not clearable.**
- Per claim: `scripts/sprint_eligible.py` exits non-zero (no or multiple ACTIVE sprint rows, an unparsable plan file, a failed shared-reader import). The host halts and reports the stderr cause — it never reasons the predicate out from prose on the failed path.
- Per plan: a self-review `**REJECTED:**` at the inline Phase 6 checkpoint (never an inline `PHASE_5_REVISION` loop).
- Per plan: `PHASE_8_FAILED` (rollback after two failed self-healing attempts).
- Per plan: the `ptp-parcel-fast` subagent returns `HALT <code>: <cause>`.
- Per batch: the operator **deferred** a flagged `MULTI`-worthy plan at § 1 step 7 — the **yield**. The batch stops at that plan's slot (§ 3 step 4); plans already run keep their terminal `PHASE_9` state. This is a halt for the human — **never a skip** (it is not in the skip table) and **never a deviation** (`.devops/rules/plan-lifecycle.md` § Deviations stays at four).

> **Not a halt (skip with reason):** unmet `depends_on` (the dependency is still `QUEUED`, or `CLAIMED` below `PHASE_9` — in flight); `touches` overlap (active, batched-`PHASE_9`, or claim-time queue-pairwise) — this clause bites independently of clause 2, so a **satisfied** dependency can still leave its dependent skipped while it occupies overlapping files; a plan already at `PHASE_9`; a dependency **cycle** (queue defect — terminate and name the members); no remaining plan eligible (the fixpoint is reached — report the terminal skip set).

## 6. Consolidated report (directed)

When the eligible set is drained, write one report at `.opencode/plans/run-sprint-{n}/sprint_run_report.md`:

- one row per run plan carrying **code + title**, terminal Status, touched files, Phase 9 verification evidence, and the plan's **lane** (`serial` / `parallel`);
- a **Skipped / deferred** table — every non-run plan with its reason (unmet `depends_on` — still `QUEUED` or in-flight `CLAIMED`; `touches` overlap; pre-existing `PHASE_9`; dependency cycle; claim-time queue-pairwise overlap), plus a **`DEFERRED-MANUAL`** row for any plan the operator deferred at § 1 step 7 — its code, the topology it needs (`MULTI`), the dependents it strands (the `blocks` closure from the script's `complexity` output), and the resume path;
- a **What to do next** block covering all three exits — **approved** → run the **follow-up batch wrap-up**: one separate, operator-invoked invocation of `@agent-wrap-up` (`SKILL.md` § Batch Scope) over the whole batched set. It is never an inline continuation of this loop; per-plan `@agent-wrap-up` stays valid and composes, and either path retires each plan to `COMPLETE` and archives it. **That wrap-up also owns the batch's single `machinery-version` increment** — read from `.devops/sync-manifest.yaml` at that moment, never a value captured earlier (`.devops/rules/plan-lifecycle.md` § Claim Protocol → *Counter Ownership*); this loop never bumps it, and neither does any runner it spawned. **A plan that fails the operator's test** → retry or `PHASE_5_REVISION`; **batch halted** → fix the cause, or abandon-claim the orphan back to `QUEUED`, then re-run `@sprint-run`. A **`DEFERRED-MANUAL` yield** takes the same exit: deliver the deferred plan through `@pass-the-parcel` in `MULTI`, then re-invoke `@sprint-run` (it re-runs the preflight and recomputes the fork from live state).

On `HALT`, **emit the partial report immediately** — completed plans at `PHASE_9`, the stop point, the cause, the resume path — instead of waiting for the queue to drain. Echo the **complete body** in chat: the report path is gitignored/ephemeral and cannot be linked from tracked docs.

## 7. Named exception

This batch loop is the explicit, machine-enforced **Strict Context Isolation** exception: each spawned `ptp-parcel-fast` runs one plan's Phases 1→9 in a single fresh context, and the claim is **trunk-sequential** (keeps `git mv` + the `claim: <code>` commit, drops `git worktree add`). Gate D is **batched** — deferred to one consolidated human verdict, never skipped; each executed plan carries `claim_status: GATE_D_USER_APPROVAL` until that verdict plus the follow-up wrap-up (§ 6 — batch-scoped or per-plan) retires it to `COMPLETE`. The loop itself never archives and never marks a plan complete. The one-phase-group-per-session bound stands for every other run. See `.devops/rules/plan-lifecycle.md` § Deviations.
