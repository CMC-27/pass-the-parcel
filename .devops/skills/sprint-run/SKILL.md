---
name: sprint-run
description: 'Make sure to use this skill whenever the user says "@sprint-run", "run the sprint", "batch the sprint queue", "run all the sprint plans", or wants the committed sprint queue executed unattended. Walks the ACTIVE sprint queue, computes the eligible set per claim, claims each eligible plan on the trunk, spawns one ptp-parcel-fast per plan (locked AUTO + SINGLE, fresh context each), and emits one consolidated Gate D report. Stops the line on any hard failure. Distinct from @sprint-plan (opens a sprint) and @sprint-close (retires it).'
version: 1
updated: 2026-09-13
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
6. **Present the informed run preview**, then take **one** yes/no:
   - eligible plans, each with `code` + `title`;
   - the skip list, each entry with its reason;
   - the orphan re-adoption list, if any (surfaced for confirmation — the heuristic cannot tell a dead-batch orphan from a live concurrent claim);
   - a plain-language blast radius — *N plans → N×2 commits on your trunk (**no worktree isolation**), source edits, one Gate D at the end.*
   Label the preview a **forecast**: the predicate is re-evaluated per claim, so the executed set may differ from it. Record the operator's approval. Decline → no claims, no writes.

## 2. Eligible set (per claim)

**Immediately before each claim**, re-apply the predicate against the **live** `.devops/plans/` — not once across the queue. That is what makes the batched-`PHASE_9` protection live rather than dead text.

A queued plan is **eligible** iff all three hold:

1. It sits in the ACTIVE sprint folder with `claim_status: QUEUED`, **or** it is a preflight-reconciled orphan (rule 1.4).
2. Every code in its `depends_on` is present in `.devops/archive/`.
3. **No overlap** between its `touches` and the `touches` of **any** plan file currently in `.devops/plans/` (the template excluded) — **including plans already batched to `PHASE_9`**.

**Normalization + overlap rule.** Normalize each entry (forward slashes, lowercase, strip a trailing `/**` or `/*`). Entry A overlaps entry B when either normalized stem is a path-prefix of, or equal to, the other.
> `ponytail:` prefix-overlap heuristic — a mid-path wildcard (e.g. `src/*/db`) is not detected; upgrade path = segment-wise glob intersection.

**Queue-pairwise check (still-`QUEUED` set).** Before the first claim, run the same overlap test across every queued plan's `touches` pair. Two queued plans that overlap each other are ordered by **queue order**: the first is claimed, the later one is **skipped with its reason recorded**. If the overlap is only discovered at claim time, the outcome is the same — a recorded skip, never a silent drop and never a halt.

**Within-batch `depends_on`.** A queued plan whose dependency is still in-batch (not yet archived) is **skipped, never reordered** — the runner does not topologically sort the queue.

**Pre-existing `PHASE_9`.** A plan already at `PHASE_9` when the batch starts is skipped (already batched), not re-run.

Anything failing 1-3 is **skipped with its reason recorded**; a skip never halts the batch.

## 3. Per plan (serial)

Narrate one line before each spawn: `plan k/N: <code> claimed → running`. Then:

1. `git mv` the plan into `.devops/plans/`, fill the claim front-matter (`claim_status: CLAIMED`, `owner`, `claimed_at`, `last_touch`), and commit with the exact literal `claim: <code>` on the trunk. **No `git worktree add`** — this batch path is trunk-sequential.
2. Spawn **one** `ptp-parcel-fast` for that plan path. The spawned runner writes the plan's `## ⚙️ Plan Settings` block at claim time as its **first** action (frozen `Mode=AUTO` + `Agents=SINGLE`); the host never authors it.
3. Handle the return per the runner's outcome map: a `SKIP` continues the batch; a `HALT` stops it (§ 5).

## 4. Terminal state

Leave each run plan at `Status: PHASE_9`, `claim_status: CLAIMED`, still in `.devops/plans/`, **Gate D `OPEN`**. Never archive a plan. Never advance one past `PHASE_9`. Never flip a gate.

## 5. Stop-the-line

Halt the batch immediately and report; already-completed plans keep their terminal `PHASE_9` state.

- Preflight: no ACTIVE sprint in `.devops/backlog/SPRINTS.md`.
- Preflight: non-empty `git status --porcelain` and no accepted resume path.
- Preflight: red baseline (`check-parcel-prefix.ps1` or `check-utf8-agents.ps1` exit ≠ `0`).
- Per plan: a Phase 3.5 `Unresolvable:` entry.
- Per plan: a self-review `**REJECTED:**` at the inline Phase 6 checkpoint (never an inline `PHASE_5_REVISION` loop).
- Per plan: `PHASE_8_FAILED` (rollback after two failed self-healing attempts).
- Per plan: the `ptp-parcel-fast` subagent returns `HALT <code>: <cause>`.

> **Not a halt (skip with reason):** unmet `depends_on`; `touches` overlap (active, batched-`PHASE_9`, or claim-time queue-pairwise); a plan already at `PHASE_9`; a within-batch `depends_on` (never reorder).

## 6. Consolidated report (directed)

When the eligible set is drained, write one report at `.opencode/plans/run-sprint-{n}/sprint_run_report.md`:

- one row per run plan carrying **code + title**, terminal Status, touched files, and Phase 9 verification evidence;
- a **Skipped / deferred** table — every non-run plan with its reason (unmet `depends_on`, `touches` overlap, pre-existing `PHASE_9`, within-batch `depends_on`, claim-time queue-pairwise overlap);
- a **What to do next** block covering all three exits — **approved** → run the per-plan `@agent-wrap-up` archive sequence (one per batched plan); **a plan that fails the operator's test** → retry or `PHASE_5_REVISION`; **batch halted** → fix the cause, or abandon-claim the orphan back to `QUEUED`, then re-run `@sprint-run`.

On `HALT`, **emit the partial report immediately** — completed plans at `PHASE_9`, the stop point, the cause, the resume path — instead of waiting for the queue to drain. Echo the **complete body** in chat: the report path is gitignored/ephemeral and cannot be linked from tracked docs.

## 7. Named exception

This batch loop is the explicit, machine-enforced **Strict Context Isolation** exception: each spawned `ptp-parcel-fast` runs one plan's Phases 1→9 in a single fresh context, and the claim is **trunk-sequential** (keeps `git mv` + the `claim: <code>` commit, drops `git worktree add`). Gate D is **batched** — deferred to one consolidated human verdict, never skipped. The one-phase-group-per-session bound stands for every other run. See `.devops/rules/plan-lifecycle.md` § Deviations.
