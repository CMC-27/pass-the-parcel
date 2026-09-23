---
type: "core"
name: "Agent Changelog"
status: "stable"
description: "Chronological record of all AI agent actions, changes, and audits."
---

# Agent Changelog

All changes made by AI agents are tracked chronologically below.

---

## 2026-09-23 - Sprint 10 wave 3 (final): the owner loop closes — story → dev → user test → report (E3.16)

**Why:** The sprint's last parcel, run alone once its `touches` blockers archived. `@sprint-plan` v6→7 §6 now drafts one or more owner-voice stories per committed plan into a `stories:` front-matter row (derived from the plan's acceptance criteria where present, from the operator's intent line otherwise); `template-plan.md` Phase 4 gains the "User Story (criteria trace to it)" input so criteria are checked against the story, not just the mechanics; `@sprint-close` v9→10 §5 item 2 cites the field (story presented first, criteria fallback) with **no renumber** — anchored to E3.15's pre-built sentence exactly as its hand-off directed. Smallest surface held: no persona/agent cascade (Q1 — 11 files and `-Sync` ×9 for one guidance line the template scaffold already carries), no `plan-lifecycle.md` edit (outside `touches`; it does not enumerate optional rows). **Sprint 10 is now 7/7 delivered, 11/11 pts** — every committed parcel `COMPLETE` + archived. Follow-up parked as `T1-E3.18` (the `stories:` row has no gate behind it). Confirmation gate 5/5; repo gates green (lint 0, claims 0 stale, prefix PASS×9/NOMODEL×12, utf8 182 clean); `machinery-version` 70→71 (single batch writer).
**Ref:** `<pending — this wrap-up commit>`

## 2026-09-23 - Sprint 10 wave 2: claims gate + user-testing walk + owner framing + feedback pathway (E3.14/15/17/E1.02)

**Why:** Second batch of the owner-loop sprint, one consolidated Gate D per wave. E3.14: wrap-up Phase 7a becomes a 3-gate hard stop (lint + coverage **and** `wiki_claims.py check` with the named `update` repair path, no blind restamp) — `coverage` green + `check` red can no longer read as "verified"; the write set shrank (one home, wrap-up v16→17). E3.15: `@sprint-close` v8→v9 §5 runs a sprint-wide user-acceptance walk one-by-one via the ask tool, verdicts to `user-testing.md`, archive carries it — answered its open question: acceptance (owner) vs Gate D verification (executor), not a duplicate. E3.17: product-owner framing canonical in `OPERATING-PRINCIPLES.md` (user = product owner, agents = dev team), `-Sync` ×9; its first spawn died after writing Plan Settings and the new interrupted-run contract proved itself — re-spawn resumed cleanly, nothing fabricated. T3-E1.02: parcel-feedback pathway in `@sync-architecture` v9→10 (satellite `feedback/` outbox → operator hand-carry → template backlog intake, security-free by design) — and the wave-1 stale §-citation closed inside its write set. Six of seven committed parcels now `COMPLETE`+archived; only `T1-E3.16` remains (`touches`-blocked until this wrap-up archived its blockers). Confirmation gate 5/5 per plan; repo gates green; `machinery-version` 69→70 (single batch writer).
**Ref:** `2d508fa..318719b` (wrap-up set)

## 2026-09-23 - Sprint 10 batch 1: business report lands template-side; Phase 9 gate hang fixed (E3.12 + E3.13)

**Why:** First batch-run of Sprint 10's owner-loop queue. E3.12: `@sprint-close` v7→v8 adds the stakeholder-facing Step 5 "Write the Business Report" (per-outcome/epic/theme grouping, tone rules, show-and-tell), the archive carries `business-report.md`, and the `SPRINTS.md` row links it — the satellite-proven fix landed template-side so the next sync propagates it instead of overwriting it. E3.13: `@test-and-deploy` v6 mandates the one-shot, non-interactive gate invocation (`vitest run` / `--run` / `CI=true`) that killed the live GRID-Link hang; gate-invocation hygiene + the named interrupted-run resume contract now live **once** in `plan-lifecycle.md` (§ Gate Invocation Hygiene, § Interrupted Run — Phase 9 only, never re-run 1–8, never fabricate evidence), cited by `ptp-parcel-fast` v9, `sprint-run` v11 and `template-plan.md`. Batch ran 2 of 7 plans — the other 5 are `touches`-blocked until these archive; a zero-eligible fixpoint is the normal terminal state, the wrap-up cadence un-blocks the next run. Confirmation gate passed 5/5 assertions per plan; repo gates green (prefix NOMODEL×11, utf8 188 clean, lint 0, claims 0 stale); `machinery-version` 68→69 (single batch writer).
**Ref:** `e4f1ad8..0e39ef5` (wrap-up pair)

## 2026-09-20 - One session owns the plan; session-rotation phrasing retired (machinery 67 -> 68)

**Why:** `T1-E4.02`'s direct fix (`e80950e`) removed the session-rotation rule but never stated its replacement, and three live docs kept the `one phase-group per session` wording — so the orchestrator re-derived the retired rule and handed the operator an *"open a fresh session / say continue"* baton, twice, on `T1-E1.04`. The positive rule now lives once in `@pass-the-parcel` § Review Gates item 1 (v25 -> v26) and is mirrored into the shared prefix + seed (all 9 locked agents), the orchestrator body, and the plan template's State & Gates boilerplate (*records state, never a handoff instruction*); the three fragments (`q-and-a`, `true-or-false`, `18-knowledge-capture.md`) are swept, and *Strict Context Isolation* is redefined as the **sub-agent's** cold context. Proved by a scoped live-surface grep: the four stale phrases return **0** hits (`.devops/archive/**` + `.devops/logs/**` excluded). Gates: `check-parcel-prefix` PASS x9 / NOMODEL x11, `check-utf8-agents` ALL CLEAN (181 files), `wiki_lint` 0, `wiki_claims` 0 stale, `rule_fanout` 0 unauthorised across 8 rules.
**Ref:** `a43a368`

## 2026-09-20 - Model routing inverted: no agent declares a model (machinery 66 -> 67)

**Why:** `T1-E1.03`'s registry-canonical force-stamp is reversed — the third position on this axis after `T1-E1.01`, and the first to **delete** the binding rather than relocate it. All 11 frontmatter `model:` lines and all 11 `opencode.json` values are gone; the registry drops to two cells (key + capability class) as the recommendation input for a new **run-time** question — per gate (A/B/C/D) in `MULTI`, one per batch under `@sprint-run`. The guarding gate was **moved, never deleted** (`@Managed Simplicity`): `check-parcel-prefix` now asserts **absence** (`NOMODEL`) and `sync-architecture` strips instead of stamping. Runtime asymmetry stated, not blurred: VS Code honours a spawn-time model, opencode cannot (#6651 open) and halts explicitly.
**Ref:** `32179bb`

## 2026-09-18 - In-place single-claim execution, worktree retired (machinery 64 -> 66)

**Why:** Operator runs one sprint / one plan at a time and verifies in the single dev server — a worktree would need a second server to check. Claim protocol is now in-place only (no worktree, no plan branch); `@sprint-run` deviations 4 -> 3; skills + seeds bumped; prefix re-inlined ×9 (PASS). Gates: wiki_lint 0, claims 0 stale, fanout 0 unauthorised, 62 fixtures OK.
**Ref:** `2da6357`

---

## 2026-09-19 - T1-E2.02 ruled won't-fix, parked plan retired

**Why:** Operator ruling per Managed Simplicity: 370-line script sits under the 400-line threshold, so the split's three new wiring points exceed the benefit. Parked file retired to `.devops/archive/`; register Completed; `REFACTORING.md` row to WATCH. Backlog open queue fully clear (T1/T2/T3).
**Ref:** `8a096ce`

---

## 2026-09-18 - T1-E4.02 closed as resolved-by-direct-fix

**Why:** The parked topology review never ran as a parcel because its concrete misfire was already fixed directly: `e80950e` (one-orchestrator-delegates-phase-groups, 15 files) plus this session's reviewer `edit: allow` unblock. Registered as Completed with the residual audit named as deferred by operator choice. Triage Panel back to queue clear.
**Ref:** `aeaa0de`

---

## 2026-09-18 - Sprint 9 closed; T1-E2.06 fold review to Gate D (machinery 63 -> 64)

**Why:** Cleared the four open risks in one serial pass — Sprint 9 archived (20/20 pts, two-lane execution descoped on record), the pull-blocking fold landed (satellite lesson verbatim, exported-seam + template-side fold rules, merge-by-name semantics), `TRIAGE.md` adopted, reviewer write-unblock committed. Skips: Phases 2–3 (no `src/`, machinery-only).
**Ref:** `726221a`

---

## 2026-09-18 - PO wording: what/where/when/why + linked artefacts

**Why:** User's own words replace my paraphrase in `communication-rules.md` — the PO wants what, where, when and why, with artefacts linked for reference and review. Folded into machinery 62 (unsynced, no bump). Skips: Phases 2–6 (one-line reword, nothing new).
**Ref:** `8fe6953`

---

## 2026-09-18 - Retirement transport gaps (T1-E2.07, machinery 62 -> 63)

**Why:** Adds travelled but retirements stranded: registry delete pass, skill prune mask + declaration, structural task stamp, version discipline + v9 — next satellite pull self-heals (GRID-Link 54→59 findings). Skips: Phases 2–3 (no `src/`, no `.wiki/` delta); one process lesson routed (mid-session trunk collision).
**Ref:** `2dceac1` (plan) + `572649a` (wrap-up, machinery 63)

---

## 2026-09-18 - Link artefacts in PO updates (machinery 61 -> 62)

**Why:** PO can review, so updates must give what changed, where it lives, and when it's needed. One bullet added to `communication-rules.md` § User-facing conversation; no prefix/template text changed. Skips: Phases 2–6 (one-bullet docs tweak, preference already codified).
**Ref:** `c876530`

---

## 2026-09-18 - User-facing conversation is dev-to-PO (machinery 60 -> 61)

**Why:** User found agent chat overly technical (senior-to-senior). New canonical rule in `communication-rules.md` § User-facing conversation — practical outcomes first, no unexplained jargon; pointed at from `AGENTS.md:11`, live `base-context.md:10` (prefix re-synced to 9 agents), and both seed templates so new satellites inherit it. Existing satellites keep local `base-context.md`/`AGENTS.md` (only registry rows force-push), so they need the one-liner added manually. Skips: Phases 2–4 (docs/process-only, no plan); Phase 5–6 (nothing new — preference codified as the rule itself).
**Ref:** `b409757`

