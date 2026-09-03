---
name: build-roadmap
description: Make sure to use this skill whenever the user mentions building a product roadmap, creating a roadmap, defining themes or epics, /build-roadmap, planning strategic phases, or wants to map out the future of a product at a high level above the backlog. Use it to create or update a product-roadmap.md file and optionally scaffold aligned epics and implementation plans.
version: 1
updated: 2026-09-03
---

# Build Roadmap — Product Roadmap Builder

## Context: Document Hierarchy

The project operates on a three-tier planning hierarchy:

| Level | Document | Versioning | Location |
|---|---|---|---|
| **L1 — Theme** | `product-roadmap.md` | T1, T2, T3… | `.devops/backlog/` (master doc) |
| **L2 — Epic** | `product-roadmap.md` (sections) | T{n}-E1, T{n}-E2… | `.devops/backlog/` (master doc) |
| **L3 — Impl Plan** | `T{n}-E{n}.{impl}-{slug}-plan.md` | .01, .02, .03… | `.devops/plans/` |

A **Theme** is the strategic container (e.g. "Master Data Management"). An **Epic** is a large body of work within a theme (e.g. "Material Import & Integrity"). An **Implementation Plan** is a single executable deliverable (the parcel plan).

---

## 1. Discover Existing Roadmap

Before doing anything else, scan for an existing `product-roadmap.md` in the project's `.devops/backlog/` directory. If one exists, read it in full to understand current theme definitions, epic breakdowns, scope, and version number. Also read `.devops/backlog/backlog-index.md` to see what prefix codes are already assigned.

---

## 2. Determine Mode (question)

Use the `question` tool to confirm intent. Present the three options:

- **Create** — Build a new roadmap from scratch (no roadmap exists yet).
- **Update** — Add a new theme, edit an existing theme, or add/update epics within a theme.
- **Scaffold Implementation Plans** — Break a specific epic down into concrete implementation plans.

Wait for the response before proceeding.

---

## 3. Theme Interview (question — per theme)

For **Create** and **Update** modes, interview the user for each theme being written or changed. Ask these questions using `question` before writing any file.

### Q1 — Theme Name & Strategic Intent
Ask: *"What is the theme name and core strategic focus? (What problem does it solve, for whom?)"*
Determine the next available T-number by scanning `.devops/backlog/backlog-index.md`.

### Q2 — Key Features
Ask: *"What are the main user-facing features or capabilities this theme delivers?"*
List at least one option per feature already known from context. Accept free-text additions.
Set `multiple: true`.

### Q3 — Technical Goals
Ask: *"What are the key technical milestones, infrastructure changes, or architectural decisions this theme requires?"*
Pre-populate options from codebase context where possible.
Set `multiple: true`.

### Q4 — Theme Boundary (Definition of Done)
Ask: *"What signals that this theme is complete? (e.g., a deployed feature set, a passing benchmark)"*
This becomes a success criterion. Store it as a `> Done when:` callout.

### Q5 — Epic Breakdown
Ask: *"How would you break this theme into epics? Suggest a split based on natural work boundaries."*
Pre-populate with suggested epics based on Q2/Q3 answers. Each epic will get an E-number within the theme.
Set `multiple: true` to let the user select/refine.

Repeat Q1–Q5 for each additional theme.

---

## 4. Write or Update the Roadmap

After the interview, write `.devops/backlog/product-roadmap.md` using the gathered answers.

### Theme template (with epics):
```markdown
## T{n}: [Theme Name]

> **Focus:** [One-sentence strategic intent from Q1.]
> **Done when:** [Success signal from Q4.]

### Key Features
- **[Feature Name]** — [User-facing description from Q2.]

### Technical Goals
- [Technical milestone from Q3.]

### Epics
- **T{n}-E1: [Epic Name]** — [One-line description.]
  - Acceptance Criteria: [What qualifies as done for this epic.]
  - Impl Plans: *(added as scaffolded)*
- **T{n}-E2: [Epic Name]** — [One-line description.]
  - Acceptance Criteria: [What qualifies as done for this epic.]
  - Impl Plans: *(added as scaffolded)*
```

**Structural rules:**
- Separate themes with `---` horizontal rules.
- Include a metadata header table: Document Version, Project, Last Updated.
- Write features from the **user's perspective**.
- Write technical goals from the **engineering perspective**.
- Keep each theme and epic self-contained.
- Increment `Document Version` on every meaningful update (1.0 → 1.1; major restructure → 2.0).

### Update backlog-index.md
After writing/updating the roadmap, sync `.devops/backlog/backlog-index.md`:
- If new themes were added, add theme headings (e.g., `## T{n} — [Theme Name]`)
- If new epics were added, add epic subheadings (e.g., `### T{n}-E{n}: [Epic Name]`)

---

## 5. Scaffold Implementation Plans (question — when Scaffold mode or on completion)

After writing the roadmap, use `question` to ask:
*"Would you like to scaffold implementation plans for any epics now?"*
Present each epic as a selectable option with its T{n}-E{n} code. Set `multiple: true`.

For each selected epic, ask:
*"How many implementation plans does this epic need? Let's define each one — what's the title and one-line intent?"*
Collect a list of plan titles and intents from the user.

For each implementation plan, apply the **backlog** skill workflow:

1. Determine the next available implementation number by scanning `.devops/plans/` for existing plans with the same `T{n}-E{n}.` prefix.
2. Create the plan at `.devops/plans/{code}-{slug}-plan.md` using the Pass-the-Parcel template.
3. Set State Dashboard: `Status: BACKLOG`, `Active Persona: Planner`.
4. Populate Phase 1 with the epic's scope, key features, and technical goals from the roadmap.
5. Populate Phase 2 with relevant docs and code context discovered during research.
6. Add a table entry to `.devops/backlog/backlog-index.md` under the correct Theme/Epic section.
7. Include the epic's acceptance criteria in Phase 3 as pre-seeded questions.
8. Add a `Roadmap Theme: T{n} — [Theme Name]` metadata line in the plan header.

---

## 6. Output Summary

After all files are written, report:
- Files created or modified (with clickable links).
- Current theme count and titles.
- Epic count per theme.
- Implementation plans scaffolded (count + prefix codes + links).
- Any gaps or open decisions surfaced during the interview.
