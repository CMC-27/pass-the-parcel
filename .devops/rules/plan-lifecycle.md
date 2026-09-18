---
title: Plan Lifecycle
tags: [dev, rules, plans, parcel, lifecycle, concurrency]
status: approved
owner: Wiki Owner
last-reviewed: 2026-09-16
related-to: [./README.md, ../skills/pass-the-parcel/SKILL.md, ../skills/sprint-plan/SKILL.md]
---

# Plan Lifecycle

> How parcel plans live, move and retire. The plan file is the parcel: the entire system state lives in one self-contained markdown file, and each sub-agent run is stateless — it reads the plan, executes its phase-group, updates the plan, and returns to the orchestrator. A plan keeps the **same stable code** for its whole life: physical location is only a signal, the code is the link.

## The Stable Code

Every plan carries a stable code `T{theme}-E{epic}.{impl}` — assigned once, never changed. The code, not the folder, is the identity that links a plan to its theme register, its sprint, its claim, and its archive record. Moving the file never changes the code.

## Claim Front-Matter

Anything in `.devops/plans/` — and every plan committed to a sprint queue — carries this front-matter block at the very top of the file, above the plan title:

```
code: T1-E1.04
sprint: sprint-1-<slug>
claim_status: QUEUED        # QUEUED | CLAIMED | GATE_D_USER_APPROVAL | COMPLETE
owner: <agent/model or user>
claimed_at: <ISO-8601>
last_touch: <ISO-8601>
touches: ["path/glob", "..."]
depends_on: ["<code>", "..."]
triage: SINGLE              # MULTI | SINGLE — commit-time topology recommendation (@sprint-plan § 4c)
```

- `claim_status` is the claim state. The pipeline phase stays in the bottom `## 📍 State & Gates` `Status` row — never conflate the two.
- `claim_status` values: `QUEUED` (parked in the backlog, or committed to a sprint queue but not yet claimed), `CLAIMED` (claimed and in flight — Phases 1→8), `GATE_D_USER_APPROVAL` (executed through Phase 9, Gate D `OPEN`, awaiting the human verdict), `COMPLETE` (archived). `IN_PROGRESS` is **retired** — nothing ever set it.
- `GATE_D_USER_APPROVAL` is the terminal claim state of **every** path that reaches Phase 9: the `@sprint-run` batch path (which never archives on its own — see § Deviations) and the manual sequential sprint flow (claim a plan, run it to Gate D, leave it in `.devops/plans/` while the next plan is claimed). Its bottom `Status` stays `PHASE_9`; only the Gate D verdict plus `@agent-wrap-up` moves it to `COMPLETE`.
- `touches` is the declared write set; it is the overlap check that keeps serial claims safe.
- `triage` is the **commit-time topology recommendation** (`MULTI` / `SINGLE`), scored by `@sprint-plan` § 4c against the canonical five signals in `@pass-the-parcel` § Agent Topology → *Complexity Triage* — a recommendation, never the pipeline configuration. The frozen `Plan Settings` `Agents` row is what the pipeline obeys and is written at plan start; `triage` is what the plan *recommends* before any phase runs. The manual path reads it as the recommendation to confirm; the `@sprint-run` batch path **cannot honour it** (its preset is locked), so it surfaces it as a **flag** — see the *MULTI-worthy yield* below. An absent field is tolerated (a queue that predates the field); the mechanical half of the flag still applies.
- `depends_on` names codes that must be **satisfied** before this plan may be claimed. A code is satisfied when it is either **(a)** present in `.devops/archive/` — the plan wrapped up and archived (the manual / per-plan path), **or (b)** present in `.devops/plans/` with `claim_status: GATE_D_USER_APPROVAL` — executed through Phase 9 with Gate D `OPEN`, awaiting the human verdict (the batch path's terminal state). **Any other state is unmet**: still `QUEUED` in the sprint queue, or `CLAIMED` in `.devops/plans/` below `PHASE_9` (in flight). This is the **dependency** rule only; the `touches`-overlap check below is a *separate* blocker that a satisfied dependency does **not** clear.
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

The `claim_status` mirrors the pipeline: `QUEUED` -> `CLAIMED` (Phases 1→8) -> `GATE_D_USER_APPROVAL` (at `PHASE_9`, Gate D `OPEN`) -> `COMPLETE` (Gate D verdict + wrap-up + archive).

**Revision loop:** `PHASE_7` -> (Gate B or C fails) -> `PHASE_5_REVISION` -> `PHASE_5` -> (Phases 6-7 re-run) -> `PHASE_7` -> Gate C

**Failure states:** Gate A rejected -> `PHASE_1`. Execution rolled back after two failed self-healing attempts -> `PHASE_8_FAILED` (orchestrator routes retry / `PHASE_5_REVISION` / user decision).

**Gates (hard stops):** A (Scope, after Phase 3) -> B (Spec & Plan, after Phase 5) -> C (Peer Reviews, after Phase 7) -> D (Implementation, after Phase 9)

**Gate flips:** gates flip to `APPROVED`/`REJECTED` only AFTER the user's (or AUTO verification's) verdict, recorded by the orchestrator. Executing agents halt with their gate `OPEN`.

