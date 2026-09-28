---
type: "sprint"
sprint: 13
name: "V1 Hardening"
slug: "v1-hardening"
status: "open"
capacity_points: 30
created: "2026-09-28"
closed: ""
---

# Sprint 13: V1 Hardening

## Goal
Close every gap the independent review surfaced and ship **v1.1.0**: the four unguarded invariants get checkers, the `touches` false-green is fixed, the hot prose collapses to canon, the regrown sync engine splits below threshold, the wiki stands up an honesty pass, a measured cost baseline is recorded, and the release lands with every gate green on the tag commit.

## Capacity
- Budget: 30 pts (Large — the V1 hardening push, operator ruling 2026-09-28)
- Committed: 27 pts across 9 plans
- Buffer: 3 pts held for spillover / discovery (the Sprint 12 lesson: `T1-E1.05` went S→L after commit — resizes are sprint-level rulings, never plan-level)

## Committed Scope (queue)

> Queue order is the first claim order, not an execution dependency: `@sprint-run` re-evaluates eligibility before each claim and iterates to a fixpoint, so a plan listed above its dependency is still reached once that dependency is satisfied (archive or `GATE_D_USER_APPROVAL`). Do not topologically sort; the runner resolves it. All 9 plans carry `stories:` (legal-state assertion passed 9/9 at commit).

