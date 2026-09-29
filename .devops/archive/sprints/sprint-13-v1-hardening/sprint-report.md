# Sprint 13 (V1 Hardening): Business Report

## What this sprint set out to do

Make the template safe to hand to the next workspace: close every gap an independent review had found, and ship a clean, measured **v1.1.0** with every automated check green.

## What was delivered

**Start work from a known-good state.** Every claim on the template now begins from one named health check, and a failing check stops the work before it starts — there is no "start anyway" branch. A comment sitting inside a plan's list of files to touch can no longer silently hide half that list, so the pipeline always knows the true size of a change.

**Close-out you can trust.** Whether the trunk was healthy at the end of a piece of work is now measured by a checker rather than remembered by whoever ran it. It can say honestly "not verified yet — nothing has been published" instead of implying a green nobody observed, and it refuses to accept a pass that the published history cannot back up.

**Rules written once.** The instructions that appear in many places at once — how a change is reviewed, which modes exist, how work is routed — are now written in one authoritative home and referred to everywhere else. Changing one costs a single edit, and no reader can be left acting on a stale copy.

**A transport you can review.** The engine that copies this template into another workspace had quietly grown to nearly a thousand lines. It has been split into focused modules and is now roughly a third of that size, with its behaviour proven identical before and after against saved reference outputs.

**An honest knowledge base.** Pages that describe an application this template does not actually ship are now clearly labelled as templates, and the index shows that label up front — so anyone reading cold can tell seed text from verified truth.

**Readable working documents.** Plan documents have a recorded ceiling: a cell that grows unreadable is now a stated, known gap with a named upgrade path, rather than something nobody notices.

**A measured release.** v1.1.0 closes the change log and, for the first time, records what running this template actually costs — measured numbers with their sources, and an explicit "not available" wherever a figure was never supplied. Nothing is estimated.

## Wins

- **A red check now stops work before it starts**, instead of surfacing four rounds into a change.
- **"Was it green?" became a measurement**, with an honest way to say "not yet verified".
- **The largest single file in the tooling dropped from 975 to 314 lines** — the piece you depend on every sprint is reviewable again.
- **Changing a rule now costs one edit**, not a hunt through every surface that repeats it.

## Quality

Nine of nine committed pieces of work were delivered, at their committed sizes — **27 of 27 effort points, 100% of plan**, with the 3-point contingency never touched. The automated suite now holds **113 checks across 6 test files**, up from 83 at the start of the sprint, and the full gate set — lint, links, evidence, encoding, transport self-test, configuration parsing — finished the sprint **green**.

The owner's own acceptance walk covered **9 outcomes: 9 passed, 0 failed, 0 blocked**. Three were walked personally; the remaining six were executed by the agent on the owner's instruction, and the sheet records exactly which was which. Two of the new checks proved themselves live during the walk — one refused to let an unverified change be published, and only allowed it once the record was corrected.

## Open items for the owner

- **Publish and tag v1.1.0.** The release is written and all local checks pass, but the work has not been pushed to the shared repository yet, so it has not been verified by the published checks. Push first, confirm green, then create the `v1.1.0` tag and release notes — you reserved this step for yourself.
- **The green-stamp record has a known weak spot.** Sessions that run without a plan can now leave the publishing check red for everyone who follows; your ruling recorded a stamp to clear this close, and the underlying gap is handed to the next wrap-up for a proper fix.
- **No acceptance failures to act on** — every test the owner needed to experience passed.

## What's next

The sprint record and its retrospective are archived at [sprint.md](../archive/sprints/sprint-13-v1-hardening/sprint.md); the acceptance sheet sits beside it at [user-testing.md](../archive/sprints/sprint-13-v1-hardening/user-testing.md). Run `@sprint-plan` when you are ready to open the next cycle — the capacity figure to carry forward is **100%**, so the next plan's budget can be set with some confidence.
