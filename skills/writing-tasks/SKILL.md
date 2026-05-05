---
name: writing-tasks
description: Use when you have an approved PRD (and SysDesign if Full) for a Phase, before touching code. Produces bite-sized implementation tasks with TDD steps, BDD scenarios, and CP-xx coverage.
---

# Writing Tasks

## Overview

Write comprehensive implementation tasks assuming the engineer has zero context for the codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about the toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-tasks skill to create the implementation tasks."

**Save tasks to:** `docs/superpowers/specs/<phaseName>/tasks.md`

## Inputs

Read the Phase folder at `docs/superpowers/specs/<phaseName>/`:

- **Always:** `prd.md` — Goal, User Stories, Non-goals, Constraints, Complexity
- **If Full:** `sysdesign.md` — Interface Contracts, CP-xx, Wiring Matrix, Latent/Deterministic tagging

## Scope Check

If the PRD covers multiple independent subsystems, it should have been broken into sub-Phases during brainstorming. If it wasn't, suggest breaking this into separate task files — one per subsystem. Each task file should produce working, testable software on its own.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the tasks is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

## Correctness Properties & Wiring (Full Phases)

If the Phase has `Complexity: Full` and a `sysdesign.md` exists, the tasks must honor two extra contracts:

- **Correctness Properties** — SysDesign lists `CP-<NN>: <invariant>` items. Each implementation task that touches a CP must include a PBT step, not only example-based tests. Reference the CP ID in the task.
- **Wiring Matrix** — SysDesign lists caller → callee → timing → arg source. For every new exported function whose row in the matrix points at an external caller, follow the implementation task with a *wiring task* whose steps integrate the new function into that caller.

If the Phase is Lite (no sysdesign.md), skip this — proceed with standard TDD-shaped tasks.

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Tasks Document Header

**Every tasks file MUST start with this header:**

```markdown
# [Phase Name] Implementation Tasks

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement these tasks. Steps use checkbox (`- [ ]`) syntax for tracking.

**PRD:** prd.md
**SysDesign:** sysdesign.md (or N/A for Lite)
**Goal:** [One sentence from PRD]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test**

```python
# BDD: Given <precondition> When <action> Then <expected>
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

### PBT Task (for CP-xx, Full Phases only)

````markdown
### Task N.5: PBT for CP-<NN>

**CP-<NN>:** <invariant statement from sysdesign.md>

- [ ] **Step 1: Write property-based test**

```python
from hypothesis import given, strategies as st

@given(st.integers(min_value=0))
def test_cp_nn_invariant(value):
    # CP-<NN>: <invariant>
    result = function(value)
    assert invariant_holds(result)
```

- [ ] **Step 2: Run PBT**

Run: `pytest tests/path/test.py::test_cp_nn -v`
Expected: PASS (100 examples)

- [ ] **Step 3: Commit**
````

### Wiring Task (for Wiring Matrix rows, Full Phases only)

````markdown
### Task N+1: Wire <Callee> into <Caller>

**Wiring Matrix row:** <Caller> calls <Callee> with <params>

- [ ] **Step 1: Write integration test**
- [ ] **Step 2: Implement the wiring**
- [ ] **Step 3: Verify Wiring Matrix matches implementation**
- [ ] **Step 4: Commit**
````

## No Placeholders

Every step must contain the actual content an engineer needs. These are **task failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — the engineer may be reading tasks out of order)
- Steps that describe what to do without showing how (code blocks required for code steps)
- References to types, functions, or methods not defined in any task

## Remember
- Exact file paths always
- Complete code in every step — if a step changes code, show the code
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent commits

## Self-Review

After writing the complete tasks, look at the PRD (and SysDesign if Full) with fresh eyes and check the tasks against them. This is a checklist you run yourself — not a subagent dispatch.

**1. PRD coverage:** Skim each User Story in the PRD. Can you point to a task that implements it? List any gaps.

**2. Placeholder scan:** Search your tasks for red flags — any of the patterns from the "No Placeholders" section above. Fix them.

**3. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

**4. SysDesign contract coverage (Full Phases only):** For each CP-xx in the SysDesign, point to the task and the PBT step covering it. For each Wiring Matrix row whose callee is newly introduced, confirm a wiring task integrates it. List gaps and add tasks.

If you find issues, fix them inline. No need to re-review — just fix and move on. If you find a PRD requirement with no task, add the task.

## After Writing

1. Save to `docs/superpowers/specs/<phaseName>/tasks.md`
2. Commit to git
3. If Roadmap exists, auto-update the Phase's Tasks path
4. Run `spec-scan` on the Phase folder — loop until PASS (especially cross-file validation)
5. Ask user to review: "Tasks written and committed to `<path>`. Please review before we start execution."

## Execution Handoff

After the user approves the tasks, offer execution choice:

**"Tasks complete and saved to `<path>`. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- Fresh subagent per task + two-stage review

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:executing-plans
- Batch execution with checkpoints for review

## Related Skills

- `brainstorming` — produces the PRD that this skill consumes
- `writing-sysdesign` — produces the SysDesign that Full Phases consume
- `spec-scan` — validates tasks and cross-file consistency
- `subagent-driven-development` — recommended execution approach
- `executing-plans` — alternative execution approach
