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
triage: SINGLE              # MULTI | SINGLE | MICRO — commit-time topology recommendation (@sprint-plan § 4c)
```

- `claim_status` is the claim state. The pipeline phase stays in the bottom `## 📍 State & Gates` `Status` row — never conflate the two.
- `claim_status` values: `QUEUED` (parked in the backlog, or committed to a sprint queue but not yet claimed), `CLAIMED` (claimed and in flight — Phases 1→8), `GATE_D_USER_APPROVAL` (executed through Phase 9, Gate D `OPEN`, awaiting the human verdict), `COMPLETE` (archived). `IN_PROGRESS` is **retired** — nothing ever set it.
- `GATE_D_USER_APPROVAL` is the terminal claim state of **every** path that reaches Phase 9: the `@sprint-run` batch path (which never archives on its own — see § Deviations) and the manual sequential sprint flow (claim a plan, run it to Gate D, leave it in `.devops/plans/` while the next plan is claimed). Its bottom `Status` stays `PHASE_9`; only the Gate D verdict plus `@agent-wrap-up` moves it to `COMPLETE`.
- `touches` is the declared write set; it is the overlap check that keeps serial claims safe.
- `triage` is the **commit-time topology recommendation** (`MULTI` / `SINGLE` / `MICRO`), scored by `@sprint-plan` § 4c against the canonical five signals in `@pass-the-parcel` § Agent Topology → *Complexity Triage* — a recommendation, never the pipeline configuration. `MICRO` is the third value and is **manual-path only**: its definition, bounds and collateral are § *Micro Lane* below, and a sprint queue never carries one (`@sprint-plan` § 4c). The frozen `Plan Settings` `Agents` row is what the pipeline obeys and is written at plan start; `triage` is what the plan *recommends* before any phase runs. The manual path reads it as the recommendation to confirm; the `@sprint-run` batch path **cannot honour it** (its preset is locked), so it surfaces it as a **flag** — see the *MULTI-worthy yield* below. An absent field is tolerated (a queue that predates the field); the mechanical half of the flag still applies.
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

**Gates (hard stops):** A (Scope, after Phase 3) -> B (Spec & Plan, after Phase 5) -> C (Peer Reviews, after Phase 7) -> D (Implementation, after Phase 9). The `MICRO` gate subset — A and C `N/A` — is § *Micro Lane* below.

**Gate flips:** gates flip to `APPROVED`/`REJECTED` only AFTER the user's (or AUTO verification's) verdict, recorded by the orchestrator. Executing agents halt with their gate `OPEN`.

**Modes:** `USER-MANAGED` (default — every gate halts for the user) / `AUTO` (orchestrator auto-clears Gates A-C **only** on positive evidence — see § AUTO Gate Evidence Contract; Gate D always requires the human).

