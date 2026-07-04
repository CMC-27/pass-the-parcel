---
type: "core"
name: "Theme & Linguistics"
status: "stable"
dependencies: []
db_relations: []
description: "Documents the theme system architecture, token structure, nomenclature mappings, and content localization rules."
---

# Theme & Linguistics System

The theme system is a flexible, token-based architecture that enables dynamic branding, accessibility modes, and user customization. It leverages CSS variables, React Context, and [styling framework] for a seamless styling experience.

---

## 1. Token-Based Architecture

The source of truth for all themes is located in `src/config/themes.js`. Each theme is defined as an object containing:
- `id`: A unique identifier for the theme.
- `name`: A human-readable display name.
- `description`: A brief summary of the theme's aesthetic.
- `tokens`: A collection of CSS variables (e.g., `--color-primary`, `--font-family-sans`).

### Default Theme Presets

| Theme ID | Name | Description |
|---|---|---|
| `[theme-id-1]` | `[Theme Name 1]` | [Brief description] |
| `[theme-id-2]` | `[Theme Name 2]` | [Brief description] |
| `[theme-id-3]` | `[Theme Name 3]` | [Brief description] |

---

## 2. RGB Conversion & Opacity Support

To support opacity utility classes (e.g., `bg-primary/50`), hex color tokens are automatically converted to RGB channel strings.

- **Logic:** The `hexToRgbChannels` helper in `ThemeContext.jsx` converts `#RRGGBB` to `R G B`.
- **Application:** Two versions of each color token are injected into `:root`:
  - `--color-primary: #004ac6;` (Original hex)
  - `--color-primary-rgb: 0 74 198;` (RGB channels for opacity support)

---

## 3. Styling Framework Mapping

Styling utility classes are mapped to CSS variables in the config:

```javascript
colors: {
  primary: {
    DEFAULT: '[CSS variable reference]',
  },
}
```

This allows the application to respond instantly to theme changes without a full rebuild.

---

## 4. State Management & Persistence

The `ThemeContext` manages the active theme state and user-specific overrides.

- **Merging:** Base theme tokens are merged with `customOverrides`.
- **Persistence:** Theme settings are synchronized with [cloud persistence layer] and fall back to `localStorage`.
- **Custom Themes:** Users can snapshot their current overrides to create personal themes.

---

## 5. Dynamic Font Injection

- **FONT_MAP:** A dictionary mapping font names to CDN URL specifications.
- **Injection Logic:** When the active font changes, a `<link>` tag is appended to the document head.
- **Optimization:** Only fonts currently in use are fetched.

---

## 6. Nomenclature Mappings (Content Localization)

The application uses terminology that may vary by theme, locale, or white-label configuration.

| Functional Area | Default Label | [Theme/Locale B] Label | [Theme/Locale C] Label |
|---|---|---|---|
| [Feature/Entity 1] | `[Default Name]` | `[Alternate Name]` | `[Alternate Name]` |
| [Feature/Entity 2] | `[Default Name]` | `[Alternate Name]` | `[Alternate Name]` |

---

## 7. UI Text Rules

* **No Hardcoded Strings:** UI text must reference translation keys or theme config.
* **[Translation Key Registry]:** Key-value pairs stored in `src/config/locale.js`.
* **Tone:** [Describe the tone and voice expected in UI strings].
