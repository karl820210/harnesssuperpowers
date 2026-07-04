---
inclusion: manual
name: spec-scan
description: Spec compliance scan. Scans a Phase's PRD / SysDesign / Tasks documents for completeness and cross-file consistency: CP-xx Correctness Properties, precondition/postcondition, Wiring Matrix, BDD+TDD task structure. Use before running all tasks, when validating spec quality, or when a PostToolUse hook fires on a spec file edit.
---

<!-- SUPERPOWERS_ADAPTER -->

# Spec Scan (Kiro Adapter)

> **Canonical**: `skills/spec-scan/SKILL.md`

## Quick Reference

- **When to use:** before "run all tasks", when validating a spec, or triggered by `spec-sdd-check` hook.
- **Main output:** Markdown table of compliance findings per `PRD` / `SysDesign` / `Tasks`.
- **Key steps:**
  1. Resolve target Phase via Discovery Contract (argument > active editor > latest).
  2. Detect which Phase files exist and scan each against the checklist in canonical.
  3. Report with ✅ / ❌ and list gaps.

## Full Content

See canonical → `skills/spec-scan/SKILL.md`.