---

## 2026-09-18 - Reviewer write-unblock (machinery 59 -> 60)

**Why:** `ptp-grumpy-architect` + `ptp-smooth-operator` carried `edit: deny` but their output contract writes `reviews/arch_review.md` / `product_review.md`, so MULTI reviews could not complete. Flipped `edit` to `allow` in `opencode.json` + frontmatter `tools: [read, edit, search]`; kept `bash/task/webfetch` denied (spec audit is read-only; `git show` stays orchestrator-supplied). Pre-existing backlog dirt (2 modified + 2 untracked backlog files) untouched by this session.
**Ref:** working tree (uncommitted; baseline `e80950e`)

---

## 2026-09-17 - Template hygiene cull (machinery 58 -> 59)

**Why:** A cleanliness review of the template (direct user direction) found five surfaces that had stopped paying for themselves, and two live docs that had drifted from truth. **Deleted:** `.devops/skills/wiki-bootstrap/references/qa-14-testing-standards.md` - an orphan (the skill's own Question Set table routes slot 14 to the testing subtree, and no surface referenced the file; the skill's `references:` frontmatter claim drops 19 -> 18 question sets); `.wiki/hooks/README.md` - unreferenced, and it contradicted the linked `hooks-index.md` about what the folder is for; `.github/CODEOWNERS` - template-owner-specific, inherited by every fork; and the `docs/` directory itself - after T1-E4.01 its only content was a note about a retired export, so the tombstone stopped paying for itself (Managed Simplicity). **Corrected:** `.devops/rules/process-lessons.md` dropped the two entries a prior maturity pass had proved superseded or wrong (the wiki-lint severity contract, and the "sync clobbers model bindings" premise) - register 22 -> 20; `.wiki/core/18-knowledge-capture.md` records the `docs/` removal beside the existing visualizer note and past-tenses the retired `wiki_okf.py import` action; the structure manifest anchor 14 (`docs/`) is pruned with the canonical-authority rows renumbered 15-22 -> 14-21; `README.md`, `.gitattributes`, `.wiki/core/17-docs-blueprint.md`, `.devops/rules/surface-budget.md` and the `check-utf8-agents.ps1` scan list lose their `docs/` reference. `.devops/archive/` is deliberately **kept** - its traceability is load-bearing for 27 live links.

**Ref:** Direct user direction ("check the cleanliness of this template repo... remove"), delivered as a direct cull. Gates: `wiki_lint` exit 0; `wiki_claims` 0 stale; prefix OK (byte-identical); `ALL CLEAN (181 files)`; `rule_fanout` exit 0 (agreement 4/4 AGREE); coverage no-op OK; frontmatter-YAML + JSON parse OK; `-SelfTest` OK (5 dirs, 34 skills, 18 files); fixture suites 29 + 10 + 5 + 18 OK; `machinery-version 58 -> 59` recorded in `version-history.md`.

---

## 2026-09-17 - Scripts scale with satellite size (machinery 57 → 58)

**Why:** The machinery is fixed-size, but the surfaces it scans are not: a satellite's `.wiki` grows into the thousands of docs, its `src/` into thousands of files, its `.devops/archive` without bound. Profiling found the cost was not I/O of the docs but the *bookkeeping* around them — `Path.resolve()` alone was 48% of `wiki_lint`'s runtime (a `GetFinalPathNameByHandle` syscall per link per check), the wiki corpus was enumerated ~6× and every doc read 4-5× per run, `.devops/archive|logs|plans` were enumerated only to be skipped per file, `check-utf8-agents.ps1` built a `FileInfo` per entry through `Get-ChildItem -Recurse` on PS 5.1, `sync-manifest.ps1` formatted each SHA256 byte through a PowerShell pipeline, and the spaghetti scanner spent four `existsSync` syscalls per source file looking for its test. Three behaviour-preserving workstreams fix each: a syscall-free `path_key` + memoised `resolve_link` and a per-run read/enumeration cache in `LintContext` (with `os.walk` pruning) for the Python wiki tooling; .NET enumeration plus single-call hashing for the PowerShell gates; a `WALKED` set for the Node scanner. `wiki_claims` now shares one read per doc and one read+hash per unique source between `digest` and `symbol_resolves`.
**Ref:** Direct user direction — "review all our scripts to ensure they can run as fast as possible in large satellites", delivered as a fast AUTO+SINGLE pass. Measured on a synthetic 2100-doc satellite, old vs new, **byte-identical findings**: `wiki_lint` **5,979 → 900 ms (6.6×)** · `check-utf8-agents` **1,206 → 615 ms (2.0×)**; template repo: `wiki_lint` **604 → 203 ms**, `spaghetti-monster-scan` **305 → 94 ms**. Gates: 29 + 10 + 5 + 18 fixture tests OK · every gate byte-identical vs baseline (`wiki_lint`, `wiki_lint --quiet`, `claims coverage`, `rule_fanout`, `sprint_eligible`, UTF-8 guard, prefix check) except the scanner's own self-measurement · PREFIX-LOCKED bytes untouched (no `-Sync` needed) · 2 claims re-stamped · `wiki_lint` + `coverage` both exit 0 at wrap-up · machinery lesson routed to `.devops/rules/process-lessons.md` · **ref: `562dbb7`**.

---

## 2026-09-17 - Operating Principles codified: goal → principal instrument → supporting instruments (machinery 56 → 57)

**Why:** Both halves of the template were mature but stated as *peers* ("Two jobs"), so nothing said **why the template exists** or what it optimises for. The user's frame: Pass the Parcel is the goal; the wiki, cache-first context, Managed Simplicity and wiki stewardship all serve it. A new root `OPERATING-PRINCIPLES.md` states the hierarchy once — goal (stateless / independently reviewed / gated / deterministic) → principal instrument (the agent-managed wiki: canonical truth + stewardship) → supporting instruments (cache-first, Managed Simplicity, deterministic guardrails) — with the test "every instrument must state how it serves the goal." `README.md` and `AGENTS.md` carry compact forms plus a link; satellites do not get the doc (their own detail lives in `.wiki/core/`). Report-only hardening: two surface-budget rows plus an optional `agreement:` section in `rule_fanout.py`; the two pre-existing `auto-clear` unauthorised sites were reworded to cite the contract (`parcel.agent.md`, `ptp-parcel-fast.subagent.md`), taking the report to **0 unauthorised**; the PREFIX-LOCKED bytes were left untouched.
**Ref:** Operating Principles codification — direct user direction, no theme/epic. Gates: prefix PASS (byte-identical) · `ALL CLEAN (184 files)` · `wiki_lint` exit 0 · claims 0 stale (2 re-stamped) · 29 + 5 + 18 fixture tests OK · `rule_fanout` exit 0 (8 rules, 0 unauthorised, agreement 4/4 AGREE)

---

## 2026-09-17 - Register-truth tidy-up: the phantom `machinery 62` erased, and the guard fixtures wired into CI (no machinery-version bump)

**Why:** A follow-up audit of `T1-E4.01` against the live tree found the change itself sound but its *bookkeeping* drifted in three ways. **(1)** Two surfaces cited the release as **`machinery 62`** — `MATURITY.md`'s dated scorecard row and `sync-manifest.yaml`'s `prune_files` comment — while the counter is unambiguously **56** (the manifest field, version-history v0.7.26 and the changelog "55 → 56" all agree, and the W8.1 commit states the bump happens once, at wrap-up). A stale prediction that survived in two places, so a single-surface fix would have left the drift half-corrected; both now read 56. **(2)** `REFACTORING.md` recorded the decomposed engine as *"Now **485** lines"* — true at W6, not at HEAD, since W8.1 added the `prune_dirs` capability (+12); the live claim is restamped **497** and the historical W6 figure annotated, never rewritten. **(3)** `validate.yml` ran **one** of the four fixture suites: `test_sprint_eligible.py` was gated while `test_check_utf8_agents.py` (10 cases) and `test_wiki_claims_coverage.py` (5) — both of which guard **gates**, not report-only tooling — were discovered locally but enforced by nothing. Both are now CI steps. `test_rule_fanout.py` stays **deliberately un-gated**: the surface budget is report-only by design, and gating its test would erode the "never a second gate over the gates" principle W1 set. `MATURITY.md`'s stale `*Last reviewed 2026-09-13*` footer is restamped to match its own frontmatter. **No machinery-version bump:** nothing in the portable `agents/rules/scripts/templates` set changed (`validate.yml` is explicitly non-portable; MATURITY/REFACTORING are backlog registers; the manifest edit is comment-only), so a bump would signal a satellite upgrade for zero satellite-facing change — the exact counter churn Axis 7 exists to watch.
**Ref:** `T1-E4.01` follow-up — gates green: 57 tests OK · `ALL CLEAN (183 files)` · `wiki_lint` exit 0 · claims 0 stale / 0 unresolved · `git grep "machinery 62"` returns zero

---

## 2026-09-17 - Machinery surface budget: Managed Simplicity lands, rule fan-out 59 → 2, both god-scripts split, the encoding gate 32× faster, four skills and two scripts retired (machinery 55 → 56)

**Why:** The template verified that its machinery surfaces *agree*; nothing verified there were *too many*, and with no application code only internal consistency pushed back. Measured, not asserted: one canon rule was independently authored in 4-5 surfaces, so a single change cost ~5 synchronised edits. The parcel added the missing counterweight — **Managed Simplicity** as the first principle plus a report-only **surface-budget report** — then applied it: rule fan-out **59 → 2** unauthorised restatement sites, `sync-architecture.ps1` **995 → 485** and `wiki_lint.py` **485 → 60** with line-for-line golden parity, the encoding gate **18.41 s → 0.57 s** with its EOF blind spot fixed, and four skills + two scripts + a generated artefact retired behind a new **`prune_dirs`** that actually deletes a retired folder from an already-synced satellite (7 `PRUNE` → deleted → `IN SYNC`, proven against a live pre-retirement target).
**Why (recorded, not hidden):** exactly **two** CI assertions were lost with their subjects — the OKF export/import round trip and the visualizer freshness check; the frontmatter-YAML invariant was **kept**, re-pointed at the live `.wiki/**` corpus, and both losses are named in the dated `MATURITY.md` row. A PowerShell text round-trip corrupted six skills during a version bump and the W7-rewritten encoding guard caught all six — the gate paid for itself inside the same session.
**Ref:** `505f281` (wrap-up; plan commits `180359c` W0 · `6bee792` W1 · `0ed41bf` W2 · `4c18e7d` W6 · `7d102a6` W7 · `dc466fc` W8.0 · `dd78dd9` W8.1 · `acdd24a` plan doc)

