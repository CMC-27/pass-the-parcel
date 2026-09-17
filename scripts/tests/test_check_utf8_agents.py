"""Fixtures for scripts/check-utf8-agents.ps1 — the encoding guard.

Stdlib unittest over temp trees, driving the real script through its `-Root` parameter
(the scripts/sprint_eligible.py --root precedent). The guard scans only `*.md`, so every
case plants its bytes in a `.md` file under a scanned directory.

The decisive case is the EOF family: the pre-W7 loop bound (`$i -lt $bytes.Length - 2`)
never tested the final two bytes, so a file ending exactly with C3 A2 passed silently.
That window is gone, and these cases pin it.

Marker bytes are built from code points here too — this fixture never writes a literal
mojibake glyph, and it never writes marker bytes into the repository (temp trees only).
"""

import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parent.parent
GUARD = SCRIPTS / "check-utf8-agents.ps1"
POWERSHELL = shutil.which("powershell") or shutil.which("pwsh")

# The five markers, as raw bytes.
MARKERS = {
    "c3a2": bytes([0xC3, 0xA2]),
    "c3b0c2": bytes([0xC3, 0xB0, 0xC2]),
    "efbfbd": bytes([0xEF, 0xBF, 0xBD]),
    "ce93_c2": bytes([0xCE, 0x93, 0xC2]),
    "ce93_c3": bytes([0xCE, 0x93, 0xC3]),
    "e289a1c692": bytes([0xE2, 0x89, 0xA1, 0xC6, 0x92]),
}

# Legitimate multi-byte UTF-8 that must never be flagged.
LEGIT = {
    "em_dash": "\u2014".encode("utf-8"),
    "emoji": "\U0001f600".encode("utf-8"),
    "arrow": "\u2192".encode("utf-8"),
}


@unittest.skipIf(POWERSHELL is None, "PowerShell host not available")
class Utf8GuardTests(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.root = Path(self._tmp.name)
        (self.root / ".devops" / "agents").mkdir(parents=True)
        (self.root / ".devops" / "skills").mkdir(parents=True)

    def tearDown(self):
        self._tmp.cleanup()

    def plant(self, name: str, payload: bytes) -> Path:
        path = self.root / ".devops" / "agents" / name
        path.write_bytes(payload)
        return path

    def run_guard(self, *extra: str):
        result = subprocess.run(
            [POWERSHELL, "-NoProfile", "-File", str(GUARD), "-Root", str(self.root), *extra],
            capture_output=True,
            text=True,
        )
        return result.returncode, result.stdout

    # --- each marker fires, including with its last byte at EOF -----------------

    def test_each_marker_at_eof_fires(self):
        for name, marker in MARKERS.items():
            with self.subTest(marker=name):
                (self.root / ".devops" / "agents").glob("*.md")
                for stale in (self.root / ".devops" / "agents").glob("*.md"):
                    stale.unlink()
                path = self.plant("eof.agent.md", b"# t\n\n" + marker)
                code, out = self.run_guard()
                self.assertEqual(code, 1, out)
                self.assertIn("MANGLED:", out)
                self.assertIn(path.name, out)

    def test_each_marker_at_offset_zero_and_midfile(self):
        for name, marker in MARKERS.items():
            for position, payload in (("zero", marker + b"body\n"), ("mid", b"body\n" + marker + b"\ntail\n")):
                with self.subTest(marker=name, position=position):
                    for stale in (self.root / ".devops" / "agents").glob("*.md"):
                        stale.unlink()
                    self.plant(f"{position}.agent.md", payload)
                    code, out = self.run_guard()
                    self.assertEqual(code, 1, f"{name}/{position}: {out}")

    # --- clean and legitimate content passes ------------------------------------

    def test_clean_file_exits_zero(self):
        self.plant("clean.agent.md", b"# Clean\n\nNo mojibake here.\n")
        code, out = self.run_guard()
        self.assertEqual(code, 0, out)
        self.assertIn("ALL CLEAN (1 files scanned)", out)

    def test_empty_file_exits_zero(self):
        self.plant("empty.agent.md", b"")
        code, out = self.run_guard()
        self.assertEqual(code, 0, out)

    def test_near_miss_c3_only_passes(self):
        self.plant("nearmiss.agent.md", b"# t\n\n" + bytes([0xC3]) + b"\n")
        code, out = self.run_guard()
        self.assertEqual(code, 0, out)

    def test_near_miss_ce93_other_byte_passes(self):
        self.plant("nearmiss2.agent.md", b"# t\n\n" + bytes([0xCE, 0x93, 0x41]) + b"\n")
        code, out = self.run_guard()
        self.assertEqual(code, 0, out)

    def test_legitimate_utf8_passes(self):
        payload = b"# t\n\n" + LEGIT["em_dash"] + LEGIT["emoji"] + LEGIT["arrow"] + b"\n"
        self.plant("legit.agent.md", payload)
        code, out = self.run_guard()
        self.assertEqual(code, 0, out)

    # --- -All adds the immutable archive ----------------------------------------

    def test_archive_is_scanned_only_under_all(self):
        archive = self.root / ".devops" / "archive"
        archive.mkdir(parents=True)
        (archive / "history.md").write_bytes(b"# h\n\n" + MARKERS["c3a2"])
        code, out = self.run_guard()
        self.assertEqual(code, 0, out)
        code, out = self.run_guard("-All")
        self.assertEqual(code, 1, out)
        self.assertIn("history.md", out)

    # --- the guard's own source carries no literal marker glyph -----------------

    def test_guard_source_contains_no_literal_marker_glyph(self):
        raw = GUARD.read_bytes()
        for name, marker in MARKERS.items():
            self.assertNotIn(marker, raw, f"guard source contains the raw {name} marker sequence")
        self.assertIn(rb"\u00C3\u00A2", raw)

    def test_guard_source_bytes_passed_as_a_scanned_carrier_are_clean(self):
        # A copied .ps1 is never a target (the guard scans only *.md), so the source bytes
        # are carried inside a *.md file that IS scanned.
        self.plant("carrier.agent.md", GUARD.read_bytes())
        code, out = self.run_guard()
        self.assertEqual(code, 0, out)


if __name__ == "__main__":
    unittest.main(verbosity=2)
