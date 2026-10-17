import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tea_shared/tea_shared.dart';

/// 與 tea_shop_server 溝通的 REST client。
class ApiClient {
  /// 預設 server 位址。可用 `--dart-define=API_BASE_URL=...` 覆寫。
  static const defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  final String baseUrl;
  final http.Client _client;

  ApiClient({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? defaultBaseUrl,
        _client = client ?? http.Client();

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  /// POST 新訂單，server 會指派訂單編號並回傳完整訂單。
  Future<Order> createOrder(List<OrderLine> lines) async {
    final res = await _client.post(
      _uri('/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'time': DateTime.now().toIso8601String(),
        'lines': lines.map((l) => l.toJson()).toList(),
      }),
    );
    if (res.statusCode != 201) {
      throw ApiException('建立訂單失敗 (${res.statusCode})');
    }
    return Order.fromJson(_decode(res.bodyBytes));
  }

  /// 查詢訂單；傳入 [date] 只取當天。
  Future<List<Order>> fetchOrders({DateTime? date}) async {
    final query = <String, String>{};
    if (date != null) query['date'] = _formatDate(date);
    final res = await _client.get(_uri('/orders', query.isEmpty ? null : query));
    if (res.statusCode != 200) {
      throw ApiException('取得訂單失敗 (${res.statusCode})');
    }
    final json = _decode(res.bodyBytes);
    final list = json['orders'] as List<dynamic>;
    return list
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 健康檢查。
  Future<bool> health() async {
    try {
      final res = await _client.get(_uri('/health'));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _decode(List<int> bytes) =>
      jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;

  static String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  void dispose() => _client.close();
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
