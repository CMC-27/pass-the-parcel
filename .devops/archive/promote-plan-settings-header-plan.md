# Parcel Plan: Promote Plan Settings (Mode / Agents) to a Frozen Header Block
## Theme-Epic: T-Machinery, E-Parcel-Config

## ⚙️ Plan Settings (FROZEN — set at plan start, read before any phase)

| Setting | Value | Meaning |
|---|---|---|
| **Mode** | `AUTO` | `USER-MANAGED` (every gate halts for the user) or `AUTO` (orchestrator auto-clears Gates A-C; Gate D always halts) |
| **Agents** | `SINGLE` | `MULTI` (comprehensive — full `ptp-*` delegation, 4 gates) or `SINGLE` (fast — inline personas, Group C skipped, Gates B+C merged at Gate B, Gate C `N/A`) |

> **Frozen config — read this before executing ANY phase.** These two settings govern the entire pipeline and are never edited after plan start; they are deliberately at the TOP so no session can miss them. Mutable runtime state (Status / Active Persona / gates) lives ONLY in the cache-anchored `## 📍 State & Gates` section at the bottom. See `@pass-the-parcel` § Agent Topology.

> **Skill Architecture:** This template is consumed by the `pass-the-parcel` skill. Each phase delegates to a specialized sub-skill. See the parcel skill's Skill Delegation Map.
>
> **RULES:**
> - Full skeleton required - ALL 10 phases + Wrap Up MUST be present.
> - Halt points are HARD STOPS - each gate blocks all subsequent phases.
> - Persona matches Status - use the State Lifecycle table in pass-the-parcel skill.
> - Read **Plan Settings** above before acting; the topology there governs which gates apply.
>
> **🔒 CACHE-ANCHORED:** The **Plan Settings** block above is frozen config; the mutable State Dashboard + Gate Log live in the **last section** (`## 📍 State & Gates`). Gate transitions update ONLY those bottom rows — do NOT edit content above once written. Byte-stable prefix = LLM prefix-cache hits for every downstream agent re-read.

---

## 1 Phase 1: Expansion & Scoping
**Skill Executed:** `ptp-context-hunter` (SINGLE: orchestrator inline)

**Intent:**
`Mode` (USER-MANAGED/AUTO) and `Agents` (MULTI/SINGLE) are plan-start settings that govern the whole pipeline, but they live in the cache-anchored **bottom** `## 📍 State & Gates` table next to mutable runtime state. Sessions/subagents sometimes miss them. Promote the two behavioral settings to a frozen, top-of-file `## ⚙️ Plan Settings` block; leave only mutable state (Status / Active Persona / gates) at the bottom. Fix every reference that points at the bottom for mode/topology.

**In Scope:**
- Add a top `## ⚙️ Plan Settings` block (Mode + Agents) to `.devops/plans/template-plan.md`.
- Remove the `Mode` and `Agents` rows from the bottom State & Gates table in the template.
- Update all prose/instructions that say "record/read Mode or Agents in State & Gates (bottom)" to point to the new top block:
  - `.opencode/plans/base-context.md` (canonical prefix)
  - `.devops/agents/parcel.agent.md` (orchestrator steps 2-3)
  - `.devops/skills/pass-the-parcel/SKILL.md`
  - `.devops/rules/plan-lifecycle.md`
  - `HOW-TO.md`
  - `.devops/templates/base-context.template.md` (satellite seed)
  - `.wiki/core/18-knowledge-capture.md` (tribal-knowledge claims)
- Re-sync PREFIX-LOCKED agents after editing `base-context.md`.

**Out of Scope:**
- Relocating `Version` / `Depends On` / `Blocks` (separate metadata-taxonomy cleanup; not the reported failure).
- Migrating already-archived plans under `.devops/archive/` (historical records, frozen).
- Any change to gate semantics, lifecycle states, or topology behavior.

**Perimeter Notes:**
- The plan prose in `template-plan.md` uses "State & Gates" for status/persona/gates (mutable) — those references stay. Only mode/agents references move.
- `ptp-*` subagent unique sections only reference State & Gates for *status* — no change needed; shared-prefix text arrives via `-Sync`.

