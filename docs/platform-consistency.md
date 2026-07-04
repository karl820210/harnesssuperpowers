# Platform Consistency Policy

> **Who reads this, when:** anyone adding or changing a hook, steering file, or always-on rule; and auditors checking why a behavior exists on one platform but not another. This file is the single place where cross-platform behavior parity is declared — including the *deliberate* gaps.

## Current wiring (verified 2026-07-04, post v6.1.1.H merge)

| Behavior | Claude Code (`hooks/hooks.json`) | Cursor (`hooks/hooks-cursor.json`) | Kiro (`.kiro/hooks/`, `.kiro/steering/`) | Codex |
|---|---|---|---|---|
| Session-start injection (using-superpowers) | `SessionStart` hook → `session-start` | `sessionStart` hook → `session-start` | No hook; `inclusion: always` steering files carry the always-on load | **None by design** (native skill discovery; `.codex-plugin/plugin.json` declares empty hooks) |
| Spec compliance check on edit | `PostToolUse` (matcher `Edit\|Write\|MultiEdit`) → `spec-sdd-check` | `afterFileEdit` + `afterTabFileEdit` → `spec-sdd-check` | `fileEdited` hook, glob-limited to spec paths → `spec-scan` | None |
| Session-end KnowHow reminder | `Stop` → `capture-knowhow-reminder` (async) | `stop` → `capture-knowhow-reminder` | `agentStop` hook (`knowhow-sync.kiro.hook`) → `capturing-knowhow` | None |
| Reminder redundancy layer | hook only (1 layer) | hook + `.cursor/rules/harnesssuperpowers-reminders.mdc` (2 layers) | hook + `knowhow-sync-rules.md` steering (2 layers) | None |
| Pre-commit docs check | none | none | `pre-commit-check.kiro.hook` — **disabled** (`enabled: false`) | None |

## Policy

1. **Parity by default.** A new loop-relevant behavior (capture, injection, compliance check) must be wired on Claude Code, Cursor, AND Kiro in the same change — or its absence recorded in the Limitations table below. A behavior wired on one platform only, without a Limitations entry, is a defect. Adding a NEW Limitations row is itself a policy decision: it requires explicit user approval, recorded in the commit message.
2. **Codex follows upstream main, untouched.** Codex intentionally has no hook wiring (upstream design: native skill discovery, empty `hooks` declaration). Do NOT add fork mechanisms to Codex packaging; if a fork mechanism cannot work on Codex, add a row to Limitations instead of implementing.
3. **Semantic parity, not mechanical parity.** Platforms may implement the same behavior differently (hook vs always-on steering). What must match is the *observable effect*: same trigger moment, same guidance content, same canonical source file. When content lives in two places (e.g., hook script + steering reminder), both must point at the same canonical skill rather than duplicating its text.
4. **Filtering granularity is allowed to differ** (Claude/Cursor fire on every edit and filter inside the script; Kiro filters by glob) as long as the *effective* trigger set is the same for spec files.
5. **Weight discipline applies per platform.** Always-on additions require the gates in `docs/knowhow-promotion-protocol.md` on every platform — Kiro's `inclusion: always` steering is the easiest place to accumulate silent context tax; audit it against the same ≥recurrence/compressible/broad gates.

## Known limitations (deliberate, not defects)

| # | Gap | Why it stays |
|---|---|---|
| 1 | Codex: no session-start injection, no capture reminder, no spec check | Upstream design decision (native skill discovery; empty hooks suppress auto-discovery). Fork policy: follow main, do not extend. |
| 2 | Claude Code has 1 reminder redundancy layer (hook only) vs Cursor/Kiro's 2 | Claude Code hooks fire reliably; a duplicate always-on layer would double-pay context tax for no observed failure. Revisit only on evidence of missed reminders. |
| 3 | Kiro has no session-start hook; always-on steering substitutes | Kiro's steering model already loads on every session; a hook would duplicate injection. |
| 4 | `pre-commit-check.kiro.hook` is disabled | Pre-commit checking is delegated to target projects (materialized by `bootstrapping-harness`), not the plugin repo. Enabling here would double-fire in bootstrapped projects. |
| 5 | Kiro `afterTabFileEdit` equivalent does not exist | Kiro's `fileEdited` covers both manual and tab edits; no gap in effect. |

## Change checklist (run before committing any hook/steering change)

- [ ] All three active platforms wired or a Limitations row added/updated.
- [ ] JSON files parse; referenced scripts exist (`hooks/run-hook.cmd` resolves the name).
- [ ] Content points at one canonical file; no forked copies of guidance text.
- [ ] If the change adds always-on weight: promotion gates satisfied + user approval recorded in the commit message.
- [ ] This file's wiring table updated in the same commit.
