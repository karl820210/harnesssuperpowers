---
name: harness-engineering
description: Harness Engineering 框架 — 審計、診斷、改善 AI agent 的駕馭架構。涵蓋 Feedforward（Skills/Steering 事前引導）、Feedback（Hooks/Tests 事後偵測）、接線完整性（Wiring Matrix）、Latent vs Deterministic 分界、Feedback Flywheel 知識回饋迴圈。當需要審計 harness 覆蓋率、診斷模組接線遺漏、改善 agent 工作品質、建立新的 guide 或 sensor、或討論 harness engineering 架構時使用。
---

# Harness Engineering 框架

本技能整合 Martin Fowler、Garry Tan（YC）、Flywheel 框架、Static→Dynamic Decomposition 四篇核心文獻的概念，落地為可操作的審計與改善流程。

## 核心概念

### Agent = Model + Harness

Harness 是包裹 LLM 模型的一切 — 不是讓模型更聰明，而是在對的時間把對的上下文送給模型。

在 Kiro 中，Harness 由五個元件組成：

| 元件 | Kiro 落地 | 角色 | 抽象層次 |
|------|----------|------|---------|
| Skills | `.kiro/skills/*/SKILL.md` | Fat Skills — 領域知識與工作流程（Feedforward Guide, Inferential） | 專案特定（領域知識） |
| Steering | `.kiro/steering/*.md` | 行為規則與慣例（Feedforward Guide, Inferential） | 專案特定（慣例規則） |
| Hooks | `.kiro/hooks/*.kiro.hook` | 自動觸發檢查（Feedback Sensor, Computational/Inferential） | 通用可移植（偵測模式） |
| Specs | `.kiro/specs/*/` | 結構化開發流程（Feedforward Guide, Computational） | 專案特定（功能規格） |
| KnowHow + 自檢清單 | `.kiro/skills/docs/` | 經驗累積與回饋迴圈（Feedback Flywheel） | 專案特定（歷史教訓） |

注意：Hook 應該是通用的偵測規則，不綁定專案特定的類別名稱或歷史編號。專案特定的檢查項放在 Steering 或自檢清單裡。

### Feedforward vs Feedback（Martin Fowler）

- Feedforward（事前引導）：在 agent 行動前預防錯誤。Skills、Steering、Spec 模板。
- Feedback（事後偵測）：在 agent 行動後偵測並自我修正。Hooks、Tests、KnowHow Sync。
- 只有 Feedforward → agent 編碼了規則但不知道是否有效
- 只有 Feedback → agent 不斷重複同樣的錯誤

兩者必須同時存在。

### Computational vs Inferential

- Computational（確定性）：Tests、Linters、Type Checkers。快速、可靠、每次變更都跑。
- Inferential（推理性）：AI Code Review、LLM as Judge。較慢、較貴、非確定性。

### Latent vs Deterministic（Garry Tan）

系統中的每一步不是 Latent 就是 Deterministic：
- Latent = 需要模型判斷的（設計決策、程式碼審查、架構選擇）
- Deterministic = 同樣輸入同樣輸出的（測試、編譯、碰撞判定、SQL 查詢）

搞混這兩者是 agent 設計中最常見的錯誤。把確定性問題硬塞進潛在空間 = 看起來合理但完全錯誤的結果。

### Thin Harness, Fat Skills（Garry Tan）

- 把智力往上推進 Skills（Latent 層）
- 把執行往下推進確定性工具（Deterministic 層）
- 保持 Harness 精簡 — 只做四件事：執行模型、讀寫檔案、管理上下文、強制安全規則

反面模式：Fat Harness with Thin Skills — 40 個工具定義吃掉一半 context window。

### Resolver = Context Router

Resolver 是上下文的路由表 — 當任務類型 X 出現時，載入文件 Y。

在 Kiro 中，Resolver 由三個機制實現：
1. Skill description 欄位 — 模型自動配對使用者意圖
2. Steering fileMatch — 讀到特定檔案時自動載入規則
3. Hook event patterns — 特定事件觸發時自動提醒

### Static Scaffolding → Dynamic Decomposition（文章二）

