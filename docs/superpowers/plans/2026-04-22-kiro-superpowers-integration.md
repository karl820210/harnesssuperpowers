# Kiro → Superpowers Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 `.kiro/` 的 Harness Engineering value-adds（SDD workflow、Wiring Matrix、5-Dim Audit、KnowHow sync、SDD scan、Bootstrapping）提升為 cross-IDE Superpowers core skills，並把 `.kiro/` 轉成指向 canonical 的 adapter。

**Architecture:** Three-layer extension model — Layer 1（Framework core；本 repo）；Layer 2（Project extension；`docs/superpowers/` + `.cursor/` + `.kiro/`）；Layer 3（Runtime evaluators；Mode A 形式化腳本 / Mode B 探索性 agent-native）。`.kiro/` 轉為 adapter 指向 canonical `skills/`。

**Tech Stack:** Markdown skill docs、`run-hook.cmd` polyglot shell wrapper、bash/PowerShell 驗證腳本、Claude Code / Cursor / Kiro 三家為一等公民 IDE。

**Related Spec:** `docs/superpowers/specs/2026-04-22-kiro-superpowers-integration-design.md`

**Execution:** Subagent-Driven（user 已選），每個 Task 獨立 commit + two-stage review（SDD compliance → code quality）。

---

## File Structure Overview

| 類別 | 檔案數 | Phase |
|---|---|---|
| 新 canonical skill | 5（harness-engineering、sdd-workflow、sdd-scan、capturing-knowhow、bootstrapping-harness + 3 templates）| P1 |
| 修改 upstream skill | 3（writing-plans、subagent-driven-development/spec-reviewer-prompt、verification-before-completion） | P2 |
| 新 command | 2（capture-knowhow、scan-spec）| P3 |
| 新 hook script | 2（spec-sdd-check、capture-knowhow-reminder）| P3 |
| 修 hook manifest | 2（hooks.json、hooks-cursor.json）| P3 |
| 新 doc | 2（harness-extension-guide.md、更新 README.md）| P4 |
| `.kiro/` adapter | 5 skills + 2 steering + 1 new steering + 2 hook pointers + 1 UsageReadme | P5 |
| 驗證腳本 | 1（`scripts/verify-adapters.sh`）| P0/P5 |

---

## Phase 0 — Preparation

### Task 0.1: 建立 feature worktree + branch

**Files:**
- Create: `.worktrees/kiro-integration/`（external；skip git add）

**Context:** 使用 `skills/using-git-worktrees` skill。此 plan 後續所有工作在 worktree 內進行；假設 worktree 已設好（或同等隔離環境）後繼續。

- [ ] **0.1.1 建立 worktree 並切換分支**

```bash
cd "<repo root>"
git checkout -b feat/kiro-integration
git worktree add .worktrees/kiro-integration feat/kiro-integration || true
cd .worktrees/kiro-integration
```

- [ ] **0.1.2 驗證 worktree 起點乾淨**

Run: `git status --porcelain`
Expected: 空輸出（或只有 `docs/superpowers/specs/2026-04-22-kiro-superpowers-integration-design.md` 這份 design doc 已存在）。

- [ ] **0.1.3 Commit design doc（若尚未 commit）**

```bash
git add docs/superpowers/specs/2026-04-22-kiro-superpowers-integration-design.md
git commit -m "docs: add kiro-superpowers integration design"
```

---

### Task 0.2: 建立 `scripts/verify-adapters.sh` 骨架

**Files:**
- Create: `scripts/verify-adapters.sh`
- Create: `scripts/` 目錄（若不存在）

**Purpose:** 在 Phase 5 結束後被呼叫，確保 `.kiro/skills/*/SKILL.md` adapter 與 canonical `skills/*/SKILL.md` 的 `description` 一致、pointer 路徑存在。Phase 0 先建骨架（沒有 adapter 時 exit 0），後續 phase 逐步加入檢查。

- [ ] **0.2.1 建立腳本檔，寫入以下完整內容：**