**Agents (topology axis — orthogonal to Modes):** `MULTI` (default — **comprehensive plan**: full `ptp-*` delegation, independent Group C reviewers, 4 gates) / `SINGLE` (**fast plan**: the orchestrator executes each group's persona inline with no `task` spawns, Group C is skipped, and Gates B+C merge into one approval at Gate B with Gate C `N/A`) / `MICRO` (**small-change record**: the collapsed parcel — Phases 2-8 rendered as marked `N/A — MICRO` sections, Gates A and C `N/A`, Gate B carrying the eligibility assertion plus the micro plan; **manual-path only** — § *Micro Lane* below). Chosen by task complexity at plan start (blast radius / contract change / risk / ambiguity / novelty) and confirmed by the user. Gate D always halts for the human in every topology; `AUTO` auto-clears Gates A-C **only** on positive evidence, per § AUTO Gate Evidence Contract. See `@pass-the-parcel` § Agent Topology. Both `Mode` and `Agents` are recorded in the plan's **Plan Settings** block at the **TOP** of the plan file (frozen at plan start) — never the bottom State & Gates.

### Micro Lane (`Agents: MICRO` — the third topology value)

> **Stated once here; cited everywhere.** `@pass-the-parcel` § Agent Topology, `.devops/plans/template-plan.md`, `@sprint-plan` § 4c, `scripts/sprint_eligible.py` and the shared prefix (`base-context.md` + its seed) each name `MICRO` and point back here. No other surface restates the bounds.

`MICRO` is a value on the **existing** topology axis — not a fourth `Mode`, not a lane outside the lifecycle, and **no new lifecycle state**. It exists because the light path is already the field's most-used one (the 2026-09-24 GRID-Link audit measured 155 of 346 archived plans recording skipped-phase markers and 35 explicit ad-hoc runs) and an unsanctioned path is drift, not a mode.

**Eligibility (the recorded bounds — all of them, every time).**
- **≤ 3 files** touched, one domain — the *Complexity Triage* LOW blast-radius bound (`@pass-the-parcel` § Agent Topology), which is also the exact **inverse** of the advisory blast-radius signal `scripts/sprint_eligible.py` computes;
- **no reserved surface** and **no prefix-embed cascade** — the same predicate `scripts/sprint_eligible.py`'s `serial_reason()` / `lanes` already embody (§ *Reserved Surfaces & the Lane Model*);
- **reversible** — undone by `git revert`, with no migration and no data step;
- **no contract change** — no schema, API or wiki-facing behaviour change.

**Eligibility is asserted, never scripted.** No check can decide eligibility at the only moment it matters — plan start, when no diff exists to pass over — and the mechanical halves already have exactly one home in `scripts/sprint_eligible.py`'s advisory output, so a second checker would fork the predicate. The **eligibility line** is therefore what a micro plan records and Gate B checks for presence, exactly as § AUTO Gate Evidence Contract checks every other gate's evidence. `ponytail:` ceiling — presence proves the author *declared* the bounds, never that the declaration is true; upgrade path is a scripted pass over the diff once one exists.

**Gates.** `A` and `C` are recorded `N/A (MICRO)` — eligibility is by definition a small, reversible, local change, so there are no scope questions to ask and no peer review to run. **Gate B carries the eligibility assertion and the micro plan** — it is the one planning halt — and **Gate D always halts** for the human, exactly as in every other topology.

**The rendered record (a collapsed parcel).** The plan file is still the record. Phases 2, 3, 4, 6, 7 and 8 render as `N/A — MICRO` sections, each carrying the eligibility line, so the archive shows exactly what was bypassed and why. The **micro plan** — the change, its acceptance criteria and its file-level steps — renders inside the Phase 5 `N/A — MICRO` section, which is Gate B's positive evidence (see § AUTO Gate Evidence Contract); Phase 1 records the intent, Phase 9 the verification evidence, and Phase 10 plus the Wrap Up behave as usual. The **Wrap Up's increment is patch level**: a micro change is never a new capability surface, so the level rule needs no exception.

**Manual path only.** The `@sprint-run` batch preset is untouched and no batch surface changes. A `MICRO` plan is **not committed to a sprint queue** — micro items are exactly the between-sprint changes (`@sprint-plan` § 4c), and a queued one would be run by the batch as the full `SINGLE` parcel it already is.

## Claim Protocol (in-place, one claim at a time)

A **claim** is the right to execute one plan against the working tree. Only one claim is active at a time. Claiming is a local, in-workspace git operation — no remote and no integration branch.

1. **Select.** From the active sprint queue, take the next item whose `depends_on` is **satisfied** (per § Claim Front-Matter: every dependency present in `.devops/archive/` **or** present in `.devops/plans/` with `claim_status: GATE_D_USER_APPROVAL`) and which has **no `touches` overlap** with any plan already in `.devops/plans/`. The `@sprint-run` batch path re-evaluates this predicate immediately before **each** claim against the live `.devops/plans/` (never once across the queue) and **iterates to a fixpoint** — each pass claims at most one plan, then re-applies the predicate to the remaining queued set until nothing is eligible (`.devops/skills/sprint-run/SKILL.md` § 2).
2. **Derive the declared write set — the *Write-Set Derivation Witness*.** Before the claim commits, run `python scripts/write_set_check.py --plan <plan>` (manual path) or let the batch's per-claim pass run it (`@sprint-run` § 2). It answers **one** question — *does the declared `touches` name every file this plan must write?* — by expanding the declared set under three coupling rules and reporting any forced write the declaration omits: **prefix-cascade** (a declared base-context source forces the whole PREFIX-LOCKED agent set, discovered from the tree — the same set `check-parcel-prefix.ps1 -Sync` rewrites), **embed-cascade** (a declared `.devops/skills/<slug>/SKILL.md` forces `.devops/agents/<slug>.subagent.md` when that agent file exists), and **claim-source** (a declared path that is a `claims:` source under `.wiki/**` forces every doc declaring it, because claims bind by whole-file sha256). A declared directory or glob entry satisfies a required path through the overlap rules below. It **cites** § *Write-Set Overlap Predicate* as the **different** predicate it must never be conflated with — that one asks whether two plans collide; this one asks whether a plan's own declaration is complete. `exit 1` is a **stop-the-line on both claim paths**: amend the declaration and re-run; never reason the closure out from prose. A `touches` amendment made at claim time is a **protocol deviation, not bookkeeping** — re-verify the set against the plan's body *and* against the live canonical-home convention the moment the claim is taken, and record the amendment as the deviation it is.
3. **Claim on trunk.** Fill `claim_status: CLAIMED`, `owner`, `claimed_at`, `last_touch`; `git mv` the plan from the sprint queue into `.devops/plans/`; commit `claim: <code>` on the workspace trunk. Confirm the commit carries the plan's **content**, not only the rename — `git mv` stages the rename while working-tree edits stay unstaged, so a bare commit records a content-empty claim with the front-matter living only in the working tree. `git add` the plan file explicitly and check `git show --stat HEAD`; amend when the stat is rename-only.
4. **No isolation step.** All work runs in place on the trunk — no `git worktree add`, no `plan/<code>-<slug>` branch.
5. **Execute.** Run the pipeline on the trunk, in place.
6. **Complete.** Set `claim_status: COMPLETE`; `git mv` the plan to `.devops/archive/` (root); commit. **`@sprint-run` batched Gate D exception:** the plan terminates at `PHASE_9` with `claim_status: GATE_D_USER_APPROVAL` and Gate D `OPEN`, and archives per plan only after the single consolidated human verdict plus the follow-up batch wrap-up (§ Deviations).
7. **Shared files stay on trunk.** `sprint.md`, `backlog-index.md`, `agent-changelog.md`, `.devops/sync-manifest.yaml`, and `.devops/logs/version-history.md` are edited directly on the working tree at claim/close time — never from unclaimed work. (`ponytail:` ceiling — the changelog is written by the trunk, not a branch; upgrade path is per-plan changelog fragments.)

### Counter Ownership (`machinery-version`)

`machinery-version` is **template-owned and sync-stamped — a satellite never bumps it**. A satellite's value is a projection of the template's: the next pull stamps the source value into the satellite's manifest, so a satellite-side increment is inert (nothing records it) and reads back as `AHEAD`, a halt-and-reconcile, not an upgrade. Every rule below — the writer, the ordering, the level and the migration staging — binds the **template**.

`machinery-version` is a **global monotonic counter**, so it has exactly one writer per unit of work — this is the surface where a second writer *corrupts* rather than conflicts (a stale base produces a value a predecessor already used, and the CI predicate in `.github/workflows/validate.yml` then reports a release row that does not describe the set).

- **Manual / per-plan path:** `@agent-wrap-up` Phase 7b owns it — one increment covering that plan's portable-surface changes, with the literal recorded in `.devops/logs/version-history.md`.
- **`@sprint-run` batch path:** the **follow-up batch wrap-up** owns it — **one** increment for the whole batch (`@agent-wrap-up` § Batch Scope), read from `.devops/sync-manifest.yaml` **at that moment**, never a value captured earlier. A plan runner **never** bumps the counter: N runners reading the same base is precisely the collision this rule removes. Legacy per-plan increments inside one batch are harmless — the contract is *strictly increasing values, each recorded*, not a count.
- **Value shape & ordering (`major.minor.patch`).** The counter is a **tiered tuple, compared element-wise and only within one shape** — an integer and a dotted value are never ordered against each other (the migration crosses that boundary once: `73 -> 1.0.73`). `-Check` reports behind as `UPGRADE`, ahead as `AHEAD` and a shape crossing as `MIGRATION`; the last two **halt-and-reconcile** and a sync refuses to write before they are resolved, so a counter the target earned is never silently rewound. The value **is** the release-log `Version` column — one number, one writer, one check.
- **The level rule.** The increment's level is read mechanically from the diff: **patch** = a routine improvement (the default); **minor** = a new capability surface (a path with no prior registry/manifest row); **major** = an operator-contract change — the diff intersects the reserved-surfaces set (§ *Reserved Surfaces & the Lane Model* above). Ceremony attaches to the level: patch = a one-line release row; major = a full row + a `CHANGELOG.md` entry + a tag, and a major is a mandatory pull milestone for every satellite.
- **Migration staging.** The tiered value ships in **two releases**: release A carries the dotted-tolerant parser and the ordering-aware verdict while the value stays an integer — the script that runs during a satellite pull is the satellite's *own* (old) one, whose `(\d+)` stamp would corrupt a dotted value mid-pull; release B flips the value, one line. The scheme's canonical homes are `.devops/logs/version-history.md` § *Machinery Versioning Strategy* and the `.devops/sync-manifest.yaml` header; this section owns the **writer** and the **monotonicity** rules only.
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
- Gate transitions mutate ONLY those bottom rows; the frozen settings block and phase content above are byte-stable between gate transitions — a revision round rewrites the phase content it owns, and the prefix cache resumes from the rewrite.
- Every "update the dashboard" instruction means "update the bottom State & Gates section".

## AUTO Gate Evidence Contract (canonical — cite it, never restate it)

The one definition of what makes an `AUTO` gate clearable. Cited by `@pass-the-parcel` § Review Gates, `ptp-parcel-fast` § Auto-clear test, and `@sprint-run` § 5. Do not fork a second dialect: a drifted test either passes an empty self-review by omission, or halts a gate that was proven.

An `AUTO` gate clears **only on positive, presence-based evidence**. The test is **mechanical** — presence plus reference, never a quality judgement. A quality judgement in the test produces false halts; its absence is what makes the test safe to automate.

**Gate-critical sections (scoped, not global).** Phases 1-3 for Gate A; Phases 4-5 for Gate B; the Phase 6 self-review block for the `SINGLE` checkpoint. Phases 8-9 belong to Gate D and are **deliberately outside this contract** — Gate D is the human's.

**Cross-cutting checks.**

- **P1 — no unresolved placeholder.** After removing fenced code blocks and code spans, the gate's **evidence blocks** (Phase 3's question/answer block; Phase 4's acceptance-criteria table; Phase 6's self-review table; for a `MICRO` plan, the Phase 5 marker section) carry no line-leading unchecked box (`[ ]`) and none of the bare tokens `TBD` / `TODO` / `FIXME`. The strip step is what makes the test **quotation-safe**: a plan may quote the very tokens it forbids. **Forward work lists are exempt** — `### To-Do List` and the Phase 8 execution checklist are `[ ]` at Gate B by design, ticked during Phase 8, and are not evidence.
- **P2 — no blocking verdict.** No line whose first non-whitespace token is `**REJECTED:**` or `Unresolvable:`, and no Phase 6 `**Verdict:**` line recording a value other than `PASS`. A bare mention inside prose is not an entry. P2 is the *retained* negative test, now **necessary but never sufficient**.

