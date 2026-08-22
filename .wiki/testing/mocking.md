---
type: "testing"
name: "Mocking Standards"
status: "template"
dependencies: []
description: "Shared mock conventions and setup for tests."
---

# Mocking Standards

## Canonical Location

- Shared auto-mocks live in `src/test/mocks/` or `src/__mocks__/`
- Per-test overrides defined inline or in `__tests__/mocks/`

## Setup

- Global mocks configured in test setup files
- Module-level mocks with `vi.mock('module-name')` (Vitest) or `jest.mock('module-name')`
- Manual mocks for modules with complex setup

## Rules

- Prefer module-level mocking over manual dependency injection
- Mock at the boundary (network, file system, browser APIs)
- Do not mock what you don't own (third-party lib internals)
- Reset mocks between tests