```bash
#!/usr/bin/env bash
# verify-adapters.sh — ensure .kiro/ adapter skills stay in sync with canonical skills/.
#
# Checks (for each .kiro/skills/*/SKILL.md that contains the adapter marker):
#   1) adapter front-matter 'description' field matches canonical
#   2) the canonical pointer path exists
#
# Exit codes:
#   0  all adapters in sync (or no adapters present)
#   1  at least one adapter is out of sync
#
# Usage: bash scripts/verify-adapters.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

ADAPTER_MARKER='<!-- SUPERPOWERS_ADAPTER -->'
FAIL=0
CHECKED=0

extract_front_matter_field() {
    # extract_front_matter_field <file> <field>
    # Returns trimmed value of a `field: value` line inside the top YAML block.
    local file="$1"
    local field="$2"
    awk -v f="$field" '
        BEGIN { inblock=0 }
        /^---[[:space:]]*$/ { inblock = !inblock; next }
        inblock && $0 ~ "^"f"[[:space:]]*:" {
            sub("^"f"[[:space:]]*:[[:space:]]*", "", $0)
            print $0
            exit
        }
    ' "$file"
}

check_adapter() {
    local adapter_file="$1"
    CHECKED=$((CHECKED + 1))

    # Parse canonical pointer from line like: "> **Canonical**: `skills/<name>/SKILL.md`"
    local canonical_rel
    canonical_rel=$(grep -E '^\> \*\*Canonical\*\*:' "$adapter_file" | head -n1 \
        | sed -E 's/.*`([^`]+)`.*/\1/')
    if [ -z "$canonical_rel" ]; then
        echo "FAIL: $adapter_file — cannot find canonical pointer line" >&2
        FAIL=$((FAIL + 1))
        return
    fi

    if [ ! -f "$canonical_rel" ]; then
        echo "FAIL: $adapter_file — canonical file missing: $canonical_rel" >&2
        FAIL=$((FAIL + 1))
        return
    fi

    local adapter_desc canonical_desc
    adapter_desc=$(extract_front_matter_field "$adapter_file" description)
    canonical_desc=$(extract_front_matter_field "$canonical_rel" description)

    if [ "$adapter_desc" != "$canonical_desc" ]; then
        echo "FAIL: $adapter_file — description drift" >&2
        echo "  adapter  : $adapter_desc" >&2
        echo "  canonical: $canonical_desc" >&2
        FAIL=$((FAIL + 1))
        return
    fi
}

while IFS= read -r -d '' f; do
    if grep -Fq "$ADAPTER_MARKER" "$f"; then
        check_adapter "$f"
    fi
done < <(find .kiro/skills -name SKILL.md -print0 2>/dev/null || true)

if [ "$FAIL" -eq 0 ]; then
    echo "verify-adapters.sh: $CHECKED adapter(s) checked, all in sync"
    exit 0
else
    echo "verify-adapters.sh: $FAIL failure(s) in $CHECKED adapter(s)" >&2
    exit 1
fi
```

- [ ] **0.2.2 設為可執行**

Run (Unix): `chmod +x scripts/verify-adapters.sh`
Run (Windows): n/a；bash via `run-hook.cmd` 仍可執行。

- [ ] **0.2.3 Smoke test：P0 時應該沒 adapter，腳本回傳 0**

Run: `bash scripts/verify-adapters.sh`
Expected: `verify-adapters.sh: 0 adapter(s) checked, all in sync` + exit 0

- [ ] **0.2.4 Commit**

```bash
git add scripts/verify-adapters.sh
git commit -m "chore: add verify-adapters.sh skeleton for .kiro/ adapter sync checks"
```

---

## Phase 1 — New Canonical Skills

> **Phase intent:** 新增 5 個 canonical skill（`harness-engineering`、`sdd-workflow`、`sdd-scan`、`capturing-knowhow`、`bootstrapping-harness`）。順序依依賴：`harness-engineering` 最先（其他 reference 它）；其他四個彼此獨立。
>
> **Content language rule:** core skill 內容一律英文（user 先前決策）。description 欄位英文。body 英文。範例、UI prompts 維持英文。

### Task 1.1: `skills/harness-engineering/SKILL.md`（migrate + generalize）

**Files:**
- Create: `skills/harness-engineering/SKILL.md`
- Source: `.kiro/skills/harness-engineering/SKILL.md`

**Transform rules（apply to source → target）:**

1. **Front-matter description** 改為：
   `Harness Engineering framework — audit, diagnose, and improve an AI agent's harness coverage. Covers Feedforward (Skills/Steering guides), Feedback (Hooks/Tests sensors), Wiring Integrity (Wiring Matrix), Latent vs Deterministic boundary, and the Feedback Flywheel. Use when auditing harness coverage, diagnosing missed wiring, improving agent work quality, authoring new guides or sensors, or discussing harness engineering architecture.`

2. **整體翻譯**：原檔為中文，canonical 版本改為英文（核心術語保留原英文：Feedforward / Feedback / Wiring Matrix / Latent / Deterministic / Flywheel / Thin Harness）。

3. **"Agent = Model + Harness" 段落的 5-element 表格** 改為跨 IDE 中性版本：

```markdown
| Element | Location (cross-IDE)                                        | Role                                 | Abstraction |
|---------|-------------------------------------------------------------|--------------------------------------|-------------|
| Skills  | `skills/*/SKILL.md` (Superpowers), `.kiro/skills/`, `.cursor/skills/` | Fat Skills — domain knowledge & workflows (Feedforward, Inferential) | Project-specific |
| Steering| `CLAUDE.md`, `AGENTS.md`, `.kiro/steering/`, `.cursor/rules/` | Behavior rules & conventions (Feedforward, Inferential) | Project-specific |
| Hooks   | `hooks/*.json`, `.kiro/hooks/*.kiro.hook`                   | Automatic triggers (Feedback, Computational/Inferential) | Portable (detection patterns) |
| Specs   | `docs/superpowers/specs/`, `.kiro/specs/`                   | Structured development flow (Feedforward, Computational) | Project-specific |
| KnowHow | `docs/superpowers/knowhow/`, project knowhow files           | Accumulated lessons (Feedback Flywheel) | Project-specific |

Note: Hooks should be generic detection rules. Project-specific checks belong in Steering or per-project checklists.
```

4. **"Resolver = Context Router" 段落的三機制** 改為跨 IDE 中性版本：

```markdown
Across IDEs, Resolver is realized by three mechanisms:
1. **Skill description** — the model's auto-matching hook for user intent.
2. **Steering file glob / alwaysApply** — conventions loaded when specific files are opened (Cursor rules, Kiro `inclusion: fileMatch`).
3. **Hook event matcher** — reminders injected on specific events (Claude Code `PostToolUse` matcher, Kiro `fileEdited patterns`).
```

5. **"在 Kiro 中的落地" (feedback flywheel 段) 改為：**

```markdown
Concrete wiring in a Superpowers-enabled project:
- A session-end hook (`Stop` in Claude Code, `agentStop` in Kiro) triggers `capturing-knowhow` → updates Skills/Steering/checklists.
- This is not extra work; it is how the Static layer keeps getting sharper.
```

6. **保留 verbatim（只做中→英翻譯）：**
   - Feedforward vs Feedback 定義段
   - Computational vs Inferential 定義段
   - Latent vs Deterministic 定義段
   - Thin Harness, Fat Skills 段
   - Static Scaffolding → Dynamic Decomposition 三層架構段
   - Wiring Integrity 段
   - **審計流程 → 改為 "Audit Process"**，5 個維度內容保留（翻譯）
   - **改善流程 → 改為 "Remediation Priorities"**，4 個優先級保留
   - Wiring Matrix 模板整段（含範例）
   - Task 結構模板（含接線任務）
   - 與現有框架的關係圖
   - 參考文獻

7. **新增「Related Skills」段**放在 "References" 之前：

```markdown
## Related Skills

- `skills/sdd-workflow/SKILL.md` — structured SDD/BDD/TDD flow that consumes Wiring Matrix.
- `skills/writing-plans/SKILL.md` — plan authoring that materializes CP-xx and Wiring Matrix into tasks.
- `skills/verification-before-completion/SKILL.md` — invokes the 5-dimension audit at completion checkpoints.
- `skills/capturing-knowhow/SKILL.md` — the Flywheel feedback capture point.
```

**Steps:**

- [ ] **1.1.1 讀取 source** — `.kiro/skills/harness-engineering/SKILL.md`（參考 286 行原版）
- [ ] **1.1.2 建立目錄與檔案**

```bash
mkdir -p skills/harness-engineering
```

- [ ] **1.1.3 撰寫 `skills/harness-engineering/SKILL.md`** — 套用上述 transform rules，產出英文 canonical 版本。行數預計 ~280 行（與原版相近）。

- [ ] **1.1.4 驗證無 Kiro-specific terminology 殘留**

Run: `grep -iE '在 Kiro 中|\.kiro/' skills/harness-engineering/SKILL.md | grep -v "^>" || echo "CLEAN"`
Expected: `CLEAN`（唯一可接受出現 `.kiro/` 的地方是 5-element 表格中列舉 cross-IDE path 時；這類行若出現，手動確認上下文是列舉而非暗示 Kiro-only，不需 fail）

- [ ] **1.1.5 Front-matter sanity check**

Run: `head -n 5 skills/harness-engineering/SKILL.md`
Expected：第 1 行 `---`、第 2 行 `name: harness-engineering`、第 3 行 `description:` 開頭。

- [ ] **1.1.6 Commit**

```bash
git add skills/harness-engineering/SKILL.md
git commit -m "feat(skills): add harness-engineering canonical skill"
```

---

### Task 1.2: `skills/sdd-workflow/SKILL.md`（new — full inline draft）

**Files:**
- Create: `skills/sdd-workflow/SKILL.md`

**Purpose:** thin overview of Specification-Driven → Behavior-Driven → Test-Driven flow that cross-references `writing-plans`, `subagent-driven-development`, `verification-before-completion`, and `harness-engineering`. 不重複完整 TDD 內容（在 `test-driven-development` skill 裡），不重複完整 plan 結構（在 `writing-plans` 裡）。

**Full inline content（即最終檔案內容）：**

```markdown
---
name: sdd-workflow
description: Specification-Driven → Behavior-Driven → Test-Driven three-stage flow. Use when starting a new feature that needs structured requirements → design → tasks with Correctness Properties, Interface Contracts, and a Wiring Matrix. Complements writing-plans (plan authoring), subagent-driven-development (execution), and harness-engineering (audit).
---

# SDD → BDD → TDD Workflow

Structured three-stage flow that turns an idea into verified code.

## When to Use

- Starting a feature that has non-trivial correctness requirements
- The task has interface contracts the caller or callee must uphold
- Multiple modules must be wired together and wiring gaps have bitten you before
- A Kiro `spec/*` folder, or `docs/superpowers/specs/<feature>.md`, is expected

If the task is a one-file tweak, this flow is overkill — prefer `writing-plans` alone.

## The Three Stages

```
Stage 1  SDD   — Requirements  → Design
Stage 2  BDD   — Tasks with Given-When-Then scenarios
Stage 3  TDD   — Implementation Red → Green → Refactor (+ PBT)
```

Each stage produces verifiable artifacts that feed the next.

---

## Stage 1 — SDD (Specification-Driven Design)

Produces the `requirements` and `design` sections of the spec.

**Requirements must include Correctness Properties:**

- Format: `CP-<NN>: <property statement>`
- Example: `CP-01: After a fish's TTL expires, it must be removed from the scene; no orphans may remain.`
- CPs are invariants — they hold for all valid inputs, not just happy paths.
- Each CP should later map to at least one Property-Based Test (PBT).

**Design must include Interface Contracts:**

- Each exported function / method is annotated with `precondition` and `postcondition`.
- Example:
  ```
  ProcessShot(bulletID, fishID)
    precondition:  bullet.Active && fish.Alive
    postcondition: fish.HP decreased OR miss recorded
  ```

**Design must include a Wiring Matrix.** See `skills/harness-engineering/SKILL.md` for the canonical template. Summary:

| Order | Caller | Callee method | Argument source | Output / side-effect |
|---|---|---|---|---|
| 1 | {main loop} | {subsystem}.Update(dt) | {state source} | {broadcast / state change} |

The Wiring Matrix is the sole source of truth for integration tasks in Stage 3.

**Design must mark each computation step as Latent or Deterministic.** See `harness-engineering` for the distinction. Deterministic steps must not be left for the agent to "infer".

## Stage 2 — BDD (Behavior-Driven Development)

Produces the `tasks` section of the spec.

- Every user story / acceptance criterion converts to a Given-When-Then scenario.
- Scenarios live in the test file (as comments or test function names).
- Naming: `Test_<Feature>_Given<State>_When<Action>_Then<Outcome>` (adapt per language).
- Scenarios must cover: happy path, boundary conditions, error / edge cases.

Each implementation task in `tasks.md` has this shape:

```
- [ ] N. <feature description>
  - [ ] N.1 Write BDD scenario (Given-When-Then)
  - [ ] N.2 Write failing test (Red)
  - [ ] N.3 Write minimal implementation (Green)
  - [ ] N.4 Refactor; tests stay green
  - [ ] N.5 Write PBT for the matching CP-xx (if any)
```

If the task adds an exported function that the Wiring Matrix expects to be called, it MUST be followed by a wiring task:

```
- [ ] N+1. Wiring: integrate <method> into <caller>
  - [ ] (N+1).1 Call <method> in <caller> per Wiring Matrix timing and args
  - [ ] (N+1).2 Integration test for the full call chain
  - [ ] (N+1).3 Confirm Wiring Matrix matches implementation
```

## Stage 3 — TDD (Test-Driven Development)

See `skills/test-driven-development/SKILL.md` for the canonical Iron Law and Red-Green-Refactor discipline. Summary:

- **Iron Law:** No failing test → no production code. Wrote code first? Delete it.
- **Red:** Write the test. Run it. Confirm failure reason is "feature missing", not a typo.
- **Green:** Write the minimum code that makes the test pass. Nothing else.
- **Refactor:** Clean up while tests stay green. No new behavior.

Every CP-xx gets at least one PBT in addition to example-based tests.

---

## Checkpoint Task (end of each phase)

Every phase-ending task should invoke the 5-dimension audit from `skills/harness-engineering/SKILL.md`:

1. **Feedback coverage** — every new exported function has a unit test; cross-module calls have integration tests.
2. **Wiring integrity** — every new method has at least one caller.
3. **Latent / Deterministic split** — no deterministic logic left to agent inference.
4. **Test health** — no flaky tests.
5. **Flywheel health** — new KnowHow captured if applicable.

See `skills/verification-before-completion/SKILL.md` for the completion gate.

---

## Handoff

When Stage 1 artifacts exist, invoke `skills/writing-plans/SKILL.md` to turn tasks into a bite-sized implementation plan. When the plan is ready, invoke `skills/subagent-driven-development/SKILL.md` to execute with two-stage review.

## Related Skills

- `skills/harness-engineering/SKILL.md` — Wiring Matrix canonical + 5-dim audit.
- `skills/writing-plans/SKILL.md` — plan authoring.
- `skills/subagent-driven-development/SKILL.md` — execution with spec + quality review.
- `skills/test-driven-development/SKILL.md` — canonical TDD discipline.
- `skills/sdd-scan/SKILL.md` — static SDD compliance scanner.
- `skills/verification-before-completion/SKILL.md` — evidence-before-claim gate.
```

**Steps:**

- [ ] **1.2.1 建立目錄**

```bash
mkdir -p skills/sdd-workflow
```

- [ ] **1.2.2 寫入上述內容到 `skills/sdd-workflow/SKILL.md`**

- [ ] **1.2.3 Broken-link check — 所有 reference 的 skill 路徑實際存在**

Run:
```bash
for p in \
  skills/harness-engineering/SKILL.md \
  skills/writing-plans/SKILL.md \
  skills/subagent-driven-development/SKILL.md \
  skills/test-driven-development/SKILL.md \
  skills/verification-before-completion/SKILL.md; do
  test -f "$p" && echo "OK  $p" || echo "MISS $p"
done
```
Expected: 全部 OK（注意：`skills/sdd-scan/SKILL.md` 在 Task 1.3 才會建立；此 reference 可容忍 Phase 1 暫時 miss）

- [ ] **1.2.4 Commit**

```bash
git add skills/sdd-workflow/SKILL.md
git commit -m "feat(skills): add sdd-workflow overview skill"
```

---

### Task 1.3: `skills/sdd-scan/SKILL.md`（migrate + generalize）

**Files:**
- Create: `skills/sdd-scan/SKILL.md`
- Source: `.kiro/skills/sdd-scan/SKILL.md`（60 行原版）

**Transform rules:**

1. **Description → English**：
   `SDD compliance scan. Scans a spec's requirements / design / tasks documents for SDD conformance: CP-xx Correctness Properties, precondition/postcondition, Wiring Matrix, BDD+TDD task structure. Use before running all tasks, when validating spec quality, or when a PostToolUse hook fires on a spec file edit.`

2. **"使用方式" 段改為跨 IDE：**

```markdown
## Invocation

- Slash command: `/scan-spec <spec-name>` (Claude Code / Cursor)
- Skill discovery: ask the agent "scan spec <name> for SDD compliance"
- Hook-driven: automatically via `spec-sdd-check` hook on `PostToolUse: Edit|Write|MultiEdit`

If no spec name is provided, the skill resolves via the Discovery Contract:

1. `${WORKSPACE_ROOT}/docs/superpowers/specs/<latest>.md`
2. `${WORKSPACE_ROOT}/.kiro/specs/<latest>/requirements.md`
3. Active editor file if it matches `**/specs/**/*.md`
```

3. **掃描項目** 整體英譯；保留 `- [ ]` checkbox 項目語意：

```markdown
## Scan Items

### 1. requirements (requirements.md or spec's Requirements section)

- [ ] Contains CP-<NN> correctness properties
- [ ] Each CP references the requirement clause it enforces

### 2. design (design.md or spec's Design section)

- [ ] Exported functions annotated with precondition / postcondition
- [ ] A "Wiring Matrix" section exists and lists caller → callee → timing → args
- [ ] Each computation step is tagged Latent or Deterministic

### 3. tasks (tasks.md or spec's Tasks section)

- [ ] Each implementation task follows the 5-substep structure (N.1 BDD → N.2 Red → N.3 Green → N.4 Refactor → N.5 PBT)
- [ ] Every task that adds an exported function is followed by a wiring task
- [ ] Each phase-ending Checkpoint task invokes the 5-dimension audit
```

4. **輸出格式** 英譯；保留 `✅ / ❌` 符號：

```markdown
## Output Format

\```
## SDD Compliance Scan — <spec_name>

### requirements
- ✅ CP-xx properties: <count>
- ✅ / ❌ <specific issue>

### design
- ✅ / ❌ precondition/postcondition
- ✅ / ❌ Wiring Matrix
- ✅ / ❌ Latent/Deterministic tagging

### tasks
- ✅ / ❌ BDD+TDD substeps
- ✅ / ❌ Wiring tasks
- ✅ / ❌ Checkpoint audit steps

### Conclusion
All compliant / <N> gaps need fixing
\```
```

5. **新增 Related Skills** 段：

```markdown
## Related Skills

- `skills/sdd-workflow/SKILL.md` — the SDD-BDD-TDD flow this scan enforces.
- `skills/harness-engineering/SKILL.md` — Wiring Matrix canonical.
- `skills/writing-plans/SKILL.md` — plan authoring downstream.
```

**Steps:**

- [ ] **1.3.1 建立目錄 + 撰寫 `skills/sdd-scan/SKILL.md`** 依 transform rules。
- [ ] **1.3.2 Verify description 非空且行寬合理**

Run: `head -n 5 skills/sdd-scan/SKILL.md`
Expected: front-matter 格式正確。

- [ ] **1.3.3 Commit**

```bash
git add skills/sdd-scan/SKILL.md
git commit -m "feat(skills): add sdd-scan compliance scanner skill"
```

---

### Task 1.4: `skills/capturing-knowhow/SKILL.md`（new — full inline draft）

**Files:**
- Create: `skills/capturing-knowhow/SKILL.md`

**Full inline content：**

```markdown
---
name: capturing-knowhow
description: Capture session-learned KnowHow into a persistent project knowledge base. Use at session end, when the user corrects your mistaken assumption, when a fix root-caused to an undocumented constraint, when a discarded-then-replaced approach revealed a hidden trade-off, or when a design decision shifted. Feeds the Harness Engineering Flywheel; complements sdd-workflow, writing-plans, and the capture-knowhow-reminder hook.
---

# Capturing KnowHow

Turn session learnings into persistent, searchable project knowledge.

## When to Capture

Capture if any of these is true:

1. A bug was fixed whose root cause was a constraint or behavior you did not know.
2. The user pointed out that your mental model was wrong.
3. An approach was tried, failed, replaced — and the reason matters next time.
4. An undocumented API / tool / framework behavior was discovered.
5. A design decision (ratio, sizing, protocol) shifted mid-work.

Do NOT capture:

- Typo fixes.
- Pure formatting changes.
- Repeated fixes of a pattern already in KnowHow.

## Discovery Contract

Resolve the project's KnowHow base in this priority order:

1. `${WORKSPACE_ROOT}/docs/superpowers/knowhow-map.md` + `docs/superpowers/knowhow/`
2. `${WORKSPACE_ROOT}/.kiro/skills/docs/` (legacy Kiro layout)
3. Nothing found → offer to run `skills/bootstrapping-harness/SKILL.md` to create the Layer 2 structure.

## The Map (`knowhow-map.md`)

A thin index that maps knowledge area → target KnowHow file → related skills / steering.

Template (maintained by `bootstrapping-harness`):

\```markdown
| Knowledge area | KnowHow file | Related skill | Related steering |
|---|---|---|---|
| Rendering / canvas | knowhow/rendering.md | `.cursor/skills/canvas/` | `rules/canvas.md` |
| Go server / concurrency | knowhow/backend.md | `.cursor/skills/go-server/` | `rules/go.md` |
\```

## The Capture Procedure

For each new KnowHow item:

1. **Classify** — look up the knowledge area in `knowhow-map.md`.
2. **Append** to the matching KnowHow file as a numbered entry:
   \```markdown
   ## <N>. <short title>

   **Context:** when/where it surfaced.
   **Problem:** what went wrong or was unknown.
   **Resolution:** what worked.
   **Lesson:** the takeaway in one sentence.
   \```
   - Numbers are monotonically increasing. Do not edit existing entries unless fixing a factual error.
3. **Update skill** — if the KnowHow changes a specification (sizes, formats, protocols), edit the matching skill's relevant section. Do NOT rewrite the whole skill.
4. **Update steering** — only if the KnowHow becomes a convention / rule / prohibition. Append to the matching steering file.
5. **Update checklist** — if the item is something worth checking every future task, add to the project's checklist file.

## Language Convention

Read the project's output language convention from `${WORKSPACE_ROOT}/docs/superpowers/README.md`. If unset, follow the current conversation language. KnowHow is long-lived, so a stable project-wide language matters more here than in one-off specs.

## Post-Capture Confirmation

Report to the user a short summary:

- KnowHow: `<file>` added entry `<N>. <title>`
- Skill: `<file>` — section `<name>` updated (or no skill changes)
- Steering: `<file>` — rule appended (or no steering changes)
- Checklist: item added (or no checklist changes)

Do not invent updates. If no target file exists, say so and suggest running `skills/bootstrapping-harness/SKILL.md`.

## Related Skills

- `skills/sdd-workflow/SKILL.md` — the Flywheel closes when captured KnowHow feeds new CP-xx or Wiring Matrix entries in the next spec.
- `skills/harness-engineering/SKILL.md` — Flywheel concept canonical.
- `skills/bootstrapping-harness/SKILL.md` — creates the KnowHow map + initial files.
- `skills/systematic-debugging/SKILL.md` — common upstream of capturable learnings.

## Hook Integration

The `capture-knowhow-reminder` hook (`Stop` / `agentStop`) nudges this skill at session end. The hook is a best-effort reminder; it never blocks the user and never writes files itself — this skill does the writing once invoked.
```

**Steps:**

- [ ] **1.4.1 建立目錄與寫檔**

```bash
mkdir -p skills/capturing-knowhow
```

- [ ] **1.4.2 寫入上述完整內容到 `skills/capturing-knowhow/SKILL.md`**

- [ ] **1.4.3 Commit**

```bash
git add skills/capturing-knowhow/SKILL.md
git commit -m "feat(skills): add capturing-knowhow skill for KnowHow flywheel"
```

---

### Task 1.5: `skills/bootstrapping-harness/SKILL.md` + templates

**Files:**
- Create: `skills/bootstrapping-harness/SKILL.md`
- Create: `skills/bootstrapping-harness/templates/README.md`
- Create: `skills/bootstrapping-harness/templates/knowhow-map.md`
- Create: `skills/bootstrapping-harness/templates/wiring-matrix.md`

**Purpose:** 初始化一個新 workspace 的 Layer 2（`docs/superpowers/{README.md, specs/, plans/, knowhow/, knowhow-map.md, wiring-matrix.md}` + `scripts/evaluators/` 占位）。

**Full inline content — `skills/bootstrapping-harness/SKILL.md`：**

```markdown
---
name: bootstrapping-harness
description: Scaffold a project's Layer 2 harness structure. Use when a new workspace adopts Superpowers and needs docs/superpowers/{specs,plans,knowhow,knowhow-map.md,wiring-matrix.md}, scripts/evaluators/ placeholders, and an output-language convention. Interactive — asks the user which language KnowHow should be written in and which initial knowledge areas to seed.
---

# Bootstrapping Harness

One-shot scaffolder for the project-level (Layer 2) Harness structure.

## When to Use

- A new workspace adopts Superpowers and has no `docs/superpowers/` yet.
- The existing `docs/superpowers/` is missing `knowhow-map.md` or `wiring-matrix.md`.
- User asks: "set up superpowers for this project", "initialize harness", or similar.

Do NOT use when the structure is already complete and matches the Discovery Contract.

## The Layer 2 Shape

```
<workspace>/
├── docs/
│   └── superpowers/
│       ├── README.md           ← project conventions (language, owners, etc.)
│       ├── specs/              ← feature specs
│       ├── plans/              ← implementation plans
│       ├── knowhow/            ← long-lived KnowHow files
│       ├── knowhow-map.md      ← knowledge area → file/skill/steering mapping
│       └── wiring-matrix.md    ← project-wide module wiring (optional; per-spec matrices preferred)
└── scripts/
    └── evaluators/             ← Mode A deterministic evaluators (placeholder)
        └── README.md           ← when to add Mode A script, when Mode B is enough
```

## The Procedure

**Step 1 — Discover existing state.**

Check each expected path. For anything that exists, do not overwrite; report it and move on.

**Step 2 — Ask language convention (interactive).**

Ask the user exactly this (one question only):

> "What language should KnowHow / knowhow-map / wiring-matrix files be written in? (English / Traditional Chinese / Simplified Chinese / other — please specify)"

Record answer in `docs/superpowers/README.md` as:

\```markdown
## Output Language Convention

- Specs / plans: follow conversation language (defaults to steering layer)
- KnowHow / knowhow-map / wiring-matrix: <user answer>
- Runtime evaluator scripts: English (convention)
\```

**Step 3 — Ask initial knowledge areas (interactive, optional).**

Ask:

> "What are the 3–5 main knowledge areas in this project? (e.g. frontend rendering, backend API, data pipeline; can skip)"

If the user lists areas, seed `knowhow-map.md` with matching rows. Otherwise seed the template header only.

**Step 4 — Materialize from templates.**

Copy each template from `skills/bootstrapping-harness/templates/` to the target path, replacing `<PLACEHOLDER>` tokens with user answers.

- `templates/README.md`        → `docs/superpowers/README.md`
- `templates/knowhow-map.md`   → `docs/superpowers/knowhow-map.md`
- `templates/wiring-matrix.md` → `docs/superpowers/wiring-matrix.md`

Create empty folders `docs/superpowers/specs/`, `docs/superpowers/plans/`, `docs/superpowers/knowhow/`, `scripts/evaluators/`, each with a `.gitkeep`.

Create `scripts/evaluators/README.md` with:

\```markdown
# Runtime Evaluators (Layer 3)

Put deterministic evaluators here (Mode A). Typical layout:

- `check-<invariant>.sh` — shell invariant check
- `validate-<contract>.py` — schema / contract check

Prefer Mode B (agent-native: shell, MCP, subagent) while exploring.
Promote to Mode A once a check is run repeatedly and the rule is stable.

See `skills/harness-engineering/SKILL.md` and `docs/harness-extension-guide.md`.
\```

**Step 5 — Confirm & summarize.**

Report what was created (paths + one-line description each). Ask the user to commit.

## Non-Goals

- Do NOT install IDE-specific files (`.claude-plugin/`, `.cursor/rules/`, `.kiro/`). Those are Layer 1 (shipped with the plugin) or per-IDE concerns.
- Do NOT write project-specific skills. User should author those on demand.

## Related Skills

- `skills/capturing-knowhow/SKILL.md` — uses the `knowhow-map.md` this skill seeds.
- `skills/harness-engineering/SKILL.md` — Wiring Matrix canonical template.
- `skills/writing-plans/SKILL.md` — consumes `docs/superpowers/plans/`.
```

**Full inline content — `skills/bootstrapping-harness/templates/README.md`：**

```markdown
# Superpowers Layer 2 — <PROJECT_NAME>

Project-specific extension for Superpowers.

## Layout

- `specs/`        — feature specs (requirements + design + tasks)
- `plans/`        — implementation plans
- `knowhow/`      — long-lived KnowHow files
- `knowhow-map.md` — index of knowledge areas → KnowHow file + related skill/steering
- `wiring-matrix.md` — (optional) project-wide wiring reference; per-spec matrices are preferred

## Output Language Convention

- Specs / plans: follow conversation language (defaults to steering layer)
- KnowHow / knowhow-map / wiring-matrix: <LANGUAGE_ANSWER>
- Runtime evaluator scripts: English (convention)

## How to Use

- New feature → `skills/brainstorming` → write spec under `specs/<date>-<name>.md`
- Have a spec → `skills/writing-plans` → write plan under `plans/<date>-<name>.md`
- Execute plan → `skills/subagent-driven-development`
- Session ends with new learnings → `skills/capturing-knowhow` → append to the right `knowhow/*.md`
- Scan spec compliance → `/scan-spec <name>` or `skills/sdd-scan`

See the canonical guide: `docs/harness-extension-guide.md` (in the Superpowers plugin).
```

**Full inline content — `skills/bootstrapping-harness/templates/knowhow-map.md`：**

```markdown
# KnowHow Map — <PROJECT_NAME>

Index of knowledge areas. Update whenever a new area surfaces.

| Knowledge area | KnowHow file | Related skill | Related steering |
|---|---|---|---|
| <AREA_1> | `knowhow/<area-1>.md` | — | — |
| <AREA_2> | `knowhow/<area-2>.md` | — | — |
| <AREA_3> | `knowhow/<area-3>.md` | — | — |

## Update rules

- Append new areas at the bottom.
- If an area splits, keep the old row and add the new one; do not delete.
- Related skill / steering columns may be empty at start; fill in as patterns emerge.
```

**Full inline content — `skills/bootstrapping-harness/templates/wiring-matrix.md`：**

```markdown
# Project Wiring Matrix — <PROJECT_NAME>

Per-spec Wiring Matrices are preferred (see `skills/harness-engineering/SKILL.md`). This file is for project-wide / long-lived wiring that spans specs.

## Main Loop / Entry Point

| Order | Caller | Callee method | Argument source | Output / side-effect |
|---|---|---|---|---|
| 1 | <entry> | <subsystem>.Init(ctx) | <config> | <state set> |

## Event Handlers

| Trigger | Caller | Callee method | Precondition |
|---|---|---|---|
| <event> | <handler> | <method> | <precondition> |

Keep rows short. Per-spec design docs carry the detail.
```

**Steps:**

- [ ] **1.5.1 建立目錄結構**

```bash
mkdir -p skills/bootstrapping-harness/templates
```

- [ ] **1.5.2 寫入 `skills/bootstrapping-harness/SKILL.md`**（上述完整內容）

- [ ] **1.5.3 寫入 3 份 templates**（上述完整內容）

- [ ] **1.5.4 Verify templates 可讀**

Run: `ls skills/bootstrapping-harness/templates/`
Expected: `README.md knowhow-map.md wiring-matrix.md`

- [ ] **1.5.5 Commit**

```bash
git add skills/bootstrapping-harness/
git commit -m "feat(skills): add bootstrapping-harness skill and templates"
```

---

### Task 1.6: Phase 1 Checkpoint — 5 canonical skills 驗證

**Files:** read-only

- [ ] **1.6.1 列出 Phase 1 所有新檔案**

Run: `git log --name-only --format= feat/kiro-integration ^main -- skills/ | grep -E 'skills/(harness-engineering|sdd-workflow|sdd-scan|capturing-knowhow|bootstrapping-harness)/' | sort -u`
Expected: 至少包含 5 個 `SKILL.md` + 3 個 templates（8 項）。

- [ ] **1.6.2 所有 skill 的 front-matter `name` 與目錄名一致**

Run:
```bash
for d in skills/harness-engineering skills/sdd-workflow skills/sdd-scan skills/capturing-knowhow skills/bootstrapping-harness; do
  name=$(awk '/^---/{n++; next} n==1 && /^name:/{sub("name:[[:space:]]*",""); print; exit}' "$d/SKILL.md")
  base=$(basename "$d")
  [ "$name" = "$base" ] && echo "OK  $d" || echo "MISMATCH $d (name=$name)"
done
```
Expected: 全部 OK。

- [ ] **1.6.3 所有 skill 的 description 非空**

Run:
```bash
for f in skills/{harness-engineering,sdd-workflow,sdd-scan,capturing-knowhow,bootstrapping-harness}/SKILL.md; do
  desc=$(awk '/^---/{n++; next} n==1 && /^description:/' "$f")
  [ -n "$desc" ] && echo "OK  $f" || echo "EMPTY $f"
done
```
Expected: 全部 OK。

- [ ] **1.6.4 無 commit 遺漏**

Run: `git status --porcelain skills/`
Expected: 空輸出。

---

## Phase 2 — Modify Upstream Skills

> **Phase intent:** 在既有 upstream skills 中植入 SDD/Harness 引用，不破壞原語意、不壓行數。每個 skill 獨立 commit，便於 revert。

### Task 2.1: `skills/writing-plans/SKILL.md` — 加入 CP-xx + Wiring Matrix reference

**Files:**
- Modify: `skills/writing-plans/SKILL.md`

**Change set:** 在 `## File Structure` 段之後（約行 34）、`## Bite-Sized Task Granularity` 段之前，插入新段 `## Correctness Properties & Wiring (optional, when SDD applies)`。保留其餘內容不變；保留 `## Self-Review` 段並在 `Type consistency` 之後增補一個 check item。

**Inline diff / insertion content：**

在 `## File Structure` 結尾段（"This structure informs the task decomposition..."）之後，新增：

```markdown
## Correctness Properties & Wiring (optional, when SDD applies)

If the spec was produced via `skills/sdd-workflow/SKILL.md`, the plan must honor two extra contracts:

- **Correctness Properties** — Requirements section lists `CP-<NN>: <invariant>` items. Each implementation task that touches a CP must include a PBT step, not only example-based tests. Reference the CP ID in the task.
- **Wiring Matrix** — Design section lists caller → callee → timing → arg source. For every new exported function whose row in the matrix points at an external caller, follow the implementation task with a *wiring task* whose steps integrate the new function into that caller (per `skills/harness-engineering/SKILL.md`).

If the spec has neither CP-xx nor a Wiring Matrix, this section is a no-op — proceed with the standard TDD-shaped tasks below.
```

**在 `## Self-Review` 段的 `**3. Type consistency:**` 之後（約行 130），新增：**

```markdown
**4. SDD contract coverage (only if CP-xx or Wiring Matrix exist):** For each CP-xx in the spec, point to the task and the PBT step covering it. For each Wiring Matrix row whose callee is newly introduced in this plan, confirm a wiring task integrates it. List gaps and add tasks.
```

**Steps:**

- [ ] **2.1.1 Read current file to confirm anchor lines**

Run: `head -n 40 skills/writing-plans/SKILL.md`
Expected: 看到 `## File Structure` 段與 `## Bite-Sized Task Granularity` 段。

- [ ] **2.1.2 Insert new `## Correctness Properties & Wiring` section** at the anchor described above. Preserve leading/trailing blank line.

- [ ] **2.1.3 Append new `**4. SDD contract coverage**` item** after `**3. Type consistency**` in `## Self-Review`.

- [ ] **2.1.4 Verify diff**

Run: `git diff skills/writing-plans/SKILL.md | head -n 60`
Expected: 看到兩處插入、無刪除、無其他段落被動到。

- [ ] **2.1.5 Broken link check**

Run: `grep -oE 'skills/[a-z-]+/SKILL\.md' skills/writing-plans/SKILL.md | sort -u | xargs -I{} sh -c '[ -f "{}" ] && echo OK {} || echo MISS {}'`
Expected: 全部 OK。

- [ ] **2.1.6 Commit**

```bash
git add skills/writing-plans/SKILL.md
git commit -m "feat(skills): writing-plans — reference CP-xx and Wiring Matrix for SDD specs"
```

---

### Task 2.2: `skills/subagent-driven-development/spec-reviewer-prompt.md` — 加入 SDD compliance check

**Files:**
- Modify: `skills/subagent-driven-development/spec-reviewer-prompt.md`

**Change set:** 原檔只檢查「missing / extra / misunderstanding」三大類；新增「SDD compliance」作為第四類，僅在 spec 宣稱採用 SDD 時生效。不改現有 prompt 的主要結構。

**Inline insertion content：**

在 prompt 模板內的 `**Verify by reading code, not by trusting report.**` 之前（約第 56 行附近）、於 `**Misunderstandings:**` 段之後，插入：

```markdown
    **SDD compliance (only if the spec uses CP-xx / Wiring Matrix):**
    - Does every CP-<NN> in the requirements have a corresponding PBT (not just example tests)?
    - Does the Wiring Matrix reflect the code? For each row whose callee was newly introduced in this task, is the callee actually invoked at the specified caller and timing?
    - Are preconditions / postconditions from the design honored at call sites?

    If the spec has no SDD markers, skip this section and proceed with the three checks above.
```

**Steps:**

- [ ] **2.2.1 Read current file** to confirm anchor position.
- [ ] **2.2.2 Insert SDD compliance block** at the specified anchor.
- [ ] **2.2.3 Verify prompt remains a single fenced code block** (check that the added lines are inside the code block, with leading 4-space indentation matching surrounding lines).

Run: `awk '/^\`\`\`$/{inblock=!inblock} {if(inblock) count++} END{print count}' skills/subagent-driven-development/spec-reviewer-prompt.md`
Expected: a sane positive integer (no split of the fenced block).

- [ ] **2.2.4 Commit**

```bash
git add skills/subagent-driven-development/spec-reviewer-prompt.md
git commit -m "feat(skills): spec-reviewer-prompt — add optional SDD compliance checks"
```

---

### Task 2.3: `skills/verification-before-completion/SKILL.md` — 加入 5-Dim Audit reference

**Files:**
- Modify: `skills/verification-before-completion/SKILL.md`

**Change set:** 在 `## When To Apply` 段之後、`## The Bottom Line` 段之前，新增段 `## Integration with Harness 5-Dimension Audit`。canonical 5-Dim 內容**不** inline（canonical 歸屬在 `harness-engineering`），只加 reference + 觸發時機摘要。保留既有語意。

**Inline insertion content：**

```markdown
## Integration with Harness 5-Dimension Audit

For feature-level checkpoints (not every single verification), also run the 5-dimension audit canonical at `skills/harness-engineering/SKILL.md`:

1. Feedback coverage — every new exported function has tests + integration tests for cross-module calls.
2. Wiring integrity — every new method has at least one caller.
3. Latent / Deterministic split — no deterministic logic left to inference.
4. Test health — no flaky tests.
5. Flywheel health — session learnings captured via `skills/capturing-knowhow/SKILL.md`.

This audit is the completion gate for a whole spec / phase, not individual tasks. Individual tasks still use the Iron Law above.
```

**Steps:**

- [ ] **2.3.1 Locate anchor** — `## When To Apply` end and `## The Bottom Line` start.
- [ ] **2.3.2 Insert new section** exactly between them.
- [ ] **2.3.3 Verify broken link**

Run: `grep -oE 'skills/[a-z-]+/SKILL\.md' skills/verification-before-completion/SKILL.md | sort -u`
Expected: include `skills/harness-engineering/SKILL.md` and `skills/capturing-knowhow/SKILL.md`, both resolving to existing files.

- [ ] **2.3.4 Commit**

```bash
git add skills/verification-before-completion/SKILL.md
git commit -m "feat(skills): verification-before-completion — reference 5-dim audit"
```

---

## Phase 3 — Commands & Hooks

### Task 3.1: `commands/capture-knowhow.md`

**Files:**
- Create: `commands/capture-knowhow.md`

**Full inline content：**

```markdown
---
description: "Invoke the superpowers:capturing-knowhow skill to capture session learnings into the project's KnowHow base."
---

Invoke the `superpowers:capturing-knowhow` skill. Follow its Discovery Contract to locate `docs/superpowers/knowhow-map.md`; if missing, offer `skills/bootstrapping-harness`.
```

- [ ] **3.1.1 Create file with above content.**
- [ ] **3.1.2 Commit**

```bash
git add commands/capture-knowhow.md
git commit -m "feat(commands): /capture-knowhow"
```

---

### Task 3.2: `commands/scan-spec.md`

**Files:**
- Create: `commands/scan-spec.md`

**Full inline content：**

```markdown
---
description: "Invoke the superpowers:sdd-scan skill to scan a spec for SDD compliance (CP-xx, preconditions, Wiring Matrix, BDD/TDD structure)."
argument_hint: "<spec-name-or-path>"
---

Invoke the `superpowers:sdd-scan` skill against `$ARGUMENTS`.
If `$ARGUMENTS` is empty, use the Discovery Contract to find the most recent spec under `docs/superpowers/specs/` or `.kiro/specs/`.
Report the findings as a Markdown table per the skill's Output Format section.
```

- [ ] **3.2.1 Create file with above content.**
- [ ] **3.2.2 Commit**

```bash
git add commands/scan-spec.md
git commit -m "feat(commands): /scan-spec"
```

---

### Task 3.3: `hooks/spec-sdd-check` 腳本

**Files:**
- Create: `hooks/spec-sdd-check`（no extension；polyglot wrapper 相容）

**Purpose:** Claude Code `PostToolUse: Edit|Write|MultiEdit` / Cursor `onAfterFileChange`。當被編輯的檔案是 `**/specs/**/*.md` 時，emit 一段 agent reminder 走 SDD 合規檢查。Reminder 走 `additional_context` / `additionalContext` 注入，不 block 使用者。

**Full inline content：**

```bash
#!/usr/bin/env bash
# spec-sdd-check — PostToolUse reminder: when a spec file is edited, nudge the
# agent to run sdd-scan next turn.
#
# Input: hook event JSON is on stdin (Claude Code) or env vars (Cursor).
# Output: JSON with additional_context / additionalContext, based on IDE.

set -euo pipefail

is_spec_path() {
    case "$1" in
        *'/specs/'*'.md') return 0 ;;
        .kiro/specs/*/*.md) return 0 ;;
        *) return 1 ;;
    esac
}

# Try to extract a file path hint from env / stdin.
# Claude Code provides tool-use info via stdin JSON; Cursor provides env vars
# such as CURSOR_CHANGED_FILE. We accept either; if we cannot determine a path
# we fall back to emitting a generic reminder (still safe — it's just a hint).

changed_file="${CURSOR_CHANGED_FILE:-}"
if [ -z "$changed_file" ] && [ -t 0 ] = false 2>/dev/null; then
    # best-effort: read first line of stdin if present
    read -r line || true
    changed_file=$(printf '%s' "$line" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]+"' | head -n1 | sed -E 's/.*"([^"]+)"$/\1/')
fi

if [ -n "$changed_file" ] && ! is_spec_path "$changed_file"; then
    # Not a spec edit — silent no-op.
    echo '{}'
    exit 0
fi

context='<system_reminder>A spec file was just edited. Before continuing, consider running `superpowers:sdd-scan` (or `/scan-spec`) on it to check: CP-xx Correctness Properties, precondition/postcondition annotations, Wiring Matrix presence, and BDD/TDD task structure. Skip if this edit was cosmetic.</system_reminder>'

if [ -n "${CURSOR_PLUGIN_ROOT:-}" ]; then
    printf '{"additional_context":"%s"}\n' "$context"
elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
    printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s"}}\n' "$context"
else
    printf '{"additionalContext":"%s"}\n' "$context"
fi

exit 0
```

- [ ] **3.3.1 Create file** at `hooks/spec-sdd-check` with above content.
- [ ] **3.3.2 Set executable** (Unix only).

```bash
chmod +x hooks/spec-sdd-check
```

- [ ] **3.3.3 Sanity run (no stdin, no env)**

Run: `bash hooks/spec-sdd-check < /dev/null`
Expected: exit 0; output is JSON (either `{}` or one of the additional-context envelopes).

- [ ] **3.3.4 Commit**

```bash
git add hooks/spec-sdd-check
git commit -m "feat(hooks): spec-sdd-check reminder script"
```

---

### Task 3.4: `hooks/capture-knowhow-reminder` 腳本

**Files:**
- Create: `hooks/capture-knowhow-reminder`

**Full inline content：**

```bash
#!/usr/bin/env bash
# capture-knowhow-reminder — Stop / agentStop reminder: nudge the agent to
# consider running superpowers:capturing-knowhow at session end.

set -euo pipefail

context='<system_reminder>Session is ending. If this session produced new KnowHow (a bug root-caused to an undocumented constraint, a mental model the user corrected, a failed approach with a lesson, an undocumented API behavior, or a design decision shift), invoke `superpowers:capturing-knowhow` (or `/capture-knowhow`) before you finish. Typo-only / format-only sessions do not need it.</system_reminder>'

if [ -n "${CURSOR_PLUGIN_ROOT:-}" ]; then
    printf '{"additional_context":"%s"}\n' "$context"
elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
    printf '{"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":"%s"}}\n' "$context"
else
    printf '{"additionalContext":"%s"}\n' "$context"
fi

exit 0
```

- [ ] **3.4.1 Create file + chmod +x.**
- [ ] **3.4.2 Sanity run**

Run: `bash hooks/capture-knowhow-reminder`
Expected: exit 0; JSON output.

- [ ] **3.4.3 Commit**

```bash
git add hooks/capture-knowhow-reminder
git commit -m "feat(hooks): capture-knowhow-reminder reminder script"
```

---

### Task 3.5: Wire into `hooks/hooks.json`（Claude Code）

**Files:**
- Modify: `hooks/hooks.json`

**Current state (for reference):**

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear|compact",
        "hooks": [ { "type": "command", "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" session-start", "async": false } ]
      }
    ]
  }
}
```

**Target state:**

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" session-start",
            "async": false
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" spec-sdd-check",
            "async": false
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" capture-knowhow-reminder",
            "async": true
          }
        ]
      }
    ]
  }
}
```

- [ ] **3.5.1 Overwrite `hooks/hooks.json` with Target state.**

- [ ] **3.5.2 Validate JSON**

Run (Unix): `python -m json.tool hooks/hooks.json > /dev/null && echo OK || echo FAIL`
Run (Windows): `powershell -Command "Get-Content hooks/hooks.json | ConvertFrom-Json | Out-Null; Write-Host OK"`
Expected: `OK`.

- [ ] **3.5.3 Commit**

```bash
git add hooks/hooks.json
git commit -m "feat(hooks): wire spec-sdd-check (PostToolUse) and capture-knowhow-reminder (Stop)"
```

---

### Task 3.6: Wire into `hooks/hooks-cursor.json`（Cursor）

**Files:**
- Modify: `hooks/hooks-cursor.json`

**Current state (for reference):**

```json
{
  "version": 1,
  "hooks": {
    "sessionStart": [ { "command": "./hooks/session-start" } ]
  }
}
```

**Target state：**

```json
{
  "version": 1,
  "hooks": {
    "sessionStart": [
      { "command": "./hooks/session-start" }
    ],
    "onAfterFileChange": [
      {
        "command": "./hooks/run-hook.cmd",
        "args": ["spec-sdd-check"]
      }
    ],
    "onStop": [
      {
        "command": "./hooks/run-hook.cmd",
        "args": ["capture-knowhow-reminder"]
      }
    ]
  }
}
```

> **Note:** Cursor 的 hook event 命名（`onAfterFileChange` / `onStop`）若與實際 Cursor runtime 有出入，Phase 6 smoke test 會抓出；屆時調整以 runtime 為準。

- [ ] **3.6.1 Overwrite `hooks/hooks-cursor.json` with Target state.**
- [ ] **3.6.2 Validate JSON**

Run: `python -m json.tool hooks/hooks-cursor.json > /dev/null && echo OK`
Expected: `OK`.

- [ ] **3.6.3 Commit**

```bash
git add hooks/hooks-cursor.json
git commit -m "feat(hooks): wire Cursor hooks for spec-sdd-check and capture-knowhow-reminder"
```

---

## Phase 4 — Docs

### Task 4.1: `docs/harness-extension-guide.md`

**Files:**
- Create: `docs/harness-extension-guide.md`

**Full inline content：**

```markdown
# Harness Extension Guide

How to extend Superpowers into a concrete project — the Layer 1 / Layer 2 / Layer 3 model.

## The Three Layers

```
Layer 1  Framework Core (this plugin)
         skills/ + commands/ + hooks/ + docs/ + plugin manifests
         Zero project assumptions.

Layer 2  Project Extension (inside a workspace)
         docs/superpowers/specs /plans /knowhow /knowhow-map.md
         .cursor/skills/  .kiro/skills/  — IDE-specific extensions
         Per-project conventions and domain knowledge.

Layer 3  Runtime Evaluators (inside a workspace)
         Mode A  scripts/evaluators/*.sh — deterministic, reproducible
         Mode B  agent-native (shell, MCP, subagent) — exploratory, inferential
         Promotion: Mode B repeat patterns → formalize into Mode A scripts.
```

Layer 1 never assumes Layer 2 or 3 exists. Core skills use the Discovery Contract to locate Layer 2 files gracefully.

## Discovery Contract (Layer 2 Lookup Priority)

Core skills resolve Layer 2 files in this order:

1. `${WORKSPACE_ROOT}/docs/superpowers/<filename>`
2. `${WORKSPACE_ROOT}/.kiro/<filename>` (Kiro legacy)
3. `${WORKSPACE_ROOT}/<filename>` (repo root fallback)

Applies to: `knowhow-map.md`, `wiring-matrix.md`, `specs/*.md`, `plans/*.md`, `scripts/evaluators/*`.

## Mode A vs Mode B Evaluators

| Dimension | Mode A | Mode B |
|---|---|---|
| Form | `scripts/evaluators/*.sh` etc. | Agent-native (shell, MCP, subagent) |
| I/O shape | Fixed | Free |
| Good for | Repetitive, rule-stable checks | Unspecified / judgment-heavy |
| Reproducible | Yes | No |
| Speed | Fast | Slow |

**Promotion path (Flywheel):** Mode B check repeated many times → `skills/capturing-knowhow` captures the pattern → engineer formalizes as Mode A script → subsequent runs use Mode A.

## Output Language Convention

Set per-project in `docs/superpowers/README.md`.

| Artifact | Language | Controlled by |
|---|---|---|
| Core skill content | English | Layer 1 (this plugin) |
| Agent replies | User / workspace steering | `CLAUDE.md` / `AGENTS.md` / `.kiro/steering/language.md` |
| `specs/*.md`, `plans/*.md`, `wiring-matrix.md` | Conversation language | Steering layer |
| `knowhow/*.md`, `knowhow-map.md` | Project-wide, stable | `docs/superpowers/README.md` convention (asked by `bootstrapping-harness`) |
| `scripts/evaluators/*` | English (convention) | — |

## Cross-IDE Support Matrix

| IDE | Plugin manifest | Skill discovery | Commands | Hooks | Steering |
|---|---|---|---|---|---|
| Claude Code | `.claude-plugin/plugin.json` | `skills/` via description | `commands/*.md` | `hooks/hooks.json` | `CLAUDE.md` |
| Cursor | `.cursor-plugin/plugin.json` | `skills/` via description | `commands/*.md` | `hooks/hooks-cursor.json` | `AGENTS.md` / `.cursor/rules/` |
| Kiro | `.kiro/` | `.kiro/skills/*/SKILL.md` via inclusion | — | `.kiro/hooks/*.kiro.hook` | `.kiro/steering/` |
| Codex | `.codex/INSTALL.md` (symlinks) | `skills/` via description | via symlink | — | `AGENTS.md` |
| OpenCode | `docs/README.opencode.md` | `skills/` via description | — | — | `AGENTS.md` |
| Gemini CLI | (no dedicated doc; `AGENTS.md` + skill discovery) | `skills/` via description (verify per release) | — | — | `AGENTS.md` |

## Getting Started in a New Workspace

```
1. Invoke skills/bootstrapping-harness         → scaffolds Layer 2
2. Brainstorm a feature (skills/brainstorming) → writes docs/superpowers/specs/<name>.md
3. (Optional) /scan-spec <name>                → SDD compliance scan
4. Write a plan (skills/writing-plans)         → docs/superpowers/plans/<name>.md
5. Execute (skills/subagent-driven-development) with two-stage review
6. Session ends → capture learnings (/capture-knowhow)
```

## Related

- `skills/harness-engineering/SKILL.md` — framework canonical + 5-dim audit + Wiring Matrix template.
- `skills/sdd-workflow/SKILL.md` — SDD → BDD → TDD flow overview.
- `skills/bootstrapping-harness/SKILL.md` — Layer 2 scaffolder.
- `docs/superpowers/specs/2026-04-22-kiro-superpowers-integration-design.md` — the design behind this integration.
```

**Steps:**

- [ ] **4.1.1 Create file with above content.**
- [ ] **4.1.2 Broken-link check**

Run:
```bash
grep -oE 'skills/[a-z-]+/SKILL\.md' docs/harness-extension-guide.md | sort -u | xargs -I{} sh -c '[ -f "{}" ] && echo OK {} || echo MISS {}'
```
Expected: all OK.

- [ ] **4.1.3 Commit**

```bash
git add docs/harness-extension-guide.md
git commit -m "docs: add harness-extension-guide.md (Layer 1/2/3 model)"
```

---

### Task 4.2: Update root `README.md` Features section

**Files:**
- Modify: `README.md`

**Change set:** 在現有 Features / Overview 段加入一行（位置依實際 README 結構；若無 Features 段則附加到 Overview 底）：

```markdown
- **Harness Engineering & SDD workflow** (new) — `skills/harness-engineering`, `skills/sdd-workflow`, `skills/sdd-scan`, `skills/capturing-knowhow`, `skills/bootstrapping-harness`. See `docs/harness-extension-guide.md`.
```

若現有 README 無明確 Features 清單，則在 Overview / Introduction 段末加一段：

```markdown
### Extending into Your Project

This plugin ships generic core skills; your project grows a Layer 2 extension (`docs/superpowers/`) and optional Layer 3 evaluators. See `docs/harness-extension-guide.md` for the scaffolding procedure.
```

- [ ] **4.2.1 Read current README.md to decide insertion point.**
- [ ] **4.2.2 Insert the Features bullet and/or the "Extending into Your Project" subsection per anchor found.**
- [ ] **4.2.3 Commit**

```bash
git add README.md
git commit -m "docs: README — mention Harness Engineering skills and extension guide"
```

---

## Phase 5 — `.kiro/` Adapter Conversion

> **Phase intent:** `.kiro/` 不再承載內容，只承載 Kiro-discovery front-matter + canonical pointer + quick reference。每個 adapter commit 前後都可跑 `scripts/verify-adapters.sh`。

### Adapter 標準結構（所有 adapter task 都套用這個模板）

```markdown
---
inclusion: <manual|fileMatch|always>                  # Kiro front-matter
fileMatchPattern: "<pattern>"                          # only if fileMatch
name: <skill-name>                                     # same as canonical
description: <EXACT same string as canonical description>
---

<!-- SUPERPOWERS_ADAPTER -->

# <Skill Name> (Kiro Adapter)

> **Canonical**: `skills/<skill-name>/SKILL.md` (this file is the Kiro-side discovery adapter; see canonical for the full content.)

## Quick Reference

- **When to use:** <1–2 lines extracted from canonical>
- **Main output:** <1 line>
- **Key steps:**
  1. <step>
  2. <step>
  3. <step>

## Full Content

See canonical → `skills/<skill-name>/SKILL.md`.
```

Rules:
- `description` **must be byte-identical** to canonical front-matter `description` (verified by `verify-adapters.sh`).
- `<!-- SUPERPOWERS_ADAPTER -->` marker is required for `verify-adapters.sh` to classify the file as an adapter.
- Quick Reference 最多 ~10 行，不要複製 canonical 的完整章節。
- `name` 可省略（Kiro 會用目錄名）；若保留，必須與 canonical `name` 一致。

---

### Task 5.1: `.kiro/skills/harness-engineering/SKILL.md` → adapter

**Files:**
- Replace: `.kiro/skills/harness-engineering/SKILL.md`（原 286 行完整內容 → 替換為 adapter）

**Adapter content（完整）:**

```markdown
---
inclusion: manual
name: harness-engineering
description: Harness Engineering framework — audit, diagnose, and improve an AI agent's harness coverage. Covers Feedforward (Skills/Steering guides), Feedback (Hooks/Tests sensors), Wiring Integrity (Wiring Matrix), Latent vs Deterministic boundary, and the Feedback Flywheel. Use when auditing harness coverage, diagnosing missed wiring, improving agent work quality, authoring new guides or sensors, or discussing harness engineering architecture.
---

<!-- SUPERPOWERS_ADAPTER -->

# Harness Engineering (Kiro Adapter)

> **Canonical**: `skills/harness-engineering/SKILL.md` — this file is the Kiro-side discovery adapter.

## Quick Reference

- **When to use:** auditing harness coverage (Feedforward / Feedback / Wiring / Latent-Deterministic / Flywheel), authoring new skills/steering/hooks, or designing Wiring Matrix for a new spec.
- **Main output:** Wiring Matrix, 5-dimension audit report, remediation plan.
- **Key steps:**
  1. Run the 5-dimension audit on the target scope.
  2. Fill gaps per Remediation Priorities (Computational Feedback → Feedforward Guide → Inferential Feedback → Dynamic Layer).
  3. Add the Wiring Matrix template to the target spec's Design section.

## Full Content

See canonical → `skills/harness-engineering/SKILL.md`.
```

**Steps:**

- [ ] **5.1.1 Overwrite file with adapter content above.**
- [ ] **5.1.2 Run verify-adapters.sh**

Run: `bash scripts/verify-adapters.sh`
Expected: `1 adapter(s) checked, all in sync`, exit 0.

- [ ] **5.1.3 Commit**

```bash
git add .kiro/skills/harness-engineering/SKILL.md
git commit -m "refactor(kiro): harness-engineering → adapter pointing to canonical"
```

---

### Task 5.2: `.kiro/skills/sdd-scan/SKILL.md` → adapter

**Adapter content:**

```markdown
---
inclusion: manual
name: sdd-scan
description: SDD compliance scan. Scans a spec's requirements / design / tasks documents for SDD conformance: CP-xx Correctness Properties, precondition/postcondition, Wiring Matrix, BDD+TDD task structure. Use before running all tasks, when validating spec quality, or when a PostToolUse hook fires on a spec file edit.
---

<!-- SUPERPOWERS_ADAPTER -->

# SDD Scan (Kiro Adapter)

> **Canonical**: `skills/sdd-scan/SKILL.md`

## Quick Reference

- **When to use:** before "run all tasks", when validating a spec, or triggered by `spec-sdd-check` hook.
- **Main output:** Markdown table of compliance findings per `requirements` / `design` / `tasks`.
- **Key steps:**
  1. Resolve target spec via Discovery Contract (argument > active editor > latest).
  2. Scan each section against the checklist in canonical.
  3. Report with ✅ / ❌ and list gaps.

## Full Content

See canonical → `skills/sdd-scan/SKILL.md`.
```

- [ ] **5.2.1 Overwrite. 5.2.2 verify-adapters.sh. 5.2.3 Commit.**

```bash
git add .kiro/skills/sdd-scan/SKILL.md
git commit -m "refactor(kiro): sdd-scan → adapter"
```

---

### Task 5.3: `.kiro/skills/subagent-driven-development/SKILL.md` → adapter

**Adapter content:**

```markdown
---
inclusion: manual
name: subagent-driven-development
description: Use when executing implementation plans with independent tasks in the current session
---

<!-- SUPERPOWERS_ADAPTER -->

# Subagent-Driven Development (Kiro Adapter)

> **Canonical**: `skills/subagent-driven-development/SKILL.md`

## Quick Reference

- **When to use:** executing a plan with independent tasks, staying in the current session, wanting fresh-context subagents per task.
- **Main output:** each task implemented + two-stage review (spec compliance → code quality) + commit.
- **Key steps:**
  1. Read plan, extract all tasks with full text.
  2. For each task: dispatch implementer → dispatch spec reviewer → dispatch code quality reviewer → mark complete.
  3. After all tasks: dispatch final reviewer → invoke `finishing-a-development-branch`.

## Full Content

See canonical → `skills/subagent-driven-development/SKILL.md`.
```

> Note: `.kiro/skills/subagent-driven-development/` 原本附帶 5 個 helper markdown。這些都在 upstream 有對應內容（不同位置），都應刪除：
>
> | Kiro file | Upstream equivalent | Action |
> |---|---|---|
> | `implementer-prompt.md` | `skills/subagent-driven-development/implementer-prompt.md` | Delete (same path duplicate) |
> | `spec-reviewer-prompt.md` | `skills/subagent-driven-development/spec-reviewer-prompt.md` | Delete (same path duplicate) |
> | `code-quality-reviewer-prompt.md` | `skills/subagent-driven-development/code-quality-reviewer-prompt.md` | Delete (same path duplicate) |
> | `requesting-code-review.md` | `skills/requesting-code-review/SKILL.md` (**separate top-level skill**) | Delete (content duplicated in a separate upstream skill) |
> | `receiving-code-review.md` | `skills/receiving-code-review/SKILL.md` (**separate top-level skill**) | Delete (content duplicated in a separate upstream skill) |

- [ ] **5.3.1 Overwrite `SKILL.md`** with the adapter content above.

- [ ] **5.3.2 Verify upstream equivalents exist before deleting**

Run:
```bash
for p in \
  skills/subagent-driven-development/implementer-prompt.md \
  skills/subagent-driven-development/spec-reviewer-prompt.md \
  skills/subagent-driven-development/code-quality-reviewer-prompt.md \
  skills/requesting-code-review/SKILL.md \
  skills/receiving-code-review/SKILL.md; do
  [ -f "$p" ] && echo "OK  $p" || echo "MISS $p"
done
```
Expected: all OK. If any MISS → stop and escalate (upstream layout changed).

- [ ] **5.3.3 Delete the 5 Kiro-side helpers**

```bash
git rm .kiro/skills/subagent-driven-development/implementer-prompt.md
git rm .kiro/skills/subagent-driven-development/spec-reviewer-prompt.md
git rm .kiro/skills/subagent-driven-development/code-quality-reviewer-prompt.md
git rm .kiro/skills/subagent-driven-development/requesting-code-review.md
git rm .kiro/skills/subagent-driven-development/receiving-code-review.md
```

- [ ] **5.3.4 Run verify-adapters.sh**

Run: `bash scripts/verify-adapters.sh`
Expected: exit 0 (adapter description matches canonical).

- [ ] **5.3.5 Commit**

```bash
git add .kiro/skills/subagent-driven-development/
git commit -m "refactor(kiro): subagent-driven-development → adapter; drop duplicated helpers"
```

---

### Task 5.4: `.kiro/skills/brainstorming/SKILL.md` → adapter

**Source:** `.kiro/skills/brainstorming/SKILL.md`（Kiro 特化版 117 行，整合 Kiro Spec 流程）
**Adapter content：**

```markdown
---
inclusion: manual
name: brainstorming
description: Interactive requirement exploration and design dialogue. Use when discussing a new feature, spec, requirement, or starting Requirements stage. One question at a time to clarify intent, propose 2-3 options with trade-offs, present design in sections and confirm each. Forbidden to write any implementation code before design approval.
---

<!-- SUPERPOWERS_ADAPTER -->

# Brainstorming (Kiro Adapter)

> **Canonical**: `skills/brainstorming/SKILL.md`

## Quick Reference

- **When to use:** exploring a fresh requirement before any code; feeding `sdd-workflow` or `writing-plans`.
- **Main output:** an approved design suitable for Spec Requirements/Design stage.
- **Key steps:**
  1. Explore context; optionally offer Visual Companion.
  2. Ask one question at a time; prefer multiple-choice.
  3. Propose 2–3 options with trade-offs; recommend one.
  4. Present design in sections; confirm each.
  5. Self-review (placeholders, consistency, scope, ambiguity).
  6. Await user approval.

## Kiro-specific note

After approval, a Kiro Spec (requirements / design / tasks) is the design document — no separate `docs/plans/` needed in Kiro workflow. Outside Kiro (Claude Code / Cursor), the design is captured in `docs/superpowers/specs/<date>-<name>.md` and turned into a plan by `skills/writing-plans`.

## Full Content

See canonical → `skills/brainstorming/SKILL.md`.
```

- [ ] **5.4.1 Overwrite. 5.4.2 verify-adapters.sh. 5.4.3 Commit.**

```bash
git add .kiro/skills/brainstorming/SKILL.md
git commit -m "refactor(kiro): brainstorming → adapter"
```

---

### Task 5.5: `.kiro/skills/systematic-debugging/SKILL.md` → adapter

**Adapter content：**

```markdown
---
inclusion: manual
name: systematic-debugging
description: Use when facing any bug, test failure, unexpected behavior, performance issue, or integration problem — before proposing a fix. Especially when time pressure tempts skipping investigation, repeated failed fixes, or wanting to act without fully understanding the problem.
---

<!-- SUPERPOWERS_ADAPTER -->

# Systematic Debugging (Kiro Adapter)

> **Canonical**: `skills/systematic-debugging/SKILL.md`

## Quick Reference

- **When to use:** any bug / failure / unexpected behavior before proposing a fix.
- **Core rule:** do not propose a fix until root cause is identified. Fixing symptoms = failure.
- **Key phases:**
  1. Reproduce — minimal, deterministic case.
  2. Isolate — bisect cause.
  3. Understand — why the root cause leads to the symptom.
  4. Fix — only after Understand; follow TDD Red-Green-Refactor.

## Full Content

See canonical → `skills/systematic-debugging/SKILL.md`.
```

- [ ] **5.5.1 Overwrite. 5.5.2 verify-adapters.sh. 5.5.3 Commit.**

```bash
git add .kiro/skills/systematic-debugging/SKILL.md
git commit -m "refactor(kiro): systematic-debugging → adapter"
```

---

### Task 5.6: `.kiro/steering/` — 精簡 + 新增 language.md

**Files:**
- Modify: `.kiro/steering/sdd-bdd-tdd-workflow.md` — 精簡為 pointer + Kiro inclusion rule
- Modify: `.kiro/steering/knowhow-sync-rules.md` — 精簡為 pointer
- Create: `.kiro/steering/language.md` — per-workspace output 語言 override

**Target content — `.kiro/steering/sdd-bdd-tdd-workflow.md`（從 217 行精簡）：**

```markdown
---
inclusion: fileMatch
fileMatchPattern: "**/*_test.go,**/*.test.js,**/*.spec.js,.kiro/specs/**/*.md"
---

# SDD → BDD → TDD Workflow (Kiro Steering Pointer)

This file was the original full SDD-BDD-TDD spec. The canonical content now lives in the Superpowers plugin — it is shared across IDEs (Claude Code / Cursor / Kiro / Codex / OpenCode).

## Canonical

- Overview: `skills/sdd-workflow/SKILL.md`
- TDD discipline: `skills/test-driven-development/SKILL.md`
- Wiring Matrix template + 5-dim audit: `skills/harness-engineering/SKILL.md`
- Static compliance scan: `skills/sdd-scan/SKILL.md`

## Why the steering file still exists

Kiro loads steering via `inclusion: fileMatch`. When a test file or a spec markdown is opened, this file is loaded — it nudges the agent to consult the canonical skills above.

## Kiro-only notes

- Spec folder convention: `.kiro/specs/<feature>/{requirements,design,tasks}.md`
- Running all tasks from `tasks.md`: see `subagent-driven-development` (canonical).

The full SDD rules (CP-xx format, Wiring Matrix, BDD scenarios, TDD Iron Law, Checkpoint 5-dim audit, Task self-review) are in the canonical skills. Do not duplicate them here.
```

**Target content — `.kiro/steering/knowhow-sync-rules.md`（從 84 行精簡）：**

```markdown
---
inclusion: always
---

# KnowHow Sync Rules (Kiro Steering Pointer)

## Canonical

- Skill: `skills/capturing-knowhow/SKILL.md`

## Why the steering file still exists

Kiro loads `inclusion: always` steering on every session. This file keeps a short reminder live in Kiro's context so the agent knows when to invoke `capturing-knowhow`.

## Trigger criteria (short form)

Capture when:
1. A bug was fixed with root cause in a previously unknown constraint.
2. The user corrected the agent's mental model.
3. An approach failed and was replaced; the reason matters next time.
4. An undocumented API / tool / framework behavior was discovered.
5. A design decision shifted (ratio, size, protocol).

Do NOT capture: typo-only, format-only, repeat of existing KnowHow.

## Kiro-only note

The `knowhow-sync.kiro.hook` on `agentStop` reinforces this reminder at session end. See `.kiro/hooks/knowhow-sync.kiro.hook`.
```

**New file — `.kiro/steering/language.md`：**

```markdown
---
inclusion: always
---

# Output Language — Kiro Workspace Override

- Agent replies: Traditional Chinese (繁體中文) unless the user speaks another language.
- Specs / plans / wiring-matrix: same as conversation language.
- KnowHow files / knowhow-map: per project convention — resolve from `docs/superpowers/README.md` (preferred) or `.kiro/skills/docs/` (legacy).
- Core skill content (the plugin): English (do not rewrite).

If the user says "reply in English", switch immediately and keep the same rule for subsequent artifacts until told otherwise.
```

**Steps:**

- [ ] **5.6.1 Overwrite `.kiro/steering/sdd-bdd-tdd-workflow.md` with target content.**
- [ ] **5.6.2 Overwrite `.kiro/steering/knowhow-sync-rules.md` with target content.**
- [ ] **5.6.3 Create `.kiro/steering/language.md`** with target content.
- [ ] **5.6.4 Commit**

```bash
git add .kiro/steering/sdd-bdd-tdd-workflow.md .kiro/steering/knowhow-sync-rules.md .kiro/steering/language.md
git commit -m "refactor(kiro): steering → pointers to canonical skills; add language.md"
```

---

### Task 5.7: `.kiro/hooks/*.kiro.hook` — 指向 canonical

**Files:**
- Modify: `.kiro/hooks/spec-sdd-check.kiro.hook`
- Modify: `.kiro/hooks/knowhow-sync.kiro.hook`
- Leave: `.kiro/hooks/pre-commit-check.kiro.hook`（保持 `enabled: false`，不改）

**Target content — `.kiro/hooks/spec-sdd-check.kiro.hook`：**

```json
{
  "enabled": true,
  "name": "Spec SDD 合規檢查",
  "description": "Spec 檔案被編輯時，提醒執行 superpowers:sdd-scan（canonical：skills/sdd-scan/SKILL.md）",
  "version": "2",
  "when": {
    "type": "fileEdited",
    "patterns": [
      ".kiro/specs/**/requirements.md",
      ".kiro/specs/**/design.md",
      ".kiro/specs/**/tasks.md",
      "docs/superpowers/specs/**/*.md"
    ]
  },
  "then": {
    "type": "askAgent",
    "prompt": "Spec 檔案剛被編輯。請考慮執行 `superpowers:sdd-scan`（或 `/scan-spec`），檢查：CP-xx Correctness Properties、precondition/postcondition、Wiring Matrix、BDD/TDD 任務結構。若本次修改純屬排版/錯字，可略過。Canonical 內容在 `skills/sdd-scan/SKILL.md`。"
  }
}
```

**Target content — `.kiro/hooks/knowhow-sync.kiro.hook`：**

```json
{
  "enabled": true,
  "name": "KnowHow 自動同步",
  "description": "agent 執行結束時，提醒執行 superpowers:capturing-knowhow（canonical：skills/capturing-knowhow/SKILL.md）",
  "version": "2",
  "when": {
    "type": "agentStop"
  },
  "then": {
    "type": "askAgent",
    "prompt": "Session 即將結束。若本次有新 KnowHow（bug 根因是未知限制、使用者指出錯誤認知、嘗試方案失敗並替換、發現未文件化行為、設計決策變更），請執行 `superpowers:capturing-knowhow`（或 `/capture-knowhow`）。純排版/錯字不需要。Canonical 內容在 `skills/capturing-knowhow/SKILL.md`；工作流與 Discovery Contract 以 canonical 為準。"
  }
}
```

**Steps:**

- [ ] **5.7.1 Overwrite `spec-sdd-check.kiro.hook`.**
- [ ] **5.7.2 Overwrite `knowhow-sync.kiro.hook`.**
- [ ] **5.7.3 Validate JSON**

Run: `python -m json.tool .kiro/hooks/spec-sdd-check.kiro.hook > /dev/null && python -m json.tool .kiro/hooks/knowhow-sync.kiro.hook > /dev/null && echo OK`
Expected: `OK`.

- [ ] **5.7.4 Commit**

```bash
git add .kiro/hooks/spec-sdd-check.kiro.hook .kiro/hooks/knowhow-sync.kiro.hook
git commit -m "refactor(kiro): hooks point to canonical capturing-knowhow and sdd-scan"
```

---

### Task 5.8: Update `.kiro/UsageReadme_kiro.md`

**Files:**
- Modify: `.kiro/UsageReadme_kiro.md`

**Change set:** 重寫頂部「模組清單」段，改為「Layer 2 入口 + Canonical 對照表」。保留 `客製化` 說明段中專案特定調整（`environment.md` / `language.md` / `knowhow-sync-rules.md` 映射表）。移除重複指向 canonical 的細節說明。

**Replacement for the `## 模組清單` section（整段替換）：**

