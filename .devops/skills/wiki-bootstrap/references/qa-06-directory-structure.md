# Q&A: 04 — Directory Structure (The Map)

**Why this doc matters to AI agents:**
Agents use this to decide where to put new files. A wrong folder = a code review failure or a broken convention. Missing folders = agents invent their own (inconsistent) structure.

**Required sections:**
- Root layout (top-level folders and their purpose)
- `src/` tree with each subfolder's purpose
- Logic directory conventions (where utilities, hooks, services live)
- Component library structure (atoms / molecules / organisms)
- File naming rules per folder

## Questions to ask
1. What is the root layout of the project? (Top-level folders and what each is for.)
2. Walk through `src/` — what is each top-level subfolder responsible for?
3. Where do utilities live? Where do custom hooks live? Where do engines/services live?
4. How is the component library organized? (Atomic design? Feature folders? Flat by type?)
5. What are the file naming rules per folder? (e.g., `PascalCase.tsx` for components, `camelCase.ts` for utils, `use*.ts` for hooks.)
6. Are there any non-obvious folder conventions (e.g., colocated tests, barrel files, feature folders with co-located docs)?
7. Are there any directories in `src/` that aren't documented here?

## Sources of truth
- `src/` — actual tree (use `ls` and `glob`)
- `package.json` — scripts reveal how folders are used
- `tsconfig.json` — path aliases reveal logical grouping
