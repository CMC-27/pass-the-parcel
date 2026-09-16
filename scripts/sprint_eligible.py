#!/usr/bin/env python3
"""sprint_eligible.py - the @sprint-run batch eligibility predicate, executable.

The predicate is DEFINED in .devops/rules/plan-lifecycle.md:
  - section Claim Front-Matter   -> when a depends_on code counts as satisfied
  - section Claim Protocol       -> the *Write-Set Overlap Predicate* + the fixpoint
and restated as the host's contract in .devops/skills/sprint-run/SKILL.md section 2.
This script is its executable embodiment; it cites those sections and does not
fork a second written dialect.

Usage (the host's command, run from the workspace root):
    python scripts/sprint_eligible.py
Overrides:
    --root <dir>        repository root to read (fixture tests use a temp tree)
    --sprint-dir <dir>  an explicit sprint folder, bypassing the SPRINTS.md lookup,
                        so @sprint-plan's commit-time preflight can call this before
                        a sprint is ACTIVE

Output contract:
    exit 0 -> ONE JSON object on stdout, keys: schema, root, sprint, sprint_dir,
              queue, eligible, claim_order, parallel_groups, skipped, in_flight,
              orphans, already_phased, complexity, counts
    exit 1 -> a single "sprint_eligible: <cause>" line on stderr and NO JSON.
              A non-zero exit is a stop-the-line for @sprint-run: never fall back to
              reasoning the predicate out from prose.

"complexity" is ADVISORY data (like "parallel_groups"), not part of the eligibility
predicate: one entry per queued plan, {"triage", "signals", "multi_worthy", "blocks"}.
The MULTI-worthy flag is the UNION of a declared triage recommendation (the plan's
claim front-matter `triage: MULTI|SINGLE`, written by @sprint-plan at commit time) and
a mechanical backstop on the plan's own declared `touches` breadth. The signals are
DEFINED in .devops/skills/pass-the-parcel/SKILL.md section Agent Topology ->
*Complexity Triage* ("blast radius: <= 3 files, one domain" is low); this script cites
that definition and does not fork a second written dialect.

Read-only by construction: this script never writes, claims, archives or flips a gate.

ponytail: ceilings (deliberate, documented - see plan-lifecycle.md section Claim Protocol)
  - a mid-path wildcard ("src/*/db") is NOT detected; upgrade path = segment-wise
    glob intersection;
  - "parallel_groups" is advisory data only - the fixpoint "claim_order" stays the
    authoritative serial order (T1-E3.11 owns any scheduler);
  - queue order is the ascending plan code, not the physical order of the sprint.md
    table;
  - "complexity" audits the DECLARED write set, not the tree: a plan with 3 declared
    touches that edits 20 files is not detected; and the declared half is a judgement
    this script deliberately does not re-derive (T1-E3.10 owns the flag, not a scorer).
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
    from wiki_lint import frontmatter_block, list_field, parse_frontmatter
except ImportError as exc:  # fail closed: the host halts, it never re-implements
    sys.stderr.write(f"sprint_eligible: shared reader import failed: {exc}\n")
    raise SystemExit(1)

SCHEMA = "sprint-eligible/1"
TEMPLATE = "template-plan.md"
QUEUED = "QUEUED"
CLAIMED = "CLAIMED"
DONE = "GATE_D_USER_APPROVAL"
PHASE_9 = "PHASE_9"
TRIAGE_MULTI = "MULTI"
BLAST_RADIUS_MAX = 3
BLAST_RADIUS = "blast-radius"
CODE_RE = re.compile(r"^([a-z]+\d*-e\d+\.\d+)", re.IGNORECASE)
STATUS_RE = re.compile(r"^\|\s*\*\*Status\*\*\s*\|\s*`([^`]+)`", re.MULTILINE)
ACTIVE_MARK = "\U0001F7E2 ACTIVE"
LINK_RE = re.compile(r"\]\(([^)]+)\)")


def fail(msg: str):
    """Halt loudly. The host's contract is: non-zero exit means STOP, not re-derive."""
    sys.stderr.write(f"sprint_eligible: {msg}\n")
    raise SystemExit(1)


def rel(path: Path, root: Path) -> str:
    try:
        return path.resolve().relative_to(root.resolve()).as_posix()
    except ValueError:
        return path.as_posix()


def normalize(entry: str) -> str:
    """Normalize a touches entry (canonical rule: forward slashes, lowercase,
    strip a trailing /** or /*)."""
    e = entry.strip().strip("\"'").replace("\\", "/").lower()
    while e.endswith("/"):
        e = e[:-1]
    if e.endswith("/**"):
        e = e[:-3]
    elif e.endswith("/*"):
        e = e[:-2]
    while e.startswith("./"):
        e = e[2:]
    return e