---

## 2026-09-16 - Sprint 9 wave 6: lane classification and one counter owner — and a headline descoped at Gate D (machinery 54 → 55)

**Why:** Two real pieces of hardening landed. The predicate's documented `ponytail:` hole is **closed** — a mid-path wildcard (`src/*/db` vs `src/a/db/schema.sql`) is now detected, which `T1-E3.09` knowingly shipped as undetected and which is a *safety* bug rather than a cosmetic one under any future concurrency. And the **Reserved Surface Set** is now both canonical (`plan-lifecycle.md`) and executable: the script emits a 9-member `reserved_surfaces` plus a live `lanes` classification, so a plan touching `sync-manifest.yaml`, `version-history.md`, `base-context.md` + its seed, `.devops/agents`, `.devops/sprints`, `SPRINTS.md`, `backlog-index.md` or `agent-changelog.md` is classified `serial` and `parallel_groups` can never pack it with anything else. Finally, `machinery-version` gains **one owner per batch** — the wrap-up — which is the fix for the collision *every wave of this sprint* hand-carried by reading a stale base, and the same collision that cost Sprint 8 its clean 44/45/46/47 ledger. Fixtures 24 → 29. **But the parcel's headline was descoped, and the way it surfaced is the most useful thing this wave produced.** `T1-E3.11`'s Phase 1 Intent contracted for worktree-isolated parallel lanes ("concurrent spawn; serialised merge", and `§ Deviations: trunk-sequential replaced by group-parallel") while its own Phase 4 acceptance criteria tested **only classification** — and Sprint 9's *Explicitly Out of Scope* forbids "permitting parallel claims" outright, with batch deviation 3 already dropping `git worktree add`. Facing that, the runner refused the three contradicted directives, built what was specified testably, and **disclosed the gap at Gate D instead of grading itself PASS** — which is the only reason it was caught before sprint close rather than after. The operator approved the parcel on its nine met criteria, recorded Sprint 9's concurrency clause as **unmet**, and had the sprint Goal amended to match delivery rather than silently reworded; genuine two-lane *execution* needs a **fifth** batch deviation and stays unbuilt. The generalisable defect is that a plan's **title and its acceptance criteria described different parcels**, and nothing in the pipeline tests for that — the MULTI-worthy flag built one wave earlier fired on `blast-radius` and caught the *risk*, not the *contradiction*. Also recorded: this run obeyed the OLD per-plan counter model by necessity (the wrap-up that now owns the increment is created by this very change), and `touches` grew 12 → 15 — the sixth consecutive wave to under-declare. `machinery-version: 55`. Wave 6 of six — the sprint queue is now fully drained.
**Ref:** `28c1330` (plan: T1-E3.11)

---

## 2026-09-16 - Sprint 9 wave 5: the batch can now flag a plan it shouldn't run unattended — and Sprint 9 answers its own flag (machinery 53 → 54)

**Why:** The batch presets force `AUTO` + `SINGLE` on every queued plan regardless of complexity, so a `MULTI`-worthy plan could run with no independent reviewer and no adversarial pass — and the only record of that trade was a human's memory of the risk note in `sprint.md`. `scripts/sprint_eligible.py` now emits a **`complexity`** block per queued plan (`triage`, the mechanical `signals` that fired, `multi_worthy`, and `blocks` — the dependents a deferral would strand) plus `counts.multi_worthy`, so the fork is presented **before** the run rather than discovered in it. The signal is **computed from canonical signals, never declared**: `blast-radius` fires from the declared `touches` alone. A deferred plan becomes a **`DEFERRED-MANUAL` hole** — the loop **stops at its slot** (a halt for the human, never a skip, never a queue reorder) and the report names the dependents it strands; `plan-lifecycle.md` § Deviations stays at **four** because a yield is a halt, not a relaxation. The fixture suite grew 18 → **24 tests** (two pinning both union directions of `blocks`, one proving `MAYBE` triage still exits 0 with the mechanical backstop firing, one proving the fail-closed path). **The interesting result is that this sprint indicts itself.** Asked whether the flag would have caught `T1-E3.09`/`T1-E3.11`, the runner answered plainly instead of flatteringly: it fires on **6 of 6**, not just the two `L` plans — every Sprint 9 wave edits the pipeline that executes it, so the over-reach is *uniform*, and a flag discriminating among these six would be discriminating on taste rather than on the canonical signals. That is recorded as the **scope of the finding, not a false positive**. No new knowledge-capture entry was warranted: the governing lesson already lives in `.devops/rules/process-lessons.md` as `[2026-09-13] The @sprint-run batch preset silently overrules a sprint's recorded plan settings`, and this parcel converts that warning into a mechanical flag — the stronger form. `machinery-version: 54`. Wave 5 of six; wave 6 is the flag's first live customer.
**Ref:** `4aa2968` (plan: T1-E3.10)

---

## 2026-09-16 - Sprint 9 wave 4: the eligibility predicate becomes executable, and the host stops reasoning from prose (machinery 52 → 53)

**Why:** The batch eligibility predicate — dependency satisfaction, `touches` overlap, fixpoint order — was load-bearing **prose** duplicated across four documents, with no executable test. That is the exact class of gap that cost Sprint 8 its single-verdict batch (`G2`): the rule was stated well and *still* drifted, because nothing could fail. It is now a script. `scripts/sprint_eligible.py` emits one JSON verdict (`sprint`, `queue`, `eligible`, `claim_order`, `parallel_groups`, `skipped[].reasons`, `in_flight`, `orphans`, `already_phased`, `counts`) and exits `1` with **empty stdout** and a bare `sprint_eligible: <cause>` on stderr for every refusal — so the host **halts** instead of falling back to prose, which the authority clause forbids. `skipped[].reasons` is a **list** precisely so the dependency verdict and the write-set verdict stay separately reportable, which is the clause separation `T1-E3.03` depends on. `scripts/tests/test_sprint_eligible.py` pins all of it with **18 green fixtures** — dependency chain, mutual cycle, overlap skip, satisfied-via-`GATE_D_USER_APPROVAL`, in-flight dependency, already-`PHASE_9`, template exclusion, archive fallback, normalization, the documented **mid-path-wildcard miss** (asserted, not glossed), parallel-group layering, determinism, the schema, and five halt paths — and `.github/workflows/validate.yml` runs the **fixtures only**, since the live zero-arg run exits 1 whenever no sprint is ACTIVE and must never gate CI. Authority is cited across six surfaces (`plan-lifecycle.md`, `sprint-run` v5→6, `pass-the-parcel` v19→20, `ptp-parcel-fast` v3→4, `parcel-sprint.agent.md`, `HOW-TO.md`), and a companion grep confirmed all three fallback-phrase hits are **prohibitions** — none admits a prose fallback. Two things worth recording: the **fixtures caught a real bug before the verdict** (the first `satisfied()` closure captured a pre-fixpoint `done` set, so a dependent was never claimed after its dependency was picked), and the plan's own live run became the proof of the clause separation it implements — `T1-E3.10` now reports **only** the `touches` overlap while `T1-E3.11` keeps both the unmet dependency and the overlap. The wrap-up also closed two long-standing wiki drifts this wave surfaced: `.wiki/core/18-knowledge-capture.md` § Parcel Pipeline said the batch "relaxes **three** rules" (now **four**) and stated `depends_on` as "not archived" (now the archive-**or**-`GATE_D_USER_APPROVAL` disjunction). `machinery-version: 53`. Wave 4 of six in Sprint 9 — the sprint's hard checkpoint, and the last wave whose eligibility the host may compute from prose.
**Ref:** `7c42926` (plan: T1-E3.09)

---

## 2026-09-16 - Sprint 9 wave 3: Phase 3 questions batch — and wave 2's retirement is actually finished (machinery 50 → 52)

**Why:** Phase 3 relayed clarification questions strictly one at a time — a stated "non-negotiable" — so a plan's whole decision surface cost the operator N separate round-trips. It is now a **mode**: where the ask tool accepts a question **array** (`question`) the surface is relayed as one batched questionnaire; where it accepts a single question (`vscode_askQuestions`) it stays one call per question. The tool's own **signature** is the capability test, so there is no probe and no hard-coded surface list, and the design degrades to today's sequential UX by construction rather than failing. The final `"Is this all the context required?"` confirm is always asked **on its own** — never a questionnaire row — the 5-8 budget is unchanged, and the `AUTO`/batch path still asks nothing at all (`ptp-parcel-fast` never calls an ask tool; `ptp-phase3-answerer` resolves from the Research Map). The rule lived in **seven** live places, so the sweep covered all of them: `ptp-context-hunter` v5→v6 **deletes** its two duplicate statements in favour of one authoritative bullet, `pass-the-parcel` v17→v18, `ptp-phase3-answerer` v2→v3, plus `template-plan.md`, the ORCHESTRATOR-ONLY delegation-map row and its seed mirror, `parcel.agent.md` steps 7-8, and `ptp-context-hunter.subagent.md`'s relay hard rule. This wave also **finished wave 2's job**: `T1-E3.07` replaced the negative `AUTO` auto-clear test with a positive-evidence contract but grepped only two surfaces for the old wording, so three live copies survived its "mirror gone" claim — `pass-the-parcel/SKILL.md` § Review Gates, `plan-lifecycle.md` § Modes/Agents, and `parcel.agent.md` rule 14, the last still quoting the retired test **verbatim** in the main orchestrator's own gate rulebook. Wave 3's runner found them, correctly left them alone as outside its declared write set, and the wrap-up closed them (all three now cite § AUTO Gate Evidence Contract); `pass-the-parcel` v18→v19. The generalisable lesson is now in `.devops/rules/process-lessons.md`: verify a rule's retirement by grepping its **distinctive phrase** across the whole machinery surface and counting live copies before claiming retirement, and have Gate D evidence name the surfaces swept — not just the match count. Retiring a rule and proving it retired are separate jobs. `machinery-version: 52`. Wave 3 of six in Sprint 9.
**Ref:** `3eaedac` (plan: T1-E3.08)

---

## 2026-09-16 - Sprint 9 wave 2: AUTO gates clear on positive evidence, not by omission (machinery 48 → 49)

**Why:** An `AUTO` gate cleared whenever no `**REJECTED:**` line was found — a **negative** test, so an empty or vague self-review passed by default and the gate's real question ("was this actually verified?") was never asked. This parcel replaces the absence test with a **positive-evidence contract**: each auto-cleared gate must carry named, checkable evidence, and an unproven gate is now a **stop-the-line** rather than a silent pass. The contract is stated **once**, canonically, in `.devops/rules/plan-lifecycle.md` § *AUTO Gate Evidence Contract*, and **cited** from four sites — `pass-the-parcel`, `ptp-parcel-fast`, `sprint-run` (v4→v5) and the shared prefix — rather than restated, following the precedent wave 1 set (canonical in `plan-lifecycle.md`, cited by skills) and superseding this plan's own Q3 proposal to home it in `pass-the-parcel` § Review Gates. The old per-skill mirror is gone (0 matches), the prefix + its seed now point at the contract instead of paraphrasing it and were re-inlined byte-for-byte across 11 binding surfaces (`-Sync`: 9 `FIXED` + 1 `EMBED`; verify `PASS ×9`), and `template-plan.md` gains the Phase 6 / Phase 9 evidence shapes a plan must actually carry. `ptp-parcel-fast` v2→3, `pass-the-parcel` v16→17. Three design flaws were found and **fixed by the runner before the verdict rather than papered over**: P1's unchecked-box arm would have failed *every* plan at Gate B (a plan's own `### To-Do List` is `[ ]` by design — scoped with a named exemption), P2 missed a rejection recorded as a `**Verdict:**` value, and a naive substring test matched the contract's own quotation of the tokens it forbids. That self-fix is recorded precisely because a self-review which both found these and graded itself PASS is a `SINGLE`-topology limitation, not a strength — independent review stays `T1-E3.10`'s remit. Two pre-existing drifts observed and deliberately left: `HOW-TO.md` still says "Three deviations" where `plan-lifecycle.md` lists four, and `backlog-index.md:24` links a `TRIAGE.md` that has never existed. `machinery-version: 49`. Wave 2 of six in Sprint 9; the batch again drained at one plan, since every remaining queue plan declares the same `sync-manifest.yaml` + `version-history.md` pair this one parks.
**Ref:** `ae4e346` (plan: T1-E3.07)

