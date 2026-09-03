---
type: "ref"
name: "Reference Index"
status: "template"
dependencies: []
description: "Catalog of external reference materials linked from wiki docs."
---

# Reference Index

This index catalogs reference materials in `ref/` — external specifications, generated reports, and third-party documentation snapshots that wiki docs link to but that are not part of the core doc structure. This is a **template index** — populate it as references are added; do not invent rows for files that don't exist.

---

## Reference Materials

| Item | Origin | Linked From | Purpose |
|---|---|---|---|
| _(one row per file or subdirectory)_ | [where it came from] | `[wiki doc](path)` | [why it's kept] |

---

## Rules

- Every item must note its origin and purpose (see `README.md` in this folder).
- Reference material is read-only context — never edit an external snapshot to make a link work.
- When a reference goes stale, replace or delete it and update the linking doc in the same change.

---

## See Also
- [System Index](../core/00-system-index.md)