**Modes:** `USER-MANAGED` (default — every gate halts for the user) / `AUTO` (orchestrator auto-clears Gates A-C **only** on positive evidence — see § AUTO Gate Evidence Contract; Gate D always requires the human).

**Agents (topology axis — orthogonal to Modes):** `MULTI` (default — **comprehensive plan**: full `ptp-*` delegation, independent Group C reviewers, 4 gates) / `SINGLE` (**fast plan**: the orchestrator executes each group's persona inline with no `task` spawns, Group C is skipped, and Gates B+C merge into one approval at Gate B with Gate C `N/A`). Chosen by task complexity at plan start (blast radius / contract change / risk / ambiguity / novelty) and confirmed by the user. Gate D always halts for the human in both topologies; `AUTO` auto-clears Gates A-C **only** on positive evidence, per § AUTO Gate Evidence Contract. See `@pass-the-parcel` § Agent Topology. Both `Mode` and `Agents` are recorded in the plan's **Plan Settings** block at the **TOP** of the plan file (frozen at plan start) — never the bottom State & Gates.

## Claim Protocol (in-place, one claim at a time)

A **claim** is the right to execute one plan against the working tree. Only one claim is active at a time. Claiming is a local, in-workspace git operation — no remote and no integration branch.

1. **Select.** From the active sprint queue, take the next item whose `depends_on` is **satisfied** (per § Claim Front-Matter: every dependency present in `.devops/archive/` **or** present in `.devops/plans/` with `claim_status: GATE_D_USER_APPROVAL`) and which has **no `touches` overlap** with any plan already in `.devops/plans/`. The `@sprint-run` batch path re-evaluates this predicate immediately before **each** claim against the live `.devops/plans/` (never once across the queue) and **iterates to a fixpoint** — each pass claims at most one plan, then re-applies the predicate to the remaining queued set until nothing is eligible (`.devops/skills/sprint-run/SKILL.md` § 2).
2. **Claim on trunk.** Fill `claim_status: CLAIMED`, `owner`, `claimed_at`, `last_touch`; `git mv` the plan from the sprint queue into `.devops/plans/`; commit `claim: <code>` on the workspace trunk.
3. **No isolation step.** All work runs in place on the trunk — no `git worktree add`, no `plan/<code>-<slug>` branch.
4. **Execute.** Run the pipeline on the trunk, in place.
5. **Complete.** Set `claim_status: COMPLETE`; `git mv` the plan to `.devops/archive/` (root); commit. **`@sprint-run` batched Gate D exception:** the plan terminates at `PHASE_9` with `claim_status: GATE_D_USER_APPROVAL` and Gate D `OPEN`, and archives per plan only after the single consolidated human verdict plus the follow-up batch wrap-up (§ Deviations).
6. **Shared files stay on trunk.** `sprint.md`, `backlog-index.md`, `agent-changelog.md`, `.devops/sync-manifest.yaml`, and `.devops/logs/version-history.md` are edited directly on the working tree at claim/close time — never from unclaimed work. (`ponytail:` ceiling — the changelog is written by the trunk, not a branch; upgrade path is per-plan changelog fragments.)

### Counter Ownership (`machinery-version`)

`machinery-version` is a **global monotonic counter**, so it has exactly one writer per unit of work — this is the surface where a second writer *corrupts* rather than conflicts (a stale base produces a value a predecessor already used, and the CI predicate in `.github/workflows/validate.yml` then reports a release row that does not describe the set).

- **Manual / per-plan path:** `@agent-wrap-up` Phase 7b owns it — one increment covering that plan's portable-surface changes, with the literal recorded in `.devops/logs/version-history.md`.
- **`@sprint-run` batch path:** the **follow-up batch wrap-up** owns it — **one** increment for the whole batch (`@agent-wrap-up` § Batch Scope), read from `.devops/sync-manifest.yaml` **at that moment**, never a value captured earlier. A plan runner **never** bumps the counter: N runners reading the same base is precisely the collision this rule removes. Legacy per-plan increments inside one batch are harmless — the contract is *strictly increasing values, each recorded*, not a count.
- **The prefix regenerate is not part of this.** `check-parcel-prefix.ps1 -Sync` stays with the plan that edits a reserved prefix surface, because deferring it would leave a red `check-parcel-prefix.ps1` in the window the next claim's green-baseline preflight inspects. The batch host owns the **invariant** (exit `0` at every claim boundary), not the repair.

### Write-Set Overlap Predicate (canonical — cite it, never restate it)

The one definition of `touches` overlap. It is cited by `@sprint-run` § 2 (per-claim eligibility) and `@sprint-plan` § 4 (commit-time wave preflight). Do not fork a second dialect: a drifted predicate either admits a colliding claim or serialises a disjoint queue.

- **Normalize** each `touches` entry: forward slashes, lowercase, strip a trailing `/**` or `/*`.
- **Entry overlap:** A overlaps B when some path can match both patterns **and** either normalized segment list is a path-prefix of, or equal to, the other. Segments are compared segment-wise, so a wildcard is honoured anywhere in the path:
  - `*` matches exactly **one** segment;
  - `**` matches **zero or more** segments;
  - a literal segment matches only itself, so `src/a` does **not** swallow `src/ab` (the boundary rule).
- **Plan overlap:** two plans overlap when *any* entry of one overlaps *any* entry of the other.
- **Consequence:** an overlapping plan is **not claimable** while the other plan sits in `.devops/plans/` — including a plan already batched to `PHASE_9` (`claim_status: GATE_D_USER_APPROVAL`, not yet archived). This is a **separate blocker** from `depends_on`: a satisfied dependency does not clear it.
- **Executable embodiment (batch path):** `scripts/sprint_eligible.py` (stdlib-only, fixture-tested by `scripts/tests/test_sprint_eligible.py`) implements this predicate together with the § Claim Front-Matter dependency rule and the queue fixpoint, and prints the eligible set, claim order, advisory `parallel_groups` + `lanes` and per-plan skip reasons as JSON. `@sprint-run` § 2 computes eligibility from that output; a non-zero exit is a stop-the-line — never a fallback to prose. The definition stays **here**: the script cites this section, it does not restate it.

### Reserved Surfaces & the Lane Model

> **Stated once here; cited everywhere.** `sprint_eligible.py` embodies it (the `RESERVED_SURFACES` constant + `serial_reason()`), `@sprint-run` § 2 consumes it as advisory data, and no other surface re-lists the members.

The reserved set is the surfaces whose write is **global rather than file-local** — the ones where a second writer cannot merge, only corrupt. A plan whose `touches` intersects any member is on the **serial lane**:

`.opencode/plans/base-context.md` · `.devops/templates/base-context.template.md` · `.devops/agents` · `.devops/sync-manifest.yaml` · `.devops/logs/version-history.md` · `.devops/logs/agent-changelog.md` · `.devops/sprints` · `.devops/backlog/backlog-index.md` · `.devops/backlog/SPRINTS.md`

**The prefix-embed cascade (transitive).** A `.devops/skills/<slug>/SKILL.md` edit whose body is embedded in an existing `.devops/agents/<slug>.subagent.md` is **also** serial: executing it forces a `-Sync` that rewrites a reserved agent file. Without this rule, the classifier would call this template's most common edit lane-B and be wrong.

| Lane | Membership | Execution |
|---|---|---|
| **serial** | `touches` intersects the reserved set, or the prefix-embed cascade | one at a time; never packed with another plan |
| **parallel** | everything else | mutually disjoint — claimable concurrently **by a runner that provides real isolation** |

> **A lane is a classification, not an execution namespace.** Every path runs in place, one claim at a time in `claim_order`, and executes both lanes serially. `lanes` and `parallel_groups` are therefore **advisory** data — the `complexity` precedent — consumed by the host's preview and report. A queue that is entirely serial (as this template's usually is) reports an empty `parallel_groups` rather than implying a concurrency the path does not have.

