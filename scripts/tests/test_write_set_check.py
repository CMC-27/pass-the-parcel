#!/usr/bin/env python3
"""Fixture tests for scripts/write_set_check.py — the Write-Set Derivation Witness.

The predicate's definition is canonical in .devops/rules/plan-lifecycle.md section
Claim Protocol (step 2); this suite pins the script that embodies it. Each case drives
the REAL CLI (subprocess + exit code + stdout shape), because the exit code and the
one-line stderr are the contract both claim paths consume.

Every case builds a throwaway tree in tempfile and drives the real script over it via
`--root`, the scripts/sprint_eligible.py fixture doctrine.

Run: python scripts/tests/test_write_set_check.py
"""

import json
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
SCRIPT = REPO_ROOT / "scripts" / "write_set_check.py"

# The PREFIX-LOCKED set the fixture's tree carries: parcel*.agent.md + ptp-*.subagent.md.
AGENTS = ("parcel.agent.md", "parcel-sprint.agent.md", "ptp-alpha.subagent.md", "ptp-beta.subagent.md")
AGENT_PATHS = [f".devops/agents/{name}" for name in AGENTS]
NOT_AN_AGENT = ".devops/agents/wiki-writer.agent.md"  # no shared prefix -> never R1/R2
CLAIM_SOURCE = "scripts/thing.py"
WIKI_DOCS = [".wiki/core/doc-a.md", ".wiki/core/doc-b.md"]


class Tree:
    """A throwaway machinery tree: agents, skills, a wiki with grounded claims, a plan."""

    def __init__(self, base: Path):
        self.root = base
        self.agents = base / ".devops" / "agents"
        self.skills = base / ".devops" / "skills"
        self.wiki = base / ".wiki" / "core"
        self.plans = base / ".devops" / "plans"
        for folder in (self.agents, self.skills, self.wiki, self.plans,
                       base / ".opencode" / "plans", base / ".devops" / "templates"):
            folder.mkdir(parents=True, exist_ok=True)
        for name in AGENTS:
            (self.agents / name).write_text("# agent\n", encoding="utf-8")
        (base / NOT_AN_AGENT).write_text("# writer\n", encoding="utf-8")
        for slug in ("ptp-alpha", "pass-the-parcel"):
            (self.skills / slug).mkdir(parents=True, exist_ok=True)
            (self.skills / slug / "SKILL.md").write_text("# skill\n", encoding="utf-8")
        for doc in WIKI_DOCS:
            target = base / doc
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(
                "---\ntitle: doc\nclaims:\n  - id: c1\n    source: "
                f"{CLAIM_SOURCE}#Symbol\n    hash: sha256:00\n---\n# doc\n",
                encoding="utf-8",
            )

    def plan(self, touches=(), no_touches=False, name="fixture-plan.md"):
        lines = [
            "---",
            "code: T1-E9.99",
            "sprint: none",
            "claim_status: QUEUED",
            "owner: fixture",
            'claimed_at: "2026-09-27"',
            'last_touch: "2026-09-27"',
            "touches: [" + ", ".join(json.dumps(t) for t in touches) + "]",
            "depends_on: []",
            "---",
            "# Fixture plan",
            "",
        ]
        if no_touches:
            lines = [ln for ln in lines if not ln.startswith("touches:")]
        path = self.plans / name
        path.write_text("\n".join(lines), encoding="utf-8")
        return path


def run(plan, root):
    return subprocess.run(
        [sys.executable, str(SCRIPT), "--plan", str(plan), "--root", str(root)],
        capture_output=True,
        text=True,
    )


def payload(result):
    return json.loads(result.stdout)


