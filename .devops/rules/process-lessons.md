---
title: Process & Tooling Lessons
tags: [dev, rules, process, lessons, machinery]
status: approved
owner: Wiki Owner
last-reviewed: 2026-09-17
related-to: [plan-lifecycle.md, agents-and-skills.md, ../skills/knowledge-capture/SKILL.md, ../skills/knowledge-consolidation/SKILL.md]
---

# Process & Tooling Lessons

> **The exit door for machinery, process and tooling knowledge.** `.wiki/core/18-knowledge-capture.md` (KC) holds **app-domain** tribal knowledge only; a lesson about the parcel/sprint machinery, the dev toolchain, or docs tooling is captured and promoted **here** instead. KC cannot promote such entries anywhere (the wiki documents the app, not the machinery), so without this register they accumulate forever — a one-way ratchet.
>
> **Entry format:** `- **[YYYY-MM-DD] Short title** — the rule. *Do instead:* the fix (only when non-obvious).` Max 3 lines, terse and deterministic.
>
> **Maintenance:** this is a staging register, not an archive. Fold a matured rule into its owning skill or [`plan-lifecycle.md`](plan-lifecycle.md) and delete it here; review the register at **sprint close** and keep it under ~25 entries. New rules arrive by capture-time routing (`@knowledge-capture`) or promotion (`@knowledge-consolidation` Phase 6b).

---

## Parcel & Sprint Mechanics

- **[2026-09-18] Re-check `git status` after any external commit lands mid-session** — a concurrent session committed on top of this parcel's claim and swept one of its working-tree files (the manifest prune line) into an unrelated release; the content survived but the attribution did not. *Do instead:* commit narrowly (`git add` only the plan's files), and after any foreign commit re-verify each planned file is where it should be (working tree vs HEAD) before continuing.

- **[2026-09-17] Never round-trip a file through PowerShell text cmdlets** — a version bump applied as `Get-Content -Raw | Set-Content -Encoding UTF8` under PS 5.1 read BOM-less UTF-8 as ANSI and re-wrote it, mojibake-corrupting six skill files in one loop; the damage is invisible in an editor and only the byte guard saw it (`T1-E4.01`, and the guard had been rewritten one wave earlier in that same parcel). *Do instead:* edit with the file tool, or write with `[System.IO.File]::WriteAllText($p, $t, (New-Object System.Text.UTF8Encoding($false)))`, then confirm with `scripts/check-utf8-agents.ps1` — the only check that reads the bytes.

- **[2026-09-16] A stated non-negotiable is reversed as a mode, never by drift** — Phase 3's one-question-at-a-time rule (KC rule 8) charged the user one round-trip per decision; where the ask surface accepts a question *array* the whole decision surface is answerable in one sitting. *Do instead:* make it a mode (batched where the surface supports it, sequential otherwise; the final "is this all the context required?" confirm stays standalone), record the rationale here, and sweep **every** surface that restates it — the rule lived in seven live places, and a partial flip is indistinguishable from drift.

- **[2026-09-16] Verify a rule's retirement across EVERY live surface, not just the plan's declared writes** — `T1-E3.07` retired the negative `AUTO` test and grepped only the prefix + `ptp-parcel-fast`, so its "mirror gone" claim was true only of the surfaces it looked at; the same sentence survived in `pass-the-parcel/SKILL.md`, `plan-lifecycle.md` and `parcel.agent.md`. *Do instead:* grep the rule's **distinctive phrase** over the whole machinery surface (`.devops/{agents,skills,rules}`, `.opencode/plans/base-context.md` + its seed, `HOW-TO.md`) and count live copies **before** claiming retirement — and have the Gate D evidence cite the surfaces swept, not just the match count.

- **[2026-09-16] In a self-referential sprint a plan's `touches` goes stale as its siblings land** — waves 1 and 2 of Sprint 9 each found 2-4 authored files missing from the claim front-matter: surfaces named in the plan's own Constraints/steps, *plus* files that became the canonical home only **after** an earlier wave landed (E3.06 moved the AUTO clause into `plan-lifecycle.md`, which E3.07 then had to declare). *Do instead:* re-verify `touches` against the plan's body **and** against the live canonical-home convention immediately before claiming — a claim-time amendment is a protocol deviation, not a bookkeeping fix.

- **[2026-09-16] A register row reading COMPLETE is a claim, not a measurement** — `T21-E6` recorded the Firebase Node 20→22 runtime upgrade COMPLETE; six days later `firebase functions:list` reported `nodejs20` on all five functions, including the JWT bridge every authenticated query depends on. The parcel updated one of two declarations and the other one won at deploy time. *Do instead:* re-measure a deployed state from the live artefact rather than the declaration, and when two declarations exist for one setting, name the single owner instead of updating one and leaving the other to win. *(Routed from GRID-Link Sprint 8 close — portable-surface fold review T1-E2.06.)*

- **[2026-09-10] Verify a cleanup parcel's orphan premise before deleting** — a feature shipped *after* the backlog item was filed may have re-wired the "orphan" (T19-E1a's engines were re-imported by T23-E1). *Do instead:* re-grep the current import graph first; if the premise is stale the parcel is a no-op, not a deletion.

- **[2026-07-18] Conflicting Phase 3 answers must not be silently resolved** — when Q3 says "5 tests" and Q5 says "3 tests" for the same file, halt at the gate with the conflict enumerated. *Do instead:* surface both at Gate B and get explicit resolution.

