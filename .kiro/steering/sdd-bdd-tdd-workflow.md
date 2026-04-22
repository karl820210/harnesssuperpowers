---
inclusion: fileMatch
fileMatchPattern: "**/*_test.go,**/*.test.js,**/*.spec.js,.kiro/specs/**/*.md"
---

# SDD → BDD → TDD 開發流程

本專案採用 Specification-Driven → Behavior-Driven → Test-Driven 三階段開發流程。
每個 Spec 的 Requirements / Design / Tasks 階段必須對應產出以下產物。

## 第一階段：SDD（Specification-Driven Design）

對應 Spec 的 Requirements + Design 階段。

- Requirements 必須包含明確的正確性屬性（Correctness Properties）
  - 格式：`CP-{編號}: {屬性描述}`
  - 範例：`CP-01: 任何魚的 TTL 到期後必須從場景移除，不得殘留`
- Design 必須包含可驗證的介面契約（Interface Contract）
  - 每個公開函式/方法標註前置條件（precondition）與後置條件（postcondition）
  - 範例：`ProcessShot(bulletID, fishID) → precondition: bullet.Active && fish.Alive / postcondition: fish.HP decreased OR miss recorded`
- Design 必須包含接線矩陣（Wiring Matrix）
  - 列出每個新增方法的呼叫者、呼叫時機、參數來源
  - 若方法需要在 Room.Tick 或事件處理中被呼叫，必須明確標示
  - 格式：表格，欄位為「呼叫者 | 被呼叫方法 | 呼叫時機 | 參數來源 | 廣播訊息」
  - 接線矩陣是後續接線任務和整合測試的依據
- 正確性屬性、介面契約和接線矩陣是後續 BDD 場景和 PBT 測試的依據

## 第二階段：BDD（Behavior-Driven Development）

對應 Spec 的 Tasks 階段，在寫實作程式碼之前。

- 每個 User Story / 驗收條件必須轉換為 Given-When-Then 場景
- 場景寫在對應的測試檔案中，作為註解或測試函式名稱
- Go 測試命名慣例：`Test_{Feature}_{Given}_{When}_{Then}`
  - 範例：`Test_Collision_GivenActiveBullet_WhenHitsFish_ThenDamageApplied`
- JS 測試（若有）命名慣例：`describe('{Feature}') > it('should {behavior} when {condition}')`
- 場景必須覆蓋：
  - 正常路徑（Happy Path）
  - 邊界條件（Boundary）
  - 錯誤處理（Error / Edge Case）

## 第三階段：TDD（Test-Driven Development）

每個 Task 的實作必須遵循 Red → Green → Refactor 循環。

### Iron Law

**沒有失敗測試就不准寫 production code。**

先寫了 production code？刪掉，從測試重新開始。
- 不保留作「參考」
- 不邊看邊「adapt」
- 不「之後再補測試」
- Delete means delete

### TDD 常見合理化藉口 — 全部無效

| 藉口 | 現實 |
|------|------|
| 「太簡單不需要測試」 | 簡單程式碼也會壞。寫測試只要 30 秒。 |
| 「之後再補測試」 | 測試直接通過什麼都不能證明。 |
| 「先寫後補測試效果一樣」 | 後補測試問的是「它做了什麼」，先寫測試問的是「它應該做什麼」。 |
| 「保留當參考，再從測試開始」 | 你會 adapt 它。那就是後補測試。Delete means delete。 |
| 「需要先探索」 | 可以。探索完丟掉，從 TDD 重新開始。 |
| 「TDD 會拖慢速度」 | TDD 比 debug 快。 |

### 執行順序

1. **Red**：先寫測試（基於 BDD 場景），確認測試失敗
   - **Verify RED（必做）**：跑測試，確認失敗原因是功能缺失（不是 typo 或 import 錯誤）
   - 測試直接通過？→ 你在測試已有行為，修改測試
