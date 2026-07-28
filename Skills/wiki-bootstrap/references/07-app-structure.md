---
type: "core"
name: "App Structure Shell"
status: "stable"
dependencies: []
db_relations: []
description: "The outermost application shell — router, layout wrappers, context mounting, and navigation architecture."
---

# `[App].jsx` (Application Shell)
**Path:** `src/[App].jsx`

## Purpose
The global router and state container. It authenticates the user, reads their role, and instantiates the global layout shell (Sidebar, TopNav, main content area) and the active feature View based on contextual clearance and role permissions.

## Layout Shell Components
- **`[Sidebar].jsx`**: Left-hand navigation rail or sidebar. Lists primary routes. Role-gated navigation items.
- **`[TopNav].jsx`**: Top header bar. Contains user account controls, global project selector (if applicable), or breadcrumb navigation.
- **`[Workspace / Layout Wrapper]`**: [Describe any overarching layout wrapper — e.g., IndustrialWorkspace — that wraps child views and enforces consistent padding/header behavior].

## Context Providers Mounted at Root
List all React Context providers that must wrap the app here:
- `<[AuthContext]>` — Manages user session and role.
- `<[ToastProvider]>` — Global notification layer.
- `<[EntityProvider]>` — Global cached data (e.g., Materials, Products).
- `<[ProjectProvider]>` — Global active project state.
- `<[ThemeProvider]>` — Runtime theme tokens.

## Routing Architecture
- **Routing Strategy:** [Describe routing approach — e.g., state-based `activeTab` prop, React Router `<Route>`, Next.js file-system routing].
- **Auth Gate:** If the auth session is missing, the app renders `<[SignIn]/>` instead of the main shell.
- **Role-Based Routing:** [Describe how roles gate access to routes — e.g., Admin-only routes are hidden from Estimator role].

## Code Elements
```jsx
// Illustrative structure — fill in actual components
<[AuthContext]>
  <[ThemeProvider]>
    <[ToastProvider]>
      <[EntityProvider]>
        <[ProjectProvider]>
          <[Sidebar] />
          <[TopNav] />
          <main>
            {/* Route-based View renders here */}
            {activeTab === '[route]' && <[FeatureView] />}
          </main>
        </[ProjectProvider]>
      </[EntityProvider]>
    </[ToastProvider]>
  </[ThemeProvider]>
</[AuthContext]>
```

## Backend Requirements
- **Auth Check:** Reads from [auth provider — e.g., Firebase Auth / Supabase Auth] to verify `user` object presence on mount.
- **Role Resolution:** Fetches or derives the `role` from [source — e.g., a `profiles` DB table, a custom claims token, or a Supabase RLS context function].
