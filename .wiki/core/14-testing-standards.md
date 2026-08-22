---
type: "core"
name: "Testing Standards"
status: "template"
dependencies: []
db_relations: []
description: "Gateway to the testing documentation subtree. Defines test patterns, mocking standards, performance budgets, and PR checklist."
---

# Testing Standards

This document is the gateway to the testing documentation subtree. It defines the high-level testing architecture and links to detailed standards.

---

## Testing Documentation

The testing subtree lives at `.wiki/testing/` and contains:

| Doc | Purpose |
|---|---|
| `testing-index.md` | Hub for all testing docs |
| `pattern.md` | Test taxonomy, naming, location, what-to-test |
| `mocking.md` | Shared mock conventions and setup |
| `performance.md` | Per-file test performance budgets |
| `checklist.md` | PR review checklist for test files |

---

## Core Principles

- Tests live next to source (`__tests__/` or `.test.*` sibling pattern)
- Unit tests for pure logic, integration tests for side-effectful code
- Mocks at module boundaries, not internal implementation details
- Every PR must include or update relevant tests

---

## See Also
- [Testing Index](../testing/testing-index.md)
- [Docs Blueprint](./17-docs-blueprint.md)
