# Kiro 專案初始化模組

此專案提供一套可複用的 AI 協作模組（steering、hooks、skills），讓你快速為新專案建立 Kiro agent 的協作規範。

## 模組清單

### Steering（自動載入的規則）

| 檔案 | 載入方式 | 用途 |
|------|----------|------|
| `steering/language.md` | always | 指定 agent 回覆語言（預設：繁體中文） |
| `steering/environment.md` | always | 本機開發環境設定（Python 版本、OS、依賴）— 匯入後必須重寫 |
| `steering/documentation-rules.md` | always | Commit 時自動更新 CHANGELOG 和 DEV_NOTES 的規則 |
| `steering/knowhow-sync-rules.md` | always | 開發中發現的知識點自動同步到 KnowHow / Skill / Steering |
| `steering/skill-routing.md` | always | Skill 路由表 — 根據使用者意圖導向正確的 skill，含優先級和紀律分類 |
| `steering/sdd-bdd-tdd-workflow.md` | fileMatch | SDD→BDD→TDD 三階段開發流程（讀到測試檔或 spec 文件時載入） |

### Hooks（自動觸發的動作）

| 檔案 | 觸發時機 | 用途 |
|------|----------|------|
| `hooks/pre-commit-check.kiro.hook` | `preToolUse`（shell） | git commit 前提醒更新 CHANGELOG 和 DEV_NOTES |
| `hooks/knowhow-sync.kiro.hook` | `agentStop` | agent 執行完畢後，自動檢查是否有新知識點需同步 |
| `hooks/spec-sdd-check.kiro.hook` | `fileEdited`（spec md） | 編輯 spec 文件時，提醒檢查 SDD 合規（CP-xx、介面契約、Wiring Matrix） |

### Skills（領域知識與工作流程）

| 檔案 | 用途 |
|------|------|
| `skills/brainstorming/` | 對話式需求探索與設計 — 一次一個問題釐清需求，分段呈現設計，含 Visual Companion 視覺化工具 |
| `skills/systematic-debugging/` | 系統化除錯 — 4 階段根因分析（Reproduce → Isolate → Understand → Fix），含平行派遣、Defense in Depth |
| `skills/subagent-driven-development/` | 子代理驅動開發 — 每個 task 派遣新 sub-agent，搭配 two-stage review（SDD 合規 → 品質），含 3 個 prompt 模板 + code review 紀律 |
| `skills/git-worktree/` | Git Worktree 隔離開發（可選）— worktree 建立、安全驗證、baseline 測試、分支完成（merge/PR/discard）的完整生命週期。不使用 worktree 工作流時可刪除此 skill |
| `skills/harness-engineering/` | Harness Engineering 審計框架 — 審計、診斷、改善 AI agent 的駕馭架構 |
| `skills/sdd-scan/` | SDD 合規掃描 — run all tasks 前掃描 spec 是否符合 SDD 規則 |
| `skills/kiro-framework-audit/` | Kiro 框架健康度審計 — 掃描 steering/hooks/skills 的品質、context budget、機制分界 |

> `skills/skill-creator/` 是 Kiro 內建的技能建立工具，不屬於本模組的可複用範圍。

## 使用方式

1. 將本專案中 `UsageReadme.md` **以外**的檔案複製到目標專案的 `.kiro/` 目錄下
2. 依照下方「匯入後需客製化的項目」逐一調整
3. 使用「匯入後 Agent Prompt」請 agent 協助你完成客製化

## 匯入後需客製化的項目

### `steering/language.md`

- 若目標專案不使用繁體中文，修改或移除此檔案

### `steering/environment.md`

> ⚠️ **必須重寫**：此檔案的內容為範例，匯入後需替換為目標專案的實際環境。

| 項目 | 說明 |
|------|------|
| Python 版本 | 替換為目標專案使用的 Python 版本與指令（或其他語言的 runtime） |
| 作業系統 | 替換為目標專案的開發環境 OS 和 shell |
| 專案依賴 | 替換為目標專案的核心依賴和版本 |

### `steering/documentation-rules.md`

