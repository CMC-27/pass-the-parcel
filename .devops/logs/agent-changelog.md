---
type: "core"
name: "Agent Changelog"
status: "stable"
description: "Chronological record of all AI agent actions, changes, and audits."
---

# Agent Changelog

All changes made by AI agents are tracked chronologically below.

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

---

