#!/usr/bin/env python3
"""
wiki_lint_checks.py — the ten check steps and the `--fix` writer of the `.wiki/` linter.

`main()` lives in `scripts/wiki_lint.py` and calls `run_checks()` here. Step order, every
finding's text, the exit-code rule (`1` iff any hard failure survives) and the repair
semantics are unchanged from the pre-split single file.

State that used to be closed over by `main()` is now explicit: a `LintContext` carries
`findings`, `hard_msgs`, `hard_failures` and `bad_encoding`, and `hard(msg)` is a method.
The checks module holds **no module-level mutable state**.
"""

from __future__ import annotations

import os
import re
from pathlib import Path

from wiki_lint_core import (
    DEVOPS,
    FM_EXEMPT_PREFIXES,
    FM_LINK_FIELDS,
    HISTORICAL_PREFIXES,
    HUB,
    MANIFEST,
    REQUIRED_FIELDS,
    ROOT,
    VALID_FORMAT_VERSION,
    VALID_STATUS,
    WIKI,
    category_indexes,
    encoding_problem,
    extract_links,
    frontmatter_block,
    is_fm_exempt_name,
    is_path_token,
    list_field,
    parse_frontmatter,
    path_key,
    rel,
    resolve_link,
)


class LintContext:
    """The lint run's explicit state: what used to be main()'s closure variables."""

    def __init__(self) -> None:
        self.findings: list[str] = []
        self.hard_msgs: list[str] = []
        self.hard_failures = 0
        self.bad_encoding: set[str] = set()
        # Per-run I/O caches: the wiki corpus is enumerated once and every file is
        # read at most once, however many of the checks inspect it.
        self._wiki_files: list[Path] | None = None
        self._text: dict[Path, str] = {}
        self._raw: dict[Path, bytes] = {}

    def hard(self, msg: str) -> None:
        self.hard_failures += 1
        self.hard_msgs.append(msg)
        self.findings.append(f"HARD  {msg}")

    def key(self, path: Path) -> str:
        """A syscall-free identity for a path (see `wiki_lint_core.path_key`)."""
        return path_key(path)

    def wiki_files(self) -> list[Path]:
        """Every `.wiki/**/*.md`, enumerated once per run."""
        if self._wiki_files is None:
            self._wiki_files = sorted(WIKI.rglob("*.md"))
        return self._wiki_files

    def text(self, path: Path) -> str:
        cached = self._text.get(path)
        if cached is None:
            cached = path.read_text(encoding="utf-8")
            self._text[path] = cached
        return cached

    def raw(self, path: Path) -> bytes:
        cached = self._raw.get(path)
        if cached is None:
            cached = path.read_bytes()
            self._raw[path] = cached
        return cached


def _md_files_pruned(base: Path, skip_dirs: tuple[str, ...] = ()) -> list[Path]:
    """`base.rglob("*.md")`, sorted, without descending into `skip_dirs`.

    Pruning matters because `.devops/archive`, `.devops/logs` and `.devops/plans`
    grow without bound in a long-lived satellite and every file under them is
    skipped anyway — the walk should not pay to enumerate them.
    """
    skip = {os.path.normcase(os.path.join(str(base), d)) for d in skip_dirs}
    out: list[Path] = []
    for dirpath, dirnames, filenames in os.walk(base):
        dirnames[:] = [d for d in dirnames if os.path.normcase(os.path.join(dirpath, d)) not in skip]
        for name in filenames:
            if name.endswith(".md"):
                out.append(Path(dirpath) / name)
    return sorted(out)


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


def fix_unindexed(index_path: Path, doc_path: Path) -> str | None:
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

def check_encoding(ctx: LintContext) -> None:
    # 0. Encoding guard: flag BOMs and non-UTF-8 files before any parsing.
    #    This byte check is the only one that inspects raw bytes, not parsed text.
    for f in ctx.wiki_files():
        enc = encoding_problem(ctx.raw(f))
        if enc:
            ctx.bad_encoding.add(ctx.key(f))
            ctx.hard(f"{rel(f)}: {enc}")


def check_structure_anchors(ctx: LintContext) -> None:
    # 1. Structure manifest anchors exist.
    if ctx.key(MANIFEST) in ctx.bad_encoding:
        anchors = []
    else:
        manifest_text = MANIFEST.read_text(encoding="utf-8")
        anchors = re.findall(r"\| `([^`]+)` \|", manifest_text)
    for anchor in anchors:
        p = ROOT / anchor
        if not p.exists():
            ctx.hard(f"structure.md: missing anchor `{anchor}`")