---

## 2 Phase 2: Requirements & Context
**Skill Executed:** `ptp-context-hunter` (SINGLE: orchestrator inline)

**Forensic Context Inventory:**
> [x] Wiki core docs read (`.wiki/core/18-knowledge-capture.md` carries the parcel-config claims)
> [x] Knowledge capture read (`.wiki/core/18-knowledge-capture.md` lines 28, 57)
> [x] Source code verified (template, skill, base-context, agent, rules, HOW-TO, seed template)

**Relevant Existing Decisions (from knowledge capture):**
- KC Rule #1 / Parcel entry: "State & Gates live at the BOTTOM of a plan; everything above stays byte-stable (LLM prefix cache)." — this decision is amended: settings are frozen at top, mutable state at bottom.
- KC Rule #7: never hand-edit PREFIX-LOCKED surfaces; edit `base-context.md` then `check-parcel-prefix.ps1 -Sync`.

**Relevant Docs Found:**
- `.devops/rules/plan-lifecycle.md:20,34-42` — template + cache-anchored contract.
- `.wiki/core/18-knowledge-capture.md:28,57` — parcel config claims.

**Relevant Code Found:**
- `.devops/plans/template-plan.md:10,12,284-285,287-288,276-301` — settings rows + rules + cache note.
- `.opencode/plans/base-context.md:40-46` — mode/topology prose.
- `.devops/agents/parcel.agent.md:99-100,103` — record points.
- `.devops/skills/pass-the-parcel/SKILL.md:27,59,103` — lifecycle/cache/topology record points.
- `.devops/templates/base-context.template.md:48-54` — seed mirror.
- `HOW-TO.md:61` — record point.
- `scripts/check-parcel-prefix.ps1` — validates prefix + model registry; does NOT parse plan setting rows (safe to move).

---

## 3 Phase 3: User Clarification
**Skill Executed:** `ptp-context-hunter` → `ptp-phase3-answerer` (AUTO)

> [x] Q1: Promote Mode + Agents only, or all immutable metadata (Version/Depends/Blocks)?
> [x] Q2: Header block name/shape?
> [x] Q3: Keep a pointer note in the bottom table?
> [x] Q4: Should the template's RULES blockquote keep the Topology line?
> [x] Q5: Update the knowledge-capture tribal entry or leave it?
> [x] Final validation: "Is this all the context required?" -> Yes

**Architectural Conflict Warnings Raised:**
- None. Moving Mode/Agents does not touch the mutable-state cache contract — they are written before the freeze.

### Phase 3.5 Research Map (AUTO)
| Q# | Core Docs | Code Files | KC Entries |
|---|---|---|---|
| Q1 | — | `template-plan.md` bottom table | KC Parcel entry |
| Q2 | — | `template-plan.md` top block | — |
| Q3 | — | `template-plan.md` bottom note | — |
| Q4 | — | `template-plan.md` RULES | — |
| Q5 | `18-knowledge-capture.md` | — | KC Rule #1 / Parcel entry |

**Auto-resolutions (AUTO):**
- Q1 -> **Mode + Agents only.** Minimal, addresses the reported miss; broader metadata move is deferred (Simplicity Ladder + tight perimeter).
- Q2 -> `## ⚙️ Plan Settings (FROZEN — set at plan start, read before any phase)` with a 3-column `Setting | Value | Meaning` table.
- Q3 -> Yes — a one-line pointer in the bottom section prevents future re-introduction of the rows.
- Q4 -> Remove the now-duplicated `**Topology:**` bullet from RULES; the header block is the single source of truth.
- Q5 -> Update both KC references (rule + Parcel entry); docs marked `in-progress` until wrap-up.

### Test Proposals (TDD)
1. **No orphan settings row** — Steps: grep template + active agent/skill/rules files for a bottom-table `Mode`/`Agents` row. Expected: none outside `.devops/archive/`.
2. **Header present** — Steps: read `template-plan.md` top. Expected: `## ⚙️ Plan Settings` exists before `## 1 Phase 1`.
3. **Prefix integrity** — Steps: `scripts\check-parcel-prefix.ps1` + `scripts\check-utf8-agents.ps1`. Expected: exit 0.