def entry_overlap(a: str, b: str) -> bool:
    """A overlaps B when either stem is a path-prefix of, or equal to, the other.

    The prefix must fall on a path boundary, so "src/a" does not swallow "src/ab".
    """
    if not a or not b:
        return False
    if a == b:
        return True
    return a.startswith(b + "/") or b.startswith(a + "/")


def plan_overlap(mine: list, theirs: list):
    """Return the other plan's first overlapping entry, or None."""
    for be in theirs:
        for ae in mine:
            if entry_overlap(ae, be):
                return be
    return None


def blocks_for(code: str, queue: list) -> list:
    """Queued codes whose depends_on transitively reaches `code` (sorted, self excluded).

    Used by the batch host's DEFERRED-MANUAL report: the plans a deferral strands.
    BFS over the reverse depends_on edges, restricted to the queued set.
    """
    dependents = {}
    for rec in queue:
        for dep in rec["depends_on"]:
            dependents.setdefault(dep, []).append(rec["code"])
    stranded, frontier = set(), [code]
    while frontier:
        for child in dependents.get(frontier.pop(), []):
            if child != code and child not in stranded:
                stranded.add(child)
                frontier.append(child)
    return sorted(stranded)


def complexity_for(rec: dict, queue: list) -> dict:
    """The MULTI-worthy flag: declared triage UNION the mechanical backstop.

    The signal set is DEFINED in .devops/skills/pass-the-parcel/SKILL.md section
    Agent Topology -> *Complexity Triage*; only the deterministic, cheaply checkable
    one ("blast radius": more than BLAST_RADIUS_MAX declared touches is not "<= 3
    files") is computed here, as the canonical definition of MULTI-worthy stays there.
    An unrecognised `triage` value never errors - it simply does not fire the declared
    signal, so the backstop still applies (fail open, never halt a batch on a typo).
    """
    signals = [BLAST_RADIUS] if len(rec["touches"]) > BLAST_RADIUS_MAX else []
    multi_worthy = rec["triage"] == TRIAGE_MULTI or bool(signals)
    return {
        "triage": rec["triage"] or None,
        "signals": signals,
        "multi_worthy": multi_worthy,
        "blocks": blocks_for(rec["code"], queue) if multi_worthy else [],
    }


def status_of(body: str) -> str:
    m = STATUS_RE.search(body)
    return m.group(1).strip() if m else ""


def load_plan(path: Path, root: Path, require_claim: bool) -> dict:
    """Read one plan file. Unparsable state is an ERROR, never a silent skip."""
    text = path.read_text(encoding="utf-8-sig")
    block = frontmatter_block(text)
    if block is None:
        fail(f"plan file has no front-matter block: {rel(path, root)}")
    fm, body = parse_frontmatter(text)
    code = (fm.get("code") or "").strip()
    if not code:
        if require_claim:
            fail(f"plan file has no code field: {rel(path, root)}")
        m = CODE_RE.match(path.stem)
        code = m.group(1).upper() if m else ""
    claim = (fm.get("claim_status") or "").strip()
    if require_claim and not claim:
        fail(f"plan file has no claim_status field: {rel(path, root)}")
    return {
        "code": code.upper(),
        "path": rel(path, root),
        "claim_status": claim,
        "status": status_of(body),
        "sprint": (fm.get("sprint") or "").strip(),
        "triage": (fm.get("triage") or "").strip().upper(),
        "touches": [normalize(e) for e in list_field(block, "touches") if e.strip()],
        "depends_on": [c.strip().upper() for c in list_field(block, "depends_on") if c.strip()],
    }


def plan_files(folder: Path, root: Path) -> list:
    """The queue/claimed set: *-plan.md in code order, template excluded."""
    if not folder.is_dir():
        return []
    found = [p for p in folder.glob("*-plan.md") if p.is_file() and p.name != TEMPLATE]
    return [load_plan(p, root, require_claim=True) for p in sorted(found, key=lambda p: p.name.lower())]


def archive_codes(root: Path) -> set:
    """Every archived plan code: front-matter 'code', else the filename stem."""
    codes = set()
    folder = root / ".devops" / "archive"
    if not folder.is_dir():
        return codes
    for path in sorted(folder.rglob("*-plan.md")):
        fm, _ = parse_frontmatter(path.read_text(encoding="utf-8-sig"))
        code = (fm.get("code") or "").strip()
        if not code:
            m = CODE_RE.match(path.stem)
            code = m.group(1) if m else ""
        if code:
            codes.add(code.upper())
    return codes


