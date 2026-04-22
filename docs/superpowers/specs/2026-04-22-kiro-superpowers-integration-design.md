# Design: Integrating `.kiro` into Superpowers

**Status**: Draft (design complete, pending implementation plan)
**Date**: 2026-04-22
**Scope**: Fuse the user's Kiro-specific Harness Engineering implementation (`.kiro/`) into the cross-IDE Superpowers plugin, while preserving Kiro's native discovery conventions.

---

## 0. Context & Goals

### 0.1 Current State

- **Superpowers** (this repo) is a cross-IDE Agentic Development framework (Claude Code / Cursor / Codex / OpenCode / Gemini CLI / Kiro) built around Harness Engineering principles. It provides generic skills (`brainstorming`, `writing-plans`, `executing-plans`, `subagent-driven-development`, `verification-before-completion`, `systematic-debugging`, `test-driven-development`, …) and ships a plugin manifest + hooks for each IDE.
- **`.kiro/`** is the user's Kiro-specific implementation added on top of Superpowers. It contributes value-adds Superpowers currently lacks:
  - **SDD workflow**（requirement → design → tasks，以 BDD/TDD 補強）
  - **Harness Engineering** canonical framework（Wiring Matrix、5-Dim Audit）
  - **SDD scanner**（spec placeholder / ambiguity detection）
  - **KnowHow sync**（feedback flywheel）
  - **Bootstrapping harness**（新專案初始化）
  - Kiro-specific auditing skill（`kiro-framework-audit`，保留 Kiro-only）

### 0.2 Goals

1. 把 `.kiro/` 的通用 value-adds 提升為 **cross-IDE** 的 Superpowers core skills，讓 Claude / Cursor / Codex 等 IDE 使用者也能受益。
2. 保留 Kiro 原生的 discovery convention（inclusion mode、`.kiro/hooks`、`.kiro/steering`），改由 **adapter pattern** 轉接到 canonical 內容。
3. 建立 Layer 2/3 擴展機制，讓放進具體專案時可以注入專案特定知識與真實環境驗證。
4. 保持 Superpowers 的 zero-dependency 哲學（純 Markdown + polyglot shell wrapper）。

### 0.3 Non-Goals

- **不** 重寫 upstream Superpowers 既有 skills 的核心語意（僅在必要處加 reference）。
- **不** 要求所有 IDE 支援度一致（Claude/Cursor/Kiro 為一等公民，其他 IDE graceful degradation）。
- **不** 引入 Node/Python 以外的 runtime 相依（保持 polyglot wrapper 就好）。

### 0.4 Integration Strategy

採 **Fork Integration (C) → Independent Plugin (B)** 兩階段：
- **本次（本 design 覆蓋範圍）**：Fork 內做完 hybrid integration，在自有環境先跑順。
- **後續（out of scope）**：把可通用部分打包成獨立 plugin 對外發佈。

---

## 1. Architecture

### 1.1 Three-Layer Extension Model

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 1 — Framework Core（本 repo / Superpowers plugin）     │
│   skills/ + commands/ + hooks/ + docs/ + .claude-plugin/ …   │
│   純通用、無專案偏見                                          │
└────────────────────────┬────────────────────────────────────┘
                         │ Discovery Contract
┌────────────────────────┴────────────────────────────────────┐
│ Layer 2 — Project Extension（放進某專案的 workspace 時產生）  │
│   docs/superpowers/  ← specs / plans / knowhow / wiring      │
│   .cursor/skills/    ← Cursor 特化擴充                       │
│   .kiro/skills/      ← Kiro 特化擴充 / adapter               │
│   每個專案各自維護                                           │
└────────────────────────┬────────────────────────────────────┘
                         │ Evaluator Contract
