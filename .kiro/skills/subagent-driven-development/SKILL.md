---
inclusion: manual
name: subagent-driven-development
description: Use when executing implementation plans with independent tasks in the current session
---

<!-- SUPERPOWERS_ADAPTER -->

# Subagent-Driven Development (Kiro Adapter)

> **Canonical**: `skills/subagent-driven-development/SKILL.md`

## Quick Reference

- **When to use:** executing a plan with independent tasks, staying in the current session, wanting fresh-context subagents per task.
- **Main output:** each task implemented + two-stage review (spec compliance → code quality) + commit.
- **Key steps:**
  1. Read plan, extract all tasks with full text.
  2. For each task: dispatch implementer → dispatch spec reviewer → dispatch code quality reviewer → mark complete.
  3. After all tasks: dispatch final reviewer → invoke `finishing-a-development-branch`.

## Full Content

See canonical → `skills/subagent-driven-development/SKILL.md`.
