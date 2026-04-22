---
inclusion: manual
name: sdd-scan
description: SDD compliance scan. Scans a spec's requirements / design / tasks documents for SDD conformance: CP-xx Correctness Properties, precondition/postcondition, Wiring Matrix, BDD+TDD task structure. Use before running all tasks, when validating spec quality, or when a PostToolUse hook fires on a spec file edit.
---

<!-- SUPERPOWERS_ADAPTER -->

# SDD Scan (Kiro Adapter)

> **Canonical**: `skills/sdd-scan/SKILL.md`

## Quick Reference

- **When to use:** before "run all tasks", when validating a spec, or triggered by `spec-sdd-check` hook.
- **Main output:** Markdown table of compliance findings per `requirements` / `design` / `tasks`.
- **Key steps:**
  1. Resolve target spec via Discovery Contract (argument > active editor > latest).
  2. Scan each section against the checklist in canonical.
  3. Report with ✅ / ❌ and list gaps.

## Full Content

See canonical → `skills/sdd-scan/SKILL.md`.