```markdown
## 架構總覽（Kiro 端）

`.kiro/` 現在是 **Superpowers plugin 的 Kiro adapter 層**。大多 skill / steering 改為 pointer，指向 Superpowers plugin 內的 canonical 檔案（cross-IDE 共用）。Kiro 原生 discovery（`inclusion`、`fileMatch`、`agentStop` 等）仍保留。

### Skills — adapter 對照

| Kiro skill | 型態 | Canonical |
|---|---|---|
| `skills/brainstorming/` | adapter | `skills/brainstorming/` (plugin) |
| `skills/systematic-debugging/` | adapter | `skills/systematic-debugging/` (plugin) |
| `skills/subagent-driven-development/` | adapter | `skills/subagent-driven-development/` (plugin) |
| `skills/harness-engineering/` | adapter | `skills/harness-engineering/` (plugin) |
| `skills/sdd-scan/` | adapter | `skills/sdd-scan/` (plugin) |
| `skills/git-worktree/` | **Kiro-only**（composite of plugin `using-git-worktrees` + `finishing-a-development-branch`） | — |
| `skills/skill-creator/` | **Kiro-only**（無 upstream 對應） | — |
| `skills/kiro-framework-audit/` | **Kiro-only**（審計 `.kiro/` 自身） | — |

### Steering — pointer + Kiro-only

| Kiro steering | 型態 | Canonical |
|---|---|---|
| `steering/language.md` | Kiro-only override | — |
| `steering/environment.md` | **Kiro-only**（專案環境；匯入後重寫） | — |
| `steering/documentation-rules.md` | **Kiro-only**（commit 時文件規則） | — |
| `steering/knowhow-sync-rules.md` | pointer | `skills/capturing-knowhow/SKILL.md` |
| `steering/skill-routing.md` | **Kiro-only**（Kiro 側 skill 路由表） | — |
| `steering/sdd-bdd-tdd-workflow.md` | pointer | `skills/sdd-workflow/SKILL.md` + `skills/harness-engineering/SKILL.md` |

### Hooks

| Kiro hook | 觸發 | 行為 |
|---|---|---|
| `hooks/spec-sdd-check.kiro.hook` | `fileEdited` (spec md) | 提醒 `superpowers:sdd-scan` |
| `hooks/knowhow-sync.kiro.hook` | `agentStop` | 提醒 `superpowers:capturing-knowhow` |
| `hooks/pre-commit-check.kiro.hook` | `preToolUse`（shell） | disabled（保留，留待專案自行 enable） |

### Canonical 流程（跨 IDE）

1. Brainstorming（`skills/brainstorming/`）→ 設計批准
2. 若採用 SDD：建立 spec（Kiro `.kiro/specs/` 或跨 IDE `docs/superpowers/specs/`）
3. `skills/writing-plans/` 產 plan（Kiro 若用 Spec 流程此步可省）
4. `skills/subagent-driven-development/` 執行 + two-stage review
5. Session 結束 → `skills/capturing-knowhow/`

詳見 plugin 端 `docs/harness-extension-guide.md`。
```