2. **Green**：寫最少量的實作程式碼讓測試通過
   - **Verify GREEN（必做）**：跑測試，確認通過且其他測試沒壞
   - 不加功能、不重構其他程式碼、不「改善」超出測試範圍的東西
3. **Refactor**：重構程式碼，測試必須持續通過
   - 只在 Green 之後才重構
   - 保持測試綠燈，不加新行為

### Go 測試規則
- 測試檔案放在同 package，命名 `{file}_test.go`
- 使用標準 `testing` 套件，不引入外部測試框架（除非 PBT 需要）
- Property-Based Testing 使用 `testing/quick` 或團隊選定的 PBT 庫
- 每個正確性屬性（CP-xx）必須有對應的 PBT 測試

### JS 測試規則（若適用）
- 純函式邏輯可用簡易 assert 測試
- Canvas 渲染邏輯以手動驗證為主，但狀態邏輯必須有測試

## Task 撰寫規則

### 粒度與完整性

每個子任務應是 **2-5 分鐘可完成的單一動作**。每步必須包含完整內容：

**禁止 Placeholder** — 以下寫法是 Task 撰寫失敗，絕不允許：
- TBD、TODO、「之後補」、「填入細節」
- 「加入適當的錯誤處理」/「加入驗證」/「處理邊界條件」（不具體）
- 「為上述功能寫測試」（沒有實際測試程式碼）
- 「類似 Task N」（重複寫出程式碼 — 執行者可能不按順序讀）
- 描述要做什麼但沒有展示怎麼做的步驟（程式碼步驟必須有 code block）

### 子任務結構

Spec 的 tasks.md 中，每個實作 Task 必須包含以下子任務結構：

```
- [ ] N. {功能描述}
  - [ ] N.1 撰寫 BDD 場景（Given-When-Then）
  - [ ] N.2 撰寫失敗測試（Red）
  - [ ] N.3 實作最小程式碼（Green）
  - [ ] N.4 重構並確認測試通過（Refactor）
  - [ ] N.5 撰寫 PBT 測試驗證正確性屬性（若有對應 CP）
```

若該 Task 新增了 exported function/method，且 Wiring Matrix 標示它需要被其他模組呼叫，則必須緊跟一個接線任務：

```
- [ ] N+1. 接線：將 {方法名} 整合到 {呼叫者}
  - [ ] (N+1).1 在呼叫者中呼叫該方法（依 Wiring Matrix 的時機與參數）
  - [ ] (N+1).2 撰寫整合測試驗證完整呼叫鏈（從觸發到結果廣播）
  - [ ] (N+1).3 確認 Wiring Matrix 與實作一致
```

### Tasks Self-Review

撰寫完所有 Task 後，自我檢查：

1. **Spec 覆蓋**：逐一檢查 Requirements 的每個需求，能否指向一個實作它的 Task？列出缺口。
2. **Placeholder 掃描**：搜尋上述「禁止 Placeholder」清單中的模式，修掉。
3. **Type 一致性**：後面 Task 使用的型別、method 名稱、property 名稱是否與前面 Task 定義的一致？（例如 Task 3 叫 `clearLayers()` 但 Task 7 叫 `clearFullLayers()` 就是 bug）

發現問題就直接修，不需要重新 review。若發現 spec 需求沒有對應 Task，補上。

## Checkpoint Task 規則

tasks.md 中每個階段結束時應有一個 Checkpoint task（例如 Server 核心元件完成後、Server 整合完成後、Client 整合完成後、全系統完成後）。

Checkpoint task 的描述必須包含以下五維度審計指令：

