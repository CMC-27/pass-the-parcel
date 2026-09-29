---
name: sync-architecture
description: "Use when the user mentions syncing architecture, pulling template updates, updating parcel machinery, 'sync tools', 'pull latest skills/agents', or wants this workspace's .devops machinery refreshed from the template repo. Runs scripts/pull-architecture.ps1 against the current workspace root and reports drift."
version: 16
updated: 2026-09-29
---

# Sync Architecture (`sync-architecture`)

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
   | `DRIFT` | same version, different bytes | **locally customized copy — do not blindly overwrite; ask the user.** Offer to show the diff before re-running without `-Check`. A `DRIFT` on a portable file whose bytes changed under an unchanged `machinery-version` is **expected while the template's wrap-up window is open** — it closes at the template's own wrap-up — and the pull's diff is the safe check |
   | `MISSING` | never installed here | will be created by a sync |
   | `SOURCE-ABSENT` | manifest bug in the template | report to the template repo owner |
   | `PRUNE` | retired upstream but present in the target | a sync will delete it — **counts as out of sync** |
   | `AHEAD` | target's counter is ahead of the source | **halt-and-reconcile** — the `commonest cause` is a satellite-side bump of a counter it does not own (inert: stamped back down on the next pull); the sync refuses to write |
   | `MIGRATION` | the two counters crossed lineage shape (integer vs dotted) | **halt-and-reconcile** by hand before pulling; the sync refuses to write |

   Summarize counts + the IN SYNC / OUT OF SYNC line. Exit code 1 = out of sync (any
   `UPGRADE`/`DRIFT`/`MISSING`/`SOURCE-ABSENT`/`PRUNE`/`AHEAD`/`MIGRATION` verdict). A retired file reports
   `PRUNE` on its own line, never a parent-directory `DRIFT`.

3b. **Interpret `-Verify` output** (never writes; exit 0 = `VERIFIED`):

   - `[FAIL]` rows name exactly what is missing or mis-wired: `AGENTS.md` machinery
     markers, `opencode.json`'s `skills` array (it must be the V2-native **flat array** and
     declare `.devops/skills`), `base-context.md`, the wiki anchor
     (`.wiki/core/00-system-index.md`), or machinery a sync should have materialised.
     Fix the named item, then re-run.
   - A shape-broken `opencode.json` gets its own `[FAIL]`, reading
     `opencode.json is not valid JSON: …` and naming the defect — a comma left dangling before
     a closing brace or bracket, or braces/brackets that do not balance. The same
     host-monotone verdict the write-guard uses gates this check, so a config one host's parser
     would accept is never reported valid on this one. The engine's own `-SelfTest` asserts the
     row against a real config, and its child-failure output shape is stated once in
     `scripts/sync-architecture.ps1`'s header contract — cite it, do not restate it.
   - `[WARN]` rows are advisory only (e.g. `.ptp-source` not yet recorded) and never fail
     the run.
   - Machinery gates run check-only (prefix check without `-Sync`, UTF-8, wiki lint).
     A gate failure means the machinery itself is broken — report verbatim.

4. **First-time satellite** (many `MISSING` rows): after syncing, tell the user which
   repo-specific files still need authoring from the seed templates in `.devops/templates/`:
   `AGENTS.md`, `opencode.json`, `.opencode/plans/base-context.md` — then
   `scripts\check-parcel-prefix.ps1 -Sync` once parcel agents exist.

## Workflow Step 5 — Report Parcel Feedback Upstream

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
   claim_status: QUEUED   # field + enum canon: .devops/rules/plan-lifecycle.md § Claim Front-Matter

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

### Feedback rules (step 5)

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
- **Registry propagation, model stripping & config key-shape migration.** A sync reconciles the
  target's `base-context.md` registry capability-class rows (inserts rows the target lacks, prunes
  rows for retired keys — rows only, prose untouched), **removes every `model` binding it finds and
  never stamps one** (T1-E1.04), and migrates the target's `skills` key to the V2-native flat array
  — every write JSON-validated and reverted rather than shipped unparsable, and a shape it cannot
  rewrite safely is refused with a printed operator remedy. One exception is structural, not a
  model: the locked-preset host's `permission.task` allow-list is still stamped from the seed
  (see the step-4 comment in `scripts/lib/sync-bindings.ps1`). Full semantics live in
  `.devops/rules/agents-and-skills.md` § Sync Protocol — cited here, never restated.
- **Pull semantics are merge-by-name, not mirror and not additive.** The engine copies portable surfaces with `Copy-Item $s\* $t -Recurse -Force`: a file present in **both** repos is **replaced wholesale** (target-side edits to a portable file are lost — this is why the fold review in `@sprint-close` §8 is template-side), while a file present in the **target only** survives untouched (satellite-only residue is never pruned — "sync" can leave local files behind). Neither "mirror" nor "additive" predicts both; read every pull verdict with this model.
- A retired file inside a portable skill reports `PRUNE`, never a parent-skill `DRIFT`:
  declare it in `prune_files` like any other retirement — the parent-dir mask covers skills.
- **CI gates travel as a self-contained workflow file, never `workflow_call`, a composite action, or "documented wiring."** The invariant gates (prefix integrity, UTF-8, wiki lint, coverage, claims drift) must run in every satellite, and a template cannot enforce anything through a **second repo** at runtime or a documented block. Ship them as a plain portable `.github/workflows/machinery-gates.yml` (the `wiki-refresh.yml` precedent) riding `portable_files` — no secret, no wiring step. Its header states the **invariant-everywhere / template-identity** split once, and the template's own superset cites that split instead of restating it. *(process-lessons, 2026-09-25)*
- **Version discipline.** A skill's `version` MUST bump with any `SKILL.md` or reference change.
  Without the bump `-Check` reports `DRIFT` ("locally customized?") on stale machinery instead
  of `UPGRADE`, and operators learn to overwrite real local edits. After any machinery edit in the template repo itself, the wrap-up discipline bumps per-skill
  `version` / `machinery-version`; this skill only consumes those numbers, never edits them.
  The counter is **template-owned and sync-stamped — a satellite never bumps it**
  (`.devops/rules/plan-lifecycle.md` § Claim Protocol → *Counter Ownership*), and a
  satellite-side bump of a counter it does not own is the `commonest cause` of an `AHEAD`
  halt — the bump is inert and is stamped back down on the next pull.
