---
name: sdd-scan
description: SDD 合規掃描。掃描指定 spec 的 requirements.md、design.md、tasks.md 是否符合 SDD 規則（CP-xx 正確性屬性、precondition/postcondition、Wiring Matrix、BDD+TDD 結構）。當需要掃描 spec 合規性、檢查 SDD 規則、驗證 spec 文件品質、run all tasks 前檢查時使用。
metadata:
  author: kiro
  version: "1.0"
---

# SDD 合規掃描

在 run all tasks 前，掃描指定 spec 的三份文件是否符合 SDD 規則。

## 使用方式

在 chat 中輸入 `#sdd-scan` 並指定 spec 名稱，例如：
```
#sdd-scan hit-system-v2
```

若未指定 spec 名稱，掃描當前開啟的 spec（從 active editor file 推斷）。

## 掃描項目

### 1. requirements.md
- [ ] 是否包含 CP-{編號} 格式的正確性屬性？
- [ ] 每個 CP 是否標註對應的需求條款？

### 2. design.md
- [ ] 公開函式是否標註 precondition / postcondition？
- [ ] 是否有接線矩陣（Wiring Matrix）段落？
- [ ] 計算步驟是否標示 Latent / Deterministic？

### 3. tasks.md
- [ ] 實作任務是否包含 BDD + TDD 子任務結構（N.1 BDD → N.2 Red → N.3 Green → N.4 Refactor → N.5 PBT）？
- [ ] 新增 exported function 的任務後面是否有接線任務？
- [ ] Checkpoint task 是否包含五維度審計指令？

## 輸出格式

```
## SDD 合規掃描結果 — {spec_name}

### requirements.md
- ✅ CP-xx 正確性屬性：{數量} 條
- ✅ / ❌ {具體問題}

### design.md
- ✅ / ❌ precondition/postcondition
- ✅ / ❌ Wiring Matrix
- ✅ / ❌ Latent/Deterministic 標示

### tasks.md
- ✅ / ❌ BDD+TDD 結構
- ✅ / ❌ 接線任務
- ✅ / ❌ Checkpoint 審計指令

### 結論
全部合規 / 有 {N} 項缺漏需修正
```
