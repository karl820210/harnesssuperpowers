# Superpowers Layer 2 — <PROJECT_NAME>

Project-specific extension for Superpowers.

## Layout

- `specs/`        — feature specs (requirements + design + tasks)
- `plans/`        — implementation plans
- `knowhow/`      — long-lived KnowHow files
- `knowhow-map.md` — index of knowledge areas → KnowHow file + related skill/steering
- `wiring-matrix.md` — (optional) project-wide wiring reference; per-spec matrices are preferred

## Output Language Convention

- Specs / plans: follow conversation language (defaults to steering layer)
- KnowHow / knowhow-map / wiring-matrix: <LANGUAGE_ANSWER>
- Runtime evaluator scripts: English (convention)

## How to Use

- New feature → `skills/brainstorming` → write spec under `specs/<date>-<name>.md`
- Have a spec → `skills/writing-plans` → write plan under `plans/<date>-<name>.md`
- Execute plan → `skills/subagent-driven-development`
- Session ends with new learnings → `skills/capturing-knowhow` → append to the right `knowhow/*.md`
- Scan spec compliance → `/scan-spec <name>` or `skills/sdd-scan`

See the canonical guide: `docs/harness-extension-guide.md` (in the Superpowers plugin).
