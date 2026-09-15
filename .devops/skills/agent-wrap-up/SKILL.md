---
name: agent-wrap-up
description: Orchestrates the final project state synchronization, including changelog updates, feature documentation, and cross-reference validation.
version: 12
updated: 2026-09-16
---

# Agent Wrap-Up Skill

## Persona
You are the **Lead Context Architect**. Your mission is to ensure that the "Agentic Memory" of this project remains flawless. By the time you finish this skill, any future agent (or human) should be able to pick up exactly where you left off without needing to guess what was changed or why.

## Trigger Conditions
Activate this skill whenever:
1.  A primary development task is completed.
2.  The user says "wrap up", "we're done", "ship it", "archive this", or "good job".
3.  You are closing out a major feature branch or bug fix.

---

## Token Economy & Delegation Model

Wrap-up's token cost is concentrated in *reads* (wiki docs, backlog index), not edits. Two rules keep it lean without losing any benefit.

### Phase-Gating (Skip What Doesn't Apply)
Immediately after Phase 0, triage the diff and declare skips explicitly:
- Diff touches no `src/` files (docs/process-only session) → skip Phases 2–3.
- No plan in `.devops/plans/` was followed this session → skip Phase 4.
- Nothing new surfaced (orphans, debt, backlog matches, tribal knowledge) → skip Phases 5–6 with a one-line declaration in the changelog Why line.
- Phases 0, 1, and 7 are always mandatory.

### Subagent Delegation (Phases 2–6)
Phases 2–6 are read-heavy and parallelizable. On feature-scale sessions, dispatch two subagents **concurrently** after Phase 0. Each prompt must carry the wiki-first mandate (AGENTS.md rule 6) and the agent's exclusive write scope to prevent collisions:

| Agent | Owns (exclusive write scope) | Phases | Returns (summary only — never file contents) |
|-------|------------------------------|--------|----------------------------------------------|
| **A — Wiki Agent** | `.wiki/**` | 2, 3, plus Phase 5 `defer` rows and Phase 6 **app-domain** knowledge-capture | One-line-per-doc summary: created/updated/promoted + stale refs fixed + deviations logged |
| **B — Process Agent** | `.devops/plans/`, `.devops/archive/`, `.devops/backlog/`, `.devops/rules/process-lessons.md` | 4, 5 (minus `defer` rows), Phase 6 **machinery** knowledge-capture | Counts only: plans archived, backlog entries created/resolved/annotated, process lessons routed |

Delegation rules:
- Main agent retains Phases 0, 1 (changelog synthesis from the two returned summaries), and 7.
- Both subagents must follow the `@wiki-writer` discipline for any prose edits they make.
- On small sessions (a handful of files, no plan), running Phases 2–6 inline is acceptable — delegation pays off only when the read surface is large.

---

## Batch Scope (sprint batch wrap-up)

Wrap-up normally closes **one** plan. The **batch scope** closes a sprint's whole batched set in one pass. It is the follow-up step the `@sprint-run` batch defers to: that batch ends at `PHASE_9` with `claim_status: GATE_D_USER_APPROVAL` and never wraps itself up.

**Trigger — separate, operator-invoked.** Runs **after** the batch Gate D verdict and **outside** the batch loop — a distinct invocation, never an inline continuation of `@sprint-run`. Either the ordinary wrap-up path (any orchestrator) or `parcel-sprint` itself, which may spawn `wiki-writer` for the read-heavy wiki reconciliation.

**Input.** A list of plan codes. Omitted → every plan in `.devops/plans/` carrying `claim_status: GATE_D_USER_APPROVAL`. An empty list is a no-op, not an error.

**Rule — every phase once, except Phase 4.** Phases 0, 1, 2, 3, 5, 6 and 7a/7b run **once for the batch** exactly as written below: one diff, one changelog entry naming the theme, one wiki reconciliation, one backlog sweep, one consolidation, one gate pass. Only **Phase 4** iterates, once per plan in the input list. Batch scope is a *scope* on this skill — this skill remains the **only** wrap-up owner. Never create a second wrap-up skill.

**Confirmation gate — safety-critical, not simplifiable.** Before a plan is marked complete, assert **each** of the following for it, individually and from file/git evidence — never from the batch report:

