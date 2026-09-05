---
type: "core"
name: "Agent Changelog"
status: "stable"
description: "Chronological record of all AI agent actions, changes, and audits."
---

# Agent Changelog

All changes made by AI agents are tracked chronologically below.

---

## 2026-09-06 - Audits Home + Q&A / True-or-False Skill Alignment

**Agent:** GitHub Copilot (OpenCode Go / Glm 5.3 Flash)

**Files Modified:**
- `.devops/audits/README.md` — NEW state folder for audit session artifacts: `true-or-false-<slug>-YYYY-MM-DD.md`, `<slug>-QA-YYYY-MM-DD.md`, `ui-inventory-<element>-YYYY-MM-DD.md`; rules (one file per session, JIT persistence, findings promote to plans but logs are never retro-edited)
- `.devops/skills/q-and-a/SKILL.md` — NEW skill (was untracked); frontmatter aligned to repo trigger-description convention, version 1→3; log location → `.devops/audits/`; plan naming `<slug>-plan.md`; phantom skill refs replaced (write-knowledge-document/write-process/refine-knowledge-area → wiki-writer, cross-reference-analysis → wiki-lint); `.wikirules/`/`.languagerules/` → `.wiki/rules/` paths; "Phase 4.1" → "Phase 3 discovery / Gate A"
- `.devops/skills/true-or-false/SKILL.md` — version 2→4; same alignment pass (trigger description, `.devops/audits/` log home, `.wiki/rules/` paths, wiki-lint/wiki-assessment/knowledge-capture refs, genericized SME persona, plan template path)
- `.devops/skills/ui-inventory-scanner/SKILL.md` — version 1→2; NEW Phase 7 "Persist the Report": every scan saves full report (stats + tables + anomalies + Proposed Changes section) to `.devops/audits/ui-inventory-<element>-YYYY-MM-DD.md`
- `.devops/README.md` — `.devops/audits/` added to "What Lives Here" table (type: state)
- `AGENTS.md` — task-lookup row added: "Viewing audit results (T/F, Q&A, UI inventories)" → `.devops/audits/README.md`

**Database/API Changes:** None

**Summary:** Established `.devops/audits/` as the single home for audit-style session artifacts (True-or-False validation logs, Q&A discovery logs, UI inventory scan reports) and aligned the two newly added skills (q-and-a, true-or-false) with repo conventions so they are transportable machinery: trigger-style descriptions, canonical `.wiki/rules/` paths, `.devops/plans/` plan naming, and cross-references only to skills that exist in this repo. UI inventory scans now persist durable reports to the audits folder instead of dying with the session. No `sync-manifest.yaml` change needed — audits are state, not machinery; satellites receive the convention via the synced skills. Skipped: Phases 2–4 (no `src/` or `.wiki/` code docs, no plan followed), Phases 5–7 (no orphan/debt/backlog matches surfaced). **Wrap-up ref:** recorded after commit.

---

## 2026-09-05 - Sync prune_files Mechanism (machinery-version 6)

**Agent:** GitHub Copilot (Copilot SDK)

**Files Modified:**
- `.devops/sync-manifest.yaml` — NEW `prune_files:` key listing the 8 retired `parcel-*.md` runbooks; machinery-version 5→6
- `scripts/sync-architecture.ps1` — prune handling: copy mode deletes `prune_files` present in target (`PRUNED`); `-Check` reports `PRUNE` verdict; `-DryRun` reports would-prune; `-SelfTest` plants a stale file, re-syncs, asserts removal
- `.devops/rules/agents-and-skills.md` — Sync Protocol documents `prune_files`
- `.devops/README.md` — Pruning bullet in Transportability
- `HOW-TO.md` — `PRUNE` verdict row added to the `-Check` verdict table

**Database/API Changes:** None

**Summary:** Added a `prune_files` manifest key so the sync engine deletes files from satellites that were retired upstream. Previously the sync was overwrite-only — renamed/removed portable files (e.g. the `parcel-*.md` → `.agent.md` migration) left orphaned runbooks in satellites. Now `prune_files` entries present in the target are deleted on sync, reported as `PRUNE` in `-Check`, and covered by `-SelfTest`. Verified: `sync-architecture.ps1 -SelfTest` (prune path OK), end-to-end prune test (stale file removed). **Wrap-up ref:** `364dae4`

---

## 2026-09-05 - Sync `-Verify` Mode: Post-Load Structural Verification (machinery-version 7)

**Agent:** GitHub Copilot (OpenCode Go / Glm 5.3 Flash)

