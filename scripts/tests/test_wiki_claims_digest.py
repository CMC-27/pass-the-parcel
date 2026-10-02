"""Fixtures for `digest()` — the claims reader's host-stability contract.

Stdlib unittest over temp trees. Two layers, because the defect this guards was
a gate-level lie (a satellite red in CI and green locally on the same commit):

  * the digest itself — a CRLF working tree and an LF checkout of the same
    content must hash identically, a content edit must still change it;
  * the real `check` subcommand over a planted repo — the same claim passes
    against a CRLF source when pinned to the normalised digest, and goes STALE
    when pinned to the old raw-byte digest.

A binary source (not valid UTF-8) is still hashed raw: it has no newline
convention to fold, so its pin stays byte-for-byte.
"""

import hashlib
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(SCRIPTS))

import wiki_claims  # noqa: E402  (scripts/ must be on the path before this import)

READERS = ("wiki_claims.py", "wiki_lint.py", "wiki_lint_core.py", "wiki_lint_checks.py")
CONTENT = "export function bom(mult) {\n  return mult * 2;\n}\n"
LF_DIGEST = hashlib.sha256(CONTENT.encode("utf-8")).hexdigest()
RAW_BINARY = b"\x00\x01\r\n\xff\xfe\r\n"


def plant(root: Path, rel: str, data: bytes) -> Path:
    path = root / rel
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)
    return path


def doc_for(source: str, digest_hex: str) -> str:
    return (
        "---\n"
        "id: fixture\n"
        "status: stable\n"
        "claims:\n"
        "  - id: fixture-claim\n"
        f"    source: {source}\n"
        f"    hash: sha256:{digest_hex}\n"
        "---\n\n"
        "# Fixture\n"
    )


class DigestContractTests(unittest.TestCase):
    """The digest: same content, any line endings, one hash."""

    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.root = Path(self._tmp.name)
        self.lf = plant(self.root, "lf.js", CONTENT.encode("utf-8"))
        self.crlf = plant(
            self.root, "crlf.js", CONTENT.replace("\n", "\r\n").encode("utf-8")
        )

    def tearDown(self):
        self._tmp.cleanup()

    def test_crlf_and_lf_checkouts_hash_identically(self):
        self.assertEqual(wiki_claims.digest(self.lf), LF_DIGEST)
        self.assertEqual(wiki_claims.digest(self.crlf), LF_DIGEST)

    def test_lone_cr_is_folded_too(self):
        old_mac = plant(self.root, "cr.js", CONTENT.replace("\n", "\r").encode("utf-8"))
        self.assertEqual(wiki_claims.digest(old_mac), LF_DIGEST)

    def test_a_content_edit_still_changes_the_hash(self):
        edited = plant(
            self.root,
            "edited.js",
            CONTENT.replace("* 2", "* 3").replace("\n", "\r\n").encode("utf-8"),
        )
        self.assertNotEqual(wiki_claims.digest(edited), LF_DIGEST)

    def test_binary_source_is_hashed_raw(self):
        binary = plant(self.root, "blob.bin", RAW_BINARY)
        self.assertEqual(
            wiki_claims.digest(binary), hashlib.sha256(RAW_BINARY).hexdigest()
        )


class CheckEndToEndTests(unittest.TestCase):
    """The real `check`, over a planted repo whose source file is CRLF on disk."""

    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.root = Path(self._tmp.name)
        (self.root / "scripts").mkdir()
        for name in READERS:
            shutil.copy(SCRIPTS / name, self.root / "scripts" / name)
        plant(self.root, "src/bom.js", CONTENT.replace("\n", "\r\n").encode("utf-8"))

    def tearDown(self):
        self._tmp.cleanup()

    def run_check(self, pinned: str):
        plant(
            self.root,
            ".wiki/core/fixture.md",
            doc_for("src/bom.js", pinned).encode("utf-8"),
        )
        return subprocess.run(
            [sys.executable, str(self.root / "scripts" / "wiki_claims.py"), "check"],
            capture_output=True,
            text=True,
            cwd=str(self.root),
        )

    def test_normalised_pin_passes_against_a_crlf_source(self):
        result = self.run_check(LF_DIGEST)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_raw_byte_pin_goes_stale_against_the_same_source(self):
        raw = hashlib.sha256(CONTENT.replace("\n", "\r\n").encode("utf-8")).hexdigest()
        result = self.run_check(raw)
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("STALE", result.stdout)


if __name__ == "__main__":
    unittest.main(verbosity=2)
