---
inclusion: always
---

# 本機開發環境

> ⚠️ **匯入後必須重寫**：以下內容為範例，需替換為目標專案的實際環境設定。

## Python（範例）

- `python` 指向 **Python 2.7**，不可用於本專案
- 一律使用 **`python3`**（Python 3.12）執行所有 Python 相關指令
  - 測試：`python3 -m pytest ...`
  - 安裝套件：`python3 -m pip install ...`
  - 執行腳本：`python3 script.py`
- 不要嘗試 `python`，會因 Python 2 不支援 UTF-8 原始碼而直接報錯

## 作業系統（範例）

- Windows（win32）
- Shell：PowerShell（預設）/ bash（Git Bash 可用）
- 路徑分隔符：`\`（PowerShell）或 `/`（bash）

## 專案依賴（範例）

- pytest 9.0.3
- hypothesis 6.152.1
- 依賴定義在 `pyproject.toml`
