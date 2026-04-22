---
name: brainstorming
description: 對話式需求探索與設計。當討論新功能、規格、需求、設計、或開始 Spec 的 Requirements 階段時使用。一次一個問題探索意圖，提出 2-3 方案比較，分段呈現設計並逐段確認。設計未批准前禁止寫任何程式碼。
metadata:
  author: kiro
  version: "1.0"
  origin: "萃取自 superpower/brainstorming，整合 Kiro Spec 流程"
---

# 對話式需求探索與設計（Brainstorming）

把模糊的想法變成明確的設計，透過自然對話逐步釐清。

## HARD GATE

**設計未經使用者批准前，禁止寫任何實作程式碼、建立任何檔案結構、或執行任何實作動作。**

不管專案看起來多簡單都適用。「太簡單不需要設計」是最常見的失敗模式 — 簡單專案裡未檢驗的假設造成最多浪費。

---

## 流程

### 1. 探索專案脈絡

- 檢查現有檔案、文件、最近 commit
- 評估範圍：如果請求描述了多個獨立子系統，立即標記需要拆分，不要花時間細化一個過大的 spec

### 2. 提供 Visual Companion（若主題涉及視覺問題）

若預期後續問題會涉及視覺內容（mockup、layout、diagram），**用獨立訊息**詢問是否啟用：

> 「接下來的討論可能有些東西用看的比用說的清楚。我可以在瀏覽器裡展示 mockup、diagram、比較圖。要試試嗎？（需要開啟一個 localhost URL）」

這個提議必須是獨立訊息，不要和其他問題混在一起。使用者拒絕就用純文字繼續。

詳見 `visual-companion.md`。

### 3. 逐一提問釐清需求

- **一次只問一個問題** — 不要一次丟出多個問題
- 盡量用選擇題（比開放式問題容易回答）
- 聚焦：目的、限制、成功標準

### 4. 提出 2-3 個方案

- 每個方案列出取捨
- 帶上你的推薦和理由
- 推薦方案放第一個

### 5. 分段呈現設計

- 每段依複雜度調整長度（簡單的幾句話，複雜的 200-300 字）
- 每段結束後確認：「到這裡看起來對嗎？」
- 涵蓋：架構、元件、資料流、錯誤處理、測試策略
- 隨時可以回頭修改

### 6. 設計 Self-Review

呈現完設計後，用新鮮眼光自我檢查：

1. **Placeholder 掃描**：有沒有 TBD、TODO、不完整的段落？修掉。
2. **內部一致性**：各段落之間有沒有矛盾？架構和功能描述是否匹配？
3. **範圍檢查**：這個設計是否聚焦到可以用一個 Spec 實作？還是需要拆分？
4. **歧義檢查**：有沒有需求可以被兩種方式解讀？選一個並明確寫出。

發現問題就直接修，不需要重新 review。

### 7. 使用者審核

> 「設計已整理完成。請確認是否要調整，確認後我們進入 Spec 的 Requirements/Design 階段。」

等使用者回應。有修改就改，批准後才進入實作規劃。

---

## 與 Kiro Spec 的整合

Brainstorming 是 Spec **之前**的探索階段：

```
Brainstorming（本 skill）→ Kiro Spec Requirements → Design → Tasks → subagent-driven-development 執行
```

**銜接流程**：
1. Brainstorming 產出設計 → 使用者批准
2. 使用者在 Kiro 建立 Spec（或 agent 協助建立）
3. Agent 撰寫 Requirements（含 CP-xx）+ Design（含 Wiring Matrix）+ Tasks（遵循 `sdd-bdd-tdd-workflow.md` 的 Task 撰寫規則）
4. `subagent-driven-development` skill 從 tasks.md 開始逐一執行

不需要另外寫 `docs/plans/` 文件 — Kiro Spec 就是我們的設計文件。

---

## 設計原則

- **YAGNI** — 無情地移除不需要的功能
- **隔離與清晰** — 每個單元一個職責、明確介面、可獨立理解和測試
- **在現有 codebase 中工作** — 先探索現有結構，遵循既有 pattern
- **大專案拆分** — 如果設計涵蓋多個獨立子系統，建議拆成多個 Spec，每個獨立開發

---

## 判斷是否需要 Visual Companion

| 內容類型 | 用瀏覽器 | 用文字 |
|---------|---------|--------|
| UI mockup、wireframe、layout | ✅ | |
| 架構 diagram、資料流圖 | ✅ | |
| 並排視覺比較 | ✅ | |
| 需求/範圍問題 | | ✅ |
| 概念性 A/B/C 選擇 | | ✅ |
| 取捨清單、比較表 | | ✅ |
| 技術決策（API 設計、資料模型） | | ✅ |

關於 UI 主題的問題不一定是視覺問題。「你想要什麼樣的 wizard？」是概念問題（用文字）。「這兩個 wizard layout 哪個好？」是視覺問題（用瀏覽器）。
