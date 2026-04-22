# Harness Extension Guide

How to extend Superpowers into a concrete project — the Layer 1 / Layer 2 / Layer 3 model.

## The Three Layers

```
Layer 1  Framework Core (this plugin)
         skills/ + commands/ + hooks/ + docs/ + plugin manifests
         Zero project assumptions.

Layer 2  Project Extension (inside a workspace)
         docs/superpowers/specs /plans /knowhow /knowhow-map.md
         .cursor/skills/  .kiro/skills/  — IDE-specific extensions
         Per-project conventions and domain knowledge.

Layer 3  Runtime Evaluators (inside a workspace)
         Mode A  scripts/evaluators/*.sh — deterministic, reproducible
         Mode B  agent-native (shell, MCP, subagent) — exploratory, inferential
         Promotion: Mode B repeat patterns → formalize into Mode A scripts.
```

Layer 1 never assumes Layer 2 or 3 exists. Core skills use the Discovery Contract to locate Layer 2 files gracefully.

## Discovery Contract (Layer 2 Lookup Priority)

Core skills resolve Layer 2 files in this order:

1. `${WORKSPACE_ROOT}/docs/superpowers/<filename>`
2. `${WORKSPACE_ROOT}/.kiro/<filename>` (Kiro legacy)
3. `${WORKSPACE_ROOT}/<filename>` (repo root fallback)

Applies to: `knowhow-map.md`, `wiring-matrix.md`, `specs/*.md`, `plans/*.md`, `scripts/evaluators/*`.

## Mode A vs Mode B Evaluators

| Dimension | Mode A | Mode B |
|---|---|---|
| Form | `scripts/evaluators/*.sh` etc. | Agent-native (shell, MCP, subagent) |
| I/O shape | Fixed | Free |
| Good for | Repetitive, rule-stable checks | Unspecified / judgment-heavy |
| Reproducible | Yes | No |
| Speed | Fast | Slow |

**Promotion path (Flywheel):** Mode B check repeated many times → `skills/capturing-knowhow` captures the pattern → engineer formalizes as Mode A script → subsequent runs use Mode A.

## Output Language Convention

Set per-project in `docs/superpowers/README.md`.

| Artifact | Language | Controlled by |
|---|---|---|
| Core skill content | English | Layer 1 (this plugin) |
| Agent replies | User / workspace steering | `CLAUDE.md` / `AGENTS.md` / `.kiro/steering/language.md` |
| `specs/*.md`, `plans/*.md`, `wiring-matrix.md` | Conversation language | Steering layer |
| `knowhow/*.md`, `knowhow-map.md` | Project-wide, stable | `docs/superpowers/README.md` convention (asked by `bootstrapping-harness`) |
| `scripts/evaluators/*` | English (convention) | — |

## Cross-IDE Support Matrix

| IDE | Plugin manifest | Skill discovery | Commands | Hooks | Steering |
|---|---|---|---|---|---|
| Claude Code | `.claude-plugin/plugin.json` | `skills/` via description | `commands/*.md` | `hooks/hooks.json` | `CLAUDE.md` |
| Cursor | `.cursor-plugin/plugin.json` | `skills/` via description | `commands/*.md` | `hooks/hooks-cursor.json` | `AGENTS.md` / `.cursor/rules/` |
| Kiro | `.kiro/` | `.kiro/skills/*/SKILL.md` via inclusion | — | `.kiro/hooks/*.kiro.hook` | `.kiro/steering/` |
| Codex | `.codex/INSTALL.md` (symlinks) | `skills/` via description | via symlink | — | `AGENTS.md` |
| OpenCode | `docs/README.opencode.md` | `skills/` via description | — | — | `AGENTS.md` |
| Gemini CLI | (no dedicated doc; `AGENTS.md` + skill discovery) | `skills/` via description (verify per release) | — | — | `AGENTS.md` |

## Getting Started in a New Workspace

```
1. Invoke skills/bootstrapping-harness         → scaffolds Layer 2
2. Brainstorm a feature (skills/brainstorming) → writes docs/superpowers/specs/<name>.md
3. (Optional) /scan-spec <name>                → SDD compliance scan
4. Write a plan (skills/writing-plans)         → docs/superpowers/plans/<name>.md
5. Execute (skills/subagent-driven-development) with two-stage review
6. Session ends → capture learnings (/capture-knowhow)
```

## Related

- `skills/harness-engineering/SKILL.md` — framework canonical + 5-dim audit + Wiring Matrix template.
- `skills/sdd-workflow/SKILL.md` — SDD → BDD → TDD flow overview.
- `skills/bootstrapping-harness/SKILL.md` — Layer 2 scaffolder.
- `docs/superpowers/specs/2026-04-22-kiro-superpowers-integration-design.md` — the design behind this integration.
