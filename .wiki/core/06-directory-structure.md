---
title: "Physical Directory Structure"
type: "core"
name: "Directory Structure"
status: "stable"
dependencies: []
db_relations: []
description: "Physical source directory layout, mapping folders to their functional purpose."
---

# Physical Directory Structure

This document provides a fast mental model of the physical `/src` codebase to help locate implementation assets without running recursive terminal searches.

## Root Directory (`/src`)
- **`[MainApp].jsx`**: The global router and state container. Gatekeeps routes based on auth context.
- **`main.jsx`**: Global entry point.
- **`index.css`**: Styling directives and global CSS overrides.

## 1. `/src/views` (The Pages)
The primary routing destinations. Nested to match business units:
- **`/[domain-1]`**: `[View1]`, `[View2]`. [Description].
- **`/[domain-2]`**: `[View3]`, `[View4]`. [Description].
- **`/[domain-3]`**: `[View5]`. [Description].
- **`/[domain-4]`**: `[View6]`, `[View7]`. [Description].
- **`/settings`**: `SettingsView`. Global appearance and configuration.
- **`/reports`**: Analytics dashboards.

## 2. `/src/components` (The Building Blocks)
- **`/ui`**: Pure, agnostic presentation components (`Button.jsx`, `Modal.jsx`, `Badge.jsx`).
- **`/layout`**: Structural layout wireframes (`[Workspace].jsx`, `Sidebar.jsx`, `TopNav.jsx`).
- **`/[domain-1]`** & **`/[domain-2]`**: "Feature Components" — highly opinionated components bound to specific data domains.

## 3. `/src/context` (The Global State)
- **`AuthContext.jsx`**: Wraps the app. Holds auth provider `user` and derived `role`.
- **`[Entity]Context.jsx`**: Caches the [entity] dictionary. Exposes `[entities]` array and `refresh[Entities]()`.
- **`[Project]Context.jsx`**: Caches the global `[projects]` list.
- **`ThemeContext.jsx`**: Manages runtime theming, persistence, and CSS variable injection.
- **`ToastContext.jsx`**: Global notification state.

## 4. `/src/hooks` (Custom Logic Hooks)
Feature-specific reusable logic extracted from views.
- **`[useHookName].js`**: [Description of what this hook manages].
- **`[useHookName].js`**: [Description].

## 5. `/src/utils` (Pure Logic & Helpers)
Files executing data mutation without UI overhead.
- **`[calculator].js`**: [Description].
- **`[formatter].js`**: [Description].
- **`cn.js`**: Class merge utility (for conditional Tailwind class application).
- **`[aiClient].js`**: [Description — logic for calling AI/LLM endpoints].

## 6. `/src/config` (Bridges & Variables)
- **`[authProvider].js`**: Initializes the primary auth provider.
- **`[dbClient].js`**: Initializes the primary database client.
- **`theme.js`**: Centralized object for labeling and display constants.
- **`themes.js`**: Registry of runtime theme presets.
