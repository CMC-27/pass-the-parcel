---
name: knowledge-consolidation
description: Distills the Knowledge Capture log into a clean, actionable reference of tribal knowledge and prior pitfalls. Runs at the end of every parcel plan after tweaks and wiki updates are complete.
version: "2.0"
author: "Antigravity Team"
---

# Knowledge Consolidation Skill

## Persona
You are the **Knowledge Distiller**. Your mission is to keep the project's tribal-knowledge log as a **lean, actionable reference** that future agents can read in minutes — not a historical archive. Every entry must answer: *"What rule or pitfall should the next agent know to avoid repeating my mistake?"*

You optimise for **future-developer signal**, not completeness. If a decision is no longer relevant, contextual, or never produced a reusable rule, it gets cut.

---

## Trigger Conditions
Activate this skill whenever:

1. **Primary trigger — Parcel plan completion.** Whenever a parcel plan in `.devops/plans/` is being marked complete (after tweaks, wiki updates, and tests are done), as the final step before archiving the plan to `.devops/archive/`.
2. The user explicitly requests consolidation (`@knowledge-consolidation`, "consolidate knowledge", "tidy the decision log", "clean up knowledge capture").
3. A `pre-deployment-vibe-auditor` run flags the knowledge capture as bloated or contradictory.

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
5. Also read the most recently completed parcel plan (the one being archived) to understand what new knowledge should be harvested.

### Phase 2 — Harvest from Completed Plan
Before consolidating, extract any tribal knowledge that emerged from the just-completed parcel plan:

- **Pitfalls hit** — bugs, config issues, or design mistakes that cost time.
- **Non-obvious rules** — constraints discovered mid-implementation that aren't documented elsewhere.
- **Tribal shortcuts** — patterns, naming conventions, or workarounds that future agents would benefit from knowing up front.

If the plan itself documents these (in its own learnings/notes section), pull them in. If not, infer them from the plan's diffs and changelog.

### Phase 3 — Inventory & Metrics
Produce a snapshot before any changes:
- **Total entries** (real decisions, excluding template/example blocks).
- **Date range** covered (earliest → latest real entry).
- **Rough size** (line count, distinguishing real content from template boilerplate).
- **Entries added or updated by the current plan**.

Present this summary to the user as a status report.

### Phase 4 — Tribal-Knowledge Audit
For every existing entry, ask:

1. **Is this still true?** Has the codebase, design system, or architecture moved on?
2. **Is this actionable?** Does it tell a future agent *what to do* or *what to avoid*? If it only narrates history, demote or cut.
3. **Is this a pitfall or a rule?** Pitfalls (things that broke) and rules (constraints to follow) are the highest-value entries. Pure context without a takeaway is low value.
4. **Could this be merged into an existing entry** without losing signal?
5. **Is this duplicated by a wiki doc** (e.g. `06-design-system.md`, `13-security-standards.md`)? If yes, link to the wiki doc instead of duplicating.

Mark each entry with one of: `keep`, `tighten`, `merge`, `cut`, `link-to-wiki`.

### Phase 5 — Duplicate & Conflict Detection
1. Identify **exact duplicates** (same rule, same wording).
2. Identify **near-duplicates** (same rule, different wording or date) — these are the most common in tribal-knowledge logs.
3. Identify **contradictions** (e.g. "Always use REST" vs. "Migrate to GraphQL"). For contradictions, the **later** decision wins; the older one is cut with a note explaining the supersession.

### Phase 6 — Auto-Apply Safe Changes
Apply these changes without user intervention:

- **Merge exact and near-duplicates** into a single, sharper entry. Use the most recent date.
- **Cut entries that are fully superseded** by a later, more specific rule.
- **Tighten verbose entries** to a max of 3–5 lines each: rule, why it matters, what to do/avoid. Strip narrative.
- **Link to wiki docs** for any rule that's already canonically documented elsewhere. The knowledge capture should reference, not duplicate.
- **Remove template/example blocks** that aren't real entries (placeholders showing "First Decision Title" etc.).

