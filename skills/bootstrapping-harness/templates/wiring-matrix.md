# Project Wiring Matrix — <PROJECT_NAME>

Per-spec Wiring Matrices are preferred (see `skills/harness-engineering/SKILL.md`). This file is for project-wide / long-lived wiring that spans specs.

## Main Loop / Entry Point

| Order | Caller | Callee method | Argument source | Output / side-effect |
|---|---|---|---|---|
| 1 | <entry> | <subsystem>.Init(ctx) | <config> | <state set> |

## Event Handlers

| Trigger | Caller | Callee method | Precondition |
|---|---|---|---|
| <event> | <handler> | <method> | <precondition> |

Keep rows short. Per-spec design docs carry the detail.
