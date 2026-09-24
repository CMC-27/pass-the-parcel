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
              orphans, already_phased, complexity, mode_conflicts, triage_values, counts
    exit 1 -> a single "sprint_eligible: <cause>" line on stderr and NO JSON.
              A non-zero exit is a stop-the-line for @sprint-run: never fall back to
              reasoning the predicate out from prose.

"complexity" is ADVISORY data (like "parallel_groups"), not part of the eligibility
predicate: one entry per queued plan, {"triage", "signals", "multi_worthy", "blocks"}.
The MULTI-worthy flag is the UNION of a declared triage recommendation (the plan's
claim front-matter `triage: MULTI|SINGLE|MICRO`, written by @sprint-plan at commit time)
and a mechanical backstop on the plan's own declared `touches` breadth. The signals are
DEFINED in .devops/skills/pass-the-parcel/SKILL.md section Agent Topology ->
*Complexity Triage* ("blast radius: <= 3 files, one domain" is low); this script cites
that definition and does not fork a second written dialect.

MICRO is the third and lightest value of that vocabulary: it is the exact INVERSE of the
MULTI-worthy flag and is MANUAL-PATH ONLY, so the batch path can neither honour nor
deliver it - its bounds, gate set and collapsed rendering are DEFINED in
.devops/rules/plan-lifecycle.md section *Micro Lane*. It is deliberately NOT a signal
here: a `triage: MICRO` plan never fires multi_worthy on the declared value alone, and
the blast-radius backstop still applies. "triage_values" echoes the legal vocabulary
(the "reserved_surfaces" precedent) so the value set is explicit rather than implied by
which strings happen to be compared.

"lanes" is ADVISORY data too (schema sprint-eligible/1, added by T1-E3.11): one entry
per queued plan, "serial" or "parallel". The Reserved Surface Set that forces the
serial lane is DEFINED in .devops/rules/plan-lifecycle.md section Claim Protocol ->
*Reserved Surfaces & the Lane Model*; this script cites it and echoes the set it used
as "reserved_surfaces" so the host can present it. A lane is a CLASSIFICATION, not an
execution namespace: every path runs in place, one claim at a time, and
therefore still claims one plan at a time.

"mode_conflicts" is ADVISORY data too (schema sprint-eligible/1, added by T1-E3.20):
one entry per queued plan, {"authored", "preset", "conflict"}. It surfaces the batch
preset's overrule risk - a plan whose AUTHORED Plan Settings Mode disagrees with the
batch's locked preset Mode - so the host can present it in the SAME operator answer as
the MULTI-worthy fork and a recorded Mode ruling is never silently replaced at claim
time. The preset Mode is DEFINED in .opencode/plans/base-context.md section
Orchestrator Presets (parcel-sprint -> AUTO) and .devops/rules/plan-lifecycle.md
section Deviations (the locked preset is a named deviation); this script cites those
homes and does not fork a second written dialect. Like "complexity" and "lanes" it is
data for the host, never a clause of the eligibility predicate: a conflict never
changes the eligible set.

Read-only by construction: this script never writes, claims, archives or flips a gate.

ponytail: ceilings (deliberate, documented - see plan-lifecycle.md section Claim Protocol)
  - "parallel_groups" is advisory data only - the fixpoint "claim_order" stays the
    authoritative serial order; it is lane-aware (a serial-lane plan is never packed
    into a group) but it schedules nothing;
  - queue order is the ascending plan code, not the physical order of the sprint.md
    table;
  - "complexity" audits the DECLARED write set, not the tree: a plan with 3 declared
    touches that edits 20 files is not detected; and the declared half is a judgement
    this script deliberately does not re-derive (T1-E3.10 owns the flag, not a scorer).
  (The mid-path-wildcard overlap ceiling recorded here until T1-E3.11 is CLOSED: the
  matcher is segment-wise and a mid-path `*` or `**` is detected. See segment_overlap.)
  - "mode_conflicts" reports, it never blocks: an accepted preset overrule runs
    exactly as today, now with the operator informed. The check adds a signal at the
    EXISTING fork, not a fourth deviation - the batch preset stays locked.
  - "triage_values" is an echo of the legal vocabulary, never a validation pass: an
    unrecognised value still fails open to the mechanical backstop (never a halt), and
    MICRO is only named, never gated here (plan-lifecycle.md section Micro Lane owns it).
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
TRIAGE_SINGLE = "SINGLE"
# The third value, and the only one the batch path cannot deliver: MICRO is the
# manual/between-sprint record. Its bounds and gate set are DEFINED in
# .devops/rules/plan-lifecycle.md section *Micro Lane*; cited here, never restated.
TRIAGE_MICRO = "MICRO"
TRIAGE_VALUES = (TRIAGE_MULTI, TRIAGE_SINGLE, TRIAGE_MICRO)
BLAST_RADIUS_MAX = 3
BLAST_RADIUS = "blast-radius"
CODE_RE = re.compile(r"^([a-z]+\d*-e\d+\.\d+)", re.IGNORECASE)
STATUS_RE = re.compile(r"^\|\s*\*\*Status\*\*\s*\|\s*`([^`]+)`", re.MULTILINE)
# The batch path's locked preset Mode. DEFINED in .opencode/plans/base-context.md
# section Orchestrator Presets (parcel-sprint -> AUTO) and
# .devops/rules/plan-lifecycle.md section Deviations (the locked preset is a named
# deviation); cited here, never restated as a second dialect.
BATCH_PRESET_MODE = "AUTO"
MODE_RE = re.compile(r"^\|\s*\*\*Mode\*\*\s*\|\s*`([^`]+)`", re.MULTILINE)
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


