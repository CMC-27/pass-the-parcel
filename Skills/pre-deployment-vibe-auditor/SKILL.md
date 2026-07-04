---
name: pre-deployment-vibe-auditor
description: Make sure to use this skill whenever the user mentions deploying, pushing code, checking production readiness, finalizing a feature, ending a session, or wrapping up work. Use it to scan for architectural drift, security risks, unoptimized queries, and missing CI/CD infrastructure, shifting vibe-coded code to a hardened production-ready state.
---

# Pre-Deployment & End-of-Session Vibe-Code Auditor

Systematically scan the current codebase and recent diffs across the following four phases. For every flagged item, report its **Status** (Vulnerable, Missing, or Drifting), **Evidence** (specific files and lines), and an **Actionable Fix** (exact code snippets, configuration rules, or terminal commands).

## 1. Agentic & Workspace Governance

Ensure the workspace configuration, instructions, and dependencies are structurally sound.

* **Maintain Agentic Context:** Verify that repository-level AI instructions (e.g., `AGENTS.md`) are present and accurate. Generate or update `AGENTS.md` with current UI libraries, state management choices, and strict testing requirements.
* **Enforce Dependency Hygiene:** Inspect `package.json` and lockfiles. Pin exact dependency versions, remove unused prototype packages, and check for outdated major libraries.

## 2. Zero-Trust Data Security & Access

Ensure all data layers and inputs are secure by default.

* **Enforce Database Row-Level Security (RLS):** Ensure RLS is active on all database tables (e.g., Supabase or Firebase firestore.rules). Generate role-based security rules or SQL policies to restrict access to authenticated owners.
* **Secure Secrets:** Scan all source files for hardcoded API keys, tokens, or private URIs. Extract secrets into `.env` references.
* **Validate and Sanitize Input:** Enforce schema validation (e.g., Zod) on all entry boundaries including API routes and server actions.
* **Prevent Dynamic Injection (XSS):** Sanitize dynamic HTML rendering. Secure any unsafe DOM manipulations (e.g., `dangerouslySetInnerHTML`, `innerHTML`) using a verified sanitizer library.

## 3. Reliability & Blast Radius Management

Prevent scale issues and ensure failures are gracefully isolated.

* **Integrate Feature Flags:** Propose a feature flag utility or service configuration for all newly introduced modules. Support instant environment-variable-driven rollbacks of new features.
* **Establish Error Boundaries:** Verify top-level error boundaries or global exception middleware are implemented to prevent full-screen application failures.
* **Optimize Database Query Patterns:** Identify and eliminate database queries inside loops (N+1 queries). Convert them to batched or joined operations to maintain performance at scale.

## 4. Release & Observability Infrastructure

Ensure automated guardrails and production monitoring are in place.

* **Configure CI/CD Pipelines:** Verify or generate a CI/CD workflow (e.g., GitHub Actions in `.github/workflows/`) that automatically runs linting, type-checking, and tests on pull requests.
* **Ensure Robust Test Coverage:** Propose parameterized test suites (e.g., Vitest, Playwright) protecting critical paths against future AI refactoring regressions.
* **Initialize Observability:** Verify structured logging or error tracking service initialization (e.g., Sentry, Datadog) is present at the application entry point.

## Output Dashboard

Present the audit results in a structured Markdown dashboard:
* Categorize findings clearly under the four phases.
* Use **🟢 PASS**, **🟡 WARNING**, and **🔴 CRITICAL FAIL** status indicators.
* Provide copy-pasteable, immediate code remedies for all **🔴 CRITICAL FAIL** items so the user can easily execute them.
