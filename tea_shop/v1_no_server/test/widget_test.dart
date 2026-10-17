import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tea_shop/daily_report_page.dart';
import 'package:tea_shop/main.dart';
import 'package:tea_shop/models.dart';
import 'package:tea_shop/order_store.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await OrderStore.instance.debugClear();
  });

  testWidgets('POS shows 10 menu items and cart panel', (tester) async {
    tester.view.physicalSize = const Size(1920, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const TeaShopApp());

    expect(find.text('泡沫紅茶店 POS'), findsOneWidget);
    for (final item in menuItems) {
      expect(find.text(item.name), findsOneWidget);
    }
    expect(find.text('結帳'), findsOneWidget);
    expect(find.text('尚無品項\n點左側菜單開始點餐'), findsOneWidget);
  });

  test('menu has exactly 10 items including pearl milk tea', () {
    expect(menuItems.length, 10);
    expect(menuItems.any((m) => m.name == '珍珠奶茶'), isTrue);
  });

  test('cart item price includes add-ons', () {
    final item = menuItems.first;
    final cartItem = CartItem(
      item: item,
      sugar: '半糖',
      ice: '少冰',
      addOns: const [AddOn('珍珠', 10), AddOn('布丁', 15)],
      quantity: 2,
    );
    expect(cartItem.unitPrice, item.price + 25);
    expect(cartItem.subtotal, (item.price + 25) * 2);
  });

  test('order store aggregates revenue and cups per day', () {
    final today = DateTime.now();
    OrderStore.instance.add(Order(
      orderNo: 'A001',
      time: today,
      lines: [
        const OrderLine(
            name: '珍珠奶茶', optionLabel: '半糖 | 少冰', unitPrice: 75, quantity: 2),
      ],
    ));
    OrderStore.instance.add(Order(
      orderNo: 'A002',
      time: today,
      lines: [
        const OrderLine(
            name: '檸檬紅茶', optionLabel: '正常糖 | 正常冰', unitPrice: 45, quantity: 1),
      ],
    ));

    expect(OrderStore.instance.ordersForDate(today).length, 2);
    expect(OrderStore.instance.revenueForDate(today), 75 * 2 + 45);
    expect(OrderStore.instance.cupsForDate(today), 3);
    // 昨天沒有訂單
    final yesterday = today.subtract(const Duration(days: 1));
    expect(OrderStore.instance.ordersForDate(yesterday), isEmpty);
    expect(OrderStore.instance.revenueForDate(yesterday), 0);
  });

  test('next order number continues from existing max', () {
    expect(OrderStore.instance.nextOrderNo(), 'A001');
    OrderStore.instance.add(Order(
      orderNo: 'A007',
      time: DateTime.now(),
      lines: const [
        OrderLine(
            name: '珍珠奶茶', optionLabel: '半糖 | 少冰', unitPrice: 65, quantity: 1),
      ],
    ));
    expect(OrderStore.instance.nextOrderNo(), 'A008');
  });

  test('orders persist and reload after restart', () async {
    final today = DateTime.now();
    OrderStore.instance.add(Order(
      orderNo: 'A001',
      time: today,
      lines: const [
        OrderLine(
            name: '黑糖鮮奶', optionLabel: '正常糖 | 正常冰', unitPrice: 70, quantity: 2),
      ],
    ));
    // 等待非同步寫入 SharedPreferences 完成
    await Future<void>.delayed(Duration.zero);

    // 模擬重啟：新的 store 實例載入已保存資料
    await OrderStore.instance.reload();
    expect(OrderStore.instance.orders.length, 1);
    expect(OrderStore.instance.ordersForDate(today).first.orderNo, 'A001');
    expect(OrderStore.instance.revenueForDate(today), 140);
  });

  testWidgets('daily report shows revenue and order details', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final today = DateTime.now();
    OrderStore.instance.add(Order(
      orderNo: 'A001',
      time: today,
      lines: [
        const OrderLine(
            name: '珍珠奶茶', optionLabel: '半糖 | 少冰 | 珍珠', unitPrice: 75, quantity: 2),
      ],
    ));

    await tester.pumpWidget(const MaterialApp(home: DailyReportPage()));

    expect(find.text('日報表'), findsOneWidget);
    expect(find.text('總收入'), findsOneWidget);
    expect(find.text('\$150'), findsWidgets); // 摘要卡 + 訂單頭 + 明細各一處
    expect(find.text('A001'), findsOneWidget);
    expect(find.text('2x 珍珠奶茶'), findsOneWidget);
  });
}
