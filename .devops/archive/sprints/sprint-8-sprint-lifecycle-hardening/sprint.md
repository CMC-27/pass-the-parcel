---
type: "sprint"
sprint: 8
name: "Sprint Lifecycle Hardening"
slug: "sprint-lifecycle-hardening"
status: "closed"
capacity_points: 10
created: "2026-09-15"
closed: "2026-09-16"
---

# Sprint 8: Sprint Lifecycle Hardening

## Goal
By the end of Sprint 8, an executed plan sitting at `PHASE_9` with Gate D `OPEN` is a **first-class, machine-checkable claim status** (`GATE_D_USER_APPROVAL`) that satisfies a dependant's `depends_on` and unblocks intra-queue chains in `@sprint-run`; the batch host has a **coalesced wrap-up** that confirms, completes and archives a batch in one pass; and "Parcel Fast" exists as **one entity**, reachable only through `parcel-sprint` → `ptp-parcel-fast`.

## Capacity
- Budget: 10 pts (Standard)
- Committed: 9 pts across 3 plans
- Buffer: 1 pt held for spillover / discovery

> **Calibration note:** no prior `sprint.md` exists, so the retro's capacity-accuracy line is the first datapoint. The effective load is higher than 9 pts suggests — T1-E3.03 edits ~14 files plus regenerated agent copies, and each wave carries its own Gate D verdict and wrap-up (see Delivery Model).

## Committed Scope (queue)
| # | Code | Plan | Size | Source tier | Link |
|---|------|------|------|-------------|------|
| 1 | T1-E3.05 | Retire the selectable `parcel-fast` orchestrator | M | ⚪ PARKED | [t1-e3.05-retire-parcel-fast-orchestrator-plan.md](t1-e3.05-retire-parcel-fast-orchestrator-plan.md) |
| 2 | T1-E3.03 | `GATE_D_USER_APPROVAL` claim status + dependency predicate + fixpoint batch runner | M | 🟡 NEXT | [t1-e3.03-gate-d-user-approval-plan.md](t1-e3.03-gate-d-user-approval-plan.md) |
| 3 | T1-E3.04 | Batch sprint wrap-up for `parcel-sprint` | M | 🟢 LATER | [t1-e3.04-sprint-batch-wrap-up-plan.md](t1-e3.04-sprint-batch-wrap-up-plan.md) |

> **Queue order is load-bearing, not cosmetic.** The `#` column is the claim order. See Delivery Model.
>
> **Operator reorder (2026-09-15, at the run preview).** The queue was committed `03 → 04 → 05`; the operator directed the batch to start with T1-E3.05 instead, on the grounds that it is dependency-free and removes the duplicate `parcel-fast` agent first. Because T1-E3.04 requires T1-E3.03 to be **archived** before it can be claimed, the only valid execution of that direction is **05 → 03 → 04**. T1-E3.05's `D9` ("refresh the `parcel-fast` preset-provenance boilerplate in the parked T1-E3.03/E3.04 plans") also becomes actionable under this order, because both are still in the queue rather than already archived.
>
> **T1-E3.05 triage gap (recorded, not fixed here).** T1-E3.05 was registered in the T1 theme register but never added to the Triage Panel in `backlog-index.md`, so it carried the ⚪ PARKED tier rather than a triaged one. It is committed here by operator instruction. Fixing the panel row is a `backlog-index.md` edit that no plan in this queue owns — routed to the sprint-close backlog sweep instead of being silently patched.

## Explicitly Out of Scope
- **The `parcel-sprint` batch wrap-up execution itself.** T1-E3.04 *specifies* the batch wrap-up; running it is post-Gate-D behaviour and is not exercised by this sprint's own delivery, which wraps each plan individually.
- **Gap 4 (blast-radius test scoping + where the full suite runs).** Named as out of scope by T1-E3.05; it is a separate parcel.
- **Retiring or narrowing per-plan `@agent-wrap-up`.** T1-E3.04 adds a batch *scope*; the per-plan path stays valid and composes.
- **Redesigning the preset mechanism, or introducing a replacement selectable fast orchestrator.** T1-E3.05 removes one; it must not add one.
- **Rewriting historical records** — `.devops/archive/**`, prior `CHANGELOG.md` rows, prior changelog entries.
- **T1-E2.02 (`check-parcel-prefix.ps1` split).** Still parked; it touches the same script as T1-E3.05 but is not committed here.
- **Relaxing the `touches` predicate, queue order, or worktree isolation** to make this sprint batch in one pass.

