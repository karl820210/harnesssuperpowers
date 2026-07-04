---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time.

**Order questions by architectural impact:** ask first the questions whose answers would change the architecture or invalidate other decisions; leave cosmetic and isolated choices for last. A cheap ordering test: "if the answer surprised me, how much of the plan survives?" — the less survives, the earlier the question.

If a question can be answered by exploring the codebase, explore the codebase instead.

Pairs with `skills/blind-spot-scan/SKILL.md`: run a blind-spot scan first when the *questions themselves* are unknown (unfamiliar territory); grill-me resolves the questions once they are on the table.
