---
title: AI Rules
tags: [language, ai, guardrails, writing]
status: approved
owner: Wiki Owner
last-reviewed: 2026-08-19
related-to: [./README.md, ./voice-and-tone.md, ../.wikirules/README.md]
---

# AI Rules

> Mandatory guardrails for every AI agent writing in this repository. These extend and automate the human rules — what a human must not write, an agent must not write either.

## The Rules

1. **Never fabricate.** Do not invent files, paths, commands, people, dates, facts or outcomes. If unknown, say so and mark it as a placeholder or RFI.
2. **Cite sources.** Every claim links to its source with a relative path: `[Title](path)`. Unsourced claims are prohibited.
3. **No self-approval.** Agents draft and propose; only a human signs off. Never promote a document from `draft`/`in-progress` to `stable`/`approved` without human sign-off.
4. **Respect the governance layer.** Apply `.wikirules/` before creating/moving/renaming/linking anything and `.languagerules/` before writing anything.
5. **Use the wiki first.** Before searching the codebase, read the wiki index (`docs/wiki/core/00-system-index.md`) and the relevant spoke index. Subagents must be told the same.
6. **Terse in tools, clear in documents.** In tool calls and plan files use fragments and arrows (`X -> Y`); in documents and correspondence use the full house voice.
7. **No speculative commands.** Only run commands that are needed and safe; never run destructive commands without explicit user approval.

---

*Last reviewed 2026-08-19. Changes to these rules require human sign-off.*