---

## 2026-09-16 - Sprint 9 wave 1: `T1-E3.06` closes the Sprint 8 coverage gaps (machinery 47 → 48)

**Why:** Sprint 8's own execution exposed three gaps none of its planning found: `.devops/sprints/**` sat outside the UTF-8 gate (queue plans were the only plan-state artefact with no encoding coverage), `@sprint-plan` committed a mutually-overlapping queue without ever testing `touches` overlap (so the batch could only ever run it one wave at a time — Sprint 8's `G2`), and the spaghetti scanner crashed on a repo with no `src/` while never scanning the machinery roots. All three now close. **G1:** the encoding gate covers queue plans — live scan 222 → 228. **G2:** one canonical *Write-Set Overlap Predicate* lives in `plan-lifecycle.md` § Claim Protocol, with `sprint-run` § 2 and `sprint-plan` § 4b **citing** it rather than restating it, so no second dialect can drift; `@sprint-plan` gains a mandatory commit-time N-wave preflight that states the accepted cost as *N verdicts + N wrap-ups*; the matured `[2026-09-13] touches-overlap` lesson is folded into its owning surfaces and deleted. **G3:** the scanner no-ops on a missing root instead of throwing, now scans `scripts/`, `.devops/skills/`, `.devops/agents/` and `.devops/templates/`, and the refactoring register is **adopted** as `.devops/backlog/REFACTORING.md`. G3 was a decision, not just a fix — resolved as *adopt the register + state the opt-in fallback in the planning/closing skills*; reverting to opt-in-only is a one-file revert. Skill versions `sprint-plan` v4→v5, `sprint-run` v3→v4, `sprint-close` v5→v6. Wave 1 of six in Sprint 9 — and the batch then drained at that one plan, because all six queue plans share `sync-manifest.yaml` + `version-history.md` and the batch path never archives, which is precisely the defect G2's new preflight now reports at planning time instead of mid-run. Two residual risks carried forward and disclosed rather than hidden: the scanner self-flags at rank 1 because its CCN heuristic counts `?`/`|`/`&&` inside regex literals, and its ranking maths has no unit test (fixtures prove the guard and multi-root union only).
**Ref:** `b1696e3` (plan: T1-E3.06)

---

## 2026-09-16 - Batch sprint wrap-up: `@agent-wrap-up` gains a batch scope (machinery 47)

**Why:** A batch sprint ended at `PHASE_9` with `GATE_D_USER_APPROVAL` and had no way to *finish* — retiring N plans meant running the heavy per-plan `@agent-wrap-up` N times inline. Rather than create a second wrap-up source of truth, the fix is a **batch scope** on the existing skill: `@agent-wrap-up` now accepts an **input list** of plan codes, runs every phase **once for the batch** (one diff, one changelog entry naming the theme, one wiki reconciliation, one backlog sweep, one gate pass) and iterates **only Phase 4**, once per plan. The safety that makes coalescing legitimate is a **confirmation gate**: five individually-checkable per-plan assertions — bottom `Status: PHASE_9`, `claim_status: GATE_D_USER_APPROVAL`, a `DONE <code>` runner outcome, Phase 9 evidence **plus** a populated acceptance-criteria table, and the exact `plan: <code>` commit on the trunk — and a plan failing **any** one is **carry-forward**, left in place and never marked complete. Repo gates run once per batch; a red gate blocks the **whole** batch and a red tree is never auto-cleaned. Retirement is now named as `@sprint-run`'s **fourth** deviation (`plan-lifecycle.md` § Deviations item 2, renumbered) — a separate, **operator-invoked** step, never an inline continuation of the batch loop, which is what lets a set fail closed together instead of archiving plan-by-plan as verdicts arrive. `parcel-sprint`'s `task` allow-list gains exactly one named target, `wiki-writer` (no glob), so the host can delegate the read-heavy wiki prose while the structural narrowing still holds; the shared prefix's own claim — "narrowed to exactly `ptp-parcel-fast`" — was falsified by that widening and moved with it (edited in `base-context.md` + seed, re-inlined by `-Sync`), since the prefix is read by every agent as its rulebook. `D6` needed no work: T1-E3.03 had already taught `sprint-close` to treat a surviving `GATE_D_USER_APPROVAL` plan as unfinished. `machinery-version: 47`. Wave 3 of Sprint 8 — and the first live exercise of the scope it defines, used to retire itself.

**Ref:** `cbc9398` (plan: T1-E3.04); wrap-up `c290082`

---

## 2026-09-16 - Executed-to-Gate-D becomes a first-class claim status: `GATE_D_USER_APPROVAL` (machinery 46)

**Why:** The batch runner's eligibility clause required every `depends_on` code to be present in `.devops/archive/`, but the batch path *forbids* archiving (each plan stops at `PHASE_9`) — so the only state a batch could ever produce for a dependency was the exact state the predicate refused, and a sprint with an intra-queue chain executed only its roots. A per-sprint human ruling papered over it; this bakes the ruling into the state machine. `claim_status` becomes `QUEUED | CLAIMED | GATE_D_USER_APPROVAL | COMPLETE` (the dead `IN_PROGRESS`, which nothing ever set, is retired), and `depends_on` is **satisfied** by archive **or** by a plan sitting in `.devops/plans/` with `GATE_D_USER_APPROVAL` — any other state is unmet. The disjunction is what makes the two wrap-up paths compose: a manually wrapped plan matches the archive clause, a batched one matches the status clause, and a plan that later fails Gate D reverts to `CLAIMED` so dependents re-block correctly. `@sprint-run` v1→v2 gains a **fixpoint loop** (bounded, deterministic, cycle-safe, progress-correct) plus a dependency-cycle preflight and a resolution forecast; `ptp-parcel-fast` v1→v2 sets the state at chain step 8; `sprint-status` v2→3 and `sprint-close` v4→5 learn to read it so an executed plan is not reported in-flight or closed over. The plan both **introduced** the state and terminated in it, and the live queue then demonstrated the clause separation the design depends on: `T1-E3.04`'s dependency flipped from unmet to satisfied under the new rule while its 8-entry `touches` overlap still returned SKIP — a satisfied dependency no longer masks a write-set conflict. Mirrored across `plan-lifecycle.md` (canonical predicate, enum, Claim Protocol, Deviations), the `base-context.md` shared prefix + seed (re-inlined ×9, prefix PASS), `pass-the-parcel` v14→15, `sprint-plan` v3→4, `parcel-sprint.agent.md` unique content, `template-plan.md`, `SPRINTS.template.md` v3→4 and `HOW-TO.md`. `machinery-version: 46`. Wave 2 of Sprint 8.

**Ref:** `61bd5de` (plan: T1-E3.03); wrap-up `8b21238`

---

## 2026-09-15 - Parcel Fast becomes subagent-only: the selectable orchestrator is retired (machinery 44 → 45)

**Why:** "Parcel Fast" existed twice — a selectable orchestrator (`.devops/agents/parcel-fast.agent.md`) and the hidden batch subagent (`.devops/agents/ptp-parcel-fast.subagent.md`) — one prefix apart, a documented confusion hazard, and only one of the two was ever needed. Operator ruling (2026-09-15): **Parcel Fast is a subagent of `parcel-sprint` only**; the main `parcel` agent is the tool used to deliver a plan from any investigated context. The retirement deletes the agent file and every surface derived from it **together** — the Model Registry row, the Orchestrator Presets row, and the `opencode.json` + seed `agent.parcel-fast` entries — because `check-parcel-prefix.ps1` validates registry↔file↔config **bidirectionally**, so any partial removal is a hard FAIL rather than a silent half-state. The prefix header, the `ORCHESTRATOR-ONLY:START` marker comment and the presets prose now name only the survivors (`parcel` = `ask`; `parcel-sprint` = locked batch host), and `-Sync` re-inlined the prefix byte-for-byte into the **9** remaining locked agents (2 orchestrators + 7 `ptp-*`; 10 → 9; PASS ×9, 11 model bindings, exit 0). `prune_files` gains `.devops/agents/parcel-fast.agent.md` — load-bearing, not cosmetic: `.devops/agents` is portable, so a satellite that already synced would keep an orphan file whose registry row is gone and fail its own prefix check. `machinery-version: 43 -> 44`. Mirrored across `AGENTS.md` + `AGENTS.template.md` v12→v13, `.devops/README.md`, `agents-and-skills.md`, `HOW-TO.md`, `.wiki/rules/naming.md`, `model-routing`, `pass-the-parcel` v13→v14, `template-plan.md`, `base-context.template.md` v12→v13, `opencode.template.json` v7→v8. Substring hazard handled by construction: `parcel-fast` is a substring of `ptp-parcel-fast`, so every edit was phrase-exact and the surviving subagent's byte-equality is asserted by the prefix check.

