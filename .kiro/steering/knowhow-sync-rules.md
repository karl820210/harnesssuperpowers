---
inclusion: always
---

# KnowHow 自動同步規則

## 目的
開發過程中發現的問題、解決方案、經驗教訓，必須自動同步到對應的 KnowHow 文件、Skill 和 Steering，形成知識閉環。

## 觸發時機
當 agent 在修正 bug、解決問題、或調整設計時，若發現了「AI 自己沒注意到，經過人工補充或除錯才了解的」知識點，必須：

1. 先完成修正工作
2. 判斷這個知識點屬於哪個分類（見下方映射表）
3. 更新對應的 KnowHow 文件（追加新條目）
4. 更新對應的 Skill / Steering（若知識點影響規格或慣例）
5. 更新開發自檢清單（若知識點是可重複檢查的項目）

## KnowHow 分類映射表

### 映射規則：知識點 → 該寫到哪裡

| 知識領域 | KnowHow 文件 | 相關 Skill（更新規格） | 相關 Steering（更新慣例） |
|----------|-------------|----------------------|-------------------------|
| 座標/渲染/Canvas | 魚機製作KnowHow.md | pixel-art-generator, retro-vfx-director | canvas-conventions.md |
| Go Server/鎖/goroutine | 魚機製作KnowHow.md | go-server | go-conventions.md |
| WebSocket 協議/訊息格式 | 魚機製作KnowHow.md | go-server, retro-vfx-director | go-conventions.md |
| 像素圖編譯/色板/尺寸 | 魚機製作KnowHow.md | go-pixel-compiler, pixel-art-generator | pixel-project.md |
| 3D 模型製程/Meshy/概念圖 | 魚機製作KnowHow.md | cannon-system（模型製程段落） | — |
| 出魚腳本/波次/場景 | 魚機製作KnowHow.md | spawn-script-engine | spawn-script-conventions.md |
| RTP/機率/水位 | 魚機製作KnowHow.md | game-design, go-server | — |
| Boss 機制/V值/永生魚 | 魚機製作KnowHow.md | game-design | — |
| 小爆獎/翻牌/覺醒觸發 | 魚機製作KnowHow.md | game-design, game-presentation | — |
| 演出節奏/期待感/動畫 | 遊戲演出KnowHow.md | game-presentation, retro-vfx-director, pachinko-演出 | — |
| 音效/BGM/8-bit | 遊戲演出KnowHow.md | ui-audio, 8bit-audio-converter, retro-vfx-director | canvas-conventions.md |
| UI/HUD/字體 | 遊戲演出KnowHow.md | ui-audio | canvas-conventions.md |
| 砲台/武器/射擊 | 魚機製作KnowHow.md | cannon-system, shooting-skills | — |
| 魚群AI/Steering | 魚機製作KnowHow.md | steering-ai | — |
| 特殊遊戲規則 | 魚機製作KnowHow.md | game-design | — |
| API 整合/外部服務 | 魚機製作KnowHow.md | — | — |
| 編碼/路徑/環境 | 魚機製作KnowHow.md | — | — |
| Sprite Sheet/動畫幀 | 魚機製作KnowHow.md | pixel-animator, pixel-art-generator | — |

### 更新原則

#### KnowHow 文件（追加）
- 格式：`## {編號}. {標題}`
- 必填：問題、解決、教訓
- 編號遞增，不修改已有條目（除非資訊過時需修正）

#### Skill 文件（修改）
- 只更新受影響的段落，不重寫整個 Skill
- 若新知識點改變了規格（如尺寸、色板、協議格式），直接修改 Skill 中的對應表格或參數
- 若新知識點新增了功能，在 Skill 中新增對應段落

#### Steering 文件（修改）
- 只在知識點涉及「慣例/禁止事項/必須遵守的規則」時才更新
- 新增規則放在對應段落末尾

#### 開發自檢清單（追加）
- 若知識點是「每次寫程式都該檢查的事」，追加到 `開發自檢清單.md` 對應分類
- 格式：`- [ ] {檢查項目描述}`

## 判斷是否需要同步的標準

以下情況必須同步：
1. 修了一個 bug，且根因是「之前不知道的限制或行為」
2. 使用者指出了 agent 的錯誤認知
3. 嘗試了某個方案但失敗，換了另一個方案
4. 發現了 API/工具/框架的未文件化行為
5. 調整了設計決策（如機率、尺寸、協議格式）

以下情況不需要同步：
1. 單純的 typo 修正
2. 程式碼格式調整
3. 已知問題的重複修正（KnowHow 已有記錄）

## 同步完成後的確認
更新完所有相關文件後，在回覆中簡要列出：
- 📝 KnowHow：新增了什麼條目
- 🔧 Skill：修改了哪個 Skill 的哪個段落
- 📏 Steering：修改了哪條規則
- ✅ 自檢清單：新增了什麼檢查項