> **Never relax the predicate to make a queue batch in one pass.** Overlap on the shared surfaces (`base-context.md`, `sync-manifest.yaml`, `.devops/logs/version-history.md`) is real — concurrent edits would corrupt the prefix lock and the `machinery-version` bump. A queue that overlaps is an **N-wave queue**: the fix is to *report* N at planning time, when trimming or reordering is still cheap.
>
> `ponytail:` ceilings — none on the matcher: a mid-path wildcard (`src/*/db`) **is** detected (the segment-wise upgrade this section's own ceiling once named was executed by `T1-E3.11`). There is no concurrent executor: `parallel_groups` stays advisory and one claim runs at a time.

### MULTI-worthy Yield (batch path only)

The topology recommendation recorded at commit time (`triage`) can be overruled by the batch's locked preset, so a `MULTI`-worthy plan could otherwise run `SINGLE` — no independent reviewer, no adversarial pass — and never say so. The batch path therefore surfaces it **before the first claim**.

- **Flag.** A queued plan is `multi_worthy` when **either** its `triage` is `MULTI` **or** its declared `touches` exceed the *Complexity Triage* blast-radius bound (`≤ 3 files, one domain`; `@pass-the-parcel` § Agent Topology). `scripts/sprint_eligible.py` computes it as its **advisory** `complexity` key — the `parallel_groups` precedent: data for the host, not a clause of the eligibility predicate. The signal set stays **defined** in `@pass-the-parcel`; the script cites it.
- **Fork.** `@sprint-run` § 1 presents every flagged plan for **one** operator answer: **accept batch risk** (`AUTO` + `SINGLE`, no independent reviewer) or **defer to manual**. Acceptance is pre-clearable for one, several or all, so a fully unattended run stays possible and the pause is opt-in.
- **Yield.** A deferral is a **pure pause at that plan's slot**: the batch claims in `claim_order` and halts on reaching it — it never claims **past** a hole. The report records `DEFERRED-MANUAL` with the plan's code, the topology it needs (`MULTI`), the dependents it strands (the computed `blocks` closure), and the resume contract: deliver the plan via `@pass-the-parcel` in `MULTI`, then re-invoke `@sprint-run`. Nothing is persisted — the next invocation recomputes the fork from live state.
- **A halt, never a relaxation.** This is precisely why it is **not** one of § Deviations' items: the batch relaxes exactly three rules, and this adds a stop instead of removing one.

## Cache-Anchored State & Gates

- The **Plan Settings** block (`Mode` + `Agents`) is frozen config at the **TOP** of every plan file — written once at plan start, never edited after.
- The State Dashboard + Gate Log are the **last section** of every plan file (`## 📍 State & Gates`) and hold the only mutable runtime state.
- Gate transitions mutate ONLY those bottom rows; the frozen settings block and phase content above stay byte-stable to preserve LLM prefix-cache hits.
- Every "update the dashboard" instruction means "update the bottom State & Gates section".

## AUTO Gate Evidence Contract (canonical — cite it, never restate it)

The one definition of what makes an `AUTO` gate clearable. Cited by `@pass-the-parcel` § Review Gates, `ptp-parcel-fast` § Auto-clear test, and `@sprint-run` § 5. Do not fork a second dialect: a drifted test either passes an empty self-review by omission, or halts a gate that was proven.

An `AUTO` gate clears **only on positive, presence-based evidence**. The test is **mechanical** — presence plus reference, never a quality judgement. A quality judgement in the test produces false halts; its absence is what makes the test safe to automate.

**Gate-critical sections (scoped, not global).** Phases 1-3 for Gate A; Phases 4-5 for Gate B; the Phase 6 self-review block for the `SINGLE` checkpoint. Phases 8-9 belong to Gate D and are **deliberately outside this contract** — Gate D is the human's.

**Cross-cutting checks.**

- **P1 — no unresolved placeholder.** After removing fenced code blocks and code spans, the gate's **evidence blocks** (Phase 3's question/answer block; Phase 4's acceptance-criteria table; Phase 6's self-review table) carry no line-leading unchecked box (`[ ]`) and none of the bare tokens `TBD` / `TODO` / `FIXME`. The strip step is what makes the test **quotation-safe**: a plan may quote the very tokens it forbids. **Forward work lists are exempt** — `### To-Do List` and the Phase 8 execution checklist are `[ ]` at Gate B by design, ticked during Phase 8, and are not evidence.
- **P2 — no blocking verdict.** No line whose first non-whitespace token is `**REJECTED:**` or `Unresolvable:`, and no Phase 6 `**Verdict:**` line recording a value other than `PASS`. A bare mention inside prose is not an entry. P2 is the *retained* negative test, now **necessary but never sufficient**.

