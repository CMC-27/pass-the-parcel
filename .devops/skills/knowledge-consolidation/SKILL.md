---
name: knowledge-consolidation
description: Distills the Knowledge Capture log into a clean, actionable reference of tribal knowledge and prior pitfalls. Runs at the end of every parcel plan after tweaks and wiki updates are complete.
version: 2
updated: 2026-09-09
---

# Knowledge Consolidation Skill

## Persona
You are the **Knowledge Distiller**. Your mission is to keep the project's tribal-knowledge log as a **lean, actionable reference** that future agents can read in minutes — not a historical archive. Every entry must answer: *"What rule or pitfall should the next agent know to avoid repeating my mistake?"*

You optimise for **future-developer signal**, not completeness. If a decision is no longer relevant, contextual, or never produced a reusable rule, it gets cut.

---

## Tribal vs. Canonical Distinction

Every entry in the knowledge capture sits on a spectrum. Classification drives the consolidation action:

| Attribute | Tribal (stay in KC) | Borderline (Phase 8) | Canonical (promote to wiki) |
|---|---|---|---|
| **Stability** | May change after a refactor; specific to a plan | Stable for now, uncertain long-term | Survived 2+ plans; defines how things work |
| **Scope** | One plan, one feature, one bug | Crosses 2+ areas | Cross-cutting; every agent needs this |
| **Form** | "X broke because Y — don't repeat" | "We chose X over Y because..." | "Always do X. Never do Y." |
| **Wiki home** | None — too specific | Could fit under existing § | Clear natural home in core/conventions |
| **Example** | "`activeAssemblyIdRef` ref-mutation is a safety pattern, not a smell" | "Container 'on' token architecture" | "Every form field needs `id` + `htmlFor`" |

**The promotion test:** If the rule is stable and repeatable enough that an agent would find it by reading the wiki first, it belongs in the wiki — and gets **deleted from KC entirely**. KC never holds pointers or summaries of wiki content: agents read the wiki before KC, so a pointer duplicates a lookup they already do. What survives in KC is only what the wiki cannot hold: one-off edge cases with future practical use, gotchas that cost time, and constraints not derivable from reading the code.

**Repetition is a promotion signal:** When the same rule appears under different dates from different plans, the wiki is missing it. Frequency trumps the individual stability heuristic — those entries should be promoted, not just deduplicated inside KC.

---

## Modes

| Mode | When | What runs |
|---|---|---|
| **Tidy (default)** | After every parcel plan — the final step of `agent-wrap-up` Phase 7 | Phase 2 (harvest) + Phase 3 (metrics) + enforcement of line limits, dedupe, placeholder/header removal, supersession cuts, encoding repair — via **surgical edits only** (Phase 7 restricted to entries touched or added this session; never a whole-file rewrite) + Phase 10 (light counts report) |
| **Full audit (explicit only)** | Fires when: the user requests it, a `pre-deployment-vibe-auditor` run flags KC as bloated/contradictory, **or the KC file exceeds 200 lines** | All Phases 3–11, including the Tribal-Knowledge Audit (Phase 4), conflicts (Phase 5), wiki promotions (Phase 6), user clarification (Phase 8), and the full Phase 9 rewrite |

**Never run the full audit as a silent side effect of plan completion** — it rewrites the file (cache churn + wiki-lint churn) and can request user clarification mid-wrap-up. Tidy mode must keep the file well under the **hard 500-line ceiling**; if a tidy run leaves the file above 200 lines, say so and recommend a full audit.

## Trigger Conditions
Activate this skill whenever:

1. **Primary trigger — Parcel plan completion (tidy mode).** Whenever a parcel plan in `.devops/plans/` is being marked complete (after tweaks, wiki updates, and tests are done), as the final step before archiving the plan to `.devops/archive/`.
2. The user explicitly requests consolidation (tidy if they say "tidy the log", full audit if they say "consolidate/clean up knowledge capture").
3. A `pre-deployment-vibe-auditor` run flags the knowledge capture as bloated or contradictory (full audit).

---

## Execution Phases

