---
name: authoring-roadmap
description: Use when creating or updating a macro roadmap for long-term project planning. Use when the user needs to establish strategic Waves, define Phases (deliverable units), set scope boundaries, and track progress across development sessions.
---

# Authoring a Macro Roadmap

## Overview

Create and maintain a growth-friendly macro roadmap that stays useful as the project evolves.

Core principle: a roadmap is a **living navigation artifact**, not immutable law. It grows with the project — continuously maintained, not created once and abandoned.

## When to Use

- Starting a new project and need strategic direction before coding
- The user says "let's plan the roadmap" or similar
- An existing roadmap needs updating after completing a Phase
- Converting a rough draft or brainstorming output into a structured roadmap

Do NOT use when the user wants to jump straight into a specific Phase — go to `brainstorming` instead.

## Hierarchy

```
Wave (fixed — strategic segment)
  └─ [Epic] (flexible — insert when a Wave has > 7 Phases)
       └─ Phase (fixed — atomic deliverable unit)
            └─ Stage 0~3 (fixed — execution lifecycle)
                 └─ Task (bite-sized work item inside tasks.md)
```

### Layer Definitions

| Layer | Required Fields | Optional Fields | Notes |
|:---|:---|:---|:---|
| **Wave** | Goal, Done Definition, Risks, Non-goals | CP + Sensor (naming: `CP-W<N>-<NN>`) | Strategic level. No implementation details. |
| **Epic** (flexible) | Goal, Non-goals, Phase list | — | Insert only when a Wave has > 7 Phases. Can be nested. |
| **Phase** | Goal, Depends on, Complexity, PRD/SysDesign/Tasks paths, Status | — | Atomic deliverable unit. Each Phase produces PRD + optional SysDesign + Tasks. |

### Phase Record Template

```markdown
### Phase N: <Name>

- **Goal:** <one sentence — what the world looks like when done>
- **Depends on:** <Phase X> | None
- **Complexity:** Lite | Full
- **PRD:** <path> | TBD | N/A
- **SysDesign:** <path> | TBD | N/A (Lite)
- **Tasks:** <path> | TBD | N/A
- **Status:** Not Started | In Progress | Done
```

### Complexity (Lite vs Full)

- **Lite:** No new public interfaces, no multi-module coordination → only PRD + Tasks
- **Full:** New exported functions/APIs OR 2+ modules need coordination → PRD + SysDesign + Tasks

Complexity is determined during `brainstorming` (Stage 1), not in the roadmap. The roadmap records the decision.

## Terminology Rules

| Term | Meaning |
|:---|:---|
| **Wave** | Strategic segment (Wave 1, Wave 2, ...) |
| **Epic** | Grouping layer between Wave and Phase (optional, flexible) |
| **Phase** | Atomic deliverable unit — gets its own PRD, SysDesign (if Full), and Tasks |
| **Stage** | Execution lifecycle within a Phase (Stage 0: Roadmap, Stage 1: PRD+SysDesign, Stage 2: Tasks, Stage 3: Execute) |

Avoid aliases that blur these meanings.

## Governance Principles

1. **Order by user journey** — Waves are sequenced by product/user value, not technical convenience.
2. **Freeze boundaries before execution** — A Phase's Non-goals and acceptance criteria must be locked before Stage 3 begins.
3. **At least one verifiable constraint per Phase** — Full Phases have CP-xx in SysDesign; Lite Phases have BDD acceptance criteria in PRD.

## Roadmap Discovery (New Roadmap)

When creating a roadmap from scratch, ask one question at a time. Include a recommended answer direction.

### Q1: Project Goal & Audience

> "What problem does this project solve? Who is it for?
>  If you could measure success with a single metric, what would it be?"

→ Produces: Roadmap top-level Goal + Value Metric

### Q2: What "Done" Looks Like

> "What does V1.0 (or the first usable version) look like?
>  What can users do when it's done?"

→ Produces: Wave Done Definition (coarse)

### Q3: What We're NOT Doing

> "What features seem important but you explicitly don't want to build in this stage?"

