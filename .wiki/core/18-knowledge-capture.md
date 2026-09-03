---
title: "Knowledge Capture & Decision Log 🧠"
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

### Parcel Version Pipeline Retired — Single Cache-Anchored Plan
* **Context:** The `v1.0_draft → v1.1_merged → v2.0_approved` version pipeline (a pre-cache-anchored design) duplicated Phase 4 content that already lived in the plan file, emitted a separate `v2.0_approved.md` with no State & Gates section, and gave the code-surgeon an ambiguous execution source (both the plan and `v2.0_approved.md`). A duplicate skill-bundled template copy also drifted from the canonical template.
* **Action:** Deleted the `parcel-compactor` agent + skill (removed from `opencode.json`, base-context delegation map, `.gitattributes`). High-visionary writes Phase 4 into the plan file only (no `v1.0_draft.md` snapshot). Orchestrator creates `run-[slug]/` with `reviews/` + `decision_log.md` only; no compaction step. Code-surgeon reads Phase 4 + State & Gates from `.devops/plans/[slug]-plan.md` as the single execution source. Deleted the skill-bundled template copy; `pass-the-parcel` skill + AGENTS.md point to the single canonical `.devops/plans/template-plan.md`.
* **Rationale:** Removes duplicate cache surfaces and ambiguous execution sources. The cache-anchored plan (byte-stable top, State & Gates at bottom) is now the sole artifact mutated across the lifecycle. Isolated `reviews/` outputs retained — they prevent confirmation bias.

---

## 🚀 Tooling & DevOps
* **Decision Date:** 2026-08-17 *(phase numbering updated 2026-09-03 — spec-first renumbering; canonical mapping now lives in `.opencode/plans/base-context.md` Model Registry)*
* **Context:** The pass-the-parcel pipeline needed a clearer model-to-phase mapping to match model strengths to task difficulty and reduce token spend on heavy models for lighter roles.
* **Action:** Adopted a fixed model assignment for the parcel pipeline (canonical identifiers: `mimo-2.5`, `v4-flash-max`, `deepseek-v4-flash` — no aliases):
    * **mimo-2.5** — orchestrator + Phases 1-3 (Scoper), Phases 4-5 (High-Visionary), Phase 7 (Smooth Operator), Wrap Up.
    * **v4-flash-max** — Phase 6 (Grumpy Architect / Spec & Logic Audit).
    * **deepseek-v4-flash** — Phases 8-9 (Code Surgeon, ponytail coding + single-pass direct-to-disk execution).
    * Phase 4 is the wiki requirements spec + Phase 5 the standard implementation plan — **no code snippets unless absolutely necessary** — persona: **High-Visionary**.
    * Phase order: **Grumpy Architect (Phase 6)** runs before **Smooth Operator (Phase 7)**.
    * **Phase 6 is a Spec & Logic Audit, not a code review** — the plan contains no code, so it evaluates system contracts, edge cases, file boundary collisions, dependency gaps, YAGNI bloat, performance trade-offs, and architectural anti-patterns.
    * **Deterministic rejection loop at Gate B** — a failing Phase 6/7 review sets `PHASE_5_REVISION` and returns the plan to Group B for fixes; an unapproved plan never advances to execution.
    * **Execution isolation** — Phase 8 (Code Surgeon) triggers only after Gate B is cleared by explicit user input and writes directly to disk, bypassing intermediate Markdown code blocks.
* **Rationale:**
    * **Capability-fit routing**: the heavy review model (`v4-flash-max`) is reserved for the senior architectural audit; the orchestrator model (mimo-2.5) handles the majority of planning/communication/UX work where balanced capability suffices.
    * **Token efficiency**: trimming Phase 5 to standard implementation instructions (no code snippets) shrinks plan size and review surface; code specifics are deferred to the Code Surgeon via ponytail markers.
    * **Review ordering**: architectural hardening (Grumpy, Phase 6) must land before product smoothing (Smooth Operator, Phase 7) so the Smooth Operator cross-checks the already-hardened plan instead of handing off structural concerns forward.
    * **Safety**: the `PHASE_5_REVISION` loop + execution isolation prevent unapproved plans from cascading into code changes.
    * **Consistency**: both `opencode.json` and the agent runbooks must stay in lockstep — they are the same agent definitions in two formats; model identifiers are canonicalized to avoid parser ambiguity.

---

