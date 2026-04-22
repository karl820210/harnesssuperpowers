---
inclusion: always
---

# KnowHow Sync Rules (Kiro Steering Pointer)

## Canonical

- Skill: `skills/capturing-knowhow/SKILL.md`

## Why the steering file still exists

Kiro loads `inclusion: always` steering on every session. This file keeps a short reminder live in Kiro's context so the agent knows when to invoke `capturing-knowhow`.

## Trigger criteria (short form)

Capture when:
1. A bug was fixed with root cause in a previously unknown constraint.
2. The user corrected the agent's mental model.
3. An approach failed and was replaced; the reason matters next time.
4. An undocumented API / tool / framework behavior was discovered.
5. A design decision shifted (ratio, size, protocol).

Do NOT capture: typo-only, format-only, repeat of existing KnowHow.

## Kiro-only note

The `knowhow-sync.kiro.hook` on `agentStop` reinforces this reminder at session end. See `.kiro/hooks/knowhow-sync.kiro.hook`.
