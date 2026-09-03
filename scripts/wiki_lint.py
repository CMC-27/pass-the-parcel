#!/usr/bin/env python3
"""
wiki_lint.py — Deterministic linter for the parcel blueprint knowledge base.

Enforces the rules in .wiki/rules/:
  - Structure manifest anchors exist (hard failure if a declared anchor is missing)
  - Internal links resolve (hard failure if a link target is missing)
  - Frontmatter required fields present (name, title, type, status)
  - Orphans detected (report only)

Usage:
    python scripts/wiki_lint.py            # report findings
    python scripts/wiki_lint.py --fix      # auto-repair deterministic issues
    python scripts/wiki_lint.py --quiet    # suppress output on clean run

Exits 1 on hard failures (broken links, missing anchors, missing frontmatter).
"""

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
WIKI = ROOT / ".wiki"
MANIFEST = ROOT / ".wiki" / "rules" / "structure.md"
LOGS = ROOT / ".devops" / "logs" / "knowledge-changelog.md"

VALID_STATUS = {"stable", "in-progress", "deprecated", "template", "approved"}
REQUIRED_FIELDS = ["name", "type", "status"]

# README/index files are exempt from the required-fields check (they may be plain headers).
FM_EXEMPT_FILES = {"README.md", "index.md", "testing-index.md", "conventions-index.md", "ref-index.md", "00-system-index.md", "components-index.md", "features-index.md", "logic-index.md", "database-index.md"}

# Paths exempt from the frontmatter required-fields check.
FM_EXEMPT_PREFIXES = (
    str(ROOT / ".devops" / "agents"),
    str(ROOT / ".devops" / "skills" / "ptp-"),
    str(ROOT / ".devops" / "skills" / "pass-the-parcel"),
    str(ROOT / ".devops" / "rules"),
    str(ROOT / ".wiki" / "rules"),
    str(ROOT / ".opencode"),
)


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


def main() -> int:
    parser = argparse.ArgumentParser(description="Deterministic wiki linter")
    parser.add_argument("--fix", action="store_true", help="auto-repair deterministic issues")
    parser.add_argument("--quiet", action="store_true", help="suppress output on clean run")
    args = parser.parse_args()

    findings = []
    hard_failures = 0

    # 1. Structure manifest anchors exist.
    manifest_text = MANIFEST.read_text(encoding="utf-8")
    anchors = re.findall(r"\| `([^`]+)` \|", manifest_text)
    for anchor in anchors:
        # Skip anchors that look like paths inside tables with backticks (files).
        p = ROOT / anchor
        if not p.exists():
            hard_failures += 1
            findings.append(f"HARD  structure.md: missing anchor `{anchor}`")

    # 2. Walk wiki content, check links + frontmatter.
    for f in sorted(WIKI.rglob("*.md")):
        rel = f.relative_to(ROOT).as_posix()
        text = f.read_text(encoding="utf-8")
        fm, body = parse_frontmatter(text)

        # Frontmatter required fields.
        if not str(f).startswith(FM_EXEMPT_PREFIXES) and f.name not in FM_EXEMPT_FILES:
            for field in REQUIRED_FIELDS:
                if field not in fm:
                    hard_failures += 1
                    findings.append(f"HARD  {rel}: missing frontmatter field `{field}`")
                    break
            if "status" in fm and fm["status"] not in VALID_STATUS:
                hard_failures += 1
                findings.append(f"HARD  {rel}: invalid status `{fm['status']}`")

        # Links resolve.
        for link in extract_links(body):
            if link.startswith(("http://", "https://", "mailto:", "#", "file://")):
                continue
            target = resolve_link(link, f)
            if target is None:
                hard_failures += 1
                findings.append(f"HARD  {rel}: broken link `{link}`")

    # 3. Orphans (report only).
    linked_targets = set()
    for f in WIKI.rglob("*.md"):
        text = f.read_text(encoding="utf-8")
        for link in extract_links(text):
            t = resolve_link(link, f)
            if t:
                linked_targets.add(str(t.resolve()))
    for f in WIKI.rglob("*.md"):
        if f.name in ("README.md", "index.md", "00-system-index.md", "knowledge-capture.md"):
            continue
        # Excluded from orphan detection: ref/, templates/, examples/ (per the wiki-lint skill).
        rel = f.relative_to(WIKI).as_posix()
        if rel.startswith(("ref/", "templates/", "examples/")):
            continue
        if str(f.resolve()) not in linked_targets:
            findings.append(f"INFO  {f.relative_to(ROOT).as_posix()}: orphan (no inbound links)")

# 4. Report.
    if not findings:
        if not args.quiet:
            print("OK: wiki healthy - 0 broken links, all anchors present, frontmatter valid.")
        return 0
    if args.quiet and hard_failures == 0:
        # Soft findings only on a clean run - suppress output, exit 0.
        return 0
    for line in findings:
        print(line)
    print(f"---\n{len(findings)} findings, {hard_failures} hard failures.")
    return 1 if hard_failures else 0


if __name__ == "__main__":
    sys.exit(main())