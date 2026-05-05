# Project Development Hierarchy

This document defines the hierarchy structure for software development projects within the Superpowers framework, from strategic direction to atomic execution.

---

## 1. Hierarchy Overview

| Layer | Name | Focus | AI Agent Context |
| :--- | :--- | :--- | :--- |
| **Wave** | Strategic Segment | Long-term direction | Roadmap top-level grouping |
| **[Epic]** | Flexible Grouping | Organize when > 7 Phases | Optional — insert when needed |
| **Phase** | Atomic Deliverable | Independent feature/module | Gets PRD + SysDesign (Full) + Tasks |
| **Stage** | Execution Lifecycle | 0: Roadmap → 1: PRD+SysDesign → 2: Tasks → 3: Execute | Determines which skill to use |
| **Task** | Bite-Sized Work Item | 2-5 minute action | Individual steps in tasks.md |

---

## 2. Layer Definitions

### Wave (Strategic Segment)
* **Definition:** Strategic grouping sequenced by user/product journey. Usually 2-4 per project.
* **Fields:** Goal, Done Definition, Risks, Non-goals, CP + Sensor (optional)
* **Example:** Wave 1: Core Gameplay, Wave 2: Social Features, Wave 3: Monetization

### Epic (Flexible Grouping — optional)
* **Definition:** Intermediate grouping between Wave and Phase. Insert only when a Wave has > 7 Phases.
* **Fields:** Goal, Non-goals, Phase list
* **Example:** Epic: Boss Battle System (under Wave 1)

### Phase (Atomic Deliverable)
* **Definition:** An independently deliverable feature, module, or change. Each Phase produces its own PRD, optional SysDesign (Full), and Tasks.
* **Complexity:** Lite (PRD + Tasks) or Full (PRD + SysDesign + Tasks)
* **Example:** Phase 1: Fish Spawning System, Phase 2: Collision Detection

### Stage (Execution Lifecycle within a Phase)
* **Definition:** The development stage of a Phase. Fixed lifecycle:
    * **Stage 0 — Roadmap:** Strategic planning (handled by `authoring-roadmap`)
    * **Stage 1 — PRD + SysDesign:** Requirements and design (handled by `brainstorming` + `writing-sysdesign`)
    * **Stage 2 — Tasks:** Implementation planning (handled by `writing-tasks`)
    * **Stage 3 — Execute:** Coding and testing (handled by `subagent-driven-development`)

### Task (Bite-Sized Work Item)
* **Definition:** A single action that takes 2-5 minutes. Written in `tasks.md`.
* **Example:** Write failing test for spawning logic, implement spawn function, commit

---

## 3. Example Application (Game Development)

* **Wave 1:** Core Gameplay
    * **Phase 1:** Boss AI State Machine
        * Stage 0: Recorded in Roadmap
        * Stage 1: PRD (brainstorming) → SysDesign (Full — has CP-xx and Wiring Matrix)
        * Stage 2: Tasks (bite-sized implementation steps)
        * Stage 3: Execute (subagent-driven development)
    * **Phase 2:** Fish Spawning System
        * Stage 1: PRD (Lite — no new public interfaces)
        * Stage 2: Tasks
        * Stage 3: Execute
* **Wave 2:** Social Features
    * **Phase 3:** Leaderboard
    * **Phase 4:** Friend System

---

## 4. Key Design Decisions

### Fixed Ends, Flexible Middle

Wave and Phase are **fixed** layers that always exist. Epic is a **flexible** layer inserted only when needed (> 7 Phases under a Wave).

### Lite vs Full Complexity

| Signal | Complexity |
|:---|:---|
| New exported functions / API endpoints / public interfaces | Full |
| 2+ modules need to coordinate | Full |
| Neither signal present | Lite |

### Phase Naming Convention

| Type | Format | Example |
|:---|:---|:---|
| Roadmap Phase | `YYYY-MM-DD-w<N>-p<N>-<topic>` | `2026-05-04-w1-p1-fish-spawning` |
| With Epic | `YYYY-MM-DD-w<N>-e<N>-p<N>-<topic>` | `2026-05-04-w1-e1-p2-collision` |
| Ad-hoc Phase | `YYYY-MM-DD-<topic>` | `2026-05-05-login-bug` |
