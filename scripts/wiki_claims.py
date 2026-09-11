#!/usr/bin/env python3
"""wiki_claims.py — Grounded Claims checker for the wiki knowledge base.

A claim binds a material fact in a wiki doc to the source file that makes it
true, plus a sha256 of that file's bytes. When the source changes, the claim is
reported stale — the wiki reports its own drift instead of silently rotting.
`check` also resolves the `#symbol` fragment against its source file: a claim
that names a symbol the source does not contain is a false fact, reported as
`UNRESOLVED-SYMBOL` (a file-level claim with no `#symbol` is still legal).

Owns the claims-block parser (see .wiki/rules/claims.md). wiki_lint.py imports
it lazily; never re-implement claims parsing elsewhere.

Usage:
    python scripts/wiki_claims.py check            # verify claims, exit 1 on drift
    python scripts/wiki_claims.py affected <sha>   # docs hit by <sha>..HEAD
    python scripts/wiki_claims.py update           # re-stamp hashes to current
    python scripts/wiki_claims.py check --quiet    # suppress output when clean

Exit codes: 0 clean, 1 drift/findings, 2 usage error (bad ref / no git).
"""

import argparse
import hashlib
import re
import subprocess
import sys
from pathlib import Path

from wiki_lint import (
    ROOT,
    WIKI,
    frontmatter_block,
    is_path_token,
    list_field,
    parse_frontmatter,
    rel,
    resolve_link,
)

# ponytail: whole-file hashing. A claim about one symbol goes stale when any
# line of the file changes. Deliberate over-flagging (safe); upgrade path is a
# symbol-region hash. See .wiki/rules/claims.md.
CLAIM_KEYS = ("id", "source", "hash")
LINK_FIELDS = ("dependencies", "related-to")


# ---------------------------------------------------------------------------
# Claims parser — the single owner of the `claims:` frontmatter shape.
# ---------------------------------------------------------------------------

def claims(block: str | None) -> list[dict[str, str]]:
    """Parse a block-list of claim mappings from a frontmatter block.

    Shape (flat YAML subset, no anchors/aliases/nesting beyond one level):
        claims:
          - id: slug
            source: path#symbol
            hash: sha256:<hex>
    """
    if not block:
        return []
    items: list[dict[str, str]] = []
    cur: dict[str, str] | None = None
    in_claims = False
    for line in block.splitlines():
        if re.match(r"^claims\s*:\s*$", line) or re.match(r"^claims\s*:\s*\[\s*\]\s*$", line):
            in_claims = True
            continue
        if not in_claims:
            continue
        if re.match(r"^\S", line):  # next top-level key ends the block
            break
        m = re.match(r"^\s*-\s*([A-Za-z0-9_-]+)\s*:\s*(.*)$", line)
        if m:
            cur = {m.group(1): m.group(2).strip().strip("\"'")}
            items.append(cur)
            continue
        m = re.match(r"^\s+([A-Za-z0-9_-]+)\s*:\s*(.*)$", line)
        if m and cur is not None:
            cur[m.group(1)] = m.group(2).strip().strip("\"'")
    return items


def source_path(claim: dict[str, str]) -> str:
    """Repo-relative POSIX path before the `#symbol` fragment."""
    return claim.get("source", "").split("#", 1)[0].strip()


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


# Identifier-shaped symbols (function/class/constant names) must match on a word
# boundary; anything else (e.g. a Markdown section title) is matched as a
# case-insensitive substring.
_IDENT_SYMBOL = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")


def symbol_resolves(path: Path, symbol: str) -> bool:
    """True when `symbol` is present in the source file at `path`.

    ponytail: word/substring matching, not real symbol extraction — a name that
    only appears in a comment or string still resolves. Catches the lie this gate
    targets (a symbol that exists nowhere) with zero dependencies; upgrade path is
    per-language extraction (AST for Python, heading regex for Markdown).
    """
    try:
        text = path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return False
    if _IDENT_SYMBOL.match(symbol):
        return re.search(
            rf"(?<![A-Za-z0-9_]){re.escape(symbol)}(?![A-Za-z0-9_])", text
        ) is not None
    return symbol.lower() in text.lower()


# ---------------------------------------------------------------------------
# Corpus walk
# ---------------------------------------------------------------------------

def claim_docs() -> list[tuple[Path, list[dict[str, str]]]]:
    """Every wiki doc that carries a `claims:` block."""
    out = []
    for f in sorted(WIKI.rglob("*.md")):
        block = frontmatter_block(f.read_text(encoding="utf-8"))
        items = claims(block)
        if items:
            out.append((f, items))
    return out


def referenced_paths(doc: Path, items: list[dict[str, str]]) -> set[str]:
    """Source paths a doc's claims point at, plus its frontmatter link targets."""
    refs: set[str] = set()
    for c in items:
        src = source_path(c)
        if src:
            refs.add(src)
    block = frontmatter_block(doc.read_text(encoding="utf-8"))
    for key in LINK_FIELDS:
        for token in list_field(block, key):
            if is_path_token(token) and resolve_link(token, doc):
                refs.add(rel(resolve_link(token, doc)))
    return refs


