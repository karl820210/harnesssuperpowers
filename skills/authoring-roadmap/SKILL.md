---
name: authoring-roadmap
description: Use when converting roadmap drafts into a structured macro roadmap, or creating one from brainstorming outcomes. Use when the user needs a coarse-grained roadmap with phase goals, done definitions, dependencies, correctness properties, sensors, and scope boundaries.
---

# Authoring a Macro Roadmap

## Overview

Convert a roadmap draft (or blank slate) into a growth-friendly macro roadmap that stays useful as the project evolves.

Core principle: a roadmap is a navigation artifact, not immutable law. Establish the structure first, then fill details incrementally.

## Layer-Weighted Strategy (Option 4)

Roadmap documents direction and decomposition. Detailed execution evidence belongs in L5 specs/plans.

| Level | Required | Recommended | Avoid |
|:---|:---|:---|:---|
| L1 (Roadmap/Wave) | Goal, Done Definition, Dependencies/Parallelism, Risks, Non-goals | >=1 CP+Sensor pair | Implementation details |
| L2 (Initiative) | Goal, Done Definition, Dependencies/Parallelism | >=1 CP+Sensor pair | Spec SSOT field at L2 |
| L3 (Epic) | Goal, Done Definition | >=1 CP+Sensor pair | Full test matrix |
| L4 (Feature) | One-line Value statement | Spec/Plan link or `TBD(owner/ETA)` | Full verification details |
| L5 (Phase) | N/A in macro roadmap | N/A in macro roadmap | Writing execution-level details in macro roadmap |

## Governance Model (Hybrid)

- **B-Shell (Workflow-first):** order strategic phases by user/product journey.
- **A-Core (Contract-first):** before L4 enters L5, freeze acceptance boundaries.
- **C-Shield (Automation-first):** require at least one CP+Sensor pair per major unit, with minimal sensor growth.

## Terminology Rules

- Use `Wave 1/2/3/...` for strategic sequencing.
- Keep `L5 Phase` for execution lifecycle only (`Spec/Plan -> Dev -> QA -> Deploy`).
- Avoid alternate aliases that can blur L5 meaning.

## Grill-Me Question Sequence

Ask one question at a time and include a recommended answer direction.

These questions align **product direction and acceptance boundaries** so the agent can discuss what to build and what “done” means.
They should not be used to decide how to present the roadmap formatting.

1. **Primary audience/use-case + top value metric**
   - Example: "Who is the primary reader, and what single metric proves we won the next stage?"
2. **Strategic product journey + scope cut**
   - Ask which end-to-end journey is prioritized first ("the first fight"), and what is explicitly out of scope for now.
3. **Wave ordering & dependency assumptions (B-Shell)**
   - Ask which strategic waves come first, and which assumptions must hold before later waves can start.
4. **Done definition at wave/initiative level (A-Core)**
   - Ask what 1–3 acceptance statements must be true for a wave to be considered done (coarse, not execution steps).
5. **Correctness properties + smallest evidence type (C-Shield)**
   - Ask which invariants (CPs) matter most, and what sensor/evidence is the minimal acceptable proof (tests/lint/logs/deterministic gate).
6. **Top risks & explicit non-goals**
   - Ask the biggest risks that could derail the next wave, and the non-goals to prevent scope creep.

## File Placement (HarnessSuperpowers Convention)

```text
docs/superpowers/Roadmap.md
docs/superpowers/project_hierarchy_structure.md
docs/superpowers/specs/
docs/superpowers/plans/
```

If a repository has different documentation conventions, follow the repository's own rules.

## Skill-Managed Assets

Keep these files inside this skill folder as reusable assets:

```text
.cursor/skills/authoring-roadmap/project-hierarchy-structure.md
.cursor/skills/authoring-roadmap/wave-template.md
```

When applying to a project, copy/adapt hierarchy content into:

```text
docs/superpowers/project_hierarchy_structure.md
```

## Section Order (Main Document)

```text
# <Project> Macro Roadmap
## 0. Terminology and Layer Rules
## 1. Dependency and Parallelism Map
## 2. Current Status (living updates)
## 3. Wave 1
## 4. Wave 2
## 5. Wave 3
## 6. Wave 4
```

## Common Mistakes

| Mistake | Fix |
|:---|:---|
| Putting Spec SSOT fields at L2 | Move links to L4 `Spec/Plan` |
| Using unclear milestone aliases | Standardize on Wave naming |
| Putting L5 Dev/QA details in macro roadmap | Keep those in specs/plans |
| Placing `Current Status` at the end | Move it before wave sections |
| Forcing identical fields at all layers | Use the layer-weighted strategy |
| Leaving Spec/Plan blank with no owner/date | Use `TBD(owner/ETA)` |

## Supporting Template

Use `wave-template.md` in this skill folder as the reusable starting point.