┌────────────────────────┴────────────────────────────────────┐
│ Layer 3 — Runtime Evaluator（該專案的實際驗證能力）           │
│   Mode A  scripts/evaluators/*.sh  ← 形式化、可重現           │
│   Mode B  agent-native tools       ← MCP / shell / subagent  │
│   Promotion path：B 常用 → 提煉成 A                          │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Core Principles

| 原則 | 說明 |
|---|---|
| **Thin Harness, Fat Skills** | Layer 1 保持薄，專案特化推到 Layer 2 |
| **Feedforward vs Feedback** | skills/steering 是 feedforward；hooks/evaluators/tests 是 feedback |
| **Latent vs Deterministic** | 需模型判斷走 Mode B；規則固定走 Mode A |
| **Mode A/B Coexistence** | 不強迫專案先有形式化 evaluator；agent 能邊做邊補 |
| **Discovery Contract** | core skill 讀 Layer 2 時走統一的路徑優先級 |

### 1.3 Evaluator Mode A / Mode B

| 面向 | Mode A（形式化）| Mode B（探索性）|
|---|---|---|
| 形式 | `scripts/evaluators/*.sh` 等確定性腳本 | agent 用 shell / MCP（Playwright、瀏覽器）/ subagent |
| 輸入輸出 | 固定 | 自由 |
| 適用 | 重複性、規則清晰的驗證 | 沒 spec / 需人類式推理 |
| 可重現 | ✅ | ❌（同 prompt 可能不同結果）|
| 速度 | 快 | 慢 |

**Promotion Path（flywheel）**：Mode B 驗證連續命中某 pattern → `capturing-knowhow` 擷取 → 提煉成 Mode A script → 之後直接 Mode A 跑。

---

## 2. Target File Map

### 2.1 新增 Core Skills（Layer 1）

| 路徑 | 角色 | 來源 |
|---|---|---|
| `skills/harness-engineering/SKILL.md` | **Canonical** Harness 框架、Wiring Matrix、5-Dim Audit | 搬自 `.kiro/skills/harness-engineering/` 並泛化 |
| `skills/sdd-workflow/SKILL.md` | SDD（requirement → design → tasks）workflow 總覽 | 源自 `.kiro/steering/sdd-bdd-tdd-workflow.md` |
| `skills/sdd-scan/SKILL.md` | spec 一致性 / placeholder / ambiguity scan | 搬自 `.kiro/skills/sdd-scan/` |
| `skills/capturing-knowhow/SKILL.md` | KnowHow 擷取與 feedback flywheel | 源自 `.kiro/steering/knowhow-sync-rules.md` |
| `skills/bootstrapping-harness/SKILL.md` + `templates/` | 新專案初始化 Layer 2 骨架 | 新增（Kiro 原無） |

### 2.2 修改既有 Upstream Skills

| 路徑 | 改動 |
|---|---|
| `skills/writing-plans/SKILL.md` | 加入 Correctness Properties (CP-xx)、Wiring Matrix reference |
| `skills/subagent-driven-development/spec-reviewer-prompt.md` | 加入 SDD compliance 檢查項 |
| `skills/verification-before-completion/SKILL.md` | 加入 5-Dim Audit reference（canonical 在 `harness-engineering`）|

> **遵守原則**：不壓行數、不犧牲語意完整性。Canonical 內容放 `harness-engineering`，其他 skill 用 reference + 簡短 inline summary。

### 2.3 新增 Commands

| 路徑 | 功能 |
|---|---|
| `commands/capture-knowhow.md` | 觸發 `capturing-knowhow` skill |
| `commands/scan-spec.md` | 觸發 `sdd-scan` skill |

命名遵循 upstream 的 **verb-noun** 格式（對齊 `brainstorm` / `write-plan` / `execute-plan`）。

### 2.4 新增 Hooks

| 路徑 | 事件 | 功能 |
|---|---|---|
| `hooks/spec-sdd-check` | `PostToolUse: Edit\|Write\|MultiEdit` | 編輯 spec 檔案時 reminder 跑 sdd-scan |
| `hooks/capture-knowhow-reminder` | `Stop` | session 結束 reminder 擷取 KnowHow |

`hooks/hooks.json`（Claude Code）與 `hooks/hooks-cursor.json`（Cursor）各加一份 mapping；使用 upstream 的 `run-hook.cmd` polyglot wrapper。

### 2.5 新增文件

| 路徑 | 內容 |
|---|---|
| `docs/harness-extension-guide.md` | Layer 1/2/3 架構、Mode A/B 指南、output 語言 convention |
| `docs/superpowers/specs/2026-04-22-kiro-superpowers-integration-design.md` | 本文件 |
| `scripts/verify-adapters.sh` | `.kiro/` adapter 與 canonical skill 的一致性檢查 |

### 2.6 `.kiro/` 轉 Adapter

| 路徑 | 處理 |
|---|---|
| `.kiro/skills/harness-engineering/SKILL.md` | 既有 → 轉 adapter（指向 canonical） |
| `.kiro/skills/sdd-scan/SKILL.md` | 既有 → 轉 adapter |
| `.kiro/skills/subagent-driven-development/SKILL.md` | 既有 → 轉 adapter |
| `.kiro/skills/brainstorming/SKILL.md` | 既有（Kiro 特化版本）→ 轉 adapter 指向 upstream |
| `.kiro/skills/systematic-debugging/SKILL.md` | 既有（Kiro 特化版本）→ 轉 adapter 指向 upstream |
| `.kiro/skills/kiro-framework-audit/SKILL.md` | **保留**（Kiro-only，不遷移）|
| `.kiro/skills/git-worktree/SKILL.md` | **保留**（Kiro-only；upstream 分為 `using-git-worktrees` + `finishing-a-development-branch` 兩個 skill，此為 Kiro 端 composite，視為 Kiro-specific helper） |
| `.kiro/skills/skill-creator/SKILL.md` | **保留**（Kiro-only；upstream 無對應 skill；`.cursor/skills-cursor/` 的 skill-creator 為 Cursor 側工具，兩者各自獨立） |
| `.kiro/steering/sdd-bdd-tdd-workflow.md` | 改為 pointer + Kiro inclusion rule |
| `.kiro/steering/knowhow-sync-rules.md` | 改為 pointer |
| `.kiro/steering/language.md`（新增） | per-workspace output 語言 override |
| `.kiro/hooks/spec-sdd-check.kiro.hook` | 改指向 canonical `skills/sdd-scan` |
| `.kiro/hooks/knowhow-sync.kiro.hook` | 改指向 canonical `skills/capturing-knowhow` |
| `.kiro/hooks/pre-commit-check.kiro.hook` | 保持 disabled |
| `.kiro/UsageReadme_kiro.md` | 更新為「Layer 2 入口 + canonical 對照表」 |

---

## 3. Per-Skill Content Strategy

### 3.1 Canonical Skills（新增）

#### 3.1.1 `skills/harness-engineering/SKILL.md`
- **定位**：canonical 的 Harness 框架 meta-skill，其他 skill 會 reference。
- **內容**：Agent = Model + Harness、Feedforward/Feedback、Latent/Deterministic、Thin Harness + Flywheel、Wiring Integrity、**Wiring Matrix template**、**5-Dim Audit**（context budget / wiring / feedforward-feedback balance / latent-deterministic split / flywheel readiness）、remediation priorities。
- **差異 vs `.kiro/` 原版**：去除 Kiro-specific 詞彙、改用跨 IDE 中性語；保留 templates。

#### 3.1.2 `skills/sdd-workflow/SKILL.md`
- **定位**：thin overview，指向 `writing-plans` 處理 plans、指向 `harness-engineering` 處理 CP / Wiring。
- **內容**：3-stage（requirement / design / tasks）概覽、BDD scenarios 入口、TDD Iron Law（Red-Green-Refactor）、checkpoint 5-Dim audit 掛鉤點。
- **不重複**：詳細內容散到 `writing-plans`（plans） + `subagent-driven-development/spec-reviewer-prompt`（spec check） + `verification-before-completion`（audit）。

#### 3.1.3 `skills/sdd-scan/SKILL.md`
- **定位**：spec 品質 scanner。
- **內容**：placeholder detection（`TODO` / `TBD` / 空章節）、ambiguity markers（`maybe` / `probably` / `大概`）、inter-section consistency（CP 與 Wiring Matrix 對齊）、scope drift（design 出現 requirement 沒有的項目）。
- **輸出**：掃描報告 Markdown 表格。

#### 3.1.4 `skills/capturing-knowhow/SKILL.md`
- **定位**：feedback flywheel 入口。
- **內容**：session 結束時觸發（skill description trigger 為主、hook 輔助）、讀 Discovery Contract 找 `docs/superpowers/knowhow-map.md`、append 新 entry（Title / Context / Pattern / Related Skill）、不改動既有 entry。
- **語言**：讀 `docs/superpowers/README.md` 的 convention；讀不到跟對話語言。

#### 3.1.5 `skills/bootstrapping-harness/SKILL.md` + templates
- **定位**：新專案初始化 Layer 2 骨架。
- **內容**：互動式問答產出 `docs/superpowers/{README.md, specs/, plans/, knowhow/, knowhow-map.md, wiring-matrix.md}` 與 `scripts/evaluators/` 占位、詢問 output 文件語言並寫進 convention。
- **Templates**：`templates/knowhow-map.md`, `templates/wiring-matrix.md`, `templates/README.md`。

### 3.2 修改 Upstream Skills

| Skill | 加入內容 | Canonical 歸屬 |
|---|---|---|
| `writing-plans/SKILL.md` | CP-xx、Wiring Matrix reference | Wiring Matrix canonical 在 `harness-engineering` |
| `subagent-driven-development/spec-reviewer-prompt.md` | SDD compliance 檢查（placeholder / consistency / scope） | 掃描邏輯 canonical 在 `sdd-scan` |
| `verification-before-completion/SKILL.md` | 5-Dim Audit 掛鉤點 + reference | 5-Dim Audit canonical 在 `harness-engineering` |

### 3.3 `.kiro/` Adapter 規格

每個 adapter skill 有統一結構：

```markdown
---
inclusion: fileMatch|manual|always  # Kiro-specific front-matter
fileMatchPattern: "…"                # 如 fileMatch
description: <canonical description 同步>
---

# <Skill Name> (Kiro Adapter)

> **Canonical**: `skills/<name>/SKILL.md`（此檔為 Kiro-side discovery adapter）

## Quick Reference（讀 canonical 前的最小必要摘要）

- 觸發時機：…
- 主要產出：…
- 關鍵步驟 3~5 點：…

## Full Content

See canonical → `skills/<name>/SKILL.md`
```

**一致性保證**：`scripts/verify-adapters.sh` 檢查 adapter 的 `description` 與 canonical `SKILL.md` front-matter 中的 `description` 一致，且 canonical pointer 路徑存在。

---

## 4. Cross-IDE Mechanisms

### 4.1 IDE Capability Matrix

| IDE | plugin manifest | skill discovery | commands | hooks | steering |
|---|---|---|---|---|---|
| Claude Code | `.claude-plugin/plugin.json` | `skills/` via description | `commands/*.md` | `hooks/hooks.json` | `CLAUDE.md` |
| Cursor | `.cursor-plugin/plugin.json` | `skills/` via description | `commands/*.md` | `hooks/hooks-cursor.json` | `AGENTS.md` / `.cursor/rules/` |
| Kiro | （無 manifest；用 `.kiro/`）| `.kiro/skills/*/SKILL.md` via inclusion | （Kiro 端無 slash command）| `.kiro/hooks/*.kiro.hook` | `.kiro/steering/` |
| Codex | `.codex/INSTALL.md` + symlinks | `skills/` via description | 透過 symlink | — | `AGENTS.md` |
| OpenCode | `docs/README.opencode.md` | `skills/` via description | — | — | `AGENTS.md` |
| Gemini CLI | （repo 目前無專屬 doc；走通用 `AGENTS.md` + skill discovery）| `skills/` via description（待 Phase 6 驗證） | — | — | `AGENTS.md` |

### 4.2 Discovery Contract（Layer 2 路徑解析優先級）

Core skill 讀取 Layer 2 檔案時，依序嘗試：

```
1. ${WORKSPACE_ROOT}/docs/superpowers/<filename>     # 預設 convention
2. ${WORKSPACE_ROOT}/.kiro/<filename>                # Kiro convention 回退
3. ${WORKSPACE_ROOT}/<filename>                      # repo root 回退
```

適用檔案：`knowhow-map.md`、`wiring-matrix.md`、`specs/*.md`、`plans/*.md`、`scripts/evaluators/*`。

### 4.3 Hook Mapping & Degradation

| Kiro 事件 | Claude Code | Cursor | 回退 |
|---|---|---|---|
| `fileEdited`（spec-sdd-check）| `PostToolUse: Edit\|Write\|MultiEdit` | `onAfterFileChange` | agent 自己 discover |
| `agentStop`（knowhow-sync）| `Stop` | `onStop` | skill description trigger |

**原則**：hook 是**輔助 feedback**，不是唯一觸發路徑；hook 不支援時靠 skill description 觸發，不會 block 使用者。

**`hooks.json` 新增片段（示意）**：

```json
{
  "hooks": {
    "PostToolUse": [
      { "matcher": "Edit|Write|MultiEdit",
        "hooks": [ { "type": "command",
          "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" spec-sdd-check",
          "async": false } ] }
    ],
    "Stop": [
      { "hooks": [ { "type": "command",
          "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" capture-knowhow-reminder",
          "async": true } ] }
    ]
  }
}
```

### 4.4 Command Registration

兩個新 command 走 **verb-noun** 格式：`/capture-knowhow`、`/scan-spec`（對齊 upstream `/brainstorm`、`/write-plan`、`/execute-plan`）。

### 4.5 Language Convention

| 面向 | 語言 | 控制點 |
|---|---|---|
| Core skill 內容（repo 內）| 英文 | Layer 1 固定 |
| Agent 對使用者回應 | 由 user/workspace steering 決定（預設繁中）| `CLAUDE.md` / `AGENTS.md` / `.kiro/steering/language.md` |
| `specs/*.md`、`plans/*.md`、`wiring-matrix.md` | 跟隨對話語言 | steering layer |
| `knowhow/*.md`、`knowhow-map.md` | **專案統一語言** | `docs/superpowers/README.md` convention（`bootstrapping-harness` 初始化時問） |
| `scripts/evaluators/*` | 英文（runtime 腳本）| 慣例 |

### 4.6 Plugin Manifests

既有 `.claude-plugin/plugin.json`、`.cursor-plugin/plugin.json` 不需調整（skills 走 directory discovery）。OpenCode / Gemini CLI 在 Migration Phase 6 實地驗證。

---

## 5. Migration Phases & Validation

### 5.1 依賴圖

```
P0 Preparation
  └→ P1 New canonical skills
       └→ P2 Modify upstream skills
            └→ P3 Commands + Hooks
                 └→ P4 Docs
                      └→ P5 .kiro/ adapter conversion
                           └→ P6 Cross-IDE smoke test
                                └→ P7 E2E flywheel demo
```

### 5.2 Phases

- **P0 — Preparation**：worktree branch；`scripts/verify-adapters.sh` skeleton；commit design doc。**驗收**：腳本 exit 0。
- **P1 — New core skills**：新增 5 個 canonical skill（順序：harness-engineering → sdd-workflow → sdd-scan → capturing-knowhow → bootstrapping-harness + templates），每個獨立 commit。**驗收**：IDE discovery 可 trigger；broken link 掃描通過。
- **P2 — Modify upstream skills**：依次修 `writing-plans` / `subagent-driven-development/spec-reviewer-prompt` / `verification-before-completion`。**Risk**：最高。**驗收**：小任務跑完 brainstorming → writing-plans → subagent-driven-development → verification-before-completion，無 regression。
- **P3 — Commands + Hooks**：新增 `commands/capture-knowhow.md`、`commands/scan-spec.md`；`hooks/spec-sdd-check`、`hooks/capture-knowhow-reminder`；修 `hooks/hooks.json`、`hooks/hooks-cursor.json`。**驗收**：hook 實際觸發不 block。
- **P4 — Docs**：`docs/harness-extension-guide.md`；更新 repo `README.md` Features。**驗收**：onboarding 可讀。
- **P5 — `.kiro/` adapter conversion**：5 個 adapter skill（harness-engineering / sdd-scan / subagent-driven-development / brainstorming / systematic-debugging）、2 個 steering 精簡（sdd-bdd-tdd-workflow / knowhow-sync-rules）+ 新增 language.md、2 個 hook 改指向 canonical（spec-sdd-check / knowhow-sync；pre-commit-check 維持 disabled）、UsageReadme 更新；git-worktree、skill-creator、kiro-framework-audit 保持 Kiro-only 不動。**驗收**：`verify-adapters.sh` exit 0；Kiro inclusion modes 仍觸發。
- **P6 — Cross-IDE smoke test**：Claude/Cursor/Kiro（一等公民，skill + hook + command 全驗）；Codex/OpenCode/Gemini CLI（minimum skill discovery 即可）。**驗收**：每個 IDE 至少 discover 5 個新 core skill。
- **P7 — E2E flywheel demo**：toy task（例：為 `/write-plan` 加 `--dry-run`）跑完整 loop（brainstorming → scan-spec → write-plan → subagent-driven-development → verification-before-completion → capture-knowhow）。**驗收**：每步驟對應 skill 有被 invoke；`knowhow-map.md` 被 append。

### 5.3 Risk Table

| Risk | 機率 | 對策 |
|---|---|---|
| P2 改 upstream 破壞現有工作流 | 中 | commit 獨立、before/after 對照、易 revert |
| P5 adapter 描述飄移 | 中 | `verify-adapters.sh` 在每個 adapter commit 前跑 |
| P6 非一等公民 IDE 不支援 hook | 低 | document 支援矩陣；不 block |
| 輸出語言分裂 | 中 | `bootstrapping-harness` 初始化問 + steering override |
| Kiro 使用者混淆 adapter + canonical | 中 | adapter 必須 inline quick-reference，不只 pointer |

### 5.4 Success Criteria

1. 5 個 core skill + 2 個 command + 2 個 hook 在 Claude Code / Cursor 都能被 trigger。
2. `scripts/verify-adapters.sh` exit 0。
3. Zero regression：既有 upstream workflow 不 break。
4. Kiro 端 `.kiro/hooks`、`.kiro/skills`、`.kiro/steering` 原觸發行為保留。
5. 新 project 能靠 `bootstrapping-harness` 一鍵產出 Layer 2 骨架。
6. P7 E2E flywheel 跑成功一次。

---

## Appendix A — References

- `CLAUDE.md` / `AGENTS.md` — 當前 repo 對 AI agent 的指引
- `.kiro/UsageReadme_kiro.md` — Kiro 實作文件
- `.kiro/steering/sdd-bdd-tdd-workflow.md` — SDD-BDD-TDD 原版
- `.kiro/skills/harness-engineering/SKILL.md` — Harness canonical 原版
- `skills/using-superpowers/SKILL.md` — Superpowers 元技能
- `skills/writing-plans/SKILL.md`、`skills/brainstorming/SKILL.md`、`skills/subagent-driven-development/SKILL.md`、`skills/verification-before-completion/SKILL.md`、`skills/systematic-debugging/SKILL.md` — 受影響的 upstream skills

## Appendix B — Open Questions（留給 implementation plan 階段）

1. P7 toy task 細節（哪個 flag、最小 spec 怎麼寫）→ implementation plan 階段決定。
2. `bootstrapping-harness` 互動式問答的具體 prompt wording → implementation plan 階段決定。
3. `verify-adapters.sh` 除了 description/pointer 一致性外，是否還要檢查 Quick Reference 是否偏離 canonical → implementation plan 階段決定（初版只檢查 description + pointer）。
4. `.kiro/skills/git-worktree/` composite 是否值得將「Kiro 端合併 superpower/using-git-worktrees + finishing-a-development-branch」的做法反饋到 upstream（變成一個新 canonical composite skill）→ 非本次整合範圍，留待後續評估。
5. Gemini CLI 的 skill discovery 行為是否穩定、是否需要補寫 `docs/README.gemini.md` → Phase 6 smoke test 後依結果決定。
