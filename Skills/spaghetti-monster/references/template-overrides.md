---
type: skill-override
target_skill: spaghetti-monster
project: YOUR-PROJECT-NAME
---

# [Project] Spaghetti-Monster Overrides

Project-specific implementations of the three Extension Hooks. Loaded during Stage 1.5 of the `spaghetti-monster` skill. If this file is missing, the hooks run in their default form (see `../SKILL.md`).

---

## Hook A — Domain Context Gate

### Glossary source

List the canonical domain glossary and any supplementary docs:

* `docs/wiki/core/03-glossary-of-terms.md`
* *(add supplementary docs here)*

### Domain-touching indicators

A function is domain-touching if it references any of the following terms **in a non-utility context** (i.e., not just an import path or string literal):

| Term | Meaning (short) | Hydrate from |
|---|---|---|
| *(define your domain terms here)* | | |

### Domain-touching modules (high-confidence list)

If the target file is in this list, always run Hook A regardless of the function's apparent complexity:

* *(list project-specific modules)*

### Required surface to user

Before Stage 2, present:

> *This function touches [DomainTerm]. Key invariants:*
> *- [list 2-4 invariants pulled from the wiki docs]*
> *- [list any non-obvious tribal knowledge from 18-knowledge-capture.md that applies]*
> *The refactor must preserve [list]. Proceed?*

If the user has not acked, halt. Domain refactors done blind are how production breaks.

---

## Hook B — Performance Budget Check

Define your project's performance budgets:

| Budget | Limit | Source of truth | How to measure |
|---|---|---|---|
| *(define budgets here)* | | | |

### Bundle size delta formula

```
delta = (new_bytes - old_bytes) / old_bytes
```

---

## Hook C — External Dependency Guard

List any rate-limited or contract-bound services that **must not be refactored carelessly**.

### C.1 — *(Service name)*

**Files:** *(list files)*

**Constraints:**
* *(list constraints)*

### C.2 — *(Service name)*

**Files:** *(list files)*

**Constraints:**
* *(list constraints)*

---

## Priority-ordered refactor recommendations

This section is populated by the project team after initial scans. Leave empty for the skill to operate on default heuristics.
