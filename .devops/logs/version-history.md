---
type: "core"
name: "Version History"
status: "stable"
description: "Formal release log and 3-level versioning strategy for the application."
---

# Version History & Policy

This log records the formal releases, deployments, and the 3-level versioning strategy enforced across the application.

## 📌 Versioning Strategy (3-Level System)

All versioning follows the semantic hierarchy configured within the `/Test-and-Deploy` pipeline:

1. **Level 1 (Major)**: User-directed primary versions (e.g., `1.02.003` -> `2.00.000`). Triggered for fundamental architectural updates, paradigm shifts, or major product milestones. Resets both minor and patch levels to double/triple zero padding.
2. **Level 2 (Minor)**: New feature versions (e.g., `1.02.003` -> `1.03.003`). Adds `.01` to Level 2 versioning (allowing up to 99 level 2 versions), while preserving the patch level as-is. Prompted and confirmed when introducing discrete new features, capabilities, or major screen flows.
3. **Level 3 (Patch)**: Automated deployment versions (e.g., `1.02.003` -> `1.02.004`). Adds `.001` to Level 3 versioning (allowing up to 999 level 3 versions), while preserving the minor level as-is. Automatically bumped on every routine code deployment or patch push if no major/minor bump is specified.

---

## 📈 Release Log

| Version | Date | Level | Deployer | Key Release Highlights / Milestones |
|---|---|---|---|---|
| **v0.3.4** | 2026-09-05 | Patch | GitHub Copilot (OpenCode Go / Glm 5.3 Flash) | Sync `-Verify` mode: read-only post-load gate — structural checks of the satellite-authored surface (`AGENTS.md` machinery markers, `opencode.json` wiring, `base-context.md`, wiki anchor, machinery presence, `.ptp-source` advisory) + machinery gates check-only; post-sync structural report informational (bootstrap exits 0); wiki-lint gate skips wiki-less targets; machinery-version 6→7 (combined set with prune_files). |
| **v0.3.3** | 2026-09-05 | Patch | GitHub Copilot (Copilot SDK) | Sync `prune_files` mechanism: `prune_files:` key in `sync-manifest.yaml` deletes retired files from satellites (8 old `parcel-*.md` runbooks); `sync-architecture.ps1` prunes on copy, reports `PRUNE` in `-Check`, `-SelfTest` verifies; machinery-version: 6 (5→6). |
| **v0.3.2** | 2026-09-04 | Patch | GitHub Copilot (Copilot SDK) | VS Code custom agent migration: `parcel-*` runbooks → `parcel.agent.md` + `wiki-writer.agent.md` (selectable) + `ptp-*.subagent.md` + `wiki-verifier.subagent.md` (subagents); `/parcel` command folded into `parcel.agent.md`; `opencode.json` agent block removed; `check-parcel-prefix.ps1` handles frontmatter-in-file; machinery-version 4→5. |
| **v0.3.1** | 2026-09-04 | Patch | GitHub Copilot (Copilot SDK) | Sync discoverability + `.vscode` portability: AGENTS.md + seed template gain sync row; `.vscode` added to `portable_dirs` (settings.json sanitized of machine-specific `git.path`/PATH, tasks.json folder-open auto-launch removed), tracked + synced; machinery-version 2→4. |
| **v0.3.0** | 2026-09-03 | Minor | GitHub Copilot (opencode-go/qwen3.8-flash) | Independent-review hardening: template de-contamination (GRID residue removed from wiki titles + catalog indexes rebuilt as generic patterns), Model Registry replaced by capability slots (`planning`/`review-heavy`/`execution`, binding = satellite `opencode.json`), CI gate `.github/workflows/validate.yml`, sync engine `-SelfTest`, UTF-8 guard extended to skills, coverage gate graceful no-op without `src/`, hooks/ref/examples index docs, DESIGN.md folded into `09-design-system.md`. machinery-version: 2 |
| **v0.2.0** | 2026-09-03 | Minor | GitHub Copilot (opencode-go/glm) | Template sync from GRID-Deploy: spec-first parcel pipeline (Phase 4 wiki spec, Gates A/B/C, `PHASE_5_REVISION` loop), `wiki-writer` rename, `wiki-verifier` agent, Theme/Epic plan prefixes (`T{n}-E{n}.{impl}`), knowledge promotion workflow (capture v1.1 / consolidation v3.0), coverage gate (`wiki_coverage_check.py`), hardened deterministic `wiki_lint.py` (hub-spoke + BFS reachability + `--fix`/`--changelog`), `.vscode/settings.json`, UTF-8 mojibake repair, frontmatter `title` + status normalization across 31 wiki docs, integrations spoke linked from hub. |
| **v0.1.0** | 2026-08-18 | Patch | deepseek-v4-flash | Parcel orchestration overhaul: High-Visionary Phase 4 (no code snippets), Grumpy Architect → Spec & Logic Audit (Phase 5), Smooth Operator Phase 6, Code Surgeon single-pass direct-to-disk (Phases 7-8), deterministic `PHASE_4_REVISION` rejection loop at Gate C, canonical model registry (mimo-2.5 / v4-flash-max / deepseek-v4-flash), PREFIX-LOCKED cache enforcement (.gitattributes + check scripts + pre-commit hook). |