def segments(entry: str) -> list:
    """A normalized entry as path segments (empty segments dropped)."""
    return [s for s in entry.split("/") if s]


def segment_overlap(a: str, b: str) -> bool:
    """Two path segments overlap when equal, or when either is the `*` wildcard."""
    return a == b or a == "*" or b == "*"


def entry_overlap(a: str, b: str) -> bool:
    """Segment-wise glob intersection: A overlaps B when some path matches both, and
    either segment list is a prefix of, or equal to, the other (the canonical
    prefix-or-equal rule, now wildcard-aware).

    - `*`  matches exactly one segment.
    - `**` matches zero or more segments.
    - a literal segment matches only itself, so "src/a" does NOT swallow "src/ab" -
      the boundary rule the literal test enforced is preserved.

    Bounded BFS over (index_a, index_b) pairs with a visited set, so a pathological
    pattern terminates instead of backtracking exponentially.
    """
    if not a or not b:
        return False
    sa, sb = segments(a), segments(b)
    if not sa or not sb:
        return False
    seen = set()
    stack = [(0, 0)]
    while stack:
        i, j = stack.pop()
        if (i, j) in seen:
            continue
        seen.add((i, j))
        if i == len(sa) or j == len(sb):
            # one pattern is exhausted: it is a prefix of (or equal to) the other
            return True
        if sa[i] == "**":
            stack.append((i + 1, j))            # `**` consumes zero segments
            stack.append((i, j + 1))            # `**` consumes one segment
            continue
        if sb[j] == "**":
            stack.append((i, j + 1))
            stack.append((i + 1, j))
            continue
        if segment_overlap(sa[i], sb[j]):
            stack.append((i + 1, j + 1))
    return False


def plan_overlap(mine: list, theirs: list):
    """Return the other plan's first overlapping entry, or None."""
    for be in theirs:
        for ae in mine:
            if entry_overlap(ae, be):
                return be
    return None


# The Reserved Surface Set - the surfaces whose write is GLOBAL rather than
# file-local, so two writers cannot merge. DEFINED (stated once) in
# .devops/rules/plan-lifecycle.md section Claim Protocol -> *Reserved Surfaces &
# the Lane Model*; this tuple is its executable embodiment and cites that section.
# A plan whose `touches` hits any member is on the serial lane.
RESERVED_SURFACES = (
    ".opencode/plans/base-context.md",             # the prefix source (a re-inline rewrites 9 agents)
    ".devops/templates/base-context.template.md",  # the prefix seed
    ".devops/agents",                              # the inlined-prefix targets
    ".devops/sync-manifest.yaml",                  # the machinery-version counter
    ".devops/logs/version-history.md",             # the counter's recorded release row
    ".devops/logs/agent-changelog.md",
    ".devops/sprints",                             # sprint.md + the committed queue
    ".devops/backlog/backlog-index.md",
    ".devops/backlog/SPRINTS.md",
)

SKILL_EMBED_RE = re.compile(r"^\.devops/skills/([^/]+)/skill\.md$")


