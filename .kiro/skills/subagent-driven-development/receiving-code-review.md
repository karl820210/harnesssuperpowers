# 回應 Code Review（Receiving）

## 回應流程

```
收到 review feedback 時：
1. READ：完整讀完所有 feedback，不要邊讀邊反應
2. UNDERSTAND：用自己的話重述需求（或提問）
3. VERIFY：對照 codebase 實際狀況驗證
4. EVALUATE：對這個 codebase 來說技術上合理嗎？
5. RESPOND：技術性確認或有理由的反駁
6. IMPLEMENT：一次修一項，每項都測試
```

## 禁止的回應

- ❌ 「You're absolutely right!」（performative agreement）
- ❌ 「Great point!」/「Excellent feedback!」
- ❌ 「Let me implement that now」（驗證前不要動手）
- ❌ 任何感謝表達（「Thanks for catching that!」）

正確的回應：
- ✅ 重述技術需求
- ✅ 提出釐清問題
- ✅ 用技術理由反駁（如果 reviewer 錯了）
- ✅ 直接動手修（行動 > 言語）
- ✅ 「Fixed. [簡述改了什麼]」
- ✅ 「Good catch — [具體問題]. Fixed in [位置].」

## 不清楚的 Feedback

**任何一項不清楚就全部停下來問清楚再動手。**

不要只做懂的部分 — 項目之間可能有關聯，部分理解 = 錯誤實作。

範例：
```
feedback 有 6 項，你懂 1,2,3,6，不懂 4,5

❌ 先做 1,2,3,6，之後再問 4,5
✅ 「我理解 1,2,3,6。4 和 5 需要釐清後再開始。」
```

## 何時反駁

反駁的時機：
- 建議會破壞現有功能
- Reviewer 缺乏完整上下文
- 違反 YAGNI（未使用的功能）
- 對這個技術棧來說技術上不正確
- 與使用者的架構決策衝突

反駁方式：
- 用技術理由，不要防禦性
- 問具體問題
- 引用可運作的測試/程式碼
- 涉及架構決策時與使用者確認

反駁錯了怎麼辦：
- ✅ 「你是對的 — 我檢查了 X，確實是 Y。修正中。」
- ❌ 長篇道歉或解釋為什麼反駁

## 實作順序

多項 feedback 時：
1. 先釐清所有不清楚的項目
2. 按順序實作：
   - 阻塞問題（壞掉的、安全的）
   - 簡單修正（typo、import）
   - 複雜修正（重構、邏輯）
3. 每項修完都單獨測試
4. 確認無迴歸

## 來源區分

### 來自 sub-agent reviewer
- 信任度中等 — 仍需驗證建議是否適用
- 不要盲目實作，先對照 codebase 確認

### 來自使用者
- 信任度高 — 理解後實作
- 範圍不清楚時仍要問
- 不要 performative agreement，直接行動

### 來自外部 reviewer
- 信任度低 — 先驗證再實作
- 檢查：技術上正確嗎？會破壞現有功能嗎？reviewer 理解完整上下文嗎？
- 與使用者先前決策衝突時，先與使用者確認
