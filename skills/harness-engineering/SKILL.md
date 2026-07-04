---
name: harness-engineering
description: "Framework health diagnostic tool — NOT a per-task gate. Use periodically: when onboarding a new project, after completing a major Phase, when agent quality degrades, or during scheduled reviews. Covers Feedforward (Skills/Steering), Feedback (Hooks/Tests), Wiring Integrity, Latent vs Deterministic boundary, and the Feedback Flywheel."
---

# Harness Engineering Framework

This skill integrates concepts from six core references — Martin Fowler, Garry Tan (YC), the Flywheel framework, Static → Dynamic Decomposition, Kief Morris's "On the Loop", and Anthropic's "Building Effective Agents" — into an actionable audit and improvement process (see the References section for details).

## Core Concepts

### Agent = Model + Harness

The Harness is everything wrapping the LLM model — it does not make the model smarter; it delivers the right context to the model at the right time.

A Harness is composed of five elements:

| Element | Location (cross-IDE)                                        | Role                                 | Abstraction |
|---------|-------------------------------------------------------------|--------------------------------------|-------------|
| Skills  | `skills/*/SKILL.md` (Superpowers), `.kiro/skills/`, `.cursor/skills/` | Fat Skills — domain knowledge & workflows (Feedforward, Inferential) | Project-specific |
| Steering| `CLAUDE.md`, `AGENTS.md`, `.kiro/steering/`, `.cursor/rules/` | Behavior rules & conventions (Feedforward, Inferential) | Project-specific |
| Hooks   | `hooks/*.json`, `.kiro/hooks/*.kiro.hook`                   | Automatic triggers (Feedback, Computational/Inferential) | Portable (detection patterns) |
| Specs   | `docs/superpowers/specs/`, `.kiro/specs/`                   | Structured development flow (Feedforward, Computational) | Project-specific |
| KnowHow | `docs/superpowers/knowhow/`, project knowhow files           | Accumulated lessons (Feedback Flywheel) | Project-specific |

Note: Hooks should be generic detection rules. Project-specific checks belong in Steering or per-project checklists.

### Feedforward vs Feedback (Martin Fowler)

- Feedforward (guide before the act): prevent errors before the agent acts. Skills, Steering, Spec templates.
- Feedback (detect after the act): detect and self-correct after the agent acts. Hooks, Tests, KnowHow Sync.
- Feedforward only → the agent encodes rules but never learns whether they work.
- Feedback only → the agent keeps repeating the same mistakes.

Both must coexist.

### Computational vs Inferential

- Computational (Deterministic): Tests, Linters, Type Checkers. Fast, reliable, run on every change.
- Inferential: AI Code Review, LLM as Judge. Slower, more expensive, non-deterministic.

### Latent vs Deterministic (Garry Tan)

Every step in the system is either Latent or Deterministic:
- Latent = requires model judgment (design decisions, code review, architectural choice).
- Deterministic = same input yields same output (tests, compilation, collision detection, SQL queries).

Confusing these two is the most common mistake in agent design. Stuffing a deterministic problem into the latent space = plausible-looking but completely wrong output.

### Thin Harness, Fat Skills (Garry Tan)

- Push intelligence up into Skills (the Latent layer).
- Push execution down into deterministic tools (the Deterministic layer).
- Keep the Harness thin — it should only do four things: run the model, read/write files, manage context, and enforce safety rules.

Anti-pattern: Fat Harness with Thin Skills — 40 tool definitions devouring half the context window.

### Resolver = Context Router

The Resolver is the routing table for context — when task type X appears, load document Y.

Across IDEs, Resolver is realized by three mechanisms:
1. **Skill description** — the model's auto-matching hook for user intent.
2. **Steering file glob / alwaysApply** — conventions loaded when specific files are opened (Cursor rules, Kiro `inclusion: fileMatch`).
3. **Hook event matcher** — reminders injected on specific events (Claude Code `PostToolUse` matcher, Kiro `fileEdited patterns`).

### Static Scaffolding → Dynamic Decomposition (Reference 2)