→ Produces: Wave Non-goals (guardrails against over-engineering)

### Q4: Wave Decomposition

> "If you split the goal into 2-4 major phases, how would you cut them?
>  Which comes first? Why?"

→ Produces: Wave breakdown + ordering rationale

### Q5: Phase Expansion (per Wave)

> "For Wave 1, what are the independently deliverable features or modules?
>  Just list them roughly — no need for precision yet."

→ Produces: Phase list under each Wave

### Q6: Risks & Dependencies

> "What's most likely to go wrong?
>  Are there any Phases that must be completed before others can start?"

→ Produces: Risks + Phase-level `Depends on`

### End Condition

When Wave breakdown, Phase list, Non-goals, and Risks all have answers, compile the draft roadmap and present for user confirmation.

## Roadmap Update Mechanism

### Agent Auto-Updates (low-risk, factual)

| Event | Update |
|:---|:---|
| PRD completed | Fill Phase's PRD path |
| SysDesign completed | Fill Phase's SysDesign path |
| Tasks completed | Fill Phase's Tasks path |
| Phase execution complete (tests pass) | Phase Status → Done |

### Agent Suggests, Human Confirms (high-risk, structural)

| Event | Agent Action |
|:---|:---|
| New Phase needed | Suggest: "Recommend adding Phase N+1: <name>. Reason: [X]. Add it?" |
| Wave Goal needs change | Suggest: "Wave 1 Goal may need adjustment because [X]." |
| New dependency discovered | Suggest: "Phase 5 may need Depends on: Phase 3." |
| Epic needs split/merge | Suggest: "Epic A has > 7 Phases. Split into A1 and A2?" |

## Connection to brainstorming

When `brainstorming` starts, it checks if a Roadmap exists:

- **Exists:** Agent reads it and asks: "Continue from Roadmap, or start an ad-hoc Phase?"
  - Continue → reads current Wave/Phase context, constrains brainstorming scope
  - Ad-hoc → runs standard brainstorming flow, does not modify Roadmap
- **Does not exist:** Normal brainstorming flow. No Roadmap required.

## File Placement

```text
docs/superpowers/roadmap.md
docs/superpowers/specs/
  YYYY-MM-DD-w1-p1-<topic>/
    prd.md
    sysdesign.md
    tasks.md
```

Phase folder naming:
- Roadmap Phase: `YYYY-MM-DD-w<N>-p<N>-<topic>` (with Epic: `w<N>-e<N>-p<N>`)
- Ad-hoc Phase: `YYYY-MM-DD-<topic>`

If a repository has different documentation conventions, follow the repository's own rules.

## Skill-Managed Assets

Keep these files inside this skill folder as reusable assets:

```text
skills/authoring-roadmap/project-hierarchy-structure.md
skills/authoring-roadmap/wave-template.md
```

When applying to a project, copy/adapt hierarchy content into:

```text
docs/superpowers/project_hierarchy_structure.md
```

## Section Order (Main Document)

```text
# <Project> Macro Roadmap
## 0. Terminology and Layer Rules
## 1. Current Status (living updates)
## 2. Wave 1
##    (Phases listed under each Wave)
## 3. Wave 2
## ...
```

## Common Mistakes

| Mistake | Fix |
|:---|:---|
| Using unclear milestone aliases | Standardize on Wave / Phase / Stage |
| Putting execution details in macro roadmap | Keep those in specs/<phaseName>/ |
| Placing Current Status at the end | Move it before Wave sections |
| Forcing identical fields at all layers | Use the layer definitions above |
| Leaving PRD/Tasks blank with no owner/date | Use `TBD(owner/ETA)` |
| Forgetting Non-goals | Non-goals prevent scope creep — always fill them |

## Related Skills

- `brainstorming` — reads Roadmap at startup, produces PRD for each Phase
- `writing-sysdesign` — produces SysDesign for Full Phases
- `writing-tasks` — produces Tasks for each Phase
- `spec-scan` — validates Phase documents
- `finishing-a-development-branch` — triggers Roadmap status update on Phase completion
