---
name: bootstrapping-harness
description: Scaffold a project's Layer 2 harness structure. Use when a new workspace adopts Superpowers and needs docs/superpowers/{specs,knowhow,knowhow-map.md}, scripts/evaluators/ placeholders, and an output-language convention. Interactive — asks the user which language KnowHow should be written in and which initial knowledge areas to seed.
---

# Bootstrapping Harness

One-shot scaffolder for the project-level (Layer 2) Harness structure.

## When to Use

- A new workspace adopts Superpowers and has no `docs/superpowers/` yet.
- The existing `docs/superpowers/` is missing `knowhow-map.md` or `wiring-matrix.md`.
- User asks: "set up superpowers for this project", "initialize harness", or similar.

Do NOT use when the structure is already complete and matches the Discovery Contract.

## The Layer 2 Shape

```
<workspace>/
├── docs/
│   └── superpowers/
│       ├── README.md           ← project conventions (language, owners, etc.)
│       ├── roadmap.md          ← macro roadmap (created via authoring-roadmap)
│       ├── specs/              ← Phase folders (prd.md, sysdesign.md, tasks.md)
│       ├── handover/           ← session handover files
│       ├── knowhow/            ← long-lived KnowHow files
│       └── knowhow-map.md      ← knowledge area → file/skill/steering mapping
└── scripts/
    └── evaluators/             ← Mode A deterministic evaluators (placeholder)
        └── README.md           ← when to add Mode A script, when Mode B is enough
```

## The Procedure

**Step 1 — Discover existing state.**

Check each expected path. For anything that exists, do not overwrite; report it and move on.

**Step 2 — Ask language convention (interactive).**

Ask the user exactly this (one question only):

> "What language should KnowHow / knowhow-map / wiring-matrix files be written in? (English / Traditional Chinese / Simplified Chinese / other — please specify)"

Record answer in `docs/superpowers/README.md` as:

```markdown
## Output Language Convention

- Specs / plans: follow conversation language (defaults to steering layer)
- KnowHow / knowhow-map / wiring-matrix: <user answer>
- Runtime evaluator scripts: English (convention)
```

**Step 2.5 — Install always-on steering/rules (required).**

Create always-on policy files so the agent has stable defaults in a new workspace (especially when hook injection is unreliable). This step is mandatory for a new workspace adopting this harness.

### Cursor

- `.cursor/rules/harnesssuperpowers-language.mdc` (always-on rule)

Also install these always-on, **project-scoped** policies:

- Environment facts (project must rewrite immediately): `.cursor/rules/harnesssuperpowers-environment.mdc`
- Documentation discipline (commit-time rules; adapt to your repo): `.cursor/rules/harnesssuperpowers-documentation-rules.mdc`

### Kiro

- `.kiro/steering/language.md` (inclusion: always)
- Environment facts: `.kiro/steering/environment.md`
- Documentation discipline: `.kiro/steering/documentation-rules.md`

### Claude Code

Claude Code reads `CLAUDE.md` (workspace root) as always-on context, and `.claude/settings.json` for permissions and hooks.

**Files to create (if not present):**

- `CLAUDE.md` — merges language defaults, environment facts, and commit-time discipline into a single always-on file. Use `templates/claude-claude-md.md`.
- `.claude/settings.json` — tool permissions and PreToolUse hook for commit discipline. Use `templates/claude-settings.json`.
- `.claude/scripts/pre-commit-check.sh` — hook script called by settings.json. Use `templates/claude-pre-commit-check.sh`.

**What each section of `CLAUDE.md` maps to:**

| Cursor / Kiro file | `CLAUDE.md` section |
|---|---|
| `harnesssuperpowers-language.mdc` | `## Output Language` |
| `harnesssuperpowers-environment.mdc` | `## Environment Facts` |
| `harnesssuperpowers-documentation-rules.mdc` | `## Commit-time Discipline` |

**Hook behaviour:**
The `pre-commit-check.sh` script exits 1 (blocking) when code files are staged but neither `docs/DEV_NOTES.md` nor `docs/CHANGELOG.md` is staged. Exit 0 passes through silently. Adjust the doc-path pattern in the script to match the project’s actual docs layout.

All language/environment/documentation defaults should be set the same way as for Cursor/Kiro (see above). If these files already exist, do not overwrite — report and move on.

**Step 3 — Ask initial knowledge areas (interactive, optional).**

Ask:

> "What are the 3–5 main knowledge areas in this project? (e.g. frontend rendering, backend API, data pipeline; can skip)"

If the user lists areas, seed `knowhow-map.md` with matching rows. Otherwise seed the template header only.

**Step 4 — Materialize from templates.**

Copy each template from `skills/bootstrapping-harness/templates/` to the target path, replacing `<PLACEHOLDER>` tokens with user answers.

- `templates/README.md`        → `docs/superpowers/README.md`
- `templates/knowhow-map.md`   → `docs/superpowers/knowhow-map.md`
- `templates/wiring-matrix.md` → `docs/superpowers/wiring-matrix.md`

Always copy (unless target already exists):

**Cursor:**
- `templates/cursor-language-rule.md` → `.cursor/rules/harnesssuperpowers-language.mdc`
- `templates/cursor-environment-rule.md` → `.cursor/rules/harnesssuperpowers-environment.mdc`
- `templates/cursor-documentation-rules-rule.md` → `.cursor/rules/harnesssuperpowers-documentation-rules.mdc`

**Kiro:**
- `templates/kiro-language-steering.md` → `.kiro/steering/language.md`
- `templates/kiro-environment-steering.md` → `.kiro/steering/environment.md`
- `templates/kiro-documentation-rules-steering.md` → `.kiro/steering/documentation-rules.md`

**Claude Code:**
- `templates/claude-claude-md.md` → `CLAUDE.md`
- `templates/claude-settings.json` → `.claude/settings.json`
- `templates/claude-pre-commit-check.sh` → `.claude/scripts/pre-commit-check.sh`

Create empty folders `docs/superpowers/specs/`, `docs/superpowers/handover/`, `docs/superpowers/knowhow/`, `scripts/evaluators/`, each with a `.gitkeep`.

Create `scripts/evaluators/README.md` with:

```markdown
# Runtime Evaluators (Layer 3)

Put deterministic evaluators here (Mode A). Typical layout:

- `check-<invariant>.sh` — shell invariant check
- `validate-<contract>.py` — schema / contract check

Prefer Mode B (agent-native: shell, MCP, subagent) while exploring.
Promote to Mode A once a check is run repeatedly and the rule is stable.

See `skills/harness-engineering/SKILL.md` and `docs/harness-extension-guide.md`.
```

**Step 5 — Confirm & summarize.**

Report what was created (paths + one-line description each). Ask the user to commit.

## Non-Goals

- Do NOT install IDE-specific files broadly. Exception: the required always-on steering/rules in Step 2.5 (`.cursor/rules/` and `.kiro/steering/*`) exists to make new workspaces consistent when hook injection is unreliable.
- Do NOT write project-specific skills. User should author those on demand.

## Related Skills

- `skills/capturing-knowhow/SKILL.md` — uses the `knowhow-map.md` this skill seeds.
- `skills/harness-engineering/SKILL.md` — framework diagnostic tool.
- `skills/writing-tasks/SKILL.md` — produces tasks in `docs/superpowers/specs/<phaseName>/tasks.md`.
- `skills/authoring-roadmap/SKILL.md` — produces `docs/superpowers/roadmap.md`.
