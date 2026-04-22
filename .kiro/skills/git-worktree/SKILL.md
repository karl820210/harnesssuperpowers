---
name: git-worktree
description: Git Worktree 隔離開發。當開始新功能開發需要隔離環境、需要平行開發多個功能、或完成功能分支需要 merge/PR/清理時使用。涵蓋 worktree 建立、安全驗證、baseline 測試、分支完成的完整生命週期。
metadata:
  author: kiro
  version: "1.0"
  origin: "萃取自 superpower/using-git-worktrees + finishing-a-development-branch"
---

# Git Worktree 隔離開發

用 git worktree 建立隔離的開發環境，完成後處理分支合併/清理。

---

## Part 1：建立 Worktree

### 目錄選擇（按優先級）

1. **檢查現有目錄**：`.worktrees/` 或 `worktrees/`（若都存在，`.worktrees/` 優先）
2. **問使用者**：若都不存在
   - `.worktrees/`（專案內，隱藏）
   - `~/.config/superpowers/worktrees/<project>/`（全域位置）

### 安全驗證

**專案內目錄必須確認被 .gitignore 忽略：**

```bash
git check-ignore -q .worktrees 2>/dev/null
```

未被忽略 → 加到 `.gitignore` → commit → 再建 worktree。

**為什麼重要**：防止意外把 worktree 內容 commit 到 repo。

### 建立步驟

```bash
# 1. 偵測專案名稱
project=$(basename "$(git rev-parse --show-toplevel)")

# 2. 建立 worktree + 新分支
git worktree add .worktrees/{feature-name} -b feature/{feature-name}

# 3. 安裝依賴（自動偵測）
# Node.js: npm install
# Go: go mod download
# Python: pip install -r requirements.txt
# Rust: cargo build

# 4. 跑 baseline 測試
# 確保 worktree 起始狀態是乾淨的
```

**測試失敗**：回報失敗，問使用者是否繼續。
**測試通過**：回報就緒。

### 回報格式

```
Worktree ready at {full-path}
Tests passing ({N} tests, 0 failures)
Ready to implement {feature-name}
```

---

## Part 2：開發中

### 最佳實踐

- 定期 rebase main 分支
- 每個 task 完成後 commit
- 跑完整測試套件再合併

### 命名慣例

- 分支：`feature/{descriptive-name}`
- Worktree 目錄：`.worktrees/{descriptive-name}`

---

## Part 3：分支完成

### Step 1：驗證測試

**合併前必須確認測試通過。測試失敗就停下來，不提供選項。**

### Step 2：提供 4 個選項

```
實作完成。你想怎麼處理？

1. Merge 回 {base-branch}（本地）
2. Push 並建立 Pull Request
3. 保留分支不動（之後自己處理）
4. 丟棄這次工作
```

### Step 3：執行選擇

| 選項 | Merge | Push | 保留 Worktree | 清理分支 |
|------|-------|------|--------------|---------|
| 1. Merge locally | ✓ | — | — | ✓ |
| 2. Create PR | — | ✓ | ✓ | — |
| 3. Keep as-is | — | — | ✓ | — |
| 4. Discard | — | — | — | ✓（force） |

**Option 1：Merge locally**
```bash
git checkout {base-branch}
git pull
git merge {feature-branch}
# 驗證合併後測試
git branch -d {feature-branch}
# 清理 worktree
git worktree remove {worktree-path}
```

**Option 2：Push + PR**
```bash
git push -u origin {feature-branch}
gh pr create --title "{title}" --body "..."
# 保留 worktree（PR 可能需要修改）
```

**Option 3：Keep as-is**
- 回報分支和 worktree 位置，不做任何操作

**Option 4：Discard**
- **必須確認**：列出會刪除的分支和 commit，要求使用者輸入「discard」確認
```bash
git checkout {base-branch}
git branch -D {feature-branch}
git worktree remove {worktree-path}
```

---

## 禁止事項

- ❌ 建 worktree 前不驗證 .gitignore（專案內目錄）
- ❌ 跳過 baseline 測試
- ❌ 測試失敗時繼續合併
- ❌ 不確認就丟棄工作
- ❌ 假設目錄位置（遵循優先級）

---

## 與現有框架的關係

- **subagent-driven-development** 可在 worktree 中執行，提供隔離環境
- **sdd-bdd-tdd-workflow.md** 的驗收標準在合併前必須全部滿足
- **documentation-rules.md** 的 commit 規則在 worktree 中同樣適用
