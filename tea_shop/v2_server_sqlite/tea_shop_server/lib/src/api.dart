import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:tea_shared/tea_shared.dart';

import 'order_repository.dart';

const _jsonHeaders = {'Content-Type': 'application/json; charset=utf-8'};

/// 建立 REST API handler。
///
/// - `GET  /health`             健康檢查
/// - `POST /orders`             新增訂單（server 指派訂單編號）
/// - `GET  /orders?date=YYYY-MM-DD`  查詢訂單與當日彙總
Handler createApi(OrderRepository repo) {
  final router = Router()
    ..get('/health', (Request request) {
      return Response.ok(
        jsonEncode({'status': 'ok'}),
        headers: _jsonHeaders,
      );
    })
    ..get('/orders', (Request request) {
      final dateParam = request.url.queryParameters['date'];
      final List<Order> orders;
      if (dateParam != null && dateParam.isNotEmpty) {
        final date = DateTime.tryParse(dateParam);
        if (date == null) {
          return _badRequest('date 格式錯誤，需為 YYYY-MM-DD');
        }
        orders = repo.listByDate(date);
      } else {
        orders = repo.listAll();
      }
      return Response.ok(
        jsonEncode(_ordersPayload(orders)),
        headers: _jsonHeaders,
      );
    })
    ..post('/orders', (Request request) async {
      final body = await request.readAsString();
      final Map<String, dynamic> json;
      try {
        json = jsonDecode(body) as Map<String, dynamic>;
      } catch (_) {
        return _badRequest('無法解析 JSON');
      }

      final linesJson = json['lines'];
      if (linesJson is! List || linesJson.isEmpty) {
        return _badRequest('lines 不可為空');
      }

      final List<OrderLine> lines;
      try {
        lines = linesJson
            .map((e) => OrderLine.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return _badRequest('lines 欄位格式錯誤');
      }

      final DateTime time;
      final timeStr = json['time'];
      if (timeStr is String && timeStr.isNotEmpty) {
        final parsed = DateTime.tryParse(timeStr);
        if (parsed == null) return _badRequest('time 格式錯誤');
        time = parsed;
      } else {
        time = DateTime.now();
      }

      final order = Order(
        orderNo: repo.nextOrderNo(),
        time: time,
        lines: lines,
      );
      repo.insert(order);

      return Response(
        201,
        body: jsonEncode(order.toJson()),
        headers: _jsonHeaders,
      );
    });

  return const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_cors())
      .addHandler(router.call);
}

Map<String, dynamic> _ordersPayload(List<Order> orders) {
  final revenue = orders.fold(0, (sum, o) => sum + o.total);
  final cups = orders.fold(0, (sum, o) => sum + o.cupCount);
  return {
    'orders': orders.map((o) => o.toJson()).toList(),
    'summary': {
      'revenue': revenue,
      'cups': cups,
      'count': orders.length,
    },
  };
}

Response _badRequest(String message) => Response(
      400,
      body: jsonEncode({'error': message}),
      headers: _jsonHeaders,
    );

/// 允許跨來源請求（Flutter web 開發時需要）。
Middleware _cors() {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
  };
  return (Handler inner) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: corsHeaders);
      }
      final response = await inner(request);
      return response.change(headers: corsHeaders);
    };
  };
}
