---
type: "core"
name: "Security Standards"
status: "approved"
dependencies: ["[auth-context]"]
db_relations: ["[primary_table]", "[secondary_table]"]
description: "Core security boundary definitions, data isolation, role-based access, agentic governance, and row-level policies for [APP_NAME]."
---

# Security Standards: Core Security Principles for Agentic Development

## Overview

This document defines the strict security perimeter, architectural guardrails, and coding standards required for all development within this repository. **Any autonomous agent, AI assistant, or human contributor modifying this codebase MUST adhere to these principles.**

AI-assisted development accelerates feature delivery but introduces unique risks such as architectural drift, hallucinated dependencies, and rapid misconfiguration. The policies below enforce a "secure-by-default" posture, prevent regressions, and manage the blast radius of deployed code.

---

## 1. Agentic Governance & Context Compliance

AI assistants must operate within strictly defined boundaries to prevent architectural drift:

* **Mandatory Context Loading:** Before generating code, agents must read and internalize the workspace rules file (`AGENT.md` / `GEMINI.md` / `.cursorrules`) and any relevant architectural documentation in `/docs/core`.
* **Framework Adherence:** Code generation must strictly follow the defined UI library, state management patterns, and testing requirements. Do not introduce new frameworks or patterns without explicit authorization.
* **Self-Correction:** If an instruction contradicts the established rules or security baselines, the agent must halt execution, explicitly flag the contradiction, and request clarification.

---

## 2. Strict Secret & Dependency Management

* **Zero-Credential Commits:** Never generate code that hardcodes credentials, API keys (e.g., [AI provider], payment processor), or database URIs.
* **`.gitignore` Verification:** Before creating or modifying environment variables (e.g., `.env`), verify that the file is explicitly listed in `.gitignore`.
* **Environment Variable Routing:** All authentication with third-party services must utilize environment variables (e.g., `VITE_[SERVICE]_API_KEY`). Warn immediately if there is any risk of exposing secrets to version control.
* **Dependency Pinning & Auditing:** Only import established, verified packages. When adding new dependencies to `package.json`, ensure strict version pinning to prevent supply chain attacks via hallucinated or typo-squatted packages.

---

## 3. Zero-Trust Backend & Data Security

* **Default to Deny-All:** When generating or modifying database schemas, tables, or collections (including security rules or SQL migrations), default all access to `deny all`.
* **Explicit Row-Level Security (RLS):** Require explicit, user-scoped policies for `SELECT`, `INSERT`, `UPDATE`, and `DELETE` operations. Ensure users can only read or mutate their own data.
* **Server-Side Validation:** Never rely solely on client-side validation. All incoming payloads must be strictly typed, sanitized, and validated on the server before interacting with the database.

---

## 4. API Security, Rate Limiting & Abuse Prevention

* **Mandatory Rate Limiting:** Implement rate limiting or request throttling on all public-facing API routes, serverless functions, and server actions by default.
* **Graceful Throttling:** Return appropriate HTTP status codes (e.g., `429 Too Many Requests`) when limits are exceeded. The application must handle these without crashing.
* **Prompt Injection Defenses (For AI Features):** Any endpoint that accepts user input and passes it to an LLM must sanitize the input to prevent prompt injection, jailbreaking, or unauthorized data exfiltration.

---

## 5. Comprehensive Error Handling & Observability

* **Eliminate Silent Failures:** Every network request and database transaction must be wrapped in appropriate error handling (e.g., `try/catch` blocks). Do not assume external calls will succeed.
* **No Stack Trace Exposure:** Log the exact point of failure with full context on the server, but return sanitized, generic error messages to the client.
* **Audit Logging:** Critical state changes (e.g., authentication events, role changes, financial transactions, approval locks) must generate secure, append-only audit log entries.

---

## 6. Blast Radius Control & Safe Releases

* **Feature Flag Integration:** Significant new features or logic changes should be wrapped in feature flags to allow instant toggle-offs in production without a full pipeline rebuild.
* **Stateless Deployments:** Ensure application code remains stateless to allow for rapid, seamless rollbacks across containerized or serverless environments.

---

## 7. AI-Native Testing & Continuous Verification

* **Autonomous Test Generation:** When generating complex logic or new components, agents must simultaneously generate the corresponding unit and integration tests.
* **Regression Prevention:** Tests must verify edge cases, malicious inputs, and unauthorized access attempts — not just the happy path.
* **CI Pipeline Integration:** Code pushed to version control must pass automated testing suites, linting, and static application security testing (SAST) before merging.

---

### Quick Reference: Vulnerability to Guardrail Mapping

| High-Risk Area | Agentic Vulnerability | Required Guardrail / AI Action |
| --- | --- | --- |
| **Data Exposure** | Auto-generating public DB schemas | Enforce [auth provider] Rules / RLS; Default `deny-all`. |
| **Credential Leaks** | Hardcoding API keys during prototyping | Validate `.gitignore`; use `process.env` / `VITE_*` exclusively. |
| **Supply Chain** | Importing hallucinated/malicious packages | Pin dependencies; verify package existence on `npmjs.com`. |
| **API Abuse** | Exposing unthrottled serverless functions | Wrap all endpoints in rate-limiters; handle `429`s. |
| **Architectural Drift** | Ignoring project design patterns | Mandatory read of agent rules file before generation. |
| **Production Outages** | Shipping untested "happy path" code | Wrap new logic in Feature Flags; generate tests automatically. |
