---
title: Human Rules
tags: [language, human, writing, editing]
status: approved
owner: Wiki Owner
last-reviewed: 2026-08-19
related-to: [./README.md, ./voice-and-tone.md, ./prohibited-language.md]
---

# Human Rules

> Practical writing and editing checklist for people. The AI rules (`.languagerules/ai-rules.md`) extend these; they never replace them.

## Writing Checklist

1. **Read the voice first.** Apply `.languagerules/voice-and-tone.md` before drafting anything.
2. **Front-load.** Purpose & context, then summary, then detail (`.wikirules/document-structure.md`).
3. **One idea per paragraph.** Short paragraphs, short sentences, active voice.
4. **Link everything you reference.** Every claim, doc and path you mention gets a relative link.
5. **Cut filler.** Re-read once purely to delete words that add nothing.
6. **Check prohibited language.** Scan against `.languagerules/prohibited-language.md`.
7. **Verify with the linter.** Run `python .wikirules/wiki_lint.py` after creating or moving wiki content.

## Editing Checklist

1. Does the opening stand alone? Could a reader stop after the summary and understand?
2. Is every claim sourced?
3. Is every path correct and every link resolving?
4. Is the frontmatter complete and valid?
5. Is the language plain, direct and free of prohibited words?

---

*Last reviewed 2026-08-19. Changes to these rules require human sign-off.*