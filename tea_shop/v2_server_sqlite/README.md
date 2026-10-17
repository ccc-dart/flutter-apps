# 泡沫紅茶店 POS 系統

一套以 Flutter 打造的泡沫紅茶店 POS（銷售櫃檯）系統，包含點餐、結帳、日報表，並搭配一個 Dart 後端將訂單資料集中保存，讓店長可跨裝置檢視營業狀況。

## 專案結構

本目錄下共有三個彼此關聯的 Dart / Flutter 套件，以及兩個教學用的範例 App：

```
flutter/
├── tea_shared/        共用資料模型（Dart package）
├── tea_shop_server/   後端 API（Dart + shelf + SQLite）
└── tea_shop/          POS 前端（Flutter）
```

### 為什麼拆成共用套件

`tea_shared` 同時被前端（`tea_shop`）與後端（`tea_shop_server`）相依，訂單的 `Order` / `OrderLine` 模型與 `toJson` / `fromJson` 只有一份實作，因此兩端的 JSON 格式永遠一致，不會有對不上的問題。這正是選用 Dart 寫後端的最大好處。

```
┌────────────────┐        HTTP (JSON)        ┌──────────────────┐
│  tea_shop      │  ───────────────────────▶ │  tea_shop_server │
│  (Flutter POS) │  POST /orders             │  shelf + SQLite  │
│                │  GET  /orders?date=...    │                  │
└───────┬────────┘ ◀─────────────────────── └────────┬─────────┘
        │                                             │
        │            ┌────────────────┐               │
        └───────────▶│  tea_shared    │◀──────────────┘
        import       │  Order/Line... │   import
                     └────────────────┘
```

## 環境需求

- Flutter SDK（含 Dart 3.13+）
- 啟動後端需可用的 SQLite 動態函式庫（macOS / Linux 系統內建，Windows 需自備 `sqlite3.dll`）

確認環境：

```bash
flutter --version
dart --version
```

## 快速開始

需要開兩個終端機：一個跑後端，一個跑前端。

### 1. 啟動後端

```bash
cd tea_shop_server
dart pub get
dart run bin/server.dart
```

啟動後會顯示：

```
Tea shop server listening on http://localhost:8080
DB: tea_shop.db
```

可用環境變數調整：

| 變數 | 預設值 | 說明 |
|------|--------|------|
| `PORT` | `8080` | 監聽的埠號 |
| `DB_PATH` | `tea_shop.db` | SQLite 資料庫檔案路徑 |

```bash
PORT=9000 DB_PATH=/data/tea_shop.db dart run bin/server.dart
```

### 2. 啟動 POS 前端（Web）

```bash
cd tea_shop
flutter pub get
flutter run -d chrome
```

若後端不在 `localhost:8080`，用 `--dart-define` 指定：

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://192.168.1.10:8080
```

也可以執行在其他平台：

```bash
flutter run -d macos
flutter run -d windows
```

## 前端功能

- **點餐**：左側菜單 10 種品項（含珍珠奶茶），點選後可選甜度、冰量、加料（珍珠 / 椰果 / 布丁 / 仙草 / 紅豆）與數量。
- **訂單面板**：即時增減數量、顯示每筆小計與合計，可清除整張訂單。
- **結帳**：確認收款後送出訂單，並顯示銷售明細。
- **日報表**：店長可依日期檢視當天所有訂單明細，以及總收入、訂單數、總杯數。
- **連線狀態**：標題列顯示「已連線 / 離線」。
- **離線備援**：連不上後端時仍可結帳，訂單以 `L` 開頭編號存在本機，重新整理後不遺失。

### 響應式版面

- 寬螢幕（>= 800px）：左「菜單」右「訂單」雙欄。
- 窄螢幕：菜單在上、訂單面板在下。

## 後端 API

Base URL 預設 `http://localhost:8080`。所有回應皆為 JSON。

### `GET /health`

健康檢查。

```bash
curl http://localhost:8080/health
# {"status":"ok"}
```

### `POST /orders`

新增一筆訂單。**訂單編號由後端指派**（`A001`、`A002`…）。

請求內容：

```json
{
  "time": "2026-01-01T10:30:00.000",
  "lines": [
    {
      "name": "珍珠奶茶",
      "optionLabel": "半糖 | 少冰 | 珍珠",
      "unitPrice": 75,
      "quantity": 2
    }
  ]
}
```

`time` 可省略，預設為伺服器當下時間。

回應（HTTP 201）：

```json
{
  "orderNo": "A001",
  "time": "2026-01-01T10:30:00.000",
  "lines": [
    {
      "name": "珍珠奶茶",
      "optionLabel": "半糖 | 少冰 | 珍珠",
      "unitPrice": 75,
      "quantity": 2
    }
  ]
}
```

```bash
curl -X POST http://localhost:8080/orders \
  -H 'Content-Type: application/json' \
  -d '{"lines":[{"name":"珍珠奶茶","optionLabel":"半糖 | 少冰","unitPrice":75,"quantity":2}]}'
```

### `GET /orders?date=YYYY-MM-DD`

查詢訂單與當日彙總。省略 `date` 則回傳所有訂單。

```bash
curl "http://localhost:8080/orders?date=2026-01-01"
```

```json
{
  "orders": [ { "orderNo": "A001", "time": "...", "lines": [ ... ] } ],
  "summary": { "revenue": 150, "cups": 2, "count": 1 }
}
```

| 欄位 | 說明 |
|------|------|
| `revenue` | 當日總收入 |
| `cups` | 當日總杯數 |
| `count` | 當日訂單筆數 |

錯誤回應為 HTTP 400，格式 `{"error":"..."}`。

## 資料儲存

- **後端（權威來源）**：SQLite 檔案，資料表 `orders` 與 `order_lines`，重啟後資料保留、訂單編號會續編。
- **前端（快取 / 離線）**：`shared_preferences`（Web 為 `localStorage`）。
- **同步策略**：前端啟動與開啟日報表時向後端拉取；結帳優先送後端，失敗則建立離線訂單。離線訂單（`L` 前綴）在同步後仍會保留於本機。

> 注意：離線建立的 `L` 訂單目前**不會自動補送至後端**（尚無 outbox 機制）。

## 執行測試

三個套件各自獨立：

```bash
# 共用模型
cd tea_shared && dart test

# 後端（repository + API）
cd tea_shop_server && dart test

# 前端（模型、ApiClient、OrderStore、日報表 UI）
cd tea_shop && flutter test
```

靜態分析：

```bash
cd tea_shared && dart analyze
cd tea_shop_server && dart analyze
cd tea_shop && flutter analyze
```

## 建置部署

前端建置為靜態網站：

```bash
cd tea_shop
flutter build web --dart-define=API_BASE_URL=https://api.your-shop.com
# 產物在 tea_shop/build/web，可部署到任何靜態主機
```

後端可編譯成單一執行檔（需目標平台 SDK）：

```bash
cd tea_shop_server
dart compile exe bin/server.dart -o tea_shop_server
PORT=8080 DB_PATH=/data/tea_shop.db ./tea_shop_server
```

## 其他範例 App

| 專案 | 說明 | 執行 |
|------|------|------|
| `hello_app` | 最基本的計數器範例 | `cd hello_app && flutter run -d chrome` |
| `demo_app` | 各類 Material 視覺化元件展示（按鈕、輸入、版面、動畫等） | `cd demo_app && flutter run -d chrome` |