三層架構：
- Layer 1 (Static/T1)：Agent 內建 + 社群 Skills — table stakes
- Layer 2 (Flywheel)：每次修正 = 一個 Signal，修正原因寫回 Skills/Steering
- Layer 3 (Dynamic)：Developer Judgment — On the Loop — 即時判斷是否展開新驗證路徑

Layer 2 就是 KnowHow Sync 機制。Layer 3 無法自動化，是人類 on the loop 的核心價值。

### Feedback Flywheel（Martin Fowler / Kief Morris）

每次修正 agent 的 output，就是一個 signal。這個 signal 必須被捕捉並回饋到開發流程裡。

在 Kiro 中的落地：
- agentStop hook → KnowHow Sync → 更新 Skills/Steering/自檢清單
- 這不是額外的工作，這是讓 Static 層越來越準的機制

### 接線完整性（Wiring Integrity）

模組接線遺漏是 AI agent 開發中反覆出現的問題 — agent 把零件做好了但沒接上。

根因：現有框架覆蓋了「零件怎麼做」但沒有覆蓋「零件怎麼接」。

接線是確定性問題（A 必須呼叫 B），但被放在潛在空間讓 agent 用推理去「猜」。

---

## 審計流程

當需要審計 Harness 覆蓋率時，按以下維度逐一檢查：

### 1. Feedforward 覆蓋率

檢查每個開發領域是否有對應的事前引導：

```
對每個模組/package/目錄：
  □ 是否有對應的 Skill 描述其設計意圖與介面？
  □ 是否有對應的 Steering 描述編碼慣例？
  □ Spec Design 文件是否有介面契約（precondition/postcondition）？
```

### 2. Feedback 覆蓋率

檢查每個變更是否有對應的事後偵測：

```
對每個 exported function/method：
  □ 是否有單元測試？
  □ 是否有 BDD 場景？
  □ 正確性屬性（CP-xx）是否有 PBT 測試？
  □ 是否有呼叫者？（接線完整性）
```

### 3. 接線完整性（Wiring Matrix）

這是最容易遺漏的維度。檢查方法：

```
對每個主迴圈（game loop / request handler / event loop），確認：
  □ Design 文件的 Wiring Matrix 列出了所有應被呼叫的子系統
  □ 實作中每個子系統確實在正確時機被呼叫
  □ 呼叫順序與 Wiring Matrix 一致

對每個新增的 exported function/method：
  □ 是否有至少一個呼叫者？
  □ 呼叫者是否在正確的時機呼叫？（主迴圈中？事件觸發時？）
  □ 呼叫者是否傳入正確的參數？
```

### 4. Latent vs Deterministic 分界

檢查是否有確定性問題被放在潛在空間：

```
通用檢查項：
  □ 資料驗證 — 必須是 Deterministic（schema 驗證、型別檢查）
  □ 模組接線 — 必須是 Deterministic（明確的呼叫關係）
  □ 狀態機轉換 — 必須是 Deterministic（有限狀態、明確條件）
  □ 設計決策 — 應該是 Latent（需要人類判斷）
  □ 程式碼審查 — 應該是 Latent

領域特定範例（遊戲）：
  □ 碰撞判定 — Deterministic
  □ 獎金計算 — Deterministic

領域特定範例（Web API）：
  □ 權限檢查 — Deterministic
  □ 回應格式 — Deterministic
```

### 5. Feedback Flywheel 健康度

```
  □ agentStop hook 是否啟用？（KnowHow Sync）
  □ pre-commit hook 是否啟用？（文件更新）
  □ spec-sdd-check hook 是否啟用？（SDD 合規）
  □ KnowHow 文件是否持續增長？（知識在累積）
  □ 自檢清單是否持續增長？（教訓在轉化為檢查項）
  □ Steering 是否有被 KnowHow 回饋更新？（閉環）
```

---

## 改善流程

當審計發現缺口時，按以下優先級修補：

### 優先級 1：Computational Feedback（成本低、信心高）

- 新增缺失的單元測試
- 新增接線完整性檢查（exported function 必須有呼叫者）
- 新增 Hook 自動跑測試