---

> **HALT POINT (Gate A — Scope):** Phases 1-3 complete (+ Phase 3.5 auto-resolutions). Scope = promote Mode/Agents to a frozen top block; update references; re-sync prefix. **AUTO: Gate A auto-cleared after mechanical verification (all Q's resolved, no `Unresolvable:`, no conflict).**

---

## 4 Phase 4: Wiki Requirements & Acceptance Criteria
**Skill Executed:** `ptp-high-visionary` + `@wiki-writer` (SINGLE: inline)

> **Conditional checklist:** (a) user-visible/behavior change? YES — parcel plan config is agent-facing behavior. (b) logic-contract change? NO. (c) wiki-facing behavior change? YES — `.wiki/core/18-knowledge-capture.md` states the bottom-only contract. → **Wiki delta applies.**

**Wiki Docs to Write/Update (as `in-progress`):**
| Doc | Change |
|---|---|
| `.wiki/core/18-knowledge-capture.md` | Amend Rule #1 + Parcel Pipeline entry: settings frozen at top; mutable state at bottom |

**Acceptance Criteria:**
| # | Criterion (behavior) | Test Target |
|---|---|---|
| 1 | `template-plan.md` declares `Mode` and `Agents` in a top `## ⚙️ Plan Settings` block | read template top |
| 2 | Bottom `## 📍 State & Gates` has no `Mode`/`Agents` rows | grep template bottom |
| 3 | Orchestrator records mode/topology at the top block, not the bottom | `parcel.agent.md` steps 2-3 |
| 4 | Canonical prefix + skill + rules + HOW-TO + seed all point to the top block | grep changed files |
| 5 | PREFIX-LOCKED agents byte-identical to `base-context.md`; UTF-8 clean | `check-parcel-prefix.ps1`, `check-utf8-agents.ps1` |
| 6 | KC doc describes the new split | read `18-knowledge-capture.md:25-60` |

**Spec Notes:**
- Data flow / state changes: none (documentation/config structure only).
- Edge cases the spec must cover: historical archived plans keep the old bottom rows (do not migrate); `Blocks`/`Depends On` stay put.
- Docs consumed by this feature: `plan-lifecycle.md`, `pass-the-parcel/SKILL.md`.

---

> **NO HALT after Phase 4:** reviewed with the implementation plan at Gate B.

---

## 5 Phase 5: High-Visionary Standard Implementation Plan
**Skill Executed:** `ptp-high-visionary` (SINGLE: inline)

**Simplicity Gate:**
> [x] Climbed the Simplicity Ladder (7 rungs)
> [x] No speculative abstractions
> [x] Reuse over reimpl - Reuse Log populated
> [x] Deliberate simplifications marked with `ponytail:` comments
> [x] Safety exceptions preserved

**Reuse Log:**
| Existing Asset | Where Reused | Ladder Rung |
|---|---|---|
| Existing `## 📍 State & Gates` table shape | New `## ⚙️ Plan Settings` table | 2 |
| `check-parcel-prefix.ps1 -Sync` | Re-inline base-context into all 7 agents | 2 |

**Spaghetti Triage (See-Name-Route, Do Not Fix):**
- [x] No smells noticed

| File | Function | Smell Type | Severity | Recommended Action |
|---|---|---|---|---|
| | | | | |

### To-Do List
- [ ] Edit `template-plan.md`: add top settings block; trim RULES; update cache note; drop bottom rows; add pointer
- [ ] Edit `base-context.md`: add "where settings live" sentence
- [ ] Edit `parcel.agent.md`: steps 2-3 record at top
- [ ] Edit `pass-the-parcel/SKILL.md`: lifecycle/cache/topology record points
- [ ] Edit `plan-lifecycle.md`: template + modes/agents + cache sections
- [ ] Edit `HOW-TO.md`: record point
- [ ] Edit `base-context.template.md`: mirror sentence; version 5->6
- [ ] Edit `.wiki/core/18-knowledge-capture.md`: amend KC entries (in-progress)
- [ ] Run `check-parcel-prefix.ps1 -Sync`, then validation + `check-utf8-agents.ps1`

### File-Level Steps
1. **`.devops/plans/template-plan.md`** — Insert `## ⚙️ Plan Settings (FROZEN ...)` + explanatory quote after the `## Theme-Epic:` line. Delete the `**Topology:**` RULES bullet. Reword the `🔒 CACHE-ANCHORED` note to name the frozen settings block. In the bottom table delete the `Mode` and `Agents` rows and add a one-line pointer quote. Reword the bottom cache-rule note to include the frozen top block.
2. **`.opencode/plans/base-context.md`** — After the topology-selection paragraph, add a bolded "**Where they live:**" line: both settings are recorded in the plan's top `Plan Settings` block; the bottom State & Gates holds only mutable runtime state.
3. **`.devops/agents/parcel.agent.md`** — Step 2: record mode in the top `Plan Settings` block. Step 3: record topology in the top `Plan Settings` `Agents` row.
4. **`.devops/skills/pass-the-parcel/SKILL.md`** — Add to the lifecycle intro that Mode/Agents live in the top settings block; reword the cache-anchor rule; change line 103 to the top block; note it in § Agent Topology ("recorded in the plan's Plan Settings block").
5. **`.devops/rules/plan-lifecycle.md`** — Template description: note the frozen settings block at top + mutable tail. Modes/Agents: add location. Cache-anchored section: distinguish frozen config (top) vs mutable state (bottom).
6. **`HOW-TO.md`** — Line 61: record the choice in the plan's top `Plan Settings` block.
7. **`.devops/templates/base-context.template.md`** — Mirror step 2's sentence; bump `version: 5` -> `6`.
8. **`.wiki/core/18-knowledge-capture.md`** — Amend Rule #1 row and the Parcel Pipeline "Cache-anchored plans" bullet; set `status: in-progress` for the doc until wrap-up.

### Implementation Instructions
- No code snippets; edits are prose/table/markdown only.
- Exact string literals introduced: heading `## ⚙️ Plan Settings (FROZEN — set at plan start, read before any phase)`; table header `| Setting | Value | Meaning |`; bold keys `**Mode**`, `**Agents**`.
- Preserve existing UTF-8 (no BOM); the `⚙️`/`📍` emoji must survive.
- Do not touch `.devops/archive/**`.

### Wiki Core References
- `.wiki/core/18-knowledge-capture.md` -> parcel-config claims (amended)

### Wiki Docs to Add/Edit
- `.wiki/core/18-knowledge-capture.md` (amended per Phase 4)

---

> **HALT POINT (Gate B — Spec & Plan Review):** Phases 4-5 complete. **AUTO: Gate B auto-cleared** after mechanical verification (outputs present, no `REJECTED`, no `Unresolvable:`).

---

## 6 Phase 6: Grumpy Architect Spec & Logic Audit
**Skill Executed:** `ptp-grumpy-architect` (SINGLE: orchestrator inline)

> **`SINGLE` topology:** no independent reviewer. Inline self-review checkpoint. **Verdict:** `N/A — SINGLE self-review`.

- **System Contracts Explicit:** files + sections named above; no ambiguity.
- **File Boundary & Scope Collisions:** `parcel.agent.md` has both prefix (synced) and unique (steps 2-3) regions — edits must separate them; `-Sync` preserves unique content.
- **Dependency Gaps:** none — all touched files identified.
- **YAGNI Bloat:** Version/Depends/Blocks deliberately NOT moved (out of scope).
- **Paranoid Security:** N/A (docs/config).
- **Survivability:** N/A.
- **Edge Cases:** archived plans retain old rows — acceptable (historical); seed template must mirror.
- **Performance Trade-offs:** none.
- **Architectural Anti-Patterns:** avoids two-sources-of-truth by deleting the bottom rows (move, not copy).
- **Wiki Core Compliance:** cites knowledge-capture.

**Required Fixes:**
> [x] None

---

## 7 Phase 7: Smooth Operator Product Review
**Skill Executed:** `ptp-smooth-operator` (SINGLE: orchestrator inline)

> **`SINGLE` topology:** **`N/A — SINGLE self-review`**.

- **Vision & Journey Integrity:** directly resolves the reported "agent misses the setting" friction.
- **Scope Containment:** no gold plating; metadata relocation deferred.
- **4 Core User States:** N/A (config docs).
- **Guardrails & Permissions:** archived plans untouched.
- **Mobile / A11y / Telemetry:** N/A.

**Required Fixes:**
> [x] None

---

> **HALT POINT (Gate C — Peer Reviews):** **SINGLE topology: Gate C `N/A`.** Plan approved once at Gate B (spec + plan + inline self-review). Set Gate C row to `N/A (SINGLE)`.

---

## 8 Phase 8: Execute Changes
**Skill Executed:** `ptp-code-surgeon` (SINGLE: orchestrator inline)

**Execution Isolation:** Phase 8 triggers after Gate B cleared (SINGLE).

**Single-Pass Direct-to-Disk:**
> [x] Implementation written DIRECTLY to source files - no intermediate Markdown code blocks, no drafting files
> [x] Touched only intended lines - no adjacent refactors
> [x] Cleaned up only owned orphans
> [x] Pre-existing dead code left untouched

> [x] Step 1: `template-plan.md` settings block + reference updates
> [x] Step 2: `base-context.md` + `parcel.agent.md` + `pass-the-parcel/SKILL.md`
> [x] Step 3: `plan-lifecycle.md` + `HOW-TO.md` + `base-context.template.md`
> [x] Step 4: `.wiki/core/18-knowledge-capture.md`
> [x] Step 5: `check-parcel-prefix.ps1 -Sync` + validators

---

## 9 Phase 9: Verify Changes
**Skill Executed:** `ptp-code-surgeon` (SINGLE: orchestrator inline)

**Build & Lint:**
> [x] No JS build in this machinery repo; verification = prefix + UTF-8 + grep contracts

**Test Report:**
- [x] `check-parcel-prefix.ps1` exit 0 (all 7 agents share byte-identical prefix)
- [x] `check-utf8-agents.ps1` exit 0 (clean UTF-8, no mojibake)
- [x] Grep: no bottom-table `Mode`/`Agents` rows outside `.devops/archive/`
- [x] `template-plan.md` top block present before Phase 1
- [x] Code matches plan specifications; no functional gaps

**Evidence:**
- `check-parcel-prefix.ps1 -Sync` -> `FIXED` ×7, then `check-parcel-prefix.ps1` -> `PASS` ×7 + `MODEL`/`OC-MODEL` ×7, `OK: all PREFIX-LOCKED agents share a byte-identical prefix.`
- `check-utf8-agents.ps1` -> `ALL CLEAN (191 files scanned)`.
- `wiki_lint.py` -> `OK: wiki healthy - 0 broken links, all anchors present, frontmatter valid.`
- Grep `^\| \*\*(Mode|Agents)\*\* \|` outside archive -> only the new top `Plan Settings` rows (template + this plan); no bottom-table rows.
- `template-plan.md:4-11` top block present before `## 1 Phase 1`; bottom table `template-plan.md:289-295` has no Mode/Agents rows.
- Run workspace: `.opencode/plans/run-promote-plan-settings-header/decision_log.md`.

---

> **HALT POINT (Gate D — Implementation):** Implementation + verification complete. **Gate D always halts for the human even in AUTO.** Awaiting user sign-off.

---

## 10 Phase 10: User Review & Tweaks
**Skill Executed:** `knowledge-capture`

**Tweak Discipline:**
> Tweaks are surgical, not architectural. `expansion` and `refactor` are HALT conditions.

- [ ] Tweak classified: `fix` / `expansion` / `refactor`
- [ ] `expansion` and `refactor` routed to new parcel
- [ ] `fix` touches <= 3 files
- [ ] `fix` introduces no new abstraction absent from original plan

**Capture Categories:** Recurring / Tribal / One-off / Cosmetic-skip

| Round | Feedback | Action Taken | Capture Flag | Result |
|---|---|---|---|---|
| 1 | | | | PENDING |

**Sign-Off:** [Pending]

---

## Completion Note (Wrap Up)
**Skill Executed:** `agent-wrap-up`

> [x] Read `.wiki/core/18-knowledge-capture.md` for existing related decisions
> [x] Themed tweaks synced to knowledge capture doc
> [x] Wiki docs updated per Phase 10 tweaks
> [x] Code reconciled against Phase 4 spec — deviations logged
> [x] `status: in-progress` wiki docs promoted to `stable` (or deviation logged)
> [x] Version bumps: `pass-the-parcel` v7->v8, `base-context.template.md` v5->v6, machinery-version 33->34
> [x] Changelog + version-history entries

**Themed Tweaks:** None — user accepted the deliverable at Gate D ("wrap up, test and deploy").

**Knowledge Capture Entries:** Amended (not added) KC Rule #1 and the Parcel Pipeline entry to describe the config/state split. Consolidation tidy: no new entries warranted — the lesson is captured in the amended rule itself.

**Spec Reconciliation:** None — implementation matches Phase 4 spec. Only deviation: `Version`/`Depends On`/`Blocks` deliberately left in the bottom table (documented Out-of-Scope).

**In-Progress Promotions:** `.wiki/core/18-knowledge-capture.md` promoted `in-progress` -> `stable` (`00-system-index.md` Last Verified -> 2026-09-12).

**Dead-Code Backlog Entries (from Phase 6):** None

**Wiki Updates:** `.wiki/core/18-knowledge-capture.md`; `.wiki/core/00-system-index.md`

**Plan Archiving:** Plan archived to `.devops/archive/promote-plan-settings-header-plan.md` (via `git mv`)

**Backlog Review:** No open backlog item was resolved (this plan was created directly, not from the backlog). Added a `COMPLETE` row under T1-E2 in `backlog-index.md` for traceability.

---

## 📍 State & Gates (CACHE-ANCHORED — update ONLY this section at gate transitions)

> **Cache rule:** This is the **last section** in the file. Gate transitions mutate ONLY the rows below — phase content above AND the frozen **Plan Settings** block at the top stay byte-stable to preserve LLM prefix-cache hits. Every "Update Status" instruction in the halt points above means "edit this section".

| Metric | Value |
|---|---|
| **Status** | `COMPLETE` |
| **Version** | `v0.1.0` |
| **Active Persona** | `Executor` |
| **Depends On** | none |
| **Blocks** | none |

> **Settings:** `Mode` and `Agents` live in the **Plan Settings** block at the top of this file (frozen config — read there before any phase). Do not duplicate them here.
> Valid states: `BACKLOG`, `PHASE_1`, `PHASE_3`, `PHASE_5`, `PHASE_5_REVISION`, `PHASE_7`, `PHASE_8_FAILED`, `PHASE_9`, `COMPLETE`.

| Gate | Requirement | Status |
|---|---|---|
| A | Scope approved (Phases 1-3, + 3.5 in AUTO) | `APPROVED` (AUTO) |
| B | Spec & plan approved (Phases 4-5) | `APPROVED` (AUTO) |
| C | Peer reviews passed (Phases 6-7) | `N/A (SINGLE)` |
| D | Implementation verified (Phases 8-9) | `APPROVED` |

> Gate flips: rows flip `OPEN` → `APPROVED`/`REJECTED` ONLY after the user's (or AUTO verification's) verdict, recorded by the orchestrator. Executing agents halt with their gate `OPEN`. Rejection routes: A -> `PHASE_1`; B/C -> `PHASE_5_REVISION`; D/rollback -> `PHASE_8_FAILED`. Never edit rows above this section for gate bookkeeping.

> **This section is the LAST section in the file. All gate bookkeeping happens here.**