1. bottom `Status` is `PHASE_9`;
2. front-matter `claim_status` is `GATE_D_USER_APPROVAL`;
3. the plan's per-plan runner outcome was `DONE <code>` (a `SKIP`, a `HALT`, or a missing outcome fails);
4. Phase 9 verification evidence is present (commands + exit codes) **and** the acceptance-criteria table is populated;
5. a commit with the exact literal `plan: <code>` exists on the trunk.

Then run the repo gates **once for the batch** — tests / lint / build, `check-parcel-prefix.ps1`, `check-utf8-agents.ps1`, `wiki_lint.py`, `wiki_coverage_check.py`. A red gate is a hard stop: it blocks the **whole** batch wrap-up, and a red tree is **never** auto-cleaned.

A plan failing **any** assertion is **carry-forward** — excluded from the batch, left exactly where it is, **never** marked complete. Report it with the failed assertion named. `ponytail:` the carry-forward report is prose, not a schema; upgrade path is a machine-readable per-plan verdict row if the batch ever needs to be driven programmatically.

---

## Execution Phases

### Phase 0: Mechanical Diff (Evidence, Not Memory)
Before writing anything, establish **what actually changed** — never rely on recall.

1. **Enumerate changed files mechanically**: run `git diff --name-only <last-wrap-up-ref>..HEAD` (use the commit hash of the last wrap-up, or `git log --oneline -1` on `.devops/logs/agent-changelog.md` to find it). If no prior ref exists, diff against the session's starting commit.
2. **Classify each changed file** into a wiki domain: `.wiki/` target (features / components / logic / database / core), `.devops/` process file, or other.
3. **Carry this list into Phases 2 and 3** — it is the authoritative work inventory. Every `src/` file in the diff MUST map to a wiki doc update or an explicit "no doc needed" decision recorded in the changelog entry.

> **Why this phase exists:** wrap-up used to rely on the working agent's memory of "what's new". Memory-based inventories silently drop files, which is how entire feature areas (e.g., the proposals engine suite) went undocumented while lint stayed green.

### Phase 1: The Audit Log (`.devops/logs/agent-changelog.md`)
The changelog records **when and why** — never *what files*. File inventories are derivable from each entry's `ref` commit (`git show --stat <ref>`) and already live in the plan's Completion Note; duplicating them here is what made the log unreadable (2026-09-09 audit: ~42% of its lines were file bullets).

1.  **Add Lean Entry**: Create a new section, **max 5 content lines**:

    ```markdown
    ## YYYY-MM-DD - Short outcome title

    **Why:** [1–3 lines — the decision, the lesson, or the reason it mattered. What changed is implied by the title + ref.]
    **Ref:** `<commit-hash>`
    ```

    - One line per session, not per change: multiple plans closed in one session get one entry naming the theme.
    - No "Files Modified" list, no "Agent" line, no "Database/API Changes: None" filler. Schema changes worth flagging go in the Why line ("added X column; backfill script at …").
    - Deep detail belongs where it already lives: the archived plan (Completion Note) and git history.
2.  **Size check (warning only)**: after adding the entry, check `(Get-Content .devops/logs/agent-changelog.md).Count`. If it exceeds **500 lines**, warn the user in one line — "agent-changelog is over the 500-line guideline (currently _n_ lines); consider archiving old entries manually" — and stop. **Never auto-prune or move entries**: automated pruning was tried on 2026-09-09 and corrupted the log's structure; the cap is a soft guideline enforced by human judgment only.

### Phase 2: Wiki Docs (Reconcile Code Against Spec)
With the spec-first pipeline, docs for planned behavior were already written in parcel Phase 4 (marked `status: in-progress`). Wrap-up **reconciles** rather than retro-documents.

1. **Reconcile against the spec**: for every doc written in parcel Phase 4, verify the implemented code matches the documented behavior and acceptance criteria. Log every deviation in the plan's Completion Note (`Spec Reconciliation`) — then fix the DOC to match reality (the code that shipped is the truth).
2. **Promote**: flip each reconciled doc from `status: in-progress` to `status: stable`. A doc that could not be reconciled stays `in-progress` with a logged deviation — never promote an unreconciled claim.
3. **Cover the leftovers**: review the Phase 0 diff for assets the spec didn't anticipate:
    - New React Hooks (`src/hooks/`)
    - New UI Components (`src/components/`)
    - New Utility Functions (`src/utils/`)
    - New API Routes or Database Collections
