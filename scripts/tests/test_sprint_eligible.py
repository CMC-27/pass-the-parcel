#!/usr/bin/env python3
"""Fixture tests for scripts/sprint_eligible.py - the batch eligibility predicate.

The predicate's definition is canonical in .devops/rules/plan-lifecycle.md
(section Claim Front-Matter + section Claim Protocol -> *Write-Set Overlap
Predicate*); this suite pins the script that embodies it. Each case drives the
REAL CLI (subprocess + exit code + parsed JSON), because the exit code and stdout
shape are the contract @sprint-run consumes.

T1-E3.11 adds the segment-wise glob matcher (the mid-path-wildcard ceiling is
closed) and the advisory "lanes" classification (Reserved Surface Set + the
prefix-embed cascade).

Run: python scripts/tests/test_sprint_eligible.py
"""

import json
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
SCRIPT = REPO_ROOT / "scripts" / "sprint_eligible.py"
SPRINT = "sprint-1-fixture"
ACTIVE = "\U0001F7E2 ACTIVE"

PLAN_TEMPLATE = """---
code: {code}
sprint: {sprint}
claim_status: {claim}
owner: fixture
claimed_at: "2026-09-16"
last_touch: "2026-09-16"
touches: [{touches}]
depends_on: [{depends}]
triage: {triage}
---
# {code}

## 9 Phase 9: Verify Changes

## State & Gates

| Metric | Value |
|---|---|
| **Status** | `{status}` |
| **Version** | `v0.1.0` |
"""

SPRINTS_TEMPLATE = """---
type: "sprint"
---
# Sprint Index

| # | Sprint | Goal | Status | Link | Notes |
|---|---|---|---|---|---|
| 1 | Fixture | fixture sprint | {active} | [sprint.md](../sprints/{sprint}/sprint.md) | - |
"""


class Tree:
    """A throwaway .devops/ tree: one sprint queue, the claimed set, the archive."""

    def __init__(self, base: Path, active: bool = True):
        self.root = base
        self.sprint_dir = base / ".devops" / "sprints" / SPRINT
        self.plans_dir = base / ".devops" / "plans"
        self.archive_dir = base / ".devops" / "archive"
        self.backlog_dir = base / ".devops" / "backlog"
        for folder in (self.sprint_dir, self.plans_dir, self.archive_dir, self.backlog_dir):
            folder.mkdir(parents=True, exist_ok=True)
        (self.sprint_dir / "sprint.md").write_text("# Fixture sprint\n", encoding="utf-8")
        self.backlog_dir.joinpath("SPRINTS.md").write_text(
            SPRINTS_TEMPLATE.format(active=ACTIVE if active else "LATER", sprint=SPRINT),
            encoding="utf-8",
        )

    def plan(self, folder: Path, code: str, claim="QUEUED", status="QUEUED",
             touches=(), depends=(), with_code=True, triage=""):
        body = PLAN_TEMPLATE.format(
            code=code if with_code else "",
            sprint=SPRINT,
            claim=claim,
            status=status,
            touches=", ".join(json.dumps(t) for t in touches),
            depends=", ".join(json.dumps(d) for d in depends),
            triage=triage,
        )
        if not with_code:
            body = body.replace("code: \n", "")
        if not triage:
            body = body.replace("triage: \n", "")
        path = folder / f"{code.lower()}-fixture-plan.md"
        path.write_text(body, encoding="utf-8")
        return path

    def queued(self, code: str, **kw):
        kw.setdefault("claim", "QUEUED")
        kw.setdefault("status", "QUEUED")
        return self.plan(self.sprint_dir, code, **kw)

    def claimed_plan(self, code: str, claim="CLAIMED", status="PHASE_3", **kw):
        return self.plan(self.plans_dir, code, claim=claim, status=status, **kw)


def run(root, *args, cwd=None):
    return subprocess.run(
        [sys.executable, str(SCRIPT), "--root", str(root), *args],
        capture_output=True, text=True, cwd=str(cwd or REPO_ROOT),
    )


