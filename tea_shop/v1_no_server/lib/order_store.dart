import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

const _kOrdersKey = 'tea_shop_orders_v1';

/// 當日訂單儲存（單例）。
/// 結帳成功後寫入，日報表頁面讀取。
/// 資料以 JSON 存於 SharedPreferences，跨重啟保留。
class OrderStore extends ChangeNotifier {
  OrderStore._();

  static final OrderStore instance = OrderStore._();

  final List<Order> _orders = [];
  bool _loaded = false;

  List<Order> get orders => List.unmodifiable(_orders);

  /// 應用啟動時呼叫，載入已保存的訂單。
  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kOrdersKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _orders
            .addAll(list.map((e) => Order.fromJson(e as Map<String, dynamic>)));
      } catch (_) {
        // 資料毀損時忽略，從空白開始。
      }
    }
    _loaded = true;
    notifyListeners();
  }

  void add(Order order) {
    _orders.add(order);
    notifyListeners();
    _pendingSave = _save();
  }

  Future<void>? _pendingSave;

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_orders.map((o) => o.toJson()).toList());
    await prefs.setString(_kOrdersKey, raw);
  }

  /// 重新從 SharedPreferences 載入（用於測試模擬重啟）。
  Future<void> reload() async {
    await _pendingSave;
    _orders.clear();
    _loaded = false;
    await load();
  }

  /// 取指定日期的訂單（依日期部分比對）。
  List<Order> ordersForDate(DateTime date) {
    return _orders
        .where((o) =>
            o.time.year == date.year &&
            o.time.month == date.month &&
            o.time.day == date.day)
        .toList();
  }

  /// 取指定日期的總收入。
  int revenueForDate(DateTime date) {
    return ordersForDate(date).fold(0, (sum, o) => sum + o.total);
  }

  /// 取指定日期的總杯數。
  int cupsForDate(DateTime date) {
    return ordersForDate(date).fold(0, (sum, o) => sum + o.cupCount);
  }

  /// 下一個訂單編號（依目前已存在的最大號續編）。
  String nextOrderNo() {
    var maxSeq = 0;
    for (final o in _orders) {
      final match = RegExp(r'^A(\d+)$').firstMatch(o.orderNo);
      if (match != null) {
        final n = int.tryParse(match.group(1)!) ?? 0;
        if (n > maxSeq) maxSeq = n;
      }
    }
    return 'A${(maxSeq + 1).toString().padLeft(3, '0')}';
  }

  /// 僅供測試使用：清空所有訂單（含已保存資料）。
  @visibleForTesting
  Future<void> debugClear() async {
    _orders.clear();
    _loaded = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kOrdersKey);
  }
}
