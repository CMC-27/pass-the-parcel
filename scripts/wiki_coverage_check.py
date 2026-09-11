#!/usr/bin/env python3
"""Wiki coverage gate: verifies every non-test source file carries wiki evidence.

Complements scripts/wiki_lint.py (which validates the doc graph — links, anchors,
frontmatter, index completeness). This script validates the CODE graph: every
util/hook/component/view file must be evidenced, so the wiki can never silently
drift when code changes shape but not name.

Coverage rule: a file is covered if ANY of these holds:
  (a) its filename (e.g. `useBlockResolution.js`) appears in the domain index;
  (b) its parent folder path (e.g. `src/utils/proposals/`) appears — folder modules
      like `src/utils/csvParser/` are covered by a single folder row;
  (c) the domain index cites an identifier the file actually exports
      (regex-approximate; see the ponytail ceiling above `exports_of`);
  (d) a wiki doc carries a `claims:` entry whose `source` path resolves to the file
      (the doc→source map is inverted; the `#symbol` fragment is trusted).

Routes (a)/(b) are retained for back-compat with existing satellite indexes.
Files in ALLOWLIST are exempt (trivial helpers, barrels) — each entry MUST carry a
reason. Exit 0 = coverage OK, exit 1 = gaps found (print gap table).

Usage: python scripts/wiki_coverage_check.py
"""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# domain -> (source glob patterns, index file)
DOMAINS = {
    "logic (utils + hooks)": (
        ["src/utils/**/*.js", "src/hooks/*.js"],
        ".wiki/logic/logic-index.md",
    ),
    "components": (
        ["src/components/**/*.jsx"],
        ".wiki/components/components-index.md",
    ),
    "features (views)": (
        ["src/views/**/*.jsx"],
        ".wiki/features/features-index.md",
    ),
}

# Exempt files with explicit reasons. Keep this list SHORT — every entry is a
# documented decision that the file needs no wiki coverage.
ALLOWLIST = {
    "src/utils/csvParser/index.js": "barrel re-export of the csvParser folder module",
    "src/utils/csvParser/utils.js": "internal helper of the csvParser folder module",
    "src/utils/csvParser/io.js": "internal file-reading helper of the csvParser folder module",
    "src/utils/csvParser/export.js": "internal export helper of the csvParser folder module",
    "src/utils/csvParser/template.js": "internal CSV template helper of the csvParser folder module",
}

# ---------------------------------------------------------------------------
# Export discovery — regex approximation, stdlib only (no JS/TS parser).
# ---------------------------------------------------------------------------

# ponytail: regex export scan - approximate for anonymous default exports, re-exports with aliasing, and non-standard syntax; upgrade path is a real JS/TS parser.
_EXPORT_PATTERNS = (
    re.compile(r"export\s+(?:async\s+)?function\s*\*?\s*([A-Za-z_$][\w$]*)"),
    re.compile(r"export\s+(?:const|let|var|class)\s+([A-Za-z_$][\w$]*)"),
    re.compile(r"export\s+default\s+(?:async\s+)?function\s*\*?\s*([A-Za-z_$][\w$]*)"),
    re.compile(r"export\s+default\s+class\s+([A-Za-z_$][\w$]*)"),
    re.compile(r"export\s+default\s+(?!function\b|class\b)([A-Za-z_$][\w$]*)"),
)
_LIST_PATTERNS = (
    re.compile(r"export\s*\{([^}]*)\}"),
    re.compile(r"module\.exports\s*=\s*\{([^}]*)\}"),
)
_SIDE_EXPORT_PATTERN = re.compile(r"(?:module\.exports|exports)\.([A-Za-z_$][\w$]*)\s*=")
_IDENT_PATTERN = re.compile(r"[A-Za-z_$][\w$]*")


def exports_of(path):
    """Set of exported identifiers discovered in a source file (regex)."""
    try:
        text = path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return set()
    names = set()
    for pat in _EXPORT_PATTERNS:
        for m in pat.finditer(text):
            names.add(m.group(1))
    for pat in _LIST_PATTERNS:
        for m in pat.finditer(text):
            for token in m.group(1).split(","):
                for part in token.split(" as "):
                    part = part.strip()
                    if _IDENT_PATTERN.fullmatch(part):
                        names.add(part)
    for m in _SIDE_EXPORT_PATTERN.finditer(text):
        names.add(m.group(1))
    return names


def collect_files(patterns):
    files = []
    for pat in patterns:
        for p in sorted(ROOT.glob(pat)):
            if not p.is_file():
                continue
            rel = p.relative_to(ROOT).as_posix()
            if ".test." in p.name or ".stories." in p.name:
                continue
            if rel in ALLOWLIST:
                continue
            files.append(rel)
    return files


def covered(rel, index_text, exports, claimed_sources):
    name = Path(rel).name
    # (a) filename match with boundary guard so `Modal.jsx` does not match
    # `CSVImportModal.jsx` (preceding char must not be a word char)
    if re.search(r"(?<![\w])" + re.escape(name), index_text):
        return True
    # (b) folder-module match: parent dir path with trailing slash in index
    parent = str(Path(rel).parent.as_posix()) + "/"
    if parent in index_text:
        return True
    # (c) symbol evidence: the index cites an identifier this file exports
    for sym in exports:
        if re.search(r"(?<![\w])" + re.escape(sym) + r"\b", index_text):
            return True
    # (d) claims evidence: a `claims:` entry names this source path
    if rel in claimed_sources:
        return True
    return False


def main():
    total = 0
    gaps = []
    # Graceful no-op: the template repo has no application source tree. The gate
    # activates automatically in satellites that do (src/ present).
    if not (ROOT / "src").is_dir():
        print("coverage OK: no src/ tree in this workspace — nothing to cover")
        return 0
    # Claims evidence: the parser is owned by wiki_claims.py — import it lazily
    # AFTER the no-op guard so the template path never walks the wiki.
    from wiki_claims import claim_docs, source_path  # noqa: PLC0415
    claimed_sources = {
        src
        for _, items in claim_docs()
        for src in (source_path(c) for c in items)
        if src
    }
    for domain, (patterns, index_path) in DOMAINS.items():
        index_file = ROOT / index_path
        if not index_file.exists():
            print(f"ERROR: index file missing: {index_path}")
            return 1
        index_text = index_file.read_text(encoding="utf-8")
        files = collect_files(patterns)
        total += len(files)
        for rel in files:
            if not covered(rel, index_text, exports_of(ROOT / rel), claimed_sources):
                gaps.append((domain, rel))

    if gaps:
        print(f"COVERAGE GAPS: {len(gaps)} file(s) not referenced in their wiki index\n")
        cur = None
        for domain, rel in gaps:
            if domain != cur:
                print(f"  [{domain}]")
                cur = domain
            print(f"    - {rel}")
        print(
            "\nFix: add an index row citing an exported symbol, add a "
            "`claims: source:` binding on a wiki doc, or add to ALLOWLIST in "
            "scripts/wiki_coverage_check.py with a reason."
        )
        return 1

    print(f"coverage OK: {total} source files checked, all referenced in wiki indexes")
    return 0


if __name__ == "__main__":
    sys.exit(main())
