import 'package:sqlite3/sqlite3.dart';
import 'package:tea_shared/tea_shared.dart';

/// 訂單資料存取層（SQLite）。
class OrderRepository {
  final Database _db;

  OrderRepository(this._db);

  /// 產生下一個訂單編號（例如 A001）。
  String nextOrderNo() {
    final rows = _db.select(
      "SELECT order_no FROM orders WHERE order_no GLOB 'A[0-9]*'",
    );
    var maxSeq = 0;
    final re = RegExp(r'^A(\d+)$');
    for (final row in rows) {
      final match = re.firstMatch(row['order_no'] as String);
      if (match != null) {
        final n = int.tryParse(match.group(1)!) ?? 0;
        if (n > maxSeq) maxSeq = n;
      }
    }
    return 'A${(maxSeq + 1).toString().padLeft(3, '0')}';
  }

  /// 新增一筆訂單（含明細），使用交易確保一致性。
  void insert(Order order) {
    _db.execute('BEGIN;');
    try {
      _db.execute(
        'INSERT INTO orders (order_no, time, total, cup_count) VALUES (?, ?, ?, ?);',
        [
          order.orderNo,
          order.time.toIso8601String(),
          order.total,
          order.cupCount,
        ],
      );
      for (final line in order.lines) {
        _db.execute(
          'INSERT INTO order_lines '
          '(order_no, name, option_label, unit_price, quantity) '
          'VALUES (?, ?, ?, ?, ?);',
          [
            order.orderNo,
            line.name,
            line.optionLabel,
            line.unitPrice,
            line.quantity,
          ],
        );
      }
      _db.execute('COMMIT;');
    } catch (_) {
      _db.execute('ROLLBACK;');
      rethrow;
    }
  }

  /// 取指定日期（本地時間 YYYY-MM-DD）的訂單。
  List<Order> listByDate(DateTime date) {
    final day = _formatDay(date);
    final rows = _db.select(
      "SELECT order_no, time FROM orders "
      "WHERE substr(time, 1, 10) = ? ORDER BY time;",
      [day],
    );
    return rows.map(_loadOrder).toList();
  }

  /// 取所有訂單（新到舊）。
  List<Order> listAll() {
    final rows = _db.select(
      "SELECT order_no, time FROM orders ORDER BY time DESC;",
    );
    return rows.map(_loadOrder).toList();
  }

  Order _loadOrder(Row row) {
    final orderNo = row['order_no'] as String;
    final time = DateTime.parse(row['time'] as String);
    final lineRows = _db.select(
      'SELECT name, option_label, unit_price, quantity '
      'FROM order_lines WHERE order_no = ? ORDER BY id;',
      [orderNo],
    );
    final lines = lineRows
        .map((r) => OrderLine(
              name: r['name'] as String,
              optionLabel: r['option_label'] as String,
              unitPrice: r['unit_price'] as int,
              quantity: r['quantity'] as int,
            ))
        .toList();
    return Order(orderNo: orderNo, time: time, lines: lines);
  }

  static String _formatDay(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
