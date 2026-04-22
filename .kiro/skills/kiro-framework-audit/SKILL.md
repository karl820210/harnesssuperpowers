---
name: kiro-framework-audit
description: Kiro Agentic 框架健康度審計。掃描 .kiro/ 目錄下的 steering、hooks、skills 設定，檢查 context budget、inclusion 模式選擇、hook 設計模式、機制分界（Steering vs Hook vs Skill vs MCP vs Powers）是否合理。當需要審計 .kiro 設定品質、檢查 steering 是否臃腫、診斷 hook 設計問題、評估框架健康度時使用。
metadata:
  author: kiro
  version: "1.1"
---

# Kiro Agentic 框架健康度審計

審計 `.kiro/` 目錄下所有設定的品質與一致性，確保 steering、hooks、skills 各司其職、context budget 可控。

## 使用方式

在 chat 中輸入 `#kiro-framework-audit`，自動掃描當前 workspace 的 `.kiro/` 目錄。

## 知識來源

本技能的檢查規則萃取自：
- Yue Ning, "Steering Kiro: Best Practices, Pitfalls, and When to Use Something Else" (2026)
- yuening8080/everything-kiro 專案的結構慣例
- 本專案開發過程中累積的 KnowHow（如 toolTypes regex 限制）

---

## 審計維度

### 1. Steering 健康度

#### 1.1 Context Budget

Always-on steering 消耗每次對話的 context window，必須嚴格控制。

| 指標 | 閾值 | 說明 |
|------|------|------|
| 單檔行數 | ≤80 行 | 超過應拆分或降級為 conditional/manual |
| always 檔案數 | ≤6 個 | 超過應評估哪些可降級 |
| conditional 單檔行數 | ≤120 行 | 只在匹配時載入，可稍寬鬆 |
| manual 單檔行數 | ≤150 行 | 按需載入，最寬鬆 |

掃描步驟：
```
對 .kiro/steering/ 下每個 .md 檔案：
  1. 讀取 front-matter 的 inclusion 模式
  2. 計算正文行數（排除 front-matter）
  3. 與對應閾值比較
  4. 統計 always 檔案總數
```

#### 1.2 Inclusion 模式選擇

每條規則應放在正確的 inclusion 模式中。決策框架：

| 情境 | 應使用 | 判斷依據 |
|------|--------|---------|
| 幾乎每次對話都需要，且簡短 | `always` | 「新人第一天就要知道且永遠記住的」 |
| 重要但不是每次都需要 | `auto` | 「有時相關有時不相關」— 信任 Kiro 判斷 |
| 只在編輯特定檔案時需要 | `conditional` (fileMatch) | 「能用 glob pattern 表達觸發條件」 |
| 結構化工作流程，按需啟動 | `manual` | 「我想讓 Kiro 帶我走一遍 X 流程」 |

常見錯誤模式：
- ❌ 語言特定規則放在 always（應該用 conditional + fileMatch）
- ❌ 長篇工作流程放在 always（應該用 manual）
- ❌ 安全/commit 等不可跳過的規則放在 auto（應該用 always）
- ❌ 所有東西都放 always，沒有使用 conditional 或 manual

`auto` vs `conditional` 的關鍵差異：
- `conditional` 是**確定性的** — 由 glob pattern 決定，你能精確預測何時載入
- `auto` 是**概率性的** — 由 Kiro 讀取檔案內容後自行判斷是否相關
- 能用 glob pattern 表達的觸發條件 → 用 `conditional`
- 觸發條件取決於對話主題而非檔案類型 → 用 `auto`
- 絕對不可跳過的規則 → 不要用 `auto`，用 `always`

掃描步驟：
```
對每個 always steering：
  □ 內容是否「幾乎每次對話都需要」？
  □ 是否有語言/框架特定內容可抽到 conditional？
  □ 是否有多步驟工作流程可抽到 manual？
  □ 是否有「有時相關有時不相關」的內容可降級到 auto？

對每個 conditional steering：
  □ fileMatchPattern 是否正確覆蓋目標檔案？
  □ 是否有遺漏的檔案類型？

對每個 auto steering：
  □ 是否有不可跳過的規則？（應升級到 always）
  □ 是否能用 glob pattern 表達觸發條件？（應改用 conditional）
```

#### 1.3 內容品質

Steering 是寫給 LLM 的，不是寫給人的。

