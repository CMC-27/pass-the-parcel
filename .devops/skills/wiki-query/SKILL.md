---
name: wiki-query
description: "Use when asking a question about the codebase, looking up a concept, or synthesizing an answer from the wiki + ref/ docs. Triggers: 'what do I know about X', 'look up Y', 'find in wiki', 'search docs', 'wiki says'. Read-only — defers writing to knowledge-capture."
version: 1
updated: 2026-09-03
---

# Wiki Query Skill

## Goal
Answer questions by synthesising the contents of `.wiki/` (including `ref/`). Cite every claim with `[Title](path)` so the user can verify. Never write to disk. If the answer should be persisted, point the user to the `knowledge-capture` skill.

## Workflow

### 1. Build the Index Map
- Read `.wiki/core/00-system-index.md` to enumerate all wiki docs with summaries.
- Read `.wiki/ref/ref-index.md` to enumerate all reference docs with topics.
- Together these form the candidate pool for the question.

### 2. Match Question to Candidates
- Identify keywords in the question (e.g. "banker's rounding", "NZS 3910", "price breakdown").
- Grep the wiki for those keywords to find candidate docs.
- For topic-keyword matches, prefer `ref/` docs (e.g. tag writing → `REF-Tag-Schedule.md`).

### 3. Read & Synthesise
- Read the top 3-7 most relevant candidates (1-2 from `ref/` if topic-matched, rest from main wiki).
- If after reading the top 7 candidates **NO doc covers the question**, output exactly:
  > "No relevant docs found in the wiki. The question may be out-of-scope, or you may want to add knowledge via the knowledge-capture skill first."
  Do **NOT** fabricate an answer from training data when no source is found.
- Otherwise synthesise a chat answer with `[Title](relative-path)` inline citations.

### 4. Cite Format
In-conversation citations use project-root-relative paths:
- `[Article Title](.wiki/core/18-knowledge-capture.md)`
- `[Tag Schedule](.wiki/ref/REF-Tag-Schedule.md)`

Within a citation list at the bottom of the answer, prefer the same project-root-relative form.

### 5. End With Persistence Pointer
Always close the response with:
> "Want to persist this insight as a knowledge-capture decision? Use the `@knowledge-capture` skill to add an entry."

This is a pointer, not an action. The user decides whether to write.

### 6. Out-of-Scope Behaviour
- **Code questions** (e.g. "what does `handleClick` do?") — out of scope. Point to `grep` / codebase exploration, not the wiki.
- **Recent changes** (e.g. "what changed in the last deploy?") — out of scope. Point to `.devops/logs/agent-changelog.md`.
- **Knowledge operations** (e.g. "add this to the wiki") — out of scope. Point to `@knowledge-capture` or `@wiki-lint` skills.

## Usage Guidelines
- **Read-only by design.** This skill never writes to disk. If you find yourself wanting to save the answer, that's a separate skill (`@knowledge-capture`).
- **Prefer the wiki over training data.** When a doc covers the question, cite it. Do not answer from memory when a source is available.
- **Be honest about gaps.** "No relevant docs found" is a valid, useful answer.