| Gate | Positive evidence required, in addition to P1 + P2 |
|---|---|
| **A** (Scope, after Phase 3) | Every Phase 3 question carries an answer: in `AUTO`, each `Q#` has an `Auto-Resolution:` entry with `Rationale:` + `Source:`; in `USER-MANAGED`, each `Q#` carries the user's recorded answer. **And** the final-validation verdict line is recorded. |
| **B** (Spec & Plan, after Phase 5) | Phase 4 carries ≥1 acceptance-criterion row with a non-empty criterion **and** a non-empty `Test Target` — **or** the recorded line `No wiki delta — rationale: …`. **And** Phase 5 carries ≥1 file-level step naming a path. |
| **C** (Peer Reviews, `MULTI` only) | Each review file exists and its first line is a `PASS` / `**REJECTED:**` verdict. In `SINGLE`, Gate C is `N/A` and the Phase 6 row below replaces it. |
| **Phase 6 self-review** (`SINGLE`) | The Phase 6 section carries ≥1 self-review row that names an acceptance criterion by its `#` **and** fills both the "met?" and the evidence cell (a blank cell is not evidence), plus a `**Verdict:**` line reading `PASS`. An empty checkpoint, a prose paragraph, a bare `N/A`, or a row with a blank cell does **not** clear Gate B. |

