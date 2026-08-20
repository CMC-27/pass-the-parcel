---
name: karpathy-guidelines
description: Make sure to use this skill whenever you write, review, or refactor code, or when the user asks to implement a feature or fix a bug. Use it to reduce common coding mistakes, avoid overcomplication, make surgical changes, surface assumptions, and define verifiable success criteria.
license: MIT
---

# Karpathy Guidelines

Apply these behavioral guidelines to minimize coding mistakes, derived from [Andrej Karpathy's observations](https://x.com/karpathy/status/2015883857489522876) on AI coding pitfalls. Bias toward caution and simplicity.

## 1. Plan and Surface Assumptions

State assumptions clearly and clarify ambiguity before writing code.

* **State Assumptions Explicitly:** Write out your assumptions before starting. If any detail is uncertain, ask the user.
* **Present Alternatives:** Present multiple valid interpretations to the user instead of picking one silently.
* **Propose Simpler Paths:** Advocate for simpler approaches. Push back constructively if a request leads to unnecessary complexity.
* **Surface Confusion Immediately:** Halt execution and list confusing aspects or ambiguities for user clarification when they arise.

## 2. Prioritize Simplicity

Write the absolute minimum code required to solve the problem. Avoid speculative development.

* **Adhere Strictly to Requirements:** Implement only features explicitly asked for.
* **Keep Code Concrete:** Write inline or direct code for single-use logic rather than inventing abstractions.
* **Limit Configurability:** Stick strictly to requested flexibility or configuration parameters.
* **Focus Error Handling:** Focus error handling on realistic, reachable scenarios.
* **Refactor for Brevity:** Rewrite code blocks if they can be implemented in significantly fewer lines (e.g., refactoring 200 lines to 50).
* **Self-Audit:** Review code before finalizing: ask if a senior engineer would find it overcomplicated, and simplify accordingly.

## 3. Execute Surgical Changes

Edit only what is necessary to satisfy the request. Maintain the existing codebase's style and boundary.

* **Target Edits Precisely:** Focus code modifications strictly on target areas. Keep adjacent code, comments, and formatting intact.
* **Respect Existing Style:** Match the existing coding patterns and stylistic conventions perfectly.
* **Isolate Refactoring:** Leave working code untouched unless the request explicitly requires a refactor.
* **Clean Up Owned Orphans:** Remove any imports, variables, or functions that your changes make unused.
* **Flag External Dead Code:** Keep pre-existing dead code intact, and report it to the user as a note rather than deleting it.

## 4. Define and Verify Success Criteria

Transform every task into verifiable goals and loop until verified.

* **Establish Clear Verification Goals:**
  * "Add validation" → Write tests/verification steps for invalid inputs, then satisfy them.
  * "Fix a bug" → Write a test/verification step reproducing the bug, then make it pass.
  * "Refactor" → Ensure all tests and functionality work perfectly before and after.
* **Document a Step-by-Step Plan:** State a brief sequential plan for multi-step tasks before beginning:
  ```
  1. [Step] → verify: [check]
  2. [Step] → verify: [check]
  3. [Step] → verify: [check]
  ```
* **Verify Continuously:** Run verification steps and tests at every milestone to ensure independent correctness.