| 項目 | 說明 |
|------|------|
| 文件更新觸發條件 | 「先更新文件」括號內的觸發情境（如：比對口徑、欄位映射…）應改為目標專案的核心關注點 |
| 文件路徑 | `docs/DEV_NOTES.md`、`docs/CHANGELOG.md` 等路徑需確認是否符合目標專案結構 |
| CHANGELOG 格式 | 每則格式可依團隊習慣微調 |
| DEV_NOTES 段落名稱 | 「架構決策與取捨」「已知陷阱與 Workaround」等段落名稱可依專案性質調整 |
| 拆分閾值 | 目前設定 80 行觸發拆分提議，可依專案規模調整 |

### `steering/knowhow-sync-rules.md`

| 項目 | 說明 |
|------|------|
| KnowHow 分類映射表 | **必須重寫**。目前的映射表是針對魚機遊戲專案設計的（Canvas、Go Server、像素圖、出魚腳本等），需替換為目標專案的知識領域 |
| KnowHow 文件名稱 | `魚機製作KnowHow.md`、`遊戲演出KnowHow.md` 需改為目標專案的分類名稱 |
| 相關 Skill / Steering 欄位 | 映射表中的 Skill 名稱（如 `pixel-art-generator`、`go-server`）需改為目標專案實際使用的 Skill |

### `steering/skill-routing.md`

- 路由表中的 skill 清單應與實際安裝的 skills 一致
- 若新增或移除了 skill，需同步更新路由表
- 優先級規則和紀律分類（Rigid/Flexible）通常不需調整

### `steering/sdd-bdd-tdd-workflow.md`

> ⚠️ **不可降低標準**：客製化時只應替換語言和範例，不應刪除流程結構。即使目標專案現有的 tasks.md 沒有 BDD 場景、Red→Green→Refactor 子任務、接線任務或 Checkpoint 審計，也應該**補上這些結構**而非移除規則。這些是 SDD→BDD→TDD 流程的核心精神，缺少任何一環都會導致 agent 產出品質下降。

| 項目 | 說明 |
|------|------|
| fileMatch 模式 | 目前匹配 `*_test.go`、`*.test.js`、`*.spec.js` 和 spec md，若專案使用其他測試命名慣例需調整 |
| Go 測試規則 | 若專案不使用 Go，**替換**為對應語言的測試規則（不是移除） |
| JS 測試規則 | 若專案不使用 JS，**替換**為對應語言的測試規則（不是移除） |
| 領域特定範例 | Wiring Matrix 模板中的遊戲範例（GameLoop、physics、spawner）需替換為目標專案的實際模組 |
| Task 子任務結構 | BDD 場景 → Red → Green → Refactor → PBT 的結構**必須保留**，只替換語言特定的命名慣例 |
| 接線任務 | 新增 exported function 後的接線任務**必須保留**，這是防止「零件做好沒接上」的關鍵機制 |
| Checkpoint 審計 | 五維度審計指令**必須保留**，可依專案調整具體的測試指令（如 `go test` → `pytest`） |

### `hooks/knowhow-sync.kiro.hook`

| 項目 | 說明 |
|------|------|
| KnowHow 文件路徑 | prompt 中的 `.kiro/skills/docs/魚機製作KnowHow.md` 和 `遊戲演出KnowHow.md` 需改為目標專案的實際路徑 |

### `hooks/pre-commit-check.kiro.hook`

- 確認 hook 的觸發條件與指令是否適用於目標專案的開發流程
- 若文件路徑有調整（如 `docs/CHANGELOG.md`），prompt 中的路徑也需同步修改

### `hooks/spec-sdd-check.kiro.hook`

- 此 hook 通常不需要客製化，它會在編輯 spec 文件時自動提醒 SDD 合規
- 若不採用 SDD 流程，可將 `enabled` 設為 `false`

### `skills/harness-engineering/`

| 項目 | 說明 |
|------|------|
| Latent vs Deterministic 範例 | SKILL.md 中的「領域特定範例」段落包含遊戲和 Web API 兩組，可依專案性質增減 |
| Wiring Matrix 模板範例 | 遊戲 Server 的 Game Loop 範例需替換為目標專案的實際架構 |

### `skills/brainstorming/`

| 項目 | 說明 |
|------|------|
| Visual Companion | 需要 Node.js 環境。若目標專案不需要視覺化 brainstorming，可忽略 `scripts/` 目錄和 `visual-companion.md` |
| 與 Kiro Spec 的銜接 | 流程假設使用 Kiro 原生 Spec（Requirements → Design → Tasks），若專案用其他規格管理方式需調整「與 Kiro Spec 的整合」段落 |

### `skills/systematic-debugging/`

