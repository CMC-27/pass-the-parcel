---
type: "database"
name: "Database Index"
status: "template"
dependencies: []
description: "Catalog of all database schema documentation."
---

# Database Index

This index catalogs all database schema documentation. Each schema has a dedicated doc prefixed with `db-`.

---

## Schema Categories

### Core Tables
- `db-projects.md` - Project records
- `db-assemblies.md` - Assembly definitions
- `db-materials.md` - Material catalog
- `db-blocks.md` - Material block groups

### Relationship Tables
- `db-assembly-components.md` - Assembly component line items
- `db-assembly-instances.md` - Assembly instances
- `db-assembly-selections.md` - Assembly selections

### Lookup & Reference
- `db-lookup-data.md` - Lookup/dictionary values
- `db-assembly-templates.md` - Assembly template definitions
- `db-assembly-variations.md` - Assembly variation definitions

### Feedback & Audit
- `db-block-feedback.md` - Block feedback records
- `db-feedback.md` - General feedback records
- `db-merge-audit-log.md` - Merge operation audit trail

### Auth & Settings
- `db-firebase-jwt-claims.md` - Firebase JWT claims schema
- `db-personal-settings.md` - User personal settings
- `db-users-invitations.md` - User invitations
- `db-rls-management.md` - RLS policy management

### Misc
- `db-block-materials.md` - Block-to-material associations

---

## Naming Convention

All schema docs follow the pattern: `db-table-name.md`

---

## When to Read Which Doc

| Task | Read First |
|---|---|
| Understanding project structure | `db-projects.md` |
| Assembly composition | `db-assemblies.md` + `db-assembly-components.md` |
| Material/block relationships | `db-materials.md` + `db-blocks.md` |
| Lookup values | `db-lookup-data.md` |
| User management | `db-users-invitations.md` |
| Security/RLS setup | `db-rls-management.md` |
| Feedback pipeline | `db-feedback.md` + `db-block-feedback.md` |

---

## See Also
- [System Index](../core/00-system-index.md)
- [Core Architecture](../core/05-core-architecture.md)
