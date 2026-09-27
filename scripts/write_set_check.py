#!/usr/bin/env python3
"""write_set_check.py — the Write-Set Derivation Witness, executable.

The predicate is DEFINED in .devops/rules/plan-lifecycle.md section Claim Protocol
(step 2 — *the Write-Set Derivation Witness*). It answers ONE question, and it is
NOT the *Write-Set Overlap Predicate* (section Claim Protocol -> *Write-Set Overlap
Predicate*, embodied by scripts/sprint_eligible.py), which answers a different one:

    this script      -> does the plan's declared `touches` name every file it must write?
    sprint_eligible  -> do two plans collide on the files they touch?

The two must never be conflated; this script cites the canon and does not restate it
(surface-budget / managed-simplicity: one deterministic check per invariant).

Three rules — **prefix-cascade**, **embed-cascade**, **claim-source** — expand a declared
entry into a FORCED closure. They are DEFINED once in .devops/rules/plan-lifecycle.md
section Claim Protocol (step 2); this script embodies them and cites that home rather
than restating it (one home per rule).

Usage (both claim paths call it; run from the workspace root):
    python scripts/write_set_check.py --plan <plan path> [--root <dir>]

Output contract:
    exit 0 -> ONE JSON object on stdout, keys: schema, root, plan, declared,
              closure, missing, counts
    exit 1 -> a single "write_set_check: <cause>" line on stderr and NO JSON.
              A non-zero exit is a stop-the-line on BOTH claim paths (the manual
              path and @sprint-run's batch path).

ponytail: the check is a declaration-vs-derivation closure over three fixed rules,
never a prose reading — a plan's body is not mined for path mentions, because every
read-only evidence path would fire and the rule would be untrustworthy within a week.
Upgrade path with NO code change: register a rule's `signature:` in
.devops/rules/surface-budget.md and let rule_fanout.py name its mirror sites.
ponytail: there is NO exemption line and no --allow flag. A false positive is fixed
by declaring more, which only ever makes the plan more serial-cautious (Q3).
"""

import argparse
import json
import re
import sys
from pathlib import Path

SCRIPTS_DIR = Path(__file__).resolve().parent
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

try:
    from sprint_eligible import SKILL_EMBED_RE, entry_overlap, load_plan, normalize
    from wiki_claims import claims, source_path
    from wiki_lint import frontmatter_block
except ImportError as exc:  # fail closed: the host halts, it never re-implements
    sys.stderr.write(f"write_set_check: shared reader import failed: {exc}\n")
    raise SystemExit(1)

SCHEMA = "write-set/1"
AGENTS_DIR = ".devops/agents"
# The prefix sources whose declaration forces the PREFIX-LOCKED set (R1). Normalised
# once at import so the comparison is the canonical one, not a second dialect.
PREFIX_SOURCES = tuple(
    normalize(s) for s in (".opencode/plans/base-context.md", ".devops/templates/base-context.template.md")
)
# The PREFIX-LOCKED filename shape, case-insensitively (mirrors check-parcel-prefix.ps1's
# `-Filter 'parcel*.agent.md'` / `-Filter 'ptp-*.subagent.md'` discovery).
AGENT_NAME_RE = re.compile(r"^(parcel.*\.agent\.md|ptp-.*\.subagent\.md)$", re.IGNORECASE)


def fail(msg: str):
    """Halt loudly with ONE stderr line under THIS script's own prefix.

    The single-line idiom is sprint_eligible.fail()'s; the prefix is this script's own
    (`write_set_check: `, pinned by the plan), so the imported writer is not reused —
    it hardcodes `sprint_eligible: ` and would break this script's stderr contract.
    """
    sys.stderr.write(f"write_set_check: {msg}\n")
    raise SystemExit(1)


def repo_rel(path: Path, root: Path) -> str:
    try:
        return normalize(path.resolve().relative_to(root.resolve()).as_posix())
    except ValueError:
        return normalize(path.as_posix())


def prefix_locked_set(root: Path) -> list:
    """The PREFIX-LOCKED set, discovered from the tree (R1's target set).

    Mirrors check-parcel-prefix.ps1's own discovery (`parcel*.agent.md` +
    `ptp-*.subagent.md`) so the rule and that script's -Sync write set cannot drift
    apart. Never hardcoded: a new agent joins the set by existing.
    """
    folder = root / AGENTS_DIR
    if not folder.is_dir():
        return []
    return sorted(
        repo_rel(p, root) for p in folder.iterdir()
        if p.is_file() and AGENT_NAME_RE.match(p.name)
    )


