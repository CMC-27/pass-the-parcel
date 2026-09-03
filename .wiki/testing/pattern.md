---
title: "Testing Pattern"
type: "testing"
name: "Test Pattern"
status: "in-progress"
dependencies: []
description: "Canonical test patterns for the project."
---

# Test Pattern

## Test Taxonomy

| Type | Scope | Location |
|---|---|---|
| Unit | Pure functions, utilities, hooks | Next to source |
| Component | UI components with rendering | Next to component |
| Integration | Cross-module workflows | Feature-level directory |
| E2E | Full user journeys | `e2e/` directory |

## Naming

- Test files: `componentName.test.ts` or `componentName.test.tsx`
- Test suites: `describe('ComponentName', ...)`
- Test cases: `it('should do X when Y', ...)`

## What to Test

- Public API / interface, not internal implementation
- Edge cases and error states
- User-visible behavior
- Do NOT test: third-party libraries, constants, pure config