## Delivery Model (this sprint only)

This sprint **cannot** be delivered as one `@sprint-run` batch pass. The three plans declare mutually overlapping `touches` (all three edit `.devops/agents/**`, `base-context*`, `sync-manifest.yaml`, `version-history.md`, `HOW-TO.md`), and T1-E3.04 declares `depends_on: ["T1-E3.03"]` with a written requirement that E3.03 be **archived** — not merely at `PHASE_9` — before E3.04 may be claimed.

The claim protocol blocks a claim while any plan with an overlapping `touches` set sits in `.devops/plans/`, **including one already batched to `PHASE_9`**. So a single batch would claim T1-E3.03 and skip the other two with recorded reasons.

Delivery is therefore **three serial waves**, in the operator-reordered sequence:

| Wave | Plan | Steps |
|------|------|-------|
| 1 | T1-E3.05 | preflight preview → claim → spawn `ptp-parcel-fast` → `PHASE_9` → **operator Gate D verdict** → wrap-up/archive |
| 2 | T1-E3.03 | same, once E3.05 has left `.devops/plans/` |
| 3 | T1-E3.04 | same, once E3.03 has left `.devops/plans/` |

**Accepted cost:** three Gate D verdicts instead of the batch path's single consolidated one. The claim protocol's file-safety guarantee is not traded away for convenience — concurrent edits to `base-context.md` / `sync-manifest.yaml` would corrupt the prefix lock and the `machinery-version` bump.

