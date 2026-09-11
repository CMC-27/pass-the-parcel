#!/usr/bin/env python3
"""wiki_okf.py — bridge the wiki and an Open Knowledge Format (OKF) v0.2 bundle.

The local frontmatter schema (.wiki/rules/frontmatter.md) stays authoritative.
Two directions are supported:

  export  Project the wiki into an OKF v0.2 bundle. Copies each concept doc's
          body unchanged and rewrites the frontmatter to OKF v0.2 fields. The
          bundle root carries `okf_version: "0.2"`.
  import  Ingest an OKF v0.2 bundle into the local wiki. Translates each concept
          doc's frontmatter to the `format-version: 1` schema as an
          `status: in-progress` draft (a generated doc is a claim, not truth),
          records provenance (`okf_version`), and registers the doc in its area
          spoke index. Existing target paths are skipped, never overwritten.

Usage:
    python scripts/wiki_okf.py export [--out openwiki] [--quiet]
    python scripts/wiki_okf.py import [--from openwiki] [--out .wiki] [--quiet]

Exit codes: 0 ok, 1 no concepts found / bundle missing.
"""

import argparse
import datetime
import re
import subprocess
import sys
from pathlib import Path

from wiki_lint import (
    ROOT,
    WIKI,
    fix_unindexed,
    frontmatter_block,
    is_fm_exempt_name,
    list_field,
    parse_frontmatter,
    rel,
)

FM_RE = re.compile(r"^---\s*\n.*?\n---\s*\n", re.DOTALL)


def strip_frontmatter(text: str) -> str:
    m = FM_RE.match(text)
    return text[m.end():] if m else text


def yaml_scalar(value: str) -> str:
    """Emit a double-quoted YAML scalar with backslash escaping.

    OKF bundles are read by real YAML parsers, where a plain scalar may not
    contain `: `, `#`, or leading/trailing space (`title: A: B` is invalid).
    Quoting unconditionally is simpler than reasoning about when it is needed
    and is always valid YAML.
    """
    s = str(value).replace("\\", "\\\\").replace('"', '\\"')
    return f'"{s}"'


def concept_frontmatter(fm: dict, block: str | None) -> list[str]:
    """OKF v0.2 concept frontmatter: `type` is the only required key."""
    lines = ["---", f"type: {fm.get('type') or 'concept'}"]
    title = fm.get("title") or fm.get("name")
    if title:
        lines.append(f"title: {yaml_scalar(title)}")
    if fm.get("description"):
        lines.append(f"description: {yaml_scalar(fm['description'])}")
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
        # Navigation surfaces (README / *-index) are not concepts. Export uses the
        # same predicate as import so the two directions agree file-for-file.
        if not fm.get("type") or is_fm_exempt_name(f.name):
            continue
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


def local_frontmatter(
    fm: dict, stem: str, block: str | None, okf_version: str
) -> list[str]:
    """Translate OKF v0.2 concept frontmatter to the local `format-version: 1` schema.

    A generated doc is a draft, never truth: `status` is forced to `in-progress`.
    `okf_version` is recorded as provenance, not as a local field.
    """
    lines = ["---", f"name: {yaml_scalar(stem)}", f"type: {fm.get('type') or 'concept'}"]
    lines.append("status: in-progress")
    lines.append("format-version: 1")
    title = fm.get("title") or fm.get("name")
    if title:
        lines.append(f"title: {yaml_scalar(title)}")
    if fm.get("description"):
        lines.append(f"description: {yaml_scalar(fm['description'])}")
    tags = list_field(block, "tags")
    if tags:
        lines.append("tags: [" + ", ".join(tags) + "]")
    lines.append(f'okf_version: "{okf_version}"')
    lines.append("---")
    return lines


