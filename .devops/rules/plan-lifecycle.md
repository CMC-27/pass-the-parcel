---
title: Plan Lifecycle
tags: [dev, rules, plans, parcel, lifecycle, concurrency]
status: approved
owner: Wiki Owner
last-reviewed: 2026-09-13
related-to: [./README.md, ../skills/pass-the-parcel/SKILL.md, ../skills/sprint-plan/SKILL.md]
---

# Plan Lifecycle

> How parcel plans live, move and retire. The plan file is the parcel: the entire system state lives in one self-contained markdown file, and each agent session is stateless — it reads the plan, executes one phase-group, updates the plan, and halts. A plan keeps the **same stable code** for its whole life: physical location is only a signal, the code is the link.

## The Stable Code

Every plan carries a stable code `T{theme}-E{epic}.{impl}` — assigned once, never changed. The code, not the folder, is the identity that links a plan to its theme register, its sprint, its claim, and its archive record. Moving the file never changes the code.

## Claim Front-Matter

Anything in `.devops/plans/` — and every plan committed to a sprint queue — carries this front-matter block at the very top of the file, above the plan title:

```
code: T1-E1.04
sprint: sprint-1-<slug>
claim_status: QUEUED        # QUEUED | CLAIMED | IN_PROGRESS | COMPLETE
owner: <session/model or user>
claimed_at: <ISO-8601>
last_touch: <ISO-8601>
touches: ["path/glob", "..."]
depends_on: ["<code>", "..."]
```

- `claim_status` is the claim state. The pipeline phase stays in the bottom `## 📍 State & Gates` `Status` row — never conflate the two.
- `touches` is the declared write set; it is the overlap check that makes concurrent execution safe.
- `depends_on` names codes that must be COMPLETE (present in `.devops/archive/`) before this plan may be claimed.
- Staleness is judged by `last_touch` plus a human review flag — never by a time lease. Human-gated phases pause legitimately.

## Layout & Movement

```
        park                 queue                    claim                   complete
.devops/backlog/   ->  .devops/sprints/sprint-{n}-{slug}/  ->  .devops/plans/  ->  .devops/archive/
<code>-<slug>-backlog.md   <code>-<slug>-plan.md                 <code>-<slug>-plan.md   <code>-<slug>-plan.md
```

- **Backlog:** `.devops/backlog/` — master queue `backlog-index.md`, theme registers `t{n}-<slug>-backlog.md` (`type: theme`), and parked items `<code>-<slug>-backlog.md` (`type: backlog`, `claim_status: QUEUED`). The `-backlog.md` suffix is shared; the front-matter `type` is the discriminator.
- **Sprint queue:** `.devops/sprints/sprint-{n}-<slug>/` — the single `sprint.md` (goal, scope, capacity, out-of-scope, open/close, retro) plus committed-but-unclaimed plan files. Committed plans are *moved into* the sprint folder; the sprint references them by code.
- **Active:** `.devops/plans/` — claimed plans only. The template `template-plan.md` also lives here.
- **Archive:** `.devops/archive/` — a COMPLETE plan moves here immediately at wrap-up. A closed sprint's `sprint.md` moves to `.devops/archive/sprints/sprint-{n}-<slug>/`. Shipped plans stay at the archive root and are linked to their sprint by the `sprint:` field, not by folder.
- **Per-run workspace:** `.opencode/plans/run-[slug]/` (gitignored) — reviews, versions, decision log.

## Lifecycle

`QUEUED` -> `CLAIMED` -> `PHASE_1` -> `PHASE_3` -> `PHASE_5` -> `PHASE_7` -> `PHASE_9` -> `COMPLETE`

**Revision loop:** `PHASE_7` -> (Gate B or C fails) -> `PHASE_5_REVISION` -> `PHASE_5` -> (Phases 6-7 re-run) -> `PHASE_7` -> Gate C

**Failure states:** Gate A rejected -> `PHASE_1`. Execution rolled back after two failed self-healing attempts -> `PHASE_8_FAILED` (orchestrator routes retry / `PHASE_5_REVISION` / user decision).

**Gates (hard stops):** A (Scope, after Phase 3) -> B (Spec & Plan, after Phase 5) -> C (Peer Reviews, after Phase 7) -> D (Implementation, after Phase 9)

**Gate flips:** gates flip to `APPROVED`/`REJECTED` only AFTER the user's (or AUTO verification's) verdict, recorded by the orchestrator. Executing agents halt with their gate `OPEN`.

**Modes:** `USER-MANAGED` (default — every gate halts for the user) / `AUTO` (orchestrator auto-clears Gates A-C after mechanical verification; Gate D always requires the human).