4. **Create/Update Docs** for those leftovers: Follow the `@wiki-writer` skill for all wiki prose — read the full target doc first, integrate at the semantically correct section, never append to the end.
    - If a new feature was added: Create a doc in `.wiki/features/<feature-name>.md`.
    - If a component was added: Create/Update `.wiki/components/<component-name>.md`.
    - If logic changed: Update the relevant doc in `.wiki/logic/`.
    - **Standard**: Include inputs (props/params), outputs, side effects, and a brief "Why this exists" section.

### Phase 3: Cross-Reference Synchronization (The "Context Web")
Ensure the rest of the documentation doesn't become "stale" or misleading.

1.  **Search for References**: Use `grep` to find all mentions of the functions, components, or files you modified within the `.wiki/` and `docs/` directories.
2.  **Validate Accuracy**:
    - Does the architecture diagram in `.wiki/core/00-system-index.md` still hold?
    - Do the state shapes in `.wiki/core/04-state-context.md` need updating?
    - Are there "Usage Examples" in other docs that now use an old API signature?
3.  **Update**: Apply surgical edits to ensure every doc reflects the current reality. Where an edit changes prose structure (not a one-line fact fix), follow the `@wiki-writer` discipline: rebalance the affected section so it reads as if written at once.

### Phase 4: Plan Finalization
> **Batch scope:** in a batch wrap-up this phase runs **once per plan in the input list**; every other phase stays once-per-batch. See § Batch Scope — including its confirmation gate, which must pass for a plan before Step 1 below.

1.  **Update Implementation Plans**: If you were following a plan in `.devops/plans/`, finalize it in this strict order:
    - **Step 1 — Mark Complete:** Open the plan file and set **both** `claim_status: COMPLETE` (front-matter) and the bottom State Dashboard `Status` to `COMPLETE`. Do this **before** moving the file.
    - **Step 2 — Add Completion Note:** At the bottom of the plan, add a `## Completion Note` section explaining the actual outcome and any deviations from the original plan.
    - **Step 3 — Archive:** Move the completed plan with `git mv` from `.devops/plans/[plan-name].md` to `.devops/archive/[plan-name].md` — no stub is left at the old location. The plan stays at the archive **root**; its `sprint:` front-matter field is what links it to a sprint. The sprint's `sprint.md` archives separately to `.devops/archive/sprints/sprint-{n}-<slug>/` at sprint close (see `.devops/rules/plan-lifecycle.md`).
    - **Step 4 — Return the branch (concurrent runs):** commit, merge `plan/<code>-<slug>` back to the workspace trunk, and prune the worktree. Do not leave an unmerged plan branch behind. **`@sprint-run` batch exception (`trunk-sequential`):** there is **no branch** — verify the working tree is the trunk and **skip merge/prune** entirely.

> **Archival is mandatory, not optional.** A plan that is done but still sitting in `.devops/plans/` is a ghost — it pollutes future agents' context. Every completed plan **MUST** be archived before wrap-up is considered complete.

### Phase 5: Backlog Reconciliation (`.devops/backlog/`)
Sweep the session for unfinished business, then reconcile it against the open backlog. Both halves own the same surface — one read pass, one mental model. Do not let discovered issues disappear into the archive.

Item detail lives in the `t{n}-<slug>-backlog.md` theme registers; `backlog-index.md` holds the Themes table + Triage Panel. Reconcile both.

