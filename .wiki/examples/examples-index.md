---
type: "examples"
name: "Examples Index"
status: "template"
dependencies: []
description: "Catalog of worked examples demonstrating wiki conventions."
---

# Examples Index

This index catalogs worked examples in `examples/` — sample wiki documents, sample agent outputs, and illustrative content that shows the conventions in practice. This is a **template index** — populate it as examples are added; do not invent rows for files that don't exist.

---

## Worked Examples

| Example | Demonstrates | Pattern Source |
|---|---|---|
| [parcel-walkthrough-machinery-hardening.md](parcel-walkthrough-machinery-hardening.md) | A complete parcel run end to end — group-by-group output, a halted gate, an independent review `REJECTED`, and the revision loop | [17-docs-blueprint.md](../core/17-docs-blueprint.md), [link-hygiene.md](../rules/link-hygiene.md) |

---

## Rules

- An example must mirror a real pattern from `.wiki/rules/` or a core doc — never a one-off style.
- Mark every example `status: template` so agents never mistake it for app truth.

---

## See Also
- [Docs Blueprint](../core/17-docs-blueprint.md)
- [Templates README](../templates/README.md)