Three layers:
- Layer 1 (Static/T1): agent built-ins + community Skills — table stakes.
- Layer 2 (Flywheel): every correction is a Signal; the reason for the correction is written back into Skills/Steering.
- Layer 3 (Dynamic): Developer Judgment — On the Loop — real-time decisions about whether to open a new verification path.

Layer 2 is the KnowHow Sync mechanism. Layer 3 cannot be automated; it is the core value of a human on the loop.

### Feedback Flywheel (Martin Fowler / Kief Morris)

Every correction to the agent's output is a signal. That signal must be captured and fed back into the development process.

Concrete wiring in a Superpowers-enabled project:
- A session-end hook (`Stop` in Claude Code, `agentStop` in Kiro) triggers `capturing-knowhow` → updates Skills/Steering/checklists.
- This is not extra work; it is how the Static layer keeps getting sharper.

### Wiring Integrity

Missing module wiring is a recurring problem in AI agent development — the agent builds the parts correctly but never plugs them together.

Root cause: existing frameworks cover "how to build each part" but not "how to connect the parts".

Wiring is a deterministic problem (A must call B), but it gets placed in the latent space and left for the agent to "guess" via inference.

---

## Audit Process

When auditing Harness coverage, walk through the following dimensions in order:

### 1. Feedforward Coverage

Check that every development area has a corresponding pre-action guide:

```
For each module / package / directory:
  □ Is there a Skill describing its design intent and interfaces?
  □ Is there a Steering file describing the coding conventions?
  □ Does the Spec Design document define interface contracts (precondition/postcondition)?
```

### 2. Feedback Coverage

Check that every change has a corresponding post-action detector:

```
For each exported function/method:
  □ Is there a unit test?
  □ Is there a BDD scenario?
  □ Do the correctness properties (CP-xx) have PBT tests?
  □ Does it have a caller? (Wiring Integrity)
```

### 3. Wiring Integrity (Wiring Matrix)

This is the dimension most often missed. How to check:

```
For each main loop (game loop / request handler / event loop), confirm:
  □ The Design document's Wiring Matrix lists every subsystem that must be called.
  □ In the implementation, each subsystem is actually called at the correct time.
  □ Call order matches the Wiring Matrix.

For each newly added exported function/method:
  □ Does it have at least one caller?
  □ Does the caller invoke it at the right time? (Inside the main loop? On a specific event?)
  □ Does the caller pass the correct parameters?
```

### 4. Latent vs Deterministic Boundary

Check whether any deterministic problem has been dumped into the latent space:

```
Generic checklist:
  □ Data validation — must be Deterministic (schema validation, type checking).
  □ Module wiring — must be Deterministic (explicit call relationships).
  □ State machine transitions — must be Deterministic (finite states, explicit conditions).
  □ Design decisions — should be Latent (need human judgment).
  □ Code review — should be Latent.

Domain-specific examples (games):
  □ Collision detection — Deterministic.
  □ Bonus calculation — Deterministic.

Domain-specific examples (Web API):
  □ Permission checks — Deterministic.
  □ Response formatting — Deterministic.
```

### 5. Feedback Flywheel Health

```
  □ Is the session-end hook (Stop / agentStop) enabled? (KnowHow Sync)
  □ Is the pre-commit hook enabled? (Documentation updates)
  □ Is the spec-sdd-check hook enabled? (SDD compliance)
  □ Do KnowHow documents keep growing? (Knowledge is accumulating)
  □ Do checklists keep growing? (Lessons turn into check items)
  □ Does Steering receive feedback updates from KnowHow? (Closed loop)
  □ Any always-on rule unused for ~10 sessions? Propose demotion per
    docs/knowhow-promotion-protocol.md § Demotion — growth without
    pruning is also a failure mode
  □ Any KnowHow entry with routing-failure marks? Its index trigger
    line needs rewriting (same protocol, § Citation discipline)
```

---

## Remediation Priorities

When the audit reveals gaps, patch them in the following priority order:

### Priority 1: Computational Feedback (low cost, high confidence)

- Add missing unit tests.
- Add wiring-integrity checks (every exported function must have a caller).
- Add Hooks that run tests automatically.

### Priority 2: Feedforward Guide (prevent repeat errors)

