import 'package:sqlite3/sqlite3.dart';

/// 開啟（或建立）SQLite 資料庫並套用 schema。
///
/// [path] 傳 `':memory:'` 可建立記憶體資料庫（測試用）。
Database openDatabase(String path) {
  final Database db;
  if (path == ':memory:') {
    db = sqlite3.openInMemory();
  } else {
    db = sqlite3.open(path);
  }
  db.execute('PRAGMA foreign_keys = ON;');
  _migrate(db);
  return db;
}

void _migrate(Database db) {
  db.execute('''
    CREATE TABLE IF NOT EXISTS orders (
      order_no   TEXT PRIMARY KEY,
      time       TEXT NOT NULL,
      total      INTEGER NOT NULL,
      cup_count  INTEGER NOT NULL
    );
  ''');
  db.execute('''
    CREATE TABLE IF NOT EXISTS order_lines (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      order_no      TEXT NOT NULL REFERENCES orders(order_no) ON DELETE CASCADE,
      name          TEXT NOT NULL,
      option_label  TEXT NOT NULL,
      unit_price    INTEGER NOT NULL,
      quantity      INTEGER NOT NULL
    );
  ''');
  db.execute(
    'CREATE INDEX IF NOT EXISTS idx_orders_time ON orders(time);',
  );
  db.execute(
    'CREATE INDEX IF NOT EXISTS idx_lines_order ON order_lines(order_no);',
  );
}
