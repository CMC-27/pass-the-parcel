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

`--stamp` (T1-E3.25) is the green-stamp gate: the assertion + classifier for the
canon's `Green stamp` contract (`.devops/rules/plan-lifecycle.md` section Gate
Invocation Hygiene - this script EMBODIES that section, never restates it, the
`sprint_eligible.py` precedent). It derives the changelog locator, asserts
`recorded == located` against every `Green stamp:` record under .devops/plans/ and
.devops/archive/, and - only once the equality is green - classifies the
stamp-vs-worktree delta from the canon's two reads plus its bookkeeping allowlist,
printing the verbatim outcome line (`suite skipped - bookkeeping-only delta
(stamp <sha>)` or `suite invoked - real-file delta: <paths>`). No locator, or no
recorded stamp anywhere, exits 0 with an OK line that sends the caller to the FULL
suite: fail-safe over-run - only a record that actually exists authorises a skip.
A locator recorded nowhere (records exist) exits 1: restore the order, never
re-record the stamp to match. Invoked at the two canon moments: the wrap-up's
follow-up bookkeeping commit (`--stamp --record <plan>`, per wrapped plan) and
push time (`@test-and-deploy` section 2, repo-wide).

The canonical formats live in `.devops/plans/template-plan.md` section Completion
Note (Wrap Up) and the canon section named above - this script is their contract,
never a second copy of them.

Run: python scripts/closeout_check.py --record .devops/plans/<plan>.md
     python scripts/closeout_check.py --stamp [--record .devops/plans/<plan>.md]
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path

VERDICT_LABEL = "**CI verdict:**"
RE_VERDICT_LINE = re.compile(r"^\**\s*CI verdict:\s*(?P<value>.+?)\s*\**\s*$")
DASH = "\u2014"

RE_GREEN = re.compile(r"^CI green " + DASH + r" all (\d+) run\(s\) @ ([0-9a-f]{7,40}) succeeded$")
RE_RED = re.compile(
    r"^CI red " + DASH + r" (.+?) run (\d+) @ ([0-9a-f]{7,40}): (.+)$"
)
RE_UNREADABLE = re.compile(r"^CI status unreadable " + DASH + r" (.+)$")

# --- green-stamp contract (T1-E3.25) -------------------------------------
CHANGELOG_PATH = ".devops/logs/agent-changelog.md"
STAMP_DIRS = (".devops/plans", ".devops/archive")
RE_STAMP_LINE = re.compile(r"Green stamp:")
RE_SHA = re.compile(r"[0-9a-f]{7,40}")
# The canon's bookkeeping allowlist (plan/sprint files incl. archive moves,
# version rows, the changelog); backlog files are accepted as over-run, so they
# are deliberately NOT here. Cited, never restated: plan-lifecycle section
# Gate Invocation Hygiene.
ALLOWLIST_FILES = (
    ".devops/logs/version-history.md",
    ".devops/logs/agent-changelog.md",
)
ALLOWLIST_PREFIXES = (".devops/plans/", ".devops/archive/", ".devops/sprints/")
SKIP_NO_LOCATOR = f"no locator {DASH} no wrap-up yet {DASH} run the full suite (fail-safe over-run)"
SKIP_NO_RECORD = f"no recorded stamp {DASH} run the full suite (fail-safe over-run)"
DRIFT_FAIL = f"recorded == located violated {DASH} locator"
SKIP_LITERAL = f"suite skipped {DASH} bookkeeping-only delta"
INVOKE_LITERAL = f"suite invoked {DASH} real-file delta:"

FAIL = "FAIL: "
OK = "OK: "


def fail(reason: str) -> int:
    print(FAIL + reason)
    return 1


def ok(reason: str) -> int:
    print(OK + reason)
    return 0


def read_verdict_line(text: str) -> str | None:
    """Return the value of the last `CI verdict:` line, or None.

    Tolerates the markdown bold wrapper the template scaffold uses
    (`**CI verdict:** <value>`), on either side of the value.
    """
    found = None
    for raw in text.splitlines():
        m = RE_VERDICT_LINE.match(raw.strip())
        if m:
            found = m.group("value").strip().strip("*").strip()
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


def git(root: Path, *args: str, strip_out: bool = True) -> tuple[int, str, str]:
    try:
        proc = subprocess.run(
            ["git", *args], cwd=str(root), capture_output=True, text=True
        )
    except FileNotFoundError:
        return 127, "", "git not found on PATH"
    # strip_out=False keeps stdout verbatim: `--porcelain` column offsets break
    # if the first line's leading status space is stripped (T1-E3.25 finding).
    out = proc.stdout.strip() if strip_out else proc.stdout
    return proc.returncode, out, proc.stderr.strip()


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
        return fail(f"no `CI verdict:` line in {record}")

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


# --- green-stamp mode (T1-E3.25) ------------------------------------------


def locator_sha(root: Path) -> tuple[str | None, str | None]:
    """The push-time locator: last commit touching the changelog."""
    code, out, err = git(root, "log", "--format=%h", "-1", "--", CHANGELOG_PATH)
    if code != 0:
        return None, last_line(err)
    parts = out.split()
    return (parts[0], None) if parts else (None, None)


