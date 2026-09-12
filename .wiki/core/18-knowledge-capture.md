---
title: "Knowledge Capture & Decision Log 🧠"
type: "core"
name: "Knowledge Capture"
status: "stable"
format-version: 1
dependencies: []
db_relations: []
description: "Canonical log of core engineering decisions, tribal knowledge, and architectural strategies."
claims:
  - id: capture-via-skill
    source: .devops/skills/knowledge-capture/SKILL.md#Admission Gate
    hash: sha256:112ecfd1896184016c6e3e31ec8f8a52d1779479e62f695d76bab4d48146f9d8
  - id: prune-via-consolidation
    source: .devops/skills/knowledge-consolidation/SKILL.md#Tidy (default)
    hash: sha256:cfdf3f488510d5ab7932df515bf66a7c8363140adb2e026259e2baf597bb8441
  - id: knowledge-capture-line-ceiling
    source: .devops/skills/knowledge-consolidation/SKILL.md#hard 500-line ceiling
    hash: sha256:cfdf3f488510d5ab7932df515bf66a7c8363140adb2e026259e2baf597bb8441
---
# Knowledge Capture & Decision Log

> Tribal knowledge only: edge cases with future practical use that the wiki cannot hold. Agents read the wiki first — anything the wiki covers is deleted here, never pointed at. Hard cap 500 lines; entries ≤3 lines (Rules/Pitfalls), ≤10 lines (Archive, max 5). Capture via `knowledge-capture`; pruning via `knowledge-consolidation` (tidy after every plan).

## Quick Reference — Top 10 Rules
| # | Rule | Theme | Pitfall? |
|---|------|-------|----------|
| 1 | Plan Settings (`Mode`/`Agents`) freeze at the TOP; mutable State & Gates sits at the BOTTOM; the rest stays byte-stable (LLM prefix cache) | Parcel | ❌ |
| 2 | SKILL.md is canonical; agents embed it verbatim — regenerate with `check-parcel-prefix.ps1 -Sync`, never hand-edit | Parcel | ❌ |
| 3 | Machinery evolves in the farthest-evolved consumer; the template absorbs what survived production | Sync | ❌ |
| 4 | Portable machinery carries no absolute paths or machine-specific config | Sync | ✅ |
| 5 | Normalize CRLF→LF before hashing files across git boundaries on Windows | Sync | ✅ |
| 6 | Versioning = integer counters only; portable skills are derived (all minus `excluded_skills:`), never declared | Sync | ❌ |
| 7 | Never edit PREFIX-LOCKED surfaces directly — edit `base-context.md`, then run `check-parcel-prefix.ps1 -Sync` | Parcel | ✅ |
| 8 | Phase 3 clarification questions go to the user one at a time | Parcel | ❌ |
| 9 | Measure a gate's actual cost before optimizing agent token spend around it | Process | ✅ |
| 10 | KC entries land ≤3 lines at capture; superseded entries are cut, never struck through | Knowledge | ✅ |

## Pitfalls to Avoid
_(Mistakes that cost time or broke things. Read these first when starting similar work.)_

