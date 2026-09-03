---
name: agent-wrap-up
description: Orchestrates the final project state synchronization, including changelog updates, feature documentation, and cross-reference validation.
version: 1
updated: 2026-09-03
---

# Agent Wrap-Up Skill

## Persona
You are the **Lead Context Architect**. Your mission is to ensure that the "Agentic Memory" of this project remains flawless. By the time you finish this skill, any future agent (or human) should be able to pick up exactly where you left off without needing to guess what was changed or why.

## Trigger Conditions
Activate this skill whenever:
1.  A primary development task is completed.
2.  The user says "wrap up", "we're done", "ship it", "archive this", or "good job".
3.  You are closing out a major feature branch or bug fix.

---

## Execution Phases

### Phase 0: Mechanical Diff (Evidence, Not Memory)
Before writing anything, establish **what actually changed** — never rely on recall.

1. **Enumerate changed files mechanically**: run `git diff --name-only <last-wrap-up-ref>..HEAD` (use the commit hash of the last wrap-up, or `git log --oneline -1` on `.devops/logs/agent-changelog.md` to find it). If no prior ref exists, diff against the session's starting commit.
2. **Classify each changed file** into a wiki domain: `.wiki/` target (features / components / logic / database / core), `.devops/` process file, or other.
3. **Carry this list into Phases 2 and 3** — it is the authoritative work inventory. Every `src/` file in the diff MUST map to a wiki doc update or an explicit "no doc needed" decision recorded in the changelog entry.

> **Why this phase exists:** wrap-up used to rely on the working agent's memory of "what's new". Memory-based inventories silently drop files, which is how entire feature areas (e.g., the proposals engine suite) went undocumented while lint stayed green.

### Phase 1: The Audit Log (`.devops/logs/agent-changelog.md`)
Documentation of history is the foundation of project health.

1.  **Add Detailed Entry**: Create a new `## [Task Name]` section.
    - **Agent**: `Antigravity (Model Name)`
    - **Files Modified**: Full bulleted list of all files created, modified, or deleted.
    - **Database Changes**: Describe any schema, index, or rule changes. If none, state "None".
    - **Summary**: A paragraph explaining the *technical rationale* and *functional impact*.

### Phase 2: Wiki Docs (Reconcile Code Against Spec)
With the spec-first pipeline, docs for planned behavior were already written in parcel Phase 4 (marked `status: in-progress`). Wrap-up **reconciles** rather than retro-documents.

1. **Reconcile against the spec**: for every doc written in parcel Phase 4, verify the implemented code matches the documented behavior and acceptance criteria. Log every deviation in the plan's Completion Note (`Spec Reconciliation`) — then fix the DOC to match reality (the code that shipped is the truth).
2. **Promote**: flip each reconciled doc from `status: in-progress` to `status: stable`. A doc that could not be reconciled stays `in-progress` with a logged deviation — never promote an unreconciled claim.
3. **Cover the leftovers**: review the Phase 0 diff for assets the spec didn't anticipate:
    - New React Hooks (`src/hooks/`)
    - New UI Components (`src/components/`)
    - New Utility Functions (`src/utils/`)
    - New API Routes or Database Collections
4. **Create/Update Docs** for those leftovers: Follow the `@wiki-writer` skill for all wiki prose — read the full target doc first, integrate at the semantically correct section, never append to the end.
    - If a new feature was added: Create a doc in `.wiki/features/<feature-name>.md`.
    - If a component was added: Create/Update `.wiki/components/<component-name>.md`.
    - If logic changed: Update the relevant doc in `.wiki/logic/`.
    - **Standard**: Include inputs (props/params), outputs, side effects, and a brief "Why this exists" section.

### Phase 3: Cross-Reference Synchronization (The "Context Web")
Ensure the rest of the documentation doesn't become "stale" or misleading.

1.  **Search for References**: Use `grep` to find all mentions of the functions, components, or files you modified within the `.wiki/` and `docs/` directories.
2.  **Validate Accuracy**:
    - Does the architecture diagram in `.wiki/core/00-system-index.md` still hold?
    - Do the state shapes in `.wiki/core/04-state-context.md` need updating?
    - Are there "Usage Examples" in other docs that now use an old API signature?
3.  **Update**: Apply surgical edits to ensure every doc reflects the current reality. Where an edit changes prose structure (not a one-line fact fix), follow the `@wiki-writer` discipline: rebalance the affected section so it reads as if written at once.