- ✅ 直接陳述規則（「用 parameterized queries」）
- ❌ 解釋概念（「SQL injection 是一種…」）— LLM 已經知道
- ✅ 專案特定的偏好（「用 kebab-case 命名檔案」）
- ❌ 通用最佳實踐（「用有意義的變數名」）— LLM 預設就會
- ✅ 表格/清單格式（快速查找）
- ❌ 長篇散文（浪費 context）

改善提示：Kiro 的 Steering UI 有 **Refine** 按鈕，可自動精簡 steering 內容（移除冗餘、收緊語言、重組結構）。對超標的檔案建議先用 Refine 再手動微調。

掃描步驟：
```
對每個 steering 檔案：
  □ 是否有超過 3 行的概念解釋段落？（應精簡為 1 行規則）
  □ 是否有 LLM 已知的通用規則？（應移除）
  □ 是否使用了表格/清單而非散文？
```

#### 1.4 基礎 Steering 三件套

Kiro 內建 generator 可產生三個基礎 steering 檔案，這是最高價值的 steering — 專案特定的上下文，Kiro 無法自行推斷：

| 檔案 | 用途 |
|------|------|
| `product.md` | 產品目的、目標使用者、核心功能、商業目標 |
| `tech.md` | 技術棧、框架、工具、限制條件 |
| `structure.md` | 檔案組織、命名慣例、import 模式、架構決策 |

掃描步驟：
```
□ product.md 是否存在？（不存在 → 建議用 Kiro panel 的 "Generate Steering Docs" 產生）
□ tech.md 是否存在？
□ structure.md 是否存在？
□ 若存在，內容是否為專案特定（非模板預設值）？
```

注意：這三個檔案應該為每個專案重新產生，不應從模板複製。

### 2. Hook 設計健康度

#### 2.1 toolTypes 正確性

`toolTypes` 匹配的是 **tool category** 或 **tool name**，不是 command 字串內容。

有效的內建 category：
- `read` — 讀取檔案的工具
- `write` — 寫入檔案的工具
- `shell` — 執行 shell 指令的工具
- `web` — 網路相關工具
- `spec` — spec 相關工具
- `*` — 所有工具

Regex 匹配的是 tool name（如 `executePwsh`、`fsWrite`），不是 command 參數。

常見錯誤：
- ❌ `".*git\\s+commit.*"` — 試圖匹配 command 內容，不會觸發
- ❌ `".*\\.ts"` — 試圖匹配檔案路徑，不會觸發
- ✅ `"shell"` — 匹配所有 shell 工具呼叫
- ✅ `"write"` — 匹配所有檔案寫入
- ✅ `".*sql.*"` — 匹配 tool name 含 sql 的 MCP 工具

掃描步驟：
```
對每個 hook 的 toolTypes：
  □ 是否使用了有效的 category 或 tool name regex？
  □ 是否有試圖匹配 command 內容的 regex？（標記為 ❌）
  □ 是否使用了寬泛的 category（如 "shell"）搭配 askAgent？（見 2.6 迴圈陷阱）
```

#### 2.2 Prompt 精簡度

Hook prompt 在每次觸發時都會注入 context，應盡量精簡。

- ✅ 條件判斷 + 動作指令（「如果是 git commit，先確認 X」）
- ❌ 長篇解釋（「commit 是版本控制中…」）
- ✅ 非目標指令的快速跳過（「非 git commit 則直接執行」）

#### 2.3 Action Type 選擇

Hook 的 `then.type` 有兩種：`askAgent`（讓 agent 推理判斷）和 `runCommand`（直接執行指令）。

| 情境 | 應使用 | 原因 |
|------|--------|------|
| 確定性動作（lint、test、build） | `runCommand` | 不需要推理，直接執行更快 |
| 需要推理判斷（安全掃描、code review） | `askAgent` | 需要 LLM 分析內容 |
| 條件性動作（只在特定 command 時觸發） | `askAgent` | 需要 LLM 判斷是否符合條件 |

常見錯誤：
- ❌ 確定性動作用 `askAgent`（如 lint on save）— 浪費 context，直接 `runCommand` 即可
- ❌ 需要推理的檢查用 `runCommand`（如安全掃描）— shell 指令無法做語義分析