def claim_source_index(root: Path) -> dict:
    """R3: normalised `claims:` source path -> the .wiki/** docs that declare it.

    The `claims:` shape is parsed by its single owner (wiki_claims.claims /
    source_path) and the frontmatter block by the shared reader (wiki_lint) — no
    second frontmatter or claims dialect.
    """
    index: dict = {}
    wiki = root / ".wiki"
    if not wiki.is_dir():
        return index
    for doc in sorted(wiki.rglob("*.md")):
        block = frontmatter_block(doc.read_text(encoding="utf-8-sig"))
        for claim in claims(block):
            src = normalize(source_path(claim))
            if src:
                index.setdefault(src, set()).add(repo_rel(doc, root))
    return {src: sorted(docs) for src, docs in index.items()}


def closure(touches: list, root: Path) -> list:
    """Fold R1/R2/R3 over the declared entries into a de-duplicated forced closure.

    Each forced item is {path, rule, from} so the halt line can name the rule and the
    declared entry that forced it. A declared directory or glob entry satisfies a
    required path through the imported entry_overlap — that test happens in main().
    """
    locked = prefix_locked_set(root)
    claim_index = claim_source_index(root)
    forced: dict = {}
    for entry in touches:
        if entry in PREFIX_SOURCES:
            for path in locked:
                forced.setdefault(path, ("prefix-cascade", entry))
        match = SKILL_EMBED_RE.match(entry)
        if match:
            agent = f"{AGENTS_DIR}/{match.group(1)}.subagent.md"
            if (root / agent).is_file():
                forced.setdefault(normalize(agent), ("embed-cascade", entry))
        for doc in claim_index.get(entry, ()):
            forced.setdefault(doc, ("claim-source", entry))
    return [
        {"path": path, "rule": rule, "from": src}
        for path, (rule, src) in sorted(forced.items())
    ]


def missing_line(missing: list) -> str:
    """ONE line, comma-joined — the single-stderr-line contract."""
    parts = [f"{m['path']} ({m['rule']}, from {m['from']})" for m in missing]
    return "undeclared forced writes: " + ", ".join(parts)


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description="Write-Set Derivation Witness (read-only).")
    parser.add_argument("--plan", required=True, help="plan file to check")
    parser.add_argument("--root", default=None, help="repository root to read")
    args = parser.parse_args(argv)
    root = Path(args.root).resolve() if args.root else SCRIPTS_DIR.parent
    if not root.is_dir():
        fail(f"--root is not a directory: {args.root}")
    plan = Path(args.plan)
    if not plan.is_absolute():
        plan = Path.cwd() / plan
    if not plan.is_file():
        fail(f"plan file not found: {args.plan}")

    # Pre-check the front-matter block so the halt keeps THIS script's prefix: the
    # imported load_plan would raise under sprint_eligible's own prefix, breaking the
    # one-`write_set_check:`-line contract.
    if frontmatter_block(plan.read_text(encoding="utf-8-sig")) is None:
        fail(f"plan file has no front-matter block: {repo_rel(plan, root)}")

    rec = load_plan(plan.resolve(), root, require_claim=False)
    # An absent `touches` field is load_plan's [] — an ERROR, never a silent empty pass.
    # This rule is this script's own: load_plan fails only on a missing front-matter
    # block, so it supplies no precedent to cite here.
    if not rec["touches"]:
        fail(f"plan declares no `touches` field: {rec['path']}")

    forced = closure(rec["touches"], root)
    missing = [
        item for item in forced
        if not any(entry_overlap(declared, item["path"]) for declared in rec["touches"])
    ]
    if missing:
        fail(missing_line(missing))

    payload = {
        "schema": SCHEMA,
        "root": str(root),
        "plan": rec["path"],
        "declared": rec["touches"],
        "closure": forced,
        "missing": [],
        "counts": {
            "declared": len(rec["touches"]),
            "closure": len(forced),
            "missing": 0,
        },
    }
    sys.stdout.write(json.dumps(payload, indent=2) + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
