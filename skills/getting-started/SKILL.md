---
name: getting-started
description: Use when starting Superpowers in a new project workspace. Guides initial setup (Layer 2 scaffolding), optional Cursor hooks install choices, first spec/plan workflow, and KnowHow capture loop.
---

# Getting Started (New Project Workspace)

## Goal

Help the user start using Superpowers effectively **in a brand-new project** by bootstrapping Layer 2, running one full workflow loop, and (optionally) enabling hooks.

## Default Assumptions

- Skills/commands are installed (e.g. Cursor: `/add-plugin harnesssuperpowers`).
- The user wants **project-specific extension** (Layer 2) rather than modifying the plugin.
- Output language follows workspace steering (agent replies in user's language).

## Step 0 — Confirm platform (minimal)

Ask only what changes the procedure:

- Which IDE? (Cursor / Claude Code / Kiro / Codex / OpenCode / Gemini CLI)
- Do you want hooks enabled? (yes/no)
- If Cursor: prefer **user hooks** (global) or **project hooks** (per repo)?

## Step 1 — Bootstrap Layer 2 (Project Extension)

Invoke `skills/bootstrapping-harness/SKILL.md`.

Expected outputs created in the workspace:

- `docs/superpowers/README.md` (project conventions; KnowHow language)
- `docs/superpowers/specs/`
- `docs/superpowers/plans/`
- `docs/superpowers/knowhow-map.md`
- `docs/superpowers/knowhow/`

If the user already has `docs/superpowers/`, do not overwrite without explicit instruction—merge by extending.

## Step 2 — (Optional) Enable hooks

### Cursor

Cursor reads hooks config from:

- Project: `.cursor/hooks.json` (per repo)
- User: `%USERPROFILE%/.cursor/hooks.json` (global)
- Enterprise: `C:\\ProgramData\\Cursor\\hooks.json`

If the user chooses **project hooks**, instruct them to create or update `.cursor/hooks.json`.
If the user chooses **user hooks**, instruct them to create or update `%USERPROFILE%/.cursor/hooks.json`.

Recommended hook steps for Cursor (Windows plugin mode):

- `sessionStart` → `session-start`
- `afterFileEdit` → `spec-sdd-check`
- `stop` → `capture-knowhow-reminder`

Implementation note: on Windows, use a stable path to the plugin hook runner. Prefer:

- `cmd /c "%CURSOR_PLUGIN_ROOT%\\hooks\\run-hook.cmd" <hook-name>`

If hooks injection is unreliable in your Cursor build, install the rule fallback:

- `.cursor/rules/harnesssuperpowers-reminders.mdc` (this plugin ships it)

### Claude Code

Claude Code hooks are configured via `hooks/hooks.json` (plugin-side). No project action required.

### Kiro

Kiro uses `.kiro/hooks/*.kiro.hook` and `.kiro/steering/*` (project-side).

#### Kiro-only steering (recommended to review on day 0)

If the project will be worked in **Kiro**, keep these as **Kiro-only** (project-specific) files and review them immediately after installation:

- `.kiro/steering/environment.md` — **project environment facts** (runtime versions, OS/shell, dependencies, how to run tests/build). This must be rewritten per project.
- `.kiro/steering/documentation-rules.md` — **commit-time documentation discipline** (what docs must be updated before committing). Keep if your team uses DEV_NOTES/CHANGELOG style; otherwise adapt.
- `.kiro/steering/skill-routing.md` — **intent → skill routing** for Kiro. Keep if you rely on Kiro’s always-on routing; update when adding/removing skills.

These files are intentionally not moved into Layer 1: they are workflow- and team-specific, and they differ across projects.

## Step 3 — Run one full workflow loop (recommended)

1. **Brainstorm**: invoke `skills/brainstorming/SKILL.md` to clarify requirements and produce an approved design/spec.
2. **(Optional) Scan**: run `/scan-spec <spec-name>` (or invoke `skills/sdd-scan/SKILL.md`) if the work is spec-shaped.
3. **Plan**: invoke `skills/writing-plans/SKILL.md` to generate a plan under `docs/superpowers/plans/`.
4. **Execute**: invoke `skills/subagent-driven-development/SKILL.md` for task-by-task implementation + two-stage review.
5. **Verify**: invoke `skills/verification-before-completion/SKILL.md` at feature checkpoint.
6. **Capture KnowHow**: run `/capture-knowhow` (or invoke `skills/capturing-knowhow/SKILL.md`).

## Step 4 — Where to put project-specific knowledge

- **Stable learnings**: `docs/superpowers/knowhow/*.md` + `knowhow-map.md` (Flywheel)
- **Design intent**: `docs/superpowers/specs/*.md` (Wiring Matrix / CP-xx when applicable)
- **Deterministic checks**: `scripts/evaluators/*` (Layer 3 Mode A; promote from Mode B)

## Success Criteria (quick)

- Layer 2 exists (`docs/superpowers/` present) and the first spec/plan loop completed once.
- If hooks enabled: at least one hook successfully injects `additional_context` (verify via IDE hook logs).

