---
type: "sprint"
sprint: 9
name: "Batch Hardening"
slug: "batch-hardening"
status: "open"
capacity_points: 20
created: "2026-09-16"
closed: ""
---

# Sprint 9: Batch Hardening

## Goal
By the end of Sprint 9 the parcel batch pipeline is hardened end to end — AUTO gates clear only on positive evidence, Phase 3 can ask its whole decision surface in one sitting, batch eligibility is one tested script instead of four prose copies, MULTI-worthy plans are flagged before an unattended run, and the lane a plan needs is classified mechanically — reserved-surface plans serial, disjoint plans otherwise — while the `machinery-version` counter has a single owner per batch, so machinery plans stop colliding on shared counters — so a committed queue's wave count and gate evidence are knowable mechanically rather than discovered mid-run.

> **Goal amendment (2026-09-16, operator ruling at `T1-E3.11` Gate D).** The Goal's final clause originally read *"…and disjoint plans can run in two lanes without colliding on the `machinery-version` counter"*. **Two-lane concurrent execution was not delivered and was descoped.** `T1-E3.11`'s Phase 1 Intent contracted for worktree-isolated parallel lanes, but its own acceptance criteria tested only lane **classification**, and this sprint's *Explicitly Out of Scope* forbids *"permitting parallel claims"* while batch deviation 3 drops `git worktree add` outright — so the headline could not be built inside Sprint 9's own rules. The runner refused the three contradicted directives and disclosed the gap at Gate D rather than grading itself PASS. What landed instead is the safe half: a canonical + executable **Reserved Surface Set**, a live `lanes` classification, mid-path wildcard detection (closing the correctness hole `T1-E3.09` shipped), and **single-owner `machinery-version` bumps per batch** — which is the collision every wave of this sprint hand-carried. Genuine two-lane *execution* needs a **fifth** batch deviation (worktree isolation + a serialised merge) and is a separate future parcel. Recorded here rather than silently reworded, because the gap between a plan's title and its acceptance criteria is the defect this sprint spent six waves learning to see.

## Capacity
- Budget: 20 pts (**XL** — above the `Large (~13+)` calibration, by explicit operator ruling at planning: all six candidates selected)
- Committed: 20 pts across 6 plans
- Buffer: 0 pts — no spare capacity. If a plan overruns, it carries forward rather than expanding the sprint.

> **Calibration note.** Sprint 8 committed 9 pts and delivered ~12 effective pts; its retro's signal was *"a plan that edits the pipeline that is executing it costs roughly +1–2 pts."* Every plan below edits that pipeline, and two of them (`T1-E3.09`, `T1-E3.11`) also edit the host that spawns the runner. Treat 20 pts as a floor, not a ceiling, and expect a long sprint.

## Committed Scope (queue)
| # | Code | Plan | Size | Source tier | Link |
|---|------|------|------|-------------|------|
| 1 | T1-E3.06 | Sprint 8 gate & preflight coverage gaps | S (1) | 🟡 NEXT | [t1-e3.06-sprint-8-gate-preflight-gaps-plan.md](t1-e3.06-sprint-8-gate-preflight-gaps-plan.md) |
| 2 | T1-E3.07 | Positive-evidence auto-clear for AUTO gates | M (3) | 🟡 NEXT | [t1-e3.07-positive-evidence-auto-clear-plan.md](t1-e3.07-positive-evidence-auto-clear-plan.md) |
| 3 | T1-E3.08 | Batched clarification questionnaire | M (3) | 🟡 NEXT | [t1-e3.08-batched-clarification-questionnaire-plan.md](t1-e3.08-batched-clarification-questionnaire-plan.md) |
| 4 | T1-E3.09 | Eligibility predicate: script + fixture test + canonicalization | L (5) | 🟡 NEXT | [t1-e3.09-eligibility-predicate-script-plan.md](t1-e3.09-eligibility-predicate-script-plan.md) |
| 5 | T1-E3.10 | MULTI-worthy triage flag + batch pause/yield | M (3) | 🟢 LATER | [t1-e3.10-multi-triage-flag-batch-yield-plan.md](t1-e3.10-multi-triage-flag-batch-yield-plan.md) |
| 6 | T1-E3.11 | Two-lane concurrent batch + version-bump ownership | L (5) | 🟢 LATER | [t1-e3.11-two-lane-concurrent-batch-plan.md](t1-e3.11-two-lane-concurrent-batch-plan.md) |

