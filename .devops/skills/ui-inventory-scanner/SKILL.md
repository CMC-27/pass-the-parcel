---
name: ui-inventory-scanner
description: Make sure to use this skill whenever the user asks to audit, scan, inventory, or catalogue UI elements in the codebase (e.g., "scan all buttons", "audit all inputs", "list all modals"). It dynamically determines search patterns and extraction criteria based on the element type, produces a structured markdown inventory table, flags design-system anomalies, and saves the report to `.devops/audits/`.
tags: ["ui", "inventory", "audit", "design-system", "frontend", "component-scan"]
version: 2
updated: 2026-09-06
---

# SKILL: UI Inventory Scanner

## Context
You are a structured UI component inventory scanner. Given any UI element type (button, input, card, modal, dropdown, table row, tab, toast, etc.), you scan the codebase for all instances and produce a markdown inventory table the user can review to propose changes.

## Usage
The user says `scan all [element type]`. You determine everything else dynamically.

## Scan Pipeline

### Phase 1: Determine Search Strategy
Given the element type, reason about:
- **What HTML elements** correspond to it? (e.g., button → `<button>`, `<a role="button">`; checkbox → `<input type="checkbox">`)
- **What shared components** might exist? (e.g., `Button`, `PrimaryButton`, `HeaderButton`, or none)
- **What CSS class patterns** might indicate it? (e.g., `btn-*`, `card-*`, `modal-*`)
- **What naming conventions** does the project use? Check `src/components/ui/` for relevant component files.

Generate grep patterns accordingly — typically 2–3 patterns covering: shared component usage, raw HTML elements, and CSS class indicators.

### Phase 2: Discover the Design System
1. Read `.wiki/core/09-design-system.md` to understand the project's design tokens and component conventions.
2. Read any relevant component files in `src/components/ui/` to understand the shared component's API (props, variants, sizes).

### Phase 3: Infer Extraction Criteria
Based on the element type and the shared component's API, dynamically determine the criteria columns. Think about:

**For any element, these columns always apply:**
- ID / Name (descriptive label)
- File path + Line number
- Screen / feature (infer from file path)

**For interactive elements (buttons, links, toggles):**
- Shared component used or raw HTML
- onClick / action
- Hover / focus / active states
- Disabled / loading state
- Variant (if design system defines variants)
- Size
- Type attribute (button, submit, reset)
- Width behavior (fixed, full-width, auto)

**For form elements (inputs, selects, textareas):**
- Shared component or raw HTML
- Input type
- Label / placeholder
- Value binding
- Validation / error state
- Width
- Border radius, padding, coloring

**For containers (cards, modals, sections):**
- Shared component or raw div
- Padding, border-radius, shadow, background
- Interactive (onClick, hover)
- Width
- Close mechanism (for modals)

**For all elements, also extract:**
- Coloring / tokens (bg, text, border)
- Border radius
- Padding
- Font size / weight (if text is involved)
- Shadow
- Accessibility (aria-*, role, title)

> **Important**: If an instance lacks a given attribute, the column value is `—` (none/default). Do not guess.

### Phase 4: Search the Codebase
1. Grep using the patterns from Phase 1. Exclude `node_modules/`, `dist/`, `.opencode/`.
2. For each file found, read it to isolate every distinct instance. A single file may contain many — each gets its own row.
3. Categorize: shared component usage vs raw HTML elements.

### Phase 5: Extract Data
For each instance, walk through the JSX and extract every criterion column. Key techniques:
- **Label**: children text, `aria-label`, `placeholder`, or infer from context
- **Action**: `onClick` prop — inline arrow, named handler, `onClose`, `handleSubmit`, navigation
- **States**: look for `hover:`, `focus:`, `disabled`, `loading` props
- **Tokens**: extract CSS classes (bg-*, text-*, p-*, rounded-*, shadow-*, font-*, w-*, h-*)
- **Accessibility**: `aria-label`, `aria-describedby`, `title`, `role`, `htmlFor`

### Phase 6: Output the Table

**Summary Statistics** (top):
- Total instances
- Shared component vs raw element breakdown
- Unique variants/sizes used

**Inventory Table**:
Output a markdown table. If 40+ rows, group by screen/feature with separate tables.

**Anomalies Section** (bottom):
Flag anything unusual based on the design system:
- Raw HTML elements where a shared component exists
- Missing variant/size where design system expects one
- Hardcoded values that should be design tokens
- Missing accessibility attributes
- Inconsistent patterns across the same screen
- For buttons specifically: missing `type="button"` on non-submit buttons

End with: **"Review the table above and propose changes — I can then apply them. Full report saved to `.devops/audits/ui-inventory-<element>-YYYY-MM-DD.md`."**

### Phase 7: Persist the Report

Save the full report (summary statistics + inventory table(s) + anomalies) to `.devops/audits/ui-inventory-<element>-YYYY-MM-DD.md` so it survives the session and can be referenced by a later parcel plan:

```markdown
---
title: UI Inventory — <Element Type> (<YYYY-MM-DD>)
tags: [ui-inventory, <element>, audit]
status: draft
owner: <requester or Wiki Owner>
created: YYYY-MM-DD
last-reviewed: YYYY-MM-DD
related-to: [.wiki/core/09-design-system.md]
---

# UI Inventory — <Element Type> (YYYY-MM-DD)

> Scan scope: <patterns searched, files included/excluded>. Findings below are a point-in-time snapshot; re-scan after any refactor.

<Summary Statistics>

<Inventory Table(s)>

<Anomalies>

## Proposed Changes

_To be filled after user review — each accepted change becomes a Change Item in a parcel plan._
```

- Create `.devops/audits/` if it does not exist.
- One file per scan — never append a new scan to an old report.
- If the user proposes changes from the review, hand them to the `@backlog` skill or a parcel plan as Change Items; the audit file records findings only.
