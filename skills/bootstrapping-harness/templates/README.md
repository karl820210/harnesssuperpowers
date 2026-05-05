# Superpowers Layer 2 — <PROJECT_NAME>

Project-specific extension for Superpowers.

## Layout

- `specs/`        — Phase folders (each contains prd.md, sysdesign.md, tasks.md)
- `handover/`     — session handover files
- `knowhow/`      — long-lived KnowHow files
- `knowhow-map.md` — index of knowledge areas → KnowHow file + related skill/steering

## Output Language Convention

- PRD / SysDesign / Tasks: follow conversation language (defaults to steering layer)
- KnowHow / knowhow-map: <LANGUAGE_ANSWER>
- Runtime evaluator scripts: English (convention)

## How to Use

- New feature → `skills/brainstorming` → produces PRD under `specs/<phaseName>/prd.md`
- Full Phase → `skills/writing-sysdesign` → produces `specs/<phaseName>/sysdesign.md`
- Ready to implement → `skills/writing-tasks` → produces `specs/<phaseName>/tasks.md`
- Execute tasks → `skills/subagent-driven-development`
- Session ends with new learnings → `skills/capturing-knowhow` → append to the right `knowhow/*.md`
- Validate spec compliance → `skills/spec-scan` on Phase folder

See the canonical guide: `docs/harness-extension-guide.md` (in the Superpowers plugin).
