---
title: Voice & Tone
tags: [language, voice, tone, writing]
status: approved
owner: Wiki Owner
last-reviewed: 2026-08-19
related-to: [./README.md, ./ai-rules.md]
---

# Voice & Tone

> The house voice: professional and plain, confident without overclaiming. Applies to everything written in this repository — docs, commits, skills, agent prompts, correspondence.

## The Voice

1. **Professional and plain.** Clear, direct, plain language. Short sentences, active voice, common words.
2. **Confident without overclaiming.** State what is true and known; never inflate. Prefer "we verify this with the linter" over "we guarantee correctness".
3. **Concrete over vague.** Name the file, the path, the command, the rule. Avoid "the relevant documentation" when you can link it.
4. **No filler.** Drop pleasantries, hedging ("just", "actually", "sort of"), and throat-clearing ("It is important to note that").
5. **Human first, machine second.** Write so a person skimming the first page understands; agents read on for the detail.

## Tone Cheat-Sheet

| Write | Instead of |
|---|---|
| "Run `python scripts/wiki_lint.py`" | "It is recommended that you run the linter script" |
| "The linter hard-fails on broken links" | "Broken links are a serious issue that should be addressed" |
| "Edit base-context.md, then re-sync" | "If you wish to make changes to the configuration, you may consider editing the file" |

---

*Last reviewed 2026-08-19. Changes to these rules require human sign-off.*