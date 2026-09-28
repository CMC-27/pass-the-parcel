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


# ---------------------------------------------------------------------------
# --stamp fixtures (T1-E3.25): recorded == located + the classification line.
# Doctrine: throwaway git trees, real CLI subprocess, exact exit codes.

CHANGELOG = ".devops/logs/agent-changelog.md"
SKIP_LIT = f"suite skipped {DASH} bookkeeping-only delta (stamp {{sha}})"
INVOKE_LIT = f"suite invoked {DASH} real-file delta:"


def _init(root):
    _git(root, "init", "-q", "-b", "main")
    _git(root, "config", "user.email", "fixture@example.com")
    _git(root, "config", "user.name", "Fixture")
    _git(root, "config", "core.autocrlf", "false")


def _write(root, rel, text):
    path = root / rel
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8", newline="\n")
    return path


def _commit_all(root, msg):
    _git(root, "add", "-A")
    _git(root, "commit", "-qm", msg)
    return _git(root, "rev-parse", "--short", "HEAD")


def build_stamp_tree(root, *, record=True, record_fmt="bold", extra=None,
                     move_locator=False, pre=None):
    """Closing commit touches the changelog (locator); then the stamp append.

    pre(root) plants files BEFORE the closing commit (they exist at the stamp);
    extra(root) runs after the append (still a bookkeeping-free window);
    move_locator plants a stray post-append changelog commit (the drift case).
    """
    _init(root)
    if pre is not None:
        pre(root)
    _write(root, CHANGELOG, "# changelog (fixture)\n")
    closing = _commit_all(root, "closing commit")
    if record:
        line = (f"**Green stamp:** `{closing}`" if record_fmt == "bold"
                else f"Green stamp: {closing}")
        _write(root, ".devops/plans/p1.md", f"# fixture plan\n\n{line}\n")
        _commit_all(root, "stamp append")
    if extra is not None:
        extra(root)
    if move_locator:
        _write(root, CHANGELOG, "# changelog (stray second touch)\n")
        _commit_all(root, "stray changelog commit")
    return closing


def run_stamp(root, *extra_args):
    proc = subprocess.run(
        [sys.executable, str(SCRIPT), "--root", str(root), "--stamp", *extra_args],
        capture_output=True, text=True,
    )
    return proc.returncode, (proc.stdout + proc.stderr).strip()


