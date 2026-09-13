# How-To: Agentic Development & Documentation Lifecycle

Pass the Parcel is a template for stateless, multi-agent software delivery and a governed, agent-first wiki. This guide follows the lifecycle end to end: bootstrap a workspace, run the parcel pipeline, retain knowledge at wrap-up, validate before deploy, and sync the portable machinery into a satellite.

---

## 1. Bootstrapping & Core Setup

Every new project starts by aligning on the product context, then building the documentation base.

```mermaid
graph TD
    A[Start New Project] --> B[Create Vision & North Star]
    B --> C[Generate and Verify Wiki Library]
    C --> D[Verified .wiki/ Structure]
```

### Phase A: Vision & North Star
*   **Skill:** `@app-vision-north-star`
*   **Purpose:** Turns the codebase and requirements into a strategic roadmap (`01-vision-north-star.md`), aligning product objectives with engineering tasks and defining the constraints.

### Phase B: Generate & Verify the Wiki Library
*   **Skills:** `@wiki-generate`, then `@wiki-bootstrap`
*   **Purpose:** `@wiki-generate` drafts the `.wiki/` structure — folder taxonomy, index rows, and doc skeletons — from the codebase. `@wiki-bootstrap` then verifies each doc against reality, one doc at a time. Generated docs stay `in-progress` until a human promotes them to `stable`.

---

## 2. The Parcel Pipeline

