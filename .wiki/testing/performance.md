---
title: "Test Performance Budget"
type: "testing"
name: "Test Performance Budgets"
status: "in-progress"
dependencies: []
description: "Per-file test performance budgets and hard limits."
---

# Test Performance Budgets

## Hard Limits

| Metric | Limit |
|---|---|
| Modal mounts per test | 1 |
| `act()` calls per test | 5 |
| Setup lines per test file | 50 |
| Lines per test file | 200 |
| Async test timeout | 5000ms |

## Fork-Pool Rules (Vitest)

- Use `pool: 'forks'` for test isolation
- Memory limit per fork worker: 512MB
- Test files should not import heavy modules at top level if avoidable

## Enforcement

- CI pipeline enforces performance budgets via custom ESLint rules
- PR review gate blocks changes that exceed limits
