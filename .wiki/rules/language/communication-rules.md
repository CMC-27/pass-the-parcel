---
title: Communication Rules
tags: [language, communication, audience, writing]
status: approved
owner: Wiki Owner
last-reviewed: 2026-08-19
related-to: [./README.md, ./voice-and-tone.md]
---

# Communication Rules

> How writing differs by audience and channel. Internal writing is direct and unceremonious; external writing protects information and reads professionally.

## Internal (docs, commits, changelogs, skills, agents)

- Direct, terse, no ceremony.
- Technical detail is welcome; assume the reader knows the repo.
- Changelog entries: one line per change, past tense, with the file path.

## External (client-facing, published, public)

- Professional and plain (`.languagerules/voice-and-tone.md`).
- Never expose internal commercial or operational detail.
- Every claim is sourced or marked unknown.
- Drafts are returned for human approval — agents never send external communication unapproved.

## By Channel

| Channel | Style |
|---|---|
| Commit message | Imperative, one line, e.g. `fix: repoint check scripts to .devops/agents` |
| Changelog entry | `- <path>: <past-tense change summary>` |
| Wiki doc | Front-loaded structure with links (`.wikirules/document-structure.md`) |
| Skill directive | Terse, imperative, explicit paths and commands |
| Agent runbook | Third-person description + imperative steps |

---

*Last reviewed 2026-08-19. Changes to these rules require human sign-off.*