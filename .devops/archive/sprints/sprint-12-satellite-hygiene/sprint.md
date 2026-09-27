---
type: "sprint"
sprint: 12
name: "Satellite Hygiene"
slug: "satellite-hygiene"
status: "closed"
capacity_points: 8
created: "2026-09-26"
closed: "2026-09-27"
---

# Sprint 12: Satellite Hygiene

## Goal
Every portable surface a satellite obeys says the same true thing about the machinery counter — the bump instruction cites the template-ownership carve-out instead of contradicting it — Phase 5 and Phase 9 gain targeted-suite declaration with the full suite consolidated per batch/push/sprint (expanded 2026-09-26 from Shape A only, on the operator's field report), and the OpenCode V2 config declares only what V2 actually loads.

## Capacity
- Budget: 8 pts (extended from the ~5 Small default at operator ruling 2026-09-26, to open room for the third parked plan)
- Committed: 5 pts across 3 plans (as originally sized)
- Buffer: 3 pts held for spillover / discovery
- **Re-size 2026-09-26 — `T1-E1.05` has outgrown its committed size.** After a full pipeline run it is a **13-file sync-engine change** (the config + its seed, a portable gate, the sync engine gaining a migration duty, four prose mirrors, and two wiki docs re-stamped for grounded claims) — realistically **L (5)**, not the **S (1)** it was committed at. The committed figure above is therefore understated by ~4 pts. **Re-sizing and sprint membership are open sprint-level rulings**; the plan does not decide them.

## Committed Scope (queue)

> **▶️ Progress — updated 2026-09-27 at the `T1-E2.09` wrap-up (session handoff).** **2 of 3 committed plans are `COMPLETE` and archived.** The **only outstanding claim is `T1-E3.21`** — `python scripts/sprint_eligible.py --sprint-dir .devops/sprints/sprint-12-satellite-hygiene` returns `queue: ["T1-E3.21"]`, `claim_order: ["T1-E3.21"]`, `skipped: []`, `in_flight: []`, `orphans: []`, exit `0`. `machinery-version` is live at **78**; start it with `@pass-the-parcel` (its triage is `MULTI`). The two completed rows below carry their archive links; the re-scope notes further down are the run history at that moment — **not** current state.
>
> **Sprint-close hygiene still owed when `T1-E3.21` lands:** this file's own committed-scope rows and the `@sprint-close` sweep; `process-lessons.md` is at **30 entries** against its ~25 target (the fold review is sprint close's job); the Triage Panel in `.devops/backlog/backlog-index.md` already lists the two items parked by this wrap-up (`T1-E2.10`, `T1-E3.22`).

| # | Code | Plan | Size | Source tier | Link |
|---|------|------|------|-------------|------|
| 1 | T1-E2.09 | Satellites are told to bump a counter they do not own | M (3) | ✅ **COMPLETE 2026-09-27** (`AUTO` + `MULTI`; 4 review rounds; 13/13 Phase 9 green; `machinery 77 → 78`) | [plan](../../archive/t1-e2.09-machinery-counter-satellite-plan.md) |
| 2 | T1-E3.21 | Phase 9 test execution has no batching pattern | S (1) | 🟢 LATER (operator promotion ruling 2026-09-26, Shape A only; **same-day expansion ruling** — field report + Phase 3 Q&A recorded, write set 3→8) — **outstanding** | [t1-e3.21-phase9-test-batching-plan.md](t1-e3.21-phase9-test-batching-plan.md) |
| 3 | T1-E1.05 | OpenCode V2 config drift in `opencode.json` | **S (1) as committed → L (5) rescoped** | ✅ **COMPLETE 2026-09-26** (rescoped and re-claimed manually `USER-MANAGED` + `MULTI`; `machinery 76 → 77`) | [plan](../../archive/t1-e1.05-opencode-v2-config-plan.md) |

> Queue order is the first claim order, not an execution dependency: `T1-E2.09`'s dependency (`T1-E2.08`) is satisfied in `.devops/archive/`, and the predicate holds `T1-E2.09` out of the first claim order on `touches` overlap alone (via `HOW-TO.md` against T1-E1.05 and `.devops/rules/plan-lifecycle.md` against T1-E3.21) until its overlaps archive. The lanes are advisory classifications — every path runs in place serially.

