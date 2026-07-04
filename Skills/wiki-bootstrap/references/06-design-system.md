---
type: "core"
name: "Design System"
status: "stable"
dependencies: []
db_relations: []
description: "The single source of truth for visual design decisions in [APP_NAME]: tokens, typography, components, and interaction states."
---

# Design System: [Design Theme Name]

## 1. Overview & Creative North Star
**Creative North Star: "[Design Metaphor]"**

[Describe the visual philosophy in 2–3 sentences. What emotional or contextual impression does the UI seek to create? What is the key departure from "generic SaaS" or "default" aesthetics? What does the design communicate about the domain (e.g., industrial, clinical, creative, financial)?]

---

## 2. Color Palette

### The "[No-Line / Core Constraint]" Rule
**Explicit Instruction:** [Describe a key design constraint that prevents a common mistake — e.g., "Do not use 1px solid borders to section off content. Define boundaries only through background color shifts."]

### Surface Hierarchy & Nesting
The UI is layered as a physical stack. Define each surface level with its token name and actual value:

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
[Describe the rule for gradients, glassmorphism, or other atmospheric effects — e.g., "Use a 15-degree angle gradient from `primary` to `primary_container` for primary CTAs. Use `surface` at 80% opacity + 20px backdrop blur for floating navigation."]

---

## 3. Typography
**Font Family:** [Font name — e.g., Inter, Outfit, Roboto]

| Scale Name | Size | Weight | Usage |
|---|---|---|---|
| **Display** | `[size]rem` | `[weight]` | [Usage — e.g., Critical KPIs] |
| **Headline** | `[size]rem` | `[weight]` | [Usage — e.g., Section titles] |
| **Body** | `[size]rem` | `[weight]` | [Usage — e.g., Standard content] |
| **Label** | `[size]rem` | `[weight]` | [Usage — e.g., Status badges, metadata] |

---

## 4. Elevation & Depth
[Describe how depth is communicated. Is it through background color tiers, shadows, blur, borders?]

- **Layering Principle:** [Primary rule — e.g., "Avoid elevation shadows. Use surface-container tiers instead."]
- **Ambient Shadows (if used):** Value: `[shadow value]`, Color: `[shadow color at X% opacity]`.
- **Glassmorphism (if used):** `[surface color at X alpha]` + `blur(Xpx)`.
- **[Flush Island / Card Pattern]:** [Describe the rounding pattern for nested containers — e.g., "Interior data islands are flush at the bottom, fully rounded at the top."]

---

## 5. Core Components

### Buttons
| Variant | Background | Text | Shape |
|---|---|---|---|
| **Primary** | Gradient `primary` → `primary_container` | White | `rounded-xl` |
| **Secondary** | `surface_container_high` | `primary` | `rounded-xl` |
| **Tertiary / Ghost** | None | `primary` | No border |

**Floating Header Standard:** For action buttons inside workspace headers:
- Height: `h-[X]`, Width: `[Xpx]` or square `w-[X]` for icon-only.
- Typography: `text-[Xpx]`, `font-bold`, `uppercase`, `tracking-widest`.

### Status Badges / Chips
- **Alert / Warning:** `[background token]` with `[text token]`.
- **Success / Completion:** `[color at X% opacity]` with `solid [color]` text.

### Input Fields
- **Style:** Filled. Background: `[surface_container_high]`.
- **Active / Focus State:** `[describe focus ring or underline style]`.

### Cards & Lists
- **Separator Rule:** [Describe whether dividers/borders are allowed — e.g., "Forbid `<hr>`. Use vertical `gap-6` or alternating row fills."]

---

## 6. Do's and Don'ts

### Do
- **Do** [design rule 1].
- **Do** [design rule 2].
- **Do** [design rule 3].

### Don't
- **Don't** [anti-pattern 1 — e.g., use 1px black borders].
- **Don't** [anti-pattern 2 — e.g., use standard drop shadows].
- **Don't** [anti-pattern 3 — e.g., crowd with excessive padding].

---

## 7. Layout & Alignment Standards

### High-Density Data Rows
For data grids or table-style views:
- **Cell Height:** `h-[X]` ([X]px).
- **Input Height within cells:** `h-[X]` ([X]px) with `text-[Xpx]`.
- **Vertical Visual Axis:** [Describe any fixed pixel alignment axis for icons/elements].

### Workspace Spacing
- **Outer Margins:** `p-[X]` ([X]px).
- **Inter-Card Gap:** `gap-[X]` ([X]px).

---
*End of Document*