# ---------------------------------------------------------------------------
# Modes
# ---------------------------------------------------------------------------

def cmd_check(quiet: bool) -> int:
    rows: list[str] = []
    for doc, items in claim_docs():
        for c in items:
            cid = c.get("id", "<no-id>")
            src = source_path(c)
            if not src:
                rows.append(f"BROKEN  {rel(doc)}: claim `{cid}` has no source")
                continue
            target = ROOT / src
            if not target.exists():
                rows.append(f"MISSING {rel(doc)}: claim `{cid}` -> `{src}` not found")
                continue
            fragment = c.get("source", "").split("#", 1)
            symbol = fragment[1].strip() if len(fragment) > 1 else ""
            if symbol and not symbol_resolves(target, symbol):
                rows.append(
                    f"UNRESOLVED-SYMBOL {rel(doc)}: claim `{cid}` -> "
                    f"`{src}#{symbol}` not found in source"
                )
                continue
            stored = c.get("hash", "")
            now = "sha256:" + digest(target)
            if stored != now:
                rows.append(
                    f"STALE   {rel(doc)}: claim `{cid}` -> `{src}` "
                    f"(stored {stored or '<none>'}, now {now})"
                )
    if rows:
        for r in rows:
            print(r)
        kinds = {r.split(" ", 1)[0] for r in rows}
        print(f"---\n{len(rows)} claim finding(s).")
        if "STALE" in kinds:
            print("    stale hash     -> python scripts/wiki_claims.py update")
        if kinds & {"MISSING", "UNRESOLVED-SYMBOL", "BROKEN"}:
            print("    fix source     -> correct the claim's `source` (path#symbol) in the doc; see .wiki/rules/claims.md")
        return 1
    if not quiet:
        print("claims OK: 0 stale, all grounded sources present.")
    return 0


def cmd_affected(ref: str) -> int:
    try:
        proc = subprocess.run(
            ["git", "diff", "--name-only", f"{ref}..HEAD"],
            cwd=str(ROOT),
            capture_output=True,
            text=True,
            check=False,
        )
    except FileNotFoundError:
        print("error: git not available")
        return 2
    if proc.returncode != 0:
        print(f"error: cannot diff `{ref}..HEAD` ({proc.stderr.strip() or 'unknown ref'})")
        return 2
    changed = {line.strip() for line in proc.stdout.splitlines() if line.strip()}
    if not changed:
        print(f"no files changed in {ref}..HEAD")
        return 0
    hit = False
    for doc, items in claim_docs():
        refs = referenced_paths(doc, items)
        overlap = sorted(refs & changed)
        if overlap:
            hit = True
            print(f"{rel(doc)}  <-  {', '.join(overlap)}")
    if not hit:
        print(f"no wiki docs reference the {len(changed)} file(s) changed in {ref}..HEAD")
    return 0


def _restamp_block(block: str, digests: list[str | None]) -> str:
    """Replace the Nth `hash:` line under claims with digests[N]."""
    out: list[str] = []
    in_claims = False
    idx = -1
    for line in block.splitlines():
        if not in_claims and re.match(r"^claims\s*:", line):
            in_claims = True
            out.append(line)
            continue
        if in_claims and re.match(r"^\S", line):
            in_claims = False
        if in_claims:
            if re.match(r"^\s*-\s*id\s*:", line):
                idx += 1
            m = re.match(r"^(\s*hash\s*:\s*)(.*)$", line)
            if m and 0 <= idx < len(digests) and digests[idx] is not None:
                out.append(f"{m.group(1)}sha256:{digests[idx]}")
                continue
        out.append(line)
    return "\n".join(out)


def cmd_update() -> int:
    stamped = 0
    for doc, items in claim_docs():
        text = doc.read_text(encoding="utf-8")
        m = re.match(r"^---\s*\n(.*?)\n---\s*\n", text, re.DOTALL)
        if not m:
            continue
        digests: list[str | None] = []
        for c in items:
            src = source_path(c)
            target = ROOT / src if src else None
            digests.append(digest(target) if target and target.exists() else None)
        new_block = _restamp_block(m.group(1), digests)
        if new_block != m.group(1):
            new = text[:m.start(1)] + new_block + text[m.end(1):]
            with open(doc, "w", encoding="utf-8", newline="\n") as fh:
                fh.write(new)
            stamped += 1
            for c, d in zip(items, digests):
                if d:
                    print(f"STAMPED {rel(doc)}: claim `{c.get('id','<no-id>')}`")
    if not stamped:
        print("no claims to stamp")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Grounded Claims checker")
    sub = parser.add_subparsers(dest="mode", required=True)
    p_check = sub.add_parser("check")
    p_check.add_argument("--quiet", action="store_true")
    p_affected = sub.add_parser("affected")
    p_affected.add_argument("ref")
    sub.add_parser("update")
    args = parser.parse_args()

    if args.mode == "check":
        return cmd_check(args.quiet)
    if args.mode == "affected":
        return cmd_affected(args.ref)
    if args.mode == "update":
        return cmd_update()
    return 2


if __name__ == "__main__":
    sys.exit(main())
