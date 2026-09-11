---
name: wiki-lint
description: "Use when checking wiki health, detecting broken links, validating frontmatter, finding orphan pages, or auditing index drift and hub reachability. Triggers: 'lint wiki', 'check wiki', 'wiki health', 'broken links', 'index drift', 'frontmatter check'. Soft report only — never blocks deploy."
version: 4
updated: 2026-09-11
---

# Wiki Lint Skill

## Goal
Detect structural decay in `.wiki/` by running the deterministic linter, `scripts/wiki_lint.py`, and reporting its findings. The script is the canonical implementation of every check below; this skill owns the invocation and the judgement calls the script cannot make. Run results go to stdout only — there is no persistent lint log; git history is the record.

## What The Linter Checks

Severity contract: **exit 1 only on HARD**. WARN and INFO never block a commit or deploy.

| # | Check | Severity | Finding format |
|---|---|---|---|
| 1 | Encoding guard — no BOM, valid UTF-8 | HARD | `UTF-8 BOM` / `not valid UTF-8` |
| 2 | Structure manifest anchors exist (`.wiki/rules/structure.md`) | HARD | `missing anchor` |
| 3 | Internal markdown links resolve | HARD | `broken link` |
| 4 | Frontmatter required fields (`name`, `type`, `status`) | HARD | `missing frontmatter field` |
| 5 | Status ∈ `stable / in-progress / deprecated / template / approved` | HARD | `invalid status` |
| 6 | Frontmatter `related-to` / `dependencies` path-shaped targets resolve (`.wiki/**` + `.devops/**`) | HARD | `broken frontmatter link` |
| 7 | Hub links to every category index that exists | HARD | `[HUB MISSING SPOKE]` |
| 8 | Category index catalogues every sibling doc | WARN | `[UNINDEXED]` |
| 9 | Index rows point at existing files | WARN | `[MISSING]` |
| 10 | Every content doc reachable from `00-system-index.md` (BFS; governance/meta areas excluded) | WARN | `unreachable from hub` |
| 11 | Orphan pages (no inbound links anywhere) | INFO | `orphan` |

Exemptions baked into the script: `.wiki/rules/**` and `.devops/**` skip frontmatter-**field** checks (their links are still resolved); `README.md`, `index.md`, `*-index.md` skip the field check and the orphan/reachability reports; `ref/`, `templates/`, `examples/`, `.wiki/rules/` and `knowledge-capture.md` skip orphan/reachability reporting; non-`.md` / non-path dependency tokens (npm packages, component names, table names) are informational only; `.devops/plans/**`, `.devops/archive/**`, `.devops/logs/**` are historical records and are excluded from the frontmatter-link scan.

## Workflow

### 1. Run
```
python scripts/wiki_lint.py            # report
python scripts/wiki_lint.py --fix      # also repair index rows (see 3)
python scripts/wiki_lint.py --quiet    # silent unless HARD failures
```

### 2. Report
Findings print to stdout as deterministic lines with HARD/WARN/INFO counts derived from the scan. There is no persistent changelog for lint runs — `git log` on `.wiki/` is the audit trail.

### 3. Fix
- `--fix` performs two deterministic edits, collected from a full scan before any write: appends a row to the owning index's last table for each `[UNINDEXED]` doc, and deletes index rows whose only link target is missing (`[MISSING]`). It prints every edit as `FIX`. If no reliable table exists it skips and leaves the warning.
- `--fix` writes only when the scan is clean apart from the `[MISSING]` rows it is about to delete (each of those also trips the HARD body-link check — an accepted overlap). Any other HARD failure aborts the repair and mutates nothing.
- Everything else needs a human or this skill: prose fixes, moved paths (update all links pointing at the old path — git records the move), and promoting docs closer to the hub.

### 4. Error handling
The script never throws mid-run: unreadable files are skipped with an INFO line, an empty wiki exits 0, and `--fix` writes only after the whole scan succeeds.

## Usage Guidelines
- **Proactive**: run at the end of any work that touched wiki docs (per `agent-wrap-up`); `wiki-writer` Step 8 requires it after every substantive edit.
- **First-thing**: run on a fresh wiki to establish a baseline.
- **Drift detection**: run weekly to catch gradual decay (renamed files leaving dead links, new docs never indexed).
- **Deferred checks** (not implemented, add here if built): index size budget (>400 lines); blueprint spoke-list sync (`17-docs-blueprint.md`); hop-count reporting (>2 hops from hub); `See Also` section coverage; `ref/` index coverage (no `ref/` directory content exists yet).