> **⇧ SUPERSEDED 2026-09-27 — the three note blocks below are that day's run history, not current state. Read the Progress note at the top of § Committed Scope instead.**
>
> **⏸️ Re-scope 2026-09-26 (post-run, re-park) — supersedes the external-claim note immediately below.** `T1-E1.05` was claimed and run. The `@sprint-run` batch claimed it under `AUTO` + `SINGLE` and halted it at Gate B on an **under-declared write set** (declared 4, needed 10); the operator then re-claimed it manually under **`USER-MANAGED` + `MULTI`**. It passed Gate A/B/C after **4 Group B revision rounds** and **3 independent Phase 6 rounds + 1 Phase 7** — then **failed at Phase 8**: `python scripts/wiki_claims.py check` exited `1` because the mandated `AGENTS.md` edit stales two whole-file Grounded Claims (`.wiki/core/09-design-system.md`, `.wiki/core/12-security-standards.md`) that its `touches` did not cover, making AC8 and AC10 mutually unsatisfiable at an 11-file perimeter. **The implementation itself verified 16 of 17 Phase 9 commands** (including the whole-stack mirror run → `VERIFIED`, exit 0); the tree was rolled back cleanly and **nothing shipped**. By operator ruling (*stop, expand and rescope*) the plan was **re-parked** to this queue as `claim_status: QUEUED`, **all gates reset to `OPEN`**, with `touches` widened **11 → 13** and the claim re-stamp step moved into the write set. Full record: the plan's `⏸️ RE-PARKED` block.
>
> **Consequences for this sprint.** `T1-E1.05` is claimable again but has **outgrown its committed sizing** (S (1) → realistically L (5)) — a sprint-level ruling, recorded under *Capacity* below. `T1-E2.09` stays blocked by the predicate. **No external session ever claimed `T1-E3.21`** — the note below awaited a claim that never landed, and the live predicate treats that plan as claimable. **Nothing in this sprint has shipped yet.**

> ~~**Re-scope 2026-09-26 (external claim in flight):**~~ **(SUPERSEDED — preserved as history; no external session ever claimed `T1-E3.21`)** `T1-E3.21` is being claimed into `.devops/plans/` by a **separate session** — it is the operator-rescope constraint this row records; nothing else about its scope or sizing changed. Consequences, in claim order: **T1-E1.05 is the next claim this side** (it shares no `touches` with the Shape-A write set, so it may run alongside the external parcel); **T1-E2.09 stays blocked by the predicate** — twice over, once the external claim lands — until T1-E1.05's wrap-up archives it (the `HOW-TO.md` overlap) and T1-E3.21's wrap-up archives it (the `version-history.md` overlap). The snapshot below was recorded **before** the external claim; the live predicate at each claim boundary is the contract. Re-snapshot the queue once the external claim lands.

## Delivery Model

The § 4c triage flags for the committed set, plus the eligibility predicate's own recorded output. **Never a hand-derived wave count.**

| Code | Size | Flag | Signals that fired |
|------|------|------|--------------------|
| T1-E2.09 | M (3) | `MULTI` | blast radius (10 files across rules, skills, a script and the manifest) + contract change (the sync-protocol bump instruction every satellite obeys) |
| T1-E3.21 | S (1) | `MULTI` | blast radius (8 files: the canon rule, both execution-surface skills, the plan template, three orchestration skills) — fired at the 2026-09-26 expansion ruling; size holds S (wording only, no code) |
| T1-E1.05 | **L (5)** — rescoped 2026-09-26 from S (1) | `MULTI` | blast radius — **13 files**: the config + its seed, a portable gate, the sync engine gaining a **new migration duty**, four prose mirrors, and two wiki docs re-stamped for grounded claims. The `MULTI` flag was **honoured** on the re-run (the batch had overruled it); the run still failed at Phase 8 — on **scope**, not design. |

> **`Flag`** is the § 4c triage recommendation for that plan (`MULTI` / `—`), with the signals that fired named in the row. A `MULTI` row in a `@sprint-run` batch is surfaced as an **accept batch risk / defer to manual** fork before the first claim (`@sprint-run` § 1) — the batch's locked `AUTO` + `SINGLE` preset cannot honour the recommendation. Three rows carry it: T1-E2.09, T1-E3.21 (the 2026-09-26 expansion) and T1-E1.05.

**Predicate snapshot** — recorded at commit time, once the committed plans are in this folder and before the sprint is registered in `SPRINTS.md`; **re-run 2026-09-26 at the T1-E3.21 expansion ruling**:

`python scripts/sprint_eligible.py --sprint-dir .devops/sprints/sprint-12-satellite-hygiene`

- `claim_order`: ["T1-E1.05", "T1-E3.21"]
- `skipped`: [{"code": "T1-E2.09", "reasons": ["touches overlap: T1-E1.05 via how-to.md", "touches overlap: T1-E3.21 via .devops/rules/plan-lifecycle.md"]}]
- `multi_worthy`: 3/3 (T1-E3.21 added at the expansion — blast-radius backstop, >3 declared `touches`)
- `in_flight`: [] · `orphans`: []