掃描步驟：
```
對每個 hook：
  □ action type 是否與動作性質匹配？
  □ askAgent 的 hook 是否真的需要推理？（不需要 → 改用 runCommand）
  □ runCommand 的 hook 是否有需要推理的部分？（有 → 改用 askAgent）
```

#### 2.4 runCommand 防禦性寫法

`runCommand` hook 在工具不存在或指令失敗時可能報錯，應加入防禦性寫法。

最佳實踐：
- ✅ `npx eslint --fix ${file} 2>/dev/null || true` — 失敗時靜默跳過
- ✅ `npm test || npx vitest run || echo 'No test runner found'` — fallback chain
- ❌ `npm test` — 若 npm test 未定義會直接報錯中斷

掃描步驟：
```
對每個 runCommand hook：
  □ 指令是否有錯誤處理（|| true 或 fallback）？
  □ 是否有 stderr 重導向（2>/dev/null）避免噪音？
  □ 若依賴特定工具（eslint、jest 等），是否有 fallback？
```

#### 2.5 Hook vs Steering 分界

| 需求 | 應使用 | 原因 |
|------|--------|------|
| 「每次 commit 前檢查文件」 | Hook (preToolUse) | 自動觸發，不依賴 LLM 記憶 |
| 「commit 訊息用中文」 | Steering (always) | 風格偏好，不需要事件觸發 |
| 「寫檔前掃描 secrets」 | Hook (preToolUse) | 安全檢查必須強制執行 |
| 「偏好 early return 而非巢狀 if」 | Steering (always) | 編碼風格，引導而非強制 |
| 「存檔後跑 lint」 | Hook (fileEdited) | 自動化動作 |
| 「API 回應格式統一」 | Steering (conditional) | 設計規範 |

核心原則：
- **Steering = guidance**（模型應該遵守但可能在長 context 中忘記）
- **Hook = enforcement**（事件觸發，不管 context 狀態都會執行）

掃描步驟：
```
對每個 hook：
  □ 這個檢查是否必須每次都執行？（是 → hook 正確）
  □ 還是只是風格偏好？（是 → 應移到 steering）

對每個 steering 中的「必須/禁止」規則：
  □ 是否有對應的 hook 強制執行？（若無且很重要 → 建議新增 hook）
```

#### 2.6 preToolUse + shell 的迴圈陷阱

`preToolUse` hook 搭配 `toolTypes: ["shell"]` 會攔截**每一次** shell 指令，不只是目標指令。這會導致嚴重的迴圈問題：

問題場景：
```
1. Agent 執行 git status → hook 攔截 → askAgent「這不是 git commit，直接執行」
2. Agent 重試 git status → hook 再次攔截 → 同樣回應
3. 重複 5-7 次後 agent 報錯中斷：「failed N times in a row, stuck in a loop」
```

根因：`toolTypes: ["shell"]` 無法區分 `git commit` 和 `git status`，而 prompt 中的「非 git commit 則直接執行」需要 agent 推理判斷，但 hook 在重試時又會再次攔截。

解決方案（按優先級）：
1. **改用 steering** — 把 commit 前檢查規則放在 always steering 中（guidance 不阻斷）
2. **改用 fileEdited hook** — 監聽特定檔案變更而非 shell 指令
3. **改用 userTriggered** — 手動觸發 commit 檢查

反面模式：
- ❌ `preToolUse` + `toolTypes: ["shell"]` + `askAgent`（條件判斷型）— 高頻觸發 + 推理判斷 = 迴圈風險
- ✅ `preToolUse` + `toolTypes: ["write"]` + `askAgent`（安全掃描型）— 寫入頻率較低，每次都需要檢查

掃描步驟：
```
對每個 preToolUse + shell 的 hook：
  □ prompt 是否包含「如果是 X 則…否則跳過」的條件判斷？（是 → 迴圈風險高）
  □ 是否可以改用更精確的觸發方式？（steering / fileEdited / userTriggered）
  □ 若必須用 shell category，是否有防迴圈機制？
```

### 3. Skill 健康度

#### 3.1 職責邊界

| 機制 | 適合放 | 不適合放 |
|------|--------|---------|
| Skill | 領域知識、可複用工作流程、跨專案通用的能力 | 專案特定的慣例（用 steering）、自動化檢查（用 hook） |
| Steering | 專案特定的規則、慣例、偏好 | 長篇領域知識（用 skill）、自動化動作（用 hook） |
| Hook | 事件驅動的自動檢查/動作 | 風格偏好（用 steering）、領域知識（用 skill） |
| MCP | 外部工具/文件的存取 | 專案內部規則（用 steering）、工作流程（用 skill） |
| Powers | 成熟技術的文件+工具+最佳實踐（Terraform、Postman 等） | 專案特定的意見（用 steering）、自訂工作流程（用 skill） |

