---
alwaysApply: true
---

# HarnessSuperpowers — Documentation Rules (Cursor rule)

This rule is always-on in Cursor (`.cursor/rules/`).

## KnowHow index

At task start, scan `docs/superpowers/knowhow-map.md` trigger lines; if the task matches one, read the pointed KnowHow sections before touching that area, and cite used entries in your report.

## Commit-time discipline

When the user asks to "commit / 提交" or requests creating/fixing a commit:

1. **Update docs first** if the change involves: mappings, field/format alignment, normalization/dedup strategy, known constraints, operational steps, debugging methods.
   - `docs/DEV_NOTES.md` (long-lived decisions): architecture decisions, trade-offs, new pitfalls/workarounds, abandoned approaches.
   - `docs/CHANGELOG.md` (change log): add an entry at the top.
2. Then run git add/commit.

Adapt these paths and formats to the project if they differ.

