#!/usr/bin/env python3
"""
wiki_lint.py — Deterministic linter for the parcel blueprint knowledge base.

Enforces the rules in .wiki/rules/:
  - Structure manifest anchors exist (HARD)
  - Internal markdown links resolve (HARD)
  - Frontmatter required fields present (HARD)
  - Status is a known value (HARD)
  - Frontmatter `related-to`/`dependencies` path targets resolve (HARD)
  - Hub links to every existing category index (HARD)
  - Category index catalogues every sibling doc (WARN  [UNINDEXED])
  - Index rows point at existing files (WARN  [MISSING])
  - Every top-level `.wiki/rules/*.md` is catalogued in `.wiki/rules/README.md` (HARD  [UNCATALOGUED])
  - Every content doc reachable from the hub (WARN  unreachable from hub; rules/ excluded)
  - Orphans detected (INFO)

Usage:
    python scripts/wiki_lint.py            # report findings
    python scripts/wiki_lint.py --fix      # auto-repair deterministic index issues
    python scripts/wiki_lint.py --quiet    # suppress output on clean run

Exits 1 on hard failures (broken links, missing anchors, missing frontmatter).

Split (W6): the reader trio, primitives and constants live in `wiki_lint_core.py`; the ten
check steps and the `--fix` writer live in `wiki_lint_checks.py`. This module stays the CLI
and the import surface — the names below are re-exported literally, because
`scripts/wiki_claims.py` resolves a claim's `#symbol` with a word-boundary **text** lookup
against this file.
"""

import argparse
import sys

from wiki_lint_checks import run_checks
from wiki_lint_core import (  # noqa: F401  (re-exported: this module is the import surface)
    MANIFEST,
    REQUIRED_FIELDS,
    ROOT,
    WIKI,
    category_indexes,
    frontmatter_block,
    is_path_token,
    list_field,
    parse_frontmatter,
    rel,
    resolve_link,
)


def main() -> int:
    parser = argparse.ArgumentParser(description="Deterministic wiki linter")
    parser.add_argument("--fix", action="store_true", help="auto-repair deterministic issues")
    parser.add_argument("--quiet", action="store_true", help="suppress output on clean run")
    args = parser.parse_args()
    return run_checks(fix=args.fix, quiet=args.quiet)


if __name__ == "__main__":
    sys.exit(main())
