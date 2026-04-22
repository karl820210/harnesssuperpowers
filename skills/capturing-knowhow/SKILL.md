---
name: capturing-knowhow
description: Capture session-learned KnowHow into a persistent project knowledge base. Use at session end, when the user corrects your mistaken assumption, when a fix root-caused to an undocumented constraint, when a discarded-then-replaced approach revealed a hidden trade-off, or when a design decision shifted. Feeds the Harness Engineering Flywheel; complements sdd-workflow, writing-plans, and the capture-knowhow-reminder hook.
---

# Capturing KnowHow

Turn session learnings into persistent, searchable project knowledge.

## When to Capture

Capture if any of these is true:

1. A bug was fixed whose root cause was a constraint or behavior you did not know.
2. The user pointed out that your mental model was wrong.
3. An approach was tried, failed, replaced — and the reason matters next time.
4. An undocumented API / tool / framework behavior was discovered.
5. A design decision (ratio, sizing, protocol) shifted mid-work.

Do NOT capture:

- Typo fixes.
- Pure formatting changes.
- Repeated fixes of a pattern already in KnowHow.

## Discovery Contract

Resolve the project's KnowHow base in this priority order:

1. `${WORKSPACE_ROOT}/docs/superpowers/knowhow-map.md` + `docs/superpowers/knowhow/`
2. `${WORKSPACE_ROOT}/.kiro/skills/docs/` (legacy Kiro layout)
3. Nothing found → offer to run `skills/bootstrapping-harness/SKILL.md` to create the Layer 2 structure.

## The Map (`knowhow-map.md`)

A thin index that maps knowledge area → target KnowHow file → related skills / steering.

Template (maintained by `bootstrapping-harness`):

```markdown
| Knowledge area | KnowHow file | Related skill | Related steering |
|---|---|---|---|
| Rendering / canvas | knowhow/rendering.md | `.cursor/skills/canvas/` | `rules/canvas.md` |
| Go server / concurrency | knowhow/backend.md | `.cursor/skills/go-server/` | `rules/go.md` |
```

## The Capture Procedure

For each new KnowHow item:

1. **Classify** — look up the knowledge area in `knowhow-map.md`.
2. **Append** to the matching KnowHow file as a numbered entry:
   ```markdown
   ## <N>. <short title>

   **Context:** when/where it surfaced.
   **Problem:** what went wrong or was unknown.
   **Resolution:** what worked.
   **Lesson:** the takeaway in one sentence.
   ```
   - Numbers are monotonically increasing. Do not edit existing entries unless fixing a factual error.
3. **Update skill** — if the KnowHow changes a specification (sizes, formats, protocols), edit the matching skill's relevant section. Do NOT rewrite the whole skill.
4. **Update steering** — only if the KnowHow becomes a convention / rule / prohibition. Append to the matching steering file.
5. **Update checklist** — if the item is something worth checking every future task, add to the project's checklist file.

## Language Convention

Read the project's output language convention from `${WORKSPACE_ROOT}/docs/superpowers/README.md`. If unset, follow the current conversation language. KnowHow is long-lived, so a stable project-wide language matters more here than in one-off specs.

## Post-Capture Confirmation

Report to the user a short summary:

- KnowHow: `<file>` added entry `<N>. <title>`
- Skill: `<file>` — section `<name>` updated (or no skill changes)
- Steering: `<file>` — rule appended (or no steering changes)
- Checklist: item added (or no checklist changes)

Do not invent updates. If no target file exists, say so and suggest running `skills/bootstrapping-harness/SKILL.md`.

## Related Skills

- `skills/sdd-workflow/SKILL.md` — the Flywheel closes when captured KnowHow feeds new CP-xx or Wiring Matrix entries in the next spec.
- `skills/harness-engineering/SKILL.md` — Flywheel concept canonical.
- `skills/writing-plans/SKILL.md` — new plans should consult relevant KnowHow entries before authoring tasks.
- `skills/bootstrapping-harness/SKILL.md` — creates the KnowHow map + initial files.
- `skills/systematic-debugging/SKILL.md` — common upstream of capturable learnings.

## Hook Integration

The `capture-knowhow-reminder` hook (`Stop` / `agentStop`) nudges this skill at session end. The hook is a best-effort reminder; it never blocks the user and never writes files itself — this skill does the writing once invoked.