class WriteSetCheckTests(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.tree = Tree(Path(self._tmp.name))
        self.root = self.tree.root

    def tearDown(self):
        self._tmp.cleanup()

    # --- the clean case: every forced path declared -> exit 0 + one JSON object ----

    def test_clean_plan_exits_zero_with_json(self):
        plan = self.tree.plan(touches=[
            ".opencode/plans/base-context.md", *AGENT_PATHS,
            ".devops/skills/ptp-alpha/SKILL.md", ".devops/agents/ptp-alpha.subagent.md",
            CLAIM_SOURCE, *WIKI_DOCS,
        ])
        result = run(plan, self.root)
        self.assertEqual(result.returncode, 0, result.stderr)
        out = payload(result)
        self.assertEqual(out["schema"], "write-set/1")
        self.assertEqual(out["missing"], [])
        for key in ("schema", "root", "plan", "declared", "closure", "missing", "counts"):
            self.assertIn(key, out)

    # --- R1 prefix-cascade --------------------------------------------------------

    def test_prefix_cascade_forces_agents(self):
        plan = self.tree.plan(touches=[".opencode/plans/base-context.md"])
        result = run(plan, self.root)
        self.assertEqual(result.returncode, 1, result.stdout)
        for path in AGENT_PATHS:
            self.assertIn(path, result.stderr)
        self.assertEqual(result.stdout, "")
        self.assertEqual(len(result.stderr.strip().splitlines()), 1)

    def test_prefix_cascade_partial_declaration_names_the_rest(self):
        plan = self.tree.plan(touches=[
            ".opencode/plans/base-context.md", ".devops/agents/parcel.agent.md",
        ])
        result = run(plan, self.root)
        self.assertEqual(result.returncode, 1, result.stdout)
        self.assertNotIn("parcel.agent.md (", result.stderr)
        for path in AGENT_PATHS[1:]:
            self.assertIn(path, result.stderr)

    def test_directory_entry_satisfies(self):
        plan = self.tree.plan(touches=[".opencode/plans/base-context.md", ".devops/agents/"])
        result = run(plan, self.root)
        self.assertEqual(result.returncode, 0, result.stderr)

    # --- R2 embed-cascade ---------------------------------------------------------

    def test_embed_cascade_forces_subagent(self):
        plan = self.tree.plan(touches=[".devops/skills/ptp-alpha/SKILL.md"])
        result = run(plan, self.root)
        self.assertEqual(result.returncode, 1, result.stdout)
        self.assertIn(".devops/agents/ptp-alpha.subagent.md", result.stderr)
        self.assertIn("embed-cascade", result.stderr)
        self.assertNotIn("ptp-beta", result.stderr)

    def test_skill_without_agent_forces_nothing(self):
        plan = self.tree.plan(touches=[".devops/skills/pass-the-parcel/SKILL.md"])
        result = run(plan, self.root)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_glob_entry_satisfies(self):
        # `*` is a WHOLE-SEGMENT wildcard in the canonical matcher (entry_overlap) —
        # `*.subagent.md` is a literal segment and would NOT match, by design.
        plan = self.tree.plan(touches=[
            ".devops/skills/ptp-alpha/SKILL.md", ".devops/*/ptp-alpha.subagent.md",
        ])
        result = run(plan, self.root)
        self.assertEqual(result.returncode, 0, result.stderr)

    # --- R3 claim-source ----------------------------------------------------------

    def test_claim_source_forces_declaring_docs(self):
        plan = self.tree.plan(touches=[CLAIM_SOURCE])
        result = run(plan, self.root)
        self.assertEqual(result.returncode, 1, result.stdout)
        for doc in WIKI_DOCS:
            self.assertIn(doc, result.stderr)
        self.assertIn("claim-source", result.stderr)

    # --- the absence error is an ERROR, never a silent empty pass ------------------

    def test_absent_touches_is_an_error(self):
        plan = self.tree.plan(no_touches=True)
        result = run(plan, self.root)
        self.assertEqual(result.returncode, 1, result.stdout)
        self.assertEqual(result.stdout, "")
        self.assertTrue(result.stderr.startswith("write_set_check: "), result.stderr)
        self.assertIn("no `touches` field", result.stderr)

    # --- the halt paths -----------------------------------------------------------

    def test_exit_1_when_plan_missing(self):
        result = run(self.root / ".devops" / "plans" / "absent-plan.md", self.root)
        self.assertEqual(result.returncode, 1)
        self.assertTrue(result.stderr.startswith("write_set_check: "), result.stderr)
        self.assertEqual(result.stdout, "")

    def test_exit_1_when_root_is_not_a_directory(self):
        plan = self.tree.plan(touches=[".opencode/plans/base-context.md", *AGENT_PATHS])
        result = run(plan, self.root / "missing")
        self.assertEqual(result.returncode, 1)
        self.assertIn("--root is not a directory", result.stderr)
        self.assertEqual(result.stdout, "")

    def test_exit_1_when_plan_has_no_front_matter(self):
        plan = self.tree.plans / "broken-plan.md"
        plan.write_text("# no front matter here\n", encoding="utf-8")
        result = run(plan, self.root)
        self.assertEqual(result.returncode, 1)
        self.assertTrue(result.stderr.startswith("write_set_check: "), result.stderr)
        self.assertIn("no front-matter block", result.stderr)
        self.assertEqual(result.stdout, "")


if __name__ == "__main__":
    unittest.main(verbosity=2)
