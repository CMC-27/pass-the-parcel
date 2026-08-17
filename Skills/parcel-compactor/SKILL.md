---
name: parcel-compactor
description: Strips intermediate debate, resolved critiques, and redundant commentary from a merged parcel plan (v1.1_merged.md), outputting a lean, noise-free execution specification (v2.0_approved.md) for the blind executor.
---

# SKILL: Parcel Compactor (`parcel-compactor`)

## Philosophy
Planning produces noise. Reviewers debate. Answers get revised. By the time a plan reaches execution, the signal-to-noise ratio is degraded — the executor must wade through rejected proposals, resolved critiques, and intermediate reasoning to find the actual directives. This causes stale instruction contamination (attention attends heavily to early tokens, which may contain obsolete proposals).

Your job is noise removal. You strip everything that is not an executable directive. You produce a clean, immutable specification that a stateless executor can follow without interpretation.

---

## Activation & Role Mapping
This skill owns the compaction step between Phase 6 (Reviews) and Phase 7 (Execution) of the `pass-the-parcel` pipeline. It runs once after all reviews are merged into `v1.1_merged.md`.

---

## Core Operational Directives

### 1. Input & Output
- **Read:** `.opencode/plans/run-[slug]/versions/v1.1_merged.md` (provided by orchestrator)
- **Write:** `.opencode/plans/run-[slug]/versions/v2.0_approved.md`
- **Log:** Append compaction event to `.opencode/plans/run-[slug]/decision_log.md`

### 2. Strip Rules (What to Remove)
Remove entirely:
- All `[ ]` and `[x]` checkbox lists (Phase 2 inventory, Phase 3 questions, Phase 5-6 findings)
- All Phase 5 and Phase 6 review sections (product review + architect review) — findings are merged into directives, not kept as commentary
- All debate/conversation text, resolved critiques, intermediate reasoning
- All `Auto-Resolution:` rationale paragraphs (keep the final answer, strip the rationale)
- All `🕵️ Phase 3.5 Research Map` tables
- All `Spaghetti Triage` tables
- All `Back-and-Forth Log` entries from Phase 9
- All `🛑 HALT POINT` gate markers
- Any section labeled `PENDING`, `REJECTED`, or `BLOCKER` that was resolved

### 3. Keep Rules (What to Preserve)
Preserve verbatim:
- Phase 1: Intent, In-Scope, Out-of-Scope
- Phase 3: Final answers (user responses or auto-resolutions — just the answer, not rationale)
- Phase 4: Files to Create/Modify, Implementation Instructions, To-Do List, Test Verification Plan
- State Dashboard (summary only — Status, Mode, Version)
- The plan prefix code (e.g., `T12-E1.01`)

### 4. Output Format
Output a clean markdown file with this structure:
```markdown
# 📦 [Plan Name] v2.0 [APPROVED]

> **Execution target for @parcel-code-surgeon. No debate — directives only.**

## Intent
[Phase 1 intent, 1-2 lines]

## In Scope / Out of Scope
[Phase 1 scope lists]

## Execution Directives
[Phase 4: Files to Create/Modify table + Implementation Instructions]

## To-Do List
[Phase 4 to-do list, cleaned of checkboxes]

## Test Verification Plan
[Phase 4 test plan]

## Decisions
[Phase 3 final answers only — no rationale]
```

### 5. Fail-Safe
If the merged plan has no Phase 4 section or the to-do list is empty, write an error to `decision_log.md` and halt. Do not produce an empty execution spec.

---

## Output Contract

Return a Task report with:
- Token count: v1.1 (input) vs v2.0 (output)
- Reduction percentage
- Any directives that were ambiguous and preserved as-is
- 1-line "ready for execution" signal
