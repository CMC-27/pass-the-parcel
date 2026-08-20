---
description: Start a new parcel plan for the given feature description. Switches to the parcel-orchestrator agent, instantiates a plan file, and begins Phases 1-3. Usage: /parcel <feature description>
agent: parcel-orchestrator
---

Start a new parcel plan: $ARGUMENTS

## Setup

1. Load the `pass-the-parcel` skill for the canonical workflow, phase table, gate semantics, and template reference.
2. Derive a kebab-case slug from the description. If a parcel with this slug already exists at `.devops/plans/[slug]-plan.md`, pick it up instead of creating.
3. **Mode Selection (mandatory, before plan instantiation).** Call the `question` tool with two options:
   - `USER-MANAGED` *(Recommended)* -- halt at every gate for explicit user approval.
   - `AUTO` -- auto-advance through gates; sub-skills auto-answer questions. Destructive actions still halt.
   Record the choice. It will be written into the plan's **State & Gates** section (bottom of the file) as `**Mode**`.
4. If creating fresh, copy the template from `.devops/plans/template-plan.md` to `.devops/plans/[slug]-plan.md`. Initialize the **State & Gates** section at the bottom: `Status: PHASE_1`, `Mode: <chosen mode>`, `Active Persona: Scoper`, `Last Updated: <now>`, `Gate A: OPEN`.
5. Confirm the slug + plan path + mode with the user before proceeding.

## Execution

6. Begin Group A by delegating Phases 1-3 to the `parcel-context-hunter` sub-agent via the Task tool. Pass: the plan file path, the current `Status`, the current `Mode`, and the user's original description.
7. **Phase 3.5 (AUTO only):** If `Mode: AUTO`, delegate Phase 3.5 to the `parcel-phase3-answerer` sub-agent via the Task tool. Pass: the plan file path. On return, read the plan and check for `Unresolvable:` entries -- if any exist, treat as a hard halt and surface to the user.
8. **Mode-aware handling at Gate A:**
   - `USER-MANAGED` -- read the plan, surface the drafted Phase 3 questions to the user via the `question` tool, write the answers into the plan, advance the **State & Gates** section (bottom) to `PHASE_3` (`Gate A: APPROVED` + timestamp), and present Gate A for approval.
   - `AUTO` -- verify `Auto-Resolution:` rows are populated, advance the **State & Gates** section (bottom) to `PHASE_3` with a `Gate A: auto-cleared at <timestamp>` note, and proceed to Group B without halting.
