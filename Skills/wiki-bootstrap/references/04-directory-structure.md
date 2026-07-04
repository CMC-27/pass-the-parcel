---
type: "core"
name: "Directory Structure"
status: "stable"
dependencies: []
db_relations: []
description: "Physical source directory layout for [APP_NAME], mapping folders to their functional purpose."
---

# Physical Directory Structure

This document provides a fast mental model of the physical `/src` codebase to help you locate implementation assets without running recursive terminal searches.

## Root Directory (`/src`)
- **`[MainApp].jsx`**: The global router and state container. Gatekeeps routes based on auth context.
- **`main.jsx`**: Global entry point.
- **`index.css`**: Styling directives and global CSS overrides.

## 1. `/src/views` (The Pages)
The primary routing destinations. If a URL changes, it lands in one of these components. Nested to match business units:
- **`/[domain-1]`**: `[View1]`, `[View2]`. [Description — e.g., Admin views for managing master data].
- **`/[domain-2]`**: `[View3]`, `[View4]`. [Description — e.g., Core interactive workspace for projects].
- **`/[domain-3]`**: `[View5]`. [Description — e.g., Mobile-optimized data entry].
- **`/[domain-4]`**: `[View6]`, `[View7]`. [Description — e.g., Operational fulfillment screens].
- **`/settings`**: `SettingsView`. Global appearance and configuration.
- **`/reports`**: Analytics dashboards.

## 2. `/src/components` (The Building Blocks)
- **`/ui`**: Pure, agnostic presentation components (`Button.jsx`, `Modal.jsx`, `Badge.jsx`).
- **`/layout`**: Structural layout wireframes (`[Workspace].jsx`, `Sidebar.jsx`, `TopNav.jsx`).
- **`/[domain-1]`** & **`/[domain-2]`**: "Feature Components" — highly opinionated components bound to specific data domains (e.g., `[EntityEditorModal].jsx`, `[ImportModal].jsx`).

## 3. `/src/context` (The Global State)
- **`AuthContext.jsx`**: Wraps the app. Holds auth provider `user` and derived `role`.
- **`[Entity]Context.jsx`**: Caches the [entity] dictionary for zero-latency autocomplete in forms. Exposes `[entities]` array and `refresh[Entities]()`.
- **`[Project]Context.jsx`**: Caches the global `[projects]` list. All views consuming the project registry read from this context via `use[Projects]()` rather than running independent queries. Call `refresh[Projects](true)` after any mutation.
- **`ThemeContext.jsx`**: Manages runtime theming, persistence, and CSS variable injection.
- **`ToastContext.jsx`**: Global notification state.

## 4. `/src/hooks` (Custom Logic Hooks)
Feature-specific reusable logic extracted from views.
- **`[useKeyboardHook].js`**: [Description of what this hook manages — e.g., 2D grid navigation for a data entry grid].
- **`[usePersistenceHook].js`**: [Description — e.g., atomic selection persistence, syncing status, and sidebar progress].

## 5. `/src/utils` (Pure Logic & Helpers)
Files executing data mutation without React UI overhead.
- **`[calculator].js`**: [Description — e.g., Calculates deep multiplier logic for assemblies].
- **`[formatter].js`**: [Description — e.g., String formatters ensuring specific naming standards].
- **`cn.js`**: Class merge utility (for conditional Tailwind class application).
- **`[csvParser].js`**: [Description — e.g., Reusable logic for importing master data via CSV].
- **`[aiClient].js`**: [Description — e.g., Holds the logic for calling AI/LLM endpoints].

## 6. `/src/config` (Bridges & Variables)
- **`[authProvider].js`**: Initializes the primary auth provider.
- **`[dbClient].js`**: Initializes the primary database client.
- **`theme.js`**: Centralized object for labeling and display constants.
- **`themes.js`**: Registry of runtime theme presets.