> **Standing instruction for the waves.** Every plan in this queue edits the machinery that governs the batch loop itself (`sprint-run`, `ptp-parcel-fast`, `pass-the-parcel`) or the agent doing the spawning (`parcel-sprint.agent.md`, via T1-E3.05's prefix `-Sync`). The host therefore **re-reads `sprint-run` and re-checks preflight before each wave**, rather than carrying wave 1's instruction set into wave 2 — otherwise a wave would be executed under machinery its predecessor deliberately replaced.

## Definition of Done (sprint-level)
- [ ] All three committed parcel plans reach COMPLETE and are archived
- [ ] `check-parcel-prefix.ps1` exits 0 after the final prefix re-inline (the E3.03 then E3.05 pair both touch the prefix lock)
- [ ] `check-utf8-agents.ps1` exits 0
- [ ] `machinery-version` is strictly increasing across the three wrap-ups with a matching literal in `version-history.md` (CI gate)
- [ ] Wiki lint / claims / coverage all exit 0
- [ ] Sprint closed via `@sprint-close` (retro appended to this file + spaghetti scan run)

## Risks / Unknowns
- **`machinery-version` collision — every wave after the first is stale by construction.** All three plans independently bump the version, and each wrote its bump against a base that no longer exists once its predecessors land. With the reordered sequence `05 → 03 → 04`, the live value is `43` today, so: **wave 1 (E3.05)** does `43 → 44` exactly as written; **wave 2 (E3.03)** must do `44 → 45`, though its plan says `43 → 44`; **wave 3 (E3.04)** must do `45 → 46`, though its plan says `44 → 45`. Each wave must read the **live** value from `.devops/sync-manifest.yaml` and bump from there, never from the number written in its own plan — and must record the literal it actually used in `version-history.md` (CI gate). The same applies to per-file `version:` fields in `pass-the-parcel` and friends, whose recorded line numbers are already stale (E3.03 cites `pass-the-parcel` v10→11 and `sprint-run` v1→v2; the live `pass-the-parcel` is v13).
- **Overlap with T1-E3.03/E3.05 on `.devops/backlog/t1-parcel-pipeline-machinery-backlog.md`.** Neither plan declares it in `touches`; T1-E3.05's D8 does edit it. The register row updates therefore land in whichever wave owns them, and sprint close must reconcile rather than assume.
- **T1-E3.05 deletes a live agent file.** `.devops/agents/parcel-fast.agent.md` currently exists and passes `check-parcel-prefix.ps1`; the registry row, the agent file, and the `opencode.json` entry must be removed **together** or the prefix check fails hard.
- **T1-E3.05 Phase 3 Q&A is unrecorded.** Its five questions are still open (`[ ]`) rather than resolved; under the spawned `AUTO` preset they are auto-resolved at Phase 3.5, which is a weaker evidence bar than the interactive resolution E3.03/E3.04 received.

## Retro

### Goal — Met?
**Yes.** An executed plan at `PHASE_9` with Gate D `OPEN` is now a first-class, machine-checkable claim status (`GATE_D_USER_APPROVAL`) that satisfies a dependant's `depends_on`; the batch host has a coalesced batch wrap-up with a fail-closed confirmation gate; and "Parcel Fast" exists as one entity, subagent-only.

**But achieved through a delivery model materially different from the plan.** The sprint was committed as one queue and expected to batch; it was delivered as **three serial waves**, because all three plans declared mutually-overlapping `touches` and T1-E3.04 required T1-E3.03 to be *archived* before it could be claimed. Three Gate D verdicts were required instead of the batch path's one. The operator approved this at the run preview and then reordered the queue (`05 → 03 → 04`).

### What Shipped
| Code | Plan | Size | Effort accuracy | Notes |
|------|------|------|-----------------|-------|
| T1-E3.05 | Retire the selectable `parcel-fast` orchestrator | M | 3 est / ~3 — **accurate** | Agent file + registry row + presets row + both config entries removed together (bidirectional pairing); prefix re-inlined ×9; `prune_files` entry added. Wave 1. |
| T1-E3.03 | `GATE_D_USER_APPROVAL` status + dependency predicate + fixpoint runner | M | 3 est / ~5 — **underestimated** | 24 files (15 hand-edited + 9 regenerated). Touches the prefix lock, `plan-lifecycle`, and 6 skills at once. Wave 2. |
| T1-E3.04 | Batch sprint wrap-up for `parcel-sprint` | M | 3 est / ~4 — **underestimated** | 15 files, plus 11 paths added to `touches` mid-plan after its own change falsified prefix prose. First live use of the scope it defines (it retired itself). Wave 3. |

### Carry-Forward
| Code | Why not done | New size | Next sprint? |
|------|--------------|----------|--------------|
| — | None. All three committed plans reached `COMPLETE` and are archived. | — | — |

### Metrics: Before → After
- Hot spots (>CCN 15): **not measurable** — the CCN scanner cannot run in this workspace (`spaghetti-monster-scan.cjs` hard-crashes on a missing `src/`: `ENOENT … src`). See G3 in `T1-E3.06`.
- Files >400 lines (code/machinery, manual pass): **4 → 4** — `sync-architecture.ps1` (995), `app-vision-north-star/SKILL.md` (633), `wiki_lint.py` (485), `package-lock.json` (401, generated). None was touched this sprint, and the ritual has never surfaced any of them because the scanner only walks `src/`.
- Test count: **0 → 0** — no test suite in this template repo.
- Lint warnings: **0 → 0** — `wiki_lint` clean; no JS/TS lint configured.
- Gates: `check-parcel-prefix` **PASS**, `check-utf8-agents` **ALL CLEAN**, `wiki_lint` **0**, `wiki_claims` **0 stale**, `wiki_coverage_check` **OK**, `sync-architecture -SelfTest` **OK**, CI machinery-version predicate **OK** — all re-run green at every wave boundary and at close.
- `machinery-version`: **43 → 47** (E3.05 43→44 → +1 wrap-up → 45; E3.03 45→46; E3.04 46→47), each with its literal recorded in `version-history.md`.
- Capacity: committed **9 pts** / delivered **9 pts** = **100%** — but honest only because all three were size **M**; the *effort* was nearer 12 pts (E3.03 and E3.04 both overran because each one changed the machinery that governs the run). **New calibration signal: a plan that edits the pipeline that is executing it costs roughly +1–2 pts.**

### Retro: Keep / Drop / Try
- **Keep** — the per-wave `run → Gate D verdict → wrap-up` rhythm. It was forced by the overlap predicate, but it produced three small, individually-reviewable, individually-reversible verdicts instead of one large one. It also caught E3.05's capability question and E3.04's product question at the right moment.
- **Keep** — independently re-running every gate and recomputing the predicate at each wave boundary (rather than trusting the runner's report). The independent predicate implementation caught nothing false, but it *proved* the clause separation live rather than asserting it.
- **Keep** — declaring scope widening in `touches` **before** editing. Used twice (E3.03's `sprint-close`; E3.04's 11 prefix paths), both recorded, neither silent.
- **Drop** — committing a sprint queue without checking mutual `touches` overlap first. This is G2, and it cost the sprint its single-verdict batch. Do not repeat.
- **Drop** — trusting a skill's ritual step to be runnable. `@sprint-close` § 2 crashed and had no target register; both were discovered only at close. This is G3.
- **Try** — for the next sprint, run the `touches`-overlap test *by hand* at planning time (until G2 lands) and record the resulting wave count in `sprint.md` as part of the queue. Treat N waves as the default, not the exception.

### Lessons for the Wiki / Knowledge Capture
- **App-domain → none.** This sprint changed no application behaviour; it is machinery end to end. Nothing to add to `.wiki/core/18-knowledge-capture.md`.
- **Machinery → one existing entry annotated, no new entries.** The session's candidate lesson (`touches` overlap means a queue cannot batch itself) was **already** in `.devops/rules/process-lessons.md` (2026-09-13) *including its planner-facing "do instead"* — adding it again would have been a restatement, which the capture admission gate forbids and the one-entry budget exists to stop. The real gap is that the lesson was never **folded into its owning skill**; it is now annotated with its fold target, `T1-E3.06 G2`. This is the first sprint where the machinery register did **not** grow.
- **One observation recorded here rather than as a rule:** a capability widening in `opencode.json` silently falsified a sentence in the shared prefix describing the *old* capability, and nothing mechanically forces that coupling — `check-parcel-prefix.ps1` proves the 9 agent copies agree with each other, not that their content is still true. Held up by judgement plus the declare-first rule. **Single edge case** (trigger: the mid-sprint realisation that a leaner wrap-up was needed); its one-off trigger is why it is a retro line and not a process lesson.
- **Process-lessons register review (sprint-close § 6) — no folds due.** Every entry in `.devops/rules/process-lessons.md` remains valid and unmatured; none was folded into its owning skill this sprint. The one entry with a *pending* fold target is 2026-09-13 (`touches` overlap means an aggregate-bundle queue cannot batch itself) → `T1-E3.06 G2`: it cannot be folded and deleted until G2 ships the `@sprint-plan` preflight, so it correctly stays staged. Register size unchanged (~20 entries, under the ~25 tidy ceiling). Two entries were re-examined against this sprint's evidence and confirmed still live — including 2026-09-13 (the batch preset overrules a sprint's recorded plan settings), which was **not** triggered here because the queue's `USER-MANAGED`/`MULTI` values were unedited scaffold boilerplate rather than operator *rulings* — the discriminator that entry already names.

### New Refactoring Items (→ REFACTORING.md)
**None.** The close-of-sprint scan could not run (`ENOENT: … src`, see `T1-E3.06` G3), so a **manual** line-count pass over the 50 files the sprint touched was substituted: no file crossed the >400-line or high-CCN threshold. The only code file over 300 lines was `scripts/check-parcel-prefix.ps1` (369), **already** parked as `T1-E2.02` ("Split the `check-parcel-prefix.ps1` god-script").

> **Two blockers to the Kill List update, both filed under `T1-E3.06` G3:** (1) the scanner crashes instead of no-oping without `src/`, and never scans the machinery roots; (2) `.devops/backlog/REFACTORING.md` **does not exist** in this repo — only its seed — so the promotion step has no target and `@sprint-plan`'s Kill List source is empty by construction. The refactoring lane is dormant; adopting the register (as `SPRINTS.md` was adopted at this sprint's planning) is a decision, not an oversight to patch at close.