#### 3.2 Skill 目錄結構限制

**Kiro 只掃描 `.kiro/skills/` 的直接子目錄**，不支援巢狀分類資料夾。

- ✅ `.kiro/skills/brainstorming/SKILL.md` — 正常偵測
- ❌ `.kiro/skills/dev-workflow/brainstorming/SKILL.md` — 無法偵測，skill 不會觸發

若需要分類組織，只能用命名前綴（如 `dev-brainstorming/`、`agent-harness/`），不能用子目錄。

**Kiro Power Link 不支援 skills 觸發**，只支援 steering、hooks、MCP。因此 skills 無法打包成 Power 分發，必須直接放在專案的 `.kiro/skills/` 下。

Powers vs Steering 的分界：
- 用 **Powers** 取得技術本身的文件和工具（「Terraform 怎麼用」）
- 用 **Steering** 表達你對該技術的意見（「我們的 Terraform 模組命名慣例」）
- 若某技術有官方 Power，優先安裝 Power 而非自己寫 steering 複製文件

掃描步驟：
```
對每個 skill：
  □ 是否有專案特定的慣例混在裡面？（應抽到 steering）
  □ 是否有自動化檢查邏輯？（應抽到 hook）

對每個 steering：
  □ 是否有超過 50 行的領域知識？（應抽到 skill）
  □ 是否有外部文件的複製內容？（應改用 #[[file:path]] 引用或 MCP）
```

#### 3.2 Description 觸發準確度

Skill 的 `description` 欄位決定 Kiro 何時自動建議啟用。應包含：
- 明確的使用場景關鍵字
- 「當…時使用」的觸發條件
- 避免過於寬泛的描述（會導致不相關時也被建議）

### 4. 整體一致性

#### 4.1 機制間的交叉引用

```
對每個 steering 中提到的 hook：
  □ 對應的 hook 檔案是否存在？
  □ hook 的觸發條件是否與 steering 描述一致？

對每個 steering 中提到的 skill：
  □ 對應的 skill 目錄是否存在？

對每個 hook prompt 中提到的檔案路徑：
  □ 該檔案是否存在？
```

#### 4.2 覆蓋缺口

```
□ 是否有 steering 規則沒有對應的 hook 強制執行？（列出高風險的）
□ 是否有 hook 沒有對應的 steering 說明其目的？
□ 是否有 skill 沒有在任何 steering 或 UsageReadme 中被提及？
```

---

## 輸出格式

```
## Kiro 框架健康度審計結果

### Steering 健康度
| 檔案 | Inclusion | 行數 | 狀態 | 備註 |
|------|-----------|------|------|------|
| {name} | {mode} | {lines} | ✅/⚠️/❌ | {issue} |

Always 檔案數：{N}/6
Context budget 評估：{健康/偏高/過載}

### Hook 設計健康度
| 檔案 | 觸發類型 | toolTypes | 狀態 | 備註 |
|------|----------|-----------|------|------|
| {name} | {type} | {types} | ✅/⚠️/❌ | {issue} |

### Skill 健康度
| 檔案 | 狀態 | 備註 |
|------|------|------|
| {name} | ✅/⚠️/❌ | {issue} |

### 整體一致性
- ✅/❌ 交叉引用完整性
- ✅/❌ 覆蓋缺口

### 改善建議（按優先級）
1. 🔴 {高優先級問題}
2. 🟡 {中優先級問題}
3. 🟢 {低優先級建議}
```

---

## 與現有框架的關係

- 本技能與 `harness-engineering` 互補：harness-engineering 審計的是「開發流程的 harness 覆蓋率」（Feedforward/Feedback/Wiring），本技能審計的是「Kiro 設定本身的品質」
- 本技能與 `sdd-scan` 互補：sdd-scan 檢查 spec 文件的 SDD 合規，本技能檢查 .kiro/ 設定的框架合規
- 建議在以下時機使用：
  - 匯入本模板到新專案後
  - 新增或修改 steering/hook/skill 後
  - 定期健康檢查（每月或每個里程碑）
