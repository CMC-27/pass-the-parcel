---
name: claims
type: rule
title: Grounded Claims
status: stable
format-version: 1
tags: [wiki, rules, claims, evidence, drift]
owner: Wiki Owner
last-reviewed: 2026-09-11
related-to: [./frontmatter.md, ./link-hygiene.md, ../../scripts/wiki_claims.py]
claims:
  - id: claims-parser-owner
    source: scripts/wiki_claims.py#claims
    hash: sha256:bc7edd793b71fcfa3744730b9083eaab09d58f4ab4c3d4a3ac476cf0c5b21750
---

# Grounded Claims

> A material fact in a wiki doc can carry a **Grounded Claim** — a binding to the source file that makes it true, plus a hash of that file. When the source changes, `scripts/wiki_claims.py` reports the claim stale. The wiki stops being a static snapshot and starts reporting its own drift.

## Claim Shape

A claim lives in the owning doc's frontmatter, under `claims:`. A doc with no material claims omits the block.

```yaml
claims:
  - id: lint-required-fields
    source: scripts/wiki_lint.py#REQUIRED_FIELDS
    hash: sha256:0f1e2d...
```

| Key | Meaning |
|---|---|
| `id` | Slug, unique within the doc. Names the proposition, not the file |
| `source` | Repo-relative POSIX path, plus `#symbol` naming the function, class, constant, or section that carries the fact |
| `hash` | `sha256:` prefix + hex digest of the **whole source file's bytes** |

A claim whose `source` carries no `#symbol` is legal — it binds the fact to the whole file. When a `#symbol` **is** present, `check` resolves it against the named source file (see [Drift Semantics](#drift-semantics)).

## Hash Definition

The digest is `sha256` of the entire source file. Any edit to that file marks every claim pointing at it stale.

> **Ceiling (`ponytail:`)** — whole-file hashing over-flags: a claim about `main()` goes stale when an unrelated helper changes. This is deliberate. A false stale is a safe prompt to re-read; a missed drift is a wrong wiki. Upgrade path: hash a symbol-extracted region instead of the whole file.

## Drift Semantics

- `source` file missing on disk → **hard** lint failure (`wiki_lint.py`) and a `MISSING` row from the checker.
- `#symbol` present but absent from the source file → `UNRESOLVED-SYMBOL` row; the checker exits `1`. A claim that names a symbol the source does not contain is a false fact, so this is a deterministic failure, not a warning (one row per claim — the stale check is skipped for it).
- Recomputed hash ≠ stored hash → `STALE` row; the checker exits `1`.
- Claim present but a required key absent (`id`/`source`/`hash`) → **hard** lint failure.
- No `#symbol` in `source`, or no `claims:` block at all → legal. File-level claims are allowed and claims are opt-in per doc, not mandatory wiki-wide.

**Symbol matching (`ponytail:` ceiling):** identifier-shaped symbols (`^[A-Za-z_][A-Za-z0-9_]*$`) match on a word boundary, so `main` does not match `mainframe`. Any other symbol (e.g. a Markdown section title) matches case-insensitively as a substring. This is a text lookup, not language parsing — a name that appears only in a comment still resolves. Upgrade path: per-language symbol extraction.

## Coverage Evidence

A claim's `source` path is also consumed as **coverage evidence** by `scripts/wiki_coverage_check.py`. That gate inverts the doc→source map — it reads every `claims:` entry and treats any `source` path it names as a covered code file, independent of the domain index. A file the index never names therefore gains a second route to coverage; the four evidence routes are documented in the script's docstring, which is canonical.

The claim shape, the hash definition, and the `#symbol` semantics above are unchanged: coverage trusts the authored `#symbol` fragment rather than re-verifying it.

## Command Contract

| Command | Behaviour |
|---|---|
| `python scripts/wiki_claims.py check` | Walk `.wiki/**`, verify every claim, print `STALE`/`MISSING`/`UNRESOLVED-SYMBOL` rows, exit `1` on any |
| `python scripts/wiki_claims.py affected <sha>` | List docs whose `claims` / `dependencies` / `related-to` reference files changed in `<sha>..HEAD` |
| `python scripts/wiki_claims.py update` | Rewrite every claim's `hash` to the current source digest; print `STAMPED` rows |
| `--quiet` | Suppress output when clean (exit code still authoritative) |

`affected` exits `2` with a one-line message when the ref is unknown or the workspace is not a git repo. It never raises a traceback.

## Reporting Convention

Reports are **stdout-only** and exit codes are the contract — no committed report files. This matches `wiki_lint.py` and the retired `knowledge-changelog.md` convention.

## Workflow

1. Author a doc; add a `claims:` entry per material proposition.
2. `python scripts/wiki_claims.py update` to stamp hashes.
3. CI runs `check` on every push — a stale claim fails the build.
4. `@wiki-update` uses `affected` to refresh only the docs a diff touched.

---

*Last reviewed 2026-09-11. Changes to these rules require human sign-off.*
