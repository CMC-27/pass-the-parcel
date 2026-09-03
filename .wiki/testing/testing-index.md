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
| [Test Pattern](pattern.md) | Test taxonomy, file location, naming, what-to-test boundaries |
| [Mocking Standards](mocking.md) | Shared mock conventions, canonical mock location, override rules |
| [Test Performance Budgets](performance.md) | Per-file test performance budgets and hard limits |
| [Test PR Checklist](checklist.md) | PR review checklist for test file compliance |

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
