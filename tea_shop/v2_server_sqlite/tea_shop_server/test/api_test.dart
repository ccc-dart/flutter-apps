import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:tea_shop_server/tea_shop_server.dart';
import 'package:test/test.dart';

void main() {
  late OrderRepository repo;
  late Handler handler;

  setUp(() {
    final db = openDatabase(':memory:');
    repo = OrderRepository(db);
    handler = createApi(repo);
  });

  Future<Response> send(String method, String path, {Object? body}) async {
    final request = Request(
      method,
      Uri.parse('http://localhost$path'),
      body: body == null ? null : jsonEncode(body),
      headers: body == null ? null : {'content-type': 'application/json'},
    );
    return await handler(request);
  }

  test('GET /health returns ok', () async {
    final res = await send('GET', '/health');
    expect(res.statusCode, 200);
    expect(jsonDecode(await res.readAsString()), {'status': 'ok'});
  });

  test('POST /orders creates order and returns 201 with assigned number',
      () async {
    final res = await send('POST', '/orders', body: {
      'time': '2026-01-01T10:30:00.000',
      'lines': [
        {
          'name': '珍珠奶茶',
          'optionLabel': '半糖 | 少冰 | 珍珠',
          'unitPrice': 75,
          'quantity': 2,
        }
      ],
    });
    expect(res.statusCode, 201);
    final json = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
    expect(json['orderNo'], 'A001');
    expect(json['lines'], hasLength(1));
  });

  test('POST /orders rejects empty lines', () async {
    final res = await send('POST', '/orders', body: {'lines': []});
    expect(res.statusCode, 400);
  });

  test('GET /orders?date returns orders with summary', () async {
    // A001 與 A002 為同一天，A003 為隔天
    await send('POST', '/orders', body: {
      'time': '2026-01-01T10:00:00.000',
      'lines': [
        {'name': '珍珠奶茶', 'optionLabel': '半糖 | 少冰', 'unitPrice': 75, 'quantity': 2}
      ],
    });
    await send('POST', '/orders', body: {
      'time': '2026-01-01T15:00:00.000',
      'lines': [
        {'name': '檸檬紅茶', 'optionLabel': '正常糖 | 正常冰', 'unitPrice': 45, 'quantity': 1}
      ],
    });
    await send('POST', '/orders', body: {
      'time': '2026-01-02T09:00:00.000',
      'lines': [
        {'name': '茉香綠茶', 'optionLabel': '無糖 | 去冰', 'unitPrice': 40, 'quantity': 1}
      ],
    });

    final res = await send('GET', '/orders?date=2026-01-01');
    expect(res.statusCode, 200);
    final json = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
    final orders = json['orders'] as List;
    final summary = json['summary'] as Map<String, dynamic>;

    expect(orders, hasLength(2));
    expect(summary['revenue'], 75 * 2 + 45);
    expect(summary['cups'], 3);
    expect(summary['count'], 2);
  });

  test('CORS headers are present', () async {
    final res = await send('GET', '/health');
    expect(res.headers['access-control-allow-origin'], '*');
  });
}
