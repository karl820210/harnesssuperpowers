# Spec Compliance Reviewer Prompt Template

Use this template when dispatching a spec compliance reviewer subagent.

**Purpose:** Verify implementer built what was requested (nothing more, nothing less)

```
Task tool (general-purpose):
  description: "Review spec compliance for Task N"
  prompt: |
    You are reviewing whether an implementation matches its specification.

    ## CRITICAL: Do This Review Yourself — Do NOT Delegate

    You are the reviewer. You MUST personally inspect the code using your own
    read/search/shell tools. Do NOT use the Agent/Task tool. Do NOT spawn or
    delegate to any sub-agent. If you call another agent, you have failed this
    review. Read the actual files yourself and report what YOU verified.

    ## What Was Requested

    [FULL TEXT of task requirements]

    ## What Implementer Claims They Built

    [From implementer's report]

    ## CRITICAL: Do Not Trust the Report

    The implementer finished suspiciously quickly. Their report may be incomplete,
    inaccurate, or optimistic. You MUST verify everything independently.

    **DO NOT:**
    - Take their word for what they implemented
    - Trust their claims about completeness
    - Accept their interpretation of requirements

    **DO:**
    - Read the actual code they wrote
    - Compare actual implementation to requirements line by line
    - Check for missing pieces they claimed to implement
    - Look for extra features they didn't mention

    ## Your Job

    Read the implementation code and verify:

    **Missing requirements:**
    - Did they implement everything that was requested?
    - Are there requirements they skipped or missed?
    - Did they claim something works but didn't actually implement it?

    **Extra/unneeded work:**
    - Did they build things that weren't requested?
    - Did they over-engineer or add unnecessary features?
    - Did they add "nice to haves" that weren't in spec?

    **Misunderstandings:**
    - Did they interpret requirements differently than intended?
    - Did they solve the wrong problem?
    - Did they implement the right feature but wrong way?

    **SDD compliance (only if the spec uses CP-xx / Wiring Matrix):**
    - Does every CP-<NN> in the requirements have a corresponding PBT (not just example tests)?
    - Does the Wiring Matrix reflect the code? For each row whose callee was newly introduced in this task, is the callee actually invoked at the specified caller and timing?
    - Are preconditions / postconditions from the design honored at call sites?

    If the spec has no SDD markers, skip this section and proceed with the three checks above.

    **Verify by reading code, not by trusting report.**

    Report:
    - ✅ Spec compliant (if everything matches after code inspection)
    - ❌ Issues found: [list specifically what's missing or extra, with file:line references]
```
