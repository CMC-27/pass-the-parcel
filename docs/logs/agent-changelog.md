---
type: "core"
name: "Agent Changelog"
status: "stable"
description: "Chronological record of all AI agent actions, changes, and audits."
---

# Agent Changelog

All changes made by AI agents are tracked chronologically below.

---

## 2026-08-19 - Parcel Cache-Anchored Templates (State & Gates at Bottom)

**Agent:** opencode-go/deepseek-v4-flash (Coordinated by user)

**Files Modified:**
- `docs/plans/template-plan.md` — removed top State Dashboard; added static `🔒 CACHE-ANCHORED` banner; added bottom `## 📍 State & Gates` (State table + Mode row + Gate Log A-D); halt points point to bottom section; folded trailing `Status: COMPLETE` into bottom
- `skills/pass-the-parcel/references/template-plan.md` — mirror restructure (skill-bundled canonical copy)
- `skills/pass-the-parcel/SKILL.md` — cache-anchor rule in Plan State Lifecycle; all halt points/backlog pickup/wrap-up now reference the bottom State & Gates section
- `.opencode/command/parcel.md` — Mode written to bottom section; Gate A init `OPEN` + advance via bottom section (USER-MANAGED + AUTO)
- `.opencode/agents/parcel-context-hunter.md` — init + hard rule point to State & Gates (bottom)
- `.opencode/agents/parcel-high-visionary.md` — revision loop + Step 6 set bottom Status/Gate B
- `.opencode/agents/parcel-code-surgeon.md` — Step 6 sets bottom Status/Gate D
- `.opencode/agents/parcel-phase3-answerer.md` — Step 5 bottom phrasing
- `skills/parcel-compactor/SKILL.md` — Keep Rules: State & Gates summary (bottom)
- `skills/agent-wrap-up/SKILL.md` — Mark Complete via bottom section (Status + Gate D)
- `skills/build-roadmap/SKILL.md` — backlog scaffold sets bottom section
- `skills/spaghetti-monster/SKILL.md` — backlog packaging + exit criteria reference bottom section
- `skills/ptp-context-hunter/SKILL.md` — template init + final validation gate reference bottom section

**Database/API Changes:** None

**Summary:** Moved the hot, frequently-mutated state (Status, Active Persona, Gate Log) from the top of every parcel plan template to the LAST section of the file. LLM prefix-caching is byte-precise — a change near the top invalidates the entire file's cache for downstream stateless agents that re-read the plan at each gate. Bottom-anchoring means gate transitions mutate only the final ~15 lines; the long stable phase content stays byte-identical and hits prefix cache on every re-read. Added a static (never-edited) CACHE-ANCHORED banner at the top, consolidated Status + Gate Log into `## 📍 State & Gates`, added the Mode row (already written by `/parcel`), and folded the trailing `Status: COMPLETE` into the bottom section. All 11 downstream references (skills + agents + /parcel command) updated to point to the bottom section. Verified: `check-parcel-prefix.ps1` + `check-utf8-agents.ps1` PASS; template parity check OK (only per-template version defaults differ); smoke test shows a gate transition touches only 3 of 264 lines.

---

## 2026-05-21 - Initial Repository Scaffold
**Agent:** template-generator
**Files Modified:**
- (all files — initial scaffold)
**Database/API Changes:** None
**Summary:** Created the Vibe-App-Wiki repository scaffold with the hub-and-spoke wiki architecture, skill system, opencode integration, pass-the-parcel workflow, and developer conventions. All core docs initialized as templates ready for project-specific content.

---

## 2026-08-17 - Parcel Orchestration Overhaul (Model Assignments + Phase Reshuffle)

**Agent:** opencode-go/deepseek-v4-flash (Coordinated by user)

**Files Modified:**
- `opencode.json` — re-mapped parcel-* agent models; renamed `parcel-razor-planner` → `parcel-high-visionary`; updated descriptions
- `.opencode/agents/parcel-orchestrator.md` — model → mimo-2.5; delegation map Phase 5/6 swapped; Phase 4 → `parcel-high-visionary`
- `.opencode/agents/parcel-context-hunter.md` — model → mimo-2.5
- `.opencode/agents/parcel-high-visionary.md` — **renamed** from `parcel-razor-planner.md`; model → mimo-2.5; High-Visionary persona (standard impl plan, no code snippets unless necessary)
- `.opencode/agents/parcel-grumpy-architect.md` — model → deepseek-v4-flash-max; Senior Architect persona (hygiene → senior review; +edge cases, performance, anti-patterns); Phase 6 → Phase 5
- `.opencode/agents/parcel-smooth-operator.md` — Phase 5 → Phase 6; cross-feature check inverted to cross-reference Phase 5 arch review
- `.opencode/agents/parcel-code-surgeon.md` — added ponytail coding directives; description updated
- `.opencode/agents/parcel-phase3-answerer.md` — model → mimo-2.5
- `.opencode/plans/base-context.md` — agent list updated with models + renamed agent
- `skills/pass-the-parcel/SKILL.md` — delegation map with model assignments; Phase 4 → High-Visionary; Phase 5/6 swap; persona ownership table
- `skills/pass-the-parcel/references/template-plan.md` — skill refs + Phase 5/6 swap + new grumpy findings rows
- `skills/ptp-razor-planner/` → **renamed** to `skills/ptp-high-visionary/` — High-Visionary persona, no code snippets, mimo-2.5
- `skills/ptp-grumpy-architect/SKILL.md` — Senior Architect Review persona; directives 6-8 added (edge cases, performance, anti-patterns)
- `skills/ptp-smooth-operator/SKILL.md` — Phase 6; handoff logic inverted
- `skills/ptp-code-surgeon/SKILL.md` — ponytail coding directive (7)
- `skills/ptp-context-hunter/SKILL.md` — model → mimo-2.5
- `skills/agent-wrap-up/SKILL.md` — model → mimo-2.5
- `docs/plans/template-plan.md` — skill refs, persona refs, Phase 5/6 swap, no-code-snippet instructions
- `HOW-TO.md` — flow diagram + pipeline ordering updated

