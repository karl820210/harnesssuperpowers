# Visual Companion 操作指南

瀏覽器視覺化工具，用於在 brainstorming 過程中展示 mockup、diagram、選項比較。

## 運作方式

Server 監看一個目錄的 HTML 檔案，把最新的推送到瀏覽器。你寫 HTML 到 `screen_dir`，使用者在瀏覽器看到並可以點選。選擇記錄到 `state_dir/events`，你在下一輪讀取。

## 啟動 Session

```bash
# 啟動 server（mockup 存到專案目錄）
.kiro/skills/brainstorming/scripts/start-server.sh --project-dir /path/to/project
```

回傳 JSON：
```json
{"type":"server-started","port":52341,"url":"http://localhost:52341",
 "screen_dir":"/path/to/project/.superpowers/brainstorm/12345/content",
 "state_dir":"/path/to/project/.superpowers/brainstorm/12345/state"}
```

記下 `screen_dir` 和 `state_dir`。告訴使用者開啟 URL。

**Windows 注意**：Windows/Git Bash 會自動切換到 foreground 模式。

## 操作循環

1. **檢查 server 存活** → **寫 HTML** 到 `screen_dir` 的新檔案
   - 用語義化檔名：`platform.html`、`layout.html`
   - **不要重複使用檔名** — 每個畫面用新檔案
   - Server 自動推送最新檔案

2. **告訴使用者看瀏覽器**，結束你的回合
   - 每步都提醒 URL
   - 簡述畫面內容
   - 請使用者在 terminal 回應

3. **下一輪** — 讀取 `$STATE_DIR/events`（若存在）
   - 包含使用者的瀏覽器互動（點擊、選擇）
   - 合併 terminal 文字得到完整回饋

4. **迭代或前進** — 回饋改變當前畫面就寫新版本（如 `layout-v2.html`）

5. **回到文字模式時** — 推送等待畫面清除過期內容：
   ```html
   <div style="display:flex;align-items:center;justify-content:center;min-height:60vh">
     <p class="subtitle">Continuing in terminal...</p>
   </div>
   ```

## 寫 Content Fragment

只寫頁面內容，server 自動包裹 frame template（header、CSS、選擇指示器）。

```html
<h2>哪個 layout 比較好？</h2>
<p class="subtitle">考慮可讀性和視覺層次</p>

<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>單欄</h3>
      <p>乾淨、聚焦的閱讀體驗</p>
    </div>
  </div>
  <div class="option" data-choice="b" onclick="toggleSelect(this)">
    <div class="letter">B</div>
    <div class="content">
      <h3>雙欄</h3>
      <p>側邊導航 + 主內容</p>
    </div>
  </div>
</div>
```

不需要 `<html>`、CSS、`<script>`。Server 全部提供。

## 可用 CSS Class

| Class | 用途 |
|-------|------|
| `.options` > `.option[data-choice]` | A/B/C 選擇（加 `data-multiselect` 允許多選） |
| `.cards` > `.card[data-choice]` | 視覺設計卡片 |
| `.mockup` > `.mockup-header` + `.mockup-body` | Mockup 容器 |
| `.split` | 並排比較（兩欄） |
| `.pros-cons` > `.pros` + `.cons` | 優缺點比較 |
| `.mock-nav`, `.mock-sidebar`, `.mock-content` | Wireframe 元素 |
| `.mock-button`, `.mock-input` | 互動元素 mockup |
| `.placeholder` | 佔位區域 |

## Events 格式

使用者點擊選項時，記錄到 `$STATE_DIR/events`（每行一個 JSON）：

```jsonl
{"type":"click","choice":"a","text":"Option A","timestamp":1706000101}
```

推送新畫面時 events 檔案自動清除。

## 關閉

```bash
.kiro/skills/brainstorming/scripts/stop-server.sh $SESSION_DIR
```

使用 `--project-dir` 時，mockup 檔案保留在 `.superpowers/brainstorm/` 供日後參考。
