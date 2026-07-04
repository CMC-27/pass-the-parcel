---
name: build-roadmap
description: Make sure to use this skill whenever the user mentions building a product roadmap, creating a roadmap, defining phases, /build-roadmap, planning strategic phases, or wants to map out the future of a product at a high level above the backlog. Use it to create or update a product-roadmap.md file and optionally scaffold aligned backlog items for a given phase.
---

# Build Roadmap — Product Roadmap Builder

## Context: Document Hierarchy

The project operates on a two-tier planning hierarchy:

| Level | Document | Versioning | Location |
|---|---|---|---|
| **L2** | `product-roadmap.md` | Phases (Phase 1, 2, 3…) | `docs/backlog/` |
| **L3** | `<feature>-backlog.md` | Backlog items per phase | `docs/backlog/` |

A **roadmap phase** is the strategic container. **Backlog items** are the executable deliverables that fulfill a phase. One phase → many backlog items.

---

## 1. Discover Existing Roadmap

Before doing anything else, scan for an existing `product-roadmap.md` in the project's `docs/backlog/` directory. If one exists, read it in full to understand current phase definitions, scope, and version number.

---

## 2. Determine Mode (question)

Use the `question` tool to confirm intent. Present the three options:

- **Create** — Build a new roadmap from scratch (no roadmap exists yet).
- **Update** — Add a new phase or edit an existing phase in the current roadmap.
- **Scaffold Backlog** — Break a specific roadmap phase down into concrete backlog items.

Wait for the response before proceeding.

---

## 3. Phase Interview (question — per phase)

For **Create** and **Update** modes, interview the user for each phase being written or changed. Ask these questions using `question` before writing any file.

### Q1 — Strategic Intent
Ask: *"What is the core strategic focus of this phase? (What problem does it solve, and for whom?)"*
This becomes the `> Focus:` line in the roadmap.

### Q2 — Key Features
Ask: *"What are the main user-facing features or capabilities this phase delivers?"*
List at least one option per feature already known from context (pre-populate from conversation if the user has described them). Accept free-text additions.
Set `multiple: true`.

### Q3 — Technical Goals
Ask: *"What are the key technical milestones, infrastructure changes, or architectural decisions this phase requires?"*
Pre-populate options from codebase context where possible.
Set `multiple: true`.

### Q4 — Phase Boundary
Ask: *"What signals that this phase is complete? (e.g., a deployed feature, a passing benchmark, a shipped integration)"*
This becomes an implicit success criterion. Store it in the phase as a `> Done when:` callout if the user provides it.

Repeat Q1–Q4 for each additional phase the user wants to define.

---

## 4. Write or Update the Roadmap

After the interview, write `docs/backlog/product-roadmap.md` using the gathered answers.

### Phase template:
```markdown
## Phase N: [Phase Title]

> **Focus:** [One-sentence strategic intent from Q1.]
> **Done when:** [Success signal from Q4, if provided.]

### Key Features
- **[Feature Name]** — [User-facing description from Q2.]

### Technical Goals
- [Technical milestone from Q3.]
```

**Structural rules:**
- Separate phases with `---` horizontal rules.
- Include a metadata header table: Document Version, Project, Last Updated.
- Write features from the **user's perspective**.
- Write technical goals from the **engineering perspective**.
- Keep each phase self-contained.
- Increment `Document Version` on every meaningful update (1.0 → 1.1; major restructure → 2.0).

---

## 5. Scaffold Backlog Items (question — when Scaffold mode or on completion)

After writing the roadmap, use `question` to ask:
*"Would you like to scaffold backlog items for any of these phases now?"*
Present each phase as a selectable option. Set `multiple: true`.

For each selected phase, apply the **backlog** skill workflow per Key Feature:

1. Create a `<feature-slug>-backlog.md` (suffixed with `-backlog`) in `docs/backlog/` using the Pass-the-Parcel backlog template.
2. Set State Dashboard: `Status: BACKLOG`, `Active Persona: Planner`.
3. Populate Phase 1 (Expansion & Scoping) using the roadmap phase as source material.
4. Add a bullet entry to `docs/backlog/backlog-index.md` linking to the new file.
5. Include a `Roadmap Phase: Phase N` metadata line in the backlog plan header.

---

## 6. Output Summary

After all files are written, report:
- Files created or modified (with clickable links).
- Current phase count and titles.
- Any backlog items scaffolded (count + links).
- Any gaps or open decisions surfaced during the interview.
