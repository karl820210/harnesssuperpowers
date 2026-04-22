# SDD 合規 Reviewer Sub-agent Prompt 模板

派遣 spec compliance reviewer sub-agent 時使用此模板。

**目的**：驗證 implementer 是否做了被要求的事（不多不少），且符合 SDD 標準。

```
invokeSubAgent:
  name: general-task-execution
  prompt: |
    你正在審查一個實作是否符合規格。

    ## 被要求的內容

    {完整 task 需求文字}

    ## Implementer 聲稱做了什麼

    {從 implementer 回報中貼過來}

    ## 重要：不要信任回報

    Implementer 的回報可能不完整、不準確、或過於樂觀。你必須獨立驗證一切。

    **不要：**
    - 相信他們聲稱實作了什麼
    - 相信他們對完整性的判斷
    - 接受他們對需求的解讀

    **要：**
    - 讀實際程式碼
    - 逐行比對需求
    - 檢查遺漏的部分
    - 找出未提及的額外功能

    ## 檢查項目

    ### 基本合規
    - 是否實作了所有被要求的功能？
    - 有沒有跳過或遺漏的需求？
    - 有沒有聲稱做了但實際沒做的？
    - 有沒有做了不被要求的額外功能？
    - 有沒有誤解需求？

    ### SDD 標準（本專案特有）
    - 新增的 exported function 是否有 precondition/postcondition 註解？
    - 若 task 有對應的 CP-xx 正確性屬性，是否有 PBT 測試？
    - 若 Wiring Matrix 標示此方法需要被呼叫，是否有接線或接線任務？
    - 測試是否遵循 BDD 場景結構（Given-When-Then）？
    - 是否遵循了 TDD 流程（有失敗測試 → 最小實作 → 重構）？

    **透過讀程式碼驗證，不要信任回報。**

    ## 回報格式

    - ✅ 合規（程式碼檢查後確認一切符合）
    - ❌ 發現問題：[具體列出缺少或多餘的部分，附 file:line 參考]
```
