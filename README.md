# Flutter 範例應用集

這個 repo 收集了三個獨立的 Flutter / Dart 範例應用，作為學習 Flutter 與跨平台開發的練習。每個應用都是獨立的專案，**彼此之間沒有共用的 workspace**，必須分別進入各自的資料夾執行 `pub get` 與其他指令。

## 應用總覽

| 應用 | 目錄 | 說明 |
|------|------|------|
| **hello_app** | `hello_app/` | 最基本的 Flutter 計數器範例，適合初次接觸 Flutter |
| **demo_app** | `demo_app/` | Material 元件展示，涵蓋按鈕、輸入、版面、動畫等十大類 |
| **tea_shop** | `tea_shop/` | 泡沫紅茶店 POS 系統，含兩個版本（純本機 / 前後端） |

## 環境需求

- Flutter SDK（含 Dart 3.13+）
- 啟動 `tea_shop` v2 後端需可用的 SQLite 動態函式庫（macOS / Linux 內建，Windows 需自備 `sqlite3.dll`）

```bash
flutter --version
dart --version
```

---

## 1. hello_app

Flutter 新手入門的計數器範例：中央顯示數字，按右下角 `+` 按鈕遞增。用來驗證 Flutter 環境是否安裝成功。

```bash
cd hello_app
flutter pub get
flutter run -d chrome
```

---

## 2. demo_app

以視覺化方式展示常見 Material 元件，首頁列出分類清單，點選後進入對應的示範頁面：

- Buttons 按鈕
- Text & Typography 文字
- Input 輸入元件
- Layout 版面配置
- Card & List 卡片與列表
- Navigation 導覽
- Feedback 訊息回饋
- Progress 進度指示
- Animation 動畫
- Image & Icon 圖片圖示

```bash
cd demo_app
flutter pub get
flutter run -d chrome
```

---

## 3. tea_shop

泡沫紅茶店 POS（銷售櫃檯）系統，包含點餐、結帳與日報表。提供兩個版本：

```
tea_shop/
├── v1_no_server/        純本機版：資料以 shared_preferences 存在裝置端
└── v2_server_sqlite/    前後端版：Dart 後端 + SQLite 集中保存訂單
    ├── tea_shared/        共用資料模型（Dart package）
    ├── tea_shop_server/   後端 API（Dart + shelf + SQLite）
    └── tea_shop/          POS 前端（Flutter）
```

### v1_no_server（純本機）

資料只存在裝置本機（Web 為 `localStorage`），不需後端即可運作，適合單機使用。

```bash
cd tea_shop/v1_no_server
flutter pub get
flutter run -d chrome
```

### v2_server_sqlite（前後端）

由 Dart 後端集中保存訂單，店長可跨裝置檢視營業狀況。`tea_shared` 同時被前端與後端相依，確保兩端的 JSON 格式一致。**完整說明請見 [`tea_shop/v2_server_sqlite/README.md`](tea_shop/v2_server_sqlite/README.md)**（API 契約、環境變數、架構皆在該檔）。

需要開兩個終端機：

```bash
# 終端機 1：啟動後端（環境變數 PORT 預設 8080、DB_PATH 預設 tea_shop.db）
cd tea_shop/v2_server_sqlite/tea_shop_server
dart pub get
dart run bin/server.dart

# 終端機 2：啟動前端
cd tea_shop/v2_server_sqlite/tea_shop
flutter pub get
flutter run -d chrome
```

後端不在 `localhost:8080` 時，用 `--dart-define` 指定：

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://192.168.1.10:8080
```

前端在連不上後端時仍可結帳，訂單以 `L` 開頭編號存在本機（離線備援）。

---

## 執行測試與靜態分析

每個套件的測試與分析都必須在該套件目錄下獨立執行：

```bash
# Flutter 應用
cd hello_app        && flutter test && flutter analyze
cd demo_app         && flutter test && flutter analyze
cd tea_shop/v1_no_server && flutter test && flutter analyze

# tea_shop v2 三個套件各自獨立
cd tea_shop/v2_server_sqlite/tea_shared       && dart test && dart analyze
cd tea_shop/v2_server_sqlite/tea_shop_server  && dart test && dart analyze
cd tea_shop/v2_server_sqlite/tea_shop         && flutter test && flutter analyze
```

後端測試使用記憶體中的 SQLite，**不需先啟動任何伺服器**。

## 建置

前端可建置為靜態網站（以 `tea_shop` v2 為例）：

```bash
cd tea_shop/v2_server_sqlite/tea_shop
flutter build web --dart-define=API_BASE_URL=https://api.your-shop.com
# 產物在 build/web，可部署到任何靜態主機
```

後端可編譯成單一執行檔：

```bash
cd tea_shop/v2_server_sqlite/tea_shop_server
dart compile exe bin/server.dart -o tea_shop_server
PORT=8080 DB_PATH=/data/tea_shop.db ./tea_shop_server
```

## 授權

請見 [`LICENSE`](LICENSE)。
