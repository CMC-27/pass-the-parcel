---
title: Surface Budget
tags: [dev, rules, simplicity, budget, machinery]
status: approved
owner: Wiki Owner
last-reviewed: 2026-09-17
related-to: [managed-simplicity.md, plan-lifecycle.md, agents-and-skills.md]
---

# Surface Budget

> **The maintenance instrument of [Managed Simplicity](managed-simplicity.md).** The Simplicity Ladder governs what may be **added**; this registry and its report govern what **already exists**. It measures **rule fan-out** — how many independently authored homes a canon rule has — and prints the numbers. It is **report-only**: `scripts/rule_fanout.py` always exits `0` and is never wired into `.github/workflows/validate.yml`. A report that could block would be a second gate over the gates.

## The Metric (defined once — this is the definition)

**Per registered rule:** `sites` = the number of walk files whose text contains the rule's **`signature:`** phrase after the strips below; `unauthorised` = `sites` − the canonical home − every declared `allowed-surface:` that passes the **pointer test**.

- **Walk roots** are declared as data in the registry block (`walk-roots:`). A directory root means every `*.md` under it; an entry that names a file is that file. **Outside the walk by construction:** `.devops/archive/**`, `.devops/logs/**`, `.devops/sprints/**`, `.devops/plans/*` other than `template-plan.md`, `.wiki/**`, `.github/**`, `CHANGELOG.md` (history), and every non-markdown file (manifests, scripts and config are never sites). **The corpus is the machinery surface only** — a machinery-surface figure is never a whole-repo figure.
- **Registry-block delimiters.** Exactly one `SURFACE-BUDGET:START` / `SURFACE-BUDGET:END` HTML-comment pair fences the block. Only the text between them is parsed; the surrounding prose never is. A missing or duplicated delimiter is the malformed-registry path.
- **Registry-block self-exclusion.** This file is **stripped from the walk by exact path**, exactly like a derived region. Without it the registry's own rows give every registered rule a floor of `1`.
- **Derived regions are stripped** before counting: (a) the PREFIX-LOCKED region of an agent file — the YAML frontmatter, then the leading run of lines byte-equal to the canonical prefix; (b) every `<!-- EMBED:START:… -->` … `<!-- EMBED:END -->` block. A rule whose signature appears only inside a derived region reports `0`.
- **`allowed-surfaces:` subtracts conditionally.** A declared surface subtracts only if **the same file** both contains the signature **and** names the `canonical-home:` path (the **pointer test**). A declared surface that fails it is printed as `unlinked-allowed-surface`, **stays counted**, and is a registry defect to fix — that is what stops the declaration from becoming a grandfather allowlist. A declared surface that names the canon but does not contain the signature grants nothing.
- **The registry holds no history and the script writes nothing.** The printed table **is** the trend: read two runs side by side, and read them against the recorded Axis 7 baseline in `.devops/backlog/MATURITY.md`.

## The Registry

**Format (flat `key: value` / `- item` subset only — no nested mappings), so the reader stays ~20 lines and no YAML dependency is added.**

- `walk-roots:` — one `- <repo-relative path>` per entry (directory or file).
- `rules:` — one `- ` row per rule, four cells delimited by ` :: `:
  `id :: signature :: canonical-home :: allowed-surfaces`
  where `allowed-surfaces` is a ` | `-delimited list of repo-relative paths (may be empty).
- `canonical-home:` is a repo-relative path. `signature:` must be distinctive enough that a zero-match rule is possible.
- `agreement:` — **optional.** One `- ` row per token that must appear on every declared surface, two cells delimited by ` :: `:
  `token :: <file> | <file> | ...`. The report prints `DISAGREE` for any declared surface that lacks the token or is absent from the walk. Report-only; it never affects the exit code.

<!-- SURFACE-BUDGET:START -->
walk-roots:
  - .devops/agents
  - .devops/skills
  - .devops/rules
  - .devops/templates
  - AGENTS.md
  - HOW-TO.md
  - README.md
  - CONTRIBUTING.md
  - OPERATING-PRINCIPLES.md
  - .opencode/plans/base-context.md
  - .devops/plans/template-plan.md
