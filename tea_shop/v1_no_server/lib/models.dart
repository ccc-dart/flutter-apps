class MenuItem {
  final String id;
  final String name;
  final int price;
  final String emoji;

  const MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.emoji,
  });
}

class AddOn {
  final String name;
  final int price;

  const AddOn(this.name, this.price);
}

const sugarOptions = ['無糖', '微糖', '半糖', '少糖', '正常糖'];
const iceOptions = ['去冰', '微冰', '少冰', '正常冰'];
const addOns = [
  AddOn('珍珠', 10),
  AddOn('椰果', 10),
  AddOn('布丁', 15),
  AddOn('仙草', 15),
  AddOn('紅豆', 10),
];

const menuItems = [
  MenuItem(id: 'm01', name: '珍珠奶茶', price: 65, emoji: '🧋'),
  MenuItem(id: 'm02', name: '檸檬紅茶', price: 45, emoji: '🍋'),
  MenuItem(id: 'm03', name: '茉香綠茶', price: 40, emoji: '🍵'),
  MenuItem(id: 'm04', name: '黑糖鮮奶', price: 70, emoji: '🥛'),
  MenuItem(id: 'm05', name: '百香雙響炮', price: 65, emoji: '🥭'),
  MenuItem(id: 'm06', name: '四季春茶', price: 35, emoji: '🌿'),
  MenuItem(id: 'm07', name: '抹茶拿鐵', price: 75, emoji: '🍵'),
  MenuItem(id: 'm08', name: '桃花冰茶', price: 55, emoji: '🌸'),
  MenuItem(id: 'm09', name: '焦糖瑪奇朵', price: 70, emoji: '☕'),
  MenuItem(id: 'm10', name: '冬瓜檸檬', price: 45, emoji: '🍈'),
];

class CartItem {
  final MenuItem item;
  final String sugar;
  final String ice;
  final List<AddOn> addOns;
  int quantity;

  CartItem({
    required this.item,
    required this.sugar,
    required this.ice,
    required this.addOns,
    this.quantity = 1,
  });

  int get unitPrice =>
      item.price + addOns.fold(0, (sum, a) => sum + a.price);

  int get subtotal => unitPrice * quantity;

  String get optionLabel {
    final parts = [sugar, ice];
    if (addOns.isNotEmpty) {
      parts.add(addOns.map((a) => a.name).join('+'));
    }
    return parts.join(' | ');
  }
}

class OrderLine {
  final String name;
  final String optionLabel;
  final int unitPrice;
  final int quantity;

  const OrderLine({
    required this.name,
    required this.optionLabel,
    required this.unitPrice,
    required this.quantity,
  });

  int get subtotal => unitPrice * quantity;

  factory OrderLine.fromCartItem(CartItem c) => OrderLine(
        name: c.item.name,
        optionLabel: c.optionLabel,
        unitPrice: c.unitPrice,
        quantity: c.quantity,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'optionLabel': optionLabel,
        'unitPrice': unitPrice,
        'quantity': quantity,
      };

  factory OrderLine.fromJson(Map<String, dynamic> json) => OrderLine(
        name: json['name'] as String,
        optionLabel: json['optionLabel'] as String,
        unitPrice: json['unitPrice'] as int,
        quantity: json['quantity'] as int,
      );
}

class Order {
  final String orderNo;
  final DateTime time;
  final List<OrderLine> lines;

  const Order({
    required this.orderNo,
    required this.time,
    required this.lines,
  });

  int get total => lines.fold(0, (sum, l) => sum + l.subtotal);

  int get cupCount => lines.fold(0, (sum, l) => sum + l.quantity);

  Map<String, dynamic> toJson() => {
        'orderNo': orderNo,
        'time': time.toIso8601String(),
        'lines': lines.map((l) => l.toJson()).toList(),
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        orderNo: json['orderNo'] as String,
        time: DateTime.parse(json['time'] as String),
        lines: (json['lines'] as List)
            .map((e) => OrderLine.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
