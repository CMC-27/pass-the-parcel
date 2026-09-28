---
type: "integrations"
name: "Integrations Index"
status: "template"
dependencies: []
description: "Catalog of external service and API integrations."
---

# Integrations Index

> **Template seed** — this index catalogues a satellite's integrations; the single row below is the worked example shipped with the template, not a live integration of this repo. See [AGENTS.md](../../AGENTS.md) § Design & Scope Notes.

This index catalogs all external service integrations used by the application.

---

## Integration Docs

| Doc | Service | Description |
|---|---|---|
| [AI Provider Integration (Example)](ai-provider-integration.md) | AI provider | Provider-neutral AI model integration pattern |

---

## Integration Principles

- External API keys are managed via environment variables
- All third-party calls include timeout and error handling
- Rate limiting is enforced on outbound requests
- Service credentials never appear in source code

---

## See Also
- [AI Features](../core/15-ai-features.md)
- [Security Standards](../core/12-security-standards.md)
