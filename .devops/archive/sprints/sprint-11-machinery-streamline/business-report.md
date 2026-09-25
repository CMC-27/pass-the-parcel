# Sprint 11 (Machinery Streamline): Business Report

## What this sprint set out to do

Make the toolkit this product is built on **honest and portable**: one dependable version number, guardrails that actually run everywhere the toolkit is copied to, a lightweight path for small fixes, and a few promises that were previously only written down now genuinely kept.

## What was delivered

**A version number you can trust.** The toolkit's release identity used to be a plain counter that could be quietly rolled backwards when two copies met — one site had a copy six releases ahead, with no record of how it got there. It is now a proper tiered version that knows *which direction* the difference runs: a copy that is behind is offered the upgrade, a copy that is ahead stops and asks for a person rather than being overwritten. The automated consistency check was also tightened so that one release number can no longer be mistaken for a longer one that merely starts with the same digits.

**Guardrails that travel.** The automated quality checks used to run only inside the original toolkit — anything copied from it got no protection, so the safety net was a local habit rather than a guarantee. There is now a single self-contained check file that drops into every installation and runs the core quality checks on every change, with no wiring, no accounts and no credentials to configure.

**Choose what you install.** A new installation used to receive the entire library of 34 working procedures whether or not it needed them. It can now declare "core only" and receive the 18 that actually carry the work, while everything that protects quality still travels in full. Installations that change nothing are unaffected.

**A lightweight path for small changes.** Historically every change — however small — had to go through the same heavyweight planning process, so small fixes either paid a large cost or drifted outside the process altogether. There is now a sanctioned light path that keeps a written record without the overhead.

**Records that say it once.** The change log used to repeat the reasoning that already lived in the plan, in a third place. It is now a one-line-per-change index, and the reasoning is written once, where it belongs — so the history stays cheap to read.

**Promises now kept.** Three smaller commitments that had been written down but not enforced: every planned change must record the user story it serves (or record why there is none); an unattended run must ask before overriding a decision the owner had recorded; and the sprint's forward plan no longer presents a hand-made guess as a schedule — it records a labelled snapshot of what the planning tool actually computed.

## Wins

1. **A copy of the toolkit can no longer silently corrupt its own version history** — the single most likely cause of future confusion between installations.
2. **The quality net now reaches every installation automatically**, so the advertised protection is real rather than situational.
3. **New installations start lighter** — roughly half the working procedures, with nothing lost that carries the pipeline.
4. **Small fixes have a legitimate route**, which should reduce the number of changes made outside the process.

## Quality

Eight planned work items delivered out of eight committed — **100% of the sprint's agreed capacity (30 points of 30)**. The full deterministic check set passed green at close: zero documentation errors, zero stale references, zero encoding problems across 182 files, and every automated fixture suite passing (67 checks, up from 62). Every check runs against the committed code, not a draft.

All eight delivered outcomes were put through the sprint's acceptance check and **all eight passed**. That check was carried out by the team rather than hand-run by you — a delegation you made at close, and one recorded as such in the testing record rather than presented as your own sign-off.

## Open items for the owner

| # | Item | What it needs from you |
|---|------|------------------------|
| 1 | **Publish the follow-up version step** — the version format changed in two stages to protect installations mid-update; the second stage is a one-line switch, deliberately not yet flipped | Decide when to flip it (safe once the current release is out) |
| 2 | **The release-labelling tool** still writes the old-style version label | A small reconciliation; worth doing alongside item 1 |
| 3 | **A filed concern about copies bumping a number they do not own** — the report that prompted it arrived during this sprint and is filed, not yet built | Confirm priority for the next cycle |
| 4 | **Two internal help pages** still describe the old "install everything" behaviour | A short correction; no decision needed |
| 5 | **One large internal script** grew by roughly a third this sprint and now sits close to the size at which it should be split | Note for the next cycle — not urgent, but the margin is thin |
| 6 | **The practitioner pull from the live site** remains your call and was deliberately left until after this sprint's version work landed | Re-measure and pull when ready |

## What's next

The sprint is closed and its record, retrospective, this report and the acceptance walk are archived together. The next planning cycle can draw on the carried-forward items above, and on this sprint's calibration figure — **100% capacity accuracy** — when sizing its commitments.
