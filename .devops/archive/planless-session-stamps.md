---
type: "record"
name: "Plan-less Session Green Stamp"
status: "active"
owner: Operator
recorded: "2026-09-29"
related-to: [../rules/plan-lifecycle.md, ../skills/test-and-deploy/SKILL.md, ../skills/agent-wrap-up/SKILL.md]
---

# Plan-less Session Green Stamp

> **What this file is.** A durable home for the green stamp of a session that ran **without a plan**, so that `scripts/closeout_check.py --stamp` can find a record for the changelog commit such a session leaves behind.
>
> **This is an operator ruling, not the rule.** The canon defines the `Green stamp` as *"recorded as `Green stamp: <sha>` in each wrapped plan's `## Completion Note`"* — there is **no plan-less branch**. `@agent-wrap-up` already recognises a plan-less branch for skip declarations (the changelog index line's summary text), but the checker only scans `.devops/plans/` and `.devops/archive/`, so a plan-less changelog commit is structurally unrecordable and the push-time assertion stays red until the next plan wraps up.
>
> **Ruling (operator, 2026-09-29, at Sprint 13 close):** record the stamp here anyway. This is an explicit, one-time override of the canon's *"never re-record the stamp to match"*, chosen over halting the close and over leaving the push gate red. It is recorded in full so the line is never mistaken for the rule working as designed.

---

## Record

**Green stamp:** `a2bedbd` — the changelog locator at the moment of the ruling (`git log --format=%h -1 -- .devops/logs/agent-changelog.md`), a plan-less wrap-up commit.

**Plan-less changelog commits in this window** (each left `recorded == located` violated, because none has a Completion Note to record into):

| Commit | Session | Plan |
|--------|---------|------|
| `f7d4578` / `ba42217` | Skills review — re-outline & rebalance across `.devops/skills/` | none |
| `2cb23db` / `821c20a` | New `@user-testing` skill | none |
| `d2166b5` / `c7e489f`, `ebe76b4`, `a2bedbd` | Spawn contract + register close-outs | none |

**Known limitation of this record, stated so it is never trusted silently:** the stamp goes stale the moment *any* session lands another `.devops/logs/agent-changelog.md` commit. It relieves the gate at close-time; it does not close the defect.

**The defect still open:** either `closeout_check.py` learns to read a plan-less record, or plan-less sessions are barred from the changelog. Routed by the operator to the wrap-up + `@test-and-deploy`.
