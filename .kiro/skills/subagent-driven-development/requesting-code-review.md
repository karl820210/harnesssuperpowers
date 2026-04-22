# 請求 Code Review（Requesting）

## 何時請求

**必須：**
- 每個 task 完成後（在 subagent 流程中自動執行）
- 完成主要功能後
- 合併到 main 前

**可選但有價值：**
- 卡住時（新鮮視角）
- 重構前（建立基線）
- 修完複雜 bug 後

## 請求方式

1. 取得 git SHA 範圍（base → head）
2. 派遣 reviewer sub-agent，提供：
   - 實作了什麼
   - 對應的 spec/plan 需求
   - git diff 範圍
   - 簡要描述
3. 根據 feedback 行動：
   - **Critical** → 立即修
   - **Important** → 繼續前必須修
   - **Minor** → 記錄，之後處理

## Review 嚴重度定義

| 等級 | 範圍 | 處理 |
|------|------|------|
| Critical（必須修） | 安全漏洞、資料損壞、spec 違反、功能壞掉 | 立即修，不繼續 |
| Important（應該修） | 效能問題、可維護性、測試覆蓋缺口 | 下個 task 前修完 |
| Minor（可以修） | 命名改善、註解補充、小重構 | 記錄，批次處理 |

## Two-Stage Review 檢查清單

### Stage 1：SDD 合規（Spec Compliance）

- [ ] 是否實作了 task 要求的所有功能？（不多不少）
- [ ] 新增的 exported function 是否有 precondition/postcondition？
- [ ] 若有對應的 CP-xx，是否有 PBT 測試？
- [ ] 若 Wiring Matrix 標示需要接線，是否有接線任務或已接線？
- [ ] 測試是否遵循 BDD 場景結構？
- [ ] 是否遵循了 TDD 流程？

### Stage 2：程式碼品質（Code Quality）

- [ ] 關注點分離是否清晰？
- [ ] 錯誤處理是否適當？
- [ ] DRY 原則是否遵循？
- [ ] 邊界條件是否處理？
- [ ] 測試是否測試真實行為（不只是 mock）？
- [ ] 每個檔案是否有單一明確職責？
- [ ] 所有測試是否通過？

## 禁止事項

- ❌ 因為「很簡單」就跳過 review
- ❌ 忽略 Critical 問題
- ❌ 帶著未修的 Important 問題繼續
- ❌ 對合理的技術 feedback 爭辯（但可以用技術理由反駁）