**5a — Capture new discoveries**
1. **Orphan files / dead code**: if the session found orphan files, dead code, or ghost components, create a backlog plan at `.devops/backlog/{code}-{slug}-backlog.md` (`type: backlog`, `claim_status: QUEUED`) with affected file paths and a terse description, and add a row to the matching `t{n}-<slug>-backlog.md` theme register. Follow the `@backlog` skill.
2. **Spaghetti Triage rows**: dispose each row — `escalate-monster` (flag for the user to invoke `spaghetti-monster` directly), `new-parcel` (one backlog plan per row, same format as step 1), `defer` (log to `.wiki/core/18-knowledge-capture.md` — a `.wiki/` write, Agent A's scope under the Delegation Model), `inline-minor` (confirm resolved in the execution trace).
3. **Known issues / tech debt**: if any known limitations, workarounds, or debt were accepted during the session, create a backlog entry for each.

**5b — Reconcile the open backlog** (theme registers + `.devops/backlog/backlog-index.md`)
1. **Read the registers**: always read the full index and the theme registers before deciding nothing applies — items may be worded differently than the task; match by intent, not exact name.
2. **Match Against Completed Work**: an item qualifies for removal if the work fully implemented it, or explicitly superseded or made it irrelevant.
3. **Take Action**: **Move** fully-resolved items from the theme register's open table to its Completed table (no strike-through left behind); append `> Partially addressed by [task name] — remaining: [what's left]` to partials; leave unrelated items untouched.
4. **If no matches found**: state "No backlog items resolved by this session" and move on.

### Phase 6: Knowledge Capture & Consolidation
1. **Log Tribal Knowledge**: Review the conversation for any specific user preferences, "gotchas", or architectural decisions that aren't captured in formal documentation but should be remembered. Apply the `@knowledge-capture` **Admission Gate strictly** — only real deviations and valuable tribal knowledge qualify; everything else stays in the plan's Phase 10 log and Completion Note. **Budget: at most one new entry per session** — capture the lesson with the widest future reach; a second entry must be a genuinely different rule, not a restatement.
2. **Route and Update**: Use the `@knowledge-capture` skill to route each entry to its home — **app-domain** → `.wiki/core/18-knowledge-capture.md`; **machinery/process/tooling** (parcel/sprint pipeline, dev toolchain, scripts, docs tooling) → `.devops/rules/process-lessons.md`. Do **not** put machinery lessons in KC; that is the one-way ratchet this routing exists to stop.
3. **Consolidate (mandatory)**: Run `@knowledge-consolidation` in **tidy mode** (see its Modes table for scope). This is the step that keeps the log lean — skipping it makes KC growth one-way. Full audits are NOT part of wrap-up; they fire only on the consolidation skill's own triggers (KC above **25 entries**).

### Phase 7a: Coverage Gate (Hard Stop — both must exit 0)
Run the mechanical gates. **Wrap-up is not complete until both exit 0.** The gates are cheap (measured <1s each, tiny output) — run them inline in the main context; do NOT delegate them. Use `--quiet` on the lint gate for clean runs.

1. **Doc-graph lint**: `python scripts/wiki_lint.py --quiet` — structure anchors, body links, frontmatter fields/status, frontmatter `related-to`/`dependencies` links, hub→spoke coverage, index cataloguing (`[UNINDEXED]`/`[MISSING]`), hub reachability, orphans, encoding. (Omit `--quiet` when diagnosing failures.)
2. **Code-coverage gate**: `python scripts/wiki_coverage_check.py` — every non-test file in `src/utils`, `src/hooks`, `src/components`, `src/views` must carry wiki evidence: its domain index cites a real exported symbol (preferred), OR a wiki doc claims-binds its path, OR the retained filename/folder match. On gaps: add an index row citing a real exported symbol, add a `claims: source:` binding, or add to the script's `ALLOWLIST` with an explicit reason. The script docstring is canonical. Never skip silently.

On a failure, fix and re-run. **Do not proceed to 7b on a red gate.**

### Phase 7b: State Stamps (Checklist — easy to forget, not gated)
Mutations that keep downstream tooling honest. Do all three, then close out.
1. **Stamp freshness**: update the `Last Verified` date in the `.wiki/core/00-system-index.md` Quick Reference for every core doc touched this session.
2. **Machinery version bump**: for each modified file under `.devops/skills/` or `.devops/templates/`, bump its frontmatter `version:` by 1 and refresh `updated:` to today; for each modified file under `scripts/`, `.devops/agents/`, `.devops/rules/`, or `.wiki/rules/`, bump `machinery-version:` once in `.devops/sync-manifest.yaml`. Without this, satellites see `DRIFT` instead of `UPGRADE` on the next `-Check`.
3. **Record the wrap-up ref**: note the current commit hash in the changelog entry so the next Phase 0 diff has a clean baseline.

---

## Hard Stop
**Coverage Gate is a hard stop**: Phase 7a must exit 0 on both scripts before wrap-up is declared complete. A green lint with red coverage is a failed wrap-up. No placeholders — finish every phase you did not explicitly skip.

**Batch wrap-up is a hard stop too**: the § Batch Scope confirmation gate must pass for a plan before it is marked complete. A plan failing any assertion is carry-forward, never `COMPLETE`; a red repo gate blocks the whole batch wrap-up.
