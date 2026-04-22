---
name: skill-creator
description: Create new skills, modify and improve existing skills, and measure skill performance. Use when users want to create a skill from scratch, edit, or optimize an existing skill, run evals to test a skill, benchmark skill performance with variance analysis, or optimize a skill's description for better triggering accuracy.
---

# Skill Creator

A skill for creating new skills and iteratively improving them inside Kiro.

At a high level, the process of creating a skill goes like this:

- Decide what you want the skill to do and roughly how it should do it
- Write a draft of the skill
- Create a few test prompts and run them via subagents (Kiro's `invokeSubAgent`)
- Help the user evaluate the results both qualitatively and quantitatively
  - While the runs happen in the background, draft some quantitative evals if there aren't any (if there are some, you can either use as is or modify if you feel something needs to change about them). Then explain them to the user (or if they already existed, explain the ones that already exist)
  - Use the `eval-viewer/generate_review.py` script to show the user the results for them to look at, and also let them look at the quantitative metrics
- Rewrite the skill based on feedback from the user's evaluation of the results (and also if there are any glaring flaws that become apparent from the quantitative benchmarks)
- Repeat until you're satisfied
- Expand the test set and try again at larger scale

Your job when using this skill is to figure out where the user is in this process and then jump in and help them progress through these stages. So for instance, maybe they're like "I want to make a skill for X". You can help narrow down what they mean, write a draft, write the test cases, figure out how they want to evaluate, run all the prompts, and repeat.

On the other hand, maybe they already have a draft of the skill. In this case you can go straight to the eval/iterate part of the loop.

Of course, you should always be flexible and if the user is like "I don't need to run a bunch of evaluations, just vibe with me", you can do that instead.

Then after the skill is done (but again, the order is flexible), you can also run the skill description improver to optimize the triggering of the skill.

Cool? Cool.

---

## Kiro-first workflow (Windows friendly)

This skill runs inside Kiro on Windows. Use Kiro's native tools (`fsWrite`, `readFile`, `invokeSubAgent`, `executePwsh`, etc.) and avoid assuming Claude Code / Cursor / Cowork-specific tooling exists.

### Where skills live

Skills in Kiro have one canonical home:

- **Repo-local skills directory**: `<repo-root>/.kiro/skills/<skill-name>/SKILL.md`

Skills are activated via Kiro's `discloseContext` tool when the user's request matches the skill's name/description. The skill's YAML frontmatter (`name` + `description`) is the primary triggering mechanism.

### Kiro-native eval loop (A/B runs)

In Kiro, you can test a skill by running the same prompt via `invokeSubAgent` (using the `general-task-execution` agent):

- **With-skill**: include the skill's SKILL.md content in the subagent's `contextFiles` or embed it in the prompt.
- **Baseline**: same prompt, but without the skill content.

Save outputs to a deterministic directory structure in the current workspace so the user can diff results.

### Kiro ecosystem integration

Skills can work alongside other Kiro features:

- **Steering files** (`.kiro/steering/*.md`): always-on or conditional rules that complement skills. If a skill needs persistent rules (coding style, commit conventions), consider whether a steering file is more appropriate.
- **Hooks** (`.kiro/hooks/*.json`): event-driven automations. Skills that define repeatable workflows might benefit from companion hooks (e.g., "run lint after file edit").
- **Specs**: structured feature development. Skills can guide how specs are written or implemented.

When creating a skill, think about whether parts of it belong as steering (always-on rules) vs. skill (on-demand workflow).

## Communicating with the user

The skill creator is liable to be used by people across a wide range of familiarity with coding jargon. Pay attention to context cues to understand how to phrase your communication! In the default case:

- "evaluation" and "benchmark" are borderline, but OK
- for "JSON" and "assertion" you want to see serious cues from the user that they know what those things are before using them without explaining them

It's OK to briefly explain terms if you're in doubt.

---

## Creating a skill

### Capture Intent

Start by understanding the user's intent. The current conversation might already contain a workflow the user wants to capture (e.g., they say "turn this into a skill"). If so, extract answers from the conversation history first — the tools used, the sequence of steps, corrections the user made, input/output formats observed. The user may need to fill the gaps, and should confirm before proceeding to the next step.

1. What should this skill enable Kiro to do?
2. When should this skill trigger? (what user phrases/contexts)
3. What's the expected output format?
4. Should we set up test cases to verify the skill works? Skills with objectively verifiable outputs (file transforms, data extraction, code generation, fixed workflow steps) benefit from test cases. Skills with subjective outputs (writing style, art) often don't need them. Suggest the appropriate default based on the skill type, but let the user decide.

### Interview and Research

Proactively ask questions about edge cases, input/output formats, example files, success criteria, and dependencies. Wait to write test prompts until you've got this part ironed out.

Check available MCP tools (via `kiroPowers`) — if useful for research (searching docs, finding similar skills, looking up best practices), use them. Come prepared with context to reduce burden on the user.

### Write the SKILL.md

Based on the user interview, fill in these components:

- **name**: Skill identifier (used in `discloseContext` activation)
- **description**: When to trigger, what it does. This is the primary triggering mechanism — include both what the skill does AND specific contexts for when to use it. All "when to use" info goes here, not in the body. Make the description a little "pushy" to combat undertriggering. For instance, instead of "How to build a dashboard.", write "How to build a dashboard. Use this skill whenever the user mentions dashboards, data visualization, or wants to display any kind of data, even if they don't explicitly ask for a 'dashboard.'"
- **the rest of the skill :)**

