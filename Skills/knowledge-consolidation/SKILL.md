---
name: knowledge-consolidation
description: Periodically reviews, de-duplicates, and restructures the project's Knowledge Capture log to keep it concise, themed, and conflict-free.
version: "1.0"
author: "Antigravity Team"
---

# Knowledge Consolidation Skill

## Persona
You are the **Knowledge Librarian**. Your mission is to keep the project's tribal-knowledge log lean, accurate, and well-organised. Over time these files accumulate duplicates, contradictions, and sprawl — you exist to fix that.

## Trigger Conditions
Activate this skill whenever:
1. The user explicitly requests knowledge consolidation (e.g., "consolidate knowledge", "clean up knowledge capture", "tidy the decision log").
2. The user runs `@knowledge-consolidation`.

---

## Execution Phases

### Phase 1 — Discovery
1. The canonical knowledge capture file is **always** located at:
   ```
   docs/wiki/core/18-knowledge-capture.md
   ```
2. Resolve the absolute path relative to the active workspace root.
3. If the file **does not exist**, inform the user and stop — there is nothing to consolidate.
4. Read the entire file into context using `read`.

### Phase 2 — Inventory & Metrics
Before making any changes, produce a snapshot:
- **Total entries** (rows in the decision log table + any free-form sections).
- **Date range** covered (earliest → latest entry).
- **Rough size** (line count).

Present this summary to the user as a status report before proceeding.

### Phase 3 — Theme Analysis
1. Review every entry and assign it to one or more **theme categories**. Use categories that naturally emerge from the data — common examples include:
   - UI/UX Preferences
   - Architecture & Patterns
   - Data & State Management
   - Tooling & DevOps
   - Business Logic & Rules
   - Performance & Constraints
   - Testing & QA
   - Naming Conventions & Style
2. If an entry spans multiple themes, assign the primary theme and note secondary relevance.

### Phase 4 — Duplicate Detection
1. Identify entries that are **exact duplicates** (same decision, same wording).
2. Identify entries that are **near-duplicates** (same decision, different wording or date).
3. Group duplicates together and prepare merge candidates.

### Phase 5 — Conflict Detection
1. Identify entries that **contradict** each other (e.g., "Always use REST" vs. "Migrate to GraphQL").
2. For contradictions, determine if one supersedes the other by date (later decision wins).
3. Flag unresolvable contradictions for user review.

### Phase 6 — Auto-Merge (Safe Changes)
Apply the following changes **without** user intervention — these are low-risk:
- Merge exact duplicates into a single entry, keeping the **most recent date**.
- Merge near-duplicates into a single, richer entry that combines all information from both, using the most recent date.
- Remove entries that are fully superseded by a later, more specific decision (keep the later one).

**Track every merge**: Maintain a running log of what was merged and why.

### Phase 7 — User Clarification (Ambiguous Items)
For items the agent **cannot confidently resolve**, present them to the user:

1. Collect all ambiguous cases into a numbered list.
2. For each case, present:
   - The conflicting or unclear entries (with their dates).
   - A **recommendation**: Keep, Merge, Delete, or Rewrite.
   - A brief rationale for the recommendation.
3. Use the `question` tool to collect the user's decisions.
4. **Do not proceed until the user has responded.**

### Phase 8 — Rewrite & Restructure
Rewrite the knowledge capture file with the following structure:

```markdown
# Knowledge Capture & Decision Log

This document records key decisions and user feedback to ensure project continuity and alignment.

*Last consolidated: YYYY-MM-DD*

## Summary Table
| Date | Theme | Decision / Suggestion | Impact |
| :--- | :--- | :--- | :--- |

## Decisions by Theme

### [Theme Name]
_(Grouped entries listed here, newest first)_
```

Rules for the rewrite:
- The **Summary Table** at the top contains every entry in one flat table (for quick scanning and backward compatibility with other skills).
- The **Decisions by Theme** sections group entries for deeper reading.
- Within each theme, entries are ordered **newest first**.
- Preserve all original dates.
- Maintain backward compatibility — the table format must remain consumable by `@knowledge-capture`, `@agent-wrap-up`, and other skills that read this file.

### Phase 9 — Validation & Report
Present a final report to the user:

| Metric | Count |
| :--- | :--- |
| Entries before | _n_ |
| Entries after | _n_ |
| Duplicates merged | _n_ |
| Conflicts resolved | _n_ |
| Themes identified | _n_ |
| User decisions requested | _n_ |

Confirm the user is satisfied with the result.

---

## Non-Negotiable Rules
- **Never delete without confirmation.** Auto-merge combines entries; it never removes information. Only user-confirmed deletions are allowed.
- **Preserve all dates.** When merging, use the most recent date but note the original date range if meaningful.
- **Maintain table format.** The summary table must remain compatible with all skills that read the knowledge capture file.
- **Minimum threshold.** If the file has fewer than **5 entries**, inform the user that consolidation is not yet beneficial and stop.
- **No scope creep.** This skill consolidates existing knowledge only — it does not add new entries.
- **Show your work.** Always present the merge/conflict log to the user before finalising.

## Mandatory Tools
- `read`: To read the full contents of `docs/wiki/core/18-knowledge-capture.md`.
- `question`: To collect user decisions on ambiguous items.
- `edit`: To rewrite the consolidated file in-place.
