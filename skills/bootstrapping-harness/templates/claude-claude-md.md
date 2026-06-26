# HarnessSuperpowers — Claude Code Always-On Rules

## Output Language

- Agent replies: use the user's language; if not specified, default to <LANGUAGE_DEFAULT>.
- Specs / plans / wiring-matrix: follow conversation language.
- KnowHow / knowhow-map: follow `docs/superpowers/README.md` "Output Language Convention".
- Core plugin skill content: English (do not rewrite).

If the user says "reply in English" (or any language override), switch immediately and keep it for subsequent artifacts until told otherwise.

---

## Environment Facts

> ⚠️ **Must rewrite for this project.**

- OS: <e.g. Windows 11 / Ubuntu 22.04 / macOS>
- Shell: <PowerShell / bash / zsh>
- Primary language runtime(s): <e.g. Node 20.x, Python 3.12, Go 1.23>

### How to run

- Install deps: `<command>`
- Run tests: `<command>`
- Run lint/format: `<command>`
- Run dev server: `<command>`
- Build: `<command>`

### Path / tooling notes

- Path separator: <note>
- Known pitfalls: <note>

---

## Commit-time Discipline

When the user asks to "commit / 提交" or requests creating/fixing a commit:

1. **Update docs first** if the change involves: mappings, field/format alignment, normalization/dedup strategy, known constraints, operational steps, debugging methods.
   - `docs/DEV_NOTES.md` (long-lived decisions): architecture decisions, trade-offs, new pitfalls/workarounds, abandoned approaches.
   - `docs/CHANGELOG.md` (change log): add an entry at the top.
2. Then run git add/commit.

Adapt these paths and formats to the project if they differ.