Every multi-step task runs through the same stateless parcel pipeline: a single markdown plan file (`.devops/plans/[code]-[slug]-plan.md`) carries all state. In the default `MULTI` topology each phase group is executed by one specialized sub-agent that reads the plan, does its job, updates the plan, and exits; in `SINGLE` topology (fast plan) the orchestrator plays those personas inline — see [§ Agent Topology](#agent-topology).

```mermaid
flowchart LR
    S[ptp-context-hunter] --> P[ptp-high-visionary]
    P --> H[ptp-grumpy-architect]
    H --> PO[ptp-smooth-operator]
    PO --> E[ptp-code-surgeon]
```

1.  **`ptp-context-hunter`** — Group A (Phases 1-3): expands intent, runs the Context Inventory (wiki docs + knowledge capture + source), resolves ambiguity via interactive Phase 3 questioning, halts at Gate A.
2.  **`ptp-phase3-answerer`** — Phase 3.5 (`AUTO` mode only): auto-resolves Phase 3 questions from the Research Map; any `Unresolvable:` entry falls back to asking the user.
3.  **`ptp-high-visionary`** — Group B (Phases 4-5): writes the wiki requirements spec + acceptance criteria, then the implementation plan (Simplicity Ladder; no code snippets except exact string literals), halts at Gate B. Also owns `PHASE_5_REVISION` fix rounds.
4.  **`ptp-grumpy-architect`** — Phase 6: **Spec & Logic Audit** of the text-based architecture (the plan contains no code). Evaluates logical completeness, edge cases, file boundary collisions, dependency gaps, YAGNI bloat, performance trade-offs, security, and architectural anti-patterns. Rejection sets `PHASE_5_REVISION`.
5.  **`ptp-smooth-operator`** — Phase 7: product review of vision alignment, user journey, and scope containment. Rejection sets `PHASE_5_REVISION`.
6.  **`ptp-code-surgeon`** — Group D (Phases 8-9): **triggers only after the plan is approved** (Gate C in `MULTI`; Gate B in `SINGLE`). Executes the approved plan single-pass direct-to-disk (no intermediate Markdown code blocks), runs QA verification, halts at Gate D for user sign-off.

**Deterministic rejection loop (Gate C):** if Phase 6 or 7 fails review, the plan's status is set to `PHASE_5_REVISION` and returned to Group B (High-Visionary) before Gate C is re-evaluated. **An unapproved plan never advances to execution.**

**Gates:** A (Scope, after Phase 3) → B (Spec & Plan, after Phase 5) → C (Peer Reviews, after Phase 7) → D (Implementation, after Phase 9). The lifecycle states are canonical in the `@pass-the-parcel` skill.

### Mode Selection
Plans support two operational modes:
- **`USER-MANAGED`** *(default)* — the orchestrator halts at every gate (A, B, C, D) for explicit user approval.
- **`AUTO`** — Gates A-C auto-clear after mechanical verification; **Gate D always halts for the human**. Hard halts still fire for destructive actions, build failures, and unresolvable blockers.

### Agent Topology
Independently of the mode, a plan runs in one of two topologies — chosen by **task complexity** (blast radius, contract change, risk, ambiguity, novelty) and confirmed by the user at plan start:
- **`MULTI`** *(default — comprehensive plan)* — the orchestrator delegates each phase group to its `ptp-*` sub-agent; Group C runs as independent, context-isolated reviewers; 4 gates (A-D).
- **`SINGLE`** *(fast plan)* — the orchestrator executes each group's persona inline (no sub-agent spawns); Group C is skipped and Gates B+C merge into one approval at Gate B (Gate C `N/A`); cheapest for local, low-risk changes.

Gate A and Gate D always halt for the human in both topologies. Record the choice in the plan's **Plan Settings** block at the **TOP** of the plan file (frozen config — never the bottom State & Gates). Full contract: `@pass-the-parcel` § Agent Topology.

#### Parcel-Fast (locked preset)
`parcel-fast` is a second selectable orchestrator that ships the two axes pre-set to **`AUTO` + `SINGLE`**. It skips the Mode and Topology questions and, because `opencode.json` binds it `task: deny`, it **cannot** spawn a sub-agent. It runs the same pipeline, plan file, lifecycle, and gates as `parcel`; only the selection questions and the `MULTI` dispatch differ. Gate A and Gate D still halt. Presets are declared in the `## Orchestrator Presets` table of `.opencode/plans/base-context.md`.

#### Sprint Batch Runner (`@sprint-run`)
When a sprint is open and its queue is committed, `@sprint-run` (host agent `parcel-sprint`) runs the whole eligible queue in one unattended pass. It evaluates the eligibility predicate (no unmet `depends_on`; no `touches` overlap with any plan in `.devops/plans/`, including plans already batched to `PHASE_9`) **immediately before each claim**, presents an informed **run preview** (eligible plans, skip list with reasons, orphan re-adoptions, a blast radius) labelled a **forecast**, then for each plan claims it on the trunk and spawns one `ptp-parcel-fast` subagent (locked `AUTO` + `SINGLE`, one fresh context per plan, Phases 1→9). Plans terminate at `PHASE_9` with **Gate D `OPEN`**; the batch emits one consolidated report and one human verdict covers the whole batch — Gate D is deferred, never skipped. Two deviations from the default protocol apply: **batched Gate D** and a **trunk-sequential** claim (no `git worktree`). Hard failures stop the line immediately and emit a partial report. Full contract: `.devops/rules/plan-lifecycle.md` § Deviations and the `sprint-run` skill.

---

## 3. Knowledge Retention & Wrap-Up

As implementation concludes, the agent must document what it learned and clean up the workspace logs.

*   **Agent Changelog** (`.devops/logs/agent-changelog.md`): A running chronological journal of agent actions, changes, and state.
*   **`@knowledge-consolidation`**: Periodically structures, de-duplicates, and archives local developer knowledge into indexed snippets.
*   **`@agent-wrap-up`**: Runs final workspace state synchronization. It reviews modified files, updates logs, archives the plan, and closes the active loop.
*   **`@spaghetti-monster`**: Scans for high-complexity code regions and packages them into backlog parcel plans for later refactoring.

---

## 4. Pre-Deployment Validation

Before any code is pushed to production or committed to the remote repository, it must pass a strict security and quality gateway:

```mermaid
graph TD
    A[Code Changes Completed] --> B[Pre-Deployment Vibe Auditor]
    B --> C[Test-and-Deploy Skill]
    C --> D[Safe Git Push / Deploy]
```

*   **`@pre-deployment-vibe-auditor`**: Scans the codebase for "vibe-coded" anomalies, architectural drift, unoptimized queries, missing error handling, or security risks.
*   **`@test-and-deploy`**: Automates running the local test suite, executing linter rules, and verifying configurations before executing a safe, pre-validated git push or deployment.

---

## 5. Additional Utility Skills

| Skill | Theme | Purpose |
|---|---|---|
| `@wiki-query` | Wiki | Read-only lookup and synthesis from wiki docs |
| `@wiki-lint` | Wiki | Check wiki health, detect broken links, index drift |
| `@wiki-generate` | Wiki | Draft index rows and doc skeletons from the codebase (structure) + ingest an `openwiki/` OKF bundle |
| `@wiki-update` | Wiki | Refresh only the docs a `git diff` invalidated; stamp `last-reviewed` |
| `@wiki-bootstrap` | Wiki | Verification pass over the wiki, one doc at a time (v2) |
| `@design-audit` | Quality | Audit UI compliance against the design system |
| `@karpathy-guidelines` | Quality | Code writing and review best practices |
| `@ui-inventory-scanner` | Quality | Scan and catalogue UI elements |
| `@frontend-design` | Quality | Build production-grade frontend interfaces |
| `@backlog` | Product | Create and manage backlog items |
| `@build-roadmap` | Product | Create a product roadmap with themes and epics |
| `@true-or-false` | Product | Validate requirements against codebase reality |
| `@knowledge-capture` | Knowledge | Record tribal knowledge and decisions |
| `@skill-creator` | Knowledge | Create and iterate on new agent skills |
| `@sync-architecture` | Machinery | Pull template machinery updates into a satellite workspace |

---

## 6. Syncing Machinery into a Satellite Workspace

This repo is the **template**; any other workspace is a **satellite** that consumes the portable surface (`.devops/skills/`, `.devops/agents/`, rule layers, `.devops/templates/`, `.vscode/`, sync scripts).

### One-time bootstrap (push)
A satellite has no pull script yet, so first contact goes through the template's push engine:

```powershell
powershell -NoProfile -File <template>\scripts\sync-architecture.ps1 -Target <satellite>
# or from git: clone to %TEMP%\ptp and run the same command from there
```

Then author the three repo-specific files from the seeds in `.devops/templates/` (`AGENTS.md`, `opencode.json`, `.opencode/plans/base-context.md`) — see `.devops/templates/SATELLITE-BOOTSTRAP.md` for the full checklist.

> **v20 migration (opencode.json).** If you previously deleted the `agent` block from `opencode.json` (the old seed told you to), that layout still validates — `check-parcel-prefix.ps1` prints `SKIP` rather than failing. To run the parcel orchestrator in the opencode runtime, re-copy `.devops/templates/opencode.template.json` and fill the `<your provider/model>` placeholders.

### Ongoing pulls
Record the source once — `scripts\pull-architecture.ps1 -Source <path-or-git-url>` writes `.ptp-source` — then say "sync architecture" (`@sync-architecture`) or run `scripts\pull-architecture.ps1`. Add `-Check` for a read-only drift report with per-item verdicts:

| Verdict | Meaning |
|---|---|
| `CURRENT` | identical |
| `UPGRADE` | newer version upstream — safe to pull |
| `DRIFT` | same version, different bytes — locally customized, diff before overwriting |
| `MISSING` | never installed here — a sync will create it |
| `SOURCE-ABSENT` | manifest lists it but the template lacks it — manifest bug |
| `PRUNE` | listed in `prune_files` and present in the target — a sync will delete it (counts as out of sync) |

`-Check` exits `1` (`OUT OF SYNC`) when any of `UPGRADE`/`DRIFT`/`MISSING`/`SOURCE-ABSENT`/`PRUNE` is present; a retired file reports `PRUNE`, not a parent-directory `DRIFT`.

### Versioning
Each skill carries an integer `version:` + `updated:` date in its frontmatter; `.devops/sync-manifest.yaml` carries one `machinery-version:` covering agents/rules/scripts/templates as a coordinated set. `@agent-wrap-up` owns the bump discipline: modify a portable file → bump its version (and `machinery-version` for non-skill surfaces) → satellites see `UPGRADE`, not `DRIFT`.

### Model binding
The parcel pipeline routes by capability class — `orchestration`, `retrieval/inventory`, `retrieval/Q&A`, `deep planning/authoring`, `adversarial review`, `product review`, `execution` — never by vendor model name in prose. The Model Registry in `.opencode/plans/base-context.md` declares each agent's binding; each satellite binds the runtime in its own `opencode.json` (`agent.<name>.model`). Swapping providers is a config edit, not a machinery sync. CI (`.github/workflows/validate.yml`) enforces the prefix, encoding, wiki, JSON, SelfTest, and coverage gates on every push; `scripts/sync-architecture.ps1 -SelfTest` smoke-tests the transport engine itself on `ubuntu-latest`.

---

## 7. Wiki Evidence & Drift Automation

Docs may carry Grounded Claims (`claims:` frontmatter, `source: path#symbol` + a content hash). `scripts/wiki_claims.py check` fails CI when a claimed source changed; `affected` lists the docs a diff invalidated; `update` re-stamps. `@wiki-generate` drafts structure and `@wiki-update` refreshes incrementally. `scripts/wiki_okf.py export` projects the wiki into an OpenWiki/OKF v0.2 bundle and `import` ingests one back as `in-progress` drafts (registered in the area index, existing docs skipped); `scripts/wiki_visualize.py` writes the static graph into `docs/`. A secret-free scheduled job (`.github/workflows/wiki-refresh.yml`, weekly cron + manual dispatch) runs the claims checker and raises a `wiki-drift` issue when docs drift, closing it again once clean.

---

## See Also
- [README.md](README.md) — what Pass the Parcel is and its two jobs
- [AGENTS.md](AGENTS.md) — the agent entry point and task lookup
- [`.devops/README.md`](.devops/README.md) — operational state and the transportable machinery