> **▶️ Progress — updated 2026-09-28 at the `T1-E2.12` wrap-up (session handoff).** **1 of 9 committed plans is `COMPLETE` and archived** (`T1-E2.12`, commit trail `f42ff14` → `605a3d0`, green stamp `605a3d0`). **`T1-E2.13` is claimed** (`99e8e5d`) and sits at `Status: PHASE_1`, `Active Persona: Scoper`, Gate A `OPEN`, with **no phase content written** — it resumes cleanly from Group A, and nothing is half-done anywhere in the sprint.
>
> **Live predicate** (`python scripts/sprint_eligible.py`, exit `0`, 2026-09-28): `in_flight: ["T1-E2.13"]`, `orphans: ["T1-E2.13"]`, `eligible: ["T1-E4.05"]`, `claim_order: ["T1-E4.05"]`, `skipped: 6`. Live `machinery-version` is **84**. **The `orphans` entry is this session's live carried claim, not debris** — the predicate's heuristic cannot tell a carried claim from a dead batch spawn (`.devops/skills/sprint-run/SKILL.md` § 1 step 4), so a batch host will offer to **re-adopt** it. That offer is correct: accept it and the runner resumes the plan from its recorded `Status` (`PHASE_1`), which is exactly where it stands.
>
> **The runtime constraint that shapes this sprint — parked as `T1-E1.06`.** On the **opencode surface the `ptp-*` subagents are unreachable**: `subagent` → `ptp-context-hunter` returns `Permission denied: subagent` on a tree where `opencode.json` explicitly grants `"ptp-*": "allow"`, while the non-hidden `wiki-writer` spawns fine — so the exclusion is specific to the `hidden: true` + `mode: "subagent"` entries. Consequences: **`MULTI` cannot run there** (it was claimed, promoted and halted pre-Phase 1 on `T1-E3.22`, then released), and **`@sprint-run`'s `ptp-parcel-fast` is blocked by the same construction**. **Five of the nine committed plans are `MULTI`-triage** (`T1-E3.22`, `T1-E4.04`, `T1-E4.05`, `T2-E2.05`, `T3-E1.05`) and need a surface that exposes the subagents; **four are `SINGLE`** and run anywhere (`T1-E2.12` ✅ complete, `T1-E2.13` claimed, `T1-E3.25`, `T1-E5.03`).
>
> **Where to pick up.** Resume **`T1-E2.13`** in place — its claim is live, its `touches` is already amended to **12 declared / 0 missing** (`write_set_check` exit `0`), and the two amendments are recorded in its front-matter: the parked set named three *consumers* of the reader while the defect lives in `scripts/wiki_lint_core.py`, and the five claim-source wiki docs the edit forces are declared with the re-stamp as an obligation rather than a wrap-up surprise. **Note the serialisation:** holding `T1-E2.13` blocks five of the six remaining plans (`T1-E3.22`, `T1-E3.25`, `T1-E4.04`, `T1-E5.03`, `T2-E2.05` all cite it in their skip reasons), so `T1-E4.05` is the only other claimable plan — **and it is `MULTI`**. On a `MULTI`-incapable surface the sprint is therefore down to **`T1-E2.13` alone** until it ships; finishing it re-opens the queue.
>
> **Hygiene owed at sprint close (not before):** this file's own committed-scope rows already carry their live/archived links below; the `@sprint-close` sweep and spaghetti scan are unstarted; `process-lessons.md` stands at **24 entries** against its ~25 target, so **no fold is owed yet** — but three Sprint 13 plans (`T1-E2.12` shipped, `T1-E3.25` and `T1-E3.22` pending) add rules to the same wrap-up section, so the close should fold that trio once rather than three times. The Triage Panel in `.devops/backlog/backlog-index.md` carries the one item this sprint parked untriaged-to-completion (`T1-E1.06`).
>
> **Superseded 2026-09-28 by the `@sprint-run` batch wrap-up** (`T1-E2.13` + `T1-E4.05`; closing commit `dca146e`; `machinery-version` **84 → 85**, Minor). **3 of 9 committed plans are now `COMPLETE` and archived** (`T1-E2.12`, `T1-E2.13`, `T1-E4.05`). **The runtime constraint described above did not reproduce:** a probe spawn of `ptp-parcel-fast` returned `PROBE_OK` and two live per-plan runs followed, so `@sprint-run` is **not** blocked on this surface — the `MULTI` half stays untested, because `parcel-sprint`'s `permission.task` admits only `ptp-parcel-fast` and `wiki-writer`. The correction is recorded on `T1-E1.06` in the theme register and in the Triage Panel. **Live predicate, post-wrap-up** (`python scripts/sprint_eligible.py`, exit `0`): `eligible: ["T1-E3.22", "T1-E3.25", "T1-E4.04", "T1-E5.03", "T2-E2.05"]`, `claim_order: ["T1-E3.22", "T2-E2.05"]`, `skipped: 4` — **archiving the two plans freed the surfaces they held**, so the queue is no longer serialised behind `T1-E2.13`. The committed-scope rows below (2 and 6) and their links are **stale**; the register rows in `.devops/backlog/t1-parcel-pipeline-machinery-backlog.md` are authoritative. `process-lessons.md` now stands at **25** entries — at its cap, so the next capture owes a fold.
>
> **Superseded again 2026-09-28 by the second `@sprint-run` wave and its wrap-up** (`T1-E3.22` + `T2-E2.05`; closing commit `f214638`; `machinery-version` **85 → 86, graded Major** on an explicit operator ruling — the **first major in the ledger**, because that diff edits a reserved surface **directly** (`.devops/agents/parcel-sprint.agent.md`, not a `-Sync`-forced embed) and rewrites the claim protocol in `.devops/rules/plan-lifecycle.md`). **5 of 9 committed plans are now `COMPLETE` and archived** (`T1-E2.12`, `T1-E2.13`, `T1-E4.05`, `T1-E3.22`, `T2-E2.05`). **Live predicate, post-wrap-up** (`python scripts/sprint_eligible.py`, exit `0`): `eligible: ["T1-E3.25", "T1-E4.04", "T1-E5.03"]`, `claim_order: ["T1-E3.25"]`, `skipped: 3` — archiving freed the held surfaces again, so the queue is one plan deep rather than serialised behind the batch. The committed-scope rows 3, 4 and 8 below are **stale**; the register rows in `.devops/backlog/` are authoritative. **The major's tag step is routed to `T3-E1.05`** (still queued, and the plan that owns the release ceremony) — the counter is still an integer, so release B's dotted flip has not happened and a major tag has no correct name yet. `process-lessons.md` **remains at 25**: this batch *merged* its lesson into the existing `touches` entry rather than adding a 26th, so no fold is owed yet.

