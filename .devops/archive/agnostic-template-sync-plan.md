# Plan: Agnostic Template â€” Pull-Based Sync + Machinery Versioning

**Status:** COMPLETE (executed & archived 2026-09-03)
**Owner:** executed by GitHub Copilot (OpenCode Go / Qwen3.8 Flash)
**Date drafted:** 2026-09-03
**Depends on:** nothing in flight, but see Conflict Constraints â€” an adjacent session owns parcel agent architecture.

---

## 0. Executor Briefing (read first)

You are implementing in the repo at the workspace root (the "template repo"). This plan is
self-contained: every fact you need about the current state is embedded below. Do NOT
re-design any decision marked **DECIDED** â€” they were settled with the human owner.

### Conflict constraints (HARD)

- Do NOT edit anything under `.devops/agents/` (PREFIX-LOCKED runbooks).
- Do NOT edit `.opencode/plans/base-context.md`.
- Do NOT edit `opencode.json` (skill discovery is automatic via `skills.paths`; no registration needed).
- An adjacent session may be concurrently updating `.wiki/` content and parcel agents. If you
  hit an unexpected conflict in a file you were told to touch, stop and report instead of forcing.
- Do NOT `git push`. Committing is fine; pushing is governed by the human's `@test-and-deploy` skill.

### Repository facts (verified 2026-09-03)