**Agents (topology axis — orthogonal to Modes):** `MULTI` (default — **comprehensive plan**: full `ptp-*` delegation, independent Group C reviewers, 4 gates) / `SINGLE` (**fast plan**: the orchestrator executes each group's persona inline with no `task` spawns, Group C is skipped, and Gates B+C merge into one approval at Gate B with Gate C `N/A`). Chosen by task complexity at plan start (blast radius / contract change / risk / ambiguity / novelty) and confirmed by the user. Gate D always halts for the human in both topologies; `AUTO` auto-clears Gates A-C on mechanical verification. See `@pass-the-parcel` § Agent Topology. Both `Mode` and `Agents` are recorded in the plan's **Plan Settings** block at the **TOP** of the plan file (frozen at plan start) — never the bottom State & Gates.

## Claim Protocol (concurrent execution)

A **claim** is the right to execute one plan against the working tree. Only one claim may cover a given file at a time. Claiming is a local, in-workspace git operation — no remote and no integration branch.

1. **Select.** From the active sprint queue, take the next item with **no unmet `depends_on`** (every dependency present in `.devops/archive/`) and **no `touches` overlap** with any plan already in `.devops/plans/`. The `@sprint-run` batch path re-evaluates this predicate immediately before **each** claim against the live `.devops/plans/` (never once across the queue); the branch-point semantics below are otherwise unchanged.
2. **Claim on trunk.** Fill `claim_status: CLAIMED`, `owner`, `claimed_at`, `last_touch`; `git mv` the plan from the sprint queue into `.devops/plans/`; commit `claim: <code>` on the workspace trunk. (`@sprint-run` keeps this step and its exact `claim: <code>` commit.)
3. **Isolate.** `git worktree add <path> -b plan/<code>-<slug>` from the claim commit. **`@sprint-run` batch exception (`trunk-sequential`):** drop this step — no `plan/<code>-<slug>` branch is created and no merge/prune follows at completion; all changes land on one tree. See § Deviations.
4. **Execute.** Run the pipeline inside the worktree. **`@sprint-run` batch exception (`trunk-sequential`):** run the per-plan chain directly on the trunk instead of a worktree.
5. **Complete.** Set `claim_status: COMPLETE`; `git mv` the plan to `.devops/archive/` (root); commit; merge the branch back to the trunk locally; prune the worktree. **`@sprint-run` batched Gate D exception:** the plan terminates at `PHASE_9` with Gate D `OPEN` and archives per plan only after the single consolidated human verdict; with no branch, there is nothing to merge or prune.
6. **Shared files stay on trunk.** `sprint.md`, `backlog-index.md`, `agent-changelog.md`, `.devops/sync-manifest.yaml`, and `.devops/logs/version-history.md` are edited only on the trunk at merge/close time — never inside a plan branch. (`ponytail:` ceiling — the changelog is written by the trunk, not the branch; upgrade path is per-plan changelog fragments.)

## Cache-Anchored State & Gates

- The **Plan Settings** block (`Mode` + `Agents`) is frozen config at the **TOP** of every plan file — written once at plan start, never edited after.
- The State Dashboard + Gate Log are the **last section** of every plan file (`## 📍 State & Gates`) and hold the only mutable runtime state.
- Gate transitions mutate ONLY those bottom rows; the frozen settings block and phase content above stay byte-stable to preserve LLM prefix-cache hits.
- Every "update the dashboard" instruction means "update the bottom State & Gates section".

## Rules

1. **The plan is the only state.** Never carry workflow state in conversation; always read the plan first and update it before halting.
2. **One phase-group per session.** Never skip ahead after a gate. Save the plan and halt. **Exception:** the named `@sprint-run` batch path runs one plan's Phases 1→9 in a single fresh per-plan context — an explicit, machine-enforced **Strict Context Isolation** exception. The rule stands for every other run. See § Deviations.
3. **No gate is skippable.** Gates A–D are hard stops requiring the human — except in `AUTO` mode, where the orchestrator auto-clears Gates A–C after mechanical verification; Gate D always requires the human. In `SINGLE` topology Gate C is `N/A` — the plan is approved once at Gate B (spec + plan + inline self-review).
4. **Claim before edits.** A plan may not execute until it holds a claim (front-matter, plus a worktree for an isolated run — `@sprint-run` is `trunk-sequential` and skips the worktree; see § Deviations). Never run two claims whose `touches` overlap — serialize with the claim protocol instead of relying on the user. See § Claim Protocol.
5. **Gate C precedes all edits.** No file is touched until the plan has passed peer review and been approved for execution.
6. **Archive on completion.** A complete plan left in the plans folder is not done. `git mv` it to `.devops/archive/` (root) — no stub. The sprint's `sprint.md` archives to `.devops/archive/sprints/sprint-{n}-<slug>/` at sprint close.

## Deviations (@sprint-run batch path)

The `@sprint-run` batch host (agent `parcel-sprint`, per-plan runner `ptp-parcel-fast`) runs the committed sprint queue in one unattended pass. It deviates from the default protocol in exactly three named ways; every other section of this document stands unchanged for every other run.

1. **Batched Gate D (deferred, never skipped).** Each per-plan run terminates at `PHASE_9`, stays `claim_status: CLAIMED` in `.devops/plans/`, with **Gate D `OPEN`**. The queue's eligible set drains into **one** consolidated human verdict at the end; per-plan `@agent-wrap-up` then archives each plan. Gate D is deferred, never auto-cleared, never skipped.
2. **Trunk-sequential claim.** The Claim Protocol's step 3 (`git worktree add`) is dropped. Steps 1-2 are kept: `git mv` into `.devops/plans/` plus the exact commit literal `claim: <code>`. All changes land on one working tree — no `plan/<code>-<slug>` branch, no merge, no prune. Per-plan execution commits use the exact literal `plan: <code>`.
3. **Named Strict Context Isolation exception.** Running one plan's Phases 1→9 in a single `ptp-parcel-fast` context is an explicit, machine-enforced exception to the one-phase-group-per-session bound (`@pass-the-parcel` § Review Gates item 1). The bound stands for every other run.

The batch path's eligibility predicate (no unmet `depends_on`; no `touches` overlap with any plan in `.devops/plans/`, including plans already batched to `PHASE_9`) is evaluated **immediately before each claim**; a skip is recorded with its reason and never halts the batch. Stop-the-line triggers and the informed run preview live in the `sprint-run` skill.

---

*Last reviewed 2026-09-13. Changes to these rules require human sign-off.*