**Files Modified:**
- `scripts/sync-architecture.ps1` — NEW `-Verify` switch (verify-only mode, never writes): structural checks of the satellite-authored surface (`AGENTS.md` machinery markers, `opencode.json` `instructions`/`skills.paths` wiring, `base-context.md`, wiki anchor `.wiki/core/00-system-index.md`, machinery presence, `.ptp-source` advisory) + machinery gates. Extracted `Invoke-StructuralVerify` + `Invoke-VerificationGates` helpers; post-sync now reuses them and appends an informational STRUCTURE report (does not fail first-time bootstraps). Wiki-lint gate now SKIPs targets with no `.wiki/core` content (fresh-bootstrap false positive — previously a fresh sync exited 1 at wiki lint)
- `scripts/pull-architecture.ps1` — `-Verify` passthrough + mode line + usage doc
- `.devops/skills/sync-architecture/SKILL.md` — version 2→3; `-Verify` command row + verdict interpretation (3b)
- `.devops/templates/SATELLITE-BOOTSTRAP.md` — version 3→4; step 4 gains `-Verify` after `-Check`
- `.devops/sync-manifest.yaml` — machinery-version 6→7 (combined set with prune_files)
- `.devops/README.md` — Transportability section mentions `-Verify`

**Database/API Changes:** None

**Summary:** Adds the post-load verification gate discussed when evaluating (and rejecting) a `.parcel` folder restructure: after a satellite syncs and authors its repo-specific files, `pull-architecture.ps1 -Verify` confirms the outer structures conform to the template blueprint (`AGENTS.md` markers, `opencode.json` wiring, `base-context.md`, wiki anchor) and re-runs the machinery gates check-only, without writing. Design decisions: `-Verify` is read-only (prefix check runs without `-Sync`); post-sync structural findings are informational so first-time bootstraps still exit 0; wiki lint skips wiki-less targets. Two PowerShell pitfalls fixed during verification: `Write-Output` and native-command stdout inside functions are captured by return-value assignment — status lines now use `Write-Host`/`Out-Host`. Rebased onto the parallel `prune_files` commit (remote v0.3.3); this feature re-versioned v0.3.3→v0.3.4 and machinery-version combined to 7. Verified: `-SelfTest` OK (5 dirs, 29 skills, 5 files, prune path); e2e `-Verify` on a wired clone → `VERIFIED` exit 0; negative case (removed `opencode.json`) → `VERIFY FAILED` exit 1; fresh-target post-sync → exit 0 with STRUCTURE guidance; repo gates (prefix, UTF-8, wiki lint) all exit 0. **Wrap-up ref:** `3c01ebc`

---

## 2026-09-04 - VS Code Custom Agent Migration (machinery-version 5)

**Agent:** GitHub Copilot (Copilot SDK)

**Files Modified:**
- `.devops/agents/` — renamed to VS Code custom agent convention: `parcel.agent.md` (selectable; merged `/parcel` command + orchestrator runbook) + `wiki-writer.agent.md` (selectable; wraps `wiki-writer` skill) + `ptp-*.subagent.md` (subagents: context-hunter, high-visionary, smooth-operator, grumpy-architect, code-surgeon, phase3-answerer) + `wiki-verifier.subagent.md` (subagent). Each carries YAML frontmatter (description/tools/user-invocable) + PREFIX-LOCKED prefix (parcel/ptp only)
- `.opencode/command/parcel.md` — DELETED (moved into `parcel.agent.md`)
- `.opencode/plans/base-context.md` — PREFIX-LOCKED note + delegation map → `ptp-*` names; model registry binding → agent frontmatter
- `scripts/check-parcel-prefix.ps1` — matches `parcel.agent.md` + `ptp-*.subagent.md`; strips/preserves YAML frontmatter
- `scripts/check-utf8-agents.ps1` — scans `*.agent.md` + `*.subagent.md`
- `opencode.json` — `agent` block removed (agents now defined by `.agent.md` files)
- `.devops/templates/base-context.template.md`, `opencode.template.json`, `AGENTS.template.md`, `SATELLITE-BOOTSTRAP.md` — naming + frontmatter-in-file updates
- `AGENTS.md`, `.devops/README.md`, `.devops/rules/agents-and-skills.md`, `.wiki/rules/naming.md`, `.wiki/rules/company-scoping.md`, `README.md`, `.devops/skills/pass-the-parcel/SKILL.md` — agent naming references updated
- `.devops/sync-manifest.yaml` — machinery-version 4→5

**Database/API Changes:** None

