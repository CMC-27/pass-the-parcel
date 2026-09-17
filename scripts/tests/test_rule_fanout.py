"""Fixtures for scripts/rule_fanout.py — the surface-budget report (report-only).

Stdlib unittest over temp trees, following the scripts/tests/test_sprint_eligible.py
precedent. The decisive property is the derived-region strip: a rule whose signature
appears ONLY inside an inlined agent prefix or an EMBED block must count zero, or a
-Sync re-inline would move every count.
"""

import contextlib
import io
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(SCRIPTS))
import rule_fanout as rf  # noqa: E402

PREFIX = (
    "> **PREFIX-LOCKED:** canonical shared prefix.\n"
    "\n"
    "## Core Development Rules\n"
    "\n"
    "1. **Chunked Write Discipline:** write small.\n"
    "\n"
    "## Workspace Layout\n"
    "\n"
    "- Active plans: `.devops/plans/`\n"
)

SIGNATURE = "Managed Simplicity compact form marker"

AGENT_UNIQUE = "\n## Agent unique\n\nNo rule restatement here.\n"

REGISTRY_HEAD = (
    "---\ntitle: Surface Budget\n---\n\n"
    "# Surface Budget\n\n"
    f"{rf.BLOCK_START}\n"
    "walk-roots:\n"
    "  - .devops/agents\n"
    "  - .devops/skills\n"
    "  - .devops/rules\n"
    "rules:\n"
)


def registry_block(canonical=".devops/rules/canon.md", allowed="", signature=SIGNATURE, extra=""):
    row = f"  - test-rule :: {signature} :: {canonical} :: {allowed}\n"
    return REGISTRY_HEAD + row + extra + f"{rf.BLOCK_END}\n"


class TempTree:
    """A minimal machinery tree: prefix, canon doc, one agent, one skill."""

    def __init__(self, registry: str):
        self._tmp = tempfile.TemporaryDirectory()
        self.root = Path(self._tmp.name)
        self._write(".opencode/plans/base-context.md", PREFIX)
        self._write(".devops/rules/canon.md", "# Canon\n\none home\n")
        self._write(".devops/rules/surface-budget.md", registry)
        self._write(".devops/agents/x.agent.md", "---\nname: x\n---\n" + PREFIX + AGENT_UNIQUE)
        self._write(".devops/skills/s/SKILL.md", "# Skill\n\nno rule text\n")

    def _write(self, rel: str, text: str) -> None:
        path = self.root / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8", newline="\n")

    def write(self, rel: str, text: str) -> None:
        self._write(rel, text)

    def run(self):
        """Run the report over this tree and return (exit_code, stdout)."""
        buffer = io.StringIO()
        with contextlib.redirect_stdout(buffer):
            code = rf.main(["--root", str(self.root)])
        return code, buffer.getvalue()

    def evaluate(self):
        walk, rules = rf.parse_registry(rf.read_text(self.root / rf.REGISTRY_REL))
        self.assert_parsed(walk, rules)
        stripped, raw = rf.collect(self.root, walk)
        return {rule["id"]: rf.evaluate(rule, stripped, raw) for rule in rules}

    @staticmethod
    def assert_parsed(walk, rules):
        assert walk is not None and rules is not None, "registry block did not parse"

    def close(self):
        self._tmp.cleanup()


