---
type: "core"
name: "Agent Changelog"
status: "stable"
description: "Chronological record of all AI agent actions, changes, and audits."
---

# Agent Changelog

All changes made by AI agents are tracked chronologically below.

---

## 2026-09-13 - Parcel-Fast locked preset (machinery 37)

**Why:** The `AUTO` + `SINGLE` combination is the cheap path, but it was reachable only by answering two selection questions at plan start — the orchestrator had to be *told* to run that way, and nothing stopped a `SINGLE` run from spawning a sub-agent. Added a second selectable orchestrator, `parcel-fast`, that carries the combination as a **locked preset**: `Mode=AUTO`, `Agents=SINGLE` (new `## Orchestrator Presets` table in the `ORCHESTRATOR-ONLY` block of `base-context.md`; `parcel`'s row stays `ask`). `parcel-fast` ships a lean agent body (`.devops/agents/parcel-fast.agent.md`, prefix injected by `-Sync`) and `opencode.json` binds it `task: deny`, so `SINGLE` is enforced **structurally** — the model cannot spawn a subagent. Gate A and Gate D still halt; `AUTO` only auto-clears Gates A-C. `check-parcel-prefix.ps1` now locks `parcel*.agent.md` (full prefix for both orchestrators), and `sync-architecture.ps1` hashes their unique content so a satellite-customized prefix never false-reports DRIFT. Docs/seeds mirrored (`parcel.agent.md` steps 2-3, `template-plan.md`, `AGENTS.md`, `.devops/README.md`, `agents-and-skills.md`, `.wiki/rules/naming.md`, `HOW-TO.md`, `pass-the-parcel` v9→v10, `model-routing` v4→v5, `base-context.template.md` v7→v8, `AGENTS.template.md` v8→v9, `opencode.template.json` v4→v5, `SATELLITE-BOOTSTRAP.md`). Prefix PASS ×8 (was ×7); UTF-8 clean. machinery-version 36→37.
**Ref:** working tree (uncommitted; baseline `bfaa9a3`).

---

## 2026-09-13 - Concurrency + sprint lifecycle rewrite (machinery 36)

**Why:** The sprint model assumed one serial executor and a separate `plan.md`/`retro.md` per cycle. Reworked to concurrent, claimed execution with local-only git: a plan is committed into `.devops/sprints/sprint-{n}-<slug>/` (single `sprint.md`, no `retro.md`), claimed via claim front-matter (`code`/`sprint`/`claim_status`/`owner`/`claimed_at`/`last_touch`/`touches`/`depends_on`) + `git mv` into `.devops/plans/` + `git worktree add` on `plan/<code>-<slug>`; completed plans archive to `.devops/archive/` root, and the sprint record moves to `.devops/archive/sprints/`. Backlog detail moved into `t{n}-<slug>-backlog.md` theme registers (front-matter `type` discriminates them from parked `-backlog.md` plans); `backlog-index.md` is now Triage Panel + Themes table. Updated `plan-lifecycle` (rules 4/6 + Claim Protocol), `sprint-plan`/`sprint-status`/`sprint-close`, `pass-the-parcel`, `backlog`, `agent-wrap-up`, `spaghetti-monster`, `build-roadmap`, all seeds (`SPRINTS` + new `sprint`/`AGENTS`/`TRIAGE`/`REFACTORING`/`SATELLITE-BOOTSTRAP`/`base-context`), `base-context.md` (re-inlined ×7, prefix PASS), `parcel.agent.md`, `AGENTS.md`, `.devops/README.md`, `.devops/rules/README.md`, `template-plan.md`, and wiki docs `17-docs-blueprint`/`18-knowledge-capture`/`00-system-index` + the worked example. AGENTS.md claim hashes re-stamped. Re-adopted `.vscode/tasks.json` and dropped its stale `prune_files` entry so `sync-architecture.ps1 -SelfTest` is green. machinery-version 35→36.
**Ref:** `4364a55`.

---

## 2026-09-12 - wiki-writer runs as a subagent on demand (machinery 35)

**Why:** `wiki-writer` was configured `mode: primary`, so only a user could select it and no orchestrator could delegate wiki prose to it via the Task tool. It is now bound `mode: all` in `opencode.json`: it stays selectable, and any primary agent may invoke it as a subagent when required. `parcel`'s `task` allow-list gains `wiki-writer: allow` beside `wiki-verifier`. Mirrored in the seed `opencode.template.json` (v3→v4); agent-surface wording updated in `AGENTS.md`, `.devops/templates/AGENTS.template.md`, `.devops/README.md` and `.devops/rules/agents-and-skills.md`. machinery-version 34→35.
**Ref:** `d43aebc`.

---

## 2026-09-12 - Plan Settings promoted to a frozen header block (machinery 34)

**Why:** Plan-start settings (`Mode`/`Agents`) sat in the cache-anchored BOTTOM `State & Gates` table next to mutable gate state, so resumed sessions and narrowly-prompted subagents sometimes missed them. Split by mutability: `Mode`/`Agents` now sit in a frozen `## ⚙️ Plan Settings` block at the TOP (read before any phase); the bottom holds only mutable state. Moved (not copied) across `template-plan.md`, `base-context.md` (re-inlined ×7, prefix PASS), `parcel.agent.md` steps 2-3, `pass-the-parcel` v7→v8, `plan-lifecycle.md`, `HOW-TO.md`, seed `base-context.template.md` v5→v6, and the KC entry. machinery-version 33→34.
**Ref:** `37c84b7`.

---

## 2026-09-11 - Skill frontmatter validity + CP437 mojibake repair (machinery 33)

**Why:** Pre-commit audit found three latent defects in portable skills. (1) Six skills (`ptp-code-surgeon`, `ptp-context-hunter`, `ptp-grumpy-architect`, `ptp-high-visionary`, `ptp-smooth-operator`, `sprint-close`) had an unquoted `: ` in `description` — invalid strict YAML that opencode's loader tolerates but any real parser rejects; descriptions are now single-quoted. `caveman` was missing `version`/`updated`; added. (2) `app-vision-north-star` and `wiki-assessment` were heavily corrupted with **CP437 mojibake** — UTF-8 bytes misread through code page 437, so every `—`/`–`/emoji appeared as a multi-glyph CP437 misread; repaired by reversing each high-char run through `cp437→utf-8` (app-vision 114 runs; wiki-assessment 48 runs with 2 legitimate `—` preserved). (3) Root cause was a **guard gap**: `check-utf8-agents.ps1` detected only CP1252 mojibake (`C3 A2`, `C3 B0 C2`) and U+FFFD, so both files passed as ALL CLEAN despite the gate scanning 190 files; it now also flags the CP437 lead pairs `CE 93`+`C2`/`C3` and `E2 89 A1 C6 92`. Verified the new pattern flags the pre-repair bytes and the tree is now clean. Skill versions bumped (see v0.7.4); machinery-version 32→33.
**Ref:** working tree (uncommitted; baseline `4b06594`).

---

## 2026-09-11 - PRUNE exit-code honesty in sync -Check (machinery 32)

**Why:** `-Check` emitted a `PRUNE` verdict for a retired file lingering in a satellite but excluded it from the out-of-sync tally, so the documented contract "exit 1 = out of sync" was not driven by PRUNE. Investigation showed the literal tally fix alone was a no-op: every `prune_files` entry lives inside a portable dir, so the extra file also made its parent report `DRIFT` — misleadingly described to users as "locally customized — ask before overwriting" when the file is simply retired — and *that* already forced exit 1, masking the PRUNE nuance. Complete fix: prune files are stripped from the target side of the parent-directory hash comparison (source side untouched so a manifest bug still surfaces as a diff), and `PRUNE` is added to the `$bad` tally. `-SelfTest` gains a negative assertion — a planted prune file must report `PRUNE` + `OUT OF SYNC` with no `DRIFT`, clean again after re-sync — which fails on the pre-fix script. `sync-architecture` SKILL v4→v5; HOW-TO §6 + `.devops/README` pruning note refreshed; machinery-version 31→32.
**Ref:** working tree (uncommitted; baseline `4b06594`).

---

## 2026-09-11 - Wiki-writer pass: core-doc sweep + HOW-TO rebalance

**Why:** Wiki-writer sweep of the core docs and HOW-TO. Fixed real drift (00 dead `#9` anchor + duplicate refs; 12 wrong `AGENT.md` path + prohibited word; 17 restating canonical frontmatter/structure rules) and rebalanced HOW-TO (stale §1 bootstrap corrected to `@wiki-generate` -> `@wiki-bootstrap`, which was contradicting §5 and the v2 skills; §6 split into subsections; appended wiki-evidence paragraph promoted to §7). Added the missing `PRUNE` verdict to `sync-architecture` (v3->v4) — the engine emits it at `sync-architecture.ps1:523`, though `PRUNE` is excluded from the `-Check` out-of-sync count (flagged, not changed).
**Ref:** working tree (uncommitted; baseline `4b06594`). Tree also carries prior-session maturity-register changes (AGENTS/README/.devops/README/backlog-index/09-design-system/`MATURITY.md`) not authored this session.

---

## 2026-09-11 - OKF round-trip parity (v0.7.2)

**Why:** Post-review F4. `wiki_okf.py export` counted 56 "concepts" (any doc with a `type`) while `import` ingested 45 — the 11 `*-index.md` navigation docs were exported but skipped on ingest, so the round-trip was lossy and CI's count read like parity. Export now applies the same `is_fm_exempt_name` predicate as import, and CI asserts `exported concepts == imported`.
**Ref:** working tree (uncommitted; baseline `d4c3400`); machinery-version 30->31.

---

## 2026-09-11 - OKF interop hardening after v0.7.0 review (v0.7.1)

**Why:** Post-review F1/F2/F3/F5. `wiki_okf.py` dropped the local schema's quoting, so export emitted unquoted `title:`/`description:` scalars — a title containing `: ` (Design System, Security Standards, Worked Example) produced YAML no real parser accepts, making the OKF bridge nominally interop. Fixed with a `yaml_scalar` helper (double-quoted, backslash-escaped) applied in both directions. CI's OKF smoke was a file-count check that could not catch it — upgraded to PyYAML-parse every exported frontmatter block. Import into the live wiki now runs `wiki_lint.py` and fails if lint-dirty. Promoted `wiki_lint._fix_unindexed` -> public `fix_unindexed` (removed the private cross-module import).
**Ref:** working tree (uncommitted; baseline `d4c3400`); machinery-version 29->30; re-stamped 7 claims invalidated by the `wiki_lint.py` rename.

---

## 2026-09-11 - Wiki refresh automation: OKF ingest + secret-free CI drift issue (v0.7.0)

**Why:** Closed T2-E2.02 (G3/G5). `wiki_okf.py` gained an `import` mode (OKF v0.2 bundle → local `in-progress` drafts, index-registered, skip-on-collision); a secret-free scheduled `wiki-refresh.yml` raises/closes a `wiki-drift` issue from `wiki_claims.py check`. The docs-PR path was dropped — the portable surface stays secret-free by design. KC gained one pitfall (auto-cataloguer ignores index column semantics) + one Decision Archive entry. `machinery-version` 28→29.
**Ref:** working tree (uncommitted; baseline `d4c3400`); plan `.devops/archive/t2-e2.02-wiki-refresh-automation-plan.md`.

---

## 2026-09-11 - Residual hygiene after T2-E2.01 review (v0.6.1)

**Why:** Post-review residuals R1-R4. `scripts/wiki_claims.py check` misdirected every failure to `update`, which cannot repair an `UNRESOLVED-SYMBOL`/`MISSING`/`BROKEN` claim — now emits a per-class hint. Root `CHANGELOG.md` was one release behind (v0.6.0 absent) and the product↔machinery version tracks were unmapped. T2-E2.02 had a backlog row but no parked plan. Product `v1.0.0` was untagged.
**Ref:** working tree (uncommitted; baseline `d4c3400`); tag `v1.0.0` -> `d4c3400`; `machinery-version` 27->28.

---

## 2026-09-11 - Wiki grounding & guard hardening (v0.6.0)

**Why:** v0.4/v0.5 shipped the claims engine but it had no teeth — the rules index left `claims.md` unlisted (drift the linter could not see), only 4 claims existed so `check` passed trivially, and three guards had holes. Closed G1 (rules-index completeness hard-fail `[UNCATALOGUED]`), G2 (12 grounded claims across core slots 00/09/12/14/17/18), G4 (`UNRESOLVED-SYMBOL` `#symbol` resolution), G6 (`wiki_visualize.py --check` + CI freshness/OKF-smoke steps), G7 (UTF-8 guard now scans root `*.md`/`docs/`/`.github/`). G3/G5 deferred to T2-E2.02; `machinery-version` 26->27.
**Ref:** working tree (uncommitted at wrap-up; baseline `d4c3400`)

---

## 2026-09-11 - Template repo hygiene & onboarding (v1.0.0)

**Why:** The template's flagship asset — the 10-phase parcel pipeline — was invisible from the front door: a 40-line README titled "Application Wiki", no `LICENSE`, no community files, no release surface, no worked example. Added MIT `LICENSE` + `CONTRIBUTING`/`SECURITY`/CoC, a root `CHANGELOG.md` (human-facing releases; `version-history.md` stays the machinery log), `.github` issue/PR templates + `CODEOWNERS` + `release.yml`, a README product-page rewrite (badge, reused pipeline diagram, 5-minute quickstart), and a worked example in `.wiki/examples/`. Two gotchas recorded to KC/changelog: `pull-architecture.ps1 -Verify` exits `2` inside the template (source == target — verify from a satellite), and gitignored run workspaces must be quoted, never linked, from publishable docs. No portable surface changed (`machinery-version` stays 26).
**Ref:** `d873390`

---

## 2026-09-11 - Coverage gate: symbol/claims evidence (v0.5.0)

**Why:** `wiki_coverage_check.py` passed a file on a bare filename-substring mention — a renamed symbol inside an unchanged file was invisible to CI, so the wiki could drift while staying green. Replaced the weak anchor with a four-route evidence OR (filename, parent folder, index-cited exported symbol, `claims: source` binding); symbol discovery is a stdlib regex export scan (documented `ponytail:` ceiling), and coverage now consumes `wiki_claims.py` (single parser owner) via a lazy import after the `src/`-absent no-op guard. Additive — satellites do not regress. Closes the T2-E1.01 Q6 carry-over. `machinery-version: 26`.
**Ref:** `ce7f079`

---

## 2026-09-11 - Wiki self-maintenance: grounded claims + generate/update split (v0.4.0)

**Why:** The wiki was governance-strong but truth-weak — two frontmatter schemas across the corpus, no evidence behind factual claims, no incremental refresh from code changes, no generator, no portable format. Unified the schema (`format-version: 1`, `.wiki/rules/**` now linted), added a Grounded Claims layer (`claims:` + `scripts/wiki_claims.py` + a secret-free CI drift gate), split generation (`@wiki-generate` drafts, `@wiki-bootstrap` verifies v2) from refresh (`@wiki-update`), and added OKF v0.2 export plus a static `docs/` visualizer. `machinery-version: 25`.
**Ref:** `6992665`

---

## 2026-09-11 - CI self-test hotfix: Unix hidden `.vscode` (v0.3.17)

**Why:** The `SelfTest sync engine (transport contract)` CI step added in v0.3.13 had been red on every push since. Root cause: on Unix, dot-prefixed names are hidden and `Get-Item`/`Get-ChildItem` ignore hidden items by default (`Test-Path` does not), so `Get-ItemHashes` (`scripts/sync-architecture.ps1:278`) threw `Could not find item .../.vscode` during `-Check` and killed the child process under `$ErrorActionPreference='Stop'`. `.vscode` is the only portable-surface leaf that is dot-prefixed — `.wiki/rules`, `.devops/agents`, skill slugs and script filenames all end in visible names — which is why only it tripped, and why the Windows run stayed green (dot-names are not hidden on Windows). Fix: `-Force` on the `Get-Item`/`Get-ChildItem` calls in `Get-ItemHashes` and on the `-SelfTest` mirror + nested-copy guards. Verified locally: `-SelfTest` OK, `check-parcel-prefix` PASS ×7, `check-utf8-agents` ALL CLEAN, `wiki_lint` exit 0, coverage no-op, JSON parses, version discipline OK. machinery-version 23→24.
**Ref:** `af7ddf6`

---

## 2026-09-11 - Agent topology: SINGLE (fast plan) vs MULTI (comprehensive plan) (v0.3.16)

**Why:** Added the parcel pipeline's second, orthogonal axis — `Agents: MULTI` (comprehensive plan: `ptp-*` delegation, independent Group C reviewers, 4 gates) / `Agents: SINGLE` (fast plan: inline personas, Group C skipped, Gates B+C merged into one approval at Gate B with Gate C `N/A`) — chosen by task complexity and user-confirmed at plan start; closes the gap where "single agent mode" had leaked in ad-hoc. Gate A + Gate D stay human in both. Mirrored across skill, base-context (+ seed template), template-plan, agents, `plan-lifecycle`, and HOW-TO. No backlog items resolved; no KC entry (the axis is canonically documented in `@pass-the-parcel`), consolidation skipped — nothing new surfaced. machinery-version 22→23.
**Ref:** `1c98239`

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

