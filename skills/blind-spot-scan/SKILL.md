---
name: blind-spot-scan
description: Pre-work scan that surfaces unknown unknowns before implementation gets expensive. Use when entering an unfamiliar codebase or domain, before large or hard-to-reverse work, when the user says "blind spot scan" / "盲點掃描" / "find my unknowns", or as a front-end to brainstorming/grill-me when the right questions themselves are not yet known.
---

# Blind Spot Scan

The map (prompt, plan, assumptions) is not the terrain (codebase, environment, real constraints). Every gap between them is an *unknown*, and work quality is set by how many unknowns get surfaced **before** they are hit mid-implementation. This skill hunts the worst kind: the questions nobody has thought to ask.

## When NOT to use

Small edits in familiar territory; tasks where the terrain is already well mapped by specs and recent work. This scan costs one bounded exploration round — spend it where the map is thin.

## Procedure

1. **State the map.** Write down, in a few lines: the task as understood, the constraints given, and — critically — *the assumptions being made without evidence*. If the user provided their starting point ("I know X well, Y not at all"), include it.
2. **Probe the terrain (bounded, read-only).** Explore what the map claims: entry points, call sites of things to be changed, configs, tests, sibling implementations of similar features, platform/environment constraints. Time-box it; the goal is contact with reality, not full coverage. Dispatch a read-only subagent for wide sweeps.
3. **Report unknowns in four buckets:**
   - **Known knowns** — map claims verified against terrain (one line each; contradictions surface here).
   - **Known unknowns** — open questions already visible; note how each would be resolved (ask user / probe code / spike).
   - **Unknown knowns** — assumptions found embedded in the map that the user never stated but would instantly confirm or reject. Surface them as yes/no confirmations.
   - **Unknown-unknown candidates** — terrain features the map never mentions: hidden couplings, legacy behaviors, environment quirks, similar-but-divergent precedents ("Game42 does this differently"), things that would surprise the plan.
4. **Rank by architectural impact.** Lead with items whose resolution would change the approach (same test as `grill-me`: "if this surprised me, how much of the plan survives?"). Cap the report at ~10 items — an unranked list of 30 is another form of blindness.
5. **Hand off.** Items needing user answers → run `grill-me` (one at a time, impact-first). Items needing code evidence → probe or spike before planning. Then proceed to `brainstorming` / planning with the upgraded map.

## Output contract

For each item: **what** (one line) / **why it matters** (what breaks or changes if ignored) / **how to resolve** (ask | probe | spike). No item without a resolution path. Do not pad buckets — an honest "no unknown-unknown candidates found in scope X" beats invented risks.

## Integration

- `skills/brainstorming/SKILL.md` — run this scan first when entering unfamiliar territory; brainstorming then starts from a corrected map.
- `skills/grill-me/SKILL.md` — consumes this scan's "ask" items.
- `skills/systematic-debugging/SKILL.md` — mid-task surprises that a scan missed are capture candidates (`capturing-knowhow`).
