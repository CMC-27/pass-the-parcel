---
type: "core"
name: "Agent Changelog"
status: "stable"
description: "Chronological record of all AI agent actions, changes, and audits."
---

# Agent Changelog

All changes made by AI agents are tracked chronologically below.

---

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