**Ref:** `e9a8051` (plan: T1-E3.05); wrap-up `6d4f66a`

---

## 2026-09-14 - Knowledge Capture second destination: the machinery register (machinery 43)

**Why:** `.wiki/core/18-knowledge-capture.md` (KC) was the one and only home for tribal knowledge, but the wiki documents the *app* — so a machinery/process/tooling lesson had nowhere to graduate to and KC grew one-way, piling up every sprint's process news forever. Added `.devops/rules/process-lessons.md`, a **staging register** (entry format `- **[YYYY-MM-DD] Title** — rule. *Do instead:* fix.`, ≤3 lines) that folds a matured rule into its owning skill or `plan-lifecycle.md` and is reviewed at sprint close — a staging register, not an archive. Capture and consolidation now route **by subject**: `knowledge-capture` v6→v7 gains §3 Destination Routing plus a **one-entry-per-session budget**; `knowledge-consolidation` v7→v8 gains Phase 6b (`promote-machinery`). The size trigger moves from **physical lines to entry count** (tidy ceiling 25 entries; a full audit fires above 25 and fails above 40) because entries are hard-wrapped, so a reformat could double the line count without adding a single rule — the old trigger fired on formatting, not growth. That same shift had orphaned the `#hard 500-line ceiling` claim anchor, leaving the KC doc asserting a contract its own skill no longer stated: the doc's scope note and Knowledge System rule are reconciled and every affected claim hash restamped. `agent-wrap-up` v10→v11 routes in Phase 6 and hands the register to its Process Agent; `sprint-close` v3→v4 performs the register review, so the promise the register makes in its own header is not dead. Registers: `T1-E2.05`, `T2-E2.03`; `MATURITY.md` reassessed to machinery 43 (grades unchanged). `.devops/rules/` is a `portable_dir`, so the register rides to satellites beside the skills it belongs to.

**Ref:** `bccb428`

---

## 2026-09-14 - Chunked Write Discipline (machinery 42)

**Why:** Satellites stalled on OpenCode's `write` tool — a large payload blocks the TUI on "Preparing write…", because the tool takes the whole file as one JSON `content` string and runs a synchronous diff over it *before* the permission prompt. Because `write` **overwrites** and cannot append, an interrupted write cannot be recovered by re-sending the payload: it is the re-send that stalls. Rule: **skeleton-then-fill** — one small skeleton `write` (frontmatter + section headings, each with a unique placeholder such as `<!-- FILL:goal -->`), then one small `edit` per section replacing its placeholder, ~60–100 lines per call, resuming from a `read` of what landed after a stall. Landed as rule 9 in the `base-context.md` shared prefix (re-inlined by `-Sync`; prefix PASS across all 10 locked agents, 12 bindings, seeds agree), rule 10 in `AGENTS.md`, a `<!-- MACHINERY -->` rule 10 in seed `AGENTS.template.md` v11→v12 (subsequent rules renumbered: 11 sprint, 12 customize) and rule 4 in seed `base-context.template.md` v11→v12, plus a mandatory chunked-write step in `sprint-plan` v2→v3 §5 — the immediate offender, a large `sprint.md`. Two `AGENTS.md`-sourced claim hashes restamped. **Scope note recorded:** the skill and seeds transport automatically, but a satellite's `base-context.md` is repo-specific, so an already-bootstrapped satellite must add the rule to its own prefix (or re-seed) to carry it into its agents.

**Ref:** `d56cf8d`

---

## 2026-09-13 - Sync transport completeness: F8/F9 closed (machinery 41)

**Why:** The pre-satellite-sync audit that produced T1-E2.03 stopped at F7; two transport gaps survived. **F8** — `Update-TargetModelBindings` only stamped keys the target already had, so a newly shipped agent landed as a *file* the opencode runtime never mounted (`opencode.json` is the mount surface), reported `BINDING-SKIP`, and failed the satellite's own `check-parcel-prefix.ps1` and the whole pull (exit 1) — reproduced on a throwaway target. It was a **recorded `ponytail:` ceiling with a named upgrade path** (`t1-e1.03:276`), not an oversight, so the fix retired it exactly that way: insert the missing entry whole from the target's own synced seed (new `Find-MatchingBrace`/`Get-SeedAgentEntry`/`Add-TargetAgentEntry`; EOL-preserving, idempotent), scoped to keys the satellite has **never authored** so the existing `permission` blocks that the ceiling cited as its reason to hesitate are never restructured. **F9** — `.devops/plans/template-plan.md` was named by the shared prefix and five shipped skills but absent from `portable_files`, so a fresh satellite got "instantiate from the canonical template" with no template. Both were invisible to CI: `-SelfTest` ran on a bare target (no `opencode.json`, no `base-context.md`) and asserted only manifest-fenced items — the new fixture plants a satellite-shaped target *before* the first sync, and its F9 assertion reads the **reference** out of the prefix instead of the manifest. It failed correctly on first run, proving the guard bites. Mirrored across `sync-architecture` v6→v7, `model-routing` v7→v8, `agents-and-skills.md`, `SATELLITE-BOOTSTRAP.md` v11→v12, `.devops/README.md`, and the KC rules.

**Ref:** `6a90266`

## 2026-09-13 - test-and-deploy v4: commit `-F` guidance ported from GRID-Link

**Why:** A satellite (GRID-Link) had added a local delta to this portable skill — step 4 now mandates `git commit -F <message-file>` over `git commit -m "<message>"`. The host shell re-parses embedded double quotes in `-m` as argument boundaries and shreds a multi-line body into pathspecs (`error: pathspec 'depth' did not match any file(s) known to git`), and an inline here-string is precisely the text that gets re-parsed, so a dropped non-ASCII character can collapse a pattern to empty and then match every line. Because the skill is portable and `excluded_skills: []`, a plain satellite sync would silently overwrite the delta; ported it here (v3→v4) so it is shared machinery rather than permanent DRIFT. No body changes beyond step 4.

**Ref:** `0ee80ff`

## 2026-09-13 - Pre-satellite-sync audit tidy-up (machinery 40)

**Why:** A pre-satellite-sync architecture audit ran every deterministic gate (all green: prefix PASS ×10 + 12 model bindings, UTF-8 ALL CLEAN 202 files, `-SelfTest` OK, wiki lint/claims/coverage/visualizer exit 0) and then hunted for what the gates do *not* cover. Six issues plus one contradiction surfaced. **F1** — `Update-TargetModelBindings` only rewrote registry rows whose key the target already had, so v39's new `wiki-writer`/`wiki-verifier` rows never reached a pre-v39 satellite; reproduced on a throwaway target (`TARGET_CHECK_EXIT=1`, `no Model Registry row for 'wiki-writer'`), and sync would exit 1 with no automated repair. Fixed by inserting missing rows after the last existing row (`Get-RegistryBindings` now carries the capability-class cell), documented in `SATELLITE-BOOTSTRAP` + `model-routing` + the `sync-architecture` skill. **F2** — `parcel-compactor.md` (retired 2026-08-22) was absent from `prune_files`; added. **F3** — `check-utf8-agents.ps1` never scanned `.devops/rules` or `.devops/templates`; both added. **F4** — T1 register lacked the completed `T1-E1.03` row; backfilled. **F5** — MATURITY reassessed for machinery 38–40. **F6** — root CHANGELOG "Earlier releases" backfilled. **F7** — the Gate-A-in-`AUTO` contradiction that T1-E3.02 recorded as CW2 was resolved: `AUTO` auto-clears Gates A–C, only Gate D always halts — reconciled across `base-context.md` (re-inlined ×10, prefix PASS), the seed, `pass-the-parcel` v13, `plan-lifecycle.md`, `HOW-TO.md`, and the two orchestrator agent bodies. machinery-version 39→40.

**Ref:** `25f5fb9`.

---

## 2026-09-13 - Registry-canonical model bindings + force propagation (machinery 39)

**Why:** Model routing was validated only across the live trio (registry ↔ frontmatter ↔ `opencode.json`) while nothing checked the **seed** surfaces, and nothing carried a template binding to a satellite — a satellite that legitimately rebound got template frontmatter and failed by construction, invisibly (`-Check` strips frontmatter before hashing). Two user calls shaped the fix: satellites are **clones**, so propagation is **force** (no preservation branch, and `-Check` reporting stays silent), and the registry is the **single source** with frontmatter + `opencode.json` derived. The VS Code-only opt-out is **retired** — a missing/empty `agent` block is now a FAIL; seeds ship concrete bindings; the binding pass is **decoupled** from the prefix pass so `wiki-writer`/`wiki-verifier` gain registry rows (10 → 12) without entering a pass whose prefix they do not carry. This **reverses T1-E1.01** ("binding is satellite configuration") — recorded in the KC entry, not drifted. Mirrored across `model-routing` v5→v6, `pass-the-parcel` v11→v12, `base-context.template.md` v9→v10, `opencode.template.json` v6→v7, `SATELLITE-BOOTSTRAP.md` v9→v10, `AGENTS.md` + `AGENTS.template.md` rule 9, `agents-and-skills.md`, `HOW-TO.md`, `README.md`, the T1 register (T1-E1.01 annotated as superseded; new parked `T1-E2.02` to split the now-4-concern `check-parcel-prefix.ps1`). Verification V1-V11 all exit 0, including a throwaway-satellite bootstrap and a force-stamp revert test; wrap-up re-stamped three `AGENTS.md`-anchored claim hashes (09/12) that the rule-9 edit invalidated. machinery-version 39.
**Ref:** `e7a35da`.

---

## 2026-09-13 - Sprint batch runner (machinery 38)

