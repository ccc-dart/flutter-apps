import 'package:tea_shared/tea_shared.dart';
import 'package:tea_shop_server/tea_shop_server.dart';
import 'package:test/test.dart';

void main() {
  late OrderRepository repo;

  setUp(() {
    final db = openDatabase(':memory:');
    repo = OrderRepository(db);
  });

  Order sample(DateTime time, {int qty = 1}) => Order(
        orderNo: repo.nextOrderNo(),
        time: time,
        lines: [
          OrderLine(
            name: '珍珠奶茶',
            optionLabel: '半糖 | 少冰 | 珍珠',
            unitPrice: 75,
            quantity: qty,
          ),
        ],
      );

  test('nextOrderNo increments', () {
    expect(repo.nextOrderNo(), 'A001');
    repo.insert(sample(DateTime(2026, 1, 1)));
    expect(repo.nextOrderNo(), 'A002');
    repo.insert(sample(DateTime(2026, 1, 1)));
    expect(repo.nextOrderNo(), 'A003');
  });

  test('insert stores order with lines and totals', () {
    final order = sample(DateTime(2026, 1, 1, 10, 30), qty: 2);
    repo.insert(order);

    final loaded = repo.listAll();
    expect(loaded.length, 1);
    expect(loaded.first.orderNo, 'A001');
    expect(loaded.first.lines.length, 1);
    expect(loaded.first.total, 150);
    expect(loaded.first.cupCount, 2);
  });

  test('listByDate filters by day', () {
    repo.insert(sample(DateTime(2026, 1, 1, 9)));
    repo.insert(sample(DateTime(2026, 1, 1, 18)));
    repo.insert(sample(DateTime(2026, 1, 2, 12)));

    expect(repo.listByDate(DateTime(2026, 1, 1)).length, 2);
    expect(repo.listByDate(DateTime(2026, 1, 2)).length, 1);
    expect(repo.listByDate(DateTime(2026, 1, 3)), isEmpty);
  });
}