def stamp_shas_in(path: Path) -> list[str]:
    """Every sha a `Green stamp:` line in this file records.

    Parses the first hex token after the marker - the real archive carries
    `**Green stamp:** \\`<sha>\\``, the plain `Green stamp: <sha>`, and one
    self-describing variant (the T1-E2.12 R6 lesson: parse real records).
    """
    try:
        text = path.read_text(encoding="utf-8")
    except OSError:
        return []
    found: list[str] = []
    for line in text.splitlines():
        marker = line.find("Green stamp:")
        if marker == -1:
            continue
        m = RE_SHA.search(line, marker)
        if m:
            found.append(m.group(0))
    return found


def sha_matches(locator: str, recorded: str) -> bool:
    """Prefix-tolerant equality: %h width may grow between record and check."""
    return locator.startswith(recorded) or recorded.startswith(locator)


def collect_records(root: Path) -> dict[str, list[str]]:
    records: dict[str, list[str]] = {}
    for rel_dir in STAMP_DIRS:
        base = root / rel_dir
        if not base.is_dir():
            continue
        for path in sorted(base.glob("*.md")):
            for sha in stamp_shas_in(path):
                records.setdefault(sha, []).append(f"{rel_dir}/{path.name}")
    return records


def parse_porcelain(out: str) -> list[str]:
    paths: list[str] = []
    for line in out.splitlines():
        if len(line) < 4:
            continue
        rest = line[3:]
        if " -> " in rest:  # a staged rename contributes both sides
            old, new = rest.split(" -> ", 1)
            paths.extend([old.strip('"'), new.strip('"')])
        else:
            paths.append(rest.strip('"'))
    return paths


def version_only(root: Path, locator: str, path: str) -> bool:
    """A package.json delta is a version row iff the content read shows the
    version line alone - content decides, never the name (canon)."""
    code, out, _ = git(root, "diff", locator, "--", path)
    if code != 0 or not out:
        return False  # untracked/absent diff is never a version bump
    if "new file mode" in out or "deleted file mode" in out:
        return False
    content = [
        ln for ln in out.splitlines()
        if ln.startswith(("+", "-")) and not ln.startswith(("+++", "---"))
    ]
    if not content:
        return False
    return all(re.match(r'^[+-]\s*"version":', ln) for ln in content)


def skip_eligible(root: Path, locator: str, path: str) -> bool:
    if path in ALLOWLIST_FILES:
        return True
    if path.startswith(ALLOWLIST_PREFIXES):
        return True
    if path.rsplit("/", 1)[-1] == "package.json":
        return version_only(root, locator, path)
    return False  # backlog and everything else: accepted as over-run


def classify(root: Path, locator: str) -> str:
    """The canon's two reads + allowlist -> the verbatim outcome line.

    Any git read that fails classifies as a hit: fail-safe over-run.
    """
    code_c, out_c, err_c = git(root, "diff", "--name-only", f"{locator}..HEAD")
    code_p, out_p, err_p = git(
        root, "status", "--porcelain", "-uall", strip_out=False
    )
    if code_c != 0 or code_p != 0:
        why = last_line(err_c if code_c != 0 else err_p)
        return f"{INVOKE_LITERAL} git reads unavailable ({why})"
    paths: list[str] = []
    for path in out_c.splitlines() + parse_porcelain(out_p):
        if path and path not in paths:
            paths.append(path)
    real = [p for p in paths if not skip_eligible(root, locator, p)]
    if real:
        return f"{INVOKE_LITERAL} {', '.join(real)}"
    return f"{SKIP_LITERAL} (stamp {locator})"


def stamp_check(root: Path, record: Path | None) -> int:
    locator, why = locator_sha(root)
    if locator is None:
        return ok(SKIP_NO_LOCATOR + (f" ({why})" if why else ""))
    records = collect_records(root)
    if not records:
        return ok(SKIP_NO_RECORD)
    if record is not None:
        if not record.is_file():
            return fail(f"record not found: {record}")
        found = stamp_shas_in(record)
        if not found:
            return fail(f"no Green stamp: line in {record}")
        if not any(sha_matches(locator, sha) for sha in found):
            return fail(
                f"{record} records {found[0]} but locator is {locator}"
            )
    matching = [sha for sha in records if sha_matches(locator, sha)]
    if not matching:
        sample = ", ".join(sorted(records))
        return fail(
            f"{DRIFT_FAIL} {locator} is recorded nowhere (records: {sample})"
        )
    total = sum(len(records[sha]) for sha in matching)
    print(
        OK
        + f"recorded == located {DASH} stamp {locator} recorded in {total} plan(s)"
    )
    print(classify(root, locator))
    return 0



def main(argv=None) -> int:
    parser = argparse.ArgumentParser(
        description="Check a close-out record's CI verdict, or the green stamp."
    )
    parser.add_argument(
        "--root",
        default=str(Path(__file__).resolve().parents[1]),
        help="repo root (default: two levels above this script)",
    )
    parser.add_argument(
        "--record",
        default=None,
        help="path to the close-out record (required unless --stamp)",
    )
    parser.add_argument(
        "--remote-ref",
        default=None,
        help="remote-tracking ref (default: origin/<current branch>)",
    )
    parser.add_argument(
        "--stamp",
        action="store_true",
        help="green-stamp mode: assert recorded == located, then classify",
    )
    args = parser.parse_args(argv)
    if args.stamp:
        record = Path(args.record) if args.record else None
        return stamp_check(Path(args.root), record)
    if args.record is None:
        parser.error("--record is required unless --stamp is given")
    return check(Path(args.record), Path(args.root), args.remote_ref)


if __name__ == "__main__":
    sys.exit(main())