**Summary:** Migrated the parcel agent set to VS Code custom agent definitions so agents appear in the VS Code agent picker. Only `parcel` and `wiki writer` are selectable (`*.agent.md`); the six `ptp-*` pipeline agents + `wiki-verifier` are subagents (`*.subagent.md`, `user-invocable: false`). The `/parcel` command was folded into `parcel.agent.md`. `opencode.json` agent blocks removed (pure VS Code migration). PREFIX-LOCKED prefix contract preserved — `check-parcel-prefix.ps1` now handles frontmatter-in-file and the new naming. Verified: `check-parcel-prefix.ps1 -Sync` (7 files PASS), `check-utf8-agents.ps1`, `wiki_lint.py --quiet` (exit 0), `wiki_coverage_check.py` (exit 0). **Wrap-up ref:** `47cf81d`

---

## 2026-09-04 - Sync Discoverability + .vscode Portability (machinery-version 4)

**Agent:** GitHub Copilot (Copilot SDK)

**Files Modified:**
- `AGENTS.md` — TASK LOOKUP gains "Syncing machinery / pulling template updates" row → `@sync-architecture` skill
- `.devops/templates/AGENTS.template.md` — same row added to seed template (portable path: SATELLITE-BOOTSTRAP.md); version 1→2
- `.devops/sync-manifest.yaml` — `.vscode` added to `portable_dirs`; machinery-version 2→4
- `.vscode/settings.json` — NEW (tracked): VS Code Copilot agent/skill locations for `.devops/agents` + `.devops/skills`; machine-specific `git.path` + PATH override stripped
- `.vscode/tasks.json` — NEW (tracked): "Launch Everything" task; folder-open auto-launch removed (manual only)
- `.gitignore` — `.vscode/` un-ignored
- `.devops/README.md` — Transportability section lists `.vscode/`
- `.devops/skills/sync-architecture/SKILL.md` — machinery list includes `.vscode`; version 1→2
- `.devops/templates/SATELLITE-BOOTSTRAP.md` — portable surface includes `.vscode`; version 1→2
- `HOW-TO.md` — §6 portable surface includes `.vscode/`
- `.wiki/core/18-knowledge-capture.md` — new decision: `.vscode` portability policy
- `.devops/logs/version-history.md` — v0.3.1 release row

**Database/API Changes:** None

**Summary:** Made the sync machinery discoverable and added `.vscode` to the portable surface. A lookup-table-driven agent previously couldn't find sync directly (AGENTS.md had no sync row) — added one in both AGENTS.md and the seed template. `.vscode` (settings.json + tasks.json) was gitignored and machine-specific; it is now tracked, sanitized (git.path + PATH override removed; folder-open auto-launch removed so satellites without the referenced terminal profiles don't fail on open), and synced to satellites via `portable_dirs`. machinery-version bumped 2→4 so satellites see UPGRADE. Phase-gating: docs/machinery-only diff → Phases 2–4 skipped; backlog read → no matching items; known limitation (tasks.json references user-defined terminal profiles "Run Dev Server"/"OpenCode" — manual task only) noted. Verified: `sync-architecture.ps1 -SelfTest` (5 dirs), `check-parcel-prefix.ps1`, `check-utf8-agents.ps1`, `wiki_lint.py --quiet` all exit 0. **Wrap-up ref:** `38770fa`

---

## 2026-09-03 - Skill Streamlining: agent-wrap-up + test-and-deploy Token Economy

**Agent:** GitHub Copilot (OpenCode Go / Glm 5.3 Flash)

**Files Modified:**
- `.devops/skills/agent-wrap-up/SKILL.md` — v1→v2. Added "Token Economy & Delegation Model" section: phase-gating (explicit skip rules after Phase 0 — no `src/` diff skips 2–3, no plan skips 4, nothing surfaced skips 5–7) + two-subagent concurrent delegation for Phases 2–7 with exclusive write scopes (Agent A: `.wiki/**` incl. Phase 5 `defer` rows + Phase 7 knowledge-capture; Agent B: `.devops/plans|archive|backlog`); subagents return summary tables, never file contents. Phase 8 re-anchored as inline-only (gates measured <1s, tiny output; lint gate now invoked with `--quiet`); subagent spawn added to Mandatory Tools.
- `.devops/skills/test-and-deploy/SKILL.md` — v1→v2. §2–3: lint/test/build now run concurrently as PowerShell 5.1 `Start-Job` background jobs, full output redirected to log files, single poll per job, logs read only on failure (wall-clock = longest job, not the sum; polling discipline prevents token overrun). §4: version level defaults to Patch silently — clarifying prompt fires only on explicit feature/breaking-release signals.
- `.wiki/core/18-knowledge-capture.md` — new decision: "Gate Output Cost Must Be Measured Before Optimizing Agent Token Spend" (evidence-first validation falsified the initial gate-output claim before restructuring).

