---
name: next-session-handover
description: Use when the user mentions session-related words and wants a reusable handover prompt generated as a standalone markdown file for the next session, with medium information density and full superpowers workflow gates. Also triggered proactively when context window is nearly full.
---

# Next Session Handover

## Overview

Generate a medium-density handover markdown where **the entire file** is the prompt for the next session (paste whole file into chat). Use this when context is insufficient, a stage ends and work must continue next session, or context window is nearly full.

Core principle: the handover **points to** persistent state (Roadmap, PRD, Tasks) and only adds transient information not already in those documents.

## When to Use

Use when ANY of these are true (OR):

- The user explicitly requests a handover file for the next session
- Context window is nearly full and work is incomplete (proactive trigger)
- A Stage ends and work must continue next session

Do NOT use when:

- The user only wants a verbal summary (no file)
- The user did not mention "session" and context is sufficient
- The user mentions session but only asks "what did we do this session / summarize" without a handover-file intent

## Required Inputs (ask only if missing)

- **topic**: The handover topic (e.g. Phase 2 auth system)
- **resume-at**: The next session entry point (required; single value, e.g. "Stage 2: writing-tasks" or "Stage 3: Task 4")
- **SSOT pointers** (fixed order; must be locatable)
  1) Roadmap: `docs/superpowers/roadmap.md` or N/A
  2) Phase folder: `docs/superpowers/specs/<phaseName>/` or N/A
  3) PRD: `specs/<phaseName>/prd.md` or N/A
  4) SysDesign: `specs/<phaseName>/sysdesign.md` or N/A (Lite)
  5) Tasks: `specs/<phaseName>/tasks.md` or N/A
  6) Related knowhow (if relevant)
- **current status**: whether branch is expected clean + one-line stage status
- **transient notes** (optional): only include information NOT already in the above documents — e.g. "Task 3 failing test written but implementation not started", "dt unit is ms not s", "decided against approach B because of X"

## Output Location & Naming

- **Folder**：`docs/superpowers/handover/`
- **Filename**：`YYYY-MM-DD-next-session-<topic>.md`
- Use kebab-case for `<topic>`; avoid spaces.

## Lifecycle (Consumed-by marking)

This folder is shared with agent-initiated safety-net handovers (see Relation section below), so **all** files in it follow one lifecycle:

- A session that takes over a handover adds one line at the **top** of the file: `Consumed-by: <date> <one-line task description>`. Files are never auto-deleted; the folder is the history, cleanup is the user's call.
- A session that *discovers* an unconsumed handover it was not explicitly told to resume must **ask before taking over** — the file may be prepared for a different session or moment.
- When generating a new handover for a task that already has an unconsumed one, carry its unfinished items forward (or explicitly mark them abandoned) — never silently orphan them.

## Handover Content Contract

The handover file **itself is the prompt**. Do NOT wrap a separate "starter prompt" code block. Structure:

1) `#` Title: `Next session handover`
2) `Transient notes` (optional; omit if empty)
3) `Resume-at` (required)
4) `Current status`
5) `SSOT pointers` (fixed order; appear once)
6) `Quick verification commands` (run at start of next session; minimal set only)
7) `Prompt`
   - MUST include:
     - Explicitly require running `/using-superpowers` first
     - Audit steps MUST use subagents (executable rules):
       - `/spec-scan`: executed via a subagent, reporting PASS/FAIL + must-fix list
       - Plan Review: dispatch a general-purpose subagent filling the template at `skills/requesting-code-review/code-reviewer.md` (must-fix/should-fix)
       - Code Review: same template dispatch (changes + risk review)
     - Fixed workflow order (do not change; includes review loops and two human confirmation gates):
       - `brainstorming -> PRD`
       - `-> (Full) writing-sysdesign -> spec-scan loop until PASS`
       - `-> STOP for human confirmation (spec gate)`
       - `-> writing-tasks -> spec-scan (cross-file) loop until PASS`
       - `-> STOP for human confirmation (tasks gate)`
       - `-> commit -> using-git-worktrees -> subagent-driven-development`
       - `-> per task: implementer -> task reviewer (spec + quality verdicts) -> fix loop`
       - `-> finishing-a-development-branch`
     - Stop conditions (exceptions that require human):
       - Spec confirmation gate / Tasks confirmation gate
       - Engineering decisions / risky operations / irreversible actions / push

## Output Template (copy/paste skeleton)

When generating the handover file, emit this skeleton (keep section order; omit `Transient notes` entirely if empty):

```markdown
# Next session handover

## Transient notes (optional; omit if empty)

- <only information NOT in Roadmap/PRD/SysDesign/Tasks>

## Resume-at (required)

Resume-at: <single value, e.g. "Stage 2: writing-tasks for Phase 2">

## Current status

- Branch: <branch-name> (expected clean / has uncommitted changes)
- Stage: <Stage 0/1/2/3>

## SSOT pointers (fixed order)

1) Roadmap: <path or N/A>
2) Phase folder: <path or N/A>
3) PRD: <path or N/A>
4) SysDesign: <path or N/A (Lite)>
5) Tasks: <path or N/A>
6) Related knowhow: <path or N/A>

## Quick verification commands (run at start of next session)

```powershell
git status -sb
<fill-me: project-specific verify command if needed; otherwise omit>
```

## Prompt

I want to continue <topic> in this session.

Run `/using-superpowers` first. Use subagents for audits (`/spec-scan`; Plan/Code Review via a general-purpose subagent filling `skills/requesting-code-review/code-reviewer.md`).

The workflow MUST be:
brainstorming -> PRD
-> (Full) writing-sysdesign -> spec-scan loop until PASS
-> STOP for human confirmation (spec gate)
-> writing-tasks -> spec-scan (cross-file) loop until PASS
-> STOP for human confirmation (tasks gate)
-> commit -> using-git-worktrees -> subagent-driven-development
-> per task: implementer -> task reviewer (spec + quality) -> fix loop
-> finishing-a-development-branch

Proceed automatically. STOP and ask me when:
- Spec confirmation gate / Tasks confirmation gate
- Engineering decisions / risky operations / irreversible actions / push
```
```

## Environment / Rules

- Unless exceptional, do NOT restate environment/command constraints in the handover; rely on project rules (e.g. `.cursor/rules/harnesssuperpowers-environment.mdc`).

## Relation to the operator handover protocol

This skill produces the **planned** handover (user-driven, SDD-flavored, file-is-the-prompt). Machines with an operator-layer handover protocol also have an **agent-initiated safety-net** handover (generic five-section format: goal & status / done with evidence / remaining / blockers & landmines / agent assignments) written into the same folder under the same naming and Consumed-by rules. Section mapping: Resume-at + Current status ≈ goal & status; SSOT pointers + verification commands ≈ done-with-evidence (evidence by pointer); Transient notes ≈ blockers & landmines (same discipline: record failure trails, not just conclusions). Use this skill when the user asks for a handover or work is inside the SDD pipeline; use the generic format for non-SDD tasks and emergency interrupts.

## Common Mistakes

- Duplicating SSOT pointers (once in a section and again inside Prompt)
- Turning the handover into a tutorial for writing specs/tasks (belongs in rules/knowhow/plan)
- Setting multiple values for `Resume-at` or writing it as a tutorial (single value only)
- Forgetting the two human confirmation gates (spec / tasks)
- Restating information already in PRD/SysDesign/Tasks (handover only adds transient info)