### Skill Writing Guide

#### Anatomy of a Skill

```
.kiro/skills/skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter (name, description required)
│   └── Markdown instructions
└── Bundled Resources (optional)
    ├── scripts/    - Executable code for deterministic/repetitive tasks
    ├── references/ - Docs loaded into context as needed
    └── assets/     - Files used in output (templates, icons, fonts)
```

#### Progressive Disclosure

Skills use a layered loading system:
1. **Metadata** (name + description) — Always visible to Kiro's skill matcher (~100 words)
2. **SKILL.md body** — Loaded into context when skill is activated via `discloseContext` (<500 lines ideal)
3. **Bundled resources** — Read on demand via `readFile` (unlimited; scripts can execute without loading)

**Key patterns:**
- Keep SKILL.md under 500 lines; if approaching this limit, add hierarchy with clear pointers about where to go next.
- Reference files clearly from SKILL.md with guidance on when to read them
- For large reference files (>300 lines), include a table of contents

**Domain organization**: When a skill supports multiple domains/frameworks, organize by variant:
```
cloud-deploy/
├── SKILL.md (workflow + selection)
└── references/
    ├── aws.md
    ├── gcp.md
    └── azure.md
```
Kiro reads only the relevant reference file.

#### Principle of Lack of Surprise

Skills must not contain malware, exploit code, or any content that could compromise system security. A skill's contents should not surprise the user in their intent if described.

#### Writing Patterns

Prefer using the imperative form in instructions.

**Defining output formats:**
```markdown
## Report structure
ALWAYS use this exact template:
# [Title]
## Executive summary
## Key findings
## Recommendations
```

**Examples pattern:**
```markdown
## Commit message format
**Example 1:**
Input: Added user authentication with JWT tokens
Output: feat(auth): implement JWT-based authentication
```

### Writing Style

Try to explain to the model why things are important in lieu of heavy-handed musty MUSTs. Use theory of mind and try to make the skill general and not super-narrow to specific examples. Start by writing a draft and then look at it with fresh eyes and improve it.

### Test Cases

After writing the skill draft, come up with 2-3 realistic test prompts — the kind of thing a real user would actually say. Share them with the user: "Here are a few test cases I'd like to try. Do these look right, or do you want to add more?" Then run them.

Save test cases to `evals/evals.json`. Don't write assertions yet — just the prompts. You'll draft assertions in the next step while the runs are in progress.

```json
{
  "skill_name": "example-skill",
  "evals": [
    {
      "id": 1,
      "prompt": "User's task prompt",
      "expected_output": "Description of expected result",
      "files": []
    }
  ]
}
```