**Database/API Changes:** None

**Summary:** User trialled both skills in a satellite workspace and flagged them as token-heavy at session end. Findings were validated against the template before editing: measured both Phase 8 gates (wiki_lint 0.63s / 0 chars with `--quiet`; coverage 0.25s / 64 chars) — the "gates flood context" hypothesis was falsified and withdrawn, while the read-cost claim was confirmed (`.wiki/` = 60 docs, ~135 KB). The restructure delegates the genuinely expensive phases (2–7) to two concurrent subagents with corrected file ownership (naive `.wiki/` vs `.devops/` split had a real collision via Phase 5 `defer` rows writing into the knowledge-capture doc) and keeps cheap gates inline. Phase-gating makes wrap-up cost proportional to session shape instead of always running all 9 phases. test-and-deploy's three verification streams are independent, so they now run concurrently with output truncation by design. Phase-gating applied to this very wrap-up: docs/machinery-only diff → Phases 2–4 skipped; backlog read → no matching items. Verified: `wiki_lint.py --quiet` exit 0; `machinery-version` unchanged (skill frontmatter bumps suffice per bump discipline). Not pushed (human's `@test-and-deploy` owns that). **Wrap-up ref:** `e773d43` (last commit; this session's work is uncommitted on top — commit before the next wrap-up so the next Phase 0 diff has a clean baseline).

---

## 2026-09-03 - CI Hotfix: Untracked-File Assertion Removed

**Agent:** GitHub Copilot (OpenCode Go / Qwen3.8 Flash)

**Files Modified:**
- `.github/workflows/validate.yml` — JSON-parse step no longer asserts `.opencode/package.json` (gitignored local runtime, absent in CI checkouts); tracked JSON only
- `.wiki/core/18-knowledge-capture.md` — new decision: "CI Must Assert Only Tracked Files"

**Database/API Changes:** None

**Summary:** First v0.3.0 CI run failed on the JSON step — my gate referenced a file that exists locally but is excluded by `.opencode/.gitignore`, so a clean checkout never has it. All other steps (prefix, UTF-8, lint, coverage, version discipline) passed. Fix pushed as `14b71ce`; re-run green in 11s. Lesson captured: CI assertions must be reproducible from `git ls-files` alone.

---

## 2026-09-03 - Independent Review Hardening: Template Cleanup, Slot Registry, CI (v0.3.0)

**Agent:** GitHub Copilot (OpenCode Go / Qwen3.8 Flash)

**Files Modified:**
- `.wiki/core/01-vision-north-star.md`, `03-glossary-of-terms.md` — GRID-Deploy titles removed; BoM glossary row genericized to a placeholder pattern
- `.wiki/components/components-index.md`, `features/features-index.md`, `database/database-index.md`, `logic/logic-index.md` — catalog rows rebuilt as generic template patterns (domain-specific GRID inventories removed); each index now states "template index — populate from your app's real tree"
- `.wiki/core/10-validation-standards.md`, `11-utility-standards.md`, `17-docs-blueprint.md`, `conventions/conv-database-naming.md`, `integrations/gemini-integration.md` — domain examples genericized (Material ID → Entity ID, Firebase Cloud Function → serverless function, assembly example → order-dashboard)
- `.opencode/plans/base-context.md` + all 7 `.devops/agents/parcel-*.md` (via `-Sync`) + `.devops/templates/base-context.template.md` — Model Registry replaced by capability slots (`planning` / `review-heavy` / `execution`); vendor identifiers removed from machinery; binding rule added (satellites bind slots in their own `opencode.json`)
- `.devops/skills/pass-the-parcel/SKILL.md` + 5 `ptp-*` persona skills — slot vocabulary mirrored; versions bumped 1→2
- `.github/workflows/validate.yml` — ADDED: CI on push/PR running prefix check, UTF-8 guard, wiki lint, coverage gate, JSON parse, machinery-version discipline warning
- `scripts/sync-architecture.ps1` — ADDED `-SelfTest`: end-to-end smoke test into a throwaway temp target with manifest-mirror assertions + nested-copy defect guard; `-Target` no longer mandatory when `-SelfTest`
- `scripts/check-utf8-agents.ps1` — REWRITTEN: scans agents + all skill markdown (97 files), detects both C3 A2 double-encoding and EF BF BD replacement chars
- `.devops/skills/wiki-bootstrap/references/00-system-index.md`, `17-docs-blueprint.md` — latent U+FFFD mojibake repaired (surfaced by the extended guard)
- `scripts/wiki_coverage_check.py` — graceful no-op when no `src/` tree exists (template repo passes; satellites activate automatically)
- `.wiki/hooks/hooks-index.md`, `.wiki/ref/ref-index.md`, `.wiki/examples/examples-index.md` — ADDED following the spoke-index pattern; linked from `00-system-index.md` §8; registered in `wiki_lint.py` FM_EXEMPT_FILES
- `.wiki/conventions/conventions-index.md`, `.wiki/testing/testing-index.md`, `.wiki/integrations/integrations-index.md` — duplicate `--fix` artifact rows merged into single linked tables (orphans cleared)
- `.devops/skills/design-audit/SKILL.md` — version bumped 1→2 (its DESIGN.md reference now resolves to the wiki design doc in satellites that kept the file; template itself has none)
- `DESIGN.md` — DELETED; core token quick-reference table folded into `.wiki/core/09-design-system.md` §2; README updated; AGENTS.md gains Design & Scope Notes callout (design lives in wiki; task-lookup app rows are satellite-facing examples)
- `.devops/plans/T1-E1.01-reconcile-model-registry-plan.md` → `.devops/archive/` — resolved-by-dissolution with Completion Note; backlog-index row marked COMPLETE
- `.wiki/core/18-knowledge-capture.md` — new decision: "Model Registry Replaced by Capability Slots"; `.devops/logs/version-history.md` — v0.3.0 release row added, stale v1.0.0 placeholder row removed
- `.devops/sync-manifest.yaml` — machinery-version 1→2; `HOW-TO.md` §6 — model-binding + CI paragraphs added

**Database/API Changes:** None

**Summary:** Executed the user-approved fix list from an independent review of the template. Root cause of the model-registry contradiction (T1-E1.01) was hardcoding vendor identifiers in portable machinery — dissolved it with abstract capability slots so binding becomes satellite config. De-contaminated the wiki of GRID-Deploy inventory residue, added CI covering every pre-push gate the repo already mandated manually, hardened the sync engine with a self-test, closed the documented UTF-8 guard gap (which immediately caught two latent mojibake files), completed the spoke-index set, and consolidated design docs into the wiki. All gates exit 0: prefix PASS ×7, UTF-8 ALL CLEAN (97 files), wiki lint OK, coverage OK, selftest OK. Not pushed (human's `@test-and-deploy` owns that).

---

## 2026-09-03 - Agnostic Template: Pull-Based Sync + Machinery Versioning (W1-W9)

**Agent:** GitHub Copilot (OpenCode Go / Qwen3.8 Flash)

**Files Modified:**
- `scripts/pull-architecture.ps1` — ADDED (satellite-side pull wrapper: `-Source` param > `.ptp-source` resolution, git-URL caching under `%USERPROFILE%\.ptp\template`, passthrough `-Check`/`-DryRun`/`-NoVerify`, exit-code propagation)
- `scripts/sync-architecture.ps1` — MODIFIED: `-Check` drift report (per-item SHA256 + version verdicts CURRENT/UPGRADE/DRIFT/MISSING/SOURCE-ABSENT, IN SYNC/OUT OF SYNC summary, exit 0/1); portable skills now DERIVED (all `.devops/skills/` minus manifest `excluded_skills:`); scalar manifest parsing (`machinery-version`); bump-report line after real sync; **fixed pre-existing Copy-Item nesting bug** (dir/skill copies into existing targets nested `$t\$dirname\...` — now ensures dest and copies contents); **CRLF-normalized hashing** in `-Check` (git smudge filters materialize LF blobs as CRLF on Windows → false DRIFT without normalization)
- `.devops/skills/*/SKILL.md` — 29 skills stamped `version: 1` + `updated: 2026-09-03`; quoted `"1.x"` versions normalized to integers; `author:` frontmatter removed (`agent-wrap-up`, `app-vision-north-star`, `knowledge-capture`, `knowledge-consolidation`)
- `.devops/skills/sync-architecture/` — ADDED (the `@sync-architecture` skill: workspace-root guard, switch selection, verdict interpretation, DRIFT = ask-the-user rule, first-time-satellite guidance)
- `.devops/skills/update-global-skills/`, `.devops/skills/update-workspace-skills/` — DELETED (legacy `.gemini` sync against a directory that no longer exists; zero dangling refs verified)
- `.devops/sync-manifest.yaml` — `machinery-version: 1` added; dead `verify_commands:` key removed; explicit `portable_skills:` list replaced by derived surface + `excluded_skills: []`; `.devops/templates` added to `portable_dirs`; `pull-architecture.ps1` + `wiki_lint.py` added to `portable_files`
- `.devops/templates/` — ADDED: `AGENTS.template.md`, `opencode.template.json`, `base-context.template.md`, `SATELLITE-BOOTSTRAP.md` (seeds for the three repo-specific files a satellite authors itself + the one-time bootstrap checklist)
- `scripts/wiki_lint.py` — docstring genericized ("pass-the-parcel" → "parcel blueprint") for portability
- `.gitignore` — `.ptp-source` courtesy line added
- `HOW-TO.md` — new section 6 "Syncing Machinery into a Satellite Workspace" (bootstrap push vs ongoing pull, verdict table, versioning scheme); utility-skills table row for `@sync-architecture`
- `README.md` — step 4 under "How to Use This Template" linking HOW-TO §6 + SATELLITE-BOOTSTRAP
- `.devops/README.md` — Transportability section rewritten (pull flow, versioning, derived portable list, seeds)
- `.devops/rules/agents-and-skills.md` — Sync Protocol section documents derived portable list, `machinery-version`, per-skill `version`/`updated` requirement, wrap-up bump step
- `.devops/skills/agent-wrap-up/SKILL.md` — Phase 8 gains step 4: machinery version bump discipline (skills/templates → `version:`; scripts/agents/rules → `machinery-version:`)
- `.devops/plans/agnostic-template-sync-plan.md` → `.devops/archive/agnostic-template-sync-plan.md` — plan executed and archived with Completion Note (3 logged deviations)

**Database/API Changes:** None

**Summary:** Delivered the pull-based sync architecture for the agnostic template: satellites record their source once in `.ptp-source` and thereafter refresh via `scripts/pull-architecture.ps1` (or `@sync-architecture`), with a read-only `-Check` drift table distinguishing upstream upgrades from local customization. Versioning is integer counters — per-skill `version`/`updated` frontmatter plus one `machinery-version` covering agents/rules/scripts/templates as a coordinated set. The portable skill surface is now derived rather than declared, permanently killing the "added a skill, forgot the manifest" drift class. Two latent bugs surfaced during verification and were fixed: the Copy-Item nesting defect in the original push engine, and CRLF smudge-filter false positives in hash comparison. All six plan verification steps pass; prefix/UTF-8/wiki-lint gates exit 0. Not pushed (human's `@test-and-deploy` owns that). Wrap-Up ref: `701455b`.

---

## 2026-09-03 - Template Sync: Import Latest Parcel Architecture from GRID-Deploy

**Agent:** GitHub Copilot (opencode-go/glm) (Coordinated by user)

**Files Modified:**
- `.devops/skills/*/SKILL.md` — 19 skills updated from GRID-Deploy (newer machinery): `agent-wrap-up` (Phase 0 mechanical diff + Phase 8 coverage gate), `backlog` (Theme/Epic `T{n}-E{n}.{impl}` prefix convention, all plans live in `.devops/plans/`), `build-roadmap` (three-tier Theme→Epic→Impl hierarchy), `knowledge-capture` v1.1 (3-section format reference), `knowledge-consolidation` v3.0 (Tribal-vs-Canonical promotion test, wiki promotion phase), `pass-the-parcel` + all `ptp-*` personas (spec-first renumbering: Phase 4 wiki spec, Gate A/B/C, `PHASE_5_REVISION` loop), `spaghetti-monster` (overrides halt + State Dashboard), `true-or-false` (plan suffix), `ui-inventory-scanner`/`design-audit` (doc-path fixes), `wiki-lint` v1.2 (deterministic linter invocation)
- `.devops/skills/wiki-writer/` — ADDED (renamed from `write-wiki/`, which is deleted); all cross-references updated
- `.devops/skills/wiki-assessment/` + `.devops/skills/wiki-bootstrap/` — Theme-column slot tables, slot-14 testing-subtree note, realigned slot-purpose table, `wiki-writer` companion references, theme-linguistics reference scaffolds; all mojibake (U+FFFD/`?`) repaired to clean UTF-8
- `.devops/agents/` — all 7 parcel agents re-synced; `wiki-verifier.md` ADDED (clean-context report-only post-wrap-up auditor)
- `.opencode/plans/base-context.md` — new phase numbering (Phases 4-5 High-Visionary, 6 Grumpy, 7 Smooth, 8-9 Surgeon), Gates A (Spec & Plan) → B (Review) → C (Implementation), `PHASE_5_REVISION` loop; PREFIX-LOCKED prefix re-inlined via `check-parcel-prefix.ps1 -Sync`
- `opencode.json` — `wiki-verifier` agent registered; model assignments imported from GRID-Deploy; agent descriptions updated to new phase numbering
- `.vscode/settings.json` — ADDED (instruction/agent/skill file locations + terminal auto-approve policy)
- `.opencode/package.json` + `package-lock.json` — ADDED (`@opencode-ai/plugin` dependency, gitignored local runtime)
- `scripts/` — `wiki_lint.py` upgraded (hub-and-spoke enforcement, BFS reachability, index budget, `--changelog`, deterministic `--fix`), `wiki_coverage_check.py` ADDED (code-graph coverage gate), `spaghetti-monster-scan.cjs` ADDED
- `.devops/plans/template-plan.md` — spec-first restructure: Phase 4 Wiki Requirements & Acceptance Criteria, no-halt after Phase 3/4, three-gate State & Gates
- `.wiki/rules/` — structure manifest (conventions/testing numbered areas, renumbered anchors), link-hygiene rule 4 (index cataloguing), `status: approved→stable` normalization; language rules synced
- `.wiki/core/00-system-index.md` — added `Integrations Index` spoke link + spoke diagram row
- `.wiki/**` frontmatter — `title` field added to 31 docs missing it; legacy `template`/`approved` statuses normalized to `in-progress`/`stable`
- `.wiki/conventions/conventions-index.md`, `.wiki/testing/testing-index.md`, `.wiki/integrations/integrations-index.md` — missing index rows added via `wiki_lint.py --fix`
- `AGENTS.md` — `@wiki-writer` + wiki-verifier task-lookup rows, Rule 10 (Wiki Prose Discipline), Pre-Push Requirements section

**Database/API Changes:** None

**Wrap-Up Actions (2026-09-03, same session):**
- `.devops/rules/plan-lifecycle.md` — synced to the new spec-first lifecycle (`PHASE_4` → `PHASE_5` → `PHASE_7` → `PHASE_9`, Gates A/B/C, `PHASE_5_REVISION`); backlog-plans-in-`.devops/plans/` convention; `last-reviewed` stamped 2026-09-03
- `.wiki/core/18-knowledge-capture.md` — updated the 2026-08-17 model-mapping decision to the new phase numbering; added two decisions: *Template Sync Policy* and *UTF-8 Mojibake in Machinery Files*
- `.devops/plans/T1-E1.01-reconcile-model-registry-plan.md` + `.devops/backlog/backlog-index.md` — new backlog item (T1-E1.01): Model Registry documents `mimo-2.5` while `opencode.json` runtime assigns `deepseek-v4-flash`; needs a user decision on the canonical mapping
- Phase 0 diff verified: 89 modified, 7 added, 1 deleted files; **no `src/` changes** — docs/machinery only, no feature-doc leftovers
- Phase 8.3 freshness stamp: N/A — the hub has no `Last Verified` Quick Reference field; freshness carried by `last-reviewed` frontmatter (rules docs stamped)

**Summary:** Imported the most current parcel architecture from GRID-Deploy (the farthest-evolved consumer workspace) into this authoritative template, excluding GRID-specific app content (tech stack, BoM/tender docs, Firebase CORS script, `grids-deploy-overrides.md`). Key upgrades: spec-first parcel pipeline (wiki docs written as `in-progress` in Phase 4, promoted to `stable` at wrap-up), Theme/Epic plan prefixes, wiki promotion workflow, coverage gate (`wiki_coverage_check.py`), hardened deterministic linter, and the `wiki-verifier` clean-context auditor. Also repaired pre-existing UTF-8 mojibake in `wiki-bootstrap` skill files and cleared all frontmatter debt the new linter surfaced. Verified: `wiki_lint.py` exit 0 (0 findings), `wiki_coverage_check.py` exit 0, `check-parcel-prefix.ps1` PASS, `check-utf8-agents.ps1` ALL CLEAN, `opencode.json` valid JSON. **Wrap-up ref:** `23f7652` (last commit; all work in this entry is uncommitted on top of it — commit before the next wrap-up so the next Phase 0 diff has a clean baseline).

## Parcel Version Pipeline Collapse + Single Canonical Template

**Agent:** opencode-go/deepseek-v4-flash (Coordinated by user)

**Files Modified:**
- `.opencode/plans/base-context.md` — removed `6.5 | parcel-compactor` delegation row + `run-[slug]/versions/*` workspace layout line; re-inlined PREFIX-LOCKED prefix via `check-parcel-prefix.ps1 -Sync`
- `opencode.json` — removed `parcel-compactor` agent definition
- `.devops/agents/parcel-compactor.md` — DELETED (agent retired)
- `.devops/skills/parcel-compactor/SKILL.md` — DELETED (skill retired)
- `.devops/agents/parcel-orchestrator.md` — workspace init creates `reviews/` + `decision_log.md` only; Phase 4 writes directly to plan; compaction step (6.5) removed; code-surgeon reads plan file; delegation map updated
- `.devops/agents/parcel-high-visionary.md` — dropped `v1.0_draft.md` snapshot step; Phase 4 written into plan file directly
- `.devops/agents/parcel-code-surgeon.md` — execution source is Phase 4 + State & Gates in the plan file (replaced `v2.0_approved.md` read)
- `.devops/skills/ptp-code-surgeon/SKILL.md` — `versions/` staging reference removed
- `.devops/skills/pass-the-parcel/references/template-plan.md` — DELETED (single canonical template)
- `.devops/skills/pass-the-parcel/SKILL.md` — template reference re-pointed to `.devops/plans/template-plan.md` (2 locations)
- `AGENTS.md` — template reference re-pointed
- `.gitattributes` — removed `parcel-compactor` pin
- Also earlier this session: removed `Get-Date` tool + all date/time recording from parcel machinery; nested rule dirs (`.wiki/rules/`, `.wiki/rules/language/`, `.devops/rules/`, `scripts/wiki_lint.py`); moved wiki to `.wiki/`

**Database/API Changes:** None

**Summary:** Retired the historical `v1.0_draft → v1.1_merged → v2.0_approved` version pipeline (predated the cache-anchored State & Gates refactor). Phase 4 now lives only in the cache-anchored plan file; the code-surgeon reads Phase 4 + State & Gates from the plan as its single execution source; the compactor agent/skill and the duplicate skill-bundled template copy were deleted. Isolated `reviews/` outputs retained. Result: 7 PREFIX-LOCKED agents, one canonical template at `.devops/plans/template-plan.md`, byte-stable plan tops with bottom-only State & Gates mutation. Verified: prefix-lock OK, UTF-8 clean, wiki_lint exit 0, 0 stale version-pipeline refs.

## 2026-08-19 - Parcel Cache-Anchored Templates (State & Gates at Bottom)

**Agent:** opencode-go/deepseek-v4-flash (Coordinated by user)

**Files Modified:**
- `.devops/plans/template-plan.md` — removed top State Dashboard; added static `🔒 CACHE-ANCHORED` banner; added bottom `## 📍 State & Gates` (State table + Mode row + Gate Log A-D); halt points point to bottom section; folded trailing `Status: COMPLETE` into bottom
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
**Summary:** Created the pass-the-parcel repository scaffold (originally named Vibe-App-Wiki) with the hub-and-spoke wiki architecture, skill system, opencode integration, pass-the-parcel workflow, and developer conventions. All core docs initialized as templates ready for project-specific content.

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
- `.devops/plans/template-plan.md` — skill refs, persona refs, Phase 5/6 swap, no-code-snippet instructions
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
- `.devops/plans/template-plan.md`, `skills/pass-the-parcel/references/template-plan.md` — Phase 5 spec-audit findings rows, Gate C PASS/FAIL, Phase 7 direct-to-disk constraints
- `HOW-TO.md` — Spec & Logic Audit + deterministic rejection loop + execution isolation documented
- `opencode.json` — descriptions updated (Spec & Logic Audit, direct-to-disk, PHASE_4_REVISION)
- `AGENTS.md` — cross-view §9 → §11 pointer
- `docs/wiki/core/18-knowledge-capture.md` — updated decision record with new directives + canonical model identifiers

**Database/API Changes:** None

**Summary:** Hardened the parcel pipeline: Phase 5 (Grumpy Architect) is now strictly a Spec & Logic Audit of the text-based Phase 4 architecture — no code-level scans since the plan contains no code. Added a deterministic rejection loop at Gate C (`PHASE_4_REVISION` → return to Group B → re-review) so unapproved plans never cascade to execution. Phase 7 (Code Surgeon) now enforces single-pass direct-to-disk execution — no intermediate Markdown code blocks — and triggers only after explicit user sign-off. Standardized the model registry to canonical identifiers (mimo-2.5, v4-flash-max, deepseek-v4-flash).

---

<!-- New entries go above this line, most recent first -->
