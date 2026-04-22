---
inclusion: fileMatch
fileMatchPattern: "**/*_test.go,**/*.test.js,**/*.spec.js,.kiro/specs/**/*.md"
---

# SDD → BDD → TDD Workflow (Kiro Steering Pointer)

This file was the original full SDD-BDD-TDD spec. The canonical content now lives in the Superpowers plugin — it is shared across IDEs (Claude Code / Cursor / Kiro / Codex / OpenCode).

## Canonical

- Overview: `skills/sdd-workflow/SKILL.md`
- TDD discipline: `skills/test-driven-development/SKILL.md`
- Wiring Matrix template + 5-dim audit: `skills/harness-engineering/SKILL.md`
- Static compliance scan: `skills/sdd-scan/SKILL.md`

## Why the steering file still exists

Kiro loads steering via `inclusion: fileMatch`. When a test file or a spec markdown is opened, this file is loaded — it nudges the agent to consult the canonical skills above.

## Kiro-only notes

- Spec folder convention: `.kiro/specs/<feature>/{requirements,design,tasks}.md`
- Running all tasks from `tasks.md`: see `subagent-driven-development` (canonical).

The full SDD rules (CP-xx format, Wiring Matrix, BDD scenarios, TDD Iron Law, Checkpoint 5-dim audit, Task self-review) are in the canonical skills. Do not duplicate them here.