def payload(result):
    """Parsed stdout of a successful run; fails loudly when the contract broke."""
    if result.returncode != 0:
        raise AssertionError(f"expected exit 0, got {result.returncode}: {result.stderr}")
    return json.loads(result.stdout)


def skipped(payload_obj, code):
    for row in payload_obj["skipped"]:
        if row["code"] == code:
            return row["reasons"]
    raise AssertionError(f"{code} is not in the skip table")


def complexity(payload_obj, code):
    """One plan's advisory complexity entry (T1-E3.10's MULTI-worthy flag)."""
    try:
        return payload_obj["complexity"][code]
    except KeyError:
        raise AssertionError(f"{code} has no complexity entry")


class SprintEligibleTestCase(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.root = Path(self._tmp.name)
        self.tree = Tree(self.root)

    def tearDown(self):
        self._tmp.cleanup()

    # FILL:tests
    def test_dependency_chain_is_claimed_in_queue_order(self):
        self.tree.queued("T1-E1.01")
        self.tree.queued("T1-E1.02", depends=["T1-E1.01"])
        out = payload(run(self.root))
        self.assertEqual(out["eligible"], ["T1-E1.01"])
        self.assertEqual(out["claim_order"], ["T1-E1.01", "T1-E1.02"])
        self.assertEqual(out["skipped"], [])

    def test_mutual_cycle_leaves_both_skipped(self):
        self.tree.queued("T1-E1.01", depends=["T1-E1.02"])
        self.tree.queued("T1-E1.02", depends=["T1-E1.01"])
        out = payload(run(self.root))
        self.assertEqual(out["eligible"], [])
        self.assertEqual(out["claim_order"], [])
        self.assertIn("unmet depends_on: T1-E1.02", skipped(out, "T1-E1.01"))
        self.assertIn("unmet depends_on: T1-E1.01", skipped(out, "T1-E1.02"))

    def test_touches_overlap_skips_the_later_plan(self):
        self.tree.queued("T1-E1.01", touches=["scripts/foo.py"])
        self.tree.queued("T1-E1.02", touches=["scripts/foo.py"])
        out = payload(run(self.root))
        self.assertEqual(out["claim_order"], ["T1-E1.01"])
        self.assertIn("touches overlap: T1-E1.01 via scripts/foo.py", skipped(out, "T1-E1.02"))

    def test_dependency_satisfied_by_gate_d_user_approval(self):
        self.tree.claimed_plan("T1-E1.01", claim="GATE_D_USER_APPROVAL", status="PHASE_9")
        self.tree.queued("T1-E1.02", depends=["T1-E1.01"])
        out = payload(run(self.root))
        self.assertEqual(out["claim_order"], ["T1-E1.02"])
        self.assertEqual(out["already_phased"], ["T1-E1.01"])
        self.assertEqual(out["in_flight"], [])

    def test_in_flight_dependency_is_unmet(self):
        self.tree.claimed_plan("T1-E1.01", claim="CLAIMED", status="PHASE_3")
        self.tree.queued("T1-E1.02", depends=["T1-E1.01"])
        out = payload(run(self.root))
        self.assertEqual(out["claim_order"], [])
        self.assertIn("unmet depends_on: T1-E1.01", skipped(out, "T1-E1.02"))
        self.assertEqual(out["in_flight"], ["T1-E1.01"])
        self.assertEqual(out["orphans"], ["T1-E1.01"])

    def test_queued_plan_already_at_phase_9_is_skipped(self):
        self.tree.queued("T1-E1.01", status="PHASE_9")
        out = payload(run(self.root))
        self.assertEqual(out["claim_order"], [])
        self.assertEqual(skipped(out, "T1-E1.01"), ["already PHASE_9"])
        self.assertEqual(out["already_phased"], ["T1-E1.01"])

    def test_template_plan_changes_nothing(self):
        self.tree.queued("T1-E1.01", touches=["scripts/foo.py"])
        without = payload(run(self.root))
        shutil.copy(REPO_ROOT / ".devops" / "plans" / "template-plan.md",
                    self.tree.plans_dir / "template-plan.md")
        self.assertEqual(payload(run(self.root)), without)
        self.assertEqual(without["claim_order"], ["T1-E1.01"])

    def test_archived_dependency_is_satisfied_with_or_without_code_field(self):
        self.tree.plan(self.tree.archive_dir, "T1-E1.00")
        self.tree.plan(self.tree.archive_dir, "T1-E1.01", with_code=False)
        self.tree.queued("T1-E1.02", touches=["a/x.py"], depends=["T1-E1.00"])
        self.tree.queued("T1-E1.03", touches=["b/y.py"], depends=["T1-E1.01"])
        out = payload(run(self.root))
        self.assertEqual(out["claim_order"], ["T1-E1.02", "T1-E1.03"])
        self.assertEqual(out["skipped"], [])

    def test_overlap_normalisation_ignores_case_and_trailing_glob(self):
        self.tree.queued("T1-E1.01", touches=["Scripts/Feature/**"])
        self.tree.queued("T1-E1.02", touches=["scripts/feature/module.py"])
        out = payload(run(self.root))
        self.assertEqual(out["claim_order"], ["T1-E1.01"])
        self.assertIn("touches overlap: T1-E1.01 via scripts/feature", skipped(out, "T1-E1.02"))

    def test_mid_path_wildcard_overlap_is_detected(self):
        # T1-E3.11 closed the ceiling this case used to pin: the matcher is
        # segment-wise, so `*` matches a whole segment anywhere in the path.
        self.tree.queued("T1-E1.01", touches=["src/*/db"])
        self.tree.queued("T1-E1.02", touches=["src/a/db/schema.sql"])
        out = payload(run(self.root))
        self.assertEqual(out["claim_order"], ["T1-E1.01"])
        self.assertIn("touches overlap: T1-E1.01 via src/*/db", skipped(out, "T1-E1.02"))

    def test_double_star_spans_segments(self):
        self.tree.queued("T1-E1.01", touches=["src/**/db"])
        self.tree.queued("T1-E1.02", touches=["src/a/b/db/x.sql"])
        out = payload(run(self.root))
        self.assertEqual(out["claim_order"], ["T1-E1.01"])
        self.assertIn("touches overlap: T1-E1.01 via src/**/db", skipped(out, "T1-E1.02"))

    def test_boundary_prefix_is_not_an_overlap(self):
        # The wildcard upgrade must not degrade into a substring match.
        self.tree.queued("T1-E1.01", touches=["src/a"])
        self.tree.queued("T1-E1.02", touches=["src/ab"])
        out = payload(run(self.root))
        self.assertEqual(out["claim_order"], ["T1-E1.01", "T1-E1.02"])
        self.assertEqual(out["skipped"], [])

    def test_reserved_surface_forces_the_serial_lane(self):
        self.tree.queued("T1-E1.01", touches=[".devops/sync-manifest.yaml"])
        self.tree.queued("T1-E1.02", touches=["src/util.py"])
        out = payload(run(self.root))
        self.assertEqual(out["lanes"],
                         {"T1-E1.01": "serial", "T1-E1.02": "parallel"})
        self.assertIn(".devops/sync-manifest.yaml", out["reserved_surfaces"])
        self.assertEqual(out["reserved_surfaces"], sorted(out["reserved_surfaces"]))
        # and a direct child of a reserved directory is serial too
        child = Tree(Path(self._tmp.name) / "child")
        child.queued("T1-E1.01", touches=[".devops/agents/parcel.agent.md"])
        self.assertEqual(payload(run(child.root))["lanes"], {"T1-E1.01": "serial"})

    def test_ptp_skill_embed_cascade_is_serial(self):
        # A ptp-* SKILL.md is embedded verbatim in its agent file, so editing it
        # forces a -Sync that rewrites a reserved surface.
        (self.root / ".devops" / "agents").mkdir(parents=True, exist_ok=True)
        (self.root / ".devops" / "agents" / "ptp-parcel-fast.subagent.md").write_text(
            "---\nmodel: fixture\n---\n", encoding="utf-8")
        self.tree.queued("T1-E1.01", touches=[".devops/skills/ptp-parcel-fast/SKILL.md"])
        self.tree.queued("T1-E1.02", touches=[".devops/skills/wiki-writer/SKILL.md"])
        out = payload(run(self.root))
        # wiki-writer is bound in a .agent.md, not a .subagent.md: no embed, no cascade.
        self.assertEqual(out["lanes"],
                         {"T1-E1.01": "serial", "T1-E1.02": "parallel"})
        # same plan, no embedded agent file in the tree -> lane-B eligible
        bare = Tree(Path(self._tmp.name) / "bare")
        bare.queued("T1-E1.01", touches=[".devops/skills/ptp-parcel-fast/SKILL.md"])
        self.assertEqual(payload(run(bare.root))["lanes"], {"T1-E1.01": "parallel"})

    def test_serial_lane_is_never_packed_into_a_group(self):
        self.tree.queued("T1-E1.01", touches=[".devops/logs/version-history.md"])
        self.tree.queued("T1-E1.02", touches=["src/util.py"])
        out = payload(run(self.root))
        self.assertEqual(out["parallel_groups"], [["T1-E1.02"]])

    def test_parallel_groups_pack_disjoint_plans_and_layer_dependencies(self):
        self.tree.queued("T1-E1.01", touches=["a/one.py"])
        self.tree.queued("T1-E1.02", touches=["b/two.py"])
        out = payload(run(self.root))
        self.assertEqual(out["parallel_groups"], [["T1-E1.01", "T1-E1.02"]])

        other = Tree(Path(self._tmp.name) / "layered")
        other.queued("T1-E1.01", touches=["a/one.py"])
        other.queued("T1-E1.02", touches=["b/two.py"], depends=["T1-E1.01"])
        out = payload(run(other.root))
        self.assertEqual(out["claim_order"], ["T1-E1.01", "T1-E1.02"])
        self.assertEqual(out["parallel_groups"], [["T1-E1.01"], ["T1-E1.02"]])

    def test_output_is_deterministic(self):
        self.tree.queued("T1-E1.01", touches=["a/one.py"])
        self.tree.queued("T1-E1.02", touches=["a/one.py"])
        first, second = run(self.root), run(self.root)
        self.assertEqual(first.stdout, second.stdout)

    def test_schema_keys_and_empty_queue(self):
        out = payload(run(self.root))
        self.assertEqual(out["schema"], "sprint-eligible/1")
        for key in ("schema", "root", "sprint", "sprint_dir", "queue", "eligible",
                    "claim_order", "parallel_groups", "lanes", "reserved_surfaces",
                    "skipped", "in_flight",
                    "orphans", "already_phased", "complexity", "counts"):
            self.assertIn(key, out)
        self.assertEqual(out["counts"]["queue"], 0)
        self.assertEqual(out["sprint"], SPRINT)

    # --- T1-E3.10: the MULTI-worthy triage flag (advisory "complexity" data) ---

    def test_breadth_flags_an_undeclared_plan(self):
        # No `triage` field at all: the mechanical backstop still fires.
        self.tree.queued("T1-E1.01", touches=["a/1.py", "b/2.py", "c/3.py", "d/4.py"])
        out = payload(run(self.root))
        self.assertIsNone(complexity(out, "T1-E1.01")["triage"])
        self.assertEqual(complexity(out, "T1-E1.01")["signals"], ["blast-radius"])
        self.assertTrue(complexity(out, "T1-E1.01")["multi_worthy"])

    def test_declared_multi_flags_a_one_touch_plan(self):
        self.tree.queued("T1-E1.01", touches=["a/1.py"], triage="MULTI")
        out = payload(run(self.root))
        self.assertEqual(complexity(out, "T1-E1.01")["signals"], [])
        self.assertTrue(complexity(out, "T1-E1.01")["multi_worthy"])

    def test_local_plan_is_not_flagged(self):
        # The canonical low bound is inclusive: "<= 3 files, one domain".
        self.tree.queued("T1-E1.01", touches=["a/1.py", "a/2.py", "a/3.py"],
                         triage="SINGLE")
        out = payload(run(self.root))
        self.assertEqual(complexity(out, "T1-E1.01"),
                         {"triage": "SINGLE", "signals": [],
                          "multi_worthy": False, "blocks": []})

    def test_unknown_triage_value_fails_open_to_the_backstop(self):
        self.tree.queued("T1-E1.01", triage="MAYBE",
                         touches=[f"a/{i}.py" for i in range(5)])
        out = payload(run(self.root))  # exit 0 is asserted by payload()
        self.assertEqual(complexity(out, "T1-E1.01")["triage"], "MAYBE")
        self.assertTrue(complexity(out, "T1-E1.01")["multi_worthy"])

    def test_blocks_lists_still_queued_dependents(self):
        self.tree.queued("T1-E1.01", touches=["a/1.py", "b/2.py", "c/3.py", "d/4.py"])
        self.tree.queued("T1-E1.02", touches=["e/5.py"], depends=["T1-E1.01"])
        self.tree.queued("T1-E1.03", touches=["f/6.py"], depends=["T1-E1.02"])
        self.tree.queued("T1-E1.04", touches=["g/7.py"])
        out = payload(run(self.root))
        self.assertEqual(complexity(out, "T1-E1.01")["blocks"], ["T1-E1.02", "T1-E1.03"])
        self.assertEqual(complexity(out, "T1-E1.04")["blocks"], [])

    def test_sprint9_counterfactual_all_six_waves_are_flagged(self):
        """Proven against the over-reach it exists to catch, not a hypothetical.

        Declared `touches` counts of the six committed Sprint 9 plans (E3.06 11,
        E3.07 10, E3.08 15, E3.09 12, E3.10 10, E3.11 12). None of them carried a
        `triage` field - they predate it - so this is the mechanical backstop alone
        firing, which is exactly the sprint's failure mode (scaffold declarations).
        """
        counts = {"T1-E1.01": 11, "T1-E1.02": 10, "T1-E1.03": 15,
                  "T1-E1.04": 12, "T1-E1.05": 10, "T1-E1.06": 12}
        for code, n in counts.items():
            self.tree.queued(code, touches=[f"{code.lower()}/f{i}.md" for i in range(n)])
        out = payload(run(self.root))
        self.assertTrue(all(complexity(out, c)["multi_worthy"] for c in counts))
        self.assertEqual(out["counts"]["multi_worthy"], 6)

    def test_explicit_sprint_dir_bypasses_the_active_row(self):
        idle = Tree(Path(self._tmp.name) / "idle", active=False)
        idle.queued("T1-E1.01", touches=["a/one.py"])
        out = payload(run(idle.root, "--sprint-dir", str(idle.sprint_dir)))
        self.assertEqual(out["claim_order"], ["T1-E1.01"])

    def test_exit_1_when_no_active_sprint_row(self):
        idle = Tree(Path(self._tmp.name) / "idle", active=False)
        result = run(idle.root)
        self.assertEqual(result.returncode, 1)
        self.assertIn("no ACTIVE sprint row", result.stderr)
        self.assertEqual(result.stdout, "")

    def test_exit_1_when_root_is_not_a_directory(self):
        result = run(Path(self._tmp.name) / "missing")
        self.assertEqual(result.returncode, 1)
        self.assertIn("--root is not a directory", result.stderr)
        self.assertEqual(result.stdout, "")

    def test_exit_1_when_plan_has_no_front_matter(self):
        (self.tree.sprint_dir / "t1-e1.99-broken-plan.md").write_text(
            "# no front matter here\n", encoding="utf-8")
        result = run(self.root)
        self.assertEqual(result.returncode, 1)
        self.assertIn("plan file has no front-matter block", result.stderr)
        self.assertEqual(result.stdout, "")

    def test_exit_1_when_shared_reader_import_fails(self):
        solo = Path(self._tmp.name) / "solo"
        solo.mkdir()
        shutil.copy(SCRIPT, solo / "sprint_eligible.py")
        result = subprocess.run(
            [sys.executable, str(solo / "sprint_eligible.py"), "--root", str(self.root)],
            capture_output=True, text=True, cwd=str(solo),
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn("shared reader import failed", result.stderr)
        self.assertEqual(result.stdout, "")


if __name__ == "__main__":
    unittest.main(verbosity=2)

