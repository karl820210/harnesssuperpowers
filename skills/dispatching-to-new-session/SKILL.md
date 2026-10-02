---
name: dispatching-to-new-session
description: Use when the user asks to run a piece of work in a separate, new Claude session through a task card while the current session stays open — e.g. "用任務卡在新的session…執行", "開新 session 去做…", "派給新 session", "另開一個 session 跑…", or names the model/effort the new session should use. Not for continuing the current work in the next session, and not for in-session subagents.
---

# Dispatching to a New Session

## Overview

The current session stays as coordinator and hands ONE scoped job to a fresh session. The job travels as a **task card file**; the file is the new session's prompt. This is dispatch, not handover: nothing here ends the current session.

## Routing

| User intent | Use |
|---|---|
| Run job X in a new / separate session (this session continues) | **this skill** |
| Continue *this* work next session; context nearly full; stage ends | `next-session-handover` |
| Parallel work inside this session | `dispatching-parallel-agents` |

"任務卡" alone does not mean handover — decide by whether the current session's work continues elsewhere (handover) or a separate job is sent out (dispatch).

Invoke only on explicit user request. If you think a job would suit a new session, say so in one line; do not write a card unasked.

## Before writing

Check the handover folder and the job's intended output paths for an existing card or report on the same job. If one exists (consumed or not), tell the user what exists and ask before writing a new card.

## The card (always a file — no exceptions)

**Location:** the project's handover folder (superpowers projects: `docs/superpowers/handover/`), filename `YYYY-MM-DD-dispatch-<topic>.md`. Shares the folder's Consumed-by lifecycle with `next-session-handover`.

**Language:** the project's output-language convention; else the conversation language.

**Required slots, in this order** — every slot present, none merged away:

1. **Header** — recommended model + effort; job nature (read-only analysis / implementation / …); the rules: on start add `Consumed-by: <date> <task>` at the top; on finish add `Result: <date> <one-line conclusion> → <output path>` under it.
2. **Transient notes** — inputs (exact files, measurement conditions), conclusions already established that must not be re-derived (cite where they live), hypotheses to test. Only what is not already written in some document.
3. **Resume-at** — the first concrete step.
4. **Current status** — branches / repos, dirty state, whether commits are allowed.
5. **SSOT pointers** — reports, phase folder, knowhow entries, tools. Pointers, never copied content.
6. **Quick verification commands** — minimal commands proving the inputs exist.
7. **Prompt** — goal; run `/using-superpowers` first; state that the brainstorming→PRD SDD pipeline does not apply unless the job itself is SDD work; method (subagent split, models); **verification requirement** (analysis → fresh-context adversarial review before final; implementation → run/compile evidence); output paths; STOP conditions (ask the user before re-measuring, changing code to verify, commit/push, choosing what to implement).
8. **Return method** — pick one row below and write it out.

Every path in the card is absolute. If the card or the files it references are untracked in the current checkout, say so and tell the new session to read/write those absolute paths even when started in a worktree (no copies inside the worktree).

## Return method (choose by job purpose; always written in slot 8)

| Job purpose | Return method | Card must contain |
|---|---|---|
| Analysis / investigation | file return | report + evidence absolute paths; `Result:` line on finish |
| Implementation | git result + file return | branch, commit rules, STOP before commit/push; `Result:` carries commit hashes |
| Long-running, this session must react when done | `cross-session-comm` (if available) **plus** `Result:` line | this session's title for addressing; the message to send |
| Deliverable for the user, no follow-up here | file return to user | output paths; `Result:` optional |

## Launching (do both)

**Launch prompt** (used by every path below): the card's absolute path; "the whole file is the prompt"; the worktree/absolute-path note; one-line job summary.

**Model + effort:** user-specified wins; otherwise recommend by job (judgment/analysis → Opus high; bulk mechanical scanning → Sonnet). State it in the card header and in your reply.

**A. Session chip — when `spawn_task` and session-management tools are available.** A model/effort switch applies only from the target's *next* turn, so the new session's first turn must be cheap:

1. `spawn_task` with a **standby prompt**: "reply one line that you are ready and wait; the job is the card at `<absolute path>`; start when a launch message arrives or the user says 開工". Do not put the job itself in the chip prompt.
2. When notified that the user started the chip, find its session id (`list_sessions` / `get_session`: the new row whose `parentSessionId` is this session).
3. If its `model` / `effort` differ from the recommendation, call `set_session_model` / `set_session_effort` on it. Moving to a more expensive model may ask the user to approve.
4. Send the launch prompt to it (`SendMessage` to its `local_…` id, or `send_message`). Confirm delivery.

If this session is gone when the chip starts, the new session stays on standby until the user tells it to start — that is expected; the card is intact.

**B. Always** print the launch prompt in a fenced block, with the recommended model + effort, so the user can open a session elsewhere (terminal, Cursor, another app) and paste it.

## Pre-dispatch checklist

- [ ] All 8 slots present, in order
- [ ] Verification requirement written
- [ ] Return method chosen and written; `Result:` rule in the header
- [ ] All paths absolute; worktree note if anything is untracked
- [ ] Model + effort in the card header and in the reply
- [ ] Chip created with a standby prompt (if available) **and** launch prompt printed
- [ ] After the chip starts: model/effort set to the recommendation, launch prompt delivered

Any box unchecked → do not dispatch yet.
