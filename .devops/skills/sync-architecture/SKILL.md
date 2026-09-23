---
name: sync-architecture
description: "Use when the user mentions syncing architecture, pulling template updates, updating parcel machinery, 'sync tools', 'pull latest skills/agents', or wants this workspace's .devops machinery refreshed from the template repo. Runs scripts/pull-architecture.ps1 against the current workspace root and reports drift."
version: 10
updated: 2026-09-23
---

# SKILL: Sync Architecture (`sync-architecture`)

Refresh this satellite workspace's transportable machinery (skills, agents, rules, templates,
scripts, `.vscode`) from the template repo recorded in `.ptp-source`. Thin wrapper over
`scripts/pull-architecture.ps1`, which delegates to the template's `sync-architecture.ps1`.

## Workflow

1. **Identify the workspace root** (cwd). Refuse if no `.devops/` directory exists there —
   that is the wrong kind of workspace; tell the user to bootstrap from the template first
   (see `.devops/templates/SATELLITE-BOOTSTRAP.md`).

2. **Run the pull script** with the switch matching the user's intent:

   | User asks | Command |
   |---|---|
   | "what's new" / "check" / "is anything outdated" | `powershell -NoProfile -File scripts\pull-architecture.ps1 -Check` |
   | "preview" / "show me what would change" | `powershell -NoProfile -File scripts\pull-architecture.ps1 -DryRun` |
   | "sync" / "update machinery" / "pull latest" | `powershell -NoProfile -File scripts\pull-architecture.ps1` |
   | "verify" / "is my satellite wired up correctly" / "check my bootstrap" | `powershell -NoProfile -File scripts\pull-architecture.ps1 -Verify` |

   Never pass `-Source` unless the user explicitly supplies one — `.ptp-source` remembers it.
   If no `.ptp-source` exists, relay the script's hint: run once with `-Source <path-or-git-url>`.

3. **Interpret the verdict table** (`-Check` output) in plain language:

   | Verdict | Meaning | Action |
   |---|---|---|
   | `CURRENT` | identical | none |
   | `UPGRADE` | newer version upstream | safe to pull |
   | `DRIFT` | same version, different bytes | **locally customized copy — do not blindly overwrite; ask the user.** Offer to show the diff before re-running without `-Check` |
   | `MISSING` | never installed here | will be created by a sync |
   | `SOURCE-ABSENT` | manifest bug in the template | report to the template repo owner |
   | `PRUNE` | retired upstream but present in the target | a sync will delete it — **counts as out of sync** |

   Summarize counts + the IN SYNC / OUT OF SYNC line. Exit code 1 = out of sync (any
   `UPGRADE`/`DRIFT`/`MISSING`/`SOURCE-ABSENT`/`PRUNE` verdict). A retired file reports
   `PRUNE` on its own line, never a parent-directory `DRIFT`.

3b. **Interpret `-Verify` output** (never writes; exit 0 = `VERIFIED`):

   - `[FAIL]` rows name exactly what is missing or mis-wired: `AGENTS.md` machinery
     markers, `opencode.json` keys (`instructions` / `skills.paths`), `base-context.md`,
     the wiki anchor (`.wiki/core/00-system-index.md`), or machinery a sync should have
     materialised. Fix the named item, then re-run.
   - `[WARN]` rows are advisory only (e.g. `.ptp-source` not yet recorded) and never fail
     the run.
   - Machinery gates run check-only (prefix check without `-Sync`, UTF-8, wiki lint).
     A gate failure means the machinery itself is broken — report verbatim.

4. **First-time satellite** (many `MISSING` rows): after syncing, tell the user which
   repo-specific files still need authoring from the seed templates in `.devops/templates/`:
   `AGENTS.md`, `opencode.json`, `.opencode/plans/base-context.md` — then
   `scripts\check-parcel-prefix.ps1 -Sync` once parcel agents exist.

## 5. Report parcel feedback upstream

The reverse direction of the sync: when a satellite agent spots an issue or improvement
meant for the **template** repo mid-session (a machinery defect, a skill gap, a doc drift),
do not hold it in conversation — draft it where the operator can carry it in one action.

