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
  - Every content doc reachable from the hub (WARN  unreachable from hub; rules/ excluded)
  - Orphans detected (INFO)

Usage:
    python scripts/wiki_lint.py            # report findings
    python scripts/wiki_lint.py --fix      # auto-repair deterministic index issues
    python scripts/wiki_lint.py --quiet    # suppress output on clean run

Exits 1 on hard failures (broken links, missing anchors, missing frontmatter).
"""

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
WIKI = ROOT / ".wiki"
DEVOPS = ROOT / ".devops"
MANIFEST = ROOT / ".wiki" / "rules" / "structure.md"
HUB = WIKI / "core" / "00-system-index.md"

VALID_STATUS = {"stable", "in-progress", "deprecated", "template", "approved"}
VALID_FORMAT_VERSION = {"1"}
REQUIRED_FIELDS = ["name", "type", "status", "format-version"]

# README/index files are exempt from the required-fields check (they may be plain headers).
# Pattern-based so a new *-index.md needs no edit here.
def is_fm_exempt_name(name: str) -> bool:
    return name == "README.md" or name == "index.md" or name.endswith("-index.md")


# Paths exempt from the frontmatter required-fields check (link checks still apply).
FM_EXEMPT_PREFIXES = (
    str(ROOT / ".devops" / "agents"),
    str(ROOT / ".devops" / "skills" / "ptp-"),
    str(ROOT / ".devops" / "skills" / "pass-the-parcel"),
    str(ROOT / ".devops" / "rules"),
    str(ROOT / ".opencode"),
)

# Historical records: never linted for live claims (plans, archives, logs).
HISTORICAL_PREFIXES = (".devops/plans/", ".devops/archive/", ".devops/logs/")

# Frontmatter fields whose path-shaped values must resolve.
FM_LINK_FIELDS = ("related-to", "dependencies")

# Elements that mark a token as an illustrative placeholder, not a real path.
PLACEHOLDER_CHARS = set("<>[]{}*")


def parse_frontmatter(text: str) -> tuple[dict, str]:
    """Return (frontmatter_dict, body). Empty dict if no frontmatter."""
    if not text.startswith("---"):
        return {}, text
    match = re.match(r"^---\s*\n(.*?)\n---\s*\n", text, re.DOTALL)
    if not match:
        return {}, text
    fm = {}
    for line in match.group(1).splitlines():
        if ":" in line and not line.strip().startswith("#"):
            key, _, val = line.partition(":")
            fm[key.strip()] = val.strip().strip("\"'").strip()
    return fm, text[match.end():]


def frontmatter_block(text: str) -> str | None:
    """Return the raw YAML frontmatter block (without fences), or None."""
    if not text.startswith("---"):
        return None
    match = re.match(r"^---\s*\n(.*?)\n---\s*\n", text, re.DOTALL)
    return match.group(1) if match else None


def list_field(block: str | None, key: str) -> list[str]:
    """Extract a flow-list (`key: [a, b]`) or simple block-list (`key:` + `- a`).

    Flat scalar reader only — no nested YAML support (see plan ponytail ceiling).
    """
    if not block:
        return []
    tokens: list[str] = []
    lines = block.splitlines()
    for i, line in enumerate(lines):
        match = re.match(rf"^{re.escape(key)}\s*:\s*(.*)$", line)
        if not match:
            continue
        rest = match.group(1).strip()
        if rest.startswith("["):
            inner = rest[1:].rsplit("]", 1)[0]
            tokens += [t.strip().strip("\"'") for t in inner.split(",") if t.strip()]
        elif rest:
            tokens.append(rest.strip("\"'"))
        else:
            for nxt in lines[i + 1:]:
                sub = re.match(r"^\s+-\s*(.+)$", nxt)
                if sub:
                    tokens.append(sub.group(1).strip().strip("\"'"))
                elif not nxt.strip():
                    continue
                else:
                    break
        break
    return tokens


def is_path_token(token: str) -> bool:
    """True when a frontmatter token is a path we can resolve (vs an illustrative token)."""
    if not token or any(c in PLACEHOLDER_CHARS for c in token):
        return False
    if token.startswith(("http://", "https://", "mailto:", "#")):
        return False
    return "/" in token or token.endswith(".md")


def resolve_link(link: str, src_file: Path) -> Path | None:
    """Resolve a relative markdown link against the source file's directory."""
    link = link.split("#")[0]
    if not link or link.startswith(("http://", "https://", "mailto:", "#")):
        return None
    if link.startswith("/"):
        target = ROOT / link.lstrip("/")
    else:
        target = (src_file.parent / link).resolve()
    # Try as-is, then with .md if extensionless.
    if target.exists():
        return target
    if not target.suffix and (target.with_suffix(".md")).exists():
        return target.with_suffix(".md")
    return None


