---
name: skill-creator
description: Create and iterate on Agent Skills with proper structure, frontmatter, and progressive disclosure. Make sure to use this skill whenever the user asks to build a new skill, create an agentic instruction, generate a SKILL.md, or automate a workflow into a reusable package, even if they don't explicitly use the word "skill".
---

# Skill Creator

## 1. Capture Intent
Start by understanding the user's exact intent. The current conversation might already contain a workflow the user wants to capture (e.g., they say "turn this into a skill"). If so, extract answers from the conversation history first:
* **Workflow Elements:** Identify the tools used, the sequence of steps, corrections the user made, and input/output formats observed.
* **Environment & Scope:** Determine the target context (e.g., Firebase edge functions, Supabase RLS policies, or Cursor IDE environments) and whether the skill is global or isolated to a specific project boundary (e.g., AuraDocs or Energise).
* **Test Cases:** Skills with objectively verifiable outputs (code generation, data extraction, file transforms) benefit from test cases. Skills with subjective outputs often don't need them. Suggest the appropriate default, but let the user decide.

## 2. Interview and Research
Proactively ask questions about edge cases, input/output formats, example files, and success criteria. 
* **Reduce User Burden:** Check available MCPs or workspace configurations before asking. Come prepared with context. Do not ask questions you can answer by reading the workspace.
* **Context Gathering:** If useful for research (searching docs, finding similar skills, looking up best practices), research in parallel via subagents if available, otherwise inline. Wait to write test prompts until you've got this part ironed out.

## 3. Write the SKILL.md
Draft the skill using standard architecture. Include only files directly required for skill execution: the `SKILL.md` plus `scripts/`, `references/`, or `assets/` as needed. Keep the core `SKILL.md` focused on the decision framework and execution patterns (ideally under 150 lines), utilizing progressive disclosure for complex material.

### Frontmatter Rules
Include a YAML frontmatter block. The frontmatter requires only two fields:
* `name`: A unique identifier for the skill (lowercase, hyphens for spaces).
* `description`: The primary triggering mechanism. This must include both what the skill does AND specific contexts for when to use it. Make the skill descriptions intentionally **"pushy"** to combat under-triggering (e.g., instead of "How to build dashboards," write "Make sure to use this skill whenever the user mentions dashboards, data visualization, or wants to display metrics...").

### Body Content Rules
* **Imperative Tone:** Issue direct instructions ("Extract the data") rather than educational explanations ("Extracting data is important because..."). Assume the agent reading the skill is as smart as you are.
* **Positive Framing:** State what *to* do ("Include only essential files") rather than what *not* to do ("Do NOT include extraneous documentation like READMEs").
* **Strategic over Procedural:** Describe the specific goal and let the agent determine the exact approach, rather than micro-managing concepts the agent already understands.

## 4. Finalization
Present the drafted skill to the user. Confirm if the trigger description effectively captures their intended use cases and if the execution steps properly reflect the standard operating procedure. Upon approval, save the `SKILL.md` directly into the designated `.cursor/rules/` or global skills directory.