def check_wiki_links_and_frontmatter(ctx: LintContext) -> None:
    # 2. Walk wiki content: body links + frontmatter fields.
    for f in ctx.wiki_files():
        if ctx.key(f) in ctx.bad_encoding:
            continue
        text = ctx.text(f)
        fm, body = parse_frontmatter(text)

        # Frontmatter required fields.
        if not str(f).startswith(FM_EXEMPT_PREFIXES) and not is_fm_exempt_name(f.name):
            for field in REQUIRED_FIELDS:
                if field not in fm:
                    ctx.hard(f"{rel(f)}: missing frontmatter field `{field}`")
                    break
            if "status" in fm and fm["status"] not in VALID_STATUS:
                ctx.hard(f"{rel(f)}: invalid status `{fm['status']}`")
            if "format-version" in fm and fm["format-version"] not in VALID_FORMAT_VERSION:
                ctx.hard(f"{rel(f)}: unknown format-version `{fm['format-version']}`")

        # Links resolve.
        for link in extract_links(body):
            if link.startswith(("http://", "https://", "mailto:", "#", "file://")):
                continue
            if resolve_link(link, f) is None:
                ctx.hard(f"{rel(f)}: broken link `{link}`")


def check_frontmatter_link_targets(ctx: LintContext) -> None:
    # 3. Frontmatter link targets resolve (`.wiki/**` + `.devops/**`).
    #    Historical trees are pruned during the walk, not merely skipped per file.
    for base, skip in ((WIKI, ()), (DEVOPS, ("archive", "logs", "plans"))):
        for f in _md_files_pruned(base, skip):
            r = rel(f)
            if r.startswith(HISTORICAL_PREFIXES):
                continue
            if ctx.key(f) in ctx.bad_encoding:
                continue
            block = frontmatter_block(ctx.text(f))
            if block is None:
                continue
            for key in FM_LINK_FIELDS:
                for token in list_field(block, key):
                    if is_path_token(token) and resolve_link(token, f) is None:
                        ctx.hard(f"{r}: broken frontmatter link `{token}`")


def check_grounded_claims(ctx: LintContext) -> None:
    # 3b. Grounded claims structure. The parser is owned by wiki_claims.py —
    #     import it lazily so the module-level wiki_claims -> wiki_lint import
    #     never forms a cycle.
    from wiki_claims import claims as parse_claims  # noqa: PLC0415
    for f in ctx.wiki_files():
        if ctx.key(f) in ctx.bad_encoding:
            continue
        block = frontmatter_block(ctx.text(f))
        for claim in parse_claims(block):
            cid = claim.get("id", "<no-id>")
            absent = [k for k in ("id", "source", "hash") if k not in claim]
            if absent:
                ctx.hard(f"{rel(f)}: claim `{cid}` missing key(s): {', '.join(absent)}")
                continue
            src = claim["source"].split("#", 1)[0].strip()
            if src and not (ROOT / src).exists():
                ctx.hard(f"{rel(f)}: claim `{cid}` source not found `{src}`")


def check_rules_index(ctx: LintContext) -> None:
    # 3c. Rules-index completeness: every top-level `.wiki/rules/*.md` must be
    #     catalogued in `.wiki/rules/README.md` (the `language/` subtree carries
    #     its own README and is out of scope). Closes the drift class where a
    #     rule file ships unlisted and the linter cannot otherwise see it.
    rules_dir = WIKI / "rules"
    rules_readme = rules_dir / "README.md"
    if rules_readme.exists() and ctx.key(rules_readme) not in ctx.bad_encoding:
        _, readme_body = parse_frontmatter(ctx.text(rules_readme))
        catalogued: set[str] = set()
        for link in extract_links(readme_body):
            t = resolve_link(link, rules_readme)
            if t:
                catalogued.add(ctx.key(t))
        for rule_file in sorted(rules_dir.glob("*.md")):
            if rule_file.name == "README.md":
                continue
            if ctx.key(rule_file) not in catalogued:
                ctx.hard(f"{rel(rules_readme)}: [UNCATALOGUED] {rel(rule_file)}")


def check_hub_spokes(ctx: LintContext) -> set[str]:
    # 4. Hub -> spoke links (every category index that exists).
    hub_targets: set[str] = set()
    if HUB.exists():
        hub_text = ctx.text(HUB)
        _, hub_body = parse_frontmatter(hub_text)
        for link in extract_links(hub_body):
            t = resolve_link(link, HUB)
            if t:
                hub_targets.add(ctx.key(t))
        for idx in category_indexes():
            if ctx.key(idx) not in hub_targets:
                ctx.hard(f"{rel(HUB)}: [HUB MISSING SPOKE] {rel(idx)}")
    return hub_targets