- `scripts/sync-architecture.ps1` â€” push-based sync. Reads `.devops/sync-manifest.yaml`
  (`portable_dirs`, `portable_skills`, `portable_files` â€” a simple `- item` YAML subset parser),
  copies those items into a `-Target` repo, then regenerates PREFIX-LOCKED prefixes from the
  TARGET's own `base-context.md` and runs verification (check-parcel-prefix, check-utf8-agents,
  wiki_lint.py). Supports `-DryRun`, `-NoVerify`, `-Source` (defaults to the script's own repo).
- `.devops/sync-manifest.yaml` â€” declares the portable surface. Currently 3 dirs, 12 skills, 3 files.
  Its `verify_commands:` key is **dead config** â€” the sync script never reads it (verification is
  hardcoded in the script).
- `.devops/skills/` â€” 30 skills, one folder each with `SKILL.md`. Only 7/30 have `version:` in
  frontmatter, in inconsistent formats (`"1.0"`, `"1.2"`, one with leftover `author: "Antigravity"`).
- `.devops/agents/parcel-*.md` â€” pure-body runbooks; frontmatter deliberately lives in
  `opencode.json` (see `.wiki/rules/frontmatter.md` "Convention Exemptions"). **Never add YAML
  frontmatter to these files** â€” it would break the byte-for-byte PREFIX-LOCKED cache contract.
- `scripts/check-parcel-prefix.ps1` (verify/repair agent prefix), `scripts/check-utf8-agents.ps1`
  (encoding gate), `scripts/wiki_lint.py` (deterministic wiki governance linter).
- `.wiki/templates/` â€” exists but empty (`.gitkeep` + README).
- `.devops/skills/update-global-skills/` and `.devops/skills/update-workspace-skills/` â€” legacy
  skills syncing against `~/.gemini/config/skills` and a `Skills/` directory that no longer exists.
  Nothing else references them.
- `scripts/tmp-*` files exist from the adjacent session â€” do not touch or delete them.

---

## 1. Decided design (do not relitigate)

1. **Pull-based sync** is the primary mechanism; push (`sync-architecture.ps1`) remains the
   bootstrap engine underneath it. A satellite-side script + a `sync-architecture` skill let the
   human say "sync architecture" in ANY workspace.
2. **Versioning = integer counters, not semver.** Per-skill `version: <int>` + `updated: <date>`
   in skill frontmatter. One `machinery-version: <int>` in the manifest covering agents/rules/
   scripts as a coordinated set. No version stamps inside agent runbooks.
3. **The manifest becomes the portable list by derivation:** the script computes portable skills
   as *all* `.devops/skills/` folders **minus** an explicit `excluded_skills:` list. This kills
   the "added a skill, forgot the manifest" drift class permanently.
4. **Deferred (do NOT implement):** semver, `portable:` frontmatter tripwire,
   `local-override:` blessing protocol, per-agent trailing version comments.
5. **Seed templates** for the three repo-specific files a satellite must author itself
   (`AGENTS.md`, `opencode.json`, `base-context.md`) live in `.devops/templates/`.

---

## 2. Work items

### W1 â€” Machinery versioning backfill

1.1 In **every** `.devops/skills/*/SKILL.md`, ensure frontmatter contains exactly:

```yaml
version: 1        # integer counter, bump on any change to this skill
updated: 2026-09-03
```

- Normalize: skills that already carry `version: "1.0"` / `"1.2"` â†’ integer `1` (no history worth
  preserving). Remove any `author:` frontmatter (e.g. `agent-wrap-up`).
- Preserve every other frontmatter field exactly (especially multi-line `description:` values â€”
  they contain quotes and em-dashes; do not reflow them).

1.2 In `.devops/sync-manifest.yaml`, add at the top (after the comment block):

```yaml
machinery-version: 1
```

### W3 ordering note â€” the versioning consumer is W2; land W2 and W3 together.

### W2 â€” `scripts/pull-architecture.ps1` (new file, satellite-side)

Design (DECIDED):

```
param(
    [string]$Source,      # path or git URL of the template repo. Optional if .ptp-source exists.
    [switch]$Check,       # report only, never write (passthrough to sync -Check)
    [switch]$DryRun,      # passthrough to sync -DryRun
    [switch]$NoVerify     # passthrough to sync -NoVerify
)
```

Behavior:

1. `$root` = script's repo root (the satellite). Read `$root\.ptp-source` if it exists.
   Resolution order: explicit `-Source` param > `.ptp-source` file > error with a helpful message
   ("run with -Source <path-or-git-url> once; it will be remembered").
2. If `-Source` looks like a git URL (`https://`, `git@`, ends with `.git`, or contains `://`):
   ensure cache dir `$env:USERPROFILE\.ptp\template` exists â€” `git clone --depth 1 <url>` into it,
   or if it already exists run `git -C <cache> pull --ff-only`. Use the cache as the source path.
   If `-Source` is a local path: use it directly (no caching).
3. Validate source contains `scripts\sync-architecture.ps1` and `.devops\sync-manifest.yaml`.
4. Write `.ptp-source` in the satellite root with the resolved source (only when `-Source` was
   given). Add `.ptp-source` handling so it does NOT need gitignoring (it is satellite-local
   state; add it to this repo's `.gitignore` as a courtesy line so cloned satellites that
   gitignore nothing don't get noise â€” acceptable either way).
5. Invoke: `powershell -NoProfile -File "<source>\scripts\sync-architecture.ps1" -Source <source>
   -Target <satellite-root>` plus passthrough switches. Propagate exit code.
6. Print a short "source / target / mode" header like sync-architecture.ps1 does.

Script must run under Windows PowerShell 5.1 (same constraints as sync-architecture.ps1:
`$ErrorActionPreference = 'Stop'`, no PS7-only syntax).

### W3 â€” Version-aware pre-flight in `scripts/sync-architecture.ps1` (edit existing)

Add a `-Check` switch. When `-Check` is present, do NOT copy anything; instead produce a
per-item drift report covering every manifest item (dirs, skills, files) plus the header items:

For each item compare SHA256 hashes of every file (source vs target):

| Verdict | Condition |
|---|---|
| `CURRENT` | target exists, all file hashes equal |
| `UPGRADE` | target exists, hashes differ, target `version` < source `version` |
| `DRIFT`   | target exists, hashes differ, `version` equal (or unreadable) |
| `MISSING` | target item absent (first-time install) |
| `SOURCE-ABSENT` | manifest lists it, source missing (manifest bug â€” always report) |

Version comparison rules:

- For skills: parse `version:` (integer) from source and target `SKILL.md` frontmatter via regex
  `(?m)^version:\s*"?(\d+)"?\s*$` (first match, before the closing `---`). Non-integer/unreadable
  â†’ treat as `0` and let DRIFT classification handle it.
- For dirs and standalone files: derive from `machinery-version` in the source manifest â€” if the
  target's manifest is missing or its `machinery-version` differs, dirs/files report `UPGRADE`;
  if equal but hashes differ, report `DRIFT`.
- After the table, print a summary: counts per verdict and a one-line verdict:
  "IN SYNC" (no UPGRADE/DRIFT/MISSING/SOURCE-ABSENT) or "OUT OF SYNC".
- Exit code: 0 when IN SYNC, 1 when OUT OF SYNC (so CI / the pull script can consume it).
  `-Check` never writes, never regenerates prefixes.

Keep the existing copy + verification behavior for non-`-Check` runs untouched, EXCEPT item 3 below.

Also in the sync script:

3a. Replace the hardcoded `portable_skills` usage with derivation:
`portable_skills = (all directories in .devops\skills) - (manifest excluded_skills)`.
Add `excluded_skills:` to the manifest, initially empty list (W5 deletes the legacy skills
entirely, so nothing needs excluding once W5 lands â€” but keep the mechanism; if W5 has not yet
run when you test, temporarily exclude the two legacy skills).
3b. Remove `verify_commands` from the manifest (dead config) â€” the script's hardcoded
verification (prefix regen, utf8, wiki_lint) remains the single source of truth. Update the
manifest's header comment accordingly.
3c. Add `machinery-version` to the manifest parser and to the copy step: bump-report â€” after a
real (non-check, non-dryrun) sync, print `machinery-version: <N> materialised`.

### W4 â€” `@sync-architecture` skill (new: `.devops/skills/sync-architecture/SKILL.md`)

Frontmatter:

```yaml
---
name: sync-architecture
description: "Use when the user mentions syncing architecture, pulling template updates, updating parcel machinery, 'sync tools', 'pull latest skills/agents', or wants this workspace's .devops machinery refreshed from the template repo. Runs scripts/pull-architecture.ps1 against the current workspace root and reports drift."
version: 1
updated: 2026-09-03
---
```

Body must instruct the agent to:

1. Determine the workspace root (cwd; refuse if no `.devops/` â€” wrong kind of workspace).
2. Run `powershell -NoProfile -File scripts\pull-architecture.ps1` with passthrough switches:
   `-Check` when the user asks "check/what's new/dry question", `-DryRun` for preview, plain run
   for actual sync. Never pass `-Source` unless the user supplies one (`.ptp-source` remembers it).
3. Interpret and summarize the verdict table in plain language; for `DRIFT` items, explicitly
   warn "locally customized copy â€” do not blindly overwrite; ask the user" and offer to open the
   diff before re-running without `-Check` after user approval.
4. On `MISSING` (first-time satellite), tell the user which repo-specific files still need
   authoring from the seed templates (`.devops/templates/`).

### W5 â€” Retire legacy `.gemini` skills

- Delete `.devops/skills/update-global-skills/` and `.devops/skills/update-workspace-skills/`
  (`git rm -r`). Verified: no other file references them.
- If you execute W5 before W3's derivation is in place, nothing else to do (the manifest's
  explicit `portable_skills` list simply won't match them anymore).

### W6 â€” Expand the portable skill surface via derivation (no list edits needed)

With W3's `excluded_skills` mechanism, the portable surface automatically becomes every skill in
the repo minus the two deleted legacy ones (â‰ˆ 29 skills incl. the new `sync-architecture`).
No per-skill manifest entries to maintain. Sanity-check with a `-Check` run that the derived
list looks right before proceeding.

### W7 â€” Manifest + script portability fixups

7a. Add `scripts/wiki_lint.py` and `scripts/pull-architecture.ps1` to `portable_files`.
    Before adding wiki_lint.py, grep it for hardcoded repo-specific strings (repo name, absolute
    paths, author names). If any exist, make the minimal edit to genericize them (it lints
    `.wiki/` structure generically today â€” expect none or trivial).
7b. Keep `.opencode/.gitignore` as-is. Confirm `sync-manifest.yaml` portable_dirs stays:
    `.wiki/rules`, `.devops/rules`, `.devops/agents`, and add `.devops/templates` (from W8).

### W8 â€” Seed templates (new dir `.devops/templates/`)

Create four files. They are seeds: clearly commented, placeholder-heavy, never executed by
anything. Every file gets a frontmatter or header comment block with
`version: 1` / `updated: 2026-09-03` / `type: template` for consistency with the versioning scheme.

- `AGENTS.template.md` â€” derived from the repo's own `AGENTS.md` structure: mandatory-reading
  block, task-lookup table with placeholder rows, core-rules numbered list with placeholders,
  wrap-up protocol. Comments mark every section a satellite must customize (task lookup rows,
  rules 1â€“4 are app-specific; rules 5â€“8 are machinery and can stay verbatim).
- `opencode.template.json` â€” derived from the repo's `opencode.json`: `instructions`/`skills.paths`
  kept verbatim (they are layout-agnostic), agent blocks replaced with commented placeholders +
  one minimal example agent. Note in comments: agent blocks are generated alongside
  `.devops/agents/parcel-*.md` when a satellite adopts the parcel pipeline; a satellite that
  doesn't use parcels should delete the agent section entirely.
- `base-context.template.md` â€” skeleton matching the PREFIX-LOCKED contract: the cache-anchor
  notice block quoted from the repo's `base-context.md`, then placeholder sections
  (core rules / task lookup / delegation map / workspace layout). Prominent warning comment:
  "this file is the canonical shared prefix; editing it requires re-running
  `scripts/check-parcel-prefix.ps1 -Sync` after `opencode.json` agents exist."
- `SATELLITE-BOOTSTRAP.md` â€” the checklist tying it all together:
  1. `powershell -NoProfile -File <path-to-template>\scripts\sync-architecture.ps1 -Target <this repo>`
     (one-time push bootstrap â€” pull script doesn't exist here yet), or
     `git clone <template-url> %TEMP%\ptp && powershell -NoProfile -File %TEMP%\ptp\scripts\sync-architecture.ps1 -Target .`
  2. Copy the three templates to their real locations and customize.
  3. Run `powershell -NoProfile -File scripts\pull-architecture.ps1 -Source <template-url>` to
     record `.ptp-source` for future pulls.
  4. Verify: `powershell -NoProfile -File scripts\pull-architecture.ps1 -Check` â†’ IN SYNC.

### W9 â€” Docs

9a. `HOW-TO.md`: new section **"6. Syncing Machinery into a Satellite Workspace"** â€” the two
    flows (one-time bootstrap with push/clone; ongoing pull with `.ptp-source`), the `-Check`
    verdict table, and the versioning scheme in three sentences (per-skill integer version,
    machinery-version, wrap-up bump discipline).
9b. `README.md`: one short paragraph under "How to Use This Template" linking to the HOW-TO
    section and `.devops/templates/SATELLITE-BOOTSTRAP.md`.
9c. `.devops/README.md` "Transportability" section: mention pull flow + versioning + templates.
9d. `.devops/rules/agents-and-skills.md` "Sync Protocol" section: document the derived portable
    list (`excluded_skills`), `machinery-version`, per-skill `version`/`updated` fields, and the
    wrap-up bump step. Note that skill frontmatter now requires `version` + `updated`.
9e. `.devops/skills/agent-wrap-up/SKILL.md`: add one step to its workflow â€” for each modified
    file under `.devops/skills/` or `.devops/templates/` or `scripts/`, bump its `version`
    (skills/templates) and bump `machinery-version` in the manifest (scripts/agents/rules), and
    refresh `updated`.

---

## 3. Sequencing

1. W1 (stamps) + W2 (pull script) + W3 (sync -Check + derivation) + W5 (retire legacy) â€” the core;
   W1/W3 must land together (versions without a consumer are decoration).
2. W4 (skill) â€” depends on W2.
3. W7 (manifest fixups) â€” depends on W3/W5.
4. W8 (templates) â€” independent, any time after W3.
5. W9 (docs) â€” last, once behavior is final.

## 4. Verification (executor must run all of these)

```powershell
# 1. Deterministic gates still pass in THIS repo (PREFIX-LOCKED untouched):
powershell -NoProfile -File scripts\check-parcel-prefix.ps1
powershell -NoProfile -File scripts\check-utf8-agents.ps1
python scripts/wiki_lint.py

# 2. Build a throwaway satellite and exercise the full loop:
git clone . $env:TEMP\ptp-satellite
powershell -NoProfile -File scripts\sync-architecture.ps1 -Target $env:TEMP\ptp-satellite   # bootstrap push
powershell -NoProfile -File $env:TEMP\ptp-satellite\scripts\pull-architecture.ps1 -Check    # expect IN SYNC, exit 0
# 3. Drift detection: modify one source skill (add a line, bump its version), then re-run -Check
#    from the satellite â†’ expect UPGRADE for that skill and exit 1.
# 4. Revert the source skill edit (git checkout -- .devops/skills/<slug>/SKILL.md).
# 5. -DryRun path of pull-architecture.ps1 against the satellite â†’ prints, writes nothing (verify via git -C satellite status).
# 6. git URL resolution: pull-architecture.ps1 -Source <local-path> in a second fresh clone writes .ptp-source correctly.
```

Definition of done: all six checks pass; no file outside the work items was modified
(`git status` shows only expected paths + the adjacent session's `scripts/tmp-*` noise);
`sync-manifest.yaml` has `machinery-version`, `excluded_skills`, no `verify_commands`,
and `.devops/templates/` exists with the four files.

## 5. Out of scope (explicitly)

- Anything touching `.devops/agents/` content, `base-context.md`, or `opencode.json`.
- The `local-override:` blessing protocol, semver, `portable:` frontmatter.
- Pushing, tagging, or changelog entries in `.devops/logs/` (the human's wrap-up skill owns logs).
- Cleaning up `scripts/tmp-*` files (adjacent session's workspace).
---

## Completion Note (Wrap Up 2026-09-03)

**Outcome:** All work items W1-W9 delivered and verified end-to-end (commits `31da0f7` + `701455b`). Full loop proven on throwaway satellites: bootstrap push -> pull -Check IN SYNC (exit 0) -> source version bump UPGRADE (exit 1) -> revert IN SYNC -> -DryRun purity -> .ptp-source remembered + gitignored. Deterministic gates (prefix / utf8 / wiki_lint) all exit 0.

**Deviations from plan (all necessary, code is truth):**
1. **Pre-existing Copy-Item nesting bug fixed** (`sync-architecture.ps1`): `Copy-Item $s $t -Recurse` into an existing target nested content at `$t\$dirname\...` instead of overwriting in place — every re-sync of `.wiki/rules` would have doubled the tree. Now ensures the destination dir and copies its contents. The plan assumed the copy step was sound; it was not.
2. **CRLF false-DRIFT fixed** (commit `701455b`): git smudge filters (`core.autocrlf=true` + `eol=lf` in `.gitattributes`) materialize LF blobs as CRLF on Windows, so raw SHA256 byte-hashes reported phantom DRIFT after any satellite checkout. `-Check` now normalizes CRLF->LF before hashing both sides. Plan's hash-comparison design was correct in intent but platform-naive.
3. **Bootstrap ordering:** a satellite must run `pull-architecture.ps1 -Source <x>` once *before* a meaningful `-Check` (the wrapper needs a source to resolve). Already reflected in SATELLITE-BOOTSTRAP.md steps 3->4 order; noted here for future readers.

**Spec Reconciliation:** No Phase 4 wiki docs were written for this plan (executor-briefing format, not parcel format); documentation landed directly in HOW-TO.md section 6, README, .devops/README Transportability, and .devops/rules/agents-and-skills.md Sync Protocol — all reconciled against shipped behavior including the two fixes above.

**Dead-Code Backlog Entries (from execution):** None — no orphans found; the two legacy .gemini skills were deleted outright (W5), zero dangling references verified by grep.