> **Queue order is the claim order, not a topological sort.** The one hard ordering constraint is the dependency chain `T1-E3.09 → T1-E3.10 → T1-E3.11`; the table places each dependency ahead of its dependant so the fixpoint reaches them in sequence. `T1-E3.06`, `T1-E3.07`, and `T1-E3.08` are dependency-free and are listed first so the simplest, lowest-risk plans land before the predicate rewrite.
>
> **Committing two `🟢 LATER` items (`T1-E3.10`, `T1-E3.11`) is an explicit operator ruling** at planning, not spare-capacity drift: the six plans are one designed sequence, and severing it would leave `T1-E3.09`'s predicate and group output with no consumer.

## Delivery Model (this sprint only)
The operator's choice at planning was **`@sprint-run` batch delivery**: one batch invocation that claims plans one at a time to a fixpoint and ends in the single consolidated Gate D report. That is the *mechanism* — but it cannot be one atomic pass.

**All six plans declare mutually overlapping `touches`.** Every one of them edits `.devops/sync-manifest.yaml` and `.devops/logs/version-history.md`; five of the six also edit `.devops/skills/sprint-run/SKILL.md`, and four edit `.devops/skills/pass-the-parcel/SKILL.md` and/or `.devops/plans/template-plan.md`. The claim protocol admits a plan only when **no** plan with an overlapping `touches` set sits in `.devops/plans/` — including one batched to `PHASE_9`. A queue with N mutually-overlapping plans is therefore **N sequential waves**, and this one is **six**.

> This is precisely the `G2` defect recorded at Sprint 8's close (*"Drop — committing a sprint queue without checking mutual `touches` overlap first. Do not repeat."*) — and this sprint contains the two plans that fix it: `T1-E3.06 G2` (the `@sprint-plan` preflight) and `T1-E3.09` (the tested predicate that preflight will call). Sprint 9 is self-referential: it is the last sprint that has to absorb this cost by hand.

| Wave | Plan | Size | Steps |
|------|------|------|-------|
| 1 | T1-E3.06 | S | preview → claim → spawn `ptp-parcel-fast` → `PHASE_9` → wrap-up/archive |
| 2 | T1-E3.07 | M | same, once wave 1 has left `.devops/plans/` |
| 3 | T1-E3.08 | M | same |
| 4 | T1-E3.09 | L | same — **lands the authoritative eligibility script** |
| 5 | T1-E3.10 | M | same, once `T1-E3.09` is archived |
| 6 | T1-E3.11 | L | same, once `T1-E3.09` and `T1-E3.10` are archived |

**Accepted cost:** six serial claims instead of one atomic pass. The claim protocol's file-safety guarantee is not traded away — concurrent edits to `base-context.md` / `sync-manifest.yaml` would corrupt the prefix lock and the `machinery-version` bump.

**Standing instruction for the waves (carried from Sprint 8).** Every plan in this queue edits the machinery that governs the batch loop itself (`sprint-run`, `ptp-parcel-fast`, `pass-the-parcel`) or the host that spawns it (`parcel-sprint.agent.md`, via `T1-E3.10`/`E3.11`). The host MUST **re-read `sprint-run` and re-check preflight before each wave**, rather than carrying wave 1's instruction set into wave 2 — otherwise a wave executes under machinery its predecessor deliberately replaced. This is sharpest at **wave 4**: from `T1-E3.09` onward, `parcel-sprint` is meant to shell out to `scripts/sprint_eligible.py` and halt on a script error — the host's eligibility computation changes mid-sprint by design.

**`machinery-version` collision — every wave after the first is stale by construction.** All six plans independently bump the counter, and each wrote its bump against a base that no longer exists once its predecessors land. The live value today is **`47`**. Each wave MUST read the live value from `.devops/sync-manifest.yaml` and bump from there — never from the number written in its own plan — and record the literal actually used in `.devops/logs/version-history.md` (CI gate). `T1-E3.11` is the plan that moves this ownership to the host/wrap-up, but it is **wave 6**, so waves 1–5 all carry the collision by hand. This is the same hazard that cost Sprint 8 a clean 44/45/46/47 ledger.

