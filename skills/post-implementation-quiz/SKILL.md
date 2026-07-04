---
name: post-implementation-quiz
description: After a large change, produce a report plus a quiz the user must pass before merging. Use when a diff is too large to absorb by reading, when work touched domains the user doesn't know, when the user says "quiz me" / "考我" / "實作後測驗", or as an optional gate at finishing-a-development-branch time. Turns rubber-stamp reviews into verified understanding.
---

# Post-Implementation Quiz

After a long stretch of agent work, reading the diff gives the user surface familiarity, not understanding. If they can't answer questions about what changed and why, they don't own the change yet — and un-owned changes rot. This skill produces a report + quiz pair; passing the quiz is the merge gate.

## When to trigger

Any of: the change spans many files or an unfamiliar subsystem; the user delegated whole decisions (not just execution); the change will be maintained by the user long after this session; the user asks for it. Skip for small diffs the user watched being made.

## Step 1: The report

Write a report (file or message, scaled to the change) with four sections:

1. **Context** — what problem this change solves, what state the code was in before.
2. **Intuition** — the mental model needed to reason about the new code: the one or two ideas that make everything else obvious. This is the section that separates a report from a changelog.
3. **What changed** — per area, what was done and *why this way* (including roads not taken).
4. **Sharp edges** — what will bite the next maintainer: fragile spots, deliberate hacks, follow-ups deferred.

## Step 2: The quiz

3–7 questions. Good questions target **decisions and behavior**, not trivia:

- ✅ "A request comes in with X while Y is mid-flight — what happens now, and what would have happened before this change?"
- ✅ "If you needed to add another market variant, which file do you touch first and why?"
- ✅ "Why was approach A chosen over B here — what breaks under B?"
- ❌ "What is the name of the new function?" (trivia — tests memory, not understanding)

Every question must be answerable from the report + diff, and gradeable against them — no opinion questions.

## Step 3: Grade honestly

- The user answers; grade each answer against the actual code, citing `file:line` for corrections.
- Wrong or shaky answers → re-explain *that topic specifically*, then re-quiz with a new question on the same topic. Do not wave a wrong answer through — the gate exists to catch exactly this.
- All passed → state it plainly; the merge gate is cleared. Record any topic that needed two rounds as a `capturing-knowhow` candidate (it confused the human once; it will confuse again).

## Integration

- `skills/finishing-a-development-branch/SKILL.md` — offer this as an optional gate before the merge options when the change qualifies under "When to trigger".
- `skills/next-session-handover/SKILL.md` — a failed quiz topic is a signal the handover doc needs that topic spelled out.
- `skills/capturing-knowhow/SKILL.md` — twice-confused topics become KnowHow entries.