```
- [ ] N. Checkpoint — {階段名稱}驗證
  - 執行全部測試（go test ./... 或對應的測試指令），確認無回歸
  - Harness 五維度審計：
    1. Feedback 覆蓋率：本階段新增的 exported function 是否都有單元測試？是否有整合測試驗證跨模組呼叫鏈？
    2. 接線完整性：本階段新增的所有方法是否都有呼叫者？（尚未接線的方法應在後續 Task 中接線）
    3. Latent/Deterministic 分界：是否有確定性邏輯被留給 agent 推理而非明確實作？
    4. 測試健康度：是否有 flaky 測試？
    5. Flywheel 健康度：本階段是否有新的 KnowHow 需記錄？
  - 若有問題，列出並與使用者確認後再繼續
```

最終的 Checkpoint（全系統驗證）還應包含：
- 確認所有正確性屬性（CP-xx）都有對應的 PBT 測試
- 確認 Wiring Matrix 所有條目都已接線
- 確認無未呼叫的 exported function（除非標記為 public API）

## 測試 Anti-Patterns

寫測試或加 mock 時，注意以下常見錯誤：

### 測試 mock 行為而非真實行為
- ❌ `expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument()` — 驗證 mock 存在，不是驗證元件行為
- ✅ 測試真實元件行為，或不 mock 該元件

### 在 production class 加 test-only method
- ❌ 在 production class 加 `destroy()` 只給測試用 — 污染 production code，若意外呼叫很危險
- ✅ 把測試清理邏輯放在 test utilities 裡

### Mock 前不理解依賴
- ❌ 「為了安全先 mock」— 可能 mock 掉測試依賴的副作用，導致測試通過但原因錯誤
- ✅ 先理解真實方法的副作用，只 mock 真正慢/外部的操作，保留測試需要的行為

### 不完整的 mock 資料
- ❌ 只 mock 你知道的欄位 — 下游程式碼可能依賴你沒 mock 的欄位，靜默失敗
- ✅ Mock 完整的資料結構，與真實 API 回應一致

### 判斷標準
- 如果 assertion 檢查的是 mock 元素（`*-mock` test ID）→ 你在測試 mock，不是測試行為
- 如果 method 只在測試檔案中被呼叫 → 不該放在 production class
- 如果 mock setup 超過測試邏輯的 50% → 考慮用整合測試取代
- 如果移除 mock 測試就壞了 → 你可能 mock 了不該 mock 的東西

## 驗收標準

一個 Task 完成的條件：
1. 所有 BDD 場景對應的測試通過
2. 所有相關正確性屬性的 PBT 測試通過
3. `go test ./...` 全部通過（Server 端）
4. 無新增的 lint 警告
5. 若 Task 新增了 exported function，該 function 必須有至少一個呼叫者（接線完整性）
6. 若有對應的接線任務，整合測試必須驗證完整呼叫鏈

### 完成前驗證（Iron Law）

**宣稱完成前必須跑驗證指令並讀完整輸出。沒有跑過驗證就宣稱完成 = 說謊。**

- ✅ 跑測試指令 → 看到「34/34 pass」→ 「所有測試通過」
- ❌ 「should pass now」/「looks correct」/「應該沒問題」

禁止使用的詞彙（除非有驗證證據支撐）：
- 「should」「probably」「seems to」「應該」「大概」「看起來」

每種宣稱對應的驗證：

| 宣稱 | 必須跑的驗證 | 不夠的驗證 |
|------|------------|----------|
| 測試通過 | 測試指令輸出：0 failures | 之前跑過、「應該會過」 |
| Build 成功 | Build 指令：exit 0 | Linter 通過（linter ≠ compiler） |
| Bug 已修 | 原始重現案例通過 | 改了程式碼、假設修好了 |
| 需求已滿足 | 逐條對照 spec checklist | 測試通過（測試可能沒覆蓋所有需求） |

## 與現有流程的整合

- 此流程與 `knowhow-sync-rules.md` 互補：TDD 過程中發現的知識點仍需同步
- 此流程與 `documentation-rules.md` 互補：commit 前仍需更新 CHANGELOG / DEV_NOTES
- Spec 的 Requirements 階段產出正確性屬性，Design 階段產出介面契約，Tasks 階段執行 BDD + TDD
