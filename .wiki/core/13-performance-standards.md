---
title: "⚡ Performance Standards"
type: "core"
name: "Performance Standards"
status: "stable"
dependencies: []
db_relations: []
description: "Architectural guardrails for maintaining a 95+ Lighthouse Performance Score, passing Core Web Vitals, and ensuring a frictionless user experience."
---

# Performance Standards

This document establishes the architectural guardrails for maintaining a **95+ Lighthouse Performance Score** and ensuring a snappy, responsive user experience. We optimize for **Core Web Vitals**: LCP, INP, and CLS.

---

## 1. Bundle Architecture & Splitting

### The Lazy-Loading & Prefetching Rule

To keep the **Initial Bundle Size under 250KiB (Gzipped/Brotli)**, all non-critical routes and heavy UI components MUST be deferred.

* **Required Lazy Components:**
  * **[Admin / Internal Views]:** `[ViewName1]`, `[ViewName2]`, `[ViewName3]`.
  * **[User-Facing Views]:** `[ViewName4]`, `[ViewName5]`.
  * **Modals & Drawers:** Any overlay containing complex forms or data tables.

* **Intent-Based Prefetching:** Preload lazy chunks when a user hovers over navigation links.

### Singleton Dynamic Import Pattern

For heavy utility libraries, use the dynamic `import()` statement:

```javascript
const handleExport = async (data) => {
  const { unparse } = await import('papaparse');
  const csv = unparse(data);
};
```

---

## 2. React Render Optimization (Solving INP)

### Non-Blocking State Updates

* **`useTransition`:** Wrap expensive state updates in `startTransition`.
* **`useDeferredValue`:** Use for deferring computationally heavy list renders.
* **Debounced State Sync:** High-frequency inputs must be debounced to **300ms**.

### State Colocation & Memoization

* **Push State Down:** Keep state close to the consuming component.
* **Targeted `React.memo()`:** Memoize components that frequently receive identical props.
* **Mandatory Memoization:** `Sidebar`, `TopNav`, large data grid rows, chart components.

---

## 3. Data Fetching & Network Efficiency

* **Caching & Deduping:** All API requests must route through a caching layer or context service.
* **Stale-While-Revalidate:** Render cached data immediately while re-fetching in the background.
* **Parallel Fetching:** Fetch multiple endpoints via `Promise.all()` at route level.
* **Progressive Chunked Synchronization:** Background syncs in chunks of `[1000]` rows.

---

## 4. Asset & Media Delivery

### Image Optimization

* **Explicit Dimensions:** Every `<img>` MUST have `width` and `height` attributes.
* **Modern Formats:** Serve images in WebP or AVIF.
* **Native Lazy Loading:** Images below the fold must include `loading="lazy"`.

### Font & CSS Strategy

* **Preload Critical Fonts:** Prevent FOUT by preloading primary fonts.
* **CSS Co-location:** Critical layout styles in initial bundle; view-specific styles with components.

---

## 5. Build Configuration & Vendor Management

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

1. **Bundlephobia Audit:** Check [Bundlephobia](https://bundlephobia.com) before installing packages.
   - Packages **>50KiB** require architectural approval.
   - Packages **>100KiB** MUST be dynamically imported.
2. **Strict Tree-Shaking:** Use precise named imports.

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

CI/CD pipelines must include automated bundle-size checks and Lighthouse CI. Any PR that increases the main bundle by more than **5%**, drops Performance below **90**, or fails a Core Web Vital on "Fast 3G / Mobile" is a **Breaking Change**.
