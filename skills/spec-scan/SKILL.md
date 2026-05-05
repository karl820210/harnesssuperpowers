---
name: spec-scan
description: Use when validating Phase documents (PRD, SysDesign, Tasks) for completeness and cross-file consistency. Replaces sdd-scan. Automatically detects which files exist in a Phase folder and runs appropriate checks.
---

# Spec Scan

## Overview

Validate Phase documents for completeness, structural compliance, and cross-file consistency.

Core principle: scan what exists, report what's missing, verify cross-references.

**Announce at start:** "I'm running spec-scan on `<phaseName>`."

## When to Use

- After writing or editing any Phase document (prd.md, sysdesign.md, tasks.md)
- Before proceeding from one Stage to the next
- When the `spec-sdd-check` hook triggers on file edits in `specs/<phaseName>/`
- When explicitly requested by user or another skill

## The Procedure

### Step 1: Detect Files

Read the Phase folder at `docs/superpowers/specs/<phaseName>/`:

```
prd.md         → exists? → run PRD checks
sysdesign.md   → exists? → run SysDesign checks
tasks.md       → exists? → run Tasks checks
```

### Step 2: Run Per-File Checks

#### PRD Checks

- [ ] Has `## Goal` section (non-empty)
- [ ] Has `## Non-Goals` section (non-empty, at least 1 item)
- [ ] Has `## User Stories` section with at least 1 User Story
- [ ] Each User Story has BDD acceptance criteria (1-3 per story)
- [ ] Has `## SysDesign Decision` section with Complexity (Lite/Full) recorded
- [ ] Has `## Meta` section with Complexity and Date fields

#### SysDesign Checks (Full Phases only)

- [ ] Has `## Meta` with PRD Reference pointing to existing prd.md
- [ ] Has `## 3. Interface Definitions` with at least 1 exported function
- [ ] Each exported function has Precondition AND Postcondition
- [ ] Has `## 5. Correctness Properties` with at least 1 CP-xx
- [ ] Has `## 6. Wiring Matrix` with at least 1 row
- [ ] Wiring Matrix rows have all columns filled (Caller, Method, Param Source, Output)
- [ ] Has `## 7. Latent vs Deterministic Tagging` with at least 1 Deterministic entry

#### Tasks Checks

- [ ] Each task is bite-sized (estimated 2-5 minutes)
- [ ] Each task has verification steps or BDD scenarios
- [ ] Tasks are independently executable (no implicit dependencies without explicit notes)

### Step 3: Cross-File Validation (when multiple files exist)

#### PRD ↔ SysDesign

- [ ] Every User Story in PRD has at least one Interface or CP in SysDesign that addresses it
- [ ] SysDesign's Non-goals do not contradict PRD's scope

#### SysDesign ↔ Tasks

- [ ] Every CP-xx in SysDesign has at least one corresponding PBT task in Tasks
- [ ] Every Wiring Matrix row with a newly introduced callee has a corresponding wiring task in Tasks
- [ ] Report unmatched CP IDs: `CP-xx → Task mapping: <unmatched CP IDs or "all covered">`

#### PRD ↔ Tasks

- [ ] Every User Story in PRD has at least one task that addresses it
- [ ] Tasks do not exceed PRD's Non-goals scope

## Output Format

```markdown
## Spec Scan — <phaseName>

### prd.md
- ✅ / ❌ Goal section: <status>
- ✅ / ❌ Non-Goals: <count> items
- ✅ / ❌ User Stories: <count> stories, each with BDD
- ✅ / ❌ SysDesign Decision: <Lite/Full>

### sysdesign.md (if exists)
- ✅ / ❌ PRD Reference: <status>
- ✅ / ❌ Interface Contracts: <count> functions with precond/postcond
- ✅ / ❌ CP-xx: <count> properties
- ✅ / ❌ Wiring Matrix: <count> rows, all columns filled
- ✅ / ❌ Latent/Deterministic: <count> entries

### tasks.md (if exists)
- ✅ / ❌ Bite-sized tasks: <count> tasks
- ✅ / ❌ Verification steps: <status>

### Cross-File Validation
- ✅ / ❌ CP-xx → PBT coverage: <unmatched IDs or "all covered">
- ✅ / ❌ Wiring Matrix → Wiring tasks: <unmatched rows or "all covered">
- ✅ / ❌ User Stories → Task coverage: <unmatched stories or "all covered">

### Conclusion
All compliant / <N> gaps need fixing
```

## Scan Modes

The scan automatically adjusts based on what's present:

| Files Present | What Gets Checked |
|:---|:---|
| prd.md only | PRD checks only |
| prd.md + sysdesign.md | PRD + SysDesign + PRD↔SysDesign cross-validation |
| prd.md + tasks.md | PRD + Tasks + PRD↔Tasks cross-validation |
| All three | Full scan with all cross-validations |

## Common Mistakes

| Mistake | Fix |
|:---|:---|
| Running scan on a Lite Phase and expecting SysDesign | Lite Phases have no sysdesign.md — this is correct |
| CP-xx exists but no PBT task | Add a PBT task for each CP |
| Wiring Matrix row without corresponding task | Add a wiring integration task |
| Vague BDD criteria in PRD | Rewrite with specific Given/When/Then |

## Related Skills

- `brainstorming` — produces PRD (triggers scan after writing)
- `writing-sysdesign` — produces SysDesign (triggers scan after writing)
- `writing-tasks` — produces Tasks (triggers scan after writing)