**Steps:**

- [ ] **5.8.1 Read current UsageReadme.**
- [ ] **5.8.2 Replace the "## 模組清單" section** with the above "架構總覽（Kiro 端）" section. Keep the rest of the file unchanged.
- [ ] **5.8.3 Sanity check**

Run: `grep -c 'Canonical' .kiro/UsageReadme_kiro.md`
Expected: ≥ 4 (several rows mention canonical).

- [ ] **5.8.4 Commit**

```bash
git add .kiro/UsageReadme_kiro.md
git commit -m "docs(kiro): UsageReadme — document adapter layout + canonical pointers"
```

---

### Task 5.9: Phase 5 Checkpoint — verify-adapters + Kiro inclusion

- [ ] **5.9.1 Run verify-adapters.sh over all adapters**

Run: `bash scripts/verify-adapters.sh`
Expected: `5 adapter(s) checked, all in sync` (5 skills converted).

- [ ] **5.9.2 Inventory `.kiro/` final structure**

Run:
```bash
ls .kiro/skills/
ls .kiro/steering/
ls .kiro/hooks/
```
Expected: 保留 `kiro-framework-audit/`、`git-worktree/`、`skill-creator/`；其他 5 skill 皆為 adapter；steering 有 `language.md`。

- [ ] **5.9.3 Ensure each adapter has the marker**

