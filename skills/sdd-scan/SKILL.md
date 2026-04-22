---
name: sdd-scan
description: SDD compliance scan. Scans a spec's requirements / design / tasks documents for SDD conformance: CP-xx Correctness Properties, precondition/postcondition, Wiring Matrix, BDD+TDD task structure. Use before running all tasks, when validating spec quality, or when a PostToolUse hook fires on a spec file edit.
---

# SDD Compliance Scan

Scan a spec's three documents (requirements / design / tasks) for SDD conformance before starting implementation.

## Invocation

- Slash command: `/scan-spec <spec-name>` (Claude Code / Cursor)
- Skill discovery: ask the agent "scan spec <name> for SDD compliance"
- Hook-driven: automatically via `spec-sdd-check` hook on `PostToolUse: Edit|Write|MultiEdit`

If no spec name is provided, the skill resolves via the Discovery Contract:

1. `${WORKSPACE_ROOT}/docs/superpowers/specs/<latest>.md`
2. `${WORKSPACE_ROOT}/.kiro/specs/<latest>/requirements.md`
3. Active editor file if it matches `**/specs/**/*.md`

Where `<latest>` is the file (or directory) whose name sorts last when filtered to the ISO-date prefix `YYYY-MM-DD-*` (lexical sort, descending). If no ISO-date-prefixed entry exists, fall back to newest modification time.

## Scan Items

### 1. requirements (requirements.md or spec's Requirements section)

- [ ] Contains CP-<NN> correctness properties
- [ ] Each CP references the requirement clause it enforces
- [ ] Every CP-<NN> is covered by at least one N.5 PBT task in tasks (reverse map)

### 2. design (design.md or spec's Design section)

- [ ] Exported functions annotated with precondition / postcondition
- [ ] A "Wiring Matrix" section exists and lists caller → callee → timing → args
- [ ] Each computation step is tagged Latent or Deterministic

### 3. tasks (tasks.md or spec's Tasks section)

- [ ] Each implementation task follows the 5-substep structure (N.1 BDD → N.2 Red → N.3 Green → N.4 Refactor → N.5 PBT)
- [ ] Every task that adds an exported function **listed in the Wiring Matrix** is followed by a wiring task (exported functions not in the matrix are not required to have one)
- [ ] Each phase-ending Checkpoint task invokes the 5-dimension audit

## Output Format

```
## SDD Compliance Scan — <spec_name>

### requirements
- ✅ CP-xx properties: <count>
- ✅ / ❌ CP-xx → N.5 PBT reverse map: <unmatched CP IDs or "all covered">
- ✅ / ❌ <specific issue>

### design
- ✅ / ❌ precondition/postcondition
- ✅ / ❌ Wiring Matrix
- ✅ / ❌ Latent/Deterministic tagging

### tasks
- ✅ / ❌ BDD+TDD substeps
- ✅ / ❌ Wiring tasks
- ✅ / ❌ Checkpoint audit steps

### Conclusion
All compliant / <N> gaps need fixing
```

## Related Skills

- `skills/sdd-workflow/SKILL.md` — the SDD-BDD-TDD flow this scan enforces.
- `skills/harness-engineering/SKILL.md` — Wiring Matrix canonical.
- `skills/writing-plans/SKILL.md` — plan authoring downstream.
