---
name: backlog
description: Make sure to use this skill whenever the user asks to add a feature, function, upgrade, idea, or task to the backlog. Use it to analyze the request, gather necessary codebase context, and create a comprehensive entry in a t{n} theme register plus a separate parked plan file. This skill creates PARKED items only — it does NOT execute, commit to a sprint, or plan execution.
version: 3
updated: 2026-09-13
---

# Backlog Management

> **Boundary:** This skill creates PARKED items only. It does not scope, plan, or execute. A parked plan lives at `.devops/backlog/<code>-<slug>-backlog.md` (`type: backlog`, `claim_status: QUEUED`). Commitment into a sprint queue is `@sprint-plan`; execution is claimed per `.devops/rules/plan-lifecycle.md` § Claim Protocol. The pipeline phases live in the bottom State & Gates — `QUEUED` means parked, `PHASE_1`+ means in flight.

## Stable Code

Every plan carries the stable code `T{theme}-E{epic}.{impl}` — assigned once, never changed. The code, not the folder, links the plan to its theme register, its sprint, and its archive record.

- **T{n}** — Theme (e.g. T1 = Parcel Pipeline Machinery)
- **E{n}** — Epic within the theme
- **.{impl}** — implementation number within the epic (e.g. `.01`, `.02`)

The plan filename follows: `<code>-<slug>-backlog.md` (parked) → `<code>-<slug>-plan.md` (committed / claimed). Older files may use `<slug>-backlog.md`; the code then lives only in the front-matter.

## Theme Registers vs Parked Items

Two file kinds share the `-backlog.md` suffix. The front-matter `type` is the discriminator:

- **Theme register** — `t{n}-<slug>-backlog.md` (`type: theme`): the stable home for a theme's epics + features, including a completed-rows table. `backlog-index.md` links to it from the Themes table.
- **Parked item** — `<code>-<slug>-backlog.md` (`type: backlog`): one parcel plan awaiting commitment.

Never store epic/feature detail in `backlog-index.md` itself — the index is a register, the theme file is the detail.

## 1. Analyze and Gather Context
When the user requests to add an item to the backlog:
- Analyze the user's request to understand the core feature, function, or upgrade.
- Proactively explore the workspace to gather relevant context (related files, current architecture, existing patterns, dependencies) useful when implementing this later.
- Do not ask the user for information you can find yourself by reading the codebase.

## 2. Determine Placement in the Hierarchy

1. **Read** `.devops/backlog/backlog-index.md` — the Themes table plus the Triage Panel.
2. **Read** the target `t{n}-<slug>-backlog.md` theme register to understand its existing epics/features.
3. **Determine** the Theme (T{n}) and Epic (E{n}).
4. **Determine** the next implementation number by scanning the theme register and `.devops/backlog/` for the highest existing `T{n}-E{n}.` number, then increment.
   - If this is the first plan in an epic, start at `.01`.
   - If a new epic is needed, add it to the theme register under the appropriate theme.
   - If a new theme is needed, create its register `t{n}-<slug>-backlog.md` from the skeleton below (`type: theme`) and add a row to the index Themes table.

### Theme register skeleton (`t{n}-<slug>-backlog.md`)

```markdown
---
type: "theme"
theme: T{n}
name: "{Theme Name}"
status: "active"
description: "{one-line theme scope}"
---

# T{n} — {Theme Name}

> {Why this theme exists and what "done" looks like for it.}

## E{n} — {Epic Name}

| Code | Title | Status | Description | Plan |
|------|-------|--------|-------------|------|
| {T..} | {title} | `QUEUED` | {one line} | [{code}-{slug}-backlog.md](./{code}-{slug}-backlog.md) |

## Completed

| Code | Title | Resolved | Note | Archive |
|------|-------|----------|------|---------|
| {T..} | {title} | {YYYY-MM-DD} | {one line} | [plan](../archive/{slug}-plan.md) |
```

## 3. Format the Backlog Entry
For each backlog item, create:

1. A row in the correct `t{n}-<slug>-backlog.md` theme register (under its epic), linking to the parked plan. Keep the description to one line.
2. A full early-prepared plan file at `.devops/backlog/<code>-<slug>-backlog.md` using the canonical Pass-the-Parcel template (full scaffold: Phases 1-10 + Wrap Up). Add the claim front-matter at the very top:

   ```yaml
   code: {T..}
   sprint: ""
   claim_status: QUEUED
   owner: ""
   claimed_at: ""
   last_touch: "{YYYY-MM-DD}"
   touches: ["{path/glob}", "..."]
   depends_on: ["{code}", "..."]
   ```

   And set the bottom **State & Gates**:
   - **Status** → `QUEUED` (parked, not in flight)
   - **Active Persona** → `Planner`
   - **File suffix** → `-backlog.md`

   Populate with the gathered context:
   - **Phase 1:** Intent, in-scope, out-of-scope.
   - **Phase 2:** Relevant files, current implementation, architectural considerations.
   - **Phase 3:** Edge cases / roadblocks / open design decisions (as open checklist items).
   - **Phase 4/5:** Tentative steps or placeholders only — the real plan is written at execution time.

## 4. Update the Index
- Ensure `backlog-index.md`'s Themes table links the theme register (add a row if the theme is new). Do **not** duplicate the item's detail in the index.
- If the item is urgent, place it in the Triage Panel at its tier (🔴/🟡/🟢/⚪/❄️); otherwise it lives only in the theme register.

> **DO NOT** change `claim_status` or move files between directories. `@sprint-plan` commits a plan into a sprint queue; `@pass-the-parcel` claims it at execution time.
