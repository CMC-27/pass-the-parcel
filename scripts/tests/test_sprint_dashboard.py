#!/usr/bin/env python3
"""Fixture tests for scripts/sprint_dashboard.py - the sprint queue dashboard.

One test method per pinned acceptance criterion (plan Phase 4: AC 1-13),
driving the REAL CLI where the CLI owns the behaviour and reading the real
repo files for the two adoption pins (AC 12/13). Pattern: temp .devops trees
(the test_sprint_eligible.py Tree idiom) - one-shot subprocesses only, never a
watch mode (plan-lifecycle § Gate Invocation Hygiene).

Run: python scripts/tests/test_sprint_dashboard.py
"""

import json
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
SCRIPT = REPO_ROOT / "scripts" / "sprint_dashboard.py"
ACTIVE = "\U0001F7E2 ACTIVE"
TOP_KEYS = ["schema", "sprint", "rows", "rails", "state"]
ROW_FIELDS = ["code", "order", "title", "size", "state", "marker", "blocked_reason"]
STATE_TOKENS = {"complete", "awaiting_gate_d", "running", "blocked",
                "waiting_on_your_call", "queued", "missing"}

SPRINT_MD = """---
type: "sprint"
sprint: {no}
name: "{name}"
slug: "{slug}"
status: "{status}"
---

# Sprint {no}: {name}

## Goal
{goal}

## Committed Scope (queue)
{scope}
"""

# The REAL template-v5 row shape: six columns, `M (3)` size cells - verbatim
# shape, seed values changed only in the quote marks (R1/E1: fixtures seed the
# real row, never the plan's prose).
SCOPE_V5 = """| # | Code | Plan | Size | Source tier | Link |
|---|------|------|------|-------------|------|
{rows}"""

ROW_V5 = "| {n} | {code} | {title} | {size} | {tier} | [{file}]({file}.md) |"

EMPTY_SCOPE = """| # | Code | Plan | Size | Source tier | Link |
|---|------|------|------|-------------|------|"""

SPRINTS_INDEX = """---
type: "sprint-index"
---
# Sprints

| # | Sprint | Goal | Status | Link | Notes |
|---|---|---|---|---|---|
{rows}
"""

SINDEX = "| {n} | {slug} | {goal} | {status} | [sprint.md](../sprints/{slug}/sprint.md) | - |"

PLAN = """---
code: {code}
sprint: {sprint}
claim_status: {claim}
owner: fixture
claimed_at: "2026-09-30"
last_touch: "2026-09-30"
touches: [{touches}]
depends_on: [{depends}]
triage: {triage}
---
# Parcel Plan: {code}

{settings}
## 9 Phase 9: Verify Changes

## 📍 State & Gates

| Metric | Value |
|---|---|
| **Status** | `{status}` |
| **Version** | `v0.1.0` |
"""

SETTINGS = """
## ⚙️ Plan Settings (FROZEN)

| Setting | Value | Meaning |
|---|---|---|
| **Mode** | `{mode}` | mode |
| **Agents** | `SINGLE` | topology |
"""


class Tree:
    """A throwaway .devops/ tree: register, sprint folder, plans, archive."""

    def __init__(self, base: Path):
        self.root = base

    def write(self, rel: str, text: str):
        p = self.root / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(text, encoding="utf-8")
        return p

    def add_register(self, entries):
        """entries = [(slug, active, closed, no)] over SPRINTS.md."""
        rows = [SINDEX.format(n=no, slug=slug, goal="fixture sprint",
                              status=(ACTIVE if active else (CLOSED_REG if closed else "—")))
                for (slug, active, closed, no) in entries]
        self.write(".devops/backlog/SPRINTS.md", SPRINTS_INDEX.format(rows="\n".join(rows)))

    def add_sprint(self, slug="sprint-1-fixture", no=1, name="Fixture", status="open",
                   goal="fixture sprint", rows="", raw_scope=None):
        scope = raw_scope if raw_scope is not None else (
            EMPTY_SCOPE if not rows else SCOPE_V5.format(rows=rows))
        self.write(f".devops/sprints/{slug}/sprint.md",
                   SPRINT_MD.format(no=no, name=name, slug=slug, status=status,
                                    goal=goal, scope=scope))

    def add_plan(self, code, sprint="sprint-1-fixture", claim="QUEUED",
                 status="PHASE_1", touches='"src/a/**"', depends="", triage="SINGLE",
                 settings=True, where="sprint", slug="sprint-1-fixture"):
        folder = ".devops/plans" if where == "plans" else f".devops/sprints/{slug}"
        self.write(f"{folder}/{code.lower()}-fixture-plan.md",
                   PLAN.format(code=code, sprint=sprint, claim=claim, status=status,
                               touches=touches, depends=depends, triage=triage,
                               settings=SETTINGS.format(mode="USER-MANAGED") if settings else ""))

    def add_archive(self, code):
        self.write(f".devops/archive/{code.lower()}-fixture-plan.md",
                   PLAN.format(code=code, sprint="sprint-1-fixture", claim="COMPLETE",
                               status="PHASE_9", touches='"src/a/**"', depends="",
                               triage="SINGLE", settings=""))

    def close_sprint(self, slug, with_tests=False):
        self.write(f".devops/archive/sprints/{slug}/sprint.md", SPRINT_MD.format(
            no=1, name="Fixture", slug=slug, status="closed", goal="fixture",
            scope=EMPTY_SCOPE))
        if with_tests:
            self.write(f".devops/archive/sprints/{slug}/user-testing.md", "# tests\n")

    def run(self, *args):
        proc = subprocess.run(
            [sys.executable, str(SCRIPT), "--root", str(self.root), *args],
            capture_output=True, text=True, encoding="utf-8", timeout=60)
        return proc