### Phase 1 — Discovery
1. The canonical knowledge capture file is **always** located at:
   ```
   .wiki/core/18-knowledge-capture.md
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
- **Rough size** (line count, distinguishing real content from template boilerplate).
- **Entries added or updated by the current plan**.

Present this summary to the user as a status report.

### Phase 4 — Tribal-Knowledge Audit
For every existing entry, ask:

1. **Is this still true?** Has the codebase, design system, or architecture moved on?
2. **Is this actionable?** Does it tell a future agent *what to do* or *what to avoid*? If it only narrates history, demote or cut.
3. **Is this a pitfall or a rule?** Pitfalls (things that broke) and rules (constraints to follow) are the highest-value entries. Pure context without a takeaway is low value.
4. **Could this be merged into an existing entry** without losing signal?
5. **Is this duplicated by a wiki doc** (e.g. `09-design-system.md`, `12-security-standards.md`)? If yes, mark `cut-duplicate` — delete the KC entry outright. No pointers, no summaries: agents read the wiki before KC, so any wiki-covered content in KC is dead weight.
6. **Should this be promoted to a wiki doc?** Apply the Tribal vs. Canonical test:
   - Is the rule stable (survived 2+ plans or appears repeatedly)?
   - Is it cross-cutting (relevant beyond the original context)?
   - Can it be stated as an imperative ("Always/never do X")?
   - Does a clear wiki home exist (core doc §, conventions doc, feature doc)?
   If 3/4 are yes, mark `promote`.

Mark each entry with one of: `keep`, `tighten`, `merge`, `cut`, `cut-duplicate`, `promote`.

### Phase 5 — Duplicate & Conflict Detection
1. Identify **exact duplicates** (same rule, same wording).
2. Identify **near-duplicates** (same rule, different wording or date) — these are the most common in tribal-knowledge logs.
3. Identify **contradictions** (e.g. "Always use REST" vs. "Migrate to GraphQL"). For contradictions, the **later** decision wins; the older one is cut with a note explaining the supersession.
4. **Frequency → Promotion signal.** When 2+ entries express the same rule from different plans or dates, that repetition is evidence of stability. Override the individual Phase 4 Q6 heuristic and mark them `promote`. Collapse into a single canonical wiki entry, not just a merged KC entry.

### Phase 6 — Promotion to Wiki

For every entry marked `promote`, determine its natural wiki home and execute the promotion:

1. **Identify destination**: Scan wiki core docs (`09-design-system.md`, `05-core-architecture.md`, etc.), conventions docs (`conv-*.md`), and feature docs for the best home. Match by theme, not by title — e.g., an entry about `text-primary-on` tokens belongs in `09-design-system.md §2`, not a new doc.

2. **Create or update the wiki doc** — follow the `@wiki-writer` skill for all wiki prose: read the full target doc first, integrate the rule at its semantically correct section (never append), and rebalance the surrounding section so it reads as if written at once.
   - If a natural home exists (a § within an existing doc), insert the entry's actionable rule at the relevant section. Use the wiki doc's existing format — don't force the KC format into it.
   - If no natural home exists and the entry warrants a new doc, create it. Add a cross-reference in the relevant index file (see Phase 11).

3. **Delete from KC**: Remove the entry entirely — promoted knowledge has no residual in KC, not even a pointer. The wiki is the single home for canonical rules; KC holds only what the wiki cannot.

4. **Track promotions**: Maintain a running list of promotions for the Phase 10 report.

### Phase 7 — Auto-Apply Safe Changes
Apply these changes without user intervention:

- **Merge exact and near-duplicates** into a single, sharper entry.
- **Cut entries that are fully superseded** by a later, more specific rule.
- **Tighten verbose entries** to a max of 3 lines each: rule, why it matters, what to do/avoid. Strip narrative. Entries must be deterministic — state the constraint, not the discussion that produced it.
- **Cut wiki-duplicated entries** (`cut-duplicate`) outright — no pointers, no summaries. Verify the wiki actually covers the rule first; if it doesn't, promote instead.
- **Promote entries** marked `promote`: extract the actionable rule to the target wiki doc via the `@wiki-writer` discipline (integrate + rebalance, never append), then delete the KC entry per Phase 6 step 3. If the wiki update is non-trivial (new section, new doc, structural re-org), flag it via Phase 8 instead of auto-applying.
- **Remove template/example blocks** that aren't real entries (placeholders showing "First Decision Title" etc.).

Track every change in a running log.

### Phase 8 — User Clarification (Ambiguous Items)
For entries that can't be confidently resolved, present them to the user:

1. For each ambiguous case, show:
   - The entry (with date).
   - A recommendation: `keep`, `tighten`, `cut`, `merge with X`, `link to wiki doc Y`, `promote to wiki doc Z`.
   - Brief rationale.
2. Use the `question` tool to collect decisions.
3. **Do not proceed until the user has responded.**

### Phase 9 — Rewrite as Actionable Reference
Rewrite the knowledge capture file with this structure:

```markdown
# Knowledge Capture & Decision Log 🧠