| Gate | Positive evidence required, in addition to P1 + P2 |
|---|---|
| **A** (Scope, after Phase 3) | Every Phase 3 question carries an answer: in `AUTO`, each `Q#` has an `Auto-Resolution:` entry with `Rationale:` + `Source:`; in `USER-MANAGED`, each `Q#` carries the user's recorded answer. **And** the final-validation verdict line is recorded. |
| **B** (Spec & Plan, after Phase 5) | Phase 4 carries ≥1 acceptance-criterion row with a non-empty criterion **and** a non-empty `Test Target` — **or** the recorded line `No wiki delta — rationale: …`. **And** Phase 5 carries ≥1 file-level step naming a path. **`MICRO`:** the Phase 5 `N/A — MICRO` section carries the recorded eligibility line plus those two rows — the marker's presence **is** the eligibility assertion (§ *Micro Lane*). |
| **C** (Peer Reviews, `MULTI` only) | Each review file exists and its first line is a `PASS` / `**REJECTED:**` verdict. In `SINGLE`, Gate C is `N/A` and the Phase 6 row below replaces it. |
| **Phase 6 self-review** (`SINGLE`) | The Phase 6 section carries ≥1 self-review row that names an acceptance criterion by its `#` **and** fills both the "met?" and the evidence cell (a blank cell is not evidence), plus a `**Verdict:**` line reading `PASS`. An empty checkpoint, a prose paragraph, a bare `N/A`, or a row with a blank cell does **not** clear Gate B. **`MICRO`:** the Phase 6 section is an `N/A — MICRO` marker, and this checkpoint's positive evidence is the Gate B row's `MICRO` clause above. |

