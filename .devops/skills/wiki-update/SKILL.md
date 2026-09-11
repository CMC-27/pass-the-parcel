---
type: "skill"
name: "wiki-update"
status: "stable"
description: "Refreshes only the wiki docs a code change actually touched. Use after a commit/merge, before wrapping up, when a claims check reports drift, or when asked to sync the wiki with recent changes. Maps git diff since the last verified sha to affected docs via their grounded claims and links, revises those, and stamps last-verified. Incremental — never a full-wiki rewrite."
references: "scripts/wiki_claims.py — affected/update modes. .wiki/rules/claims.md — claim shape and drift semantics."
version: 1
updated: 2026-09-11
---

# wiki-update

Keep the wiki current without rewriting it. Map a diff to the docs it invalidates, fix only those, stamp them.

---

## 1. The Loop

```
1. Determine the baseline sha
2. List affected docs            <- python scripts/wiki_claims.py affected <sha>
3. Read each affected doc + the changed source
4. Revise only what the change invalidated
5. Re-stamp                      <- python scripts/wiki_claims.py update
6. Stamp last-verified on each revised doc
7. Verify                        <- python scripts/wiki_lint.py --quiet
8. Hand prose polish to @wiki-writer; hand uncertainty to @wiki-bootstrap
```

---

## 2. Determine the Baseline

1. Prefer an explicit sha the user names (`git diff <sha>..HEAD`).
2. Otherwise use the newest `last-verified` date across the affected docs, and resolve it to a commit.
3. If neither is available, fall back to the last tag or the previous commit (`HEAD~1`) and **say so**.

Never silently pick a baseline. Record the sha you used in the change summary.

---

## 3. List Affected Docs

```
python scripts/wiki_claims.py affected <sha>
```

A doc is affected when one of its `claims`/`dependencies`/`related-to` targets changed. Exit `2` means the ref is unknown or the workspace is not a git repo — stop and report; do not guess a baseline.

Also run `python scripts/wiki_claims.py check`. A `STALE` row is the same signal for a claim whose source changed without the baseline being known.

---

## 4. Revise Only What Changed

For each affected doc:

1. Read the doc and the changed source side by side.
2. Change only the statements the source invalidates. Leave untouched assertions untouched.
3. If a claim's source no longer supports the statement, either correct the statement or remove the claim — never leave a claim pointing at code that contradicts the prose.
4. Follow `@wiki-writer` discipline for every sentence you write (plain, front-loaded, one idea per sentence).

> **No full rewrites.** A diff that touches one function must not regenerate the doc. Surgical edits only.

---

## 5. Stamp

```
python scripts/wiki_claims.py update
```

Then set `last-reviewed: <today>` on every revised doc. `last-reviewed` is the wiki's own freshness signal and matches the hub's `Last Verified` convention.

---

## 6. Verify

```
python scripts/wiki_lint.py --quiet
python scripts/wiki_claims.py check
```

Both must exit `0`. If lint fails, fix the doc — do not suppress the finding.

---

## 7. Boundaries

- **Docs only.** This skill never edits source code.
- **No promotion.** It does not flip a doc to `stable`; that is a wrap-up, human-owned decision.
- **No new docs.** Creating docs is `@wiki-generate`; verifying them is `@wiki-bootstrap`.
- **No baseline guessing.** If you cannot resolve a sha, say so and stop.

---

> **The rule:** the diff names the docs. Fix those, stamp those, verify, stop.