> Living reference of tribal knowledge, pitfalls, and rules. Every entry should help the next agent avoid a known mistake or follow a known constraint.

## Quick Reference — Top 10 Rules
| # | Rule | Theme | Pitfall? |
|---|------|-------|----------|
| 1 | ... | ... | ✅/❌ |

## Pitfalls to Avoid
_(Mistakes that cost time or broke things. Read these first when starting similar work.)_
- **[Date] [Short title]**: [One-line rule]. *Why:* [One-line consequence]. *Do instead:* [One-line fix].

## Rules & Constraints
_(Edge-case constraints with future practical use, not derivable from the wiki or the code. Grouped by theme.)_

### [Theme Name]
- **[Date] [Short title]**: [One-line rule].

## Decision Archive
_(Only decisions whose full story prevents a specific repeat mistake. Most recent 5 max.)_

### [Date] [Decision Title]
- **Context**: [1–2 lines max]
- **Action**: [1–2 lines max]
- **Rationale**: [1–2 lines max]
```

**Hard limits:**
- **Whole file: max 500 lines.** A tidy run that cannot bring the file under 200 lines recommends a full audit; anything over 500 is a consolidation failure, not a warning.
- Every entry in *Pitfalls* and *Rules* sections: **max 3 lines** of body text.
- Every entry in *Decision Archive*: **max 10 lines** of body text, **max 5 archive entries** (oldest cut first).
- No narrative paragraphs. Bullet points only.
- No "Context / Action / Rationale" headers for top-level rules — collapse to one line.
- No template placeholders. Real entries only.
- **No wiki pointers.** If the wiki covers it, the KC entry is deleted.

### Phase 10 — Validation & Report
Present a final report:

| Metric | Count |
|---|---|
| Entries before | _n_ |
| Entries after | _n_ |
| Cut (obsolete/superseded) | _n_ |
| Merged (duplicates) | _n_ |
| Tightened (verbose → sharp) | _n_ |
| Cut as wiki-duplicates | _n_ |
| Promoted to wiki docs (entry deleted from KC) | _n_ |
| File line count after | _n_ / 500 cap |
| New entries from current plan | _n_ |
| User decisions requested | _n_ |

Confirm the user is satisfied with the result.

### Phase 11 — Update the Wiki Index

If any new wiki docs were created, OR existing docs were updated during promotion, ensure they appear in the relevant index file (e.g. `.wiki/core/00-system-index.md`, `.wiki/features/features-index.md`). For promotion updates to existing docs, scan the doc's table of contents to verify the new section is discoverable.

---

## Non-Negotiable Rules
- **Optimise for the next agent, not for history.** Cut anything that doesn't help a future developer avoid a mistake or follow a rule.
- **3-line rule for top-level entries.** If a rule can't be said in 3 lines, it's not sharp enough — tighten it.
- **Never delete tribal knowledge without confirmation.** Auto-merge combines entries; it never removes information. User-confirmed cuts and `cut-duplicate` (wiki verifiably covers the rule) are the only deletions allowed without asking.
- **No template/example bloat.** The living log must contain real entries only. Move templates to `.wiki/templates/`.
- **Zero wiki duplication — zero pointers.** Agents read the wiki before KC, so a pointer or summary in KC is dead weight. If the wiki covers a rule, delete the KC entry. If the wiki *should* cover it but doesn't, promote the rule into the wiki, then delete the KC entry.
- **Proactive promotion.** If a stable, cross-cutting pattern lives only in KC, it's a knowledge silo. Promote it to the wiki and delete it from KC. An entry that never graduates is a signal that either (a) it's not stable enough to be a rule, or (b) consolidation left a silo.
- **Repetition is a promotion signal, not just a dedup signal.** If the same rule appears under different dates from different plans, promote it to a single canonical wiki entry and delete all KC copies.
- **Deterministic entries only.** State the constraint or the fix, not the discussion. An entry is too vague to act on if it needs more than 3 lines to be executable.
- **Run after every parcel plan.** Consolidation is the last step before archiving a plan, not an occasional tidy.
- **No scope creep on new knowledge.** This skill consolidates *and harvests from the completed plan*. It does not add knowledge from unrelated work.

## Mandatory Tools
- `read`: To read the full contents of `.wiki/core/18-knowledge-capture.md` and the recently completed parcel plan.
- `question`: To collect user decisions on ambiguous items.
- `edit`: To rewrite the consolidated file in-place.
- `glob`/`grep`: To find wiki doc cross-references.