def cmd_import(bundle_dir: Path, out_dir: Path, quiet: bool) -> int:
    if not bundle_dir.is_dir():
        print(
            f"OKF bundle not found: {bundle_dir.as_posix()} "
            "(run: python scripts/wiki_okf.py export)"
        )
        return 1

    okf_version = "unknown"
    index_md = bundle_dir / "index.md"
    if index_md.is_file():
        index_fm, _ = parse_frontmatter(index_md.read_text(encoding="utf-8"))
        okf_version = index_fm.get("okf_version") or "unknown"
    if okf_version != "0.2":
        print(f"warn: bundle okf_version is `{okf_version}`, expected `0.2` — importing anyway")

    areas = {p.name for p in WIKI.iterdir() if p.is_dir()}
    register = out_dir.resolve() == WIKI.resolve()
    written = skipped = indexed = 0
    for f in sorted(bundle_dir.rglob("*.md")):
        relp = f.relative_to(bundle_dir)
        if is_fm_exempt_name(relp.name):
            continue  # navigation surfaces (README / index / *-index) are not concepts
        text = f.read_text(encoding="utf-8")
        fm, body = parse_frontmatter(text)
        if not fm.get("type"):
            continue  # only type-bearing concepts are ingested
        block = frontmatter_block(text)
        dest = out_dir / relp
        if dest.exists():
            # ponytail: skip-on-collision. Overwriting would let a generated
            # bundle clobber authored prose; merging needs a diff model. Refuse.
            if not quiet:
                print(f"SKIP  {relp.as_posix()} (exists)")
            skipped += 1
            continue
        dest.parent.mkdir(parents=True, exist_ok=True)
        content = (
            "\n".join(local_frontmatter(fm, dest.stem, block, okf_version))
            + "\n"
            + body
        )
        with open(dest, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(content)
        written += 1
        if not quiet:
            print(f"INGEST {relp.as_posix()}")

        area = relp.parts[0] if len(relp.parts) > 1 else ""
        index_path = dest.parent / f"{dest.parent.name}-index.md"
        if register and area in areas and area != "core" and index_path.is_file():
            if fix_unindexed(index_path, dest):
                indexed += 1
                if not quiet:
                    print(f"INDEX  {index_path.as_posix()}")

    if not written:
        print(f"no new concepts imported ({skipped} skipped)")
        return 0

    # An import into the live wiki must not leave it lint-dirty. Core concepts are
    # not index-registered here (the hub owns them) and an area lacking a
    # `*-index.md` is silently unindexed — both surface as lint findings, so fail
    # loudly rather than leave a broken wiki behind.
    if register:
        proc = subprocess.run(
            [sys.executable, str(ROOT / "scripts" / "wiki_lint.py"), "--quiet"],
            cwd=str(ROOT),
            capture_output=True,
            text=True,
        )
        if proc.returncode != 0:
            print(proc.stdout.strip() or proc.stderr.strip())
            print(
                "OKF import produced a wiki that fails lint — fix the bundle paths "
                "or add the missing index registration before committing."
            )
            return 1

    print(
        f"OKF import complete: {written} ingested, {indexed} indexed, {skipped} skipped "
        "(status: in-progress — verify via @wiki-bootstrap before promoting)"
    )
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="OKF v0.2 export/import bridge")
    sub = parser.add_subparsers(dest="mode", required=True)
    p_export = sub.add_parser("export")
    p_export.add_argument("--out", default="openwiki")
    p_export.add_argument("--quiet", action="store_true")
    p_import = sub.add_parser("import")
    p_import.add_argument("--from", dest="source", default="openwiki")
    p_import.add_argument("--out", default=".wiki")
    p_import.add_argument("--quiet", action="store_true")
    args = parser.parse_args()

    if args.mode == "export":
        out = Path(args.out)
        if not out.is_absolute():
            out = ROOT / out
        return cmd_export(out, args.quiet)
    if args.mode == "import":
        src = Path(args.source)
        if not src.is_absolute():
            src = ROOT / src
        out = Path(args.out)
        if not out.is_absolute():
            out = ROOT / out
        return cmd_import(src, out, args.quiet)
    return 2


if __name__ == "__main__":
    sys.exit(main())