| # | Code | Plan | Size | Source tier | Link |
|---|------|------|------|-------------|------|
| 1 | T1-E2.12 | F2's close-out CI read has no checker (and the no-push window has no home) | M (3) | ✅ **COMPLETE 2026-09-28** (`AUTO` + `SINGLE`; 13 Phase 9 evidence rows with the pre-fix probe observed failing; `machinery 83 → 84`, minor) | [plan](../../archive/t1-e2.12-close-out-ci-read-checker-plan.md) |
| 2 | T1-E2.13 | A comment line inside a `touches` block-list silently truncates it | M (3) | 🟡 NEXT — **CLAIMED 2026-09-28**, `Status: PHASE_1`, Gate A `OPEN`, **resume at Group A** (declaration amended to 12 paths) | [t1-e2.13-block-list-comment-truncation-plan.md](../../plans/t1-e2.13-block-list-comment-truncation-plan.md) |
| 3 | T1-E3.22 | The manual claim path has no enumerated green baseline | M (3) | 🟢 LATER | [t1-e3.22-manual-claim-baseline-plan.md](t1-e3.22-manual-claim-baseline-plan.md) |
| 4 | T1-E3.25 | The green-stamp invariant has no checker | S (1) | ✅ **COMPLETE 2026-09-29** (`AUTO` + `SINGLE`; `--stamp` assertion + classifier, 27/27 fixtures with pre-fix probes observed failing; `machinery 86 → 87`, patch) | [plan](../../archive/t1-e3.25-green-stamp-invariant-gate-plan.md) |
| 5 | T1-E4.04 | Single-source the hot prose (the three highest-value rule fan-outs) | L (5) | 🟡 NEXT | [t1-e4.04-hot-prose-single-sourcing-plan.md](t1-e4.04-hot-prose-single-sourcing-plan.md) |
| 6 | T1-E4.05 | Split the regrown sync engine | L (5) | 🟡 NEXT (Kill List top-priority OPEN, via the stabilisation-sprint path) | [t1-e4.05-sync-engine-split-plan.md](t1-e4.05-sync-engine-split-plan.md) |
| 7 | T1-E5.03 | No quantitative read-cost lever remains on the plan record | S (1) | 🟢 LATER | [t1-e5.03-plan-record-size-lever-plan.md](t1-e5.03-plan-record-size-lever-plan.md) |
| 8 | T2-E2.05 | Wiki V1 honesty pass | M (3) | 🟡 NEXT | [t2-e2.05-wiki-v1-honesty-pass-plan.md](t2-e2.05-wiki-v1-honesty-pass-plan.md) |
| 9 | T3-E1.05 | v1.1.0 release + measurement baseline | M (3) | 🟡 NEXT | [t3-e1.05-v110-release-baseline-plan.md](t3-e1.05-v110-release-baseline-plan.md) |

## Delivery Model

The § 4c triage flags for the committed set, plus the eligibility predicate's own recorded output. **Never a hand-derived wave count.**