**Re-snapshot 2026-09-26 — after the `T1-E1.05` re-park** (the snapshot above kept as history):

- `queue`: ["T1-E1.05", "T1-E2.09", "T1-E3.21"] · `in_flight`: [] · `orphans`: []
- `claim_order`: ["T1-E1.05", "T1-E3.21"]
- `skipped`: [{"code": "T1-E2.09", "reasons": ["touches overlap: T1-E1.05 via scripts/sync-architecture.ps1", "touches overlap: T1-E3.21 via .devops/rules/plan-lifecycle.md"]}] — the T1-E1.05 overlap moved from `how-to.md` to `scripts/sync-architecture.ps1` when that file entered the rescoped write set
- `mode_conflicts`: 1 — `T1-E1.05` now carries an **authored** `Mode: USER-MANAGED` in its Plan Settings block, so a `@sprint-run` batch will correctly raise the mode-conflict advisory before claiming it
- `multi_worthy`: 3/3

> **Forecast, never a schedule:** the snapshot is exact at the moment it is taken and stale the moment the first claim lands. `@sprint-run` § 2 re-evaluates the predicate against the live `.devops/plans/` immediately before **each** claim, so the executed set may differ. A non-zero exit from the command above is a **stop** — fix the plan file it names; never re-derive the predicate by hand.

**Accepted cost:** one Gate D verdict and one wrap-up per wave — not one consolidated verdict; a committed plan holds its files from claim until its wrap-up archives it, and the number of waves is whatever the live predicate produces. The wrap-ups bump `machinery-version` per the manual per-plan path — one increment per wrap-up, read from the live value at that moment (three increments across this sprint, never consolidated into one).

## Explicitly Out of Scope
- **T1-E3.21 Shape B's scriptable half** — the batch-host targeted-suite hint + the AUTO evidence-contract amendment: ruled out at intake (2026-09-26); the reopen clause fired same day on the operator's field report (heavy loads and delays, suite **and** build/compile), recorded in the plan file. The expansion took the **declaration/execution/record chain** (8 surfaces) — B's scriptable machinery stays out until a batch-path report demands it
- **Release B** (the dotted flip to `1.0.73`, the named T1-E2.08 follow-up with no parked plan) — not folded into T1-E2.09; a major's pull-milestone ceremony (release row + `CHANGELOG.md` entry + tag) is a release decision, not a text-parcel rider
- **The Kill List refactoring slice** — opt-in declined at planning; the `@sprint-close` scan still runs as normal and feeds REFACTORING.md
- **T1-E1.05's broad migration-guide prose sweep** — the write set is bounded to the config flip plus the prose the flip actually invalidates (`HOW-TO.md` § Binding note, `SATELLITE-BOOTSTRAP.md` § 2); anything wider returns to the plan's Phase-3 open question
- **MATURITY.md re-grade** — this sprint's completions are rows the next grade cites, not a trigger

## Definition of Done (sprint-level)
- [x] All committed parcel plans reach COMPLETE and are archived
- [x] Full test suite green, lint clean, build exit 0
- [x] Sprint closed via @sprint-close (retro appended to this file + spaghetti scan run)

