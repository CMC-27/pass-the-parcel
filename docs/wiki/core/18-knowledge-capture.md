---
type: "core"
name: "Knowledge Capture"
status: "stable"
dependencies: []
db_relations: []
description: "Canonical log of core engineering decisions, tribal knowledge, and architectural strategies."
---

# Knowledge Capture & Decision Log

This document is the canonical, living repository for key architectural decisions, engineering compromises, and critical business rules. It preserves tribal knowledge and design rationales to guide future development.

---

## How to Add an Entry

Each entry should follow this format:

```markdown
## [Category Name]

### [Decision Title]
* **Decision Date**: YYYY-MM-DD
* **Context**: [What was the situation or problem that led to this decision?]
* **Action**: [What was decided and/or implemented?]
* **Rationale**:
    * **[Rationale Point 1]**: [Explanation].
    * **[Rationale Point 2]**: [Explanation].
```

---

## 🚀 Tooling & DevOps

### Parcel Cache-Anchored Template Convention (State & Gates at Bottom)
* **Decision Date:** 2026-08-19
* **Context:** Every parcel plan file's State Dashboard sat at the top. LLM prefix-caching is byte-precise — editing the top rows (`Status` / `Active Persona` / `Last Updated`) at every gate invalidated the entire file's cache, so each stateless downstream agent that re-read the plan paid a full cache miss on the whole document.
* **Action:** Restructured both parcel templates (`.devops/plans/template-plan.md` + `skills/pass-the-parcel/references/template-plan.md`) so the State Dashboard + Gate Log live in the **LAST section** (`## 📍 State & Gates`). A static `🔒 CACHE-ANCHORED` banner sits at the top and is never edited. Gate transitions mutate ONLY the bottom rows (`Status` + `Gate A-D` + `Last Updated`); phase content above stays byte-stable. All agent/skill/command references now say "State & Gates (bottom)". Added `Mode` row; trailing `Status: COMPLETE` folded into the bottom section.
* **Rationale:**
    * **Prefix-cache hits**: unchanged prefix bytes are served from the provider cache on re-reads; only the small mutated tail re-processes.
    * **Byte-stability discipline**: agents are instructed not to edit content above the bottom section once written — the only cache-invalidation risk left is mid-file one-time mutations (e.g., execution checklists in Phases 7-8), which is accepted since they happen once per phase, not at every gate handoff.
    * **Single source of truth**: one bottom section owns Status/Version/Mode/Persona/Last Updated + Gate Log; no duplicate `Status: COMPLETE` rows scattered in Completion Note / Wrap Up.

---

## 🚀 Tooling & DevOps

### Parcel Orchestration Model Assignment Matrix
* **Decision Date:** 2026-08-17
* **Context:** The pass-the-parcel pipeline needed a clearer model-to-phase mapping to match model strengths to task difficulty and reduce token spend on heavy models for lighter roles.
* **Action:** Adopted a fixed model assignment for the parcel pipeline (canonical identifiers: `mimo-2.5`, `v4-flash-max`, `deepseek-v4-flash` — no aliases):
    * **mimo-2.5** — orchestrator + Phases 1-3 (Scoper), Phase 4 (High-Visionary), Phase 6 (Smooth Operator), Phase 10 + Wrap Up.
    * **v4-flash-max** — Phase 5 (Grumpy Architect / Spec & Logic Audit).
    * **deepseek-v4-flash** — Phases 7-8 (Code Surgeon, ponytail coding + single-pass direct-to-disk execution).
    * Phase 4 was trimmed to a standard implementation plan — **no code snippets unless absolutely necessary** — and the persona renamed from "Razor Planner" to **High-Visionary**.
    * Phase order swapped: **Grumpy Architect (Phase 5)** now runs before **Smooth Operator (Phase 6)**.
    * **Phase 5 is a Spec & Logic Audit, not a code review** — the plan contains no code, so it evaluates system contracts, edge cases, file boundary collisions, dependency gaps, YAGNI bloat, performance trade-offs, and architectural anti-patterns.
    * **Deterministic rejection loop at Gate C** — a failing Phase 5/6 review sets `PHASE_4_REVISION` and returns the plan to Group B for fixes; an unapproved plan never advances to execution.
    * **Execution isolation** — Phase 7 (Code Surgeon) triggers only after Gate C is cleared by explicit user input and writes directly to disk, bypassing intermediate Markdown code blocks.
* **Rationale:**
    * **Capability-fit routing**: the heavy review model (`v4-flash-max`) is reserved for the senior architectural audit; the orchestrator model (mimo-2.5) handles the majority of planning/communication/UX work where balanced capability suffices.
    * **Token efficiency**: trimming Phase 4 to standard implementation instructions (no code snippets) shrinks plan size and review surface; code specifics are deferred to the Code Surgeon via ponytail markers.
    * **Review ordering**: architectural hardening (Grumpy, Phase 5) must land before product smoothing (Smooth Operator, Phase 6) so the Smooth Operator cross-checks the already-hardened plan instead of handing off structural concerns forward.
    * **Safety**: the `PHASE_4_REVISION` loop + execution isolation prevent unapproved plans from cascading into code changes.
    * **Consistency**: both `opencode.json` and `.opencode/agents/*.md` must stay in lockstep — they are the same agent definitions in two formats; model identifiers are canonicalized to avoid parser ambiguity.

---

## [First Decision Category — e.g., Data Model]

### [First Decision Title]
* **Decision Date**: YYYY-MM-DD
* **Context**: [Describe the original state].
* **Action**: [Describe what was changed].
* **Rationale**:
    * **[Point 1]**: [Explanation].
    * **[Point 2]**: [Explanation].

---

## [Second Decision Category — e.g., Import / Ingestion]

### [Second Decision Title]
* **Decision Date**: YYYY-MM-DD
* **Context**: [Describe the problem].
* **Action**: [Describe the solution].
* **Rationale**:
    * **[Point 1]**: [Explanation].
    * **[Point 2]**: [Explanation].

---

## [Third Decision Category — e.g., UI/UX Design]

### [Third Decision Title]
* **Decision Date**: YYYY-MM-DD
* **Context**: [Describe the situation].
* **Action**: [Describe the change].
* **Rationale**:
    * **[Point 1]**: [Explanation].
    * **[Point 2]**: [Explanation].

---

## [Fourth Decision Category — e.g., Data Integrity / Locks]

### [Fourth Decision Title]
* **Decision Date**: YYYY-MM-DD
* **Context**: [Describe the problem].
* **Action**: [Describe the implementation].
* **Rationale**:
    * **[Point 1]**: [Explanation].
    * **[Point 2]**: [Explanation].
