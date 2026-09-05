---
title: Audits
tags: [devops, audits, state, true-or-false, q-and-a, ui-inventory]
status: active
owner: Wiki Owner
last-reviewed: 2026-09-06
related-to: [../README.md, ../skills/true-or-false/SKILL.md, ../skills/q-and-a/SKILL.md, ../skills/ui-inventory-scanner/SKILL.md]
---

# Audits

> Session artifacts produced by audit-style skills: True-or-False validation logs, Q&A discovery logs and UI inventory scan reports. Each file is a self-contained, dated record — read it top-to-bottom, it carries its own state.

## What Lives Here

| Pattern | Produced by | Contents |
|---|---|---|
| `true-or-false-<slug>-YYYY-MM-DD.md` | `@true-or-false` | Step-by-step knowledge-base validation log (Progress table, Q&A log, Change Plan Items, Verification Summary) |
| `<slug>-QA-YYYY-MM-DD.md` | `@q-and-a` | Requirements discovery log (Progress table, Q&A log, Synthesis) |
| `ui-inventory-<element>-YYYY-MM-DD.md` | `@ui-inventory-scanner` | UI element inventory report (summary stats, inventory table, anomalies) |

## Rules

1. **One file per audit session.** Never append a new session to an old file — create a new dated file.
2. **The log is the only state.** Update it after every question/step before asking the next one (JIT persistence).
3. **Change items move, logs stay.** Findings are promoted into a parcel plan in `.devops/plans/` (or an existing plan's Change Items); the audit log itself is never edited retroactively to "apply" fixes — it records what was found.
4. **Transient runs** may use `.opencode/plans/run-<slug>/` instead; promote the file here if the results matter beyond the run.
5. **Naming:** kebab-case slug + `YYYY-MM-DD` date, per the patterns above. No free-form names.

---

*Last reviewed 2026-09-06.*
