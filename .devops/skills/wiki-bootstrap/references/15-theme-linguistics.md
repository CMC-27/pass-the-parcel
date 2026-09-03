---
type: "core"
name: "Theme & Linguistics"
status: "stable"
dependencies: []
db_relations: []
description: "Documents the theme system architecture, token structure, nomenclature mappings, and content localization rules for [APP_NAME]."
---

# Theme & Linguistics System

The [APP_NAME] theme system is a flexible, token-based architecture that enables dynamic branding, accessibility modes, and user customization. It leverages a combination of CSS variables, React Context, and [styling framework] for a seamless styling experience.

---

## 1. Token-Based Architecture

The source of truth for all themes is located in `src/config/themes.js`. Each theme is defined as an object containing:
- `id`: A unique identifier for the theme.
- `name`: A human-readable display name.
- `description`: A brief summary of the theme's aesthetic.
- `tokens`: A collection of CSS variables (e.g., `--color-primary`, `--font-family-sans`) that define the theme's visual properties.

### Default Theme Presets

| Theme ID | Name | Description |
|---|---|---|
| `[theme-id-1]` | `[Theme Name 1]` | [Brief description — e.g., "Primary industrial aesthetic with Blueprint Blue tones."] |
| `[theme-id-2]` | `[Theme Name 2]` | [Brief description — e.g., "Dark mode with high-contrast accents."] |
| `[theme-id-3]` | `[Theme Name 3]` | [Brief description — e.g., "Maximum contrast for accessibility."] |

---

## 2. RGB Conversion & Opacity Support

To support opacity utility classes (e.g., `bg-primary/50`), hex color tokens are automatically converted to RGB channel strings.

- **Logic:** The `hexToRgbChannels` helper in `ThemeContext.jsx` converts `#RRGGBB` to `R G B`.
- **Application:** The `applyTokensToDOM` function injects two versions of each color token into the `:root` element:
  - `--color-primary: #004ac6;` (Original hex for reference)
  - `--color-primary-rgb: 0 74 198;` (RGB channels for opacity support)

---

## 3. Styling Framework Mapping

Styling utility classes are mapped to CSS variables in `[tailwind.config.js / equivalent config]`:

```javascript
colors: {
  primary: {
    DEFAULT: '[usage of CSS variable]',
  },
  // ...
}
```

This mapping allows the application to respond instantly to theme changes without a full rebuild or page refresh.

---

## 4. State Management & Persistence

The `ThemeContext` manages the active theme state and user-specific overrides.

- **Merging:** Base theme tokens are merged with `customOverrides` to produce the final set of active tokens.
- **Persistence:** Theme settings are synchronized with [cloud persistence layer — e.g., Firestore] for authenticated users and fall back to `localStorage` for guest sessions.
- **Custom Themes:** Users can snapshot their current overrides to create personal themes, stored in the `customThemes` array.

---

## 5. Dynamic Font Injection

To maintain high performance and low initial payload, fonts are dynamically injected as needed:

- **FONT_MAP:** A dictionary in `ThemeContext.jsx` maps font names to their [Google Fonts / CDN] URL specifications.
- **Injection Logic:** When the active font family changes, `injectFontLink` checks the `FONT_MAP` and appends a `<link>` tag to the document head if the font hasn't been loaded yet.
- **Optimization:** This ensures that only fonts currently in use are fetched by the browser.

---

## 6. Nomenclature Mappings (Content Localization)

[APP_NAME] uses terminology that may vary by theme, locale, or white-label configuration. The table below maps functional areas to their display labels under each theme variant.

| Functional Area | Default Label | [Theme/Locale B] Label | [Theme/Locale C] Label |
|---|---|---|---|
| [Feature/Entity 1] | `[Default Name]` | `[Alternate Name]` | `[Alternate Name]` |
| [Feature/Entity 2] | `[Default Name]` | `[Alternate Name]` | `[Alternate Name]` |
| [Feature/Entity 3] | `[Default Name]` | `[Alternate Name]` | `[Alternate Name]` |

---

## 7. UI Text Rules

* **No Hardcoded Strings:** UI text strings must not be hardcoded directly in JSX. They must reference [translation keys / constants / theme config] to ensure they update correctly when the theme or locale changes.
* **[Translation Key Registry] (if applicable):** Key-value pairs are stored in `src/config/[i18n / locale].js`.
* **Tone:** [Describe the tone and voice expected in UI strings — e.g., "Professional and concise. Avoid passive voice. Use imperatives for CTAs (Save, Export, Approve)."]