def extract_links(text: str) -> list[str]:
    """Extract relative markdown link targets, skipping code blocks/fences and inline code."""
    # Strip fenced code blocks first so `[x](y)` inside code never counts.
    text = re.sub(r"```.*?```", "", text, flags=re.DOTALL)
    text = re.sub(r"`[^`]*`", "", text)
    return re.findall(r"\[[^\]]*\]\(([^)]+)\)", text)


def encoding_problem(path: Path) -> str | None:
    """Return a description if the file has a BOM or is not valid UTF-8, else None."""
    raw = path.read_bytes()
    if raw.startswith(b"\xef\xbb\xbf"):
        return "UTF-8 BOM (EF BB BF) — write UTF-8 without BOM"
    if raw.startswith(b"\xff\xfe"):
        return "UTF-16 LE BOM (FF FE) — must be UTF-8"
    if raw.startswith(b"\xfe\xff"):
        return "UTF-16 BE BOM (FE FF) — must be UTF-8"
    try:
        raw.decode("utf-8")
    except UnicodeDecodeError as e:
        return f"not valid UTF-8 ({e})"
    return None


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def category_indexes() -> list[Path]:
    """Every category spoke index that exists (excludes the hub and README)."""
    out = []
    for f in sorted(WIKI.rglob("*-index.md")):
        if f == HUB or f.name == "index.md":
            continue
        out.append(f)
    return out


# ---------------------------------------------------------------------------
# Deterministic repairs (--fix): collected during the full scan, applied once.
# ---------------------------------------------------------------------------

def _last_table_bounds(lines: list[str]) -> tuple[int, int] | None:
    """Return (start, end) line indices of the last markdown table, or None."""
    bounds = None
    start = None
    for i, line in enumerate(lines):
        if line.lstrip().startswith("|"):
            if start is None:
                start = i
        else:
            if start is not None:
                bounds = (start, i - 1)
                start = None
    if start is not None:
        bounds = (start, len(lines) - 1)
    if not bounds:
        return None
    # A table needs at least a header + separator row.
    return bounds if bounds[1] > bounds[0] else None


def _fix_unindexed(index_path: Path, doc_path: Path) -> str | None:
    lines = index_path.read_text(encoding="utf-8").splitlines()
    bounds = _last_table_bounds(lines)
    if not bounds:
        return None
    start, end = bounds
    cols = max(1, lines[start].count("|") - 1)
    fm, _ = parse_frontmatter(doc_path.read_text(encoding="utf-8"))
    name = fm.get("name") or fm.get("title") or doc_path.stem
    desc = fm.get("description") or "-"
    cells = [f"[{name}]({doc_path.name})", desc]
    while len(cells) < cols:
        cells.append("-")
    row = "| " + " | ".join(cells[:cols]) + " |"
    lines.insert(end + 1, row)
    index_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return f"FIX  {rel(index_path)}: added index row for {rel(doc_path)}"


def _fix_missing(index_path: Path, link: str) -> str | None:
    lines = index_path.read_text(encoding="utf-8").splitlines()
    kept = []
    removed = 0
    for line in lines:
        if line.lstrip().startswith("|") and f"]({link}" in line:
            removed += 1
            continue
        kept.append(line)
    if not removed:
        return None
    index_path.write_text("\n".join(kept) + "\n", encoding="utf-8")
    return f"FIX  {rel(index_path)}: removed {removed} index row(s) for missing `{link}`"


