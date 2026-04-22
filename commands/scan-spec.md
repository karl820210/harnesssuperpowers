---
description: "Invoke the superpowers:sdd-scan skill to scan a spec for SDD compliance (CP-xx, preconditions, Wiring Matrix, BDD/TDD structure)."
argument_hint: "<spec-name-or-path>"
---

Invoke the `superpowers:sdd-scan` skill against `$ARGUMENTS`.
If `$ARGUMENTS` is empty, use the Discovery Contract to find the most recent spec under `docs/superpowers/specs/` or `.kiro/specs/`.
Report the findings as a Markdown table per the skill's Output Format section.
