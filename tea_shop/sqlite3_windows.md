# Windows 上的 sqlite3.dll 設定

`tea_shop_server` 使用 [`sqlite3`](https://pub.dev/packages/sqlite3) 套件，在 Windows 上它會呼叫 `DynamicLibrary.open('sqlite3.dll')`。這個 DLL **不會自動附帶**，需要自行準備並放到 Windows 找得到的位置。

macOS / Linux 通常已內建 SQLite，不需額外處理；本文件只談 Windows。

## 1. 取得 sqlite3.dll

1. 前往官方下載頁：<https://www.sqlite.org/download.html>
2. 在 **Precompiled Binaries for Windows** 區塊下載：
   - 64 位元系統：`sqlite-dll-win-x64-*.zip`
   - 32 位元系統：`sqlite-dll-win-x86-*.zip`
3. 解壓縮，取出裡面的 `sqlite3.dll`。

> 也可從 GitHub Actions 的建置產物、或 `sqlite3_flutter_libs` 套件中取得相容版本。

## 2. 放到哪裡

Windows 的 DLL 搜尋順序為：

1. **執行檔所在目錄**
2. 系統目錄（`C:\Windows\System32` 等）
3. **目前工作目錄**
4. `PATH` 環境變數中的目錄

只要 `sqlite3.dll` 落在上述任一處即可。以下依使用情境說明。

### A. 開發時（`dart run bin/server.dart`）

在**專案根目錄**放 `sqlite3.dll`（因為此時工作目錄就是那裡）：

```
tea_shop_server/
├── bin/
│   └── server.dart
├── lib/
├── sqlite3.dll        ← 放這裡
└── pubspec.yaml
```

```powershell
cd tea_shop_server
dart pub get
dart run bin/server.dart
```

若想放其他資料夾，把它加入 `PATH`（對當前 PowerShell 工作階段有效）：

```powershell
$env:PATH = "C:\tools\sqlite;" + $env:PATH
dart run bin/server.dart
```

永久加入 PATH（需重開終端機）：

```powershell
[Environment]::SetEnvironmentVariable(
  "PATH",
  $env:PATH + ";C:\tools\sqlite",
  "User"
)
```

### B. 編譯成執行檔發佈（`dart compile exe`）

編譯後，`sqlite3.dll` 必須和 `.exe` **放在同一個資料夾**：

```powershell
cd tea_shop_server
dart compile exe bin/server.dart -o dist\tea_shop_server.exe
copy C:\path\to\sqlite3.dll dist\
.\dist\tea_shop_server.exe
```

目錄結構：

```
dist\
├── tea_shop_server.exe
└── sqlite3.dll        ← 必須和 exe 同層
```

不要把 DLL 綁進 exe（`dart compile exe` 產物是單一檔案，不會打包外部原生函式庫），部署時一併複製即可。

## 3. 進階：用程式碼指定路徑

若想自行控制載入位置（例如 DLL 放在子目錄），可用 `sqlite3/open.dart` 的 `overrideFor` 覆寫載入邏輯。在 `bin/server.dart` 最前面加入：

```dart
import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/open.dart';

Future<void> main(List<String> args) async {
  if (Platform.isWindows) {
    // 以執行檔所在目錄為基準，避免使用者從別的目錄啟動時找不到。
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    open.overrideFor(
      OperatingSystem.windows,
      () => DynamicLibrary.open('$exeDir\\sqlite3.dll'),
    );
  }

  // ...原本的啟動程式碼
}
```

重點：

- 一定要**在第一次使用 sqlite3 之前**呼叫 `overrideFor`，否則無效。
- 用 `Platform.resolvedExecutable`（執行檔目錄），不要用 `Directory.current`（會隨啟動位置改變）。
- 路徑含目錄時會**原樣**交給動態載入器，不會再自動補 `sqlite3.dll` 名稱。

## 4. 替代方案：使用 Windows 內建的 winsqlite3.dll

Windows 10 之後內建 `winsqlite3.dll`，可完全不附帶檔案：

```dart
import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/open.dart';

void main() async {
  if (Platform.isWindows) {
    open.overrideFor(
      OperatingSystem.windows,
      () => DynamicLibrary.open('winsqlite3.dll'),
    );
  }
  // ...
}
```

注意：

- 內建版本通常比官方最新版舊，某些功能或 extension 可能不支援。
- 功能齊全度與一致性考量下，**建議正式環境仍自帶官方 `sqlite3.dll`**。

## 5. 疑難排解

**`Failed to load dynamic library 'sqlite3.dll'` / `Invalid argument(s): Couldn't resolve native function`**

- 確認 `sqlite3.dll` 的**位元數**和執行環境一致（64 位元 Dart 配 64 位元 DLL）。
- 確認檔案真的在搜尋路徑中：執行檔目錄、工作目錄或 PATH。
- 用 `where.exe sqlite3.dll` 檢查 Windows 實際找到哪一個：

  ```powershell
  where.exe sqlite3.dll
  ```

**`The method 'open' was called on null`**

- 表示載入 sqlite3 失敗。優先檢查 DLL 是否放對位置與位元數。

**從別的目錄啟動就失敗**

- 改用「程式碼指定路徑」搭配 `Platform.resolvedExecutable`（見第 3 節）。

---

相關文件：專案總覽請見 [`README.md`](README.md)。
