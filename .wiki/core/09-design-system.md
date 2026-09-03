---
title: "Design System: Architectural Precision & Technical Blueprint Clarity"
type: "core"
name: "Design System"
status: "stable"
dependencies: []
db_relations: []
description: "The single source of truth for visual design decisions: tokens, typography, components, and interaction states."
---

# Design System

## 1. Overview & Creative North Star
**Creative North Star: "[Design Metaphor]"**

[Describe the visual philosophy in 2–3 sentences. What emotional or contextual impression does the UI seek to create? What is the key departure from "generic SaaS" or "default" aesthetics?]

---

## 2. Color Palette

### Core Design Tokens (Quick Reference)
These variables are defined in the global stylesheet and are the canonical token names every app built on this scaffold uses:

| Token | CSS Variable | Purpose |
|---|---|---|
| **Background / Canvas** | `--color-surface` | Primary application canvas background |
| **Container Base** | `--color-surface-container` | Main structural containers and panels |
| **Card / Element Base** | `--color-surface-card` | Cards, buttons, and floating panels |
| **Primary Accent** | `--color-primary` | Main accent branding color |
| **Secondary Accent** | `--color-secondary` | Supporting theme accent |
| **Success** | `--color-success` | Success metrics, indicators, and complete states |
| **Warning / Error** | `--color-error` | Validation failures, alerts, and critical flags |

### The "[No-Line / Core Constraint]" Rule
**Explicit Instruction:** [Describe a key design constraint that prevents a common mistake].

### Surface Hierarchy & Nesting
The UI is layered as a physical stack:

| Token Name | Hex / HSL Value | Usage |
|---|---|---|
| `surface` | `#XXXXXX` | Main canvas / page background |
| `surface-container-low` | `#XXXXXX` | Secondary section backgrounds |
| `surface-container` | `#XXXXXX` | Interactive card backgrounds |
| `surface-container-high` | `#XXXXXX` | Filled input backgrounds |
| `on_surface` | `#XXXXXX` | High-contrast text |
| `secondary` (text) | `#XXXXXX` | Standard body text |

### Primary & Accent Colors

| Token Name | Hex / HSL Value | Usage |
|---|---|---|
| `primary` | `#XXXXXX` | Primary actions, active states |
| `primary_container` | `#XXXXXX` | Gradient end / hover targets |
| `tertiary_container` | `#XXXXXX` | Alert / warning chip backgrounds |

### The "[Gradient / Glass]" Rule
[Describe the rule for gradients, glassmorphism, or other atmospheric effects].

---

## 3. Typography
**Font Family:** [Font name]

| Scale Name | Size | Weight | Usage |
|---|---|---|---|
| **Display** | `[size]rem` | `[weight]` | Critical KPIs |
| **Headline** | `[size]rem` | `[weight]` | Section titles |
| **Body** | `[size]rem` | `[weight]` | Standard content |
| **Label** | `[size]rem` | `[weight]` | Status badges, metadata |

---

## 4. Elevation & Depth
[Describe how depth is communicated — background color tiers, shadows, blur, borders].

- **Layering Principle:** [Primary rule].
- **Ambient Shadows (if used):** Value: `[shadow value]`, Color: `[shadow color at X% opacity]`.
- **Glassmorphism (if used):** `[surface color at X alpha]` + `blur(Xpx)`.

---

## 5. Core Components

### Buttons
| Variant | Background | Text | Shape |
|---|---|---|---|
| **Primary** | Gradient `primary` → `primary_container` | White | `rounded-xl` |
| **Secondary** | `surface_container_high` | `primary` | `rounded-xl` |
| **Tertiary / Ghost** | None | `primary` | No border |

### Status Badges / Chips
- **Alert / Warning:** `[background token]` with `[text token]`.
- **Success / Completion:** `[color at X% opacity]` with `solid [color]` text.

### Input Fields
- **Style:** Filled. Background: `[surface_container_high]`.
- **Active / Focus State:** `[describe focus ring or underline style]`.

### Cards & Lists
- **Separator Rule:** [Describe whether dividers/borders are allowed].

---

## 6. Do's and Don'ts

### Do
- **Do** [design rule 1].
- **Do** [design rule 2].
- **Do** [design rule 3].

### Don't
- **Don't** [anti-pattern 1].
- **Don't** [anti-pattern 2].
- **Don't** [anti-pattern 3].

---

## 7. Layout & Alignment Standards

### High-Density Data Rows
For data grids or table-style views:
- **Cell Height:** `h-[X]` ([X]px).
- **Input Height within cells:** `h-[X]` ([X]px) with `text-[Xpx]`.
- **Vertical Visual Axis:** [Describe any fixed pixel alignment axis].

### Workspace Spacing
- **Outer Margins:** `p-[X]` ([X]px).
- **Inter-Card Gap:** `gap-[X]` ([X]px).
