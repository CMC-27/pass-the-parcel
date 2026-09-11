## Summary

<!-- One paragraph: what changes, and why. -->

## Change type

- [ ] Fix (bug in the machinery or docs)
- [ ] Feature (new or changed capability)
- [ ] Documentation only
- [ ] Portable-surface change (needs a `machinery-version` bump)

## Checklist

- [ ] I read [`AGENTS.md`](../AGENTS.md) and [`CONTRIBUTING.md`](../CONTRIBUTING.md).
- [ ] Every gate passes locally: prefix integrity, UTF-8, wiki lint, coverage, claims, JSON parse.
- [ ] If I touched the PREFIX-LOCKED prefix, I edited `.opencode/plans/base-context.md` and re-ran `check-parcel-prefix.ps1 -Sync` (not the inlined copies).
- [ ] If I changed portable machinery, I bumped the relevant `version:` and/or `machinery-version:` and recorded it in `.devops/logs/version-history.md`.
- [ ] New relative links resolve; no duplicate sources of truth introduced.

## Notes for reviewers

<!-- Anything non-obvious: trade-offs, deferrals, follow-ups. -->