**Consequence — an unproven gate is a stop-the-line.** A gate whose outputs exist but fail P1, P2, or its row above is **not clearable**: the run halts with the failing gate and the missing artifact named. It is never a `REJECTED` verdict (which routes to `PHASE_5_REVISION`) and never a silent skip. `@sprint-run` § 5 carries this as a per-plan stop-the-line cause; `ptp-parcel-fast` returns `HALT <code>: unproven <gate> — <missing artifact>`.

> **Never relax the test to let a thin plan through.** The pressure to relax is always "the plan is obviously fine" — but the test is what makes that judgement auditable, and it sits between a self-authored plan and the human. `@sprint-run` batches Gate D into **one** verdict, so weak A/B evidence propagates to a single end-of-batch decision.
>
> `ponytail:` ceiling — the test proves an artifact is *present and referenced*, never that it is *correct* (a self-review row citing `AC 1` passes even if the reasoning is thin). Upgrade path = an independent reviewer in `SINGLE` — still open: `T1-E3.10` shipped the **MULTI-worthy flag + yield** instead, so a `MULTI`-worthy plan *escapes* `SINGLE` by operator choice rather than gaining a reviewer inside it.

## Gate Invocation Hygiene (canonical — cite it, never restate it)

Validation/gate commands are **one-shot, non-interactive, bounded**: a command that never returns (test-runner watch mode, a dev server, an interactive prompt) is the *failure to detect*, not a preference — and a suite expected to outlast the executing tool's default timeout must be invoked with an **explicit extended timeout**, or backgrounded and the result read once. The concrete one-shot invocations and how to derive them from a watch-shaped script live in `@test-and-deploy` § 2 (the teaching surface); every other gate surface cites this section. This applies to every path that runs gates: `@pass-the-parcel` manual runs, the `@sprint-run` batch path (`ptp-parcel-fast`), and pre-push validation.

