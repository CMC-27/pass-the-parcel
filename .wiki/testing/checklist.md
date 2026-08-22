---
type: "testing"
name: "Test PR Checklist"
status: "template"
dependencies: []
description: "PR review checklist for test file compliance."
---

# Test PR Checklist

## Pre-Merge Gates

- [ ] All new features have corresponding tests
- [ ] Bug fixes include a regression test
- [ ] Mock usage follows the mocking standards
- [ ] No test exceeds the performance budget limits
- [ ] Test files follow the naming conventions
- [ ] No `describe.skip` or `it.skip` left in committed code
- [ ] No `console.log` / debug statements in test files
- [ ] Coverage: happy path + error states + edge cases covered

## Cleanup

- [ ] Test teardown properly resets state
- [ ] No leftover mocks affecting subsequent tests
- [ ] Test data uses factories or builders (not raw fixture dumps)
