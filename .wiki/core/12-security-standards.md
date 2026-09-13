---
title: "Security Standards: Core Security Principles for Agentic Development"
type: "core"
name: "Security Standards"
status: "stable"
format-version: 1
dependencies: []
db_relations: []
description: "Core security boundary definitions, data isolation, role-based access, agentic governance, and row-level policies."
claims:
  - id: agents-read-operating-rules
    source: AGENTS.md#Core Development Rules
    hash: sha256:bb8f81e7aab0ce253879b2f8669d62b80a3f49d416e2392a01696fd947ac596f
  - id: env-vars-excluded-from-git
    source: .gitignore#.env
    hash: sha256:5ac7f6640c04da066f021c3f8bdc2f9d901ee1b93d0bdd22243a937908f627d3
---
# Security Standards: Core Security Principles

## Overview

This document defines the strict security perimeter, architectural guardrails, and coding standards required for all development within this repository. **Any autonomous agent, AI assistant, or human contributor modifying this codebase MUST adhere to these principles.**

---

## 1. Agentic Governance & Context Compliance

AI assistants must operate within strictly defined boundaries to prevent architectural drift:

* **Mandatory Context Loading:** Before generating code, agents must read the workspace rules file (`AGENTS.md`) and the wiki hub (`.wiki/core/00-system-index.md`).
* **Framework Adherence:** Code generation must strictly follow the defined UI library, state management patterns, and testing requirements.
* **Self-Correction:** If an instruction contradicts the established rules or security baselines, the agent must halt execution, explicitly flag the contradiction, and request clarification.

---

## 2. Strict Secret & Dependency Management

* **Zero-Credential Commits:** Never generate code that hardcodes credentials, API keys, or database URIs.
* **`.gitignore` Verification:** Before creating or modifying environment variables, verify the file is explicitly listed in `.gitignore`.
* **Environment Variable Routing:** All authentication with third-party services must utilize environment variables.
* **Dependency Pinning:** Only import established, verified packages. Pin strict versions to prevent supply chain attacks.

---

## 3. Zero-Trust Backend & Data Security

* **Default to Deny-All:** When generating or modifying database schemas, default all access to `deny all`.
* **Explicit Row-Level Security (RLS):** Require explicit, user-scoped policies for all operations. Users can only read or mutate their own data.
* **Server-Side Validation:** Never rely solely on client-side validation. Validate, sanitize, and type-check all payloads server-side.

---

## 4. API Security, Rate Limiting & Abuse Prevention

* **Mandatory Rate Limiting:** Implement rate limiting on all public-facing API routes.
* **Graceful Throttling:** Return `429 Too Many Requests` when limits are exceeded.
* **Prompt Injection Defenses:** Sanitize user input before passing to LLMs.

---

## 5. Comprehensive Error Handling & Observability

* **Eliminate Silent Failures:** Every network request and database transaction must have error handling.
* **No Stack Trace Exposure:** Log errors server-side; return sanitized messages to the client.
* **Audit Logging:** Critical state changes must generate secure, append-only audit log entries.

---

## 6. Blast Radius Control & Safe Releases

* **Feature Flag Integration:** Significant new features should be wrapped in feature flags.
* **Stateless Deployments:** Keep code stateless, so a rollback is a redeploy of the previous version.

---

## 7. AI-Native Testing & Continuous Verification

* **Autonomous Test Generation:** When generating complex logic, simultaneously generate corresponding unit and integration tests.
* **Regression Prevention:** Tests must verify edge cases, malicious inputs, and unauthorized access attempts.
* **CI Pipeline Integration:** Code must pass automated testing, linting, and SAST before merging.

---

### Quick Reference: Vulnerability to Guardrail Mapping

| High-Risk Area | Agentic Vulnerability | Required Guardrail |
| --- | --- | --- |
| **Data Exposure** | Auto-generating public DB schemas | Enforce RLS; Default `deny-all`. |
| **Credential Leaks** | Hardcoding API keys | Validate `.gitignore`; use env vars exclusively. |
| **Supply Chain** | Importing hallucinated packages | Pin dependencies. |
| **API Abuse** | Exposing unthrottled endpoints | Wrap in rate-limiters. |
| **Architectural Drift** | Ignoring project design patterns | Mandatory read of agent rules file. |
| **Production Outages** | Shipping untested code | Feature flags; auto-generate tests. |
