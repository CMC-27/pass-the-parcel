---
type: "core"
name: "Performance Standards"
status: "stable"
dependencies: []
db_relations: []
description: "Architectural guardrails for maintaining a 95+ Lighthouse Performance Score, passing Core Web Vitals, and ensuring a frictionless user experience in [APP_NAME]."
---

# ⚡ Performance Standards

This document establishes the architectural guardrails for maintaining a **95+ Lighthouse Performance Score** and ensuring a snappy, responsive user experience. We optimize strictly for the modern **Core Web Vitals**: Largest Contentful Paint (LCP), Interaction to Next Paint (INP), and Cumulative Layout Shift (CLS).

---

## 1. Bundle Architecture & Splitting

### The Lazy-Loading & Prefetching Rule

To keep the **Initial Bundle Size under 250KiB (Gzipped/Brotli)**, all non-critical routes and heavy UI components MUST be deferred. Pair lazy-loading with interaction-based prefetching to prevent loading spinners on navigation.

* **Required Lazy Components:**
  * **[Admin / Internal Views]:** `[ViewName1]`, `[ViewName2]`, `[ViewName3]`.
  * **[User-Facing Views]:** `[ViewName4]`, `[ViewName5]`.
  * **Modals & Drawers:** Any overlay containing complex forms, rich text editors, or data tables.

* **Intent-Based Prefetching:** Preload lazy chunks when a user hovers over the corresponding navigation link or button.

### Singleton Dynamic Import Pattern

For heavy utility libraries (e.g., `papaparse`, `jspdf`, `exceljs`, charting libraries), use the dynamic `import()` statement inside the function that requires it:

```javascript
// ✅ Correct: Load strictly on demand
const handleExport = async (data) => {
  const { unparse } = await import('papaparse');
  const csv = unparse(data);
  // ... download logic
};
```

---

## 2. React Render Optimization (Solving INP)

Interaction to Next Paint (INP) measures UI responsiveness. Blocking the main thread with heavy renders is strictly prohibited.

### Non-Blocking State Updates

* **`useTransition`:** Wrap expensive state updates (like filtering a large list) in `startTransition` to keep inputs responsive.
* **`useDeferredValue`:** Use for deferring computationally heavy list renders based on a search query.
* **Debounced State Sync:** Any high-frequency typing input (search bars, live filter inputs) must be debounced to **300ms** before syncing with global context providers or the database.

### State Colocation & Memoization

* **Push State Down:** Keep state as close to the consuming component as possible to prevent cascading re-renders.
* **Targeted `React.memo()`:** Only memoize components that frequently receive identical props. Avoid wrapping everything — comparison overhead is real.
* **Mandatory Memoization:** `Sidebar`, `TopNav`, large data grid rows, and chart/visualization components.

---

## 3. Data Fetching & Network Efficiency

Avoid "Network Waterfalls" (Component A fetches → renders Component B → fetches).

* **Caching & Deduping:** All API requests must route through a caching layer or context service. Avoid naked `useEffect` hooks for standard data fetching.
* **Stale-While-Revalidate:** UI should render immediately using cached context data while transparently re-fetching fresh data in the background.
* **Parallel Fetching:** If a view requires multiple endpoints, fetch them via `Promise.all()` at the route level before rendering child components.
* **Progressive Chunked Synchronization:** Background synchronization for large tables must be fetched in chunks (e.g., batch sizes of `[1000]` rows) to minimize memory footprint and network payloads.

---

## 4. Asset & Media Delivery

### Image Optimization

* **Explicit Dimensions:** Every `<img>` component MUST have explicit `width` and `height` attributes to reserve space and prevent Layout Shift (CLS).
* **Modern Formats:** Serve images in WebP or AVIF formats.
* **Native Lazy Loading:** All images below the fold must include `loading="lazy"`.

### Font & CSS Strategy

* **Preload Critical Fonts:** Prevent Flash of Unstyled Text (FOUT) by preloading primary fonts in `index.html`:
```html
<link rel="preload" href="/fonts/[font-name].woff2" as="font" type="font/woff2" crossorigin>
```
* **CSS Co-location:** Critical layout styles must be in the initial CSS bundle; view-specific styles should be modularized and loaded with their components.

---

## 5. Build Configuration & Vendor Management

The `vite.config.js` (or equivalent) must be optimized to prevent vendor bloat from invalidating the user's browser cache.

### Deterministic Manual Chunking

```javascript
// vite.config.js example
build: {
  rollupOptions: {
    output: {
      manualChunks: {
        'react-core': ['react', 'react-dom'],
        'auth-vendor': ['[auth-library]'],
        'db-vendor': ['[database-client]'],
        'ui-vendor': ['[ui-library-1]', '[ui-library-2]'],
      }
    }
  },
  target: 'esnext',
  minify: 'esbuild',
}
```

### The Dependency Protocol

1. **Bundlephobia Audit:** Before running `npm install <package>`, check [Bundlephobia](https://bundlephobia.com).
   - Packages **>50KiB** require architectural approval.
   - Packages **>100KiB** MUST be dynamically imported.
2. **Strict Tree-Shaking:** Avoid importing entire libraries. Use precise named imports.

---

## 6. Lighthouse Targets & CI/CD Regression

| Metric / Category | Target Score / Time |
| --- | --- |
| **Performance (Lighthouse)** | 95+ |
| **Largest Contentful Paint (LCP)** | < 2.5s |
| **Interaction to Next Paint (INP)** | < 200ms |
| **Cumulative Layout Shift (CLS)** | < 0.1 |
| **Accessibility / Best Practices** | 100 |

### The Regression Rule

CI/CD pipelines must include automated bundle-size checks and Lighthouse CI. Any Pull Request that increases the main bundle by more than **5%**, drops the Performance score below **90**, or fails a Core Web Vital on a simulated "Fast 3G / Mobile" profile is a **Breaking Change** and must not be merged until optimized.