**Why:** Sprints could be planned and triaged but not *run* unattended — every parcel still needed a human to open a session per phase group. Added the batch path: a selectable host `parcel-sprint` + the `@sprint-run` skill walk the committed queue, claim each eligible plan on the trunk, and spawn one hidden `ptp-parcel-fast` per plan (locked `AUTO`+`SINGLE`, fresh context each), terminating at `PHASE_9` with Gate D `OPEN`; one consolidated report and one human verdict cover the whole batch. Three deviations are named and bounded — **batched Gate D** (deferred, never skipped), **trunk-sequential** claim (keeps `git mv` + `claim: <code>`, drops `git worktree add`, because one host runs serially), and the **Strict Context Isolation** exception (one plan's Phases 1→9 in a single fresh context). Mirrored into the `base-context.md` shared prefix (→ `-Sync` → every locked agent), `plan-lifecycle.md` § Deviations, `agent-wrap-up`, `pass-the-parcel` v10→v11, `opencode.json` (`parcel` gains an exact `ptp-parcel-fast: deny` after the `ptp-*` glob; the host binds `task` to only `ptp-parcel-fast`), the seeds (`opencode.template.json` v5→v6, `base-context.template.md` v8→v9, `AGENTS.template.md` v9→v10, `SPRINTS.template.md` v2→v3), `AGENTS.md`, `.devops/README.md`, `HOW-TO.md`, `agents-and-skills.md`, `.wiki/rules/naming.md`, `SATELLITE-BOOTSTRAP.md`, and `check-parcel-prefix.ps1`. Prefix PASS A-10; UTF-8 clean; `-SelfTest` OK (5 dirs, 38 skills — both new skills derived with no manifest edit). Wrap-up fixed two stale `AGENTS.md`-anchored claim hashes that the plan's own edit left behind (CI-blocking via `validate.yml` "Claims drift check").
**Ref:** `3f78673`.

---

## 2026-09-13 - Parcel-Fast locked preset (machinery 37)

**Why:** The `AUTO` + `SINGLE` combination is the cheap path, but it was reachable only by answering two selection questions at plan start — the orchestrator had to be *told* to run that way, and nothing stopped a `SINGLE` run from spawning a sub-agent. Added a second selectable orchestrator, `parcel-fast`, that carries the combination as a **locked preset**: `Mode=AUTO`, `Agents=SINGLE` (new `## Orchestrator Presets` table in the `ORCHESTRATOR-ONLY` block of `base-context.md`; `parcel`'s row stays `ask`). `parcel-fast` ships a lean agent body (`.devops/agents/parcel-fast.agent.md`, prefix injected by `-Sync`) and `opencode.json` binds it `task: deny`, so `SINGLE` is enforced **structurally** — the model cannot spawn a subagent. Gate A and Gate D still halt; `AUTO` only auto-clears Gates A-C. `check-parcel-prefix.ps1` now locks `parcel*.agent.md` (full prefix for both orchestrators), and `sync-architecture.ps1` hashes their unique content so a satellite-customized prefix never false-reports DRIFT. Docs/seeds mirrored (`parcel.agent.md` steps 2-3, `template-plan.md`, `AGENTS.md`, `.devops/README.md`, `agents-and-skills.md`, `.wiki/rules/naming.md`, `HOW-TO.md`, `pass-the-parcel` v9→v10, `model-routing` v4→v5, `base-context.template.md` v7→v8, `AGENTS.template.md` v8→v9, `opencode.template.json` v4→v5, `SATELLITE-BOOTSTRAP.md`). Prefix PASS ×8 (was ×7); UTF-8 clean. machinery-version 36→37.
**Ref:** working tree (uncommitted; baseline `bfaa9a3`).

---

## 2026-09-13 - Concurrency + sprint lifecycle rewrite (machinery 36)

**Why:** The sprint model assumed one serial executor and a separate `plan.md`/`retro.md` per cycle. Reworked to concurrent, claimed execution with local-only git: a plan is committed into `.devops/sprints/sprint-{n}-<slug>/` (single `sprint.md`, no `retro.md`), claimed via claim front-matter (`code`/`sprint`/`claim_status`/`owner`/`claimed_at`/`last_touch`/`touches`/`depends_on`) + `git mv` into `.devops/plans/` + `git worktree add` on `plan/<code>-<slug>`; completed plans archive to `.devops/archive/` root, and the sprint record moves to `.devops/archive/sprints/`. Backlog detail moved into `t{n}-<slug>-backlog.md` theme registers (front-matter `type` discriminates them from parked `-backlog.md` plans); `backlog-index.md` is now Triage Panel + Themes table. Updated `plan-lifecycle` (rules 4/6 + Claim Protocol), `sprint-plan`/`sprint-status`/`sprint-close`, `pass-the-parcel`, `backlog`, `agent-wrap-up`, `spaghetti-monster`, `build-roadmap`, all seeds (`SPRINTS` + new `sprint`/`AGENTS`/`TRIAGE`/`REFACTORING`/`SATELLITE-BOOTSTRAP`/`base-context`), `base-context.md` (re-inlined ×7, prefix PASS), `parcel.agent.md`, `AGENTS.md`, `.devops/README.md`, `.devops/rules/README.md`, `template-plan.md`, and wiki docs `17-docs-blueprint`/`18-knowledge-capture`/`00-system-index` + the worked example. AGENTS.md claim hashes re-stamped. Re-adopted `.vscode/tasks.json` and dropped its stale `prune_files` entry so `sync-architecture.ps1 -SelfTest` is green. machinery-version 35→36.
**Ref:** `4364a55`.

---

## 2026-09-12 - wiki-writer runs as a subagent on demand (machinery 35)

**Why:** `wiki-writer` was configured `mode: primary`, so only a user could select it and no orchestrator could delegate wiki prose to it via the Task tool. It is now bound `mode: all` in `opencode.json`: it stays selectable, and any primary agent may invoke it as a subagent when required. `parcel`'s `task` allow-list gains `wiki-writer: allow` beside `wiki-verifier`. Mirrored in the seed `opencode.template.json` (v3→v4); agent-surface wording updated in `AGENTS.md`, `.devops/templates/AGENTS.template.md`, `.devops/README.md` and `.devops/rules/agents-and-skills.md`. machinery-version 34→35.
**Ref:** `d43aebc`.

---

## 2026-09-12 - Plan Settings promoted to a frozen header block (machinery 34)

**Why:** Plan-start settings (`Mode`/`Agents`) sat in the cache-anchored BOTTOM `State & Gates` table next to mutable gate state, so resumed sessions and narrowly-prompted subagents sometimes missed them. Split by mutability: `Mode`/`Agents` now sit in a frozen `## ⚙️ Plan Settings` block at the TOP (read before any phase); the bottom holds only mutable state. Moved (not copied) across `template-plan.md`, `base-context.md` (re-inlined ×7, prefix PASS), `parcel.agent.md` steps 2-3, `pass-the-parcel` v7→v8, `plan-lifecycle.md`, `HOW-TO.md`, seed `base-context.template.md` v5→v6, and the KC entry. machinery-version 33→34.
**Ref:** `37c84b7`.

---

## 2026-09-11 - Skill frontmatter validity + CP437 mojibake repair (machinery 33)

**Why:** Pre-commit audit found three latent defects in portable skills. (1) Six skills (`ptp-code-surgeon`, `ptp-context-hunter`, `ptp-grumpy-architect`, `ptp-high-visionary`, `ptp-smooth-operator`, `sprint-close`) had an unquoted `: ` in `description` — invalid strict YAML that opencode's loader tolerates but any real parser rejects; descriptions are now single-quoted. `caveman` was missing `version`/`updated`; added. (2) `app-vision-north-star` and `wiki-assessment` were heavily corrupted with **CP437 mojibake** — UTF-8 bytes misread through code page 437, so every `—`/`–`/emoji appeared as a multi-glyph CP437 misread; repaired by reversing each high-char run through `cp437→utf-8` (app-vision 114 runs; wiki-assessment 48 runs with 2 legitimate `—` preserved). (3) Root cause was a **guard gap**: `check-utf8-agents.ps1` detected only CP1252 mojibake (`C3 A2`, `C3 B0 C2`) and U+FFFD, so both files passed as ALL CLEAN despite the gate scanning 190 files; it now also flags the CP437 lead pairs `CE 93`+`C2`/`C3` and `E2 89 A1 C6 92`. Verified the new pattern flags the pre-repair bytes and the tree is now clean. Skill versions bumped (see v0.7.4); machinery-version 32→33.
**Ref:** working tree (uncommitted; baseline `4b06594`).

---

## 2026-09-11 - PRUNE exit-code honesty in sync -Check (machinery 32)

**Why:** `-Check` emitted a `PRUNE` verdict for a retired file lingering in a satellite but excluded it from the out-of-sync tally, so the documented contract "exit 1 = out of sync" was not driven by PRUNE. Investigation showed the literal tally fix alone was a no-op: every `prune_files` entry lives inside a portable dir, so the extra file also made its parent report `DRIFT` — misleadingly described to users as "locally customized — ask before overwriting" when the file is simply retired — and *that* already forced exit 1, masking the PRUNE nuance. Complete fix: prune files are stripped from the target side of the parent-directory hash comparison (source side untouched so a manifest bug still surfaces as a diff), and `PRUNE` is added to the `$bad` tally. `-SelfTest` gains a negative assertion — a planted prune file must report `PRUNE` + `OUT OF SYNC` with no `DRIFT`, clean again after re-sync — which fails on the pre-fix script. `sync-architecture` SKILL v4→v5; HOW-TO §6 + `.devops/README` pruning note refreshed; machinery-version 31→32.
**Ref:** working tree (uncommitted; baseline `4b06594`).

---

## 2026-09-11 - Wiki-writer pass: core-doc sweep + HOW-TO rebalance

**Why:** Wiki-writer sweep of the core docs and HOW-TO. Fixed real drift (00 dead `#9` anchor + duplicate refs; 12 wrong `AGENT.md` path + prohibited word; 17 restating canonical frontmatter/structure rules) and rebalanced HOW-TO (stale §1 bootstrap corrected to `@wiki-generate` -> `@wiki-bootstrap`, which was contradicting §5 and the v2 skills; §6 split into subsections; appended wiki-evidence paragraph promoted to §7). Added the missing `PRUNE` verdict to `sync-architecture` (v3->v4) — the engine emits it at `sync-architecture.ps1:523`, though `PRUNE` is excluded from the `-Check` out-of-sync count (flagged, not changed).
**Ref:** working tree (uncommitted; baseline `4b06594`). Tree also carries prior-session maturity-register changes (AGENTS/README/.devops/README/backlog-index/09-design-system/`MATURITY.md`) not authored this session.

---

## 2026-09-11 - OKF round-trip parity (v0.7.2)

**Why:** Post-review F4. `wiki_okf.py export` counted 56 "concepts" (any doc with a `type`) while `import` ingested 45 — the 11 `*-index.md` navigation docs were exported but skipped on ingest, so the round-trip was lossy and CI's count read like parity. Export now applies the same `is_fm_exempt_name` predicate as import, and CI asserts `exported concepts == imported`.
**Ref:** working tree (uncommitted; baseline `d4c3400`); machinery-version 30->31.

---

## 2026-09-11 - OKF interop hardening after v0.7.0 review (v0.7.1)

**Why:** Post-review F1/F2/F3/F5. `wiki_okf.py` dropped the local schema's quoting, so export emitted unquoted `title:`/`description:` scalars — a title containing `: ` (Design System, Security Standards, Worked Example) produced YAML no real parser accepts, making the OKF bridge nominally interop. Fixed with a `yaml_scalar` helper (double-quoted, backslash-escaped) applied in both directions. CI's OKF smoke was a file-count check that could not catch it — upgraded to PyYAML-parse every exported frontmatter block. Import into the live wiki now runs `wiki_lint.py` and fails if lint-dirty. Promoted `wiki_lint._fix_unindexed` -> public `fix_unindexed` (removed the private cross-module import).
**Ref:** working tree (uncommitted; baseline `d4c3400`); machinery-version 29->30; re-stamped 7 claims invalidated by the `wiki_lint.py` rename.

---

## 2026-09-11 - Wiki refresh automation: OKF ingest + secret-free CI drift issue (v0.7.0)

**Why:** Closed T2-E2.02 (G3/G5). `wiki_okf.py` gained an `import` mode (OKF v0.2 bundle → local `in-progress` drafts, index-registered, skip-on-collision); a secret-free scheduled `wiki-refresh.yml` raises/closes a `wiki-drift` issue from `wiki_claims.py check`. The docs-PR path was dropped — the portable surface stays secret-free by design. KC gained one pitfall (auto-cataloguer ignores index column semantics) + one Decision Archive entry. `machinery-version` 28→29.
**Ref:** working tree (uncommitted; baseline `d4c3400`); plan `.devops/archive/t2-e2.02-wiki-refresh-automation-plan.md`.

---

## 2026-09-11 - Residual hygiene after T2-E2.01 review (v0.6.1)

**Why:** Post-review residuals R1-R4. `scripts/wiki_claims.py check` misdirected every failure to `update`, which cannot repair an `UNRESOLVED-SYMBOL`/`MISSING`/`BROKEN` claim — now emits a per-class hint. Root `CHANGELOG.md` was one release behind (v0.6.0 absent) and the product↔machinery version tracks were unmapped. T2-E2.02 had a backlog row but no parked plan. Product `v1.0.0` was untagged.
**Ref:** working tree (uncommitted; baseline `d4c3400`); tag `v1.0.0` -> `d4c3400`; `machinery-version` 27->28.

---

## 2026-09-11 - Wiki grounding & guard hardening (v0.6.0)

**Why:** v0.4/v0.5 shipped the claims engine but it had no teeth — the rules index left `claims.md` unlisted (drift the linter could not see), only 4 claims existed so `check` passed trivially, and three guards had holes. Closed G1 (rules-index completeness hard-fail `[UNCATALOGUED]`), G2 (12 grounded claims across core slots 00/09/12/14/17/18), G4 (`UNRESOLVED-SYMBOL` `#symbol` resolution), G6 (`wiki_visualize.py --check` + CI freshness/OKF-smoke steps), G7 (UTF-8 guard now scans root `*.md`/`docs/`/`.github/`). G3/G5 deferred to T2-E2.02; `machinery-version` 26->27.
**Ref:** working tree (uncommitted at wrap-up; baseline `d4c3400`)

---

## 2026-09-11 - Template repo hygiene & onboarding (v1.0.0)

**Why:** The template's flagship asset — the 10-phase parcel pipeline — was invisible from the front door: a 40-line README titled "Application Wiki", no `LICENSE`, no community files, no release surface, no worked example. Added MIT `LICENSE` + `CONTRIBUTING`/`SECURITY`/CoC, a root `CHANGELOG.md` (human-facing releases; `version-history.md` stays the machinery log), `.github` issue/PR templates + `CODEOWNERS` + `release.yml`, a README product-page rewrite (badge, reused pipeline diagram, 5-minute quickstart), and a worked example in `.wiki/examples/`. Two gotchas recorded to KC/changelog: `pull-architecture.ps1 -Verify` exits `2` inside the template (source == target — verify from a satellite), and gitignored run workspaces must be quoted, never linked, from publishable docs. No portable surface changed (`machinery-version` stays 26).
**Ref:** `d873390`

---

## 2026-09-11 - Coverage gate: symbol/claims evidence (v0.5.0)

**Why:** `wiki_coverage_check.py` passed a file on a bare filename-substring mention — a renamed symbol inside an unchanged file was invisible to CI, so the wiki could drift while staying green. Replaced the weak anchor with a four-route evidence OR (filename, parent folder, index-cited exported symbol, `claims: source` binding); symbol discovery is a stdlib regex export scan (documented `ponytail:` ceiling), and coverage now consumes `wiki_claims.py` (single parser owner) via a lazy import after the `src/`-absent no-op guard. Additive — satellites do not regress. Closes the T2-E1.01 Q6 carry-over. `machinery-version: 26`.
**Ref:** `ce7f079`

---

## 2026-09-11 - Wiki self-maintenance: grounded claims + generate/update split (v0.4.0)

**Why:** The wiki was governance-strong but truth-weak — two frontmatter schemas across the corpus, no evidence behind factual claims, no incremental refresh from code changes, no generator, no portable format. Unified the schema (`format-version: 1`, `.wiki/rules/**` now linted), added a Grounded Claims layer (`claims:` + `scripts/wiki_claims.py` + a secret-free CI drift gate), split generation (`@wiki-generate` drafts, `@wiki-bootstrap` verifies v2) from refresh (`@wiki-update`), and added OKF v0.2 export plus a static `docs/` visualizer. `machinery-version: 25`.
**Ref:** `6992665`

---

## 2026-09-11 - CI self-test hotfix: Unix hidden `.vscode` (v0.3.17)

**Why:** The `SelfTest sync engine (transport contract)` CI step added in v0.3.13 had been red on every push since. Root cause: on Unix, dot-prefixed names are hidden and `Get-Item`/`Get-ChildItem` ignore hidden items by default (`Test-Path` does not), so `Get-ItemHashes` (`scripts/sync-architecture.ps1:278`) threw `Could not find item .../.vscode` during `-Check` and killed the child process under `$ErrorActionPreference='Stop'`. `.vscode` is the only portable-surface leaf that is dot-prefixed — `.wiki/rules`, `.devops/agents`, skill slugs and script filenames all end in visible names — which is why only it tripped, and why the Windows run stayed green (dot-names are not hidden on Windows). Fix: `-Force` on the `Get-Item`/`Get-ChildItem` calls in `Get-ItemHashes` and on the `-SelfTest` mirror + nested-copy guards. Verified locally: `-SelfTest` OK, `check-parcel-prefix` PASS ×7, `check-utf8-agents` ALL CLEAN, `wiki_lint` exit 0, coverage no-op, JSON parses, version discipline OK. machinery-version 23→24.
**Ref:** `af7ddf6`

---

## 2026-09-11 - Agent topology: SINGLE (fast plan) vs MULTI (comprehensive plan) (v0.3.16)

**Why:** Added the parcel pipeline's second, orthogonal axis — `Agents: MULTI` (comprehensive plan: `ptp-*` delegation, independent Group C reviewers, 4 gates) / `Agents: SINGLE` (fast plan: inline personas, Group C skipped, Gates B+C merged into one approval at Gate B with Gate C `N/A`) — chosen by task complexity and user-confirmed at plan start; closes the gap where "single agent mode" had leaked in ad-hoc. Gate A + Gate D stay human in both. Mirrored across skill, base-context (+ seed template), template-plan, agents, `plan-lifecycle`, and HOW-TO. No backlog items resolved; no KC entry (the axis is canonically documented in `@pass-the-parcel`), consolidation skipped — nothing new surfaced. machinery-version 22→23.
**Ref:** `1c98239`

## 2026-09-11 - Wrap-up + deploy skill streamlining (v0.3.15)

**Why:** `agent-wrap-up` (v7→v8, 161→145 lines): dropped the dead "Mandatory Tools" section and the phase-restating "Non-Negotiable Rules", merged Phases 5–6 into one Backlog Reconciliation phase (renumbering KC→6, gates→7), and split the gate phase into 7a hard-stop coverage vs 7b state stamps. `test-and-deploy` (v2→v3): added a no-`package.json` applicability guard and the missing AGENTS.md rule 9 pre-push checks (`check-parcel-prefix` + `check-utf8-agents`), folded the build step into the concurrent block. Cross-refs updated (`knowledge-consolidation`, `wiki-verifier.subagent`, `18-knowledge-capture`); `machinery-version` 21→22.
**Ref:** `af8065c`

## 2026-09-11 - T1-E2.01 review fixes (v0.3.14)

**Why:** Closed the two real defects from the T1-E2.01 implementation review: MH-15 was only half-delivered (`.wiki/rules/numbering.md` area/sub-area tables covered 6 of 8 manifest areas) and the new hub-reachability check flagged all 12 `.wiki/rules/**` docs as unreachable on the template's own clean tree (suppressed by `--quiet` in CI). Also guarded the reachability BFS read against non-UTF-8 files and converted residual sync/pull usage text to forward-slash paths.
**Ref:** `aa33291`

---

## 2026-09-11 - T1-E2.01 Machinery Integrity & Portability Hardening (v0.3.13)

**Why:** Made the template's own guarantees true. W1 linter truth & power (`wiki_lint.py`: frontmatter `related-to`/`dependencies` link checks, hub→spoke, `[UNINDEXED]`/`[MISSING]`, hub BFS reachability; `--fix` implemented; pattern-based exemptions); W2 7 broken frontmatter links repaired + `Last Verified` column; W3 transport engine Linux parity (single `Read-Manifest`, `$shellExe`, forward-slash paths) + `-SelfTest` in CI + manifest completeness; W4 seeds reconciled (`opencode.template.json` ships the 9-agent block); W5 doc truth sweep; W6 version/log discipline + failing CI version check; W7 residue removed (Gemini genericised, sprint registers parked, `theme-linguistics` refs deleted); W8 `opencode.json`↔registry validation + uniform rebind to DeepSeek V4.1 Flash. Gates: prefix PASS ×7 + `OC-MODEL`, UTF-8 ALL CLEAN (167), `wiki_lint` exit 0, coverage no-op exit 0, `-SelfTest` OK. machinery-version 19→20.
**Ref:** `0aac8bd` — plan archived to `.devops/archive/t1-e2.01-machinery-hardening-plan.md`.

---

## 2026-09-10 - Machinery Version 19 + AGENTS.md Structure (v0.3.12)

**Why:** Bumped `machinery-version` 18→19 and aligned the documentation-structure block in `AGENTS.md` + `AGENTS.template.md`. No session changelog entry was written at the time; reconstructed from commit `8c50a87` during T1-E2.01.
**Ref:** `8c50a87`

---

## 2026-09-09 - Encoding-Hardening Series (v0.3.9–v0.3.11)

**Why:** One session closed three encoding gaps: `check-utf8-agents.ps1` extended to `.wiki/**/*.md` (v0.3.9), a byte-level BOM/UTF-8 guard added to `wiki_lint.py` + `.ptp-source` written via .NET UTF-8 no-BOM (v0.3.10), and portable `.vscode/settings.json` pinned to `files.encoding: utf8` + `files.autoGuessEncoding: false` (v0.3.11); machinery-version 15→18. Reconstructed from commit `99663cd` — release rows exist in `version-history.md` but the changelog entries were never written.
**Ref:** `99663cd`

---

## 2026-09-09 - Knowledge-Changelog Decommission + Changelog History Prune (v0.3.8)

**Why:** The `knowledge-changelog.md` concept was retired — its content was template placeholders + two one-off entries, and the new philosophy (adopted this session) is that git history is the permanent record. Deleted the file, purged all live references (skills, templates, wiki, README/HOW-TO/AGENTS, `wiki_lint.py` `--changelog` flag + `LOGS` constant), and made `@wiki-lint`/`@knowledge-consolidation` reports stdout-only. `agent-changelog.md` pruned to current-session entries (older history recoverable via git). Skill versions bumped (app-vision-north-star v1→2, knowledge-capture v5→6, knowledge-consolidation v5→6, wiki-lint v1→2); machinery-version 14→15. Gates: prefix PASS ×7, UTF-8 ALL CLEAN (113), wiki_lint OK.
**Ref:** `c4c0297`


---

## 2026-09-09 - Changelog Format: Lean (When + Why), File Lists Retired

**Why:** Audit showed ~42% of changelog lines were file-bullet inventories already derivable from each entry's ref commit and the plan's Completion Note. Phase 1 now mandates a max-5-line entry (title + Why + Ref); Agent/Files/Database fields retired; delegation returns trimmed to summaries. Existing entries left as-is — no mass rewrite.
**Ref:** `b0ca295`


---

## 2026-09-09 - Wiki-Writer Rebalance Pass Over the Four Knowledge Skills

**Agent:** GitHub Copilot (OpenCode Go / Qwen3.8 Flash)

**Files Modified:
- `.devops/skills/knowledge-capture/SKILL.md` — v3→v4. Skeleton is now the single canonical KC format (Wiki-ref removed, date-prefix convention added); header-check bullet folded into lean-at-capture; consolidation-boundary line corrected to include retroactive low-value cuts.
- `.devops/skills/knowledge-consolidation/SKILL.md` — v3→v4, 224→214 lines. Trigger Conditions merged into the Modes table (one trigger surface); Phase 2 stopped restating the gate's reject categories and references the canonical gate instead; stale `link to wiki doc Y` recommendation fixed to the current verdict set; report table deduped and reordered.
- `.devops/skills/pass-the-parcel/SKILL.md` — v5→v6, 221→211 lines. Phase 10 hook collapsed from two restated tables to one line referencing the canonical Admission Gate (marked canonical — defined once in knowledge-capture).
- `.devops/skills/agent-wrap-up/SKILL.md` — v3→v4. Phase 7 step 3 trimmed to reference the consolidation Modes table instead of restating tidy scope.

**Database/API Changes:** None

**Summary:** Applied the wiki-writer Review → Re-outline → Re-balance discipline to the four skills edited across three consecutive sessions this date, which had accumulated recency-biased append drift: the Admission Gate existed in ~6 homes. Ownership fixed: knowledge-capture owns the gate table canonically; consolidation/wrap-up/pass-the-parcel reference it in one line each. No functional changes — same outcomes, less surface, no future drift vectors. Verification: wiki_lint exit 0, check-utf8 ALL CLEAN (114 files), duplication scan clean. **Wrap-up ref:** `b0ca295`


---

## 2026-09-09 - KC Strict Admission Gate: Real Deviations + Valuable Tribal Knowledge Only

**Agent:** GitHub Copilot (OpenCode Go / Qwen3.8 Flash)

**Files Modified:
- `.devops/skills/knowledge-capture/SKILL.md` — v2→v3. New §1 Admission Gate (strict, runs before classification): default answer is no; one-line test ('what will a future agent do differently without naming this plan?'); admit/reject table — accident fixes, plan-conformity tweaks, full-change rewrites, one-time preferences rejected and left in the plan log. Stale Wiki-ref bullet removed from Decision Archive format.
- `.devops/skills/pass-the-parcel/SKILL.md` — v4→v5. Phase 10 Knowledge Capture Hook rewritten: 'default to capture' inverted to 'default to skip' with the four qualifying categories and four explicit exclusions; Wrap Up references strict-admission Capture Flag.
- `.devops/skills/knowledge-consolidation/SKILL.md` — v2→v3. Phase 2 harvest applies the Admission Gate (most tweaks produce nothing worth harvesting); Phase 4 adds retroactive Q2b (cut-lowvalue) for entries that never cleared the bar; report gains 'Cut (failed Admission Gate)' row.
- `.devops/skills/agent-wrap-up/SKILL.md` — Phase 7 step 1 now states the strict bar inline.

**Database/API Changes:** None

**Summary:** Per user direction, KC admission tightened: only real deviations (plan/spec was wrong and the correction generalizes) and valuable tribal knowledge enter the log. Simply agreeing with the recommendation, fixing accidents, or redoing a change wholesale stays in the Phase 10 log / Completion Note. The gate is enforced at all three surfaces where content enters KC (capture, per-tweak hook, consolidation harvest) plus retroactively during audits. Verification: wiki_lint exit 0, check-utf8 ALL CLEAN (114 files). **Wrap-up ref:** `b0ca295`


---
## 2026-09-09 - Knowledge Capture System Overhaul: Closed Consolidation Loop + Hard Size Caps

**Agent:** GitHub Copilot (OpenCode Go / Qwen3.8 Flash)

**Files Modified:**
- `.devops/skills/agent-wrap-up/SKILL.md` — v2→v3. Phase 7 renamed "Knowledge Capture & Consolidation" with mandatory step 3: run `@knowledge-consolidation` (tidy mode) after capture — the handoff that was documented but never wired, the root cause of one-way KC growth. Phase 1 gained a hard 500-line cap on this changelog with oldest-entry pruning.
- `.devops/skills/knowledge-consolidation/SKILL.md` — v1→v2. Two modes: **Tidy** (default, every plan, surgical edits only, never a whole-file rewrite) and **Full audit** (explicit request / vibe-auditor flag / file > 200 lines). Hard limits: 500-line file ceiling, max 5 Decision Archive entries, 3-line top-level entries. Promotion policy rewritten per user direction: promoted rules are DELETED from KC (no pointers — agents read the wiki before KC), `link-to-wiki` verdict replaced by `cut-duplicate`, zero wiki duplication enforced.
- `.devops/skills/knowledge-capture/SKILL.md` — v1→v2. Lean-at-capture mandate: ≤3-line entries at capture time, append under existing headers only (never re-emit duplicate section headers), superseded entries cut at capture with supersession logged to knowledge-changelog, no-pointer rule (skip capture entirely when the wiki covers the rule).
- `.wiki/core/18-knowledge-capture.md` — full consolidation (first ever run): 269 → 64 lines. Converted to canonical 4-section format; 5 superseded entries cut, 3 rules promoted to `.devops/README.md` §Transportability then deleted here, 4 template placeholder blocks (44 lines) removed, 13 duplicate `## 🚀 Tooling & DevOps` headers collapsed, mojibake repaired. New pitfalls: truncated-line edit landmine, UTF-8 BOM via `Set-Content`.
- `.devops/README.md` — Transportability gained three canonical rules promoted from KC: portable = no absolute paths, normalize CRLF→LF before hashing across git boundaries, gates must be reproducible from a fresh clone (tracked files only).
- `scripts/check-utf8-agents.ps1` — scan extended to `.wiki/core/18-knowledge-capture.md`; new marker C3 B0 C2 catches double-encoded emoji (the `ðŸš€` class found in KC headers). Verified against synthetic bytes.
- `.devops/sync-manifest.yaml` — machinery-version 13→14
- `.devops/logs/knowledge-changelog.md` — consolidation audit record with supersession/promotion log

**Database/API Changes:** None

**Summary:** Reviewed the knowledge-capture system per user request: measured 269-line KC growing ~9 lines/day with zero consolidations ever applied (wrap-up only appended; the documented consolidation handoff existed in no executable surface). Fixed the loop (wrap-up Phase 7 now runs tidy consolidation), made consolidation cheap enough to actually fire (two modes, surgical-only default), moved leanness upstream to capture time, and adopted the user's policy: KC holds only edge cases with future practical use, never pointers, never wiki duplicates, hard 500-line caps on both KC and the agent changelog, deterministic short entries. Verification: `check-utf8-agents.ps1` ALL CLEAN (114 files), `wiki_lint.py --quiet` exit 0, `check-parcel-prefix.ps1` PASS ×7 byte-identical. **Wrap-up ref:** `b0ca295`

---

