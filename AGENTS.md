# AGENTS.md

Collection of independent Flutter/Dart sample apps. **The repo root is not a Flutter/Dart project** — there is no root `pubspec.yaml`, workspace, Makefile, or CI. Every command must be run from inside the target package directory (`flutter pub get` / `dart pub get` per package; no shared resolution).

## Packages

| Path | Kind | Notes |
|------|------|-------|
| `hello_app/` | Flutter app | Minimal counter sample |
| `demo_app/` | Flutter app | Material widget showcase |
| `tea_shop/v1_no_server/` | Flutter app | POS, local-only via `shared_preferences` |
| `tea_shop/v2_server_sqlite/tea_shared/` | Dart pkg | Shared `Order`/`OrderLine` + JSON models |
| `tea_shop/v2_server_sqlite/tea_shop_server/` | Dart pkg | `shelf` + `sqlite3` JSON API backend |
| `tea_shop/v2_server_sqlite/tea_shop/` | Flutter app | POS client; depends on `tea_shared` via path |

`tea_shop/v2_server_sqlite/` is the full-stack reference app. **`tea_shop/v2_server_sqlite/README.md` is the authoritative documentation (Chinese)** — API contract, env vars, and architecture all live there. Read it before touching v2. UI strings, comments, and docs are Chinese; match that.

## Running

```bash
# Backend (tea_shop_server): env PORT (default 8080), DB_PATH (default tea_shop.db)
cd tea_shop/v2_server_sqlite/tea_shop_server && dart run bin/server.dart

# Frontend (tea_shop): points at the backend; override with --dart-define
cd tea_shop/v2_server_sqlite/tea_shop && flutter run -d chrome \
  --dart-define=API_BASE_URL=http://192.168.1.10:8080
```

Default API base URL is `http://localhost:8080` (`tea_shop/lib/api_client.dart`). The app tolerates an unreachable backend (offline `L`-prefixed orders).

## Tests & analysis (per package, no prerequisites)

```bash
cd <pkg> && flutter test            # Flutter apps
cd <pkg> && dart test               # tea_shared, tea_shop_server
cd <pkg> && flutter analyze / dart analyze
```

Server tests open an in-memory SQLite DB, so **no running server is required**. Single test: `dart test test/order_repository_test.dart` or `flutter test test/widget_test.dart`, add `-n "<name>"` to filter.

## Gotchas

- `tea_shop/v2_server_sqlite/tea_shop_server/tea_shop.db` is **git-tracked**; running the server mutates it. Don't commit incidental order data.
- `tea_shared` is a path dependency of both `tea_shop` and `tea_shop_server` — edit the model once and both sides stay in sync.
- Adding a dependency/plugin requires re-running `pub get` in the affected package only.
- `session-ses_eb73.md` at root is a committed OpenCode session log, not source — leave it alone unless asked.
- SDK constraint is `^3.13.5`. Lints: `flutter_lints` (Flutter apps), `lints` (Dart packages), configured per-package in `analysis_options.yaml`.
