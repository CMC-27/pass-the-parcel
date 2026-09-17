---
title: Managed Simplicity
tags: [dev, rules, principle, simplicity, machinery]
status: approved
owner: Wiki Owner
last-reviewed: 2026-09-17
related-to: [plan-lifecycle.md, agents-and-skills.md, process-lessons.md, ../skills/ptp-high-visionary/SKILL.md]
---

# Managed Simplicity

> **The template's first principle.** Every rule, skill, script and register in `.devops/` is an application of it. It is stated **once**, here; the pointer surfaces carry a compact form plus a link.

## The Principle

> ### Managed Simplicity
>
> **We do one thing, we do it well, and we do it fast.**
>
> Simplicity is not the absence of structure; it is structure that earns its cost. One canonical home per rule. One deterministic check per invariant. Nothing that has stopped paying for itself. Robustness comes from those checks, not from defensive machinery — when an edge case appears we remove it or accept it out loud, never engineer around it.
>
> Depth is bought for outcomes. The wiki and the pipeline exist to keep an agent's context cheap and honest, cut bloat, and hold drift down — never for their own sake. A surface that stops doing that is retired.
>
> **Two instruments enforce this:** the **Simplicity Ladder** before anything is added (plan time), and the **surface-budget report** after it exists (maintenance).

## Why the maintenance instrument was missing

**Measured, not asserted (2026-09-16).** A single canon rule was independently authored in **4-5 surfaces** — `claim_status` 25 files / ~5 independent sites, `GATE_D_USER_APPROVAL` 20 / ~5, `auto-clear` 17 / ~5, `Chunked Write Discipline` 14 / **5 exact** — so one rule change cost ~5 synchronised edits and one retirement had to find all 5 by hand. `machinery-version` went 26 → 52 in roughly five days.

**Why the existing governance did not push back.** The template's governance verifies that machinery surfaces **agree** with each other. Nothing verified that there were **too many** of them, and this repo is self-referential (no `src/`, ~0 application tests), so only internal consistency applied — complexity grew without bound. The gradient is the finding: rules landed *after* the ("cite it, never restate it") doctrine sat at 1-3 surfaces, older rules sat at ~5. **The doctrine works; it was not enforced.**

**What was already here, and is cited rather than restated.** The Simplicity Ladder — `.devops/skills/ptp-high-visionary/SKILL.md` § *Climb the Simplicity Ladder* — governs what may be **added**. Nothing governed what **already exists**. This premise declares the principle the Ladder serves and names that missing maintenance instrument.

## The Two Instruments

| Instrument | When | What it does | Canon |
|---|---|---|---|
| **Simplicity Ladder** | **Plan time** — before anything is added | 7 rungs; stop at the first rung that holds. Rung 1 is "does this need to exist at all" | `.devops/skills/ptp-high-visionary/SKILL.md` § *Climb the Simplicity Ladder* |
| **Surface-budget report** | **Maintenance** — after a surface exists | Per registered rule, the raw site count and the unauthorised-restatement count, on one declared metric | `.devops/rules/surface-budget.md` + `scripts/rule_fanout.py` |

The report is **report-only**: it always exits `0` and is never added to `.github/workflows/validate.yml`. A report that can block would be a second gate over the gates. Deterministic **drift** checks stay exactly as they are; this instrument measures **size**, not agreement.

**The gate rule that accompanies the principle:** trim *duplication*, *overlap* and *dead capability*; **never delete a drift gate** — a gate that must go is *moved*, not removed. Gates get faster or they move; they do not get fewer.

## Homes (one canon, three pointers)

**The canon holds the statement; every pointer holds a compact operative sentence plus a link.** Do not grow the compact form — if it needs to say more, the canon changes instead. That is the anti-fan-out contract applied to the premise itself.

| Home | Form | Travels |
|---|---|---|
| `.devops/rules/managed-simplicity.md` — **canonical** | full statement + rationale | ✅ `.devops/rules` is a portable dir |
| `AGENTS.md` + `.devops/templates/AGENTS.template.md` | compact MACHINERY block citing the canon | ✅ via the seed |
| `.opencode/plans/base-context.md` + `.devops/templates/base-context.template.md` (prefix) | one operative line citing the canon | ✅ via re-sync into the 9 locked agents |

The compact form carried by all four pointer surfaces, byte-for-byte:

> **Managed Simplicity.** We do one thing, we do it well, and we do it fast. Structure must earn its cost: one canonical home per rule, one deterministic check per invariant, no surface that has stopped paying for itself. We do not build machinery for edge cases — we remove or accept them. Depth (the wiki, the pipeline) is bought for outcomes. See `.devops/rules/managed-simplicity.md`.

The premise is also **row 1 of the surface-budget registry** (`.devops/rules/surface-budget.md`), with its canonical home set to this file — the axis's own rule book obeys the axis.

---

*Last reviewed 2026-09-17. Changes to these rules require human sign-off.*