class StampModeTest(unittest.TestCase):
    """AC 1-4: --stamp verdicts and the verbatim outcome line."""

    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.root = Path(self._tmp.name) / "repo"
        self.root.mkdir(parents=True)

    def tearDown(self):
        self._tmp.cleanup()

    # AC1(a) - a plan records the locator: recorded == located, exit 0.
    def test_equality_pass_records_locator(self):
        closing = build_stamp_tree(self.root)
        code, out = run_stamp(self.root)
        self.assertEqual(code, 0, out)
        self.assertIn(f"recorded == located", out)
        self.assertIn(closing, out)

    # AC1(b) - a stray changelog commit moves the locator off every record.
    def test_drift_locator_recorded_nowhere_fails(self):
        build_stamp_tree(self.root, move_locator=True)
        code, out = run_stamp(self.root)
        self.assertEqual(code, 1, out)
        self.assertIn("recorded nowhere", out)

    # AC1 - no changelog commit at all: OK, full suite (fail-safe over-run).
    def test_no_locator_ok(self):
        _init(self.root)
        code, out = run_stamp(self.root)
        self.assertEqual(code, 0, out)
        self.assertIn("no locator", out)

    # AC1 - locator exists but nothing records a stamp: OK, full suite.
    def test_no_recorded_stamp_ok(self):
        build_stamp_tree(self.root, record=False)
        code, out = run_stamp(self.root)
        self.assertEqual(code, 0, out)
        self.assertIn("no recorded stamp", out)

    # AC2 - per-plan strict mode: missing stamp line fails.
    def test_record_flag_missing_line_fails(self):
        build_stamp_tree(self.root)
        other = _write(self.root, ".devops/plans/p2.md", "# no stamp\n")
        code, out = run_stamp(self.root, "--record", str(other))
        self.assertEqual(code, 1, out)
        self.assertIn("no Green stamp: line", out)

    # AC2 - per-plan strict mode: a stale record names both shas.
    def test_record_flag_stale_sha_fails(self):
        build_stamp_tree(self.root)
        stale = _write(self.root, ".devops/plans/p2.md",
                       "**Green stamp:** `0000000`\n")
        code, out = run_stamp(self.root, "--record", str(stale))
        self.assertEqual(code, 1, out)
        self.assertIn("0000000", out)

    # AC2 - per-plan strict mode: matching record passes.
    def test_record_flag_match_passes(self):
        build_stamp_tree(self.root)
        code, out = run_stamp(self.root, "--record",
                              str(self.root / ".devops/plans/p1.md"))
        self.assertEqual(code, 0, out)
        self.assertIn("recorded == located", out)

    # AC3 - bookkeeping-only delta: the skip literal, stamp sha included.
    def test_bookkeeping_delta_prints_skip_literal(self):
        closing = build_stamp_tree(
            self.root,
            extra=lambda r: _commit_all(
                r, _touch(r, ".devops/sprints/s1/sprint.md", "# sprint\n")))
        code, out = run_stamp(self.root)
        self.assertEqual(code, 0, out)
        self.assertIn(SKIP_LIT.format(sha=closing), out)

    # AC3 - a real committed path: the invoked literal names it.
    def test_real_committed_path_prints_invoke_literal(self):
        build_stamp_tree(
            self.root,
            extra=lambda r: _commit_all(r, _touch(r, "scripts/real.py", "x = 1\n")))
        code, out = run_stamp(self.root)
        self.assertEqual(code, 0, out)
        self.assertIn(INVOKE_LIT, out)
        self.assertIn("scripts/real.py", out)

    # AC3 - a pending (untracked) real path also invokes.
    def test_pending_real_path_prints_invoke_literal(self):
        build_stamp_tree(self.root)
        _write(self.root, "scripts/pending.py", "y = 2\n")
        code, out = run_stamp(self.root)
        self.assertEqual(code, 0, out)
        self.assertIn(INVOKE_LIT, out)
        self.assertIn("scripts/pending.py", out)

    # AC3 - package.json decided by content: version line alone skips.
    def test_package_version_only_delta_skips(self):
        def pre(r):
            _write(r, "package.json", '{\n  "version": "1.0.0"\n}\n')

        def bump(r):
            _write(r, "package.json", '{\n  "version": "1.0.1"\n}\n')
            return _commit_all(r, "version bump")

        closing = build_stamp_tree(self.root, pre=pre, extra=bump)
        code, out = run_stamp(self.root)
        self.assertEqual(code, 0, out)
        self.assertIn(SKIP_LIT.format(sha=closing), out)

    # AC3 - package.json with any other delta: real hit.
    def test_package_non_version_delta_invokes(self):
        def pre(r):
            _write(r, "package.json", '{\n  "version": "1.0.0"\n}\n')

        def bump(r):
            _write(r, "package.json",
                   '{\n  "version": "1.0.1",\n  "scripts": {"t": "vitest"}\n}\n')
            return _commit_all(r, "version + scripts bump")

        build_stamp_tree(self.root, pre=pre, extra=bump)
        code, out = run_stamp(self.root)
        self.assertEqual(code, 0, out)
        self.assertIn(INVOKE_LIT, out)
        self.assertIn("package.json", out)

    # AC3 - the real archive's bold/backtick record format parses (R6 lesson).
    def test_plain_record_format_parses(self):
        build_stamp_tree(self.root, record_fmt="plain")
        code, out = run_stamp(self.root)
        self.assertEqual(code, 0, out)
        self.assertIn("recorded == located", out)

    # AC1/edge - a staged git mv (plans -> archive) keeps both sides skippable.
    def test_archived_plan_rename_still_skips(self):
        closing = build_stamp_tree(self.root)
        (self.root / ".devops" / "archive").mkdir(parents=True, exist_ok=True)
        _git(self.root, "mv", ".devops/plans/p1.md", ".devops/archive/p1.md")
        _git(self.root, "commit", "-qm", "archive move")
        code, out = run_stamp(self.root, "--record",
                              str(self.root / ".devops/archive/p1.md"))
        self.assertEqual(code, 0, out)
        self.assertIn(SKIP_LIT.format(sha=closing), out)

    # AC3 - a pending MODIFIED allowlist path is porcelain's first line and its
    # leading status space must not shift the column parse (the live-tree find).
    def test_modified_allowlisted_first_line_skips(self):
        closing = build_stamp_tree(self.root)
        plan = self.root / ".devops/plans/p1.md"
        plan.write_text(plan.read_text(encoding="utf-8") + "more\n",
                        encoding="utf-8")
        code, out = run_stamp(self.root)
        self.assertEqual(code, 0, out)
        self.assertIn(SKIP_LIT.format(sha=closing), out)

    # Survivability - failures are reason lines, never tracebacks.
    def test_no_traceback_on_any_failure(self):
        build_stamp_tree(self.root, move_locator=True)
        code, out = run_stamp(self.root)
        self.assertNotEqual(code, 0)
        self.assertNotIn("Traceback", out)


def _touch(root, rel, text):
    _write(root, rel, text)
    return rel


if __name__ == "__main__":
    unittest.main(verbosity=2)