Run:
```bash
for f in .kiro/skills/{harness-engineering,sdd-scan,subagent-driven-development,brainstorming,systematic-debugging}/SKILL.md; do
  grep -Fq '<!-- SUPERPOWERS_ADAPTER -->' "$f" && echo "OK  $f" || echo "MISS $f"
done
```
Expected: 全部 OK.

---

## Phase 6 — Cross-IDE Smoke Test

> **Phase intent:** 手動在各 IDE 啟動 worktree，觀察 skill discovery / hook / command 是否如預期觸發。結果寫回 plan 中留底。

### Task 6.1: Claude Code smoke test (一等公民)

**Files:**
- Modify: `docs/superpowers/plans/2026-04-22-kiro-superpowers-integration.md`（append a `## Phase 6 Log` section to this plan file recording results）

**Manual test procedure：**

- [ ] **6.1.1 Open workspace in Claude Code. Trigger SessionStart (new session).**
  Expected: `using-superpowers` context injected (existing behavior; regression check).

- [ ] **6.1.2 In a chat, type: "scan spec 2026-04-22-kiro-superpowers-integration-design for SDD compliance"**
  Expected: agent discovers `superpowers:sdd-scan` and outputs a scan report.

- [ ] **6.1.3 Use `/scan-spec 2026-04-22-kiro-superpowers-integration-design` slash command**
  Expected: equivalent behavior to 6.1.2.