rules:
  - managed-simplicity :: We do one thing, we do it well, and we do it fast :: .devops/rules/managed-simplicity.md :: AGENTS.md | .devops/templates/AGENTS.template.md | .opencode/plans/base-context.md | .devops/templates/base-context.template.md
  - operating-principles :: reviewed, executed, verified change :: OPERATING-PRINCIPLES.md :: README.md | AGENTS.md
  - cache-first :: Cache-first :: OPERATING-PRINCIPLES.md :: README.md | AGENTS.md
  - claim_status :: claim_status :: .devops/rules/plan-lifecycle.md :: .devops/agents/parcel.agent.md | .devops/agents/ptp-parcel-fast.subagent.md | .devops/plans/template-plan.md | .devops/skills/agent-wrap-up/SKILL.md | .devops/skills/backlog/SKILL.md | .devops/skills/build-roadmap/SKILL.md | .devops/skills/pass-the-parcel/SKILL.md | .devops/skills/ptp-parcel-fast/SKILL.md | .devops/skills/spaghetti-monster/SKILL.md | .devops/skills/sprint-close/SKILL.md | .devops/skills/sprint-plan/SKILL.md | .devops/skills/sprint-run/SKILL.md | .devops/skills/sprint-status/SKILL.md | .devops/skills/sync-architecture/SKILL.md | .devops/templates/AGENTS.template.md | .devops/templates/SPRINTS.template.md | .devops/templates/base-context.template.md | .opencode/plans/base-context.md | AGENTS.md | HOW-TO.md
  - GATE_D_USER_APPROVAL :: GATE_D_USER_APPROVAL :: .devops/rules/plan-lifecycle.md :: .devops/agents/parcel-sprint.agent.md | .devops/plans/template-plan.md | .devops/skills/agent-wrap-up/SKILL.md | .devops/skills/pass-the-parcel/SKILL.md | .devops/skills/ptp-parcel-fast/SKILL.md | .devops/skills/sprint-close/SKILL.md | .devops/skills/sprint-plan/SKILL.md | .devops/skills/sprint-run/SKILL.md | .devops/skills/sprint-status/SKILL.md | .devops/templates/SPRINTS.template.md | .devops/templates/base-context.template.md | .opencode/plans/base-context.md | HOW-TO.md
  - auto-clear :: auto-clear :: .opencode/plans/base-context.md :: .devops/plans/template-plan.md | .devops/rules/plan-lifecycle.md | .devops/rules/process-lessons.md | .devops/skills/pass-the-parcel/SKILL.md | .devops/skills/ptp-parcel-fast/SKILL.md | .devops/templates/base-context.template.md | HOW-TO.md | README.md
  - context-isolated :: context-isolated :: .opencode/plans/base-context.md :: .devops/rules/process-lessons.md | .devops/skills/pass-the-parcel/SKILL.md | .devops/templates/base-context.template.md | HOW-TO.md | README.md
  - Chunked Write Discipline :: Chunked Write Discipline :: AGENTS.md :: .devops/skills/sprint-plan/SKILL.md | .devops/templates/AGENTS.template.md | .devops/templates/base-context.template.md | .opencode/plans/base-context.md
agreement:
  - PHASE_9 :: .opencode/plans/base-context.md | .devops/rules/plan-lifecycle.md | .devops/plans/template-plan.md
  - GATE_D_USER_APPROVAL :: .opencode/plans/base-context.md | .devops/rules/plan-lifecycle.md | .devops/plans/template-plan.md
  - MULTI :: .opencode/plans/base-context.md | .devops/rules/plan-lifecycle.md | .devops/plans/template-plan.md
  - SINGLE :: .opencode/plans/base-context.md | .devops/rules/plan-lifecycle.md | .devops/plans/template-plan.md
<!-- SURFACE-BUDGET:END -->

## Usage

```
python scripts/rule_fanout.py            # the report, over the live tree
python scripts/rule_fanout.py --root ..  # drive it against another root (fixtures)
```

Report-only. It prints a loud one-line notice and exits `0` when the block is absent or malformed, prints a table for a rule with zero matches, and **never** exits non-zero — there is no `--json`, no `--fail-on`, and no exit-code surface at all. It is surfaced by `@wiki-lint` (stdout, report-not-gate) and is **never** added to `.github/workflows/validate.yml`.

---

*Last reviewed 2026-09-17. Changes to these rules require human sign-off.*