1. **Invoke the step** when the finding is template-worthy (it would change a portable
   surface: `.devops/**`, rule layers, scripts, templates). Satellite-local app concerns
   stay satellite-local — the fold-candidates protocol (hold, do not edit the template
   locally) is the *stance*; this outbox is its *transport*.
2. **Draft the item** into a `feedback/` directory at the satellite repo root — one `.md`
   file per finding, shaped exactly as this template's parked plan so the hand-carry is
   copy-only:

   ```
   feedback/<slug>-feedback.md
   ---
   code: TBD          # template assigns the stable T{theme}-E{epic}.{impl} at registration
   type: backlog
   claim_status: QUEUED
   ---

   # Backlog: <title>

   **Discovered:** <date> — one sentence of context.

   ## Findings
   | # | Gap | Evidence | Impact |

   ## What the fix does
   <the operator's/actionable intent, or "open">

   ## Open question
   <what the template side must decide, if anything>
   ```

3. **Operator carry contract** (human-gated, no automation): at the next template sync,
   the operator hand-carries each outbox item into the template repo — copy it as
   `.devops/backlog/<code>-<slug>-backlog.md`, register it in the owning theme register
   and the Triage Panel via `@backlog`, then delete the outbox item. "Reviewed" = triaged
   to a tier (🔴/🟡/🟢/⚪) or committed to a sprint by `@sprint-plan`.

### Rules

- **No secrets/credentials in feedback items** — the portable surface is secret-free; a
  drafted item travels through operator hands and must carry findings and evidence only.
- **The outbox is a message queue, not a plan queue** — lifecycle states apply only once
  the item is landed and claimed in a template repo; a `feedback/` file in the satellite
  is debris, and a sync legitimately leaves it untouched (target-only file survives).
- `ponytail:` one shape, no per-item template file shipped — the skill carries the draft
  shape inline instead of adding a template artefact, and items carry a placeholder code
  rather than inventing satellite-side code space.

## Rules

- `-Check` never writes; it is always safe to run first. Prefer starting any sync request with
  `-Check` and presenting findings before mutating.
- A real sync regenerates PREFIX-LOCKED agent prefixes from *this* workspace's `base-context.md`
  and runs the verification gates (prefix, UTF-8, wiki lint). Report gate failures verbatim —
  never suppress them with `-NoVerify` unless the user insists.
- **Registry propagation.** A sync rewrites the target's `opencode.json` model values and its
  `base-context.md` registry rows, **inserts** rows the target is missing (machinery v40+),
  and **prunes** rows for keys the source retired (machinery T1-E2.07+) — rows only, prose
  untouched — so a template-side Model Registry retirement reaches an already-bootstrapped
  satellite with no manual edit instead of leaving its prefix check red. The same holds
  for the `opencode.json` agent block: an entry the target already
  carries is never restructured (permissions, key order and formatting stay as authored — only
  its `model` value is stamped), **except** the locked-preset host's structural
  `permission.task` allow-list, which is stamped from the seed — but a registry key the target has **never authored** is
  **inserted** whole from the target's own synced seed (machinery v41+), so a newly shipped
  agent arrives runnable instead of arriving as a file the runtime never mounts. `BINDING-SKIP`
  now means only that neither the target nor the seed could supply an entry — still a loud
  failure in the target's own `check-parcel-prefix.ps1`.
- **Pull semantics are merge-by-name, not mirror and not additive.** The engine copies portable surfaces with `Copy-Item $s\* $t -Recurse -Force`: a file present in **both** repos is **replaced wholesale** (target-side edits to a portable file are lost — this is why the fold review in `@sprint-close` §8 is template-side), while a file present in the **target only** survives untouched (satellite-only residue is never pruned — "sync" can leave local files behind). Neither "mirror" nor "additive" predicts both; read every pull verdict with this model.
- A retired file inside a portable skill reports `PRUNE`, never a parent-skill `DRIFT`:
  declare it in `prune_files` like any other retirement — the parent-dir mask covers skills.
- **Version discipline.** A skill's `version` MUST bump with any `SKILL.md` or reference change.
  Without the bump `-Check` reports `DRIFT` ("locally customized?") on stale machinery instead
  of `UPGRADE`, and operators learn to overwrite real local edits. After any machinery edit in the template repo itself, the wrap-up discipline bumps per-skill
  `version` / `machinery-version`; this skill only consumes those numbers, never edits them.