**Consequence — an unproven gate is a stop-the-line.** A gate whose outputs exist but fail P1, P2, or its row above is **not clearable**: the run halts with the failing gate and the missing artifact named. It is never a `REJECTED` verdict (which routes to `PHASE_5_REVISION`) and never a silent skip. `@sprint-run` § 5 carries this as a per-plan stop-the-line cause; `ptp-parcel-fast` returns `HALT <code>: unproven <gate> — <missing artifact>`.

> **Never relax the test to let a thin plan through.** The pressure to relax is always "the plan is obviously fine" — but the test is what makes that judgement auditable, and it sits between a self-authored plan and the human. `@sprint-run` batches Gate D into **one** verdict, so weak A/B evidence propagates to a single end-of-batch decision.
>
> `ponytail:` ceiling — the test proves an artifact is *present and referenced*, never that it is *correct* (a self-review row citing `AC 1` passes even if the reasoning is thin). Upgrade path = an independent reviewer in `SINGLE` — still open: `T1-E3.10` shipped the **MULTI-worthy flag + yield** instead, so a `MULTI`-worthy plan *escapes* `SINGLE` by operator choice rather than gaining a reviewer inside it.

## Rules

1. **The plan is the only state.** Never carry workflow state in conversation; always read the plan first and update it before halting.
2. **One orchestrator, delegated phase-groups.** One orchestrator owns the plan end-to-end and delegates each phase-group to its sub-agent(s) (A → hunter, B → visionary, C → reviewers, D → surgeon). Never skip ahead past an uncleared gate: integrate the sub-agent handback into the plan, then halt at the gate for the verdict and resume on approval. Sub-agents never continue to the next group; only the orchestrator advances the pipeline. **Exception:** the named `@sprint-run` batch path runs one plan's Phases 1→9 in a single fresh per-plan `ptp-parcel-fast` context. See § Deviations.
3. **No gate is skippable.** Gates A–D are hard stops requiring the human — except in `AUTO` mode, where the orchestrator auto-clears Gates A–C **only** on positive evidence (see § AUTO Gate Evidence Contract); Gate D always requires the human. In `SINGLE` topology Gate C is `N/A` — the plan is approved once at Gate B (spec + plan + inline self-review).
4. **Claim before edits.** A plan may not execute until it holds a claim (front-matter + `git mv` + `claim: <code>` commit, in place). Never run two claims whose `touches` overlap — serialize with the claim protocol instead of relying on the user. See § Claim Protocol.
5. **Gate C precedes all edits.** No file is touched until the plan has passed peer review and been approved for execution.
6. **Archive on completion.** A complete plan left in the plans folder is not done. `git mv` it to `.devops/archive/` (root) — no stub. The sprint's `sprint.md` archives to `.devops/archive/sprints/sprint-{n}-<slug>/` at sprint close.

