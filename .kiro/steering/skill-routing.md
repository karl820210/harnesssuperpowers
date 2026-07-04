---
inclusion: always
---

# Skill 路由表

回應前先判斷是否有 skill 適用。Process skill 優先於 Implementation skill。

## 何時啟用哪個 Skill

| 使用者意圖 | 啟用 Skill | 類型 |
|-----------|-----------|------|
| 進入不熟的 codebase/領域、大改動前找「未知的未知」 | `blind-spot-scan` | Process |
| 討論新功能、需求、設計、規格 | `brainstorming` | Process |
| 遇到 bug、測試失敗、非預期行為 | `systematic-debugging` | Process |
| 執行 Spec tasks、run all tasks | `subagent-driven-development` | Implementation |
| 開始新功能需要隔離環境 | `using-git-worktrees` | Implementation |
| run all tasks 前檢查 spec 品質 | `spec-scan` | Implementation |
| 大改動完成、merge 前要確認自己看懂了 | `post-implementation-quiz` | Process |
| 審計 .kiro/ 設定品質 | `kiro-framework-audit` | Meta |
| 審計 harness 覆蓋率、接線完整性 | `harness-engineering` | Meta |

## 優先級

1. **Process skills 先**（brainstorming、systematic-debugging）— 決定怎麼做
2. **Implementation skills 後**（subagent-driven-development、using-git-worktrees）— 執行

「建一個 X」→ 先 brainstorming，再 subagent-driven-development。
「修這個 bug」→ 先 systematic-debugging，修完走 `test-driven-development`。

## Skill 紀律

- **Rigid**（嚴格遵循）：systematic-debugging 的 4 階段、`test-driven-development` 的 TDD Iron Law（steering 對照：`.kiro/steering/sdd-bdd-tdd-workflow.md`，那是規則檔不是 skill）
- **Flexible**（可適應）：brainstorming 的問題順序、using-git-worktrees 的目錄選擇
