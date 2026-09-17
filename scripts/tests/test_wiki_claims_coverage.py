"""Fixtures for `python scripts/wiki_claims.py coverage` — the moved coverage gate.

Stdlib unittest over temp trees, driving the real subcommand through `--root`. The gate
used to be scripts/wiki_coverage_check.py; W8.0 moved it into wiki_claims.py with three
declared non-behavioural adjustments (two string re-points and the root threading). These
cases pin the verdict that the move had to preserve:

  * no `src/` tree  -> exit 0 and the byte-identical no-op line;
  * a planted `src/` gap -> exit 1 and the gap named.
"""

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parent.parent
CLAIMS = SCRIPTS / "wiki_claims.py"
NO_SRC_LINE = "coverage OK: no src/ tree in this workspace — nothing to cover"

INDEXES = (
    ".wiki/logic/logic-index.md",
    ".wiki/components/components-index.md",
    ".wiki/features/features-index.md",
)


class CoverageGateTests(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.root = Path(self._tmp.name)

    def tearDown(self):
        self._tmp.cleanup()

    def write(self, rel: str, text: str) -> None:
        path = self.root / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8", newline="\n")

    def run_gate(self):
        result = subprocess.run(
            [sys.executable, str(CLAIMS), "coverage", "--root", str(self.root)],
            capture_output=True,
            text=True,
        )
        return result.returncode, result.stdout

    def test_no_src_tree_is_a_byte_identical_no_op(self):
        code, out = self.run_gate()
        self.assertEqual(code, 0, out)
        self.assertEqual(out.strip(), NO_SRC_LINE)

    def test_planted_gap_exits_one_and_names_the_file(self):
        for rel in INDEXES:
            self.write(rel, "# index\n\n| Doc | Description |\n|---|---|\n")
        self.write("src/utils/orphan.js", "export function nothingCitesThis() {}\n")
        code, out = self.run_gate()
        self.assertEqual(code, 1, out)
        self.assertIn("COVERAGE GAPS: 1 file(s)", out)
        self.assertIn("src/utils/orphan.js", out)

    def test_covered_file_exits_zero(self):
        for rel in INDEXES:
            self.write(rel, "# index\n\n| Doc | Description |\n|---|---|\n")
        self.write("src/utils/cited.js", "export function citedThing() {}\n")
        self.write(
            ".wiki/logic/logic-index.md",
            "# index\n\n| Doc | Description |\n|---|---|\n| `cited.js` | the cited util |\n",
        )
        code, out = self.run_gate()
        self.assertEqual(code, 0, out)
        self.assertIn("all referenced in wiki indexes", out)

    def test_missing_index_exits_one(self):
        self.write("src/utils/orphan.js", "export function x() {}\n")
        code, out = self.run_gate()
        self.assertEqual(code, 1, out)
        self.assertIn("ERROR: index file missing", out)

    def test_the_retired_script_name_is_gone_from_the_gate(self):
        text = CLAIMS.read_text(encoding="utf-8")
        self.assertNotIn("wiki_coverage_check", text)


if __name__ == "__main__":
    unittest.main(verbosity=2)
