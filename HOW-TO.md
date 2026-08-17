# How-To: Agentic Development & Documentation Lifecycle

Welcome to this base-agnostic template library. This guide details the logical workflow and methodologies for building apps and managing documentation using the agentic skills provided in this workspace.

---

## 1. Bootstrapping & Core Setup

Every new project starts with aligning on the product context and establishing a solid, standardized documentation base.

```mermaid
graph TD
    A[Start New Project] --> B[Create Vision & North Star]
    B --> C[Run Documentation Bootstrap]
    C --> D[Standardized Wiki Library Structure]
```

### Phase A: Vision & North Star
*   **Skill:** `@app-vision-north-star`
*   **Purpose:** Synthesizes the codebase and requirements into an actionable, high-level strategic roadmap (`01-vision-north-star.md`). It aligns product objectives with engineering tasks and establishes constraints.

### Phase B: Documentation Bootstrap
*   **Skill:** `@wiki-bootstrap`
*   **Purpose:** Initializes a standardized folder structure under `docs/wiki/` (core contexts, architectural logs, and indices) to serve as the single source of truth for the agent.

---

## 2. Dual Agent Development Methodologies

Depending on the task's complexity, team style, or token optimization constraints, you can choose or combine two primary agentic coding patterns:

### Method A: Pass the Parcel (Stateless / Planning Mode)
*   **Skill:** `@pass-the-parcel`
*   **Execution:** Highly token-efficient and modular. A single markdown plan file (`docs/plans/...`) acts as the state carrier. Agents pass the file "parcel" to the next step, ensuring clean context boundaries.

### Method B: The Multi-Stage Code Pipeline
For deeply structured, robust feature implementation, use the sequential pipeline of specialized agent personas:

```mermaid
flowchart LR
    S[ptp-context-hunter] --> P[ptp-high-visionary]
    P --> H[ptp-grumpy-architect]
    H --> PO[ptp-smooth-operator]
    PO --> E[ptp-code-surgeon]
```

1.  **`ptp-context-hunter`**: Group A (Phases 1-3) — expands intent, runs Context Inventory (wiki docs + knowledge capture + source), resolves all ambiguity via interactive Phase 3 questioning, halts at Gate A.
2.  **`ptp-high-visionary`**: Group B (Phase 4) — reads scoped plan at Gate A, produces standard implementation plan via Simplicity Ladder (no code snippets unless necessary), halts at Gate B. Handles `PHASE_4_REVISION` fix rounds when a review fails.
3.  **`ptp-grumpy-architect`**: Phase 5 — **Spec & Logic Audit** of the text-based architecture (the plan contains no code). Evaluates logical completeness, edge cases, file boundary collisions, dependency gaps, YAGNI bloat, performance trade-offs, security, and architectural anti-patterns. Rejection sets `PHASE_4_REVISION`.
4.  **`ptp-smooth-operator`**: Phase 6 — audits plan for vision alignment, business logic, edge cases, and functional risk; syncs decisions to knowledge capture.
5.  **`ptp-code-surgeon`**: Group D (Phases 7-8) — **triggers only after Gate C is cleared by explicit user input**. Executes the approved spec with single-pass direct-to-disk writing (no intermediate Markdown code blocks), runs QA verification, halts at Gate D for user sign-off.

**Deterministic Rejection Loop (Gate C):** If Phase 5 or 6 fails review, the plan's status is set to `PHASE_4_REVISION` and returned to Group B (High-Visionary) for fixes before re-evaluating Gate C. **An unapproved plan never advances to execution.**

### Mode Selection
Plans support two operational modes:
- **`USER-MANAGED`** *(Recommended)* — the orchestrator halts at every gate (A, B, C, D) for explicit user approval.
- **`AUTO`** — gates auto-advance without user interaction. Hard halts still fire for destructive actions, build failures, and unresolvable blockers.

---

## 3. Knowledge Retention & Wrap-Up

As implementation concludes, the agent must document what it learned and clean up the workspace logs.

*   **Agent Changelog** (`docs/logs/agent-changelog.md`): A running chronological journal of agent actions, changes, and state.
*   **Knowledge Changelog** (`docs/logs/knowledge-changelog.md`): Tracks wiki health scan results and link integrity reports.
*   **`@knowledge-consolidation`**: Periodically structures, de-duplicates, and archives local developer knowledge into indexed snippets.
*   **`@agent-wrap-up`**: Runs final workspace state synchronization. It reviews modified files, updates logs, archives the plan, and closes the active loop.
*   **`@spaghetti-monster`**: Scans for high-complexity code regions and packages them into backlog parcel plans for later refactoring.

---

## 4. Pre-Deployment Validation

Before any code is pushed to production or committed to the remote repository, it must pass a strict security and quality gateway:

```mermaid
graph TD
    A[Code Changes Completed] --> B[Pre-Deployment Vibe Auditor]
    B --> C[Test-and-Deploy Skill]
    C --> D[Safe Git Push / Deploy]
```

*   **`@pre-deployment-vibe-auditor`**: Scans the codebase for "vibe-coded" anomalies, architectural drift, unoptimized queries, missing error handling, or security risks.
*   **`@test-and-deploy`**: Automates running the local test suite, executing linter rules, and verifying configurations before executing a safe, pre-validated git push or deployment.

---

## 5. Additional Utility Skills

| Skill | Purpose |
|---|---|
| `@wiki-query` | Read-only lookup and synthesis from wiki docs |
| `@wiki-lint` | Check wiki health, detect broken links, index drift |
| `@design-audit` | Audit UI compliance against design system |
| `@karpathy-guidelines` | Code writing and review best practices |
| `@backlog` | Create and manage backlog items |
| `@knowledge-capture` | Record tribal knowledge and decisions |
| `@skill-creator` | Create and iterate on new agent skills |
| `@true-or-false` | Validate requirements against codebase reality |
| `@ui-inventory-scanner` | Scan and catalogue UI elements |
| `@build-roadmap` | Create product roadmap with themes and epics |
| `@frontend-design` | Build production-grade frontend interfaces |

This framework ensures that any app built on top of this scaffold remains clean, well-documented, and safe to deploy.
