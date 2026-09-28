#!/usr/bin/env python3
"""The close-out read witness - the checker behind `@agent-wrap-up` section Phase 7a item 4.

The read itself is a `gh` call and stays a prose non-negotiable: a network read must not
enter a portable surface (T1-E2.11 Q5). What this script checks is everything about that
read that CAN be checked offline:

  * the record's verdict line is one of the three canonical literals (byte-for-byte);
  * a verdict that claims a COLOUR (green/red) names a sha that
      - equals HEAD, and
      - is reachable from the remote-tracking ref;
  * an `unreadable` verdict carries a non-empty reason.

Exit 0 when the record is well-formed and its claim is honest; exit 1 otherwise, with a
one-line reason naming the sha or ref involved. Read-only. Stdlib only. No `gh`, no
network import, no subprocess call outside `git`.

The canonical format lives in `.devops/plans/template-plan.md` section
Completion Note (Wrap Up) - this script is its contract, never a second copy of it.

Run: python scripts/closeout_check.py --record .devops/plans/<plan>.md
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path

VERDICT_PREFIX = "CI verdict:"
DASH = "\u2014"

RE_GREEN = re.compile(r"^CI green " + DASH + r" all (\d+) run\(s\) @ ([0-9a-f]{7,40}) succeeded$")
RE_RED = re.compile(
    r"^CI red " + DASH + r" (.+?) run (\d+) @ ([0-9a-f]{7,40}): (.+)$"
)
RE_UNREADABLE = re.compile(r"^CI status unreadable " + DASH + r" (.+)$")

FAIL = "FAIL: "
OK = "OK: "


def fail(reason: str) -> int:
    print(FAIL + reason)
    return 1


def ok(reason: str) -> int:
    print(OK + reason)
    return 0


def read_verdict_line(text: str) -> str | None:
    """Return the value of the last `CI verdict:` line, or None."""
    found = None
    for raw in text.splitlines():
        line = raw.strip()
        if line.startswith(VERDICT_PREFIX):
            found = line[len(VERDICT_PREFIX):].strip()
    return found


def parse_verdict(value: str) -> dict | None:
    """Parse one of the three canonical literals. None when malformed - never partial."""
    m = RE_GREEN.match(value)
    if m:
        return {"kind": "green", "runs": m.group(1), "sha": m.group(2)}
    m = RE_RED.match(value)
    if m:
        return {
            "kind": "red",
            "workflow": m.group(1),
            "run_id": m.group(2),
            "sha": m.group(3),
            "steps": m.group(4),
        }
    m = RE_UNREADABLE.match(value)
    if m:
        reason = m.group(1).strip()
        if not reason:
            return None
        return {"kind": "unreadable", "reason": reason}
    return None


def git(root: Path, *args: str) -> tuple[int, str, str]:
    try:
        proc = subprocess.run(
            ["git", *args], cwd=str(root), capture_output=True, text=True
        )
    except FileNotFoundError:
        return 127, "", "git not found on PATH"
    return proc.returncode, proc.stdout.strip(), proc.stderr.strip()


def last_line(text: str) -> str:
    lines = [ln for ln in text.splitlines() if ln.strip()]
    return lines[-1] if lines else "git failed"


def head_sha(root: Path) -> tuple[str | None, str | None]:
    code, out, err = git(root, "rev-parse", "HEAD")
    if code != 0:
        return None, last_line(err)
    return out, None


def default_remote_ref(root: Path) -> tuple[str | None, str | None]:
    code, out, err = git(root, "rev-parse", "--abbrev-ref", "HEAD")
    if code != 0:
        return None, last_line(err)
    if out == "HEAD":
        return None, "detached HEAD - no branch to name a remote-tracking ref from"
    return f"origin/{out}", None


def is_reachable(root: Path, sha: str, remote_ref: str) -> tuple[bool, str | None]:
    code, out, err = git(root, "merge-base", "--is-ancestor", sha, remote_ref)
    if code == 0:
        return True, None
    if code == 1:
        return False, None
    return False, f"{remote_ref}: {last_line(err)}"


def check(record: Path, root: Path, remote_ref: str | None) -> int:
    if not record.is_file():
        return fail(f"record not found: {record}")

    value = read_verdict_line(record.read_text(encoding="utf-8"))
    if value is None:
        return fail(f"no `{VERDICT_PREFIX}` line in {record}")

    verdict = parse_verdict(value)
    if verdict is None:
        return fail(f"malformed verdict line in {record}: {value!r}")

    if verdict["kind"] == "unreadable":
        return ok(f"unreadable - {verdict['reason']}")

    sha = verdict["sha"]
    if remote_ref is None:
        remote_ref, why = default_remote_ref(root)
        if remote_ref is None:
            return fail(why or "cannot resolve a remote-tracking ref")

    head, why = head_sha(root)
    if head is None:
        return fail(why or "cannot read HEAD")

    if not head.startswith(sha):
        return fail(f"verdict names {sha[:7]} but HEAD is {head[:7]}")

    reachable, why = is_reachable(root, sha, remote_ref)
    if why is not None:
        return fail(f"cannot resolve {why}")
    if not reachable:
        return fail(f"unbacked {verdict['kind']} claim: {sha[:7]} is not reachable from {remote_ref}")

    return ok(f"{verdict['kind']} @ {sha[:7]} backed by {remote_ref}")


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description="Check a close-out record's CI verdict.")
    parser.add_argument(
        "--root",
        default=str(Path(__file__).resolve().parents[1]),
        help="repo root (default: two levels above this script)",
    )
    parser.add_argument("--record", required=True, help="path to the close-out record")
    parser.add_argument(
        "--remote-ref",
        default=None,
        help="remote-tracking ref (default: origin/<current branch>)",
    )
    args = parser.parse_args(argv)
    return check(Path(args.record), Path(args.root), args.remote_ref)


if __name__ == "__main__":
    sys.exit(main())
