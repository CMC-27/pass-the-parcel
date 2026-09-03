---
title: "Application Shell Architecture"
type: "core"
name: "App Structure Shell"
status: "stable"
dependencies: []
db_relations: []
description: "The outermost application shell — router, layout wrappers, context mounting, and navigation architecture."
---

# Application Shell

**Path:** `src/[App].jsx`

## Purpose
The global router and state container. It authenticates the user, reads their role, and instantiates the global layout shell (Sidebar, TopNav, main content area) and the active feature View based on contextual clearance and role permissions.

## Layout Shell Components
- **`[Sidebar].jsx`**: Left-hand navigation rail or sidebar. Lists primary routes. Role-gated navigation items.
- **`[TopNav].jsx`**: Top header bar. Contains user account controls, global project selector (if applicable), or breadcrumb navigation.
- **`[Workspace / Layout Wrapper]`**: [Describe any overarching layout wrapper that wraps child views].

## Context Providers Mounted at Root
List all React Context providers that must wrap the app here:
- `<[AuthContext]>` — Manages user session and role.
- `<[ToastProvider]>` — Global notification layer.
- `<[EntityProvider]>` — Global cached data.
- `<[ProjectProvider]>` — Global active project state.
- `<[ThemeProvider]>` — Runtime theme tokens.

## Routing Architecture
- **Routing Strategy:** [Describe routing approach — e.g., state-based `activeTab` prop, React Router `<Route>`, file-system routing].
- **Auth Gate:** If the auth session is missing, the app renders `<[SignIn]/>` instead of the main shell.
- **Role-Based Routing:** [Describe how roles gate access to routes].

## Code Elements
```jsx
<[AuthContext]>
  <[ThemeProvider]>
    <[ToastProvider]>
      <[EntityProvider]>
        <[ProjectProvider]>
          <[Sidebar] />
          <[TopNav] />
          <main>
            {activeTab === '[route]' && <[FeatureView] />}
          </main>
        </[ProjectProvider]>
      </[EntityProvider]>
    </[ToastProvider]>
  </[ThemeProvider]>
</[AuthContext]>
```

## Backend Requirements
- **Auth Check:** Reads from [auth provider] to verify `user` object presence on mount.
- **Role Resolution:** Fetches or derives the `role` from [source].
