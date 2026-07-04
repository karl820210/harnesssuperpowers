# KnowHow Promotion Protocol

> **Who reads this, when:** any agent deciding whether a captured lesson should change future sessions' behavior — i.e., every time `capturing-knowhow` Step 4 ("Update steering") is reached, and during periodic harness audits (`harness-engineering`). This protocol closes the loop gap: *when and how does captured KnowHow become an injected rule?*

## The problem this solves

Without this protocol, knowledge has only two homes: buried in KnowHow files nobody re-reads, or promoted to always-on steering that taxes every session's context window. Both fail: the first gives unknown read-rates, the second crowds out the actual task and triggers early compaction. The fix is a middle tier: **promote pointers, not content.**

## The four injection tiers

| Tier | What lives here | Context tax | Examples |
|---|---|---|---|
| **T0 — always-on iron rules** | Behavioral rules ≤2 lines that apply to nearly *every* session | Paid every session — keep tiny | "never claim done without verification evidence" |
| **T1 — always-on trigger index** | One line per knowledge area, written as a **trigger condition**, pointing to T2 content | A few tokens per line, paid every session | "Touching Python 2.7 serialization → read `knowhow/backend.md` §7 first" |
| **T2 — on-demand KnowHow body** | Full numbered entries (Context/Problem/Resolution/Lesson) | Zero until pulled | `docs/superpowers/knowhow/*.md` |
| **T3 — observation buffer** | Raw per-task notes not yet worth an entry | Zero | the task's `implementation-notes.md` |

Every capture lands at **T2** (a numbered entry) with its area's **T1** index line kept trigger-worded. T0 is exceptional.

## Index lines must be trigger conditions, not titles

A title does not intercept behavior; a trigger condition does.

- ❌ `| Rendering / canvas | knowhow/rendering.md |` — reads as a filing label; no session will pull it at the right moment.
- ✅ `| Before touching canvas resize or DPR scaling → read knowhow/rendering.md §3, §5 | knowhow/rendering.md |` — names the moment the knowledge is needed.

When adding a T2 entry, rewrite its area's index line if the new entry changes *when* someone should look.

## Promotion gates (T2 → T1 wording change is free; T2 → T0 is expensive)

Propose promoting a lesson into always-on steering/rules **only when all three hold**:

1. **Recurrence or severity** — the same lesson has ≥2 KnowHow entries (or 1 entry + 1 routing failure, see below), OR a single occurrence had irreversible/expensive consequences (data loss, wrong push, production break).
2. **Compressible** — it can be stated as a one-line behavioral rule with a clear trigger. If it needs a paragraph, it stays at T2 and only its T1 index line gets sharpened.
3. **Broad applicability** — it would have changed behavior in most recent sessions, not just one task type. Task-type-specific rules belong in the matching skill, not in always-on steering.

**Approval:** additions to any always-on file (steering with `inclusion: always`, `.mdc` with `alwaysApply`, session-start-injected content) require explicit user approval — they tax every future session. Additions to T2 files and T1 wording changes do not.

- ✅ Example promotion: "PowerShell 5.1 writes UTF-16 by default" recurred in 3 entries across 2 projects → propose one T0 line: "PowerShell writing files read by other tools: always pass `-Encoding utf8`."
- ❌ Anti-example: a subtle Unity WebGL memory quirk seen once, needing 10 lines of context → stays a T2 entry; its area's T1 line becomes "Changing WebGL memory settings → read knowhow/client.md §12 first."

## Citation discipline and routing failures (the feedback signal)

- When a session actually uses a KnowHow entry, it should cite it (`knowhow/backend.md §7`) in its notes or report. This is the cheap proxy for read-rate.
- **Routing failure:** a session re-trips a mine that was already recorded in KnowHow (discovered after the fact). Record it on the entry itself: append `(routing-failure: <date>, <one line how it was missed>)` to that entry's Lesson line. A routing failure means the *index line* failed, not the entry — rewrite the trigger wording first. Two routing failures on one entry = automatic promotion candidate under gate 1.
- Honest limit: without external tooling there is no true read-rate metric. Citations and routing-failure records are proxies; treat their absence as "unknown", not "working".

## Demotion and pruning (promotion's mandatory counterpart)

- An always-on rule that has not changed behavior in ~10 sessions is a demotion candidate: move it back to T2 and leave only a T1 trigger line (user approval, same as promotion).
- Each always-on steering/rules file should stay small enough to read in one glance; when one exceeds ~60 lines, the next edit must propose consolidation before adding.
- KnowHow files: when an area file exceeds ~30 entries, consolidate duplicates and archive superseded entries to `knowhow/archive-<area>.md` (keep numbering; note "archived" in place).

## Capture timing (feeds this protocol)

Capture raw material **at the moment of surprise**, not at session end: when a non-obvious bug is root-caused, an assumption is corrected, or a path is abandoned — write 2-3 lines into the task's `implementation-notes.md` (T3) immediately. The session-end hook (`capture-knowhow-reminder`) then triggers a **harvest** from those notes into T2 entries, not a from-memory recall. Harvesting from a file survives context compaction; recalling from a compacted conversation does not. See `skills/capturing-knowhow/SKILL.md`.

## Knowledge homes across layers

Some lessons do not belong to the current project. At capture time, ask once: *where would the next victim of this mine be working?*

1. **This project** → the project's `docs/superpowers/knowhow/`.
2. **A multi-project workspace root** (sibling repos share the cause: same market family, shared tooling) → the workspace root's knowledge base, if it has one.
3. **The operator's whole environment** (editor/OS/toolchain-caused) → the operator's global lessons file, if the machine has one.

If no home exists at the right layer, capture locally at T2 and flag the entry `(candidate for <layer>)` so a later audit can relocate it.

> Machine-specific note (this fork): the global home on this machine is `E:\project\AI\harness-core\lessons.md`, governed by `E:\project\AI\harness-core\maintenance.md` §3; the layering rules live in `E:\project\AI\harness-core\layering.md`. Portable deployments should replace this note with their own locations.