- [ ] **6.1.4 Edit a spec file (e.g. append a blank line to the design doc), save.**
  Expected: `PostToolUse` fires → `spec-sdd-check` reminder injected.

- [ ] **6.1.5 End the session (`/clear` or close).**
  Expected: `Stop` fires → `capture-knowhow-reminder` injected at session end.

- [ ] **6.1.6 Record results in plan's `## Phase 6 Log` section:**

Append:
```markdown
## Phase 6 Log

### Claude Code
- SessionStart: [pass|fail + note]
- Skill discovery (sdd-scan via NL): [pass|fail + note]
- /scan-spec command: [pass|fail + note]
- spec-sdd-check (PostToolUse): [pass|fail + note]
- capture-knowhow-reminder (Stop): [pass|fail + note]
```

- [ ] **6.1.7 If any fail, open a fix task and record.**

---

### Task 6.2: Cursor smoke test

- [ ] **6.2.1–6.2.6 Repeat 6.1 in Cursor.** Hook event names (`onAfterFileChange`, `onStop`) are assumed; if Cursor's runtime expects different names, update `hooks/hooks-cursor.json` and commit as Task 6.2.7.

- [ ] **6.2.7 If fix needed:** commit `hooks/hooks-cursor.json` change with message `fix(hooks): adjust Cursor hook event names for <version>`.

