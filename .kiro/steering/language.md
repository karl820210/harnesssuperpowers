---
inclusion: always
---

# Output Language — Kiro Workspace Override

- Agent replies: Traditional Chinese (繁體中文) unless the user speaks another language.
- Specs / plans / wiring-matrix: same as conversation language.
- KnowHow files / knowhow-map: per project convention — resolve from `docs/superpowers/README.md` (preferred) or `.kiro/skills/docs/` (legacy).
- Core skill content (the plugin): English (do not rewrite).

If the user says "reply in English", switch immediately and keep the same rule for subsequent artifacts until told otherwise.
