---
type: "logic"
name: "Logic & Utilities Index"
status: "template"
dependencies: []
description: "Catalog of all utility functions, custom hooks, and core logic."
---

# Logic & Utilities Index

This index catalogs all utility functions, custom hooks, and core logic. Utilities are prefixed with `util-`, hooks with `hook-`, and schemas with `schemas-`.

---

## Utility Services

- `util-ai-client.md` - AI/LLM client integration
- `util-assembly-parser.md` - Assembly data parser
- `util-bom-calculator.md` - Bill of Materials calculator
- `util-bom-views.md` - BoM view formatters
- `util-calculated-truth.md` - Calculated truth engine
- `util-config.md` - Application configuration
- `util-csv-parser.md` - CSV file parser and validator
- `util-error-logger.md` - Error logging service
- `util-feature-flags.md` - Feature flag management
- `util-fetch-lookup-reverse-refs.md` - Lookup reverse reference fetcher
- `util-report-service.md` - Report generation service
- `util-storage.md` - Storage abstraction layer
- `util-transfer-lookup-references.md` - Lookup reference transfer utility

## Custom Hooks

- `hook-admin-form-save.md` - Admin form save logic
- `hook-assembly-keyboard.md` - Assembly keyboard shortcuts
- `hook-assembly-persistence.md` - Assembly state persistence
- `hook-batch-block-material-save.md` - Batch save for block materials
- `hook-count-up.md` - Animated count-up
- `hook-csv-import.md` - CSV import flow hook
- `hook-csv-import-confirm.md` - CSV import confirmation logic
- `hook-delete-impact.md` - Delete impact analysis
- `hook-use-entity-references.md` - Entity reference resolver
- `hook-use-master-data-counts.md` - Master data count queries

## Schemas

- `schemas-zod.md` - Zod validation schema definitions

---

## Naming Convention

All utility docs follow the pattern: `util-service-name.md`
All hook docs follow the pattern: `hook-hook-name.md`

---

## See Also
- [System Index](../core/00-system-index.md)
- [Database Index](../database/database-index.md)
