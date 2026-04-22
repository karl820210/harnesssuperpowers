---
name: subagent-driven-development
description: 子代理驅動開發。當執行 Spec tasks、run all tasks、實作計畫、或需要逐一完成多個獨立任務時使用。每個 task 派遣新的 sub-agent 執行，搭配 two-stage review（SDD 合規 → 程式碼品質）確保品質。
metadata:
  author: kiro
  version: "1.1"
  origin: "萃取自 superpower/subagent-driven-development，整合本專案 SDD/TDD 流程"
---

# 子代理驅動開發（Subagent-Driven Development）

每個 task 派遣新的 sub-agent 執行，搭配 two-stage review 確保品質。

**為什麼用 sub-agent**：新的 sub-agent 有乾淨 context，不會被前面 task 的殘留資訊干擾。Controller（你）負責讀 plan、分派任務、提供上下文，保持自己的 context 用於協調工作。

**核心原則**：每個 task 一個新 sub-agent + two-stage review（SDD 合規 → 品質）= 高品質、快速迭代

---

## 流程

### 1. 準備

1. **建議先用 `git-worktree` skill 建立隔離環境**（避免影響 main 分支）
2. 讀取 Spec 的 tasks.md，提取所有 task 的完整文字
3. 記錄每個 task 的上下文（依賴、前置 task 的產出、相關檔案）
4. 記錄 Design 文件的 Wiring Matrix 和 CP-xx 正確性屬性（review 時需要）

### 2. 逐一執行每個 Task

對每個 task：

**a) 派遣 Implementer sub-agent**
- 使用 `invokeSubAgent`（name: `general-task-execution`）
- 提供完整 task 文字 + 上下文（不要讓 sub-agent 自己去讀 plan）
- 使用 `implementer-prompt.md` 模板

**b) 處理 Implementer 回報**

| Status | 處理方式 |
|--------|---------|
| DONE | 進入 review |
| DONE_WITH_CONCERNS | 讀 concerns，若涉及正確性/範圍就先處理，否則記錄後進入 review |
| NEEDS_CONTEXT | 提供缺少的上下文，重新派遣 |
| BLOCKED | 評估阻塞原因：context 問題 → 補上下文重派；task 太大 → 拆分；plan 有誤 → 與使用者討論 |

**c) Stage 1：SDD 合規 Review**
- 派遣 Spec Reviewer sub-agent（使用 `spec-reviewer-prompt.md` 模板）
- 檢查：功能完整性、precondition/postcondition、CP-xx PBT、Wiring Matrix 接線
- 未通過 → implementer 修正 → 再 review
- **必須通過 Stage 1 才能進入 Stage 2**

**d) Stage 2：程式碼品質 Review**
- 派遣 Code Quality Reviewer sub-agent（使用 `code-quality-reviewer-prompt.md` 模板）
- 檢查：結構、可讀性、測試品質、錯誤處理、效能、安全
- 未通過 → implementer 修正 → 再 review

**e) 處理 review feedback** — 詳見 `requesting-code-review.md` 和 `receiving-code-review.md`

**f) 標記 task 完成**

### 3. 全部完成後

- 派遣最終 reviewer 檢查整體實作
- 執行完整測試套件
- 確認 Wiring Matrix 所有條目都已接線

---

## Model Selection 策略

| 任務複雜度信號 | 建議模型 |
|--------------|---------|
| 改 1-2 個檔案、spec 完整明確 | 快速便宜模型 |
| 跨多個檔案、有整合考量 | 標準模型 |
| 需要架構判斷、廣泛 codebase 理解 | 最強模型 |

---

## 禁止事項

- ❌ 在 main/master 分支上開始實作（未經使用者同意）
- ❌ 跳過任何一階段的 review
- ❌ 帶著未修正的問題繼續下一個 task
- ❌ 平行派遣多個 implementer sub-agent（會衝突）
- ❌ 讓 sub-agent 自己去讀 plan 檔案（由 controller 提供完整文字）
- ❌ 忽略 sub-agent 的問題（先回答再讓它繼續）
- ❌ 在 Stage 1 未通過前開始 Stage 2
- ❌ Spec reviewer 發現問題就算「差不多」通過

---

## 相關文件

| 文件 | 用途 |
|------|------|
| `./implementer-prompt.md` | Implementer sub-agent prompt 模板 |
| `./spec-reviewer-prompt.md` | SDD 合規 reviewer prompt 模板 |
| `./code-quality-reviewer-prompt.md` | 程式碼品質 reviewer prompt 模板 |
| `./requesting-code-review.md` | 何時請求 review、請求方式、嚴重度定義 |
| `./receiving-code-review.md` | 回應 review 的紀律、反駁時機、實作順序 |

---

## 與現有框架的關係

- **建議搭配 `git-worktree` skill** 在隔離環境中執行，完成後用其 Part 3 處理分支合併
- **Stage 1 Review** 整合 `sdd-bdd-tdd-workflow.md` 的 SDD 標準（CP-xx、Wiring Matrix、接線完整性）
- **Implementer** 遵循 `sdd-bdd-tdd-workflow.md` 的 TDD 流程（Red → Green → Refactor + PBT）
- **全部完成後** 的最終檢查對應 Checkpoint Task 的五維度審計
- **KnowHow Sync** 由 `agentStop` hook 在整個 session 結束時處理
