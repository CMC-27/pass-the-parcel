#!/usr/bin/env python3
"""wiki_okf.py — project the wiki into an Open Knowledge Format (OKF) v0.2 bundle.

The local frontmatter schema (.wiki/rules/frontmatter.md) stays authoritative.
This script is a one-way projection (export only): it copies each concept doc's
body unchanged and rewrites the frontmatter to OKF v0.2 fields. The bundle root
carries `okf_version: "0.2"`.

Usage:
    python scripts/wiki_okf.py export [--out openwiki] [--quiet]

Exit codes: 0 ok, 1 no concepts found.
"""

import argparse
import datetime
import re
import sys
from pathlib import Path

from wiki_lint import ROOT, WIKI, frontmatter_block, list_field, parse_frontmatter, rel

FM_RE = re.compile(r"^---\s*\n.*?\n---\s*\n", re.DOTALL)


def strip_frontmatter(text: str) -> str:
    m = FM_RE.match(text)
    return text[m.end():] if m else text


def concept_frontmatter(fm: dict, block: str | None) -> list[str]:
    """OKF v0.2 concept frontmatter: `type` is the only required key."""
    lines = ["---", f"type: {fm.get('type') or 'concept'}"]
    title = fm.get("title") or fm.get("name")
    if title:
        lines.append(f"title: {title}")
    if fm.get("description"):
        lines.append(f"description: {fm['description']}")
    tags = list_field(block, "tags")
    if tags:
        lines.append("tags: [" + ", ".join(tags) + "]")
    if fm.get("status"):
        lines.append(f"status: {fm['status']}")
    lines.append(f"generated: {{by: wiki_okf.py, at: {datetime.date.today().isoformat()}}}")
    lines.append("---")
    return lines


def cmd_export(out_dir: Path, quiet: bool) -> int:
    concepts = []
    for f in sorted(WIKI.rglob("*.md")):
        text = f.read_text(encoding="utf-8")
        fm, _ = parse_frontmatter(text)
        if not fm.get("type"):
            continue  # navigation surfaces (README / index) are not concepts
        block = frontmatter_block(text)
        dest = out_dir / f.relative_to(WIKI)
        dest.parent.mkdir(parents=True, exist_ok=True)
        content = "\n".join(concept_frontmatter(fm, block)) + "\n" + strip_frontmatter(text)
        with open(dest, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(content)
        concepts.append((f, fm))
        if not quiet:
            print(f"OKF  {rel(f)} -> {dest.as_posix()}")

    if not concepts:
        print("no concept docs found (no .wiki doc carries a `type`)")
        return 1

    sections: dict[str, list[str]] = {}
    for f, fm in concepts:
        area = f.relative_to(WIKI).parts[0]
        label = fm.get("title") or fm.get("name") or f.stem
        desc = fm.get("description") or ""
        row = f"- [{label}]({f.relative_to(WIKI).as_posix()})" + (f" — {desc}" if desc else "")
        sections.setdefault(area, []).append(row)

    index = ["---", 'okf_version: "0.2"', "---", "", "# Wiki Bundle", ""]
    for area in sorted(sections):
        index.append(f"## {area}")
        index.extend(sections[area])
        index.append("")
    with open(out_dir / "index.md", "w", encoding="utf-8", newline="\n") as fh:
        fh.write("\n".join(index))
    print(f"OKF bundle written: {out_dir.as_posix()} ({len(concepts)} concepts)")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="OKF v0.2 export projection")
    sub = parser.add_subparsers(dest="mode", required=True)
    p = sub.add_parser("export")
    p.add_argument("--out", default="openwiki")
    p.add_argument("--quiet", action="store_true")
    args = parser.parse_args()
    if args.mode == "export":
        out = Path(args.out)
        if not out.is_absolute():
            out = ROOT / out
        return cmd_export(out, args.quiet)
    return 2


if __name__ == "__main__":
    sys.exit(main())
