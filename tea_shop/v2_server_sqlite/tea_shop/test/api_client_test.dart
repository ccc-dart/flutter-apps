import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tea_shop/api_client.dart';
import 'package:tea_shop/models.dart';
import 'package:tea_shop/order_store.dart';

const _json = {'content-type': 'application/json; charset=utf-8'};

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await OrderStore.instance.debugClear();
  });

  test('ApiClient.createOrder sends lines and parses server order', () async {
    late http.Request captured;
    final client = MockClient((req) async {
      captured = req;
      return http.Response(
        jsonEncode({
          'orderNo': 'A001',
          'time': '2026-01-01T10:00:00.000',
          'lines': [
            {
              'name': '珍珠奶茶',
              'optionLabel': '半糖 | 少冰',
              'unitPrice': 75,
              'quantity': 2,
            }
          ],
        }),
        201,
        headers: _json,
      );
    });

    final api = ApiClient(baseUrl: 'http://test', client: client);
    final order = await api.createOrder(const [
      OrderLine(name: '珍珠奶茶', optionLabel: '半糖 | 少冰', unitPrice: 75, quantity: 2),
    ]);

    expect(captured.method, 'POST');
    expect(captured.url.path, '/orders');
    expect(order.orderNo, 'A001');
    expect(order.total, 150);
    expect(order.cupCount, 2);
  });

  test('ApiClient.fetchOrders parses list', () async {
    final client = MockClient((req) async {
      expect(req.url.queryParameters['date'], '2026-01-01');
      return http.Response(
        jsonEncode({
          'orders': [
            {'orderNo': 'A001', 'time': '2026-01-01T10:00:00.000', 'lines': []}
          ],
          'summary': {'revenue': 0, 'cups': 0, 'count': 1},
        }),
        200,
        headers: _json,
      );
    });

    final api = ApiClient(baseUrl: 'http://test', client: client);
    final orders = await api.fetchOrders(date: DateTime(2026, 1, 1));
    expect(orders, hasLength(1));
    expect(orders.single.orderNo, 'A001');
  });

  test('OrderStore.checkout uses server-assigned number when online', () async {
    final client = MockClient((req) async => http.Response(
          jsonEncode({
            'orderNo': 'A042',
            'time': '2026-01-01T10:00:00.000',
            'lines': [
              {
                'name': '珍珠奶茶',
                'optionLabel': '半糖 | 少冰',
                'unitPrice': 75,
                'quantity': 1,
              }
            ],
          }),
          201,
          headers: _json,
        ));
    OrderStore.instance
        .configureApi(ApiClient(baseUrl: 'http://test', client: client));

    final order = await OrderStore.instance.checkout(const [
      OrderLine(name: '珍珠奶茶', optionLabel: '半糖 | 少冰', unitPrice: 75, quantity: 1),
    ]);

    expect(order.orderNo, 'A042');
    expect(OrderStore.instance.online, isTrue);
    expect(OrderStore.instance.orders.single.orderNo, 'A042');
  });

  test('OrderStore.checkout falls back to offline order when server fails',
      () async {
    final client = MockClient((req) async => http.Response('boom', 500));
    OrderStore.instance
        .configureApi(ApiClient(baseUrl: 'http://test', client: client));

    final order = await OrderStore.instance.checkout(const [
      OrderLine(name: '珍珠奶茶', optionLabel: '半糖 | 少冰', unitPrice: 75, quantity: 1),
    ]);

    expect(order.orderNo, startsWith('L'));
    expect(OrderStore.instance.online, isFalse);
    expect(OrderStore.instance.orders.single.orderNo, startsWith('L'));
  });

  test('refreshFromServer keeps local offline orders', () async {
    // 先建立一筆離線訂單
    OrderStore.instance.add(Order(
      orderNo: 'L001',
      time: DateTime(2026, 1, 1, 9),
      lines: const [
        OrderLine(name: '離線茶', optionLabel: '正常糖', unitPrice: 40, quantity: 1),
      ],
    ));

    final client = MockClient((req) async => http.Response(
          jsonEncode({
            'orders': [
              {'orderNo': 'A001', 'time': '2026-01-01T10:00:00.000', 'lines': []}
            ],
            'summary': {'revenue': 0, 'cups': 0, 'count': 1},
          }),
          200,
          headers: _json,
        ));
    OrderStore.instance
        .configureApi(ApiClient(baseUrl: 'http://test', client: client));

    await OrderStore.instance.refreshFromServer();

    final nos = OrderStore.instance.orders.map((o) => o.orderNo).toSet();
    expect(nos, containsAll({'A001', 'L001'}));
  });
}