### Template Sync Policy — Machinery Flows from the Farthest-Evolved Consumer
* **Decision Date:** 2026-09-03
* **Context:** This workspace is the authoritative template for all parcel-* development workspaces, but consumer workspaces (notably GRID-Deploy) evolve the machinery faster than the template is updated — GRID-Deploy had diverged on 19 skills, all 7 parcel agents, the linter, and the parcel phase numbering.
* **Action:** Imported the latest machinery from GRID-Deploy into this template (spec-first Phase 4-9 pipeline, Theme/Epic plan prefixes, wiki promotion workflow, coverage gate, wiki-verifier agent, wiki-writer rename). GRID-specific app content was excluded (tech stack, BoM/tender docs, Firebase CORS script, workspace overrides). Known issue deferred to backlog: `base-context.md` Model Registry documents `mimo-2.5` for phases 1-5/7 while `opencode.json` runtime assigns `deepseek-v4-flash` to every agent.
* **Rationale:**
    * **Battle-tested machinery**: consumer workspaces run the machinery against real code daily; the template should absorb what survived production, not what was last written here.
    * **App-agnostic template**: app-specific content stays in consumer wikis; the template carries only portable machinery so the next workspace starts clean.
    * **Single source of truth**: the template remains the canonical copy; future consumer changes should flow back via the same sync policy.

---

### UTF-8 Mojibake in Machinery Files — Repair, Don't Re-copy
* **Decision Date:** 2026-09-03
* **Context:** Several `.devops/skills/wiki-*` files carried U+FFFD replacement chars and `?`-mangled arrows/emoji (em dashes → `�`, `→` → `?`, `–` → `n++`) from an ancestor edit saved with the wrong encoding. `check-utf8-agents.ps1` only guards `.devops/agents/parcel-*.md` — skills and scaffolds have no automated guard.
* **Action:** Repaired all affected files to clean UTF-8 (no BOM). When syncing machinery between workspaces, never assume a source file is encoding-clean: scan for `\uFFFD` and mangled sequences first, and port structural changes onto clean text rather than copying corrupted files whole.
* **Rationale:**
    * **Corruption propagates through sync**: a template sync that copies mojibake wholesale re-infects the clean workspace.
    * **Guard gap**: skills/scaffolds are read by every agent; corrupted glyphs in instructions degrade downstream behavior silently.

---

### Pull-Based Sync + Integer Machinery Versioning
* **Decision Date:** 2026-09-03
* **Context:** The template repo's only transport mechanism was push (`sync-architecture.ps1 -Target`), which requires running from the template and knowing its path. Satellites had no way to ask "am I out of date?", no version metadata to compare, and the manifest's explicit `portable_skills:` list drifted silently whenever a skill was added without a manifest edit.
* **Action:** Satellites now pull: `scripts/pull-architecture.ps1` resolves source from `-Source` > `.ptp-source` (git URLs cached under `%USERPROFILE%\.ptp\template`) and wraps the push engine. `sync-architecture.ps1 -Check` prints a per-item verdict table (CURRENT/UPGRADE/DRIFT/MISSING/SOURCE-ABSENT) with exit 0/1 for CI consumption. Versioning = integer counters: per-skill `version:` + `updated:` frontmatter, one `machinery-version:` in the manifest for agents/rules/scripts/templates as a set. Portable skills are DERIVED (all skills minus `excluded_skills:`). Deferred deliberately: semver, `portable:` frontmatter tripwire, `local-override:` blessing protocol.
* **Rationale:**
    * **Derivation kills drift**: a declared portable list is always one skill behind reality; subtraction from the filesystem can't be forgotten.
    * **Integers over semver**: machinery has no public API contract — the only question a satellite asks is "is upstream newer than me?", which one counter answers. Semver would invite relitigating major/minor meaning.
    * **DRIFT vs UPGRADE separation**: same-version-different-bytes means local customization — overwriting it silently destroys satellite work; the verdict forces an ask-the-user stop.

---

### Git Smudge Filters Break Byte-Hash Comparisons on Windows
* **Decision Date:** 2026-09-03
* **Context:** The new `-Check` drift report compared SHA256 hashes of working-tree files. After a satellite ran `git checkout`, eight items reported DRIFT despite being byte-identical in git: `core.autocrlf=true` plus `eol=lf` in `.gitattributes` materialize LF blobs as CRLF in the Windows working tree, so raw file hashes never match between a freshly cloned repo and a synced one.
* **Action:** `-Check` normalizes CRLF→LF before hashing both sides (read bytes, decode UTF-8, replace, re-hash). Committed blobs were verified already-LF (`git ls-files --eol` shows `i/lf w/crlf` — the renormalization commit was a no-op); the noise lived entirely in the smudge layer, so fixing the comparison — not the storage — was correct.
* **Rationale:**
    * **Compare semantics, not encoding artifacts**: line endings are transport noise; content drift is what the checker exists to find.
    * **Don't fight autocrlf globally**: forcing `core.autocrlf=false` or mass re-checkouts would churn every developer's working tree for a checker-only concern.
    * **General rule**: any tool that hashes across git boundaries on Windows must normalize EOL first — same trap awaits future diff/verify scripts.

