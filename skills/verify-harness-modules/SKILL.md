---
name: verify-harness-modules
description: Verify every harness module deployment on this machine against its SSOT. Use after any module SSOT update + re-injection, on a monthly cadence, when deployment drift is suspected, or when the user says "驗證模組" / "verify modules" / "模組漂移檢查". Reads each injection root's handshake manifests (*-injection.md), checks SSOT commit freshness and per-file hashes, reports PASS / STALE / MODIFIED per module, and routes MODIFIED findings to the recycle SOP.
---

# Verify Harness Modules

Machine-wide drift check for installed harness modules (the plugin, company skills, ai-usage pair, claude-channels, and any future registered module).

## Procedure

1. **Resolve the operator framework root.** `HARNESS_CORE_ROOT` comes from the machine's operator-framework config (`machine-config.md`; the global CLAUDE.md routing table states the path). If unresolvable, ask the user.
2. **Run the verifier:**
   ```
   python <HARNESS_CORE_ROOT>\scripts\verify-modules.py
   ```
   No arguments — it discovers `*-injection.md` manifests under the machine's injection roots by convention. Pass explicit manifest paths to check a single module.
3. **Read the verdict table.** Meaning of each verdict and the required follow-up:
   - `PASS` — deployment matches SSOT; nothing to do.
   - `STALE` — SSOT moved ahead of the deployed copy; re-run that module's INSTALL.md update flow (idempotent re-injection), then re-verify.
   - `MODIFIED` / `MISSING` — deployed files were edited or deleted in place; follow the recycle SOP in `<HARNESS_CORE_ROOT>\module-contract.md` §3 (re-render → diff → human review → commit to the module's designated branch → re-inject → re-verify). Do NOT silently overwrite a modified deployment — the local edit may be the newest version of that content.
   - `BROKEN` — manifest unreadable; re-run that module's injection to regenerate it.
4. **Write back the registry.** Update the「最後驗證」column for each checked module in `<HARNESS_CORE_ROOT>\harness-modules.md` with the date and verdict (factual update, no approval needed).
5. **Report** the table plus actions taken to the user. If anything was recycled, list the resulting SSOT commits.

## Cadence

Mandatory after any module SSOT update + re-injection; otherwise monthly. Do not wire this as an always-on hook — it is an on-demand gate.
