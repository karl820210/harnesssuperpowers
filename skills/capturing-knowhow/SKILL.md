---
name: capturing-knowhow
description: Capture session-learned KnowHow into a persistent project knowledge base. Use at session end, when the user corrects your mistaken assumption, when a fix root-caused to an undocumented constraint, when a discarded-then-replaced approach revealed a hidden trade-off, or when a design decision shifted. Feeds the Harness Engineering Flywheel; complements writing-sysdesign, writing-tasks, and the capture-knowhow-reminder hook.
---

# Capturing KnowHow

Turn session learnings into persistent, searchable project knowledge.

## Capture at the Moment of Surprise (not at session end)

Knowledge is born mid-task — when a non-obvious bug is root-caused, an assumption is corrected, or an approach is abandoned. By session end, compaction and drift have already diluted it. So:

1. **At the moment of surprise:** write 2-3 raw lines into the task's `implementation-notes.md` (create it if missing) — what surprised you, why, what worked. This takes seconds and does not break flow.
2. **At session end** (the `capture-knowhow-reminder` hook fires): **harvest** those notes into proper KnowHow entries using the procedure below. Harvesting from a file survives compaction; recalling from a compacted conversation does not.

If you reach session end with no notes but When-to-Capture criteria were met, still capture from memory — degraded capture beats none.

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

**Index lines are trigger conditions, not titles.** The area cell must name *the moment the knowledge is needed*, so a future session pulls the file at the right time. A bare label ("Rendering / canvas") files knowledge; a trigger ("Before touching canvas resize / DPR scaling → read §3, §5") intercepts behavior.

Template (maintained by `bootstrapping-harness`):

```markdown
| Trigger (when to read) | KnowHow file | Related skill | Related steering |
|---|---|---|---|
| Before touching canvas resize / DPR scaling → §3, §5 | knowhow/rendering.md | `.cursor/skills/canvas/` | `rules/canvas.md` |
| Adding goroutines / shared state on the server → §1 | knowhow/backend.md | `.cursor/skills/go-server/` | `rules/go.md` |
```

When a new entry changes *when* someone should look at its file, rewrite that file's trigger line in the same edit.

## The Capture Procedure

For each new KnowHow item:

0. **Route to the right home** — ask once: *where would the next victim of this mine be working?* This project → capture here. Sibling repos sharing the cause (same market family, shared tooling) → the workspace root's knowledge base. Editor/OS/toolchain-caused → the operator's global lessons file. No home at the right layer → capture here and tag the entry `(candidate for <layer>)`. See `docs/knowhow-promotion-protocol.md` § Knowledge homes.
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
4. **Consider promotion** — follow `docs/knowhow-promotion-protocol.md`: default is entry (T2) + a trigger-worded index line (T1). Promoting into any always-on steering/rule requires the protocol's three gates (recurrence-or-severity, compressible to one line, broadly applicable) **and user approval** — always-on content taxes every future session. Promote pointers, not content.
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

- `docs/knowhow-promotion-protocol.md` — when/how a captured lesson becomes an injected rule (tiers, gates, routing failures, demotion).
- `skills/writing-sysdesign/SKILL.md` — the Flywheel closes when captured KnowHow feeds new CP-xx or Wiring Matrix entries in the next SysDesign.
- `skills/harness-engineering/SKILL.md` — Flywheel concept canonical.
- `skills/writing-tasks/SKILL.md` — new tasks should consult relevant KnowHow entries before authoring.
- `skills/bootstrapping-harness/SKILL.md` — creates the KnowHow map + initial files.
- `skills/systematic-debugging/SKILL.md` — common upstream of capturable learnings.

## Hook Integration

The `capture-knowhow-reminder` hook (`Stop` / `agentStop`) nudges this skill at session end. The hook is a best-effort reminder; it never blocks the user and never writes files itself — this skill does the writing once invoked.