---

### Task 6.3: Kiro smoke test

- [ ] **6.3.1 Open workspace in Kiro.**
- [ ] **6.3.2 Open a `.kiro/specs/*/requirements.md` (create a dummy if none exists).**
  Expected: `.kiro/steering/sdd-bdd-tdd-workflow.md` (pointer version) loaded via fileMatch; agent context includes canonical pointers.
- [ ] **6.3.3 Edit `.kiro/specs/dummy/requirements.md`, save.**
  Expected: `.kiro/hooks/spec-sdd-check.kiro.hook` triggers reminder pointing to canonical.
- [ ] **6.3.4 Use `superpowers:harness-engineering` or `#harness-engineering` (Kiro slash) to invoke the Kiro adapter.**
  Expected: adapter loads; agent reads canonical via the pointer.
- [ ] **6.3.5 End agent turn.**
  Expected: `knowhow-sync.kiro.hook` fires reminder.
- [ ] **6.3.6 Log results.**

---

### Task 6.4: Codex / OpenCode / Gemini CLI — minimum discovery

> These IDEs do NOT support hooks; only verify that skill discovery works.

- [ ] **6.4.1 Codex:** verify `skills/` directory is symlinked/installed per `.codex/INSTALL.md`; trigger skill discovery by natural language ("use harness-engineering skill"). Log pass/fail.
- [ ] **6.4.2 OpenCode:** verify per `docs/README.opencode.md`. Log pass/fail.
- [ ] **6.4.3 Gemini CLI:** no dedicated doc; best-effort via `AGENTS.md` + skill mention in conversation. Log pass/fail and decide whether to open Open Question #5 follow-up.