## Deviations (@sprint-run batch path)

The `@sprint-run` batch host (agent `parcel-sprint`, per-plan runner `ptp-parcel-fast`) runs the committed sprint queue in one unattended pass. It deviates from the default protocol in exactly three named ways; every other section of this document stands unchanged for every other run. A *halt* is not a deviation — the batch may additionally stop for the operator (today: the `MULTI`-worthy yield, § Claim Protocol → *MULTI-worthy Yield*, and `sprint-run` § 1/§ 3), and a halt never enlarges this list.

1. **Batched Gate D (deferred, never skipped).** Each per-plan run terminates at `PHASE_9`, stays in `.devops/plans/` with `claim_status: GATE_D_USER_APPROVAL`, with **Gate D `OPEN`**. The queue's eligible set drains into **one** consolidated human verdict at the end. Gate D is deferred, never auto-cleared, never skipped.
2. **Retirement is a separate, operator-invoked step.** The batch loop never archives a plan and never marks one `COMPLETE`. After the verdict the **batch wrap-up** runs as a **distinct invocation** — of `@agent-wrap-up` in its **batch scope** (`SKILL.md` § Batch Scope), executed by `parcel-sprint` (which may spawn `wiki-writer` for the read-heavy wiki prose) or by the ordinary wrap-up path. One invocation covers the whole set: per plan it asserts bottom `Status: PHASE_9`, `claim_status: GATE_D_USER_APPROVAL`, a `DONE` per-plan outcome, Phase 9 evidence plus acceptance criteria, and the exact `plan: <code>` commit on the trunk; it then runs the repo gates **once** for the set, sets `COMPLETE`, and `git mv`s each plan to `.devops/archive/` (root). A plan failing any assertion is **carry-forward** — never marked complete — and a red repo gate blocks the whole batch wrap-up. Per-plan `@agent-wrap-up` remains valid and composes, so the manual path is unchanged.
3. **Single-context fast runner.** One `ptp-parcel-fast` runs its plan's Phases 1→9 in a single context instead of the default per-group delegation (`@pass-the-parcel` § Agent Topology).

The batch path's eligibility predicate (**every `depends_on` satisfied per § Claim Front-Matter** — archived **or** `GATE_D_USER_APPROVAL` in `.devops/plans/` — plus no `touches` overlap with any plan in `.devops/plans/`, including plans already batched to `PHASE_9`) is evaluated **immediately before each claim** and re-applied to the remaining queue until **no** remaining plan is eligible — a fixpoint, bounded by the queue length, deterministic in queue order, and cycle-safe (a mutual `depends_on` leaves neither eligible: terminate and flag the cycle as a queue defect). A skip is recorded with its reason and never halts the batch. **Executed by** `scripts/sprint_eligible.py` — the host acts only on its JSON, and a script error halts the batch rather than reverting to prose (`sprint-run` § 5). Stop-the-line triggers and the informed run preview live in the `sprint-run` skill.

---

*Last reviewed 2026-09-16. Changes to these rules require human sign-off.*
