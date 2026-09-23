# Sprint 10 (Owner Loop): Business Report

## What this sprint set out to do

Make the automated build process trustworthy enough to leave running on its own, and connect the loop between what gets promised, what gets built, and what you — the owner — actually check.

## What was delivered

**Reliable unattended runs.** Three fixes to the automated build process. First, a test run could previously stall the whole run with no way out; the process now runs tests in a single, non-interactive pass and names the stalling mode as the thing to avoid. Second, if a run is interrupted part-way, it now resumes from where it stopped instead of restarting or guessing. Third, a knowledge-drift check that used to be advisory now blocks completion — the project cannot be signed off while its documentation and its code disagree.

**A planning-to-review loop that involves you.** When work is planned, each item now carries a short, plain-language statement of who it is for and why. Those statements are what the acceptance criteria are written against, so the criteria describe what you asked for rather than only what was built. At the end of the cycle you are walked through the work item by item and your verdicts are recorded with the cycle's history. A plain-language report — this document — is produced for you each cycle, and the project now states plainly that you are the product owner and the agents are the delivery team.

**Improvements flowing home.** Projects that use this template can now send improvements back: an agent drafts the idea locally, you carry it across, and it lands in the backlog. Nothing is pushed automatically and nothing sensitive travels.

## Wins

1. **A stalled build can no longer block the line.** The failure that halted a live run has a fix and a documented recovery path.
2. **Interrupted work is recoverable.** A run that dies mid-way resumes cleanly; nothing is re-done and nothing is invented. This was proven for real during the sprint, not just designed.
3. **Sign-off now means something.** Documentation that has drifted from the code blocks completion instead of passing quietly.
4. **The cycle ends with your verdict, on the record.** What you tested and what you decided is kept with the cycle's history, in your own words.

## Quality

All **7 of 7** planned items were delivered — **11 of 11** planned points, a **100%** capacity result. The project's full checking suite ran clean at close: no broken documentation links, no drifted documentation, no encoding problems, and all agent configuration consistent. The sprint's 8 acceptance tests were **presented and accepted but not exercised** — you noted you cannot run them in this workspace and will report back if anything misbehaves. That is recorded honestly rather than counted as a pass, and it is the one caveat on this report's quality claim.

## Open items for the owner

1. **Report back on the 8 accepted tests** if any of them misbehaves in live use — particularly the unattended-run fixes, which are the ones that failed before.
2. **One follow-up is queued:** the new planning statements are currently a strong recommendation rather than a requirement. We can decide to enforce them, or first measure whether they are being written in practice. Your call when it comes up.
3. **Two older clean-up items remain open** in the code-quality register — both scripts that have grown larger than the agreed threshold. Neither is urgent; neither has a plan yet.

## What's next

The cycle is closed and its record is archived. The next step is to plan the following cycle: the backlog holds one queued follow-up and two standing clean-up items, and the capacity result above (100% delivered against plan) means the next cycle can be sized confidently at a similar level.

- Cycle record and retrospective: `.devops/archive/sprints/sprint-10-owner-loop/sprint.md`
- What was tested and your verdicts: `.devops/archive/sprints/sprint-10-owner-loop/user-testing.md`