def serial_reason(rec: dict, root: Path):
    """Why this plan is on the serial lane, or None when it is lane-B eligible.

    Two triggers:
      - a `touches` entry overlapping a member of RESERVED_SURFACES;
      - the prefix-embed cascade: a `.devops/skills/<slug>/SKILL.md` entry whose body
        is embedded in an existing `.devops/agents/<slug>.subagent.md`, because
        executing that plan forces a `-Sync` that rewrites a reserved agent file.
    """
    for entry in rec["touches"]:
        for surface in RESERVED_SURFACES:
            if entry_overlap(entry, surface):
                return f"reserved surface {surface}"
    for entry in rec["touches"]:
        m = SKILL_EMBED_RE.match(entry)
        if m and (root / ".devops" / "agents" / f"{m.group(1)}.subagent.md").is_file():
            return f"prefix embed cascade via {entry}"
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
    `MICRO` is one of the three recognised values (TRIAGE_VALUES) and behaves like an
    absent field here: it is the INVERSE of MULTI-worthy and is manual-path only, so it
    never fires the declared signal and the blast-radius backstop still governs.
    """
    signals = [BLAST_RADIUS] if len(rec["touches"]) > BLAST_RADIUS_MAX else []
    multi_worthy = rec["triage"] == TRIAGE_MULTI or bool(signals)
    return {
        "triage": rec["triage"] or None,
        "signals": signals,
        "multi_worthy": multi_worthy,
        "blocks": blocks_for(rec["code"], queue) if multi_worthy else [],
    }


def mode_conflict_for(rec: dict) -> dict:
    """The batch-preset overrule check (advisory) - one entry per queued plan.

    The batch path's locked preset Mode is DEFINED in
    .opencode/plans/base-context.md section Orchestrator Presets (parcel-sprint -> AUTO)
    and .devops/rules/plan-lifecycle.md section Deviations (the locked preset is a named
    deviation); this function cites those homes and does not restate their semantics. The
    AUTHORED intent is the plan's frozen Plan Settings Mode row (rec["mode"]), which the
    batch runner overwrites only at claim time - after this key is computed.

    A plan whose authored Mode disagrees is surfaced to the operator BEFORE the first
    claim, in the same fork as the MULTI-worthy flag, so a recorded USER-MANAGED ruling
    is never silently replaced. This is ADVISORY data (the complexity / parallel_groups
    precedent), never a clause of the eligibility predicate: a conflict never changes the
    eligible set. An unrecognised present value flags rather than hides (fail-safe) - the
    risk it guards is a SILENT overrule and a spurious flag costs one operator glance.
    """
    authored = rec["mode"] or None
    return {
        "authored": authored,
        "preset": BATCH_PRESET_MODE,
        "conflict": authored is not None and authored.upper() != BATCH_PRESET_MODE,
    }


def status_of(body: str) -> str:
    m = STATUS_RE.search(body)
    return m.group(1).strip() if m else ""


def mode_of(body: str) -> str:
    """The plan's AUTHORED Plan Settings Mode row, or "" when the plan carries none.

    A queued plan has not been claimed, so this reads the authored intent; the batch
    runner writes its own Mode into the block only at claim time, after this key is
    computed. A backlog-style committed plan carries no Plan Settings block at all -
    "" is the honest answer, never an error.
    """
    m = MODE_RE.search(body)
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
        "mode": mode_of(body),
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
        if serial_reason(rec, root) is not None:
            continue  # the serial lane is width 1: never packed with another plan
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
        "lanes": {r["code"]: ("serial" if serial_reason(r, root) else "parallel")
                  for r in queue},
        "reserved_surfaces": sorted(RESERVED_SURFACES),
        "skipped": skipped,
        "in_flight": in_flight,
        "orphans": orphans,
        "already_phased": already_phased,
        "complexity": {r["code"]: complexity_for(r, queue) for r in queue},
        "mode_conflicts": {r["code"]: mode_conflict_for(r) for r in queue},
        # The legal `triage` vocabulary, echoed (the "reserved_surfaces" precedent):
        # MICRO is named here so it is an explicit value, not an unrecognised string
        # that happens to behave the same way. See plan-lifecycle.md section Micro Lane.
        "triage_values": sorted(TRIAGE_VALUES),
        "counts": {
            "queue": len(queue),
            "eligible": len(eligible),
            "claim_order": len(order),
            "skipped": len(skipped),
            "in_flight": len(in_flight),
            "multi_worthy": sum(1 for r in queue if complexity_for(r, queue)["multi_worthy"]),
            "mode_conflicts": sum(1 for r in queue if mode_conflict_for(r)["conflict"]),
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