See `references/schemas.md` for the full schema (including the `assertions` field, which you'll add later).

## Running and evaluating test cases

This section is one continuous sequence — don't stop partway through.

Put results in `<skill-name>-workspace/` as a sibling to the skill directory (i.e., `.kiro/skills/<skill-name>-workspace/`). Within the workspace, organize results by iteration (`iteration-1/`, `iteration-2/`, etc.) and within that, each test case gets a directory (`eval-0/`, `eval-1/`, etc.). Don't create all of this upfront — just create directories as you go.

### Step 1: Spawn all runs (with-skill AND baseline) in the same turn

For each test case, use `invokeSubAgent` with the `general-task-execution` agent to spawn two runs — one with the skill, one without. Launch everything at once so it all finishes around the same time.

**With-skill run:**

```
invokeSubAgent:
  name: general-task-execution
  prompt: |
    Execute this task:
    - Read the skill at: <path-to-skill>/SKILL.md
    - Task: <eval prompt>
    - Input files: <eval files if any, or "none">
    - Save outputs to: <workspace>/iteration-<N>/eval-<ID>/with_skill/outputs/
  contextFiles:
    - path: <path-to-skill>/SKILL.md
```

**Baseline run** (same prompt, but the baseline depends on context):
- **Creating a new skill**: no skill at all. Same prompt, no contextFiles, save to `without_skill/outputs/`.
- **Improving an existing skill**: the old version. Before editing, snapshot the skill, then point the baseline subagent at the snapshot. Save to `old_skill/outputs/`.

Write an `eval_metadata.json` for each test case (assertions can be empty for now). Give each eval a descriptive name based on what it's testing.

```json
{
  "eval_id": 0,
  "eval_name": "descriptive-name-here",
  "prompt": "The user's task prompt",
  "assertions": []
}
```

### Step 2: While runs are in progress, draft assertions

Draft quantitative assertions for each test case and explain them to the user. Good assertions are objectively verifiable and have descriptive names.

Subjective skills (writing style, design quality) are better evaluated qualitatively — don't force assertions onto things that need human judgment.

Update the `eval_metadata.json` files and `evals/evals.json` with the assertions once drafted.

### Step 3: Grade and present results

Once all runs are done:

1. **Grade each run** — spawn a grader subagent (or grade inline) that reads `agents/grader.md` and evaluates each assertion against the outputs. Save results to `grading.json` in each run directory. The grading.json expectations array must use the fields `text`, `passed`, and `evidence`. For assertions that can be checked programmatically, write and run a script rather than eyeballing it.

2. **Aggregate into benchmark** — run the aggregation script:
   ```bash
   python -m scripts.aggregate_benchmark <workspace>/iteration-N --skill-name <name>
   ```
   This produces `benchmark.json` and `benchmark.md`. If generating benchmark.json manually, see `references/schemas.md` for the exact schema.

3. **Do an analyst pass** — read the benchmark data and surface patterns the aggregate stats might hide. See `agents/analyzer.md` for what to look for.

4. **Launch the viewer** with both qualitative outputs and quantitative data:
   ```bash
   python <skill-creator-path>/eval-viewer/generate_review.py <workspace>/iteration-N --skill-name "my-skill" --benchmark <workspace>/iteration-N/benchmark.json --static <workspace>/iteration-N/review.html
   ```
   For iteration 2+, also pass `--previous-workspace <workspace>/iteration-<N-1>`.

   Use `--static` to write a standalone HTML file. The user can open it in their browser.

**Fallback (when viewer/tooling isn't available)**:

- If `eval-viewer/` or the aggregation scripts don't exist, skip the viewer.
- Present results directly in-chat:
  - For each eval: show the prompt, list produced files, and summarize key diffs between with-skill vs baseline.
  - Collect user feedback inline and proceed to the next iteration.

5. **Tell the user** something like: "I've generated the results viewer at `<path>`. Open it in your browser — there are two tabs: 'Outputs' for qualitative review and 'Benchmark' for quantitative comparison. When you're done, come back here and let me know."

### Step 4: Read the feedback

When the user tells you they're done, read `feedback.json`:

```json
{
  "reviews": [
    {"run_id": "eval-0-with_skill", "feedback": "the chart is missing axis labels", "timestamp": "..."},
    {"run_id": "eval-1-with_skill", "feedback": "", "timestamp": "..."}
  ],
  "status": "complete"
}
```

Empty feedback means the user thought it was fine. Focus improvements on test cases where the user had specific complaints.

---

## Improving the skill

This is the heart of the loop. You've run the test cases, the user has reviewed the results, and now you need to make the skill better based on their feedback.

### How to think about improvements

1. **Generalize from the feedback.** We're trying to create skills that can be used across many different prompts. Rather than put in fiddly overfitty changes, or oppressively constrictive MUSTs, if there's some stubborn issue, try branching out and using different metaphors or recommending different patterns of working.

2. **Keep the prompt lean.** Remove things that aren't pulling their weight. Read the transcripts, not just the final outputs — if the skill is making the model waste time doing unproductive things, try removing those parts.

3. **Explain the why.** Try hard to explain the **why** behind everything you're asking the model to do. LLMs are smart — they have good theory of mind and when given a good harness can go beyond rote instructions. If you find yourself writing ALWAYS or NEVER in all caps, that's a yellow flag — reframe and explain the reasoning instead.

4. **Look for repeated work across test cases.** If all test runs independently wrote similar helper scripts or took the same multi-step approach, that's a strong signal the skill should bundle that script in `scripts/`.

### The iteration loop

After improving the skill:

1. Apply your improvements to the skill
2. Rerun all test cases into a new `iteration-<N+1>/` directory, including baseline runs
3. Generate the reviewer with `--previous-workspace` pointing at the previous iteration
4. Wait for the user to review and tell you they're done
5. Read the new feedback, improve again, repeat

Keep going until:
- The user says they're happy
- The feedback is all empty (everything looks good)
- You're not making meaningful progress

---

## Advanced: Blind comparison

For situations where you want a more rigorous comparison between two versions of a skill, there's a blind comparison system. Read `agents/comparator.md` and `agents/analyzer.md` for the details. The basic idea is: give two outputs to an independent subagent without telling it which is which, and let it judge quality.

This is optional and most users won't need it. The human review loop is usually sufficient.

---

## Description Optimization

The description field in SKILL.md frontmatter is the primary mechanism that determines whether Kiro activates a skill. After creating or improving a skill, offer to optimize the description for better triggering accuracy.

### Step 1: Generate trigger eval queries

Create 20 eval queries — a mix of should-trigger and should-not-trigger. Save as JSON:

```json
[
  {"query": "the user prompt", "should_trigger": true},
  {"query": "another prompt", "should_trigger": false}
]
```

The queries must be realistic. Not abstract requests, but concrete and specific with detail — file paths, personal context, column names, company names, URLs. Some might be in lowercase or contain abbreviations or typos or casual speech. Use a mix of different lengths, and focus on edge cases.

For the **should-trigger** queries (8-10), think about coverage — different phrasings of the same intent, some formal, some casual. Include cases where the user doesn't explicitly name the skill but clearly needs it.

For the **should-not-trigger** queries (8-10), the most valuable ones are near-misses — queries that share keywords or concepts with the skill but actually need something different.

### Step 2: Review with user

Present the eval set to the user for review. If the `assets/eval_review.html` template exists:

1. Read the template
2. Replace placeholders (`__EVAL_DATA_PLACEHOLDER__`, `__SKILL_NAME_PLACEHOLDER__`, `__SKILL_DESCRIPTION_PLACEHOLDER__`)
3. Write to a file in the workspace and tell the user to open it

Otherwise, present the eval set directly in chat and ask for feedback.

### Step 3: Lightweight optimization loop

Since Kiro doesn't have the `claude` CLI, do a manual optimization loop:

1. Review which queries the current description would likely trigger/miss
2. Update the `description` to be more specific about trigger contexts and to avoid near-miss false positives
3. Re-check the eval set by reasoning through which prompts should cause the skill to be activated
4. Iterate 2-3 times until the description covers the should-trigger set well while avoiding false positives

### Step 4: Apply the result

Update the skill's SKILL.md frontmatter with the improved description. Show the user before/after.

---

## Deciding: Skill vs. Steering vs. Hook

Kiro has three mechanisms for guiding agent behavior. When creating a new skill, consider whether the user's need is better served by one of the others:

| Mechanism | When to use | Example |
|-----------|-------------|---------|
| **Skill** (`.kiro/skills/`) | On-demand workflow triggered by user intent | "Create a migration script" |
| **Steering** (`.kiro/steering/`) | Always-on rules or conditional rules tied to file patterns | "Always use Chinese commit messages" |
| **Hook** (`.kiro/hooks/`) | Automated action on IDE events | "Run lint after saving .ts files" |

If the user asks for something that's really a persistent rule (coding style, commit conventions), suggest a steering file instead. If it's an automated reaction to events, suggest a hook.

---

## Reference files

The agents/ directory contains instructions for specialized subagents. Read them when you need to spawn the relevant subagent.

- `agents/grader.md` — How to evaluate assertions against outputs
- `agents/comparator.md` — How to do blind A/B comparison between two outputs
- `agents/analyzer.md` — How to analyze why one version beat another

The references/ directory has additional documentation:
- `references/schemas.md` — JSON structures for evals.json, grading.json, etc.

---

## Core loop summary

- Figure out what the skill is about
- Draft or edit the skill
- Run Kiro-with-access-to-the-skill on test prompts (via `invokeSubAgent`)
- With the user, evaluate the outputs:
  - Generate benchmark.json and run `eval-viewer/generate_review.py --static` to help the user review
  - Run quantitative evals
- Repeat until you and the user are satisfied

Good luck!