- 此 skill 為通用除錯流程，通常不需要客製化
- Phase 4（Fix）整合了 `sdd-bdd-tdd-workflow.md` 的 TDD 流程，若調整了 TDD 規則需確認一致性
- 「KnowHow 同步提醒」段落引用了 `knowhow-sync-rules.md` 的映射表，若映射表已重寫則此段落自動適用

### `skills/subagent-driven-development/`

| 項目 | 說明 |
|------|------|
| Prompt 模板語言 | 3 個 prompt 模板（implementer、spec-reviewer、code-quality-reviewer）目前為中文，可依團隊偏好調整 |
| SDD 標準 | spec-reviewer-prompt.md 中的 SDD 檢查項（CP-xx、Wiring Matrix、BDD、TDD）與 `sdd-bdd-tdd-workflow.md` 綁定，兩者必須一致 |
| `invokeSubAgent` 工具 | 模板使用 Kiro 的 `invokeSubAgent`（name: `general-task-execution`），若平台不支援 sub-agent 需改為手動執行 |

### `skills/git-worktree/`（可選）

> 若專案不使用 worktree 工作流，可直接刪除此 skill 目錄，並移除 `subagent-driven-development/SKILL.md` 中準備步驟和框架關係裡的 worktree 建議。其他 skill 和 steering 不受影響。

| 項目 | 說明 |
|------|------|
| 目錄偏好 | 預設優先使用 `.worktrees/`，可依團隊慣例調整 |
| 分支完成選項 | PR 建立使用 `gh pr create`（GitHub CLI），若使用 GitLab 或其他平台需替換對應指令 |
| 依賴安裝 | 自動偵測 Node.js/Go/Python/Rust，若專案使用其他語言需補充對應的安裝指令 |

### `skills/kiro-framework-audit/`

| 項目 | 說明 |
|------|------|
| Context budget 閾值 | 預設 always ≤80 行、≤6 檔，可依團隊共識調整 |
| toolTypes 有效 category | 若有自訂 MCP 工具，可在 hook 設計健康度段落補充有效的 tool name pattern |
| 機制分界表 | Steering vs Hook vs Skill vs MCP vs Powers 的分界原則為通用規則，通常不需調整 |

### `skills/sdd-scan/`

> ⚠️ **不可降低標準**：sdd-scan 的掃描項目對應 `sdd-bdd-tdd-workflow.md` 的完整規則。若目標專案現有的 spec 文件不符合掃描標準，正確做法是**修正 spec 文件使其合規**，而非放寬掃描條件。

- 此 skill 依據 `sdd-bdd-tdd-workflow.md` 的規則進行掃描，兩者必須保持一致
- 若調整了 workflow 中的語言特定規則（如測試命名慣例），需同步調整掃描項目中的對應描述
- 以下掃描項目**不可移除**：CP-xx 正確性屬性、precondition/postcondition、Wiring Matrix、BDD+TDD 子任務結構、接線任務、Checkpoint 審計

## Agent Prompts

### 檢視本專案時使用

```
幫我檢視並調整 UsageReadme.md 的內容
```

### 匯入目標專案後使用

```
請根據此專案的技術棧與開發流程，檢視 .kiro/ 下的 steering、hooks、skills 設定，
並針對以下面向提出調整建議：
1. steering/language.md 的語言設定是否正確
2. steering/environment.md 的環境設定是否已替換為本專案的實際環境
3. steering/documentation-rules.md 中的文件更新觸發條件是否符合本專案
4. steering/knowhow-sync-rules.md 的映射表需要改為哪些知識領域
5. steering/sdd-bdd-tdd-workflow.md 的測試規則和範例是否適用
6. 文件路徑（docs/DEV_NOTES.md 等）是否需要調整
7. hooks 的觸發條件與 prompt 內容是否適用
8. skills 中的領域特定範例是否需要替換
9. kiro-framework-audit 的 context budget 閾值和機制分界是否需要調整
10. 是否需要新增專案特有的 steering 規則
```

### 建立 KnowHow 自動同步機制

> 用於告訴 agent「以後每次修正都要自動記錄知識點」，搭配 `knowhow-sync-rules.md` 和 `knowhow-sync.kiro.hook` 使用。

```
在開發過程中，我們不會想要每次都還要一個一個對檔案做修改。
請將過程的這些知識記錄下來，未來每次修正都需要將 KnowHow 記錄下來並且修改相關的規格文件與 Skill。
```