- **UTF-8 mojibake in machinery files**: corruption propagates through sync and silently degrades every agent that reads the file. *Do instead:* repair to clean UTF-8 (no BOM); never re-copy a corrupted file wholesale.
- **Editing a truncated line**: `read_file` truncates long lines (~2000 chars); an edit that trusts the tail writes literal `[truncated]` text mid-file. *Do instead:* re-read or rewrite the whole entry; for giant-line appends, write a temp file and append via `[IO.File]::AppendAllText` with UTF8-no-BOM (PowerShell `Set-Content -Encoding UTF8` writes a BOM and breaks `wiki_lint.py` frontmatter checks).
- **Publishing links into gitignored run workspaces**: `.opencode/plans/run-*/` is gitignored, so a wiki/example doc that links a review or decision log breaks for every clone. *Do instead:* quote the run artefact (e.g. a `**REJECTED:**` verdict line) inline and link only tracked paths (`.devops/archive/…`).
- **Claims sourced from claim-carrying docs restamp late**: `scripts/wiki_claims.py update` stamps docs in walk order, so a claim whose `source` is another doc that also carries claims records the source's *pre-restamp* bytes and reports `STALE` right after one `update`. *Do instead:* source the claim from a non-claim file, or run `update` a second time.
- **Auto-cataloguing ignores index column semantics**: `wiki_lint._fix_unindexed` (used by lint `--fix` and `wiki_okf.py import`) inserts `[name, description]` into the first two data columns, so on an index whose columns are not `Doc | Description` (e.g. integrations' `Doc | Service | Description`) the description lands under the wrong header. *Do instead:* add the row by hand for non-standard indexes.


## Rules & Constraints
_(Stable rules derived from prior decisions. Grouped by theme.)_

### Sync & Versioning
- **Farthest-evolved consumer wins**: when template and satellite diverge, port the satellite's battle-tested machinery back; app-specific content stays in the consumer. *(2026-09-03)*
- **Post-sync bookkeeping self-heals**: sync stamps the target manifest's `machinery-version:` in place; `-Check` hashes only agent-unique content (frontmatter stripped), so per-repo prefix regeneration never reports phantom DRIFT. *(2026-09-06)*

### Parcel Pipeline
- **Split plan config from state**: `Mode`/`Agents` are frozen in a **Plan Settings** block at the TOP; the State & Gates section sits last and holds only mutable state rows; everything else stays byte-stable across the lifecycle. *(2026-08-19, revised 2026-09-12)*
- **Claim before execution**: a claim covers a declared `touches` file set — never two claims that overlap, and never a plan whose `depends_on` is not archived. Claim commits the queue→plans `git mv` on the workspace trunk; the worktree branch `plan/<code>-<slug>` is cut from it; shared files (`sprint.md`, `backlog-index.md`, `agent-changelog.md`, `sync-manifest.yaml`) are trunk-only. A plan keeps its stable `T{theme}-E{epic}.{impl}` code through backlog → sprint queue → plans → archive. *(2026-09-13)*
- **Single execution source**: the plan file is the only thing the code-surgeon reads — no versioned snapshots (the `v1.0 → v2.0_approved` pipeline is retired). *(2026-09-06)*
- **One state machine, five mirrors**: the 4-gate model (A Scope / B Spec & Plan / C Peer Reviews / D Implementation) is stated identically in the orchestrator skill, base-context, parcel agent, template, and rules doc. *(2026-09-07)*

### Agents & Models
- **Dual-surface agent binding**: agents live once in `.devops/agents/*.agent.md`; VS Code reads per-file frontmatter, opencode reads `opencode.json`. Per-file binding means the orchestrator cannot mis-spawn a model; use the provider's exact picker casing. *(2026-09-06)*
- **Set-level agent versioning**: agents are versioned as a coordinated set via `machinery-version:` — no per-file `version:`; only skills carry per-file versions, because the sync drift checker reads those from `SKILL.md`. *(2026-09-04)*

### Product & Process
- **Measure, then optimize**: measure a gate's real cost/output before restructuring around an estimated token claim. *(2026-09-03)*

### Knowledge System
- **Consolidation closes the loop**: `agent-wrap-up` Phase 6 captures AND runs `@knowledge-consolidation` (tidy mode). Capture is append-lean (≤3 lines); tidy prunes. Full audit fires only on its own triggers or when this file exceeds 200 lines. *(2026-09-09)*

## Decision Archive
_(Only decisions whose full story prevents a specific repeat mistake. Most recent 5 max.)_

### Parcel Machinery Determinism Overhaul — 4 Gates, Script-Enforced Embeds, One Question At A Time *(2026-09-07)*
- **Context**: The pipeline's state machine was stated three different ways across five surfaces; each ptp agent embedded a drifted condensed copy of its skill; gate-affecting decisions leaned on judgment words ("feels like a bolt-on").
- **Action**: Canonicalized the 4-gate model (A Scope / B Spec & Plan / C Peer Reviews / D Implementation), stated identically in orchestrator skill, base-context, parcel agent, template, and rules doc. Agent files now embed SKILL.md verbatim between `<!-- EMBED:START:<key> -->` markers, byte-checked and regenerated by `check-parcel-prefix.ps1 -Sync`. Judgment hedges replaced with operational tests (Bolt-on Test, binary telemetry rule, 20-file blast-radius bound). Phase 3 questions one-at-a-time; reviewers read-only with Findings Output Contracts (`**REJECTED:**` first line). Supersedes the capability-slot registry (2026-09-03) and the 2026-08-17 phase→model mapping.
- **Rationale**: Conflicting definitions let each surface silently redefine the protocol; verbatim embeds make drift a build failure; determinism means mechanical verification of structure while judgment stays on product decisions.

### Wiki Self-Maintenance Layer — Unified Frontmatter, Grounded Claims, Generate/Update Split *(2026-09-11)*
- **Context**: Governance was strong but truth-maintenance was not: two incompatible frontmatter schemas, no source evidence behind factual claims, no refresh path from `git diff`, no generator, no portable format.
- **Action**: One schema (`format-version: 1`) with `.wiki/rules/**` brought under the linter; Grounded Claims (`claims: id/source#symbol/sha256(file)`) plus `scripts/wiki_claims.py` and a secret-free CI drift step; `@wiki-update` (diff → affected docs → stamp); native `@wiki-generate` with `@wiki-bootstrap` demoted to a verification pass (v2); OKF v0.2 export; static `docs/` visualizer. `machinery-version: 25`.
- **Rationale**: Differentiation stays on governance; generation is borrowed (interop, never vendored). Two owner-only calls: adopting OKF field names verbatim *breaks* the link-hygiene contract (OKF requires only `type`), so OKF is a projection; and a CI job that writes docs needs a model secret + bot identity, so a template defaults to secret-free drift *detection*. Whole-file claim hashing over-flags deliberately — a false stale prompts a re-read, a missed drift ships a wrong wiki.

### Wiki Refresh Automation — OKF Ingest + Secret-Free Drift Issue *(2026-09-11)*
- **Context**: OKF export was one-way (a satellite could not bring a bundle back), and CI reported claims drift but never surfaced it to a human without someone watching the build.
- **Action**: `scripts/wiki_okf.py import` ingests an OKF v0.2 bundle as `in-progress` drafts (index-registered via the linter's canonical `_fix_unindexed`, skip-on-collision); `.github/workflows/wiki-refresh.yml` runs `wiki_claims.py check` weekly and raises/closes a `wiki-drift` issue. The docs-PR path was deliberately not built.
- **Rationale**: The drift job stays secret-free to match the repo's no-secret portable-surface principle — a model-writing CI job needs a secret + bot identity a template should not require. Extends the 2026-09-11 self-maintenance decision (secret-free drift *detection* over model-authored *repair*).