class RuleFanoutTests(unittest.TestCase):
    def setUp(self):
        self.trees = []

    def tearDown(self):
        for tree in self.trees:
            tree.close()

    def tree(self, registry: str) -> TempTree:
        tree = TempTree(registry)
        self.trees.append(tree)
        return tree

    # --- derived regions -------------------------------------------------

    def test_prefix_inlined_agent_counts_zero(self):
        tree = self.tree(registry_block())
        tree.write(".devops/agents/x.agent.md", "---\nname: x\n---\n" + PREFIX + AGENT_UNIQUE)
        self.assertEqual(tree.evaluate()["test-rule"]["sites"], [])

    def test_embed_block_counts_zero(self):
        tree = self.tree(registry_block())
        tree.write(
            ".devops/skills/s/SKILL.md",
            "# Skill\n\n<!-- EMBED:START:s -->\n"
            f"{SIGNATURE}\n"
            "<!-- EMBED:END -->\n\nafter\n",
        )
        self.assertEqual(tree.evaluate()["test-rule"]["sites"], [])

    def test_embed_marker_mentioned_in_prose_is_not_a_block(self):
        """A one-line mention of both markers (as the prefix's own header carries) is not a block."""
        tree = self.tree(registry_block())
        tree.write(
            ".devops/skills/s/SKILL.md",
            "# Skill\n\nEmbeds live between `<!-- EMBED:START -->` / `<!-- EMBED:END -->` markers.\n\n"
            f"{SIGNATURE}\n",
        )
        self.assertEqual(tree.evaluate()["test-rule"]["sites"], [".devops/skills/s/SKILL.md"])

    def test_registry_doc_excluded(self):
        tree = self.tree(registry_block())
        result = tree.evaluate()["test-rule"]
        self.assertNotIn(rf.REGISTRY_REL, result["sites"])
        self.assertEqual(result["sites"], [])

    def test_sync_reline_does_not_move_count(self):
        """A second -Sync (prefix re-inlined, twice) leaves the count unchanged."""
        tree = self.tree(registry_block())
        once = len(tree.evaluate()["test-rule"]["sites"])
        tree.write(".devops/agents/x.agent.md", "---\nname: x\n---\n" + PREFIX + PREFIX + AGENT_UNIQUE)
        self.assertEqual(len(tree.evaluate()["test-rule"]["sites"]), once)

    # --- registry parsing ------------------------------------------------

    def test_registry_block_parses(self):
        tree = self.tree(registry_block(canonical=".devops/rules/canon.md", allowed=".devops/agents/x.agent.md"))
        walk, rules = rf.parse_registry(rf.read_text(tree.root / rf.REGISTRY_REL))
        self.assertIsNotNone(walk)
        self.assertIn(".devops/agents", walk)
        self.assertEqual(len(rules), 1)
        self.assertEqual(rules[0]["signature"], SIGNATURE)
        self.assertEqual(rules[0]["home"], ".devops/rules/canon.md")
        self.assertEqual(rules[0]["allowed"], [".devops/agents/x.agent.md"])

    # --- allowed-surfaces pointer test -----------------------------------

    def test_linked_allowed_surface_subtracts(self):
        tree = self.tree(registry_block(allowed=".devops/skills/s/SKILL.md"))
        tree.write(".devops/skills/s/SKILL.md", f"# Skill\n\n{SIGNATURE}\n\nsee .devops/rules/canon.md\n")
        result = tree.evaluate()["test-rule"]
        self.assertEqual(result["sites"], [".devops/skills/s/SKILL.md"])
        self.assertEqual(result["unofficial"], [])
        self.assertEqual(result["unlinked"], [])

    def test_unlinked_allowed_surface_does_not_subtract(self):
        tree = self.tree(registry_block(allowed=".devops/skills/s/SKILL.md"))
        tree.write(".devops/skills/s/SKILL.md", f"# Skill\n\n{SIGNATURE}\n\nno pointer here\n")
        result = tree.evaluate()["test-rule"]
        self.assertEqual(result["unofficial"], [".devops/skills/s/SKILL.md"])
        self.assertEqual(result["unlinked"], [(".devops/skills/s/SKILL.md", "unlinked")])

    # --- report-only exit contract ---------------------------------------

    def test_zero_match_rule_exits_zero(self):
        tree = self.tree(registry_block(signature="a phrase that appears nowhere"))
        code, out = tree.run()
        self.assertEqual(code, 0)
        self.assertIn("test-rule", out)
        self.assertNotIn("Traceback", out)

    def test_malformed_registry_exits_zero(self):
        tree = self.tree("# No block at all\n")
        code, out = tree.run()
        self.assertEqual(code, 0)
        self.assertIn("malformed registry block", out)
        self.assertNotIn("Traceback", out)

    def test_duplicate_delimiter_exits_zero(self):
        tree = self.tree(registry_block(extra=f"{rf.BLOCK_START}\n"))
        code, out = tree.run()
        self.assertEqual(code, 0)
        self.assertIn("malformed registry block", out)

    def test_absent_registry_exits_zero(self):
        tree = self.tree(registry_block())
        (tree.root / rf.REGISTRY_REL).unlink()
        code, out = tree.run()
        self.assertEqual(code, 0)
        self.assertIn("no registry block", out)

    def test_no_sibling_yaml(self):
        repo = SCRIPTS.parent
        self.assertFalse((repo / ".devops/rules/surface-budget.yaml").exists())


if __name__ == "__main__":
    unittest.main(verbosity=2)