def main() -> int:
    parser = argparse.ArgumentParser(description="Deterministic wiki linter")
    parser.add_argument("--fix", action="store_true", help="auto-repair deterministic issues")
    parser.add_argument("--quiet", action="store_true", help="suppress output on clean run")
    args = parser.parse_args()

    findings: list[str] = []
    hard_failures = 0
    hard_msgs: list[str] = []

    def hard(msg: str) -> None:
        nonlocal hard_failures
        hard_failures += 1
        hard_msgs.append(msg)
        findings.append(f"HARD  {msg}")

    # 0. Encoding guard: flag BOMs and non-UTF-8 files before any parsing.
    #    This byte check is the only one that inspects raw bytes, not parsed text.
    bad_encoding = set()
    for f in sorted(WIKI.rglob("*.md")):
        enc = encoding_problem(f)
        if enc:
            bad_encoding.add(str(f.resolve()))
            hard(f"{rel(f)}: {enc}")

    # 1. Structure manifest anchors exist.
    if str(MANIFEST.resolve()) in bad_encoding:
        anchors = []
    else:
        manifest_text = MANIFEST.read_text(encoding="utf-8")
        anchors = re.findall(r"\| `([^`]+)` \|", manifest_text)
    for anchor in anchors:
        p = ROOT / anchor
        if not p.exists():
            hard(f"structure.md: missing anchor `{anchor}`")

    # 2. Walk wiki content: body links + frontmatter fields.
    for f in sorted(WIKI.rglob("*.md")):
        if str(f.resolve()) in bad_encoding:
            continue
        text = f.read_text(encoding="utf-8")
        fm, body = parse_frontmatter(text)

        # Frontmatter required fields.
        if not str(f).startswith(FM_EXEMPT_PREFIXES) and not is_fm_exempt_name(f.name):
            for field in REQUIRED_FIELDS:
                if field not in fm:
                    hard(f"{rel(f)}: missing frontmatter field `{field}`")
                    break
            if "status" in fm and fm["status"] not in VALID_STATUS:
                hard(f"{rel(f)}: invalid status `{fm['status']}`")
            if "format-version" in fm and fm["format-version"] not in VALID_FORMAT_VERSION:
                hard(f"{rel(f)}: unknown format-version `{fm['format-version']}`")

        # Links resolve.
        for link in extract_links(body):
            if link.startswith(("http://", "https://", "mailto:", "#", "file://")):
                continue
            if resolve_link(link, f) is None:
                hard(f"{rel(f)}: broken link `{link}`")

    # 3. Frontmatter link targets resolve (`.wiki/**` + `.devops/**`).
    for base in (WIKI, DEVOPS):
        for f in sorted(base.rglob("*.md")):
            r = rel(f)
            if r.startswith(HISTORICAL_PREFIXES):
                continue
            if str(f.resolve()) in bad_encoding:
                continue
            block = frontmatter_block(f.read_text(encoding="utf-8"))
            if block is None:
                continue
            for key in FM_LINK_FIELDS:
                for token in list_field(block, key):
                    if is_path_token(token) and resolve_link(token, f) is None:
                        hard(f"{r}: broken frontmatter link `{token}`")

    # 3b. Grounded claims structure. The parser is owned by wiki_claims.py —
    #     import it lazily so the module-level wiki_claims -> wiki_lint import
    #     never forms a cycle.
    from wiki_claims import claims as parse_claims  # noqa: PLC0415
    for f in sorted(WIKI.rglob("*.md")):
        if str(f.resolve()) in bad_encoding:
            continue
        block = frontmatter_block(f.read_text(encoding="utf-8"))
        for claim in parse_claims(block):
            cid = claim.get("id", "<no-id>")
            absent = [k for k in ("id", "source", "hash") if k not in claim]
            if absent:
                hard(f"{rel(f)}: claim `{cid}` missing key(s): {', '.join(absent)}")
                continue
            src = claim["source"].split("#", 1)[0].strip()
            if src and not (ROOT / src).exists():
                hard(f"{rel(f)}: claim `{cid}` source not found `{src}`")

    # 4. Hub -> spoke links (every category index that exists).
    hub_targets: set[str] = set()
    if HUB.exists():
        hub_text = HUB.read_text(encoding="utf-8")
        _, hub_body = parse_frontmatter(hub_text)
        for link in extract_links(hub_body):
            t = resolve_link(link, HUB)
            if t:
                hub_targets.add(str(t.resolve()))
        for idx in category_indexes():
            if str(idx.resolve()) not in hub_targets:
                hard(f"{rel(HUB)}: [HUB MISSING SPOKE] {rel(idx)}")

    # 5. Index cataloguing: [MISSING] rows and [UNINDEXED] siblings.
    unindexed: list[tuple[Path, Path]] = []
    missing: list[tuple[Path, str]] = []
    for idx in category_indexes():
        idx_text = idx.read_text(encoding="utf-8")
        _, idx_body = parse_frontmatter(idx_text)
        listed: set[str] = set()
        for link in extract_links(idx_body):
            t = resolve_link(link, idx)
            if t is None:
                findings.append(f"WARN  {rel(idx)}: [MISSING] {link}")
                missing.append((idx, link))
            else:
                listed.add(str(t.resolve()))
        for sib in sorted(idx.parent.glob("*.md")):
            if sib == idx or is_fm_exempt_name(sib.name):
                continue
            if str(sib.resolve()) not in listed:
                findings.append(f"WARN  {rel(idx)}: [UNINDEXED] {rel(sib)}")
                unindexed.append((idx, sib))

    # 6. Reachability from the hub (WARN). Governance/meta areas sit above or
    #    beside the hub-and-spoke graph, so rules/ joins the orphan exemptions.
    if HUB.exists():
        reachable = set(hub_targets)
        frontier = set(hub_targets)
        while frontier:
            nxt: set[str] = set()
            for target in frontier:
                p = Path(target)
                if not p.exists() or p.suffix != ".md":
                    continue
                if str(p.resolve()) in bad_encoding:
                    continue
                _, body = parse_frontmatter(p.read_text(encoding="utf-8"))
                for link in extract_links(body):
                    t = resolve_link(link, p)
                    if t and str(t.resolve()) not in reachable:
                        reachable.add(str(t.resolve()))
                        nxt.add(str(t.resolve()))
            frontier = nxt
        for f in WIKI.rglob("*.md"):
            if is_fm_exempt_name(f.name) or f.name == "knowledge-capture.md":
                continue
            r = f.relative_to(WIKI).as_posix()
            if r.startswith(("ref/", "templates/", "examples/", "rules/")):
                continue
            if str(f.resolve()) not in reachable:
                findings.append(f"WARN  {rel(f)}: unreachable from hub")

    # 7. Orphans (report only).
    linked_targets = set()
    for f in WIKI.rglob("*.md"):
        if str(f.resolve()) in bad_encoding:
            continue
        text = f.read_text(encoding="utf-8")
        for link in extract_links(text):
            t = resolve_link(link, f)
            if t:
                linked_targets.add(str(t.resolve()))
    for f in WIKI.rglob("*.md"):
        if is_fm_exempt_name(f.name) or f.name == "knowledge-capture.md":
            continue
        rel_wiki = f.relative_to(WIKI).as_posix()
        if rel_wiki.startswith(("ref/", "templates/", "examples/")):
            continue
        if str(f.resolve()) not in linked_targets:
            findings.append(f"INFO  {rel(f)}: orphan (no inbound links)")

    # 8. Deterministic repairs — only when the scan is clean apart from the [MISSING]
    #    rows themselves. A [MISSING] row also trips the HARD body-link check (an
    #    accepted, documented overlap: the row's link does not resolve AND the index
    #    does not catalogue a real file). Those specific hard findings must not block
    #    the repair that removes them; any other hard failure does.
    applied = 0
    missing_links = {link for _, link in missing}
    blockers = [
        m for m in hard_msgs
        if not (f"broken link `" in m and any(f"`{lnk}`" in m for lnk in missing_links))
    ]
    if args.fix and not blockers:
        for idx, doc in unindexed:
            line = _fix_unindexed(idx, doc)
            if line:
                findings.append(line)
                applied += 1
        for idx, link in missing:
            line = _fix_missing(idx, link)
            if line:
                findings.append(line)
                applied += 1
                # Drop the hard body-link finding the repaired (now deleted) row produced.
                pat = f"broken link `{link}`"
                kept = []
                for fnd in findings:
                    if fnd.startswith("HARD") and pat in fnd:
                        hard_failures -= 1
                        continue
                    kept.append(fnd)
                findings = kept

    # 9. Report.
    if not findings:
        if not args.quiet:
            print("OK: wiki healthy - 0 broken links, all anchors present, frontmatter valid.")
        return 0
    if args.quiet and hard_failures == 0:
        return 0
    for line in findings:
        print(line)
    print(f"---\n{len(findings)} findings, {hard_failures} hard failures, {applied} fixes applied.")
    return 1 if hard_failures else 0


if __name__ == "__main__":
    sys.exit(main())