def CLOSED_REG():
    return "✅ CLOSED"


# Fake the sequence literal SINDEX needs when a row is neither ACTIVE nor closed.
SINDEX_TBD = "| {n} | {slug} | fixture sprint | - | [sprint.md](../sprints/{slug}/sprint.md) | - |"


def row(code, title="livré", size="M (3)", tier="🔴 NOW", n=1, file=None):
    """One verbatim template-v5 row (six columns, `M (3)` tolerated)."""
    return ROW_V5.format(n=n, code=code, title=title, size=size, tier=tier,
                         file=(file or code.lower()))


class Dashboard(unittest.TestCase):
    """AC 1-13: one method per pinned criterion."""

    def tree(self):
        t = Tree(Path(tempfile.mkdtemp(prefix="dash-fixture-")))
        self.addCleanup(lambda: shutil.rmtree(t.root, ignore_errors=True))
        return t

    def out(self, t, *args):
        p = t.run(*args)
        return p

    # AC 1 — rows in table order, badges live, one marker (or none)
    def test_01_rows_order_and_marker(self):
        t = self.tree()
        t.add_register([("sprint-1-fixture", True, False, 1)])
        t.add_sprint(rows="\n".join([row("T1-E1.05", n=1),
                                     row("T1-E2.11", "red trunk", "M (4)", "🟠 NEXT", 2),
                                     row("T1-E5.03", "record lever", "S (1)", "🟠 NEXT", 3)]))
        t.add_archive("T1-E1.05")
        t.add_archive("T1-E2.11")
        t.add_plan("T1-E5.03", where="sprint", claim="QUEUED", status="PHASE_1")
        p = self.out(t)
        self.assertEqual(p.returncode, 0, p.stderr)
        body = p.stdout
        self.assertIn("T1-E1.05", body)
        self.assertIn("T1-E2.11", body)
        self.assertIn("T1-E5.03", body)
        self.assertLess(body.index("T1-E1.05"), body.index("T1-E2.11"))
        self.assertLess(body.index("T1-E2.11"), body.index("T1-E5.03"))
        self.assertIn("you are here", body)
        self.assertEqual(body.count("you are here"), 1)
        # complete-only variant: no marker at all (W2)
        t.add_plan("T1-E5.03", where="sprint", claim="QUEUED", status="PHASE_1")
        t.add_archive("T1-E5.03")
        p = self.out(t)
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertNotIn("you are here", p.stdout)

    # AC 2 — --json: exact top keys, exact row fields, schema, state tokens
    def test_02_json_mode_shape(self):
        t = self.tree()
        t.add_register([("sprint-1-fixture", True, False, 1)])
        t.add_sprint(rows=row("T1-E1.05"))
        t.add_archive("T1-E1.05")
        p = self.out(t, "--json")
        self.assertEqual(p.returncode, 0, p.stderr)
        data = json.loads(p.stdout)
        self.assertEqual(sorted(data.keys()), sorted(TOP_KEYS))
        self.assertEqual(data["schema"], "sprint-dashboard/1")
        self.assertEqual(data["sprint"], "sprint-1-fixture")
        self.assertTrue(data["rows"])
        for r in data["rows"]:
            self.assertEqual(sorted(r.keys()), sorted(ROW_FIELDS))
            self.assertIn(r["state"], STATE_TOKENS)
            self.assertIsInstance(r["marker"], bool)
        self.assertEqual(data["rails"][0]["rail"], "sprint start")
        self.assertIn(data["rails"][0]["phase"], {"done", "current", "pending"})
        self.assertIn("kind", data["state"])

    # AC 3 — blocked row from compute()'s skipped[], live reason
    def test_03_blocked_live_reason(self):
        t = self.tree()
        t.add_register([("sprint-1-fixture", True, False, 1)])
        t.add_sprint(rows=row("T1-E1.05", n=1))
        t.add_plan("T1-E1.05", where="sprint", claim="QUEUED", status="PHASE_1",
                   depends='"T1-E9.99"')
        p = self.out(t)
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertIn("blocked", p.stdout)
        self.assertIn("T1-E9.99", p.stdout)  # the raw reason rides the text line
        self.assertIn("unmet dependency", p.stdout)  # plain translation (R2)
        data = json.loads(self.out(t, "--json").stdout)
        self.assertEqual(data["rows"][0]["state"], "blocked")
        self.assertIn("depends_on", data["rows"][0]["blocked_reason"])

    # AC 4 — stateless rerun reflects the tree's mutation
    def test_04_rerun_reflects_mutation(self):
        t = self.tree()
        t.add_register([("sprint-1-fixture", True, False, 1)])
        t.add_sprint(rows=row("T1-E1.05", n=1))
        plan_path = t.write(".devops/plans/t1-e1.05-fixture-plan.md",
                            PLAN.format(code="T1-E1.05", sprint="sprint-1-fixture",
                                        claim="CLAIMED", status="PHASE_1",
                                        touches='"src/a/**"', depends="", triage="SINGLE",
                                        settings=""))
        first = json.loads(self.out(t, "--json").stdout)
        self.assertEqual(first["rows"][0]["state"], "running")
        plan_path.write_text(PLAN.format(code="T1-E1.05", sprint="sprint-1-fixture",
                                         claim="GATE_D_USER_APPROVAL", status="PHASE_9",
                                         touches='"src/a/**"', depends="", triage="SINGLE",
                                         settings=""), encoding="utf-8")
        second = json.loads(self.out(t, "--json").stdout)
        self.assertEqual(second["rows"][0]["state"], "awaiting_gate_d")

    # AC 5 — no ACTIVE row: named one-liner, exit 0
    def test_05_no_active_sprint_degrades(self):
        t = self.tree()
        t.add_register([("sprint-1-old", False, True, 1)])
        p = self.out(t)
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertIn("no ACTIVE sprint", p.stdout)
        self.assertIn("@sprint-plan", p.stdout)
        data = json.loads(self.out(t, "--json").stdout)
        self.assertEqual(data["state"]["kind"], "no_active_sprint")
        self.assertEqual(data["rows"], [])

    # AC 6 — two ACTIVE rows: named one-liner that asks, exit 0
    def test_06_two_active_rows_named(self):
        t = self.tree()
        t.add_register([("sprint-1-a", True, False, 1), ("sprint-2-b", True, False, 2)])
        p = self.out(t)
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertIn("two ACTIVE sprints", p.stdout)
        self.assertIn("which one is real", p.stdout)

    # AC 7 — empty queue: header + rails only; no false "did not parse"
    def test_07_empty_queue_degrades(self):
        t = self.tree()
        t.add_register([("sprint-1-fixture", True, False, 1)])
        t.add_sprint(rows="")
        p = self.out(t)
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertIn("Sprint 1: Fixture", p.stdout)
        self.assertIn("sprint start", p.stdout)
        self.assertIn("user testing", p.stdout)
        self.assertIn("sprint close", p.stdout)
        self.assertIn("current", p.stdout)   # sprint start on the ACTIVE sprint
        self.assertNotIn("did not parse", p.stdout)
        data = json.loads(self.out(t, "--json").stdout)
        self.assertEqual(data["rows"], [])
        self.assertEqual(data["state"]["kind"], "empty_queue")
        # the close-sequence ladders, via the two reachable states (plan A1/F2):
        # mid-close: frontmatter closed, register still ACTIVE, no archive copy
        t.add_sprint(rows="", status="closed")
        data = json.loads(self.out(t, "--json").stdout)
        phases = {r["rail"]: r["phase"] for r in data["rails"]}
        self.assertEqual(phases["sprint close"], "current")   # frontmatter↔register gap
        self.assertEqual(phases["user testing"], "pending")  # nothing archived yet
        # archived: copy exists -> user testing + sprint close land done;
        # sprint start stays `current` because the register row is still the
        # ACTIVE one — the row's flip ends the viewport (honest ladder)
        t.close_sprint("sprint-1-fixture", with_tests=True)
        data = json.loads(self.out(t, "--json").stdout)
        phases = {r["rail"]: r["phase"] for r in data["rails"]}
        self.assertEqual(phases["user testing"], "done")
        self.assertEqual(phases["sprint close"], "done")
        self.assertEqual(phases["sprint start"], "current")

    # AC 8 — multi_worthy queued row: waiting on your call, derived live (Q3)
    def test_08_deferred_live_state(self):
        t = self.tree()
        t.add_register([("sprint-1-fixture", True, False, 1)])
        t.add_sprint(rows=row("T1-E1.06", "subagent surface", "L (8)", "🔴 NOW", 1))
        t.add_plan("T1-E1.06", where="sprint", claim="QUEUED", status="PHASE_1",
                   triage="MULTI", touches='"scripts/x/**", "scripts/y/**",'
                                          ' "src/a/**", "src/b/**"')
        p = self.out(t)
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertIn("waiting on your call", p.stdout)
        data = json.loads(self.out(t, "--json").stdout)
        self.assertEqual(data["rows"][0]["state"], "waiting_on_your_call")

    # AC 9 — claim_status authoritative; COMPLETE-in-place; contradiction named
    def test_09_claim_status_is_authoritative(self):
        t = self.tree()
        t.add_register([("sprint-1-fixture", True, False, 1)])
        t.add_sprint(rows=row("T1-E1.05", n=1))
        # COMPLETE-in-place: claim COMPLETE in .devops/plans, body PHASE_9
        t.add_plan("T1-E1.05", where="plans", claim="COMPLETE", status="PHASE_9")
        p = self.out(t)
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertIn("complete", p.stdout)
        self.assertIn("wrap-up done, archive move pending", p.stdout)
        # contradiction: GATE_D claim with a PHASE_1 body - named, not reconciled
        t.write(".devops/plans/t1-e1.05-fixture-plan.md",
                PLAN.format(code="T1-E1.05", sprint="sprint-1-fixture",
                            claim="GATE_D_USER_APPROVAL", status="PHASE_1",
                            touches='"src/a/**"', depends="", triage="SINGLE", settings=""))
        p = self.out(t)
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertIn("claim_status contradicts body Status", p.stdout)
        data = json.loads(self.out(t, "--json").stdout)
        self.assertEqual(data["rows"][0]["state"], "awaiting_gate_d")  # claim wins

    # AC 10 — zero parsed rows from a non-empty file: named, never "empty queue"
    def test_10_empty_scope_table_named(self):
        t = self.tree()
        t.add_register([("sprint-1-fixture", True, False, 1)])
        t.add_sprint(raw_scope="| Only a hand-mangled line here. | No table. |\n")
        p = self.out(t)
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertIn("could not be parsed", p.stdout)
        self.assertNotIn("empty queue", p.stdout.lower().replace("empty-queue", "empty queue"))
        data = json.loads(self.out(t, "--json").stdout)
        self.assertEqual(data["state"]["kind"], "zero_scope_table")

    # AC 11 — table code with no plan anywhere: MISSING row
    def test_11_missing_code_rendered(self):
        t = self.tree()
        t.add_register([("sprint-1-fixture", True, False, 1)])
        t.add_sprint(rows=row("T1-E7.01", n=1))
        p = self.out(t)
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertIn("missing", p.stdout)
        data = json.loads(self.out(t, "--json").stdout)
        self.assertEqual(data["rows"][0]["state"], "missing")

    # AC 12 — sprint-run prints the dashboard at every transition + your move
    def test_12_sprint_run_cadence_recorded(self):
        skill = (REPO_ROOT / ".devops" / "skills" / "sprint-run" / "SKILL.md").read_text(encoding="utf-8-sig")
        self.assertIn("sprint_dashboard.py", skill)
        self.assertIn("print the dashboard", skill)
        self.assertIn("your move", skill)
        self.assertIn("stranded", skill)
        self.assertIn("version: 17", skill)
        self.assertIn("updated: 2026-09-30", skill)
        agent = (REPO_ROOT / ".devops" / "agents" / "parcel-sprint.agent.md").read_text(encoding="utf-8-sig")
        self.assertIn("sprint_dashboard.py", agent)

    # AC 13 — sprint-status § 4 adopts the same shape; frontmatter bumped
    def test_13_sprint_status_adopts(self):
        skill = (REPO_ROOT / ".devops" / "skills" / "sprint-status" / "SKILL.md").read_text(encoding="utf-8-sig")
        self.assertIn("sprint_dashboard.py", skill)
        self.assertIn("version: 5", skill)
        self.assertIn("updated: 2026-09-30", skill)
        # the machine home is the script + fixture, not the skill prose:
        self.assertIn("example", skill.lower())


if __name__ == "__main__":
    unittest.main()
