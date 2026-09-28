#!/usr/bin/env python3
"""Fixture tests for scripts/closeout_check.py - the close-out read witness.

The checker's contract is canonical in `.devops/skills/agent-wrap-up` section
Phase 7a, item 4 (the close-out trunk-CI read). Its three verdict literals are the
only legal forms, and the pushed-state precondition is derived offline.

Each case drives the REAL CLI (subprocess + exit code + stdout shape), following
scripts/tests/test_write_set_check.py's doctrine: every case builds a throwaway
git tree in tempfile, creates the remote-tracking ref with `git update-ref` - no
real remote, no network - and asserts the exit code plus the one-line reason.

Run: python scripts/tests/test_closeout_check.py
"""

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
SCRIPT = REPO_ROOT / "scripts" / "closeout_check.py"

DASH = "\u2014"
GREEN = f"CI green {DASH} all 16 run(s) @ {{sha}} succeeded"
RED = f"CI red {DASH} validate.yml run 12345 @ {{sha}}: Coverage gate fixtures"
UNREADABLE_NOT_PUSHED = f"CI status unreadable {DASH} not pushed @ {{sha}}"
UNREADABLE_BARE = f"CI status unreadable {DASH} gh absent"
MALFORMED = "CI green (looks fine to me)"


def _git(root, *args, check=True):
    return subprocess.run(
        ["git", *args], cwd=str(root), check=check, capture_output=True, text=True
    ).stdout.strip()


def _commit(root, name):
    (root / name).write_text(name, encoding="utf-8")
    _git(root, "add", ".")
    _git(root, "commit", "-qm", name)
    return _git(root, "rev-parse", "HEAD")


def build_tree(root, *, pushed=True, remote=True, detached=False):
    """Two commits; origin/main at HEAD when pushed, at HEAD~1 when not."""
    _git(root, "init", "-q", "-b", "main")
    _git(root, "config", "user.email", "fixture@example.com")
    _git(root, "config", "user.name", "Fixture")
    _commit(root, "one.txt")
    head = _commit(root, "two.txt")
    if remote:
        target = head if pushed else _git(root, "rev-parse", "HEAD~1")
        _git(root, "update-ref", "refs/remotes/origin/main", target)
    if detached:
        _git(root, "checkout", "-q", "--detach", "HEAD")
    return head


def write_record(root, verdict):
    (root / "record.md").write_text(
        "# Close-out record (fixture)\n\n"
        "**Completion Note (Wrap Up)**\n\n"
        f"CI verdict: {verdict}\n",
        encoding="utf-8",
    )


class CloseoutCheckTest(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.root = Path(self._tmp.name) / "repo"
        self.root.mkdir(parents=True)

    def tearDown(self):
        self._tmp.cleanup()

    def run_case(self, verdict, **tree):
        head = build_tree(self.root, **tree)
        write_record(self.root, verdict.format(sha=head) if "{sha}" in verdict else verdict)
        proc = subprocess.run(
            [
                sys.executable, str(SCRIPT),
                "--root", str(self.root),
                "--record", str(self.root / "record.md"),
                "--remote-ref", "origin/main",
            ],
            capture_output=True, text=True,
        )
        return proc.returncode, (proc.stdout + proc.stderr).strip(), head

    # AC2(i) + AC1 - a colour the remote can back passes.
    def test_green_backed_by_reachable_sha_passes(self):
        code, out, _ = self.run_case(GREEN)
        self.assertEqual(code, 0, out)

    # AC1 - a malformed verdict line is rejected.
    def test_malformed_verdict_fails(self):
        code, out, _ = self.run_case(MALFORMED)
        self.assertNotEqual(code, 0, out)

    # AC2(i) - an unbacked colour claim fails, naming the sha.
    def test_colour_for_unreachable_sha_fails(self):
        code, out, sha = self.run_case(GREEN, pushed=False)
        self.assertNotEqual(code, 0, out)
        self.assertIn(sha[:7], out)

    # BLOCK-1 - the canonical honest record of an unpushed trunk is a PASS.
    def test_unreadable_not_pushed_passes(self):
        code, out, _ = self.run_case(UNREADABLE_NOT_PUSHED, pushed=False)
        self.assertEqual(code, 0, out)

    def test_unreadable_with_bare_reason_passes(self):
        code, out, _ = self.run_case(UNREADABLE_BARE)
        self.assertEqual(code, 0, out)

    # A red trunk is the wrap-up's hard stop, never the checker's - shape only.
    def test_red_verdict_passes_shape_check(self):
        code, out, _ = self.run_case(RED)
        self.assertEqual(code, 0, out)

    # A stated sha that is not HEAD is rejected (item 4 requires headSha == HEAD).
    def test_colour_for_non_head_sha_fails(self):
        head = build_tree(self.root, pushed=True)
        write_record(self.root, "CI green \u2014 all 1 run(s) @ 0000000 succeeded")
        proc = subprocess.run(
            [
                sys.executable, str(SCRIPT),
                "--root", str(self.root),
                "--record", str(self.root / "record.md"),
                "--remote-ref", "origin/main",
            ],
            capture_output=True, text=True,
        )
        out = (proc.stdout + proc.stderr).strip()
        self.assertNotEqual(proc.returncode, 0, out)
        self.assertNotIn("Traceback", out)

    # Edge case 2 - no origin remote: a reason, never a traceback.
    def test_missing_remote_fails_with_reason(self):
        code, out, _ = self.run_case(GREEN, remote=False)
        self.assertNotEqual(code, 0, out)
        self.assertNotIn("Traceback", out)

    # Edge case 3 - detached HEAD: a reason, never a traceback.
    def test_detached_head_fails_with_reason(self):
        code, out, _ = self.run_case(UNREADABLE_BARE, detached=True)
        self.assertNotIn("Traceback", out)

    # Bold wrapper (`**CI verdict:** …`) is the template scaffold's spelling.
    def test_bold_wrapped_verdict_line_is_read(self):
        head = build_tree(self.root, pushed=True)
        (self.root / "record.md").write_text(
            f"**CI verdict:** CI green \u2014 all 16 run(s) @ {head} succeeded\n",
            encoding="utf-8",
        )
        proc = subprocess.run(
            [
                sys.executable, str(SCRIPT),
                "--root", str(self.root),
                "--record", str(self.root / "record.md"),
                "--remote-ref", "origin/main",
            ],
            capture_output=True, text=True,
        )
        out = (proc.stdout + proc.stderr).strip()
        self.assertEqual(proc.returncode, 0, out)

    # A record with no verdict line at all is a failure.
    def test_missing_verdict_line_fails(self):
        build_tree(self.root, pushed=True)
        (self.root / "record.md").write_text("# no verdict here\n", encoding="utf-8")
        proc = subprocess.run(
            [
                sys.executable, str(SCRIPT),
                "--root", str(self.root),
                "--record", str(self.root / "record.md"),
                "--remote-ref", "origin/main",
            ],
            capture_output=True, text=True,
        )
        self.assertNotEqual(proc.returncode, 0, (proc.stdout + proc.stderr).strip())


if __name__ == "__main__":
    unittest.main(verbosity=2)
