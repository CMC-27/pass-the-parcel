---
type: "core"
name: "State & Context"
status: "stable"
dependencies: []
db_relations: []
description: "Defines global state shapes, context provider APIs, and persistence strategies."
---

# State & Context Data Shapes

This document defines the expected core object shapes managed globally or heavily passed around in the application. It provides strict type references for AI agents and future developers.

---

## 1. `[AuthContext]` (User Session Shape)

`[AuthContext].jsx` manages the global user session via [auth provider]. It exposes `user`, `role`, `loading`, and helper functions.

**Object Shape (`user`):**
```json
{
  "uid": "[unique-identifier-string]",
  "email": "user@example.com",
  "displayName": "Full Name",
  "emailVerified": true,
  "photoURL": "url-string | null"
}
```

**Access Patterns:**
- `role`: Evaluated globally (e.g. `ADMIN`, `[ROLE_2]`, `[ROLE_3]`). Controls UI routing.

---

## 2. `[EntityContext]` ([Primary Entity] Base Dictionary)

Caches the global inventory of `[entities]`. Exposes `[entities]` array and `refresh[Entities]()` function.

**Object Shape (`[entities][0]`):**
```json
{
  "[entity_id]": "[unique-id]",
  "[name_field]": "[Display Name / Label]",
  "[unit_field]": "[Unit or Category]",
  "[location_field]": "[Location or Group]"
}
```

---

## 3. `[ProjectContext]` (Project Registry Cache)

Caches the global list of `[projects]` and manages the active project selection. Exposes `[projects]` array, `selected[Project]` object, `loading` bool, and helper functions.

**Hook:** `use[Projects]()` — must be used within `<[ProjectProvider]>` (mounted in `[App].jsx`).

**Object Shape (`[projects][0]`):**
```json
{
  "[project_id]": "uuid",
  "[project_code]": "[identifier]",
  "[name]": "[Human-readable project name]",
  "[group_or_owner]": "[Grouping field]",
  "created_at": "ISO8601-timestamp"
}
```

**Access Patterns:**
- `[projects]`: Full array, ordered by `created_at` descending. Fetched once per session.
- `selected[Project]`: Global state for the currently active project.
- `set[SelectedProject](project)`: Function to update the global project context.
- `refresh[Projects](force = false)`: Pass `true` to force a re-fetch.

---

## 4. Active [Primary Entity] Form / Local State

Within complex builders, the "Active [Entity]" state merges DB records into a nested map for UI performance.

**[Selections] Map (local state):**
Keyed by `[slot_id]`, returning an array of selected [items]:
```json
{
  "[slot_uuid]": [
    {
      "[item_id]": "[item-id-value]",
      "quantity": 1,
      "[modifier_field]": 1,
      "[coding_field]": "[Classification Code]",
      "[routing_field]": "[uuid-of-routing-target]"
    }
  ]
}
```

---

## 5. `[ThemeContext]` (Runtime Appearance)

Manages the global theme state, persistence, and CSS variable injection.

**Hook:** `useTheme()` from `src/context/ThemeContext.jsx`.

**Exposed State & Functions:**
- `activeThemeId`: Current active theme preset ID.
- `customOverrides`: Flat object of user-defined token overrides.
- `themes`: The full `THEMES` array from `src/config/themes.js`.
- `setTheme(id)`: Switches the active preset and clears all custom overrides.
- `updateToken(name, value)`: Updates a single token and persists it.
- `resetTheme()`: Reverts to default and clears all overrides.

**Persistence:**
- **Primary:** [Cloud persistence layer] (if authenticated).
- **Secondary/Fallback:** `localStorage` key `'[app-name]-theme'`.