## Risks / Unknowns
- **⚠️ REALISED 2026-09-26 — `T1-E1.05` was stopped four times by write-set under-declaration.** `touches` went **4 → 10 → 11 → 13** across one batch claim and one manual `USER-MANAGED` + `MULTI` run, and **every stop was a scope failure, never a design failure** — the design survived 4 revision rounds and 3 independent audits and was verified by 16 of 17 Phase 9 commands. The last and worst was a coupling **already documented in this repo's own wiki** (`.wiki/core/18-knowledge-capture.md:50` names `AGENTS.md`, both claiming docs and the remedy) that the plan's Phase 2 read *around*. **Lesson for the pipeline, not just this sprint: when any claim-source file is in `touches`, Phase 2 must check every `source:` binding against the write set.** Carried to the retro.
- **T1-E2.09 is self-referential** — it rewrites the bump instruction (`agents-and-skills.md`, `@agent-wrap-up`, `SPRINTS.template.md`) that its own wrap-up will obey; run it `MULTI` with per-phase review, and land the ownership carve-out before any later phase touches the release row
- **Stale counter anchors** — the plan was drafted against counter `73`; the live value at commit is `76` and every wrap-up reads live, so no plan phase may pin a number it does not read
- **T1-E3.21's expanded `touches`** — trimmed to three at commit per the Shape A ruling, then expanded back to eight same day on the operator's field-report ruling (the mechanism this note named, arriving early — at commit-revision time, not Phase 1). The blast-radius backstop fires `MULTI`; the plan stays on the serial lane (skill-embed cascade + `version-history.md`), and the predicate re-runs at each claim
- **Reserved-surface waves** — the wrap-up surfaces (`version-history.md`, manifest, rules) sit in multiple write sets; a red repo gate between waves is a stop-the-line. The T1-E2.09 ↔ T1-E1.05 overlap has **moved**: it is no longer `HOW-TO.md` (dropped from the rescoped write set) but **`scripts/sync-architecture.ps1`**
- ~~**E1.05 conversion timing**~~ — **RESOLVED 2026-09-26.** The "convert now or wait" question was answered *convert now, narrow* — remove the one field V2 silently ignores and stop teaching the V1 `skills` shape; the broader `agent`/`prompt`/`permission` conversion stays out of scope (it would cascade into the portable `check-parcel-prefix.ps1`). See the plan's Phase 1 *Scope amendment* blocks
- ~~**External claim coordination**~~ — **SUPERSEDED 2026-09-26.** No external session ever claimed `T1-E3.21`; the plan still sits `QUEUED` in this folder and the live predicate treats it as claimable. `T1-E1.05` was claimed and re-parked by this side. Trunk discipline is unchanged
- **Reclaiming `T1-E1.05`** — it is claimable now, but a fresh claim **must re-run Phase 3 interactively** (the recorded Q&A is reference only), re-run the mode/topology selection (its Plan Settings block still carries the previous run's `USER-MANAGED`), and re-cut `touches` against the live queue. Its Plan Settings block will raise a `mode_conflicts` advisory on any `@sprint-run` batch, which is correct

## Retro

### Goal — Met?
*"Make the portable surface a satellite obeys tell one true story — the counter's ownership clause consistent everywhere, Phase 5/9 carrying targeted-suite declaration with the full suite consolidated per batch/push/sprint, and the OpenCode V2 config declaring only what V2 loads."*

**Yes.** All three named outcomes landed and passed the owner's acceptance walk: the counter-ownership carve-out now travels on the portable surface (`T1-E2.09`), Phase 5 may declare partitioned suites and Phase 9 records the scope that ran (`T1-E3.21`), and `opencode.json` + its seed declare only what V2 loads (`T1-E1.05`). **3/3 plans, delivered.** Sprint 12 closed on the same day its last plan wrapped.

### What Shipped
| Code | Plan | Size | Effort accuracy | Notes |
|------|------|------|-----------------|-------|
| `T1-E1.05` | OpenCode V2 config drift in `opencode.json` | committed **S (1)** → actual **L (5)** | **5× under-estimate** — rescoped and re-run `USER-MANAGED` + `MULTI`; all four stops were scope, never design | 13-file sync-engine change (config + seed, a portable gate, a new migration duty, four prose mirrors, two wiki docs re-stamped); `machinery 76 → 77` |
| `T1-E2.09` | Satellites are told to bump a counter they do not own | M (3) | M as estimated | Ownership clause travels with the instruction (5 surfaces + canon); rider repaired release row 77's missing CI trailer; `machinery 77 → 78` |
| `T1-E3.21` | Phase 9 test execution has no batching pattern | S (1) | S as estimated (wording only, no code) | 8 declaration/execution/record surfaces; `Suite scope` evidence column added; `machinery 78 → 79` |

### Carry-Forward
**None — all 3 committed plans delivered and archived; the queue drained.** Recorded follow-ups (not committed work; each has a durable home):
| Item | Why not done | New size | Next sprint? |
|------|--------------|----------|--------------|
| `T1-E2.10` — manual claim path has no enumerated pre-flight checklist | Parked during this sprint's wrap-up | S (1) | Y |
| `T1-E3.22` — version-counter contract's two open seams | Parked during this sprint's wrap-up | S (1) | Y |
| `T1-E2.08` **release B** — flip the counter to `1.0.73` | Deliberately staged after release A (dotted-shape migration) | S (1) | Y |
| `process-lessons.md` **fold pass** — 31 dated entries vs ~25 target | Staging register over target; folding is close hygiene, deferred | S (1) | Y |

### Metrics: Before → After
- Hot spots (>CCN 15): **1 → 1** (the scanner itself; `CCN(h)` is a regex heuristic, ECMAScript-only, so it reads as a pointer, not a measurement)
- Files >400 lines: **5 → 6** (`sync-architecture.ps1` **757 → 864** — now 64 lines past the >800 critical; new `scripts/lib/sync-bindings.ps1` **409** crossed the >400 warn; `sprint_eligible.py` 549, `wiki_claims.py` 484, `test_sprint_eligible.py` 473, `wiki_lint_checks.py` 423 unchanged)
- Test count: **0 → 0** application tests (no `package.json` by design); machinery fixtures **67 → 67** (no new suite — `T1-E1.05` extended `sync-architecture.ps1 -SelfTest` with three plants instead)
- Lint warnings: **0 → 0**
- Capacity: budget **8** pts · committed **5** / delivered **9** → committed-vs-delivered **56%**; the shortfall is one plan (`T1-E1.05`) re-sized S → L

### Retro: Keep / Drop / Try
- **Keep** — the **same-day expansion ruling** on `T1-E3.21` (a field report reopened a closed question and the plan absorbed it without a re-plan); the **independent review depth** on `T1-E1.05` (4 revision rounds + 3 Phase 6 + 1 Phase 7 — the design survived intact because the stops were scope, not design); and the **per-plan wrap-up reading the live counter** (three increments, never consolidated).
- **Drop** — **treating an early size estimate as a write-set fact**: `T1-E1.05` was committed `S (1)` and was a 13-file `L (5)`, and every one of its four Phase-8-era stops was under-declared `touches`. Also drop the **partial close**: the register row said `✅ CLOSED` and linked `#retro` while this file still read `status: open` with an empty Retro — the close ran its artifacts (business report, user-testing) but skipped the retro and the frontmatter stamp. **The close is atomic: artifacts + retro + stamp + register row in one pass.**
- **Try** — a **`sync-architecture.ps1` split plan** (now 64 lines past critical); a **`process-lessons.md` fold pass**; and a **close-time self-check** that greps every archived sprint for `status: "open"` so a partial close fails loudly instead of leaving a register that over-claims.

### Lessons for the Wiki / Knowledge Capture
The sprint's biggest finding, from `T1-E1.05`: **when any claim-source file is in a plan's `touches`, Phase 2 must check every `source:` binding against the write set.** The coupling that caused the final stop was already documented in `.wiki/core/18-knowledge-capture.md` (it names `AGENTS.md`, both claiming docs and the remedy) and the plan read around it. Route: `.devops/rules/process-lessons.md` (machinery) — **promotion owed, not yet recorded**.

Three machinery lessons did land this sprint in `.devops/rules/process-lessons.md`:
1. **A Phase 3 option must carry label + cost/benefit + owning precedent on the first ask** (`T1-E3.21`) — a terse option set gets a literal pick the operator then declines to validate; the re-ask is pure overhead.
2. **A probe that cannot fail is worse than no probe** (`T1-E2.09`) — a criterion asserting a gate must run *that gate's own logic*, and every new probe must be run against the unfixed tree and required to fail.
3. **Never link a plan at a transient path** (`T1-E1.05`) — the claim/archive `git mv` breaks the link; link `.devops/archive/` or not at all.

`process-lessons.md` stands at **31 dated entries** (measured at close) against its **~25 soft target** — the fold review is carried forward, not skipped.

### User Acceptance Walk
**3 tests · 3 passed · 0 failed · 0 blocked.** Every delivered outcome was confirmed in the owner's hands on the first pass. Because nothing failed or was blocked, **no theme-register rows are owed** — stated here rather than left silent. Source: [`user-testing.md`](./user-testing.md).

### New Refactoring Items (→ REFACTORING.md)
The register is **present** (the business report's earlier "register is absent" line was wrong — corrected in that file); its Kill List already carries this sprint's flags, added during `T1-E1.05`. The close scan was re-run across the machinery roots and confirms them (`src/` absent by design, logged as a clean skip):
- **Promoted — `scripts/sync-architecture.ps1` `757 → 864`, 🔴 OPEN** — 64 lines past the >800 critical, from `T1-E1.05`'s sync-side migration, widened header contract and three `-SelfTest` plants. This is the register's **top-priority item**; the split precedent (`T1-E4.01` W6) is the standing fix.
- **New — `scripts/lib/sync-bindings.ps1` `408 → 409`, 🔴 OPEN** — crossed the >400 warn as the migration landed inside `Update-TargetModelBindings`.
- **Watch — `scripts/lib/sync-verify.ps1` 117, ⚪ WATCH** — cohesion, not size (`Invoke-StructuralVerify` mixes structural checks with gate orchestration); flagged by the parcel's Phase 6 and routed here rather than fixed in-scope.
No file was decomposed this sprint, so the Completed Refactors table gains no row.