- **[2026-09-13] A contract-coverage AC must name an *exported* seam** — "derived from `BriefEditForm`'s field config" was untestable (T22-E1.02) because the config is module-local. *Do instead:* pin the exact export (add it, and declare it in the file steps) or state plainly that the test is a hand-maintained snapshot that does not guard drift.

- **[2026-09-13] The `@sprint-run` batch preset silently overrules a sprint's recorded plan settings** — the batch's locked `AUTO` + `SINGLE` overwrites each plan's frozen `## ⚙️ Plan Settings` at claim time, so a sprint that ruled its bundles `USER-MANAGED` gets those gates auto-cleared regardless. *Do instead:* grep the sprint queue for `USER-MANAGED`/`MULTI` rulings and get explicit operator acceptance before firing a batch.

- **[2026-09-14] A plan whose premise has vanished is archived as resolved, never re-queued** — re-parking it `QUEUED` creates a phantom item a later `@sprint-plan` can pull and burn a parcel on. *Do instead:* archive it to `.devops/archive/` with a Completion Note and sweep the stale "still parked" claims out of the registers.

- **[2026-09-13] A parked bundle's members carry stale premises — verify each against source and schema** — HARDEN-DEADCODE found 3 of 19 members already wrong at pickup (one already fixed, one false diagnosis, one artifact gone). *Do instead:* run the Phase-1 premise check per member and record a superseded or mis-diagnosed member as a **finding with evidence**, never a silent no-op.

- **[2026-07-18] Unified refactor model** — test refactor and code refactor are one plan, one change; source-first refactors enable deeper test cleanup. Each plan declares source-refactor priority.

- **[2026-09-12] The parcel's parity constraint outranks a reviewer's structural pin** — in a zero-behaviour-change decomposition a Phase 6 fix may collide with the core constraint (T9-E9.09: the pin would have changed DOM nesting). Implement the correct structure and log the deviation + rationale for the human gate. *Companion:* `subagent` spawning is available in this runtime — MULTI's context-isolated Phases 6-7 run as independent subagents.

- **[2026-09-06] Parallel subagent execution needs an exhaustive data contract** — T22-E1's milestones list vanished because it existed in a schema one pass owned but the shared data-point contract didn't enumerate it. *Do instead:* enumerate every user-template field before partitioning files, and gate the handback with a template→schema→form coverage check.

## Docs & Tooling

- **[2026-09-17] A walker's cost is path bookkeeping, not file I/O** — profiling `wiki_lint` on a 2100-doc satellite put **48%** of runtime in `Path.resolve()` (a `GetFinalPathNameByHandle` syscall per link, per check), the `.wiki` corpus was enumerated ~6× and every doc read 4-5× per run, and the unbounded `.devops/archive|logs|plans` trees were enumerated only to be skipped per file. *Do instead:* profile before optimising a walker, then make path identity syscall-free (`os.path.normcase(os.path.abspath(p))` for anything discovered under the repo root), enumerate each root once with `os.walk` directory pruning, and read each file once per run behind a cache — the same shape applies to PowerShell, where `Get-ChildItem -Recurse` (a `FileInfo` per entry) loses to `Directory.GetFiles`/`EnumerateFiles`. Measured: `wiki_lint` 5,979 → 900 ms and the UTF-8 guard 1,206 → 615 ms, findings byte-identical.

- **[2026-08-29] Vite 500 on a view = unresolved import, usually a missing `node_modules` package** — `net::ERR_ABORTED 500` loading a `.jsx` module is not a code bug when the editor is clean. *Do instead:* check `Test-Path node_modules/<pkg>`, run `npm install`, restart the dev server (Vite caches failed resolutions).

- **[2026-08-30] PowerShell writes BOMs and mangles inline Python** — `Set-Content -Encoding UTF8` emits a BOM that breaks frontmatter parsers; `python -c "…"` inside a quoted PS string corrupts or hangs the shell. *Do instead:* write probe/migration code to a `.py` file; read wiki files with `encoding="utf-8-sig"`.

- **[2026-08-30] Bulk frontmatter rewrites silently eat formatting** — a title-backfill normalised CRLF→LF, dropped the blank line before the H1, and produced backtick-quoted YAML titles the linter never caught. *Do instead:* after any bulk doc migration, diff-audit (`git diff --ignore-cr-at-eol`), restore blank lines, and scan for BOM/mojibake.

- **[2026-07-26] Wiki anchor fragments are tied to header text, not file name** — retargeting `05-design-system.md` → `09-design-system.md` left `#5c-form-field-hygiene` pointing at a renamed slug. *Do instead:* after any path retarget, validate each anchor against the target's header slugs, or run `@wiki-lint`.

- **[2026-07-26] Wiki renumbering leaves stale agent paths** — a core-file renumbering renamed 12 files but left old paths in `.devops/agents/*.md`, breaking subagent spawns. *Do instead:* grep `.devops/agents/*.md` for doc paths after any renumbering; never retro-edit historical records in `.devops/logs/` or `.devops/archive/`.

- **[2026-09-09] Long lines are truncated on read** — `read_file` truncates at ~2000 chars with a `[truncated]` marker, so editing a line you only saw truncated writes the marker into the file. *Do instead:* append to giant-line files via a temp file + `[IO.File]::AppendAllText($target, $entry, (New-Object System.Text.UTF8Encoding($false)))`; recover with `git checkout -- <file>`.

---

## See Also
- [plan-lifecycle.md](plan-lifecycle.md) — the parcel plan lifecycle these lessons qualify
- [agents-and-skills.md](agents-and-skills.md) — agent/skill definition and sync
- [`.wiki/core/18-knowledge-capture.md`](../../.wiki/core/18-knowledge-capture.md) — the app-domain knowledge log