**Database/API Changes:** None

**Summary:** Overhauled the pass-the-parcel orchestration to a new model assignment matrix: mimo-2.5 (orchestrator) now carries Phases 1-3, 4 (High-Visionary), 6 (Smooth Operator), and wrap-up; v4 flash max (deepseek-v4-flash-max) owns Phase 5 (Grumpy Architect, reframed as a Senior Architect review covering edge cases, performance bottlenecks, and architectural anti-patterns); deepseek v4 flash owns Phase 7 (Code Surgeon, now with ponytail coding); v4 flash owns Phase 8 (QA tweaks). Phase 4 was trimmed to a standard implementation plan with no code snippets unless absolutely necessary. Phase order swapped so Grumpy Architect (Phase 5) precedes Smooth Operator (Phase 6). All skill files, agent definitions (both `opencode.json` and `.opencode/agents/*.md`), template plans, and HOW-TO docs were synchronized.

---

## 2026-08-18 - Parcel Cache Quick Wins (PREFIX-LOCKED Enforcement)

**Agent:** opencode-go/deepseek-v4-flash (Coordinated by user)

**Files Modified:**
- `.gitattributes` — NEW: pins `eol=lf` for all text + PREFIX-LOCKED files; prevents CRLF/LF drift
- `scripts/check-parcel-prefix.ps1` — NEW: verifies every `parcel-*.md` body is byte-identical to `base-context.md`; `-Sync` re-inlines
- `scripts/check-utf8-agents.ps1` — NEW: byte-level mojibake detector
- `.opencode/plans/base-context.md` — consolidated PTP Delegation Map + Model Registry + revision loop into canonical header
- `.opencode/agents/parcel-*.md` (all 8) — re-inlined byte-identical prefix via `-Sync`; repaired UTF-8 mojibake
- `AGENTS.md` — added rule 9 (PREFIX-LOCKED Integrity + check workflow)
- `skills/pass-the-parcel/SKILL.md` — canonical-copy pointer to `base-context.md`
- `.git/hooks/pre-commit` — NEW: runs both checks as a commit gate

**Database/API Changes:** None

**Summary:** Applied the cache/context quick wins from the workflow review: (1) `.gitattributes` normalizes all files to LF so byte-for-byte KV-cache matching is never silently broken by CRLF conversion; (2) `check-parcel-prefix.ps1` machine-enforces the PREFIX-LOCKED contract (verify + `-Sync` repair) and `check-utf8-agents.ps1` detects encoding corruption — both wired into a pre-commit hook; (3) moved the delegation map + model registry into the canonical `base-context.md` header so every agent shares a larger cached prefix. All 8 agent files verified byte-identical.

---

## 2026-08-17 - Parcel Pipeline Adjustments (Spec Audit + Revision Loop + Direct-to-Disk)

**Agent:** opencode-go/deepseek-v4-flash (Coordinated by user)

**Files Modified:**
- `skills/pass-the-parcel/SKILL.md` — added `PHASE_4_REVISION` lifecycle state + deterministic Gate C rejection loop; Phase 5 → Spec & Logic Audit; Phase 7 → single-pass direct-to-disk + execution isolation; canonical Model Registry (mimo-2.5 / v4-flash-max / deepseek-v4-flash)
- `skills/ptp-grumpy-architect/SKILL.md` — reframed as Spec & Logic Audit (no code-level scans); added file boundary collisions, dependency gaps, YAGNI bloat, performance trade-offs, cross-view parity
- `skills/ptp-code-surgeon/SKILL.md` — Directive 1: Single-Pass Direct-to-Disk Execution; execution isolation note
- `skills/ptp-high-visionary/SKILL.md` — Directive 0: Revision Loop Protocol (`PHASE_4_REVISION` fix rounds)
- `.opencode/agents/parcel-orchestrator.md`, `parcel-grumpy-architect.md`, `parcel-code-surgeon.md`, `parcel-high-visionary.md`, `parcel-smooth-operator.md` — Spec & Logic Audit + revision loop + direct-to-disk directives
- `.opencode/plans/base-context.md` — revision loop added to lifecycle
- `docs/plans/template-plan.md`, `skills/pass-the-parcel/references/template-plan.md` — Phase 5 spec-audit findings rows, Gate C PASS/FAIL, Phase 7 direct-to-disk constraints
- `HOW-TO.md` — Spec & Logic Audit + deterministic rejection loop + execution isolation documented
- `opencode.json` — descriptions updated (Spec & Logic Audit, direct-to-disk, PHASE_4_REVISION)
- `AGENTS.md` — cross-view §9 → §11 pointer
- `docs/wiki/core/18-knowledge-capture.md` — updated decision record with new directives + canonical model identifiers

**Database/API Changes:** None

**Summary:** Hardened the parcel pipeline: Phase 5 (Grumpy Architect) is now strictly a Spec & Logic Audit of the text-based Phase 4 architecture — no code-level scans since the plan contains no code. Added a deterministic rejection loop at Gate C (`PHASE_4_REVISION` → return to Group B → re-review) so unapproved plans never cascade to execution. Phase 7 (Code Surgeon) now enforces single-pass direct-to-disk execution — no intermediate Markdown code blocks — and triggers only after explicit user sign-off. Standardized the model registry to canonical identifiers (mimo-2.5, v4-flash-max, deepseek-v4-flash).

---

<!-- New entries go above this line, most recent first -->
