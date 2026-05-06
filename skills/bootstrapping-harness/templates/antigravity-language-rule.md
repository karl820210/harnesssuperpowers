---
trigger: always_on
glob:
description: "HarnessSuperpowers — Output Language (Antigravity rule)"
---

# HarnessSuperpowers — Output Language (Antigravity rule)

This rule is always-on in Antigravity (`.agents/rules/`).

## Defaults

- Agent replies: use the user's language; if not specified, default to Traditional Chinese (繁體中文).
- Specs / plans / wiring-matrix: follow conversation language.
- KnowHow / knowhow-map: follow `docs/superpowers/README.md` "Output Language Convention".
- Core plugin skill content: English (do not rewrite).

If the user says "reply in English" (or any language override), switch immediately and keep it for subsequent artifacts until told otherwise.