- Translate KnowHow lessons into Steering rules.
- Turn recurring patterns into Skills.
- Add a Wiring Matrix to the Design document.

### Priority 3: Inferential Feedback (higher cost, covers semantics)

- Cross-model review (different AIs reading the same code).
- Semantic duplication detection.
- Architectural drift detection.

### Priority 4: Dynamic Layer (cannot be automated)

- Identify the high-risk moments that require human On-the-Loop judgment.
- Insert friction (intervenable checkpoints) at those moments.
- Reduce friction on low-risk flows.

---

## Wiring Matrix Template

Add this section to the Spec Design document to make inter-module call relationships explicit:

```markdown
## Wiring Matrix

### Main-Loop Call Chain

| Order | Caller | Method Called | Parameter Source | Output / Side Effect |
|-------|--------|---------------|-------------------|------------------------|
| 1 | {main loop} | {subsystem}.Update(dt) | {state source} | {broadcast message / state change} |
| 2 | ... | ... | ... | ... |

### Event-Triggered Call Chain

| Trigger Event | Caller | Method Called | Precondition |
|---------------|--------|---------------|---------------|
| {user action / message} | {handler} | {handler method} | {validation condition} |
| ... | ... | ... | ... |
```

> Example (game server Game Loop):
>
> | Order | Caller | Method Called | Parameter Source | Output |
> |-------|--------|---------------|-------------------|--------|
> | 1 | GameLoop | physics.Update(dt) | entities | — |
> | 2 | GameLoop | spawner.Tick(dt, count) | config | spawn event |
> | 3 | GameLoop | network.Sync() | entities | sync message |

---

## Task Structure Template (with Wiring Tasks)

Every "build a part" task must be immediately followed by a wiring task:

```markdown
- [ ] N. Implement {method name}
  - [ ] N.1 Write the BDD scenario
  - [ ] N.2 Write the failing test (Red)
  - [ ] N.3 Implement the minimum code (Green)
  - [ ] N.4 Refactor

- [ ] N+1. Wire: integrate {method name} into {caller}
  - [ ] (N+1).1 Call {method name} from {caller} (timing and parameters per the Wiring Matrix)
  - [ ] (N+1).2 Write the integration test verifying the full call chain
  - [ ] (N+1).3 Confirm the Wiring Matrix matches the implementation
```

---

## Relationship to the Existing Framework

```
Harness Engineering (this skill)
├── Feedforward Guides
│   ├── Skills (domain knowledge)
│   ├── Steering (behavior rules)
│   ├── Specs (structured flow)
│   └── Wiring Matrix (wiring contract) ← new
├── Feedback Sensors
│   ├── Hooks (automatic triggers)
│   ├── Tests (unit / integration / PBT)
│   ├── SDD/BDD/TDD workflow
│   └── Wiring-integrity checks ← new
├── Feedback Flywheel
│   ├── KnowHow Sync (session-end hook)
│   ├── Checklists (repeatable check items)
│   └── Steering feedback updates
└── Dynamic Layer (human On the Loop)
    ├── Planning quality judgment
    ├── Cross-context verification (spawn sub-agent)
    └── High-risk moment intervention
```

---

## Related Skills

- `skills/writing-sysdesign/SKILL.md` — produces SysDesign documents with CP-xx and Wiring Matrix.
- `skills/writing-tasks/SKILL.md` — task authoring that materializes CP-xx and Wiring Matrix into bite-sized tasks.
- `skills/verification-before-completion/SKILL.md` — per-task Iron Law verification (not 5-dimension audit).
- `skills/capturing-knowhow/SKILL.md` — the Flywheel feedback capture point.

## References

- Martin Fowler, "Harness engineering for coding agent users" (2026)
- Garry Tan (YC), "Thin Harness, Fat Skills" (2026)
- Kuan-Yu Hsieh, "Flywheel: Long-running Agent framework" (2026)
- Static Scaffolding → Dynamic Decomposition (2026)
- Kief Morris, "On the Loop" — In/Out/On the Loop, the three interaction positions
- Anthropic, "Building Effective Agents" — Workflows vs Agents