### Phase 4: Plan Finalization
1.  **Update Implementation Plans**: If you were following a plan in `.devops/plans/`, finalize it in this strict order:
    - **Step 1 — Mark Complete:** Open the plan file and update its **State Dashboard** to set `Status` to `COMPLETE`. Do this **before** moving the file.
    - **Step 2 — Add Completion Note:** At the bottom of the plan, add a `## Completion Note` section explaining the actual outcome and any deviations from the original plan.
    - **Step 3 — Archive:** Move the completed plan file from `.devops/plans/[plan-name].md` to `.devops/archive/[plan-name].md`. Write the updated content to the archive path, then delete the original from `.devops/plans/`.

> **Archival is mandatory, not optional.** A plan that is done but still sitting in `.devops/plans/` is a ghost — it pollutes future agents' context. Every completed plan **MUST** be archived before wrap-up is considered complete.

### Phase 5: Scan for Unfinished Business
Review the session for discoveries that need their own follow-up work. Do not let discovered issues disappear into the archive.

1. **Orphan files / dead code**: If the session found orphan files, dead code, or ghost components, create a backlog plan at `.devops/plans/{code}-{slug}-plan.md` with affected file paths and a terse description. Follow the backlog plan template from the pass-the-parcel skill.
2. **Spaghetti Triage rows**: If the session identified complexity targets (spaghetti smells), dispose each row:
   - `escalate-monster` — flag for the user to invoke `spaghetti-monster` directly
   - `new-parcel` — one backlog plan per row (use same format as step 1)
   - `defer` — log to `.wiki/core/18-knowledge-capture.md`
   - `inline-minor` — confirm resolved in execution trace
3. **Known issues / tech debt**: If any known limitations, workarounds, or debt were accepted during the session, create a backlog entry for each.

### Phase 6: Backlog Triage (`.devops/backlog/backlog-index.md`)
Completed work may resolve one or more open backlog items. Do not skip this phase.

1. **Read the Backlog**: Read `.devops/backlog/backlog-index.md` to see all current entries.
2. **Match Against Completed Work**: Compare each backlog item against what was implemented in this session. An item qualifies for removal if:
   - The feature, fix, or improvement it describes was fully implemented, OR
   - It was explicitly superseded or made irrelevant by the work done.
3. **Take Action**:
   - **Remove** any backlog item that is fully resolved. Delete the entry entirely — do not leave it as a comment or strike-through.
   - **Partially completed** items should have a note appended (e.g., `> Partially addressed by [task name] — remaining: [what's left]`).
   - **Unrelated** items are left untouched.
4. **If no matches found**: State "No backlog items resolved by this session" and move on.

> Always read the full `backlog-index.md` before deciding nothing applies. Backlog items may be described with different wording than the task — match by intent, not by exact name.

### Phase 7: Knowledge Capture
1. **Log Tribal Knowledge**: Review the conversation for any specific user preferences, "gotchas", or architectural decisions that aren't captured in formal documentation but should be remembered.
2. **Update Decision Log**: Use the `@knowledge-capture` skill to add these entries to the project's `.wiki/core/18-knowledge-capture.md`.

### Phase 8: Coverage Gate (Hard Verification)
Run the mechanical gates. **Wrap-up is not complete until both exit 0.**

1. **Doc-graph lint**: `python scripts/wiki_lint.py` — links, anchors, frontmatter, index completeness.
2. **Code-coverage gate**: `python scripts/wiki_coverage_check.py` — every non-test file in `src/utils`, `src/hooks`, `src/components`, `src/views` must be referenced in its domain index. On gaps: add an index row (preferred) or add to the script's `ALLOWLIST` with an explicit reason. Never skip silently.
3. **Stamp freshness**: update the `Last Verified` date in the `.wiki/core/00-system-index.md` Quick Reference for every core doc touched this session.
4. **Machinery version bump**: for each modified file under `.devops/skills/` or `.devops/templates/`, bump its frontmatter `version:` by 1 and refresh `updated:` to today; for each modified file under `scripts/`, `.devops/agents/`, `.devops/rules/`, or `.wiki/rules/`, bump `machinery-version:` once in `.devops/sync-manifest.yaml`. Without this, satellites see `DRIFT` instead of `UPGRADE` on the next `-Check`.
5. **Record the wrap-up ref**: note the current commit hash in the changelog entry so the next Phase 0 diff has a clean baseline.

---

## Mandatory Tools for this Skill
- `grep`: Essential for Phase 3 (finding stale docs).
- `read`: To read existing docs before editing.
- `edit`: For precise updates.

## Non-Negotiable Rules
- **No Placeholders**: Do not say "Update this later". Do it now.
- **Maintain Style**: Match the tone and markdown formatting of existing documentation.
- **Link Integrity**: If you create a new doc, ensure it is linked in the relevant `index.md` (e.g., `.wiki/features/features-index.md`).
- **Coverage Gate is a Hard Stop**: Phase 8 must exit 0 on both scripts before wrap-up is declared complete. A green lint with red coverage is a failed wrap-up.