| Code | Size | Flag | Signals that fired |
|------|------|------|--------------------|
| T1-E2.12 | M (3) | `—` (SINGLE) | blast-radius backstop only (10 declared `touches`; commit-time judgement: checker-shaped, no contract change) |
| T1-E2.13 | M (3) | `—` (SINGLE) | blast-radius backstop only (6 declared `touches`; commit-time judgement: deterministic script fix + fixtures) |
| T1-E3.22 | M (3) | `MULTI` | blast radius (4-file claim-protocol change reaching satellites) |
| T1-E3.25 | S (1) | `—` (SINGLE) | blast-radius backstop only (4 declared `touches`, one a `scripts/` dir; commit-time judgement: wrap-up-time assertion, explicitly small) |
| T1-E4.04 | L (5) | `MULTI` | blast radius (12 files) + contract change (the #1 safety invariant's prose + PREFIX-LOCKED prefix cascade) |
| T1-E4.05 | L (5) | `MULTI` | blast radius (engine + lib modules + SelfTest fixtures) + contract change (the satellite trust boundary) |
| T1-E5.03 | S (1) | `—` (SINGLE) | none — all five low (the script's backstop does not fire: 3 declared `touches`) |
| T2-E2.05 | M (3) | `MULTI` | blast radius (19 core slots + 7 indexes) + contract change (wiki-facing truth every cold start consumes) |
| T3-E1.05 | M (3) | `MULTI` | blast radius (8 files incl. reserved wrap-up surfaces) + contract change (release ceremony + operator-facing truth sweep) |

> **`Flag`** is the § 4c triage recommendation for that plan (`MULTI` / `—`), with the signals that fired named in the row. A `MULTI` row in a `@sprint-run` batch is surfaced as an **accept batch risk / defer to manual** fork before the first claim (`@sprint-run` § 1) — the batch's locked `AUTO` + `SINGLE` preset cannot honour the recommendation. No `MICRO` row is committed (manual-path only — `.devops/rules/plan-lifecycle.md` § *Micro Lane*).

**Predicate snapshot** — recorded at commit time, once the committed plans are in this folder and before the sprint is registered in `SPRINTS.md`:

`python scripts/sprint_eligible.py --sprint-dir .devops/sprints/sprint-13-v1-hardening` (exit `0`, 2026-09-28)

- `claim_order`: ["T1-E2.12", "T1-E3.22", "T2-E2.05"]
- `skipped`: [{"code": "T1-E2.13", "reasons": ["touches overlap: T1-E2.12 via scripts", "touches overlap: T1-E3.22 via .devops/rules/plan-lifecycle.md"]}, {"code": "T1-E3.25", "reasons": ["touches overlap: T1-E2.12 via .devops/skills/agent-wrap-up/skill.md", "touches overlap: T1-E3.22 via .devops/rules/plan-lifecycle.md"]}, {"code": "T1-E4.04", "reasons": ["touches overlap: T1-E2.12 via .devops/sync-manifest.yaml", "touches overlap: T1-E3.22 via .devops/rules/plan-lifecycle.md"]}, {"code": "T1-E4.05", "reasons": ["touches overlap: T1-E2.12 via scripts"]}, {"code": "T1-E5.03", "reasons": ["touches overlap: T1-E2.12 via scripts", "touches overlap: T1-E3.22 via .devops/rules/plan-lifecycle.md"]}, {"code": "T3-E1.05", "reasons": ["unmet depends_on: T1-E4.04", "unmet depends_on: T1-E4.05", "touches overlap: T1-E2.12 via .devops/sync-manifest.yaml", "touches overlap: T1-E3.22 via how-to.md"]}]
- `lanes`: serial — T1-E2.12, T1-E2.13, T1-E4.04, T1-E4.05, T3-E1.05; parallel — T1-E3.22, T1-E3.25, T1-E5.03, T2-E2.05 (`parallel_groups`: [["T1-E3.22", "T2-E2.05"]] — advisory only, every path runs in place serially)
- `multi_worthy`: 8/9 (all but T1-E5.03 — the mechanical blast-radius backstop; commit-time triage recommends `MULTI` for 5 of the 8, `SINGLE` for T1-E2.12 / T1-E2.13 / T1-E3.25 with the reason recorded in the Flag table above)
- `mode_conflicts`: 0 — no queued plan carries an authored Plan Settings block yet, so no batch-preset overrule to surface
- `in_flight`: [] · `orphans`: [] · `already_phased`: []

> **Forecast, never a schedule:** the snapshot is exact at the moment it is taken and stale the moment the first claim lands. `@sprint-run` § 2 re-evaluates the predicate against the live `.devops/plans/` immediately before **each** claim, so the executed set may differ. A non-zero exit from the command above is a **stop** — fix the plan file it names; never re-derive the predicate by hand.

**Accepted cost:** one Gate D verdict and one wrap-up per wave — not one consolidated verdict; a committed plan holds its files from claim until its verdict plus wrap-up archives it, and the number of waves is whatever the live predicate produces. This queue is near-fully serial by construction (6 skipped at commit on real `touches` overlap over shared surfaces) — that is the reserved-surface discipline doing its job, recorded here as a planning fact, not a run-time surprise. No trim: the overlaps are genuine, and relaxing the predicate to look batchable is forbidden.

**Execution recommendation:** mixed path — the 4 `SINGLE`-triage plans (T1-E2.12, T1-E2.13, T1-E3.25, T1-E5.03) via `@sprint-run` (no independent-review loss; their own triage says SINGLE), the 5 `MULTI`-triage plans manually with independent review. Note the fork still surfaces the 3 SINGLE-but-backstop-flagged plans (T1-E2.12 / T1-E2.13 / T1-E3.25) at the batch preview — accept-batch-risk is honest there (checker-shaped, no reviewer value) and recorded.

## Explicitly Out of Scope
- **T1-E2.10** (counter contract seams) — stays parked per the standing ruling; both readings recorded, not re-litigated
- **Release B** (the dotted `1.0.73` flip) — stays a separate release decision (carried from Sprint 12)
- **Two-lane concurrent execution** — the `T1-E3.11` descoped half, unchanged
- **W4 deletion-first lifecycle hook** — stays deferred by operator decision
- **`wiki_claims.py` / `sprint_eligible.py` / `spaghetti-monster-scan.cjs` splits** — WATCH-grade Kill List rows, next sprint's slice
- **Skill library trim** — ruled: keep all 34 (operator ruling 2026-09-28; CORE already solves satellite weight)
- **Satellite field-proof of the wiki** — post-V1 follow-up; `T3-E1.05` records the template-side baseline
- **The Kill List refactoring slice as separate work** — declined as a slice (Sprint 12 precedent); the top-priority row rides inside this sprint as `T1-E4.05`, and the `@sprint-close` scan still runs as normal

## Definition of Done (sprint-level)
- [ ] All committed parcel plans reach COMPLETE and are archived
- [ ] No unguarded invariant from the review's list — T1-E2.12 / T1-E2.13 / T1-E3.22 / T1-E3.25 checker-backed, or ruled out with recorded rationale
- [ ] `rule_fanout.py`: 0 unauthorised across 12 registered rules, 0 unlinked-allowed-surfaces (three new registrations land with T1-E4.04)
- [ ] Kill List top-priority closed — sync engine + bindings below the 400-line warn, proven against pre-split goldens
- [ ] Wiki honesty — no "— never verified" on machinery-facing slots, app-facing docs marked `status: template`, lint + claims green
- [ ] Measured baseline recorded in MATURITY (T3-E1.05)
- [ ] All gates green on the tag commit — prefix, UTF-8, lint, claims, coverage, YAML, JSON, SelfTest, fixtures, version discipline
- [ ] `v1.1.0` tagged, CHANGELOG closed, MATURITY re-graded with the sprint's history row
- [ ] Sprint closed via @sprint-close (retro appended to this file + spaghetti scan run)

## Risks / Unknowns
- **Self-referential plans** — T1-E4.04 edits the prefix the agents running it re-read (`-Sync` mid-sprint); T1-E3.22/T1-E3.25/T1-E2.12 edit the claim/wrap-up rules their own claims and wrap-ups obey; T1-E4.05 splits the engine the sprint's own preflight uses. All have precedent (`T1-E2.09` ran this shape safely with `MULTI` + per-phase review).
- **Claim-source cascade** — T1-E4.04, T2-E2.05 and T3-E1.05 touch sources that whole-file Grounded Claims bind to (the Sprint 12 lesson, now recorded in `process-lessons.md`): declare the re-stamp in the write set, never read around it.
- **HOW-TO topology-drift ownership** — T1-E4.04's citing-surface sweep and T2-E2.05's finding 4 name the same fix; both plans carry the ownership question in Phase 3 so it lands exactly once.
- **Estimation drift on the two L parcels** — buffer held at 3 pts; T1-E4.05 committed at L (5) against an M→L range. Resizes are sprint-level rulings.
- **The 8/9 `multi_worthy` fork on any batch run** — the mechanical backstop fires on blast radius alone; the commit-time triage (5 MULTI / 4 SINGLE with reasons) is the judgement the fork presents alongside it.

## Retro
*Appended by `@sprint-close` when the sprint closes. Left empty while the sprint is open.*

### Goal — Met?
{Restate the goal. Yes / Partially / No, with one-line why.}

### What Shipped
| Code | Plan | Size | Effort accuracy | Notes |
|------|------|------|-----------------|-------|
| — | — | — | — | — |

### Carry-Forward
| Code | Why not done | New size | Next sprint? |
|------|--------------|----------|--------------|
| — | — | — | — |

### Metrics: Before → After
- Hot spots (>CCN 15): {X} → {Y}
- Files >400 lines: {X} → {Y}
- Test count: {X} → {Y}
- Lint warnings: {X} → {Y}
- Capacity: committed {pts} / delivered {pts} = {accuracy %}

### Retro: Keep / Drop / Try
- **Keep** (worked, do again): {…}
- **Drop** (hurt, stop): {…}
- **Try** (next sprint experiment): {…}

### Lessons for the Wiki / Knowledge Capture
{Any durable insight worth promoting via @knowledge-capture. Reference KC numbers if recorded.}

### New Refactoring Items (→ REFACTORING.md)
{List files flagged by the close-of-sprint scan. Confirm they were added to the Kill List.}
