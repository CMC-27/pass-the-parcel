---
title: "Test File Naming Conventions"
type: "convention"
name: "Test Naming Convention"
status: "in-progress"
dependencies: []
description: "Test file and test case naming conventions."
---

# Test Naming Convention

## Rules

- Test files: `componentName.test.ts` or `componentName.test.tsx`
- Test suites: `describe('ComponentName', ...)`
- Test cases: `it('should [expected behavior] when [condition]', ...)`
- Integration tests: `featureName.integration.test.ts`
- E2E tests: `user-journey.e2e.ts`
- Mock files: `__mocks__/moduleName.ts`
