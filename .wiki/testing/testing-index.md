---
type: "testing"
name: "Testing Index"
status: "template"
dependencies: []
description: "Hub for all test architecture documentation."
---

# Testing Index

This index catalogs all testing standards and conventions for the project.

---

## Testing Docs

| Doc | Purpose |
|---|---|
| `pattern.md` | Test taxonomy, file location, naming, what-to-test boundaries |
| `mocking.md` | Shared mock conventions, canonical mock location, override rules |
| `performance.md` | Per-file test performance budgets and hard limits |
| `checklist.md` | PR review checklist for test file compliance |
| [Test PR Checklist](checklist.md) | checklist |
| [Mocking Standards](mocking.md) | mocking |
| [Test Pattern](pattern.md) | pattern |
| [Test Performance Budgets](performance.md) | performance |

---

## Testing Principles

- Unit tests for pure functions and hooks
- Component tests for UI behavior and interaction
- Integration tests for cross-module workflows
- Tests live adjacent to source files
- Shared mocks in a central `__mocks__` or `test` directory

---

## See Also
- [Testing Standards](../core/14-testing-standards.md)
- [Docs Blueprint](../core/17-docs-blueprint.md)
