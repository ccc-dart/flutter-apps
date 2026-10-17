import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';
import 'models.dart';

const _kOrdersKey = 'tea_shop_orders_v1';

/// 訂單儲存（單例）。
///
/// 線上優先用 server（tea_shop_server）為權威來源；無法連線時退回本機
/// SharedPreferences 快取與離線訂單（編號前綴 `L`），確保 POS 不中斷。
class OrderStore extends ChangeNotifier {
  OrderStore._();

  static final OrderStore instance = OrderStore._();

  ApiClient? _api;
  final List<Order> _orders = [];
  bool _loaded = false;
  bool _online = false;
  Future<void>? _pendingSave;

  List<Order> get orders => List.unmodifiable(_orders);

  /// 目前是否與 server 連線正常。
  bool get online => _online;

  /// 注入 API client（測試或自訂 server 位址時使用）。
  void configureApi(ApiClient? api) {
    _api = api;
  }

  /// 應用啟動時呼叫：先載入本機快取，再嘗試同步 server。
  Future<void> load() async {
    if (_loaded) return;
    await _loadLocal();
    _loaded = true;
    notifyListeners();
    await refreshFromServer();
  }

  /// 從 server 重新拉取所有訂單（若可連線）。
  /// 本機離線訂單（`L` 前綴）會保留，不會被覆蓋。
  Future<void> refreshFromServer() async {
    final api = _api;
    if (api == null) return;
    try {
      final remote = await api.fetchOrders();
      final remoteNos = remote.map((o) => o.orderNo).toSet();
      final offline = _orders
          .where((o) =>
              o.orderNo.startsWith('L') && !remoteNos.contains(o.orderNo))
          .toList();
      _orders
        ..clear()
        ..addAll(remote)
        ..addAll(offline);
      _online = true;
      await _saveLocal();
    } catch (_) {
      _online = false;
    }
    notifyListeners();
  }

  /// 結帳：優先送 server（由 server 指派訂單編號）；
  /// 連線失敗則建立離線訂單，仍可完成交易。
  Future<Order> checkout(List<OrderLine> lines) async {
    Order order;
    final api = _api;
    if (api != null) {
      try {
        order = await api.createOrder(lines);
        _online = true;
      } catch (_) {
        _online = false;
        order = Order(
          orderNo: _nextOfflineOrderNo(),
          time: DateTime.now(),
          lines: lines,
        );
      }
    } else {
      order = Order(
        orderNo: _nextOfflineOrderNo(),
        time: DateTime.now(),
        lines: lines,
      );
    }
    _orders.add(order);
    notifyListeners();
    _pendingSave = _saveLocal();
    return order;
  }

  /// 直接加入一筆訂單（測試／離線情境使用）。
  void add(Order order) {
    _orders.add(order);
    notifyListeners();
    _pendingSave = _saveLocal();
  }

  Future<void> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kOrdersKey);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _orders
          .addAll(list.map((e) => Order.fromJson(e as Map<String, dynamic>)));
    } catch (_) {
      // 資料毀損時忽略，從空白開始。
    }
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_orders.map((o) => o.toJson()).toList());
    await prefs.setString(_kOrdersKey, raw);
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

  /// 線上下一個訂單編號（僅用於無 server 時）。
  String nextOrderNo() {
    var maxSeq = 0;
    final re = RegExp(r'^A(\d+)$');
    for (final o in _orders) {
      final match = re.firstMatch(o.orderNo);
      if (match != null) {
        final n = int.tryParse(match.group(1)!) ?? 0;
        if (n > maxSeq) maxSeq = n;
      }
    }
    return 'A${(maxSeq + 1).toString().padLeft(3, '0')}';
  }

  /// 離線訂單編號（前綴 `L`，避免與 server 的 `A` 編號衝突）。
  String _nextOfflineOrderNo() {
    var maxSeq = 0;
    final re = RegExp(r'^L(\d+)$');
    for (final o in _orders) {
      final match = re.firstMatch(o.orderNo);
      if (match != null) {
        final n = int.tryParse(match.group(1)!) ?? 0;
        if (n > maxSeq) maxSeq = n;
      }
    }
    return 'L${(maxSeq + 1).toString().padLeft(3, '0')}';
  }

  /// 重新載入（用於測試模擬重啟）。
  Future<void> reload() async {
    await _pendingSave;
    _orders.clear();
    _loaded = false;
    await load();
  }

  /// 僅供測試使用：清空所有訂單（含已保存資料）。
  @visibleForTesting
  Future<void> debugClear() async {
    _orders.clear();
    _loaded = false;
    _api = null;
    _online = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kOrdersKey);
  }
}