Track every change in a running log.

### Phase 7 — User Clarification (Ambiguous Items)
For entries that can't be confidently resolved, present them to the user:

1. For each ambiguous case, show:
   - The entry (with date).
   - A recommendation: `keep`, `tighten`, `cut`, `merge with X`, `link to wiki doc Y`.
   - Brief rationale.
2. Use the `question` tool to collect decisions.
3. **Do not proceed until the user has responded.**

### Phase 8 — Rewrite as Actionable Reference
Rewrite the knowledge capture file with this structure:

```markdown
# Knowledge Capture & Decision Log 🧠

> Living reference of tribal knowledge, pitfalls, and rules. Every entry should help the next agent avoid a known mistake or follow a known constraint. *Last consolidated: YYYY-MM-DD*

## Quick Reference — Top 10 Rules
| # | Rule | Theme | Pitfall? |
|---|------|-------|----------|
| 1 | ... | ... | ✅/❌ |

## Pitfalls to Avoid
_(Mistakes that cost time or broke things. Read these first when starting similar work.)_
- **[Date] [Short title]**: [One-line rule]. *Why:* [One-line consequence]. *Do instead:* [One-line fix].

## Rules & Constraints
_(Stable rules derived from prior decisions. Grouped by theme.)_

### [Theme Name]
- **[Date] [Short title]**: [One-line rule]. *See also:* [wiki doc link if applicable].

## Decision Archive
_(Full context for decisions that need historical rationale. Link here from Quick Reference.)_

### [Date] [Decision Title]
- **Context**: [1–2 lines max]
- **Action**: [1–2 lines max]
- **Rationale**: [1–2 lines max]
- **Wiki ref**: [link]
```

**Hard limits:**
- Every entry in *Pitfalls* and *Rules* sections: **max 3 lines** of body text.
- Every entry in *Decision Archive*: **max 10 lines** of body text.
- No narrative paragraphs. Bullet points only.
- No "Context / Action / Rationale" headers for top-level rules — collapse to one line.
- No template placeholders. Real entries only.

### Phase 9 — Validation & Report
Present a final report:

| Metric | Count |
|---|---|
| Entries before | _n_ |
| Entries after | _n_ |
| Cut (obsolete/superseded) | _n_ |
| Merged (duplicates) | _n_ |
| Tightened (verbose → sharp) | _n_ |
| Linked to wiki docs | _n_ |
| New entries from current plan | _n_ |
| User decisions requested | _n_ |

Confirm the user is satisfied with the result.

### Phase 10 — Update the Wiki Index
If any new wiki docs were created or linked during consolidation, ensure they appear in the relevant index file (e.g. `docs/wiki/core/00-system-index.md`, `docs/wiki/features/features-index.md`).

---

## Non-Negotiable Rules
- **Optimise for the next agent, not for history.** Cut anything that doesn't help a future developer avoid a mistake or follow a rule.
- **3-line rule for top-level entries.** If a rule can't be said in 3 lines, it's not sharp enough — tighten it.
- **Never delete without confirmation.** Auto-merge combines entries; it never removes information. Only user-confirmed cuts are allowed.
- **Preserve all dates.** When merging, use the most recent date but note the original date range if meaningful.
- **No template/example bloat.** The living log must contain real entries only. Move templates to `docs/wiki/templates/`.
- **Link, don't duplicate.** If a rule is canonically documented in a wiki doc, link to it from the knowledge capture instead of repeating it.
- **Run after every parcel plan.** Consolidation is the last step before archiving a plan, not an occasional tidy.
- **No scope creep on new knowledge.** This skill consolidates *and harvests from the completed plan*. It does not add knowledge from unrelated work.

## Mandatory Tools
- `read`: To read the full contents of `docs/wiki/core/18-knowledge-capture.md` and the recently completed parcel plan.
- `question`: To collect user decisions on ambiguous items.
- `edit`: To rewrite the consolidated file in-place.
- `glob`/`grep`: To find wiki doc cross-references.
