---
name: wiki-lint
description: "Use when checking wiki health, detecting broken links, validating frontmatter, finding orphan pages, or auditing index drift and hub reachability. Triggers: 'lint wiki', 'check wiki', 'wiki health', 'broken links', 'index drift', 'frontmatter check'. Soft report only — never blocks deploy."
version: "1.2"
---

# Wiki Lint Skill

## Goal
Detect structural decay in `.wiki/` by running the deterministic linter, `scripts/wiki_lint.py`, and reporting its findings. The script is the canonical implementation of every check below; this skill owns the invocation, the changelog entry, and the judgement calls the script cannot make.

## What The Linter Checks

Severity contract: **exit 1 only on HARD**. WARN and INFO never block a commit or deploy.

| # | Check | Severity | Finding format |
|---|---|---|---|
| 1 | Structure manifest anchors exist (`.wiki/rules/structure.md`) | HARD | `missing anchor` |
| 2 | Internal markdown links resolve | HARD | `broken link` |
| 3 | Frontmatter required fields (`name`, `title`, `type`, `status`) | HARD | `missing frontmatter field` |
| 4 | Status ∈ `stable / in-progress / deprecated` | HARD | `invalid status` |
| 5 | `dependencies` entries ending `.md` resolve | HARD | `unresolvable dependency` |
| 6 | Hub links to all six category indexes | HARD | `[HUB MISSING SPOKE]` |
| 7 | Category index catalogues every sibling doc | WARN | `[UNINDEXED]` |
| 8 | Index rows point at existing files | WARN | `[MISSING]` |
| 9 | Every content doc reachable from `00-system-index.md` (BFS) | WARN | `unreachable from hub` |
| 10 | Index size budget (>400 lines) | WARN | `index is N lines` |
| 11 | Blueprint spoke-list sync (`17-docs-blueprint.md`) | INFO | `spoke list drift` |
| 12 | Docs >2 hops from the hub | INFO | `N hops from hub` |
| 13 | Orphan pages (no inbound links anywhere) | INFO | `orphan` |

Exemptions baked into the script: `.wiki/rules/**` and `.devops/**` skip frontmatter-field checks; `README.md`, index files, `ref/`, `templates/`, `examples/` skip orphan/reachability reporting; non-`.md` dependency tokens (npm packages, component names, table names) are informational only.

## Workflow

### 1. Run
```
python scripts/wiki_lint.py            # report
python scripts/wiki_lint.py --fix      # also repair index rows (see 3)
python scripts/wiki_lint.py --quiet    # silent unless HARD failures
python scripts/wiki_lint.py --changelog  # also append one entry to knowledge-changelog.md (see 2)
```

### 2. Report
Pass `--changelog` to append exactly one entry to `.devops/logs/knowledge-changelog.md` per invocation — the script writes it deterministically (timestamp, HARD/WARN/INFO counts, affected files derived from findings). This is the ONLY supported way to log a run; do not hand-write entries.

### 3. Fix
- `--fix` performs two deterministic edits, collected from a full scan before any write: appends a row to the owning index's last table for each `[UNINDEXED]` doc, and deletes index rows whose only link target is missing (`[MISSING]`). It prints every edit as `FIX`. If no reliable table exists it skips and leaves the warning.
- Everything else needs a human or this skill: prose fixes, moved paths (register in the redirect log first, per `link-hygiene.md`), and promoting docs closer to the hub.

### 4. Error handling
The script never throws mid-run: unreadable files are skipped with an INFO line, an empty wiki exits 0, `--fix` writes only after the whole scan succeeds, and a locked/unwritable changelog is reported on stdout and skipped (never a crash).

## Usage Guidelines
- **Proactive**: run with `--changelog` at the end of any work that touched wiki docs (per `agent-wrap-up`); `wiki-writer` Step 8 requires it after every substantive edit.
- **First-thing**: run on a fresh wiki to establish a baseline.
- **Drift detection**: run weekly to catch gradual decay (renamed files leaving dead links, new docs never indexed).
- **Deferred checks** (not implemented, add here if built): `See Also` section coverage; `ref/` index coverage (no `ref/` directory exists yet).
