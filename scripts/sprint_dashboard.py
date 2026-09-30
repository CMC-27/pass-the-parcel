#!/usr/bin/env python3
"""sprint_dashboard.py - the sprint queue dashboard, read-only renderer.

Plan: .devops/plans/t1-e3.26-queue-dashboard-plan.md (T1-E3.26). ONE dashboard
shape, printed at every transition: the operator's renamed queue in plain
language, always answering "where am I / what is next".

Mirrors the sprint_eligible.py header idiom (executable embodiment of the
contract; the skills cite it, never restate it) in spirit only.

Contract (pinned by the plan's Phase 4 criteria + Phase 5 instructions):
  - plain-text default; degraded renders exit 0 and never silently blank;
  - --json is the ONE machine mode (no --yaml: D1 refusal - no PyYAML import,
    no declared dependency). Top-level keys schema/sprint/rows/rails/state,
    schema "sprint-dashboard/1"; rows[] fields EXACTLY code/order/title/size/
    state/marker/blocked_reason; row `state` tokens are the seven state-map
    branches; top-level `state` = {"kind": ...} (+ "dropped_rows" when a
    partial parse dropped codes - never a silent print of 4 of 5 plans);
  - exit 1 is reserved for a named data failure (a missing register); every
    degraded reality renders and exits 0.
Reads only .devops/ tree material; never .opencode/ run workspaces; writes
nothing.

Import surface (plan D2 - the named reads, no re-derivation):
  compute(root, slug, folder)            queue/complexity/lanes/skipped
  archive_codes(root)                    COMPLETE membership
  wiki_lint frontmatter_block/parse_frontmatter   plan front-matter reads
  self-owned SPRINTS.md ACTIVE-row scan  the 0/>=2 degrade paths (resolve_sprint
  is on the happy path only - it exit(1)s on exactly those counts; plan E3).
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
    from sprint_eligible import archive_codes, compute, resolve_sprint
    from wiki_lint import frontmatter_block, parse_frontmatter
except ImportError as exc:  # fail closed: never re-implement the shared readers
    sys.stderr.write(f"sprint_dashboard: shared reader import failed: {exc}\n")
    raise SystemExit(1)

SCHEMA = "sprint-dashboard/1"
ACTIVE_MARK = "\U0001F7E2 ACTIVE"    # the register status literal (plan F5)
CLOSED_MARK = "\u2705 CLOSED"        # the register closed epoch (plan F5)
SPRINTS_PATH = ".devops/backlog/SPRINTS.md"
TEMPLATE = "template-plan.md"
PLAN_GLOB = "*-plan.md"
GATE_D = "GATE_D_USER_APPROVAL"
CLAIMED = "CLAIMED"
COMPLETE = "COMPLETE"
STATUS_RE = re.compile(r"^\|\s*\*\*Status\*\*\s*\|\s*`([^`]+)`", re.MULTILINE)

# Committed Scope row: the REAL six-column template shape (`M (3)` tolerated,
# trailing cells tolerated, no $ anchor). Pinned ONCE here - the plan cites
# this line, never restates it (round-2 fix R1).
ROW_RE = re.compile(
    r"^\|\s*(\d+)\s*\|"
    r"\s*([A-Z0-9]+-E\d+\.\d+)\s*\|"
    r"\s*(.+?)\s*\|"
    r"\s*([SML]|XL)(?:\s*\((\d+)\))?\s*\|"
)

# State map (plan precedence: first match wins, in listed order).
STATE_TOKENS = (
    "complete", "awaiting_gate_d", "running", "blocked",
    "waiting_on_your_call", "queued", "missing",
)
STATE_MASK = {
    "complete": "\u2705 complete",
    "awaiting_gate_d": "\u23F3 awaiting gate D",
    "running": "\u25B6 running — batch",
    "blocked": "\U0001F6A7 blocked",
    "waiting_on_your_call": "\u23F8 waiting on your call",
    "queued": "\u2B1C queued — batch",
    "missing": "\u2754 missing",
}
KINDS = ("ok", "no_active_sprint", "two_active", "empty_queue", "zero_scope_table")
RAILS = ("sprint start", "user testing", "sprint close")
ROW_FIELD_ORDER = ("code", "order", "title", "size", "state", "marker", "blocked_reason")


def fail(msg: str):
    """Named data failure - exit 1. Degraded realities never take this path."""
    sys.stderr.write(f"sprint_dashboard: {msg}\n")
    raise SystemExit(1)


def register_state(root: Path):
    """Self-owned ACTIVE-row scan over SPRINTS.md (the degrade path's read).
    Returns (kind, register_text): "no_active_sprint" at 0 rows, "two_active"
    at >= 2, "ok" at exactly 1 (resolve_sprint re-resolves the folder on that
    happy path - the count gate keeps its exit-1 contract off the degrade
    paths, plan E3). A missing register is a named data failure, exit 1.
    """
    path = root / SPRINTS_PATH
    if not path.is_file():
        fail(f"sprint register not found: {SPRINTS_PATH}")
    text = path.read_text(encoding="utf-8-sig")
    active = [ln for ln in text.splitlines() if ACTIVE_MARK in ln]
    if not active:
        return "no_active_sprint", text
    if len(active) > 1:
        return "two_active", text
    return "ok", text


def scope_table(folder: Path):
    """Parse the Committed Scope table out of sprint.md.

    Returns (rows, dropped, zero_kind):
      rows    [(order, code, title, size)] in listed table order (Q1);
      dropped codes whose table-ish lines failed the pinned regex;
      zero_kind  "empty_queue" when the section is present, well-formed and
                 has no data rows (the honest empty queue) - or
                 "zero_scope_table" when the section is missing/pared to
                 placeholders: zero parse is NEVER silently an empty queue
                 (plan E2).
    """
    md = folder / "sprint.md"
    if not md.is_file():
        return [], [], "zero_scope_table"  # no sprint record = no table to read
    text = md.read_text(encoding="utf-8-sig")
    lines = text.splitlines()
    start = next((i for i, l in enumerate(lines) if l.strip().startswith("## Committed Scope")), None)
    if start is None:
        return [], [], "zero_scope_table"
    section = []
    for ln in lines[start + 1:]:
        if ln.strip().startswith("## "):
            break
        section.append(ln)
    header_ok = any("| #" in ln and "Code" in ln for ln in section)
    rows, dropped = [], []
    for ln in section:
        s = ln.strip()
        if not s.startswith("|") or set(s) <= set("|-: "):
            continue
        m = ROW_RE.match(s)
        if m:
            rows.append((int(m.group(1)), m.group(2).upper(), m.group(3).strip(), m.group(4)))
        elif header_ok and ("|" in s and "#" not in s):
            dropped.append(s.split("|")[2].strip() if s.count("|") > 2 else s[:24])
        else:
            continue  # the header / separator rows themselves
    zero_kind = None
    if not rows:
        zero_kind = "empty_queue" if (header_ok and not dropped) else "zero_scope_table"
    return rows, dropped, zero_kind


def sprint_meta(folder: Path):
    """sprint.md frontmatter: (number, name, status). Status "open"/"closed"
    is the literal the template seeds and @sprint-close flips."""
    text = (folder / "sprint.md").read_text(encoding="utf-8-sig")
    fm, _ = parse_frontmatter(text)
    return ((fm.get("sprint") or "").strip(),
            (fm.get("name") or "").strip(),
            (fm.get("status") or "").strip())


def claimed_plans(root: Path):
    """Live claim set from .devops/plans/: code -> {claim_status, plan_status}.
    claim_status is authoritative over the body Status (canonical:
    .devops/rules/plan-lifecycle.md § Claim Front-Matter); a contradiction is
    named, never reconciled (plan AC 9). The INTERRUPTED-RUN signature
    (CLAIMED with a PHASE_9 body) names itself too - the footer, not a guess.
    """
    folder = root / ".devops" / "plans"
    out = {}
    if not folder.is_dir():
        return out
    for path in sorted(folder.glob(PLAN_GLOB), key=lambda p: p.name.lower()):
        if path.name == TEMPLATE:
            continue
        text = path.read_text(encoding="utf-8-sig")
        fm, body = parse_frontmatter(text)
        code = (fm.get("code") or "").strip().upper()
        if not code:
            continue
        m = STATUS_RE.search(body)
        out[code] = {
            "claim_status": (fm.get("claim_status") or "").strip(),
            "plan_status": m.group(1).strip() if m else "",
        }
    return out


def build_rows(table_rows, extras, q, claimed, archived):
    """One dashboard row per committed code, table order first (Q1), trailing
    queue codes after in code order. Returns (rows, footers) - footers carry
    the named degradation notes (COMPLETE-in-place, contradiction); they are
    text-mode-only, the JSON contract stays fixed-shape (plan F3).
    """
    skipped = {s["code"]: s.get("reasons") or [] for s in q["skipped"]}
    complexity = q.get("complexity", {})
    rows, footers = [], []
    seen = set()

    def state_and_reason(code: str):
        """The plan's state map, in listed order - first match wins (F4).
        `missing` is the fallthrough: unlocatable in any tree location."""
        if code in archived:
            return "complete", None
        rec = claimed.get(code)
        if rec is not None:
            cs = rec["claim_status"]
            if cs == COMPLETE:
                footers.append(f"{code} wrap-up done, archive move pending")
                return "complete", None
            if rec["plan_status"] and _contradiction(cs, rec["plan_status"]):
                footers.append(f"{code} claim_status contradicts body Status "
                               f"({cs} / {rec['plan_status']}) - claim front-matter "
                               f"is the claim state (plan-lifecycle § Claim Front-Matter)")
            if cs == GATE_D:
                return "awaiting_gate_d", None
            if cs == CLAIMED:
                return "running", None
        if code in skipped:
            return "blocked", (skipped[code] or ["unmet dependency"])[0]
        meta = complexity.get(code) or {}
        if meta.get("multi_worthy"):
            return "waiting_on_your_call", None
        if code in q["queue"]:
            return "queued", None
        return "missing", None

    for order, (num, code, title, size) in enumerate(table_rows, start=1):
        if code in seen:
            continue
        seen.add(code)
        state, reason = state_and_reason(code)
        rows.append({"code": code, "order": order, "title": title, "size": size,
                     "state": state, "marker": False, "blocked_reason": reason})
    for code in extras:
        if code in seen:
            continue
        seen.add(code)
        state, reason = state_and_reason(code)
        rows.append({"code": code, "order": len(rows) + 1, "title": "", "size": "",
                     "state": state, "marker": False, "blocked_reason": reason})
    marker = next((r for r in rows if r["state"] != "complete"), None)
    if marker is not None:
        marker["marker"] = True  # every row complete -> no marker at all (W2)
    return rows, footers


def _contradiction(claim: str, body: str) -> bool:
    """The two named mismatches only: GATE_D claim with a non-PHASE_9 body,
    and the interrupted-run signature (CLAIMED claim, PHASE_9 body). COMPLETE
    claims never take this path - E4's badge owns them."""
    if claim == GATE_D:
        return body != "PHASE_9"
    if claim == CLAIMED:
        return body == "PHASE_9"
    return False


def rails_for(root: Path, slug: str, status: str, is_active: bool, all_complete: bool):
    """The three rails' truth functions - one total ladder each, precedence
    current > done > pending, else pending (plan A1/F2)."""
    copy = root / ".devops" / "archive" / "sprints" / slug / "sprint.md"
    testing = root / ".devops" / "archive" / "sprints" / slug / "user-testing.md"
    def phase(done, current):
        return "current" if current else ("done" if done else "pending")
    start = phase(copy.is_file(), is_active)
    user_test = phase(testing.is_file(), all_complete and status == "open")
    close = phase(copy.is_file(), status == "closed" and not copy.is_file())
    return [{"rail": r, "phase": p} for r, p in zip(RAILS, (start, user_test, close))]


def render_text(root, kind, rows, footers, rails, dropped, meta):
    """Plain-language print. Every degraded reality renders — never blank."""
    lines = []
    if kind == "no_active_sprint":
        return "no ACTIVE sprint — run @sprint-plan"
    if kind == "two_active":
        return "the register shows two ACTIVE sprints — which one is real?"
    if kind == "zero_scope_table":
        return "Committed Scope table could not be parsed — sprint.md may be hand-mangled; review it before reading this queue"
    num, name, st = meta
    title = f"Sprint {num}: {name}".rstrip(": ")
    status_word = {"open": "open", "closed": "closed"}.get(st, "")
    lines.append(f"{title}{'  ·  ' + status_word if status_word else ''}")
    for rail in rails:
        glyph = {"done": "\u2705", "current": "\u25B6", "pending": "\u2610"}[rail["phase"]]
        lines.append(f" {glyph} {rail['rail']} — {rail['phase']}")
    for r in rows:
        badge = STATE_MASK[r["state"]]
        label = f" {badge}  {r['code']}"
        if r["title"]:
            label += f"  {r['title']}"
        if r["state"] == "blocked" and r["blocked_reason"]:
            label += f" — {plain_reason(r['blocked_reason'])} (\"{r['blocked_reason']}\")"
        lines.append(label)
        if r["marker"]:
            lines.append(f"   ⟵ you are here ({STATE_MASK[r['state']]})")
    if dropped:
        lines.append(f"{len(dropped)} row(s) of the queue did not parse — review sprint.md")
    lines.extend(f"note: {f}" for f in footers)
    return "\n".join(lines)


def plain_reason(reason: str) -> str:
    """Ride R2: the owner reads 'unmet depends_on: T1-E2.x' as 'unmet
    dependency T1-E2.x'. One literal translation pass; raw in --json."""
    return (reason.replace("unmet depends_on:", "unmet dependency")
                  .replace("touches overlap:", "write-set overlap with"))


def build_report(root: Path, kind: str, rows, footers, rails, dropped, slug: str):
    out = {
        "schema": SCHEMA,
        "sprint": slug,
        "rows": [{f: r[f] for f in ROW_FIELD_ORDER} for r in rows],
        "rails": rails,
        "state": {"kind": kind},
    }
    if dropped:
        out["state"]["dropped_rows"] = list(dropped)
    return out


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description="Sprint queue dashboard (read-only view).")
    parser.add_argument("--root", default=None, help="repository root to read")
    parser.add_argument("--json", action="store_true", help="machine mode (the one contract)")
    args = parser.parse_args(argv)
    root = Path(args.root).resolve() if args.root else SCRIPTS_DIR.parent
    if not root.is_dir():
        fail(f"--root is not a directory: {args.root}")
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")  # the view never depends on the console codepage
    if hasattr(sys.stderr, "reconfigure"):
        sys.stderr.reconfigure(encoding="utf-8")

    kind, _reg = register_state(root)  # self-owned scan; 0 / >=2 stay off resolve_sprint
    if kind in ("no_active_sprint", "two_active"):
        report = build_report(root, kind, [], [], [], [], "")
        print(json.dumps(report, indent=2) if args.json else render_text(root, kind, [], [], [], [], ("", "", "")))
        return 0

    slug, folder = resolve_sprint(root, None)  # happy path only (plan E3)
    q = compute(root, slug, folder)
    rows_tbl, dropped, fell = scope_table(folder)
    if fell == "zero_scope_table":
        report = build_report(root, fell, [], [], [], dropped, slug)
        print(json.dumps(report, indent=2) if args.json else render_text(root, fell, [], [], [], dropped, ("", "", "")))
        return 0
    meta = sprint_meta(folder)
    claimed = claimed_plans(root)
    archived = archive_codes(root)
    table_codes = {c for _, c, _, _ in rows_tbl}
    extras = [c for c in q["queue"] if c not in table_codes]
    rows, footers = build_rows(rows_tbl, extras, q, claimed, archived)
    all_complete = bool(rows) and all(r["state"] == "complete" for r in rows)
    rails = rails_for(root, slug, meta[2], True, all_complete)
    if not rows:
        kind = "empty_queue"
    report = build_report(root, kind, rows, footers, rails, dropped, slug)
    print(json.dumps(report, indent=2) if args.json else render_text(root, kind, rows, footers, rails, dropped, meta))
    return 0


if __name__ == "__main__":
    sys.exit(main())
