---
name: communication-rules
type: rule
title: Communication Rules
tags: [language, communication, audience, writing]
status: stable
format-version: 1
owner: Wiki Owner
last-reviewed: 2026-09-29
related-to: [./README.md, ./voice-and-tone.md]
---
# Communication Rules

> How writing differs by audience and channel. Internal writing is direct and unceremonious; external writing protects information and reads professionally.

## Internal (docs, commits, changelogs, skills, agents)

- Direct, terse, no ceremony.
- Technical detail is welcome; assume the reader knows the repo.
- Changelog entries: one line per change, past tense, with the file path.

## User-facing conversation (chat, questions, gate prompts, reviews)

- Dev to product owner. The owner sets the direction and owns the vision; the dev team owns the technical and reports back in the owner's language. Practical outcomes first, implementation detail second.
- Plain words. No unexplained industry jargon. If a technical term is unavoidable, define it in one short clause and anchor it with one application-relevant example — what it does to the product in use.
- One idea per message. Short sentences. State what changes for the user, then what was done.
- Never perform expertise. No senior-to-senior shorthand.
- The PO wants to know what, where, when, and why changes are being made. Link the artefacts for reference and review.
- Questions and reports are addressed to the product owner as decision requests, not status filler — Phase 3 clarification questions included. Reports are to the point: what changed for the product, what it cost, what needs the owner's call; the technical record stays in the linked artefact. The user is the product owner, the agents are the dev team (role model: `OPERATING-PRINCIPLES.md` § The Goal).

## External (client-facing, published, public)

- Professional and plain (`.wiki/rules/language/voice-and-tone.md`).
- Never expose internal commercial or operational detail.
- Every claim is sourced or marked unknown.
- Drafts are returned for human approval — agents never send external communication unapproved.

## By Channel

| Channel | Style |
|---|---|
| Commit message | Imperative, one line, e.g. `fix: repoint check scripts to .devops/agents` |
| Changelog entry | `- <path>: <past-tense change summary>` |
| Wiki doc | Front-loaded structure with links (`.wiki/rules/document-structure.md`) |
| Skill directive | Terse, imperative, explicit paths and commands |
| Agent runbook | Third-person description + imperative steps |
| User chat | Dev to product owner, practical outcomes first (see § User-facing conversation) |

---

*Last reviewed 2026-09-29. Changes to these rules require human sign-off.*