def resolve_sprint(root: Path, sprint_dir_arg):
    """Return (slug, folder). Explicit --sprint-dir wins; otherwise the ACTIVE row."""
    if sprint_dir_arg:
        folder = Path(sprint_dir_arg)
        if not folder.is_absolute():
            folder = Path.cwd() / folder
        if not folder.is_dir():
            fail(f"--sprint-dir is not a directory: {sprint_dir_arg}")
        return folder.resolve().name, folder.resolve()
    index = root / ".devops" / "backlog" / "SPRINTS.md"
    if not index.is_file():
        fail(f"SPRINTS index not found: {rel(index, root)}")
    rows = [ln for ln in index.read_text(encoding="utf-8-sig").splitlines() if ACTIVE_MARK in ln]
    if not rows:
        fail(f"no ACTIVE sprint row in {rel(index, root)}")
    if len(rows) > 1:
        fail(f"{len(rows)} ACTIVE sprint rows in {rel(index, root)}")
    m = LINK_RE.search(rows[0])
    if not m:
        fail(f"ACTIVE sprint row has no markdown link: {rel(index, root)}")
    target = (index.parent / m.group(1)).resolve()
    if target.suffix == ".md":
        target = target.parent
    if not target.is_dir():
        fail(f"ACTIVE sprint link does not resolve to a folder: {m.group(1)}")
    return target.name, target


def compute(root: Path, slug: str, folder: Path) -> dict:
    queue = plan_files(folder, root)
    claimed = plan_files(root / ".devops" / "plans", root)
    archived = archive_codes(root)
    satisfied = lambda code, blockers: code in archived or any(  # noqa: E731
        b["code"] == code and b["claim_status"] == DONE for b in blockers
    )

    def reasons(rec: dict, blockers: list) -> list:
        out = [f"unmet depends_on: {dep}" for dep in rec["depends_on"]
               if not satisfied(dep, blockers)]
        for other in blockers:
            entry = plan_overlap(rec["touches"], other["touches"])
            if entry is not None:
                out.append(f"touches overlap: {other['code']} via {entry}")
        return out

    blockers = sorted(claimed, key=lambda r: r["code"])
    eligible = [r["code"] for r in queue if r["status"] != PHASE_9 and not reasons(r, blockers)]

    order = []
    virtual = list(blockers)
    remaining = list(queue)
    while True:
        pick = None
        for rec in remaining:
            if rec["status"] == PHASE_9:
                continue
            if not reasons(rec, virtual):
                pick = rec
                break
        if pick is None:
            break
        order.append(pick["code"])
        virtual.append({**pick, "claim_status": DONE, "status": PHASE_9})
        remaining.remove(pick)

    skipped = []
    for rec in queue:
        if rec["code"] in order:
            continue
        if rec["status"] == PHASE_9:
            rs = ["already PHASE_9"]
        else:
            rs = reasons(rec, virtual)
        skipped.append({"code": rec["code"], "reasons": rs})

    in_flight = [r["code"] for r in claimed if r["claim_status"] == CLAIMED]
    orphans = [
        r["code"]
        for r in claimed
        if r["claim_status"] == CLAIMED and r["status"] != PHASE_9 and r["sprint"] == slug
    ]
    already_phased = sorted({r["code"] for r in queue if r["status"] == PHASE_9}
                            | {r["code"] for r in claimed if r["status"] == PHASE_9})

    by_code = {r["code"]: r for r in queue}
    group_of = {}
    groups = []
    for code in order:
        rec = by_code[code]
        deps = [d for d in rec["depends_on"] if d in group_of]
        for i, group in enumerate(groups):
            if any(plan_overlap(rec["touches"], by_code[m]["touches"]) is not None for m in group):
                continue
            if any(group_of[d] >= i for d in deps):
                continue
            group.append(code)
            group_of[code] = i
            break
        else:
            groups.append([code])
            group_of[code] = len(groups) - 1

    return {
        "schema": SCHEMA,
        "root": str(root),
        "sprint": slug,
        "sprint_dir": rel(folder, root),
        "queue": [r["code"] for r in queue],
        "eligible": eligible,
        "claim_order": order,
        "parallel_groups": groups,
        "skipped": skipped,
        "in_flight": in_flight,
        "orphans": orphans,
        "already_phased": already_phased,
        "complexity": {r["code"]: complexity_for(r, queue) for r in queue},
        "counts": {
            "queue": len(queue),
            "eligible": len(eligible),
            "claim_order": len(order),
            "skipped": len(skipped),
            "in_flight": len(in_flight),
            "multi_worthy": sum(1 for r in queue if complexity_for(r, queue)["multi_worthy"]),
        },
    }


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description="Batch eligibility predicate (read-only).")
    parser.add_argument("--root", default=None, help="repository root to read")
    parser.add_argument("--sprint-dir", default=None, help="explicit sprint folder")
    args = parser.parse_args(argv)
    root = Path(args.root).resolve() if args.root else SCRIPTS_DIR.parent
    if not root.is_dir():
        fail(f"--root is not a directory: {args.root}")
    slug, folder = resolve_sprint(root, args.sprint_dir)
    sys.stdout.write(json.dumps(compute(root, slug, folder), indent=2) + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())

