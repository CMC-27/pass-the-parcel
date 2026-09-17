#!/usr/bin/env python3
"""Rule fan-out report — the surface-budget maintenance instrument.

Per registered rule (`.devops/rules/surface-budget.md`), counts the files that
independently restate it (raw `sites`) and subtracts the canonical home plus the
declared `allowed-surfaces:` that pass the pointer test (`unauthorised`).

REPORT-ONLY. Always exits 0 — a missing or malformed registry block prints a
loud one-line notice and exits 0, a rule with zero matches prints a row of
zeroes. An optional `agreement:` section lists tokens that must appear on every
declared surface; divergence is printed, never enforced. There is no --json, no
--fail-on and no exit-code surface at all. Never add this to
.github/workflows/validate.yml: a report that can block would be a second gate
over the gates.

Usage:
    python scripts/rule_fanout.py [--root <path>]

ponytail: counts by literal signature phrase, not by parsing prose — a rule
restated in words that avoid its signature is invisible. Upgrade path: register
a second signature per rule in the same block; no code change.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

REGISTRY_REL = ".devops/rules/surface-budget.md"
PREFIX_REL = ".opencode/plans/base-context.md"
BLOCK_START = "<!-- SURFACE-BUDGET:START -->"
BLOCK_END = "<!-- SURFACE-BUDGET:END -->"
ORCH_MARK = "<!-- ORCHESTRATOR-ONLY:START"
EMBED_START_RE = re.compile(r"<!--\s*EMBED:START.*?-->")
EMBED_END = "<!-- EMBED:END -->"
AGENTS_DIR = ".devops/agents/"

def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def parse_registry(text: str):
    """Parse the fenced registry block. Returns (walk_roots, rules) or (None, None)."""
    if text.count(BLOCK_START) != 1 or text.count(BLOCK_END) != 1:
        return None, None
    block = text.split(BLOCK_START, 1)[1].split(BLOCK_END, 1)[0]
    walk, rules = [], []
    mode = None
    for raw in block.splitlines():
        line = raw.strip()
        if not line:
            continue
        if line == "walk-roots:":
            mode = "walk"
            continue
        if line == "rules:":
            mode = "rules"
            continue
        if line == "agreement:":
            mode = "agreement"
            continue
        if not line.startswith("- "):
            continue
        item = line[2:].strip()
        if mode == "walk":
            walk.append(item)
        elif mode == "rules":
            cells = [c.strip() for c in item.split("::")]
            if len(cells) != 4:
                return None, None
            rule_id, signature, home, allowed = cells
            rules.append(
                {
                    "id": rule_id,
                    "signature": signature,
                    "home": home,
                    "allowed": [a.strip() for a in allowed.split("|") if a.strip()],
                }
            )
    if not walk or not rules:
        return None, None
    return walk, rules

def strip_frontmatter(text: str) -> str:
    if not text.startswith("---"):
        return text
    rest = text.split("\n", 1)[1] if "\n" in text else ""
    idx = rest.find("\n---")
    if idx == -1:
        return text
    body = rest[idx + 4 :]
    return body[1:] if body.startswith("\n") else body


def strip_derived(text: str, candidates: list[list[str]]) -> str:
    """Apply the same boundary rule check-parcel-prefix.ps1 enforces, then drop EMBED blocks."""
    lines = strip_frontmatter(text).split("\n")
    best = 0
    for candidate in candidates:
        n = 0
        for i, prefix_line in enumerate(candidate):
            if i < len(lines) and lines[i].rstrip("\r") == prefix_line.rstrip("\r"):
                n += 1
            else:
                break
        best = max(best, n)
    lines = lines[best:]
    return strip_embed_blocks("\n".join(lines))


def strip_embed_blocks(text: str) -> str:
    kept, skipping = [], False
    for line in text.split("\n"):
        if not skipping:
            match = EMBED_START_RE.search(line)
            if match:
                if EMBED_END in line[match.end() :]:
                    # A prose mention of the markers on one line, not a block.
                    kept.append(line)
                    continue
                skipping = True
                continue
        if skipping:
            if line.strip() == EMBED_END:
                skipping = False
            continue
        kept.append(line)
    return "\n".join(kept)

def walk_files(root: Path, roots: list[str]) -> list[Path]:
    found, seen = [], set()
    for entry in roots:
        path = root / entry
        candidates = sorted(path.rglob("*.md")) if path.is_dir() else ([path] if path.is_file() else [])
        for file in candidates:
            key = file.resolve().as_posix().lower()
            if key not in seen:
                seen.add(key)
                found.append(file)
    return found


def collect(root: Path, walk_roots: list[str]) -> tuple[dict, dict]:
    """Return (stripped_text_by_rel, raw_text_by_rel). The registry doc is self-excluded."""
    prefix = root / PREFIX_REL
    full_lines = read_text(prefix).split("\n") if prefix.is_file() else []
    shared_lines, orchestrator_lines = [], []
    for index, line in enumerate(full_lines):
        if line.startswith(ORCH_MARK):
            # The marker comment itself is not inlined into the agents: the orchestrator-only
            # block lands as its content, directly after the shared prefix.
            orchestrator_lines = shared_lines + full_lines[index + 1 :]
            break
        shared_lines.append(line)
    candidates = [orchestrator_lines, shared_lines] if orchestrator_lines else [shared_lines]

    stripped, raw = {}, {}
    for file in walk_files(root, walk_roots):
        rel = file.relative_to(root).as_posix()
        text = read_text(file)
        raw[rel] = text
        if rel == REGISTRY_REL:
            continue
        if ("/" + AGENTS_DIR) in ("/" + rel):
            text = strip_derived(text, candidates)
        else:
            text = strip_embed_blocks(text)
        stripped[rel] = text
    return stripped, raw

def evaluate(rule: dict, stripped: dict, raw: dict) -> dict:
    signature, home = rule["signature"], rule["home"]
    sites = sorted(rel for rel, text in stripped.items() if signature in text)
    allowed, unlinked = [], []
    for surface in rule["allowed"]:
        if surface not in stripped:
            unlinked.append((surface, "not-in-walk"))
        elif signature not in stripped[surface]:
            unlinked.append((surface, "no-signature"))
        elif home not in raw[surface]:
            unlinked.append((surface, "unlinked"))
        else:
            allowed.append(surface)
    unauthorised = [rel for rel in sites if rel != home and rel not in allowed]
    return {
        "rule": rule,
        "sites": sites,
        "allowed": allowed,
        "unofficial": unauthorised,
        "unlinked": unlinked,
    }


def parse_agreement(text: str):
    """Parse the optional fenced `agreement:` section. Returns rows, or None when malformed.

    Row shape: `<token> :: <file> | <file> | ...` — every declared file must contain the
    token. The section is optional; a registry without it returns [].
    """
    if text.count(BLOCK_START) != 1 or text.count(BLOCK_END) != 1:
        return []
    block = text.split(BLOCK_START, 1)[1].split(BLOCK_END, 1)[0]
    rows, mode = [], None
    for raw in block.splitlines():
        line = raw.strip()
        if not line:
            continue
        if line == "agreement:":
            mode = "agreement"
            continue
        if line in ("walk-roots:", "rules:"):
            mode = None
            continue
        if mode != "agreement" or not line.startswith("- "):
            continue
        cells = [c.strip() for c in line[2:].strip().split("::")]
        if len(cells) != 2:
            return None
        token, files = cells
        rows.append({"token": token, "files": [f.strip() for f in files.split("|") if f.strip()]})
    return rows


def evaluate_agreement(rows: list[dict], stripped: dict) -> list[dict]:
    """Per row: which declared surfaces carry the token, which do not, which are not in the walk."""
    results = []
    for row in rows:
        present, missing, absent = [], [], []
        for rel in row["files"]:
            if rel not in stripped:
                absent.append(rel)
            elif row["token"] in stripped[rel]:
                present.append(rel)
            else:
                missing.append(rel)
        results.append({"row": row, "present": present, "missing": missing, "absent": absent})
    return results


def report(results: list[dict]) -> None:
    print("Rule fan-out — surface budget (report-only; machinery corpus; see .devops/rules/surface-budget.md)")
    print()
    print(f"{'rule':<24} {'sites':>5} {'unauthorised':>12}  home")
    print("-" * 100)
    for res in results:
        rule = res["rule"]
        print(f"{rule['id']:<24} {len(res['sites']):>5} {len(res['unofficial']):>12}  {rule['home']}")
    print("-" * 100)
    for res in results:
        rule = res["rule"]
        print()
        print(f"[{rule['id']}] signature: {rule['signature']}")
        print(f"  sites ({len(res['sites'])}): {', '.join(res['sites']) if res['sites'] else '(none)'}")
        print(f"  allowed ({len(res['allowed'])}): {', '.join(res['allowed']) if res['allowed'] else '(none)'}")
        print(
            f"  unauthorised ({len(res['unofficial'])}): "
            f"{', '.join(res['unofficial']) if res['unofficial'] else '(none)'}"
        )
        if res["unlinked"]:
            detail = ", ".join(f"{path} [{why}]" for path, why in res["unlinked"])
            print(f"  unlinked-allowed-surface: {detail}")
    print()
    print(
        "Trend: read the two count columns against the recorded Axis 7 baseline in "
        ".devops/backlog/MATURITY.md — this run stores nothing."
    )


def report_agreement(results: list[dict]) -> None:
    if not results:
        return
    print()
    print(
        "Agreement — tokens that must appear on every declared surface "
        "(report-only; see .devops/rules/surface-budget.md)"
    )
    print()
    print(f"{'token':<24} {'status':<10} surfaces")
    print("-" * 100)
    for res in results:
        row = res["row"]
        status = "AGREE" if not res["missing"] and not res["absent"] else "DISAGREE"
        print(f"{row['token']:<24} {status:<10} {len(res['present'])}/{len(row['files'])}")
    print("-" * 100)
    for res in results:
        row = res["row"]
        if not res["missing"] and not res["absent"]:
            continue
        detail = []
        if res["missing"]:
            detail.append("missing-token: " + ", ".join(res["missing"]))
        if res["absent"]:
            detail.append("not-in-walk: " + ", ".join(res["absent"]))
        print(f"  [{row['token']}] " + "; ".join(detail))


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Rule fan-out report (report-only, always exits 0).")
    parser.add_argument("--root", default=None, help="repo root to scan (default: this script's repo)")
    args = parser.parse_args(argv)

    root = Path(args.root).resolve() if args.root else Path(__file__).resolve().parent.parent
    registry = root / REGISTRY_REL
    if not registry.is_file():
        print(f"rule_fanout: no registry block — {REGISTRY_REL} not found under {root}")
        return 0
    registry_text = read_text(registry)
    walk_roots, rules = parse_registry(registry_text)
    if walk_roots is None:
        print(f"rule_fanout: malformed registry block in {REGISTRY_REL} — need exactly one START/END pair, "
              "a walk-roots: list and 4-cell rules: rows")
        return 0
    agreement = parse_agreement(registry_text)
    if agreement is None:
        print(f"rule_fanout: malformed agreement section in {REGISTRY_REL} — "
              "each row must be `<token> :: <file> | <file> | ...`")
        agreement = []

    stripped, raw = collect(root, walk_roots)
    report([evaluate(rule, stripped, raw) for rule in rules])
    report_agreement(evaluate_agreement(agreement, stripped))
    return 0


if __name__ == "__main__":
    sys.exit(main())