---

### Model Registry Replaced by Capability Slots — Binding Is Satellite Config
* **Decision Date:** 2026-09-03
* **Context:** The machinery carried hardcoded vendor model identifiers (`mimo-2.5`, `v4-flash-max`, `deepseek-v4-flash`) in the PREFIX-LOCKED base-context, all seven agent runbooks, six skills, and the seed template — while `opencode.json` runtime assigned different models entirely. The mismatch (backlog T1-E1.01) could not be resolved by "picking a side" because the template cannot know which models a satellite's provider offers; hardcoding was the root defect, not the drift.
* **Action:** The Model Registry now defines three abstract capability slots — `planning` (orchestrator + Phases 1-3, 4-5, 7 + Wrap Up), `review-heavy` (Phase 6 audit only), `execution` (Phases 8-9). Concrete binding is exclusively each workspace's `opencode.json` (`agent.<name>.model`). All vendor identifiers removed from machinery surfaces; prefix re-synced via `check-parcel-prefix.ps1 -Sync`; pass-the-parcel + ptp-* skills and the seed template mirror the slot vocabulary. T1-E1.01 archived as resolved-by-dissolution.
* **Rationale:**
    * **Machinery vs config separation**: the pipeline's phase→persona routing is portable; model availability is a per-workspace, per-provider decision. Encoding the latter in the former guarantees silent drift every time a provider retires a model.
    * **Slots survive model churn**: a satellite swaps its bound model with a one-line `opencode.json` edit and zero machinery changes.
    * **Agents stay honest**: the binding rule tells agents to read their own configured model rather than assert a documented-but-false identity.

---

### CI Must Assert Only Tracked Files
* **Decision Date:** 2026-09-03
* **Context:** The first CI run (v0.3.0) failed on the JSON-parse step: it asserted `.opencode/package.json`, which is gitignored by `.opencode/.gitignore` (local opencode runtime). Locally the file exists so every gate passed; in a clean CI checkout it never does.
* **Action:** Dropped the untracked-file assertion from `validate.yml` — CI now parses only tracked JSON (`opencode.json`). Fixed in `14b71ce`; next run green.
* **Rationale:**
    * **A CI gate must be reproducible from a fresh clone**: any check referencing a path outside `git ls-files` is a latent false failure.
    * **Local-green ≠ CI-green**: run gates against a clean checkout before trusting them; this repo's ignore layers (`.gitignore` + `.opencode/.gitignore`) make hidden local state easy to acquire.

---

### Gate Output Cost Must Be Measured Before Optimizing Agent Token Spend
* **Decision Date:** 2026-09-03
* **Context:** The `@agent-wrap-up` and `@test-and-deploy` skills were flagged as token-heavy at session end. Initial analysis assumed the Phase 8 gates (`wiki_lint.py`, `wiki_coverage_check.py`) flooded the main context with output and recommended delegating them. No measurements existed — the claim was an estimate.
* **Action:** Measured both gates before restructuring: `wiki_lint.py --quiet` runs in 0.63s with zero output; `wiki_coverage_check.py` in 0.25s with 64 chars. The token cost is concentrated in *reads* (the 60-doc wiki, backlog index), not the gates. Rebuilt both skills accordingly: wrap-up gained phase-gating (explicit skip rules after the Phase 0 diff) plus a two-subagent delegation model (Agent A owns `.wiki/**` incl. `defer` rows + knowledge-capture; Agent B owns `.devops/plans|archive|backlog`); Phase 8 stays inline. test-and-deploy now runs lint/test/build concurrently via `Start-Job` (single poll each, logs to files, read only on failure) and defaults to a silent Patch version bump. Versions bumped 1→2.
* **Rationale:**
    * **Measure, then optimize**: a grep + `Measure-Command` pass falsified the gate-output claim in minutes; delegating the gates would have added subagent overhead to the cheapest phase of the skill.
    * **Isolate reads, not writes**: the subagent split pays off only where the read surface is large; cheap deterministic gates belong in the orchestrating context.
    * **File-ownership rules prevent write collisions**: the naive split (`.wiki/` vs `.devops/`) had a real collision — Phase 5 `defer` rows write into `.wiki/core/18-knowledge-capture.md`; ownership was reassigned accordingly.

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
