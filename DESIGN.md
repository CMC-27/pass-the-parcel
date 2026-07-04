# Application Design & Frontend Guidelines

Welcome to the frontend styling and layout system guide.

To ensure absolute visual consistency and match the premium design system of this application, all developers and agents **MUST** read and adhere to the core design system specification.

> [!IMPORTANT]
> **Direct System Specification:**
> Before creating or modifying any user interface elements, dashboards, or components, review the master design system document:
> ➡️ **[design-system.md](docs/wiki/core/05-design-system.md)**

---

## Creative North Star

Every application should follow a clean, premium, and unified aesthetic guidelines. Key principles include:

- **Unified Color Palette:** Use HSL or hex tokens mapped to theme variables to manage dark/light modes and custom components.
- **Architectural Layout:** Leverage consistent spacing scales, structured grid alignments, and component boundaries.
- **Visual Boundaries:** Define section separations cleanly. Avoid over-using hard borders; instead, utilize backgrounds, elevation shadows, or subtle padding offsets.

---

## Core Design Tokens (Quick Reference Template)

These variables are defined in the global stylesheet:

| Token | CSS Variable | Purpose |
|---|---|---|
| **Background / Canvas** | `--color-surface` | Primary application canvas background |
| **Container Base** | `--color-surface-container` | Main structural containers and panels |
| **Card / Element Base** | `--color-surface-card` | Cards, buttons, and floating panels |
| **Primary Accent** | `--color-primary` | Main accent branding color |
| **Secondary Accent** | `--color-secondary` | Supporting theme accent |
| **Success** | `--color-success` | Success metrics, indicators, and complete states |
| **Warning / Error** | `--color-error` | Validation failures, alerts, and critical flags |

*For the full list of variables, badge styling, interactive button specifications, and typography hierarchy, see the complete guide at [design-system.md](docs/wiki/core/05-design-system.md).*
