---
name: wiki-lint
description: "Use when checking wiki health, detecting broken links, validating frontmatter, finding orphan pages, or auditing ref/ discoverability. Triggers: 'lint wiki', 'check wiki', 'wiki health', 'broken links', 'index drift', 'frontmatter check'. Soft report only — never blocks deploy."
version: "1.0"
---

# Wiki Lint Skill

## Goal
Detect structural decay in `.wiki/` — broken links, index drift, frontmatter violations, orphan pages, missing `See Also`, ref discoverability gaps. Soft report: appends findings to `.devops/logs/knowledge-changelog.md`. Never fails a build, never deletes content.

## Workflow

### 1. Scope
Lint every `.md` file under `.wiki/`, including:
- `.wiki/core/`
- `.wiki/components/`, `.wiki/features/`, `.wiki/database/`, `.wiki/logic/`
- `.wiki/hooks/`, `.wiki/integrations/`
- `.wiki/ref/` (special handling)
- `.wiki/templates/`, `.wiki/examples/` (linter target only, not orphans)

### 2. Deterministic Operations

**2.1 Index consistency** — every file in `.wiki/**/*.md` (excluding `index.md`, `ref-index.md`, `*-template.md`, `*-example.md`, and anything in `templates/` or `examples/`) must appear in `.wiki/core/00-system-index.md`. For every entry in `00-system-index.md`, verify the file exists. Missing files marked `[MISSING]`.

**2.2 Internal links** — every `[label](relative-path)` in any wiki file must resolve. Auto-fix on `--fix` if exactly one match elsewhere in the wiki; otherwise report with file:line. Self-referential links (`[foo](foo.md)` resolving to the same file) are ignored, not bugs.

**2.3 Frontmatter** — every wiki doc must have YAML frontmatter with `type`, `name`, `status`. `status` must be one of `stable|in-progress|deprecated`. `dependencies` paths must exist.

**2.4 Orphan pages** — wiki files with zero inbound links from any other wiki file. Exclude `00-system-index.md`, `knowledge-changelog.md`, `ref/`, `templates/`, `examples/`. Report only — never auto-delete.

**2.5 `See Also` health** — warn on wiki files >100 lines without `## See Also`. Validate any `See Also` link resolves.

**2.6 ref/ coverage** — every file in `.wiki/ref/` must appear in `.wiki/ref/ref-index.md`.

### 3. Error Handling

Every operation must handle these gracefully:

- **Empty wiki** — no `.wiki/**/*.md` files exist → report 0 issues, exit cleanly.
- **Missing index** — `00-system-index.md` doesn't exist → create with empty TOC, log to changelog as informational.
- **Locked file** — file exists but is read-only → skip, log to changelog with file path.
- **Permission denied** — read fails → skip, log warning, continue with other files.
- **Self-referential link** — `[foo](foo.md)` resolves to the same file → ignore (not a bug).
- **Always exit cleanly** — never throw, never leave the changelog in a partial state. Use single `append` per lint run.

### 4. Output

Append exactly one entry to `.devops/logs/knowledge-changelog.md` per invocation:

```markdown
## [YYYY-MM-DD HH:MM] — lint | <N> issues found
* **Skill:** wiki-lint
* **Findings:** N1 (broken links, index drift) | N2 (orphan pages, missing See Also) | N3 (passes)
* **Files affected:** [list with file:line]
* **Notes:** <optional summary>
```

### 5. Optional Flags

- `--fix` — auto-fix deterministic issues (index entries, broken links with exactly one match). Still soft-report; never delete content.
- `--quiet` — no changelog entry on clean run (0 issues). Default is to log a baseline entry on every invocation.
- `--scope <path>` — limit lint to a subdirectory (e.g. `--scope .wiki/ref/`).

## Usage Guidelines
- **Proactive**: Run at end of any work that touched wiki docs (per `agent-wrap-up` protocol).
- **First-thing**: Run `@wiki-lint` on a fresh wiki to establish a baseline.
- **Drift detection**: Run weekly to catch gradual decay (e.g. renamed files leaving dead links).
