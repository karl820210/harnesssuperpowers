---
name: sdd-workflow
description: Specification-Driven → Behavior-Driven → Test-Driven three-stage flow. Use when starting a new feature that needs structured requirements → design → tasks with Correctness Properties, Interface Contracts, and a Wiring Matrix. Complements writing-plans (plan authoring), subagent-driven-development (execution), and harness-engineering (audit).
---

# SDD → BDD → TDD Workflow

Structured three-stage flow that turns an idea into verified code.

## When to Use

- Starting a feature that has non-trivial correctness requirements
- The task has interface contracts the caller or callee must uphold
- Multiple modules must be wired together and wiring gaps have bitten you before
- A Kiro `spec/*` folder, or `docs/superpowers/specs/<feature>.md`, is expected

If the task is a one-file tweak, this flow is overkill — prefer `writing-plans` alone.

## The Three Stages

```
Stage 1  SDD   — Requirements  → Design
Stage 2  BDD   — Tasks with Given-When-Then scenarios
Stage 3  TDD   — Implementation Red → Green → Refactor (+ PBT)
```

Each stage produces verifiable artifacts that feed the next.

---

## Stage 1 — SDD (Specification-Driven Design)

Produces the `requirements` and `design` sections of the spec.

**Requirements must include Correctness Properties:**

- Format: `CP-<NN>: <property statement>`
- Example: `CP-01: After a fish's TTL expires, it must be removed from the scene; no orphans may remain.`
- CPs are invariants — they hold for all valid inputs, not just happy paths.
- Each CP should later map to at least one Property-Based Test (PBT).

**Design must include Interface Contracts:**

- Each exported function / method is annotated with `precondition` and `postcondition`.
- Example:
  ```
  ProcessShot(bulletID, fishID)
    precondition:  bullet.Active && fish.Alive
    postcondition: fish.HP decreased OR miss recorded
  ```

**Design must include a Wiring Matrix.** See `skills/harness-engineering/SKILL.md` for the canonical template. Summary:

| Order | Caller | Callee method | Argument source | Output / side-effect |
|---|---|---|---|---|
| 1 | {main loop} | {subsystem}.Update(dt) | {state source} | {broadcast / state change} |

The Wiring Matrix is the sole source of truth for integration tasks in Stage 3.

**Design must mark each computation step as Latent or Deterministic.** See `harness-engineering` for the distinction. Deterministic steps must not be left for the agent to "infer".

## Stage 2 — BDD (Behavior-Driven Development)

Produces the `tasks` section of the spec.

- Every user story / acceptance criterion converts to a Given-When-Then scenario.
- Scenarios live in the test file (as comments or test function names).
- Naming: `Test_<Feature>_Given<State>_When<Action>_Then<Outcome>` (adapt per language).
- Scenarios must cover: happy path, boundary conditions, error / edge cases.

Each implementation task in `tasks.md` has this shape:

```
- [ ] N. <feature description>
  - [ ] N.1 Write BDD scenario (Given-When-Then)
  - [ ] N.2 Write failing test (Red)
  - [ ] N.3 Write minimal implementation (Green)
  - [ ] N.4 Refactor; tests stay green
  - [ ] N.5 Write PBT for the matching CP-xx (if any)
```

If the task adds an exported function that the Wiring Matrix expects to be called, it MUST be followed by a wiring task:

```
- [ ] N+1. Wiring: integrate <method> into <caller>
  - [ ] (N+1).1 Call <method> in <caller> per Wiring Matrix timing and args
  - [ ] (N+1).2 Integration test for the full call chain
  - [ ] (N+1).3 Confirm Wiring Matrix matches implementation
```

## Stage 3 — TDD (Test-Driven Development)

See `skills/test-driven-development/SKILL.md` for the canonical Iron Law and Red-Green-Refactor discipline. Summary:

- **Iron Law:** No failing test → no production code. Wrote code first? Delete it.
- **Red:** Write the test. Run it. Confirm failure reason is "feature missing", not a typo.
- **Green:** Write the minimum code that makes the test pass. Nothing else.
- **Refactor:** Clean up while tests stay green. No new behavior.

Every CP-xx gets at least one PBT in addition to example-based tests.

---

## Checkpoint Task (end of each phase)

Every phase-ending task should invoke the 5-dimension audit from `skills/harness-engineering/SKILL.md`:

1. **Feedback coverage** — every new exported function has a unit test; cross-module calls have integration tests.
2. **Wiring integrity** — every new method has at least one caller.
3. **Latent / Deterministic split** — no deterministic logic left to agent inference.
4. **Test health** — no flaky tests.
5. **Flywheel health** — new KnowHow captured if applicable.

See `skills/verification-before-completion/SKILL.md` for the completion gate.

---

## Handoff

When Stage 1 artifacts exist, invoke `skills/writing-plans/SKILL.md` to turn tasks into a bite-sized implementation plan. When the plan is ready, invoke `skills/subagent-driven-development/SKILL.md` to execute with two-stage review.

## Related Skills

- `skills/harness-engineering/SKILL.md` — Wiring Matrix canonical + 5-dim audit.
- `skills/writing-plans/SKILL.md` — plan authoring.
- `skills/subagent-driven-development/SKILL.md` — execution with spec + quality review.
- `skills/test-driven-development/SKILL.md` — canonical TDD discipline.
- `skills/sdd-scan/SKILL.md` — static SDD compliance scanner.
- `skills/verification-before-completion/SKILL.md` — evidence-before-claim gate.