### 優先級 2：Feedforward Guide（預防重複錯誤）

- 將 KnowHow 教訓轉化為 Steering 規則
- 將反覆出現的模式轉化為 Skill
- 在 Design 文件中補充 Wiring Matrix

### 優先級 3：Inferential Feedback（成本高但覆蓋語義）

- Cross-model review（不同 AI 看同一份 code）
- 語義重複偵測
- 架構漂移偵測

### 優先級 4：Dynamic Layer（無法自動化）

- 識別需要人類 On the Loop 判斷的高風險時刻
- 在這些時刻插入 friction（可介入的節點）
- 低風險流程減少 friction

---

## Wiring Matrix 模板

在 Spec Design 文件中新增此段落，明確列出模組間的呼叫關係：

```markdown
## 接線矩陣（Wiring Matrix）

### 主迴圈呼叫鏈

| 順序 | 呼叫者 | 被呼叫方法 | 參數來源 | 輸出/副作用 |
|------|--------|-----------|---------|------------|
| 1 | {主迴圈} | {子系統}.Update(dt) | {狀態來源} | {廣播訊息/狀態變更} |
| 2 | ... | ... | ... | ... |

### 事件觸發呼叫鏈

| 觸發事件 | 呼叫者 | 被呼叫方法 | 前置條件 |
|---------|--------|-----------|---------|
| {使用者操作/訊息} | {handler} | {處理方法} | {驗證條件} |
| ... | ... | ... | ... |
```

> 範例（遊戲 Server 的 Game Loop）：
>
> | 順序 | 呼叫者 | 被呼叫方法 | 參數來源 | 輸出 |
> |------|--------|-----------|---------|------|
> | 1 | GameLoop | physics.Update(dt) | entities | — |
> | 2 | GameLoop | spawner.Tick(dt, count) | config | spawn 事件 |
> | 3 | GameLoop | network.Sync() | entities | sync 訊息 |

---

## Task 結構模板（含接線任務）

每個零件任務後面必須緊跟一個接線任務：

```markdown
- [ ] N. 實作 {方法名}
  - [ ] N.1 撰寫 BDD 場景
  - [ ] N.2 撰寫失敗測試（Red）
  - [ ] N.3 實作最小程式碼（Green）
  - [ ] N.4 重構（Refactor）

- [ ] N+1. 接線：將 {方法名} 整合到 {呼叫者}
  - [ ] (N+1).1 在 {呼叫者} 中呼叫 {方法名}（依 Wiring Matrix 的時機與參數）
  - [ ] (N+1).2 撰寫整合測試驗證完整呼叫鏈
  - [ ] (N+1).3 確認 Wiring Matrix 與實作一致
```

---

## 與現有框架的關係

```
Harness Engineering（本技能）
├── Feedforward Guides
│   ├── Skills（領域知識）
│   ├── Steering（行為規則）
│   ├── Specs（結構化流程）
│   └── Wiring Matrix（接線契約）← 新增
├── Feedback Sensors
│   ├── Hooks（自動觸發）
│   ├── Tests（單元/整合/PBT）
│   ├── SDD/BDD/TDD workflow
│   └── 接線完整性檢查 ← 新增
├── Feedback Flywheel
│   ├── KnowHow Sync（agentStop hook）
│   ├── 自檢清單（可重複檢查項）
│   └── Steering 回饋更新
└── Dynamic Layer（人類 On the Loop）
    ├── Planning 品質判斷
    ├── Cross-context 驗證（spawn sub-agent）
    └── 高風險時刻介入
```

---

## 參考文獻

- Martin Fowler, "Harness engineering for coding agent users" (2026)
- Garry Tan (YC), "Thin Harness, Fat Skills" (2026)
- Kuan-Yu Hsieh, "Flywheel: Long-running Agent framework" (2026)
- Static Scaffolding → Dynamic Decomposition (2026)
- Kief Morris, "On the Loop" — In/Out/On the Loop 三種互動位置
- Anthropic, "Building Effective Agents" — Workflows vs Agents
