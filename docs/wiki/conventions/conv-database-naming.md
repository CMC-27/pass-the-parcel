---
type: "convention"
name: "Database Naming Convention"
status: "template"
dependencies: []
description: "Table, column, and index naming conventions."
---

# Database Naming Convention

## Rules

- Tables: snake_case, plural (`projects`, `assembly_instances`)
- Columns: snake_case (`created_at`, `user_id`)
- Primary keys: `id` (auto-increment or UUID)
- Foreign keys: `referenced_table_id`
- Indexes: `idx_table_column`
- Unique constraints: `uq_table_column`
- Junction tables: `table1_table2`
