import 'package:tea_shared/tea_shared.dart';
import 'package:test/test.dart';

void main() {
  test('menu has 10 items including pearl milk tea', () {
    expect(menuItems.length, 10);
    expect(menuItems.any((m) => m.name == '珍珠奶茶'), isTrue);
  });

  test('order round-trips through JSON', () {
    final order = Order(
      orderNo: 'A001',
      time: DateTime(2026, 1, 2, 13, 30),
      lines: const [
        OrderLine(
            name: '珍珠奶茶', optionLabel: '半糖 | 少冰 | 珍珠', unitPrice: 75, quantity: 2),
        OrderLine(name: '檸檬紅茶', optionLabel: '正常糖 | 正常冰', unitPrice: 45, quantity: 1),
      ],
    );

    final restored = Order.fromJson(order.toJson());

    expect(restored.orderNo, 'A001');
    expect(restored.time, order.time);
    expect(restored.lines.length, 2);
    expect(restored.total, 75 * 2 + 45);
    expect(restored.cupCount, 3);
  });
}