## Explicitly Out of Scope
- **`T1-E2.06` (🔴 NOW) — Portable-surface fold review.** Its ordering constraint is "land before the next satellite pull", not "before this sprint". No satellite pull is scheduled this cycle, so it is not committed here; it remains the top of the Triage Panel.
- **`T1-E2.02` — Split the `check-parcel-prefix.ps1` god-script.** Still parked. It touches the same script as `T1-E3.06 G1`, but `G1` only adds a directory to the scan loop; the split is a separate parcel.
- **Relaxing the `touches` predicate, or permitting parallel claims, to make this queue batch in one pass.** The opposite of what `T1-E3.09`/`T1-E3.11` are for — the overlap is real and the fix is to *report* it earlier.
- **Front-loading Phase 3 questions into `@sprint-plan`** so the batch benefits from them — explicitly deferred by `T1-E3.08` (it fixes the interactive path only).
- **A concurrency scheduler beyond two lanes** — explicitly out of scope in `T1-E3.11`.
- **Gap 4 (blast-radius test scoping / where the full suite runs)** — named out of scope by `T1-E3.06`.
- **Rewriting historical records** — `.devops/archive/**`, prior changelog/version-history rows.

## Definition of Done (sprint-level)
- [ ] All six committed parcel plans reach `COMPLETE` and are archived
- [ ] `scripts/check-parcel-prefix.ps1` exits 0 after the final prefix re-inline (four plans touch the prefix lock or `.devops/agents/**`; `T1-E3.07`, `E3.10`, `E3.11` may each drag the 9-agent `-Sync`)
- [ ] `scripts/check-utf8-agents.ps1` ALL CLEAN, **including `.devops/sprints/**`** once `T1-E3.06 G1` lands
- [ ] `scripts/sprint_eligible.py` fixture test green in CI (`T1-E3.09`), and `parcel-sprint` is authoritative on its output
- [ ] `machinery-version` is strictly increasing across all six wave wrap-ups with a matching literal in `.devops/logs/version-history.md` (CI gate)
- [ ] Wiki lint / claims / coverage all exit 0
- [ ] Sprint closed via `@sprint-close` (retro appended to this file + spaghetti scan run)

## Risks / Unknowns
- **Six serial waves, not one batch pass (highest).** All six plans mutually overlap on `sync-manifest.yaml` + `version-history.md`, so the queue can only be claimed one wave at a time (see Delivery Model). The batch mechanism is `@sprint-run`; the *shape* is six sequential claims. Do not treat "committed to a batch" as "runs unattended end to end".
- **Self-referential machinery.** Waves 2–6 edit the runner, the fast lane, and the host (`parcel-sprint.agent.md`) that is executing them. A wave MUST re-read `sprint-run` and re-check preflight before claiming the next plan, or it runs under superseded rules.
- **`machinery-version` collision on waves 1–5.** Every plan bumps from a stale base; `T1-E3.11` (which fixes ownership) is wave 6. Each wave reads the live `47`-and-counting value and records its literal, or CI fails.
- **`T1-E3.09` changes the host mid-sprint.** From wave 4 on, `parcel-sprint` is supposed to run `scripts/sprint_eligible.py` authoritatively and **halt** on a script error (fallback to prose is explicitly forbidden). If the script is wrong, the batch stops at that wave — by design, but it means wave 4 is a hard checkpoint for the rest of the sequence.
- **`Agents: MULTI` in the plans is scaffold boilerplate, and the batch overrules it.** `@sprint-run` writes the locked `AUTO`+`SINGLE` preset at claim time, so the two `L`, cross-cutting plans (`T1-E3.09`, `T1-E3.11`) run with no independent reviewer and no adversarial pass. `T1-E3.10` is the parcel that would flag exactly this; until it lands, the operator accepts the risk. Recorded, not silently ignored.
- **`T1-E3.06 G3` hides a decision, not just a fix.** G3 asks to *adopt* `.devops/backlog/REFACTORING.md` (seed → live, as `SPRINTS.md` was adopted) or to declare the refactoring lane opt-in in `sprint-close`/`sprint-plan`. That is an operator ruling, so the S=1 estimate may be optimistic.
- **Budget is a floor.** 20 pts sits above the `Large` calibration, and several plans edit the pipeline executing them (+1–2 pts each per Sprint 8's signal). Overrun carries forward; it does not expand the sprint.
- **The incoming plans arrived untracked.** `T1-E3.07`–`E3.11` were never committed before this planning commit (they were added to `.devops/backlog/` in the working tree); this sprint commit is their first appearance in git history.

## Retro
*Appended by `@sprint-close` when the sprint closes. Left empty while the sprint is open.*