---

### Task 6.5: Phase 6 commit

- [ ] **6.5.1 Commit `Phase 6 Log` appended to plan file.**

```bash
git add docs/superpowers/plans/2026-04-22-kiro-superpowers-integration.md
git commit -m "docs(plans): phase 6 cross-IDE smoke test log"
```

---

## Phase 7 — E2E Flywheel Demo

> **Phase intent:** 跑一次完整 loop 證明 Layer 1/2/3 都通。使用一個 toy task：為 `/write-plan` command 加一個 `--dry-run` flag。該 change 不影響 repo 實質功能；只是 demo 流程。

### Task 7.1: E2E demo

**Files:**
- Create（during demo）: `docs/superpowers/specs/demo-<date>-write-plan-dry-run.md`
- Create（during demo）: `docs/superpowers/plans/demo-<date>-write-plan-dry-run.md`
- Append（during demo）: `docs/superpowers/knowhow-map.md`（若不存在則先跑 bootstrapping-harness）

**Manual demo procedure：**

- [ ] **7.1.1 If `docs/superpowers/knowhow-map.md` 不存在，invoke `skills/bootstrapping-harness`** (interactive). Answer "English" when prompted for KnowHow language. Seed areas: "commands", "plugin core".

- [ ] **7.1.2 Invoke `skills/brainstorming`** with prompt: "I want to add `--dry-run` to `/write-plan` so the engineer can preview the plan output without touching files."
  Expected: one-question-at-a-time exploration, 2-3 options, sectioned design, user approval. Record the final design in `docs/superpowers/specs/demo-<date>-write-plan-dry-run.md`.

- [ ] **7.1.3 Invoke `/scan-spec demo-<date>-write-plan-dry-run`**
  Expected: scan report. Likely "no CP-xx" because this is a tiny change — that's fine; sdd-scan's Conclusion says "N gaps" — the agent should decide the spec is too small for CP.

- [ ] **7.1.4 Invoke `skills/writing-plans`** to produce `docs/superpowers/plans/demo-<date>-write-plan-dry-run.md`. Expect ~3-5 bite-sized tasks.

- [ ] **7.1.5 Invoke `skills/subagent-driven-development`** to execute. Each task gets implementer → spec reviewer → quality reviewer.

- [ ] **7.1.6 Invoke `skills/verification-before-completion`** with explicit output of "run `/write-plan --dry-run` and show no files created".

- [ ] **7.1.7 Invoke `skills/capturing-knowhow` (or `/capture-knowhow`)** to append a KnowHow entry about the dry-run pattern (e.g., "commands can have --dry-run that only emits stdout").

- [ ] **7.1.8 Verify `docs/superpowers/knowhow-map.md` was updated** with a row for the "commands" knowledge area pointing to `knowhow/commands.md`.

- [ ] **7.1.9 Record E2E result in plan's `## Phase 7 Log`:**

Append:
```markdown
## Phase 7 Log

### E2E Flywheel Demo — write-plan --dry-run

- Bootstrapping: [pass|fail + detail]
- Brainstorming → spec: [pass|fail]
- /scan-spec: [pass|fail]
- writing-plans → plan: [pass|fail]
- subagent-driven-development execution: [pass|fail + task count]
- verification-before-completion: [pass|fail]
- capturing-knowhow → knowhow-map: [pass|fail]

### Lessons captured

- [bullet list of new KnowHow entries]
```

- [ ] **7.1.10 Commit**

```bash
git add docs/superpowers/plans/2026-04-22-kiro-superpowers-integration.md docs/superpowers/specs/demo-*.md docs/superpowers/plans/demo-*.md docs/superpowers/knowhow-map.md docs/superpowers/knowhow/
git commit -m "docs: phase 7 e2e flywheel demo logs"
```

---

## Phase 8 — Final Integration Commit & PR

### Task 8.1: Final checkpoint

- [ ] **8.1.1 Run all verifications one more time:**

```bash
bash scripts/verify-adapters.sh
python -m json.tool hooks/hooks.json > /dev/null
python -m json.tool hooks/hooks-cursor.json > /dev/null
python -m json.tool .kiro/hooks/spec-sdd-check.kiro.hook > /dev/null
python -m json.tool .kiro/hooks/knowhow-sync.kiro.hook > /dev/null
```
Expected: all succeed, `verify-adapters.sh` reports `5 adapter(s) checked, all in sync`.

- [ ] **8.1.2 Broken-link sweep across all touched skill files**

```bash
for f in skills/{harness-engineering,sdd-workflow,sdd-scan,capturing-knowhow,bootstrapping-harness,writing-plans,subagent-driven-development,verification-before-completion}/SKILL.md docs/harness-extension-guide.md; do
  echo "=== $f ==="
  grep -oE '`skills/[a-z-]+/SKILL\.md`' "$f" 2>/dev/null | tr -d '`' | sort -u | while read p; do
    [ -f "$p" ] && echo "  OK  $p" || echo "  MISS $p"
  done
done
```
Expected: all OK.

- [ ] **8.1.3 git log review**

Run: `git log --oneline feat/kiro-integration ^main`
Expected: linear series of commits per Task, roughly 25+ commits.

- [ ] **8.1.4 Ready for PR. Title: `feat: integrate kiro Harness Engineering into Superpowers core`**. Body should reference:
  - `docs/superpowers/specs/2026-04-22-kiro-superpowers-integration-design.md`
  - `docs/superpowers/plans/2026-04-22-kiro-superpowers-integration.md`

(PR creation is out of this plan's scope — user controls when to push and PR.)

---

## Self-Review

### 1. Spec coverage

| Design section | Plan coverage |
|---|---|
| 0. Context & Goals | — (context only) |
| 1. Architecture (3-layer, Mode A/B) | Task 4.1 (guide), Task 1.1 (harness-engineering), Task 1.5 (bootstrapping) |
| 2.1 New core skills | Tasks 1.1–1.5 |
| 2.2 Modify upstream | Tasks 2.1–2.3 |
| 2.3 New commands | Tasks 3.1, 3.2 |
| 2.4 New hooks | Tasks 3.3–3.6 |
| 2.5 New docs | Tasks 4.1, 4.2 |
| 2.6 `.kiro/` adapters | Tasks 5.1–5.8 |
| 3. Per-skill content strategy | Embedded in Tasks 1.x (content), 2.x (modify), 5.x (adapter) |
| 4.1 IDE matrix | Task 4.1 (guide has table) |
| 4.2 Discovery Contract | Task 4.1 + Task 1.4 (capturing-knowhow describes it), Task 1.5 (bootstrapping fills templates) |
| 4.3 Hook mapping | Tasks 3.5, 3.6 |
| 4.4 Command registration | Tasks 3.1, 3.2 |
| 4.5 Language convention | Task 4.1 (guide), Task 1.5 (bootstrapping asks), Task 5.6 (`.kiro/steering/language.md`) |
| 4.6 Plugin manifests | No task needed (confirmed unchanged; Phase 6 verifies) |
| 5. Migration phases | Phase 0–8 in plan |
| 5.4 Success criteria | Task 8.1 verifies each |

**Gap check:** design §4.6 says "OpenCode / Gemini CLI behavior 在 migration phase 驗證" — covered by Task 6.4. No gaps found.

### 2. Placeholder scan

Searched plan for: TBD, TODO, implement later, fill in details, "appropriate error handling", "similar to Task N", steps describing what without showing how.

- Found placeholders only inside quoted *skill content* (e.g., `<PROJECT_NAME>` in the templates) — these are intentional template placeholders that the runtime `bootstrapping-harness` skill replaces. They are not plan placeholders.
- `[pass|fail + note]` in Phase 6/7 logs are template prompts for the operator to fill at runtime — not plan placeholders.

No true placeholders found.

### 3. Type consistency

- `description` field format: all use English single-paragraph text; all start with purpose + "Use when ...".
- Adapter structure: all use the same template (front-matter + `<!-- SUPERPOWERS_ADAPTER -->` marker + Canonical pointer + Quick Reference + Full Content link).
- Skill names referenced across tasks: `harness-engineering`, `sdd-workflow`, `sdd-scan`, `capturing-knowhow`, `bootstrapping-harness`, `writing-plans`, `subagent-driven-development`, `verification-before-completion`, `brainstorming`, `systematic-debugging`, `test-driven-development`. Spot-checked for collisions / typos — clean.
- Hook script names: `spec-sdd-check` and `capture-knowhow-reminder` — consistent across tasks 3.3, 3.4, 3.5, 3.6, 5.7.
- Command names: `/capture-knowhow`, `/scan-spec` — consistent (verb-noun).

No type inconsistencies found.

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-04-22-kiro-superpowers-integration.md`.

**Execution mode: Subagent-Driven (user pre-selected).**

- **REQUIRED SUB-SKILL:** Use `superpowers:subagent-driven-development`
- Fresh subagent per Task (numbered 0.1 through 8.1, ~30 tasks total)
- Two-stage review per Task: (a) spec compliance review — reviewer reads this plan and checks the Task's outputs match; (b) code quality review — reviewer checks file structure, adapter format compliance, JSON validity, script correctness.
- Commit boundary is each Task; Phase boundaries are natural checkpoint moments for the controller to pause and re-read context.

### Recommended Task Grouping for Dispatch

| Dispatch group | Tasks | Notes |
|---|---|---|
| G1 — Prep | 0.1, 0.2 | Must complete before any other group |
| G2 — Canonical skills | 1.1 → 1.5 (sequential) → 1.6 | 1.1 first (others reference it); 1.2-1.5 can loosely parallel but prefer sequential to avoid context drift |
| G3 — Upstream mods | 2.1, 2.2, 2.3 | Parallel-safe |
| G4 — Infra | 3.1, 3.2, 3.3, 3.4, 3.5, 3.6 | 3.5/3.6 depend on 3.3/3.4 |
| G5 — Docs | 4.1, 4.2 | Parallel-safe |
| G6 — Adapters | 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9 | Run verify-adapters.sh after each; 5.9 is a checkpoint (no commit beyond log) |
| G7 — Cross-IDE | 6.1, 6.2, 6.3, 6.4, 6.5 | Mostly manual; agent records results |
| G8 — E2E + Final | 7.1, 8.1 | 7.1 is a live flywheel demo; 8.1 is the final sweep |

### Safety Notes

- Every Task commits independently. If any Task fails review, stop the group and fix before continuing.
- Phase 6 and Phase 7 are heavily manual; the controller (user) makes the pass/fail calls, not a subagent.
- Do NOT merge to main until Phase 8.1 checkpoint passes.
