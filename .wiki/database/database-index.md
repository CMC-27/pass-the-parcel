---
type: "database"
name: "Database Index"
status: "template"
dependencies: []
description: "Catalog of all database schema documentation."
---

# Database Index

This index catalogs all database schema documentation. Each schema has a dedicated doc prefixed with `db-`. This is a **template index** — populate it from your app's real tables and collections; do not invent rows for schemas that don't exist.

---

## Schema Categories

Group rows by your app's own domains (e.g., core records, relationships, lookups, audit, auth). One table per group:

### [Category Name]
| Doc | Description |
|---|---|
| `db-[table-name].md` | [What the table stores, key relations] |

---

## Naming Convention

All schema docs follow the pattern: `db-table-name.md`

---

## When to Read Which Doc

| Task | Read First |
|---|---|
| [Understanding a core record] | `db-[table].md` |
| [Composition / relation questions] | `db-[parent].md` + `db-[child].md` |
| [Security / access setup] | `db-rls-management.md` or your auth docs |

---

## See Also
- [System Index](../core/00-system-index.md)
- [Core Architecture](../core/05-core-architecture.md)
