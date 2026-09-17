#!/usr/bin/env python3
"""
wiki_lint_core.py — the reader trio, path/link primitives and every constant of the
`.wiki/` linter.

This module is the **import surface**: `scripts/wiki_lint.py` re-exports the eleven names
its importers use (`ROOT`, `WIKI`, `frontmatter_block`, `is_path_token`, `list_field`,
`parse_frontmatter`, `rel`, `resolve_link`, `REQUIRED_FIELDS`, `category_indexes`,
`MANIFEST`) so a Grounded Claim bound to `scripts/wiki_lint.py#<symbol>` keeps resolving.
The check steps and the `--fix` writer live in `wiki_lint_checks.py`; neither module is
named `wiki_lint`, because a `scripts/wiki_lint/` package would shadow `wiki_lint.py` on
`sys.path` and break every importer (see scripts/lib/README.md for the sibling precedent).
"""


import re
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