def check_index_catalogue(ctx: LintContext) -> tuple[list[tuple[Path, Path]], list[tuple[Path, str]]]:
    # 5. Index cataloguing: [MISSING] rows and [UNINDEXED] siblings.
    unindexed: list[tuple[Path, Path]] = []
    missing: list[tuple[Path, str]] = []
    for idx in category_indexes():
        idx_text = ctx.text(idx)
        _, idx_body = parse_frontmatter(idx_text)
        listed: set[str] = set()
        for link in extract_links(idx_body):
            t = resolve_link(link, idx)
            if t is None:
                ctx.findings.append(f"WARN  {rel(idx)}: [MISSING] {link}")
                missing.append((idx, link))
            else:
                listed.add(ctx.key(t))
        for sib in sorted(idx.parent.glob("*.md")):
            if sib == idx or is_fm_exempt_name(sib.name):
                continue
            if ctx.key(sib) not in listed:
                ctx.findings.append(f"WARN  {rel(idx)}: [UNINDEXED] {rel(sib)}")
                unindexed.append((idx, sib))
    return unindexed, missing


def check_reachability(ctx: LintContext, hub_targets: set[str]) -> None:
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
                if ctx.key(p) in ctx.bad_encoding:
                    continue
                _, body = parse_frontmatter(ctx.text(p))
                for link in extract_links(body):
                    t = resolve_link(link, p)
                    if t and ctx.key(t) not in reachable:
                        reachable.add(ctx.key(t))
                        nxt.add(ctx.key(t))
            frontier = nxt
        for f in ctx.wiki_files():
            if is_fm_exempt_name(f.name) or f.name == "knowledge-capture.md":
                continue
            r = f.relative_to(WIKI).as_posix()
            if r.startswith(("ref/", "templates/", "examples/", "rules/")):
                continue
            if ctx.key(f) not in reachable:
                ctx.findings.append(f"WARN  {rel(f)}: unreachable from hub")


def check_orphans(ctx: LintContext) -> None:
    # 7. Orphans (report only).
    linked_targets = set()
    for f in ctx.wiki_files():
        if ctx.key(f) in ctx.bad_encoding:
            continue
        text = ctx.text(f)
        for link in extract_links(text):
            t = resolve_link(link, f)
            if t:
                linked_targets.add(ctx.key(t))
    for f in ctx.wiki_files():
        if is_fm_exempt_name(f.name) or f.name == "knowledge-capture.md":
            continue
        rel_wiki = f.relative_to(WIKI).as_posix()
        if rel_wiki.startswith(("ref/", "templates/", "examples/")):
            continue
        if ctx.key(f) not in linked_targets:
            ctx.findings.append(f"INFO  {rel(f)}: orphan (no inbound links)")


def apply_fixes(ctx: LintContext, unindexed, missing, enabled: bool) -> int:
    # 8. Deterministic repairs — only when the scan is clean apart from the [MISSING]
    #    rows themselves. A [MISSING] row also trips the HARD body-link check (an
    #    accepted, documented overlap: the row's link does not resolve AND the index
    #    does not catalogue a real file). Those specific hard findings must not block
    #    the repair that removes them; any other hard failure does.
    applied = 0
    missing_links = {link for _, link in missing}
    blockers = [
        m for m in ctx.hard_msgs
        if not (f"broken link `" in m and any(f"`{lnk}`" in m for lnk in missing_links))
    ]
    if enabled and not blockers:
        for idx, doc in unindexed:
            line = fix_unindexed(idx, doc)
            if line:
                ctx.findings.append(line)
                applied += 1
        for idx, link in missing:
            line = _fix_missing(idx, link)
            if line:
                ctx.findings.append(line)
                applied += 1
                # Drop the hard body-link finding the repaired (now deleted) row produced.
                pat = f"broken link `{link}`"
                kept = []
                for fnd in ctx.findings:
                    if fnd.startswith("HARD") and pat in fnd:
                        ctx.hard_failures -= 1
                        continue
                    kept.append(fnd)
                ctx.findings = kept
    return applied


def run_checks(fix: bool, quiet: bool) -> int:
    """Run the ten checks in order, then the repairs and the report. Returns the exit code."""
    ctx = LintContext()

    check_encoding(ctx)
    check_structure_anchors(ctx)
    check_wiki_links_and_frontmatter(ctx)
    check_frontmatter_link_targets(ctx)
    check_grounded_claims(ctx)
    check_rules_index(ctx)
    hub_targets = check_hub_spokes(ctx)
    unindexed, missing = check_index_catalogue(ctx)
    check_reachability(ctx, hub_targets)
    check_orphans(ctx)
    applied = apply_fixes(ctx, unindexed, missing, fix)

    if not ctx.findings:
        if not quiet:
            print("OK: wiki healthy - 0 broken links, all anchors present, frontmatter valid.")
        return 0
    if quiet and ctx.hard_failures == 0:
        return 0
    for line in ctx.findings:
        print(line)
    print(f"---\n{len(ctx.findings)} findings, {ctx.hard_failures} hard failures, {applied} fixes applied.")
    return 1 if ctx.hard_failures else 0
