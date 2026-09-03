---
title: Plan Lifecycle
tags: [dev, rules, plans, parcel, lifecycle]
status: approved
owner: Wiki Owner
last-reviewed: 2026-08-19
related-to: [./README.md, ../.devops/skills/pass-the-parcel/SKILL.md]
---

# Plan Lifecycle

> How parcel plans live, move and retire. The plan file is the parcel: the entire system state lives in one self-contained markdown file, and each agent session is stateless — it reads the plan, executes one phase-group, updates the plan, and halts.

## The Parcel

- **Active plans:** `.devops/plans/[slug]-plan.md` — instantiated from `.devops/plans/template-plan.md`.
- **Backlog:** `.devops/backlog/` — early-prepared plans not yet picked up.
- **Archive:** `.devops/archive/` — completed plans, moved via `git mv` with **no stub left** at the old location.
- **Per-run workspace:** `.opencode/plans/run-[slug]/` — reviews, versions, decision log.
- **Template:** `.devops/plans/template-plan.md` — the canonical scaffold (cache-anchored State & Gates at the bottom).

## Lifecycle

`BACKLOG` -> `PHASE_1` -> `PHASE_3` -> `PHASE_4` -> `PHASE_6` -> `PHASE_8` -> `COMPLETE`

**Revision loop:** `PHASE_6` -> (Phase 5/6 fail) -> `PHASE_4_REVISION` -> `PHASE_4` -> `PHASE_6`

**Gates:** A (Scope) -> B (Plan) -> C (Review) -> D (Implementation)

**Modes:** `BLIND`/`SINGLE` (agent delegation) x `USER-MANAGED`/`AUTO` (gate behavior)

## Cache-Anchored State & Gates

- The State Dashboard + Gate Log are the **last section** of every plan file (`## 📍 State & Gates`).
- Gate transitions mutate ONLY those bottom rows; phase content above stays byte-stable to preserve LLM prefix-cache hits.
- Every "update the dashboard" instruction means "update the bottom State & Gates section".

## Rules

1. **The plan is the only state.** Never carry workflow state in conversation; always read the plan first and update it before halting.
2. **One phase-group per session.** Never skip ahead after a gate. Save the plan and halt.
3. **No gate is skippable.** Gates A–D are hard stops requiring the human.
4. **Single flight.** Only one plan executes against the working tree at a time. Two concurrent executors collide — serialize with the user.
5. **Gate C precedes all edits.** No file is touched until the plan has passed peer review and been approved for execution.
6. **Archive on completion.** A complete plan left in the plans folder is not done. `git mv` it to `.devops/archive/` — no stub.

---

*Last reviewed 2026-08-19. Changes to these rules require human sign-off.*