**Suite scope.** Per-plan Phase 9 runs the plan-declared scope — targeted, sharded, or affected-only commands, run-once only — and records that scope plus exclusions in the Phase 9 evidence table's `Suite scope` column; the full suite consolidates at the batch wrap-up + pre-push + sprint close trio, and Gate D reads scope alongside exit codes. Per-plan compile is the plan-declared cheap derivation (`tsc --noEmit`, or the project's equivalent cheap compile); the full build consolidates with the full suite. `touches:` is a write-collision guard and never sources test selection.

**Frequency — one invocation moment per gate.** The rule: a gate runs where its subject changes — never at a layer whose diff cannot have changed it. One home, one invocation moment.

- **Subject map.** Per-plan Phase 9 guards the plan's diff; the batch wrap-up guards the batch's aggregate — including the wiki the wrap-up itself edits and the `machinery-version` counter; CI guards the repo as shipped.
- **Host coverage.** On a **host-sensitive** gate — one whose outcome depends on which machine runs it — the contract includes the host that was already green: CI green alone is not the whole contract, and the second host's run is part of the evidence rather than an optional extra. The obligation is satisfied by *running* it, not by reading the first host's result again. Cited by `@test-and-deploy` § 2.
- **`Green stamp`.** The stamp is the **single post-pass closing commit**: the first commit after the close-out gate pass lands the greenlit tree + the changelog entry, no earlier wrap-up commit (Phase 4 *Commit in place* included) stages `.devops/logs/agent-changelog.md`, and nothing content-bearing commits after it. It is **located** at push time by `git log --oneline -1 -- .devops/logs/agent-changelog.md` — the same rule `@agent-wrap-up` Phase 0 uses for its baseline, whose Phase 7b step 3 already names that commit the baseline — and **recorded** as `Green stamp: <sha>` in each wrapped plan's `## Completion Note`: the closing commit's sha, appended only after that commit exists and landed in a follow-up bookkeeping commit, so recorded equals located (equality by construction), never a stamp file. The content check classifies the **stamp-vs-worktree** delta from two plain reads — every path in `git diff --name-only <stamp>..HEAD` (committed delta) **plus** every path `git status --porcelain` reports (pending: staged, unstaged, untracked) — against the bookkeeping allowlist (version rows — `.devops/logs/version-history.md` — the changelog `.devops/logs/agent-changelog.md`, plan/sprint files incl. archive moves; backlog files accepted as over-run), where a `package.json` path from either read is decided by content, never by name: `git diff <stamp> -- <path>` showing the version line alone rides as a version row, any other delta is a real-file hit. Both reads allowlist-only ⇒ skip the full suite and record it; anything else ⇒ run it — the fail-safe is *over-run, never under-run*.
- **Probe scope.** For a **tree-wide** pre-fix probe the declared probe runs `scoped to the plan's touched files`; new tests stay unscoped, and the probe must still fail on the unfixed tree. Every declaring surface (surgeon § 1, the visionary's Test Verification Plan bullet) cites this section rather than restating the rule.
- **Moment split.** This canon governs **close-out / push-time** moments only: claim-time (§ Claim Protocol step 1) and preflight (`@sprint-run` § 1 step 3) run where they already do, untouched. `sprint-close`'s session-scoped DoD confirm ("full suite green … run them if not already verified this session") is an accepted session-scoped conditional of the close-out moment — it errs over-run and is not a second dialect of the stamp.
- **Cite only.** Every other surface cites this section and restates nothing.

`ponytail:` ceiling — the stamp is prose-derived and the landing order is prose-enforced: nothing verifies that the changelog commit is the post-pass closing commit or that no content commit follows it. Post-stamp commits (7b state stamps, the sha append, push-time version rows) are canonically ungated bookkeeping by design; upgrade path: a stored stamp file, declined under Q6.

**Do not** register this rule in `surface-budget.md` (Q6 — no registry growth): skills cite the *section name*, never the signature sentence, so the single-statement sweep stays at 1.

## Interrupted Run (resume contract — canonical)

A per-plan runner may be cancelled **mid-Phase 9** (gate command killed by a timeout budget, its host, or its operator). The debris is named so it can be resumed:

- **Signature:** plan **body** `Status: PHASE_9` **but** `claim_status: CLAIMED` **and** the Phase 9 evidence table empty or missing the exact `plan: <code>` commit.
- **Resume (host or re-spawned runner):** complete **Phase 9 only** — re-run any missing gate commands honestly, fill the evidence table, then make the `plan: <code>` commit and set `claim_status: GATE_D_USER_APPROVAL`. **Never** re-run Phases 1-8, never fabricate evidence, never restart the plan.
- **Never a silent `SKIP`:** the runner's `already PHASE_9 → SKIP` guard applies only to a plan already at `claim_status: GATE_D_USER_APPROVAL` (batched, awaiting Gate D) or `COMPLETE`; the signature above routes to the resume, not the skip.
- `@sprint-run` § 1 step 4 (orphan re-adoption) resumes the same way from the recorded `Status` when the body has **not** reached `PHASE_9`.

## Rules

1. **The plan is the only state.** Never carry workflow state in conversation; always read the plan first and update it before halting.
2. **One orchestrator, delegated phase-groups.** One orchestrator owns the plan end-to-end and delegates each phase-group to its sub-agent(s) (A → hunter, B → visionary, C → reviewers, D → surgeon). Never skip ahead past an uncleared gate: integrate the sub-agent handback into the plan, then halt at the gate for the verdict and resume on approval. Sub-agents never continue to the next group; only the orchestrator advances the pipeline. **Exception:** the named `@sprint-run` batch path runs one plan's Phases 1→9 in a single fresh per-plan `ptp-parcel-fast` context. See § Deviations.
3. **No gate is skippable.** Gates A–D are hard stops requiring the human — except in `AUTO` mode, where the orchestrator auto-clears Gates A–C **only** on positive evidence (see § AUTO Gate Evidence Contract); Gate D always requires the human. In `SINGLE` topology Gate C is `N/A` — the plan is approved once at Gate B (spec + plan + inline self-review); in `MICRO`, Gates A and C are `N/A (MICRO)` and Gate B carries the eligibility assertion plus the micro plan (§ *Micro Lane*).
4. **Claim before edits.** A plan may not execute until it holds a claim (front-matter + `git mv` + `claim: <code>` commit, in place). Never run two claims whose `touches` overlap — serialize with the claim protocol instead of relying on the user. See § Claim Protocol.
5. **Gate C precedes all edits.** No file is touched until the plan has passed peer review and been approved for execution.
6. **Archive on completion.** A complete plan left in the plans folder is not done. `git mv` it to `.devops/archive/` (root) — no stub. The sprint's `sprint.md` archives to `.devops/archive/sprints/sprint-{n}-<slug>/` at sprint close.
7. **Retiring a rule means sweeping every surface that states it.** A declared write set is not an inventory of where a rule lives: `T1-E3.07` retired a negative `AUTO` test and grepped only the prefix + `ptp-parcel-fast`, so the same sentence survived in `pass-the-parcel/SKILL.md`, this file and `parcel.agent.md`. Grep the rule's **whole vocabulary** — every verb, noun and idiom that could state it — over `.devops/{agents,skills,rules}`, `.opencode/plans/base-context.md` + its seed, and `HOW-TO.md`, and count live copies **before** claiming retirement; the Gate D evidence cites the surfaces swept, not just a match count. Keep lineage mentions (they are records, not regressions), keep the check **quotation-safe** (a guard must not contain the token it forbids, or the zero-hit test can never be zero), and **state the replacement** — a removal with no positive rule leaves a vacuum the next run fills with the nearest plausible reading. *(process-lessons, 2026-09-16)*
8. **Commit narrowly, and re-verify after a foreign commit.** `git add` only the plan's own files: a concurrent session once committed on top of a claim and swept an unrelated working-tree file into its release, so the content survived but the attribution did not. After any external commit lands mid-session, re-check `git status` and confirm each planned file is where it should be (working tree vs `HEAD`) before continuing. *(process-lessons, 2026-09-18)*

## Deviations (@sprint-run batch path)

The `@sprint-run` batch host (agent `parcel-sprint`, per-plan runner `ptp-parcel-fast`) runs the committed sprint queue in one unattended pass. It deviates from the default protocol in exactly three named ways; every other section of this document stands unchanged for every other run. A *halt* is not a deviation — the batch may additionally stop for the operator (today: the `MULTI`-worthy yield, § Claim Protocol → *MULTI-worthy Yield*, and `sprint-run` § 1/§ 3), and a halt never enlarges this list.

1. **Batched Gate D (deferred, never skipped).** Each per-plan run terminates at `PHASE_9`, stays in `.devops/plans/` with `claim_status: GATE_D_USER_APPROVAL`, with **Gate D `OPEN`**. The queue's eligible set drains into **one** consolidated human verdict at the end. Gate D is deferred, never auto-cleared, never skipped.
2. **Retirement is a separate, operator-invoked step.** The batch loop never archives a plan and never marks one `COMPLETE`. After the verdict the **batch wrap-up** runs as a **distinct invocation** — of `@agent-wrap-up` in its **batch scope** (`SKILL.md` § Batch Scope), executed by `parcel-sprint` (which may spawn `wiki-writer` for the read-heavy wiki prose) or by the ordinary wrap-up path. One invocation covers the whole set: per plan it asserts bottom `Status: PHASE_9`, `claim_status: GATE_D_USER_APPROVAL`, a `DONE` per-plan outcome, Phase 9 evidence plus acceptance criteria, and the exact `plan: <code>` commit on the trunk; it then runs the repo gates **once** for the set, sets `COMPLETE`, and `git mv`s each plan to `.devops/archive/` (root). A plan failing any assertion is **carry-forward** — never marked complete — and a red repo gate blocks the whole batch wrap-up. Per-plan `@agent-wrap-up` remains valid and composes, so the manual path is unchanged.
3. **Single-context fast runner.** One `ptp-parcel-fast` runs its plan's Phases 1→9 in a single context instead of the default per-group delegation (`@pass-the-parcel` § Agent Topology).

The batch path's eligibility predicate (**every `depends_on` satisfied per § Claim Front-Matter** — archived **or** `GATE_D_USER_APPROVAL` in `.devops/plans/` — plus no `touches` overlap with any plan in `.devops/plans/`, including plans already batched to `PHASE_9`) is evaluated **immediately before each claim** and re-applied to the remaining queue until **no** remaining plan is eligible — a fixpoint, bounded by the queue length, deterministic in queue order, and cycle-safe (a mutual `depends_on` leaves neither eligible: terminate and flag the cycle as a queue defect). A skip is recorded with its reason and never halts the batch. **Executed by** `scripts/sprint_eligible.py` — the host acts only on its JSON, and a script error halts the batch rather than reverting to prose (`sprint-run` § 5). Stop-the-line triggers and the informed run preview live in the `sprint-run` skill.

---

*Last reviewed 2026-09-24. Changes to these rules require human sign-off.*
