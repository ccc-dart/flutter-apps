import 'package:flutter/material.dart';

import 'api_client.dart';
import 'daily_report_page.dart';
import 'models.dart';
import 'order_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  OrderStore.instance.configureApi(ApiClient());
  await OrderStore.instance.load();
  runApp(const TeaShopApp());
}

class TeaShopApp extends StatelessWidget {
  const TeaShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '泡沫紅茶店 POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8D6E63),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const PosPage(),
    );
  }
}

class PosPage extends StatefulWidget {
  const PosPage({super.key});

  @override
  State<PosPage> createState() => _PosPageState();
}

class _PosPageState extends State<PosPage> {
  final List<CartItem> _cart = [];

  int get _total => _cart.fold(0, (sum, item) => sum + item.subtotal);

  void _addToCart(CartItem cartItem) {
    setState(() {
      final existing = _cart.where((c) =>
          c.item.id == cartItem.item.id &&
          c.sugar == cartItem.sugar &&
          c.ice == cartItem.ice &&
          _sameAddOns(c.addOns, cartItem.addOns));
      if (existing.isNotEmpty) {
        existing.first.quantity += cartItem.quantity;
      } else {
        _cart.add(cartItem);
      }
    });
  }

  bool _sameAddOns(List<AddOn> a, List<AddOn> b) {
    if (a.length != b.length) return false;
    final namesA = a.map((e) => e.name).toList()..sort();
    final namesB = b.map((e) => e.name).toList()..sort();
    for (var i = 0; i < namesA.length; i++) {
      if (namesA[i] != namesB[i]) return false;
    }
    return true;
  }

  void _showItemSheet(MenuItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ItemOptionSheet(
        item: item,
        onConfirm: (cartItem) {
          Navigator.pop(context);
          _addToCart(cartItem);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已加入：${item.name}'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  Future<void> _checkout() async {
    if (_cart.isEmpty) return;
    final total = _total;
    final count = _cart.fold(0, (sum, c) => sum + c.quantity);
    final items = List<CartItem>.from(_cart);
    final lines = items.map((c) => OrderLine.fromCartItem(c)).toList();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('結帳確認'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('品項數量：$count 杯'),
            const SizedBox(height: 8),
            Text(
              '應收金額：\$$total',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('請確認收款後按下「確認收款」。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('確認收款'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    _showProcessing(messenger);
    try {
      final order = await OrderStore.instance.checkout(lines);
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      setState(() => _cart.clear());
      _showReceipt(order.orderNo, order.total, count, items);
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(content: Text('結帳失敗：$e')));
    }
  }

  void _showProcessing(ScaffoldMessengerState messenger) {
    messenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('送出訂單中…'),
          ],
        ),
        duration: Duration(minutes: 1),
      ),
    );
  }

  void _showReceipt(
      String orderNo, int total, int count, List<CartItem> items) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('銷售明細'),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('訂單編號：$orderNo'),
              Text('時間：${DateTime.now().toString().substring(0, 16)}'),
              const Divider(),
              for (final c in items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${c.quantity}x ${c.item.name}  \$${c.subtotal}'),
                      Text(
                        '  ${c.optionLabel}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(ctx).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              const Divider(),
              Text(
                '合計 \$total（$count 杯）',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }

  void _clearCart() {
    if (_cart.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清除訂單'),
        content: const Text('確定要清除目前訂單的所有品項嗎？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _cart.clear());
            },
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🧋', style: TextStyle(fontSize: 26)),
            SizedBox(width: 8),
            Text('泡沫紅茶店 POS'),
          ],
        ),
        actions: [
          ListenableBuilder(
            listenable: OrderStore.instance,
            builder: (context, _) {
              final online = OrderStore.instance.online;
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Chip(
                  avatar: Icon(
                    online ? Icons.cloud_done : Icons.cloud_off,
                    size: 18,
                    color: online ? Colors.green : Colors.grey,
                  ),
                  label: Text(online ? '已連線' : '離線'),
                ),
              );
            },
          ),
          IconButton(
            tooltip: '日報表',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DailyReportPage()),
            ),
            icon: const Icon(Icons.insights),
          ),
          IconButton(
            tooltip: '清除訂單',
            onPressed: _clearCart,
            icon: const Icon(Icons.delete_sweep),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 800;
          if (wide) {
            return Row(
              children: [
                Expanded(child: _buildMenuGrid()),
                const VerticalDivider(width: 1),
                SizedBox(width: 360, child: _buildCartPanel()),
              ],
            );
          }
          return Column(
            children: [
              Expanded(child: _buildMenuGrid()),
              const Divider(height: 1),
              SizedBox(height: 320, child: _buildCartPanel()),
            ],
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 左側：菜單
  // -------------------------------------------------------------------------
  Widget _buildMenuGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 0.95,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showItemSheet(item),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.emoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(
                    item.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.price}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // 右側：訂單面板
  // -------------------------------------------------------------------------
  Widget _buildCartPanel() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            '目前訂單（${_cart.fold(0, (s, c) => s + c.quantity)} 杯）',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: _cart.isEmpty
              ? const Center(
                  child: Text(
                    '尚無品項\n點左側菜單開始點餐',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: _cart.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final cartItem = _cart[index];
                    return ListTile(
                      dense: true,
                      title: Text(cartItem.item.name),
                      subtitle: Text(
                        cartItem.optionLabel,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => setState(() {
                              if (cartItem.quantity > 1) {
                                cartItem.quantity--;
                              } else {
                                _cart.removeAt(index);
                              }
                            }),
                          ),
                          Text('${cartItem.quantity}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () =>
                                setState(() => cartItem.quantity++),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '\$${cartItem.subtotal}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('合計', style: TextStyle(fontSize: 18)),
                  Text(
                    '\$$_total',
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _cart.isEmpty ? null : _checkout,
                  icon: const Icon(Icons.payment),
                  label: const Text('結帳', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 品項選項 Bottom Sheet
// ---------------------------------------------------------------------------
class _ItemOptionSheet extends StatefulWidget {
  final MenuItem item;
  final ValueChanged<CartItem> onConfirm;

  const _ItemOptionSheet({required this.item, required this.onConfirm});

  @override
  State<_ItemOptionSheet> createState() => _ItemOptionSheetState();
}

class _ItemOptionSheetState extends State<_ItemOptionSheet> {
  String _sugar = '正常糖';
  String _ice = '少冰';
  final Set<String> _selectedAddOns = {};
  int _quantity = 1;

  int get _unitPrice {
    final addOnTotal = addOns
        .where((a) => _selectedAddOns.contains(a.name))
        .fold(0, (sum, a) => sum + a.price);
    return widget.item.price + addOnTotal;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.item.emoji,
                    style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item.name,
                        style: theme.textTheme.titleLarge),
                    Text('基本價 \$${widget.item.price}',
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _OptionSection(
              title: '甜度',
              options: sugarOptions,
              selected: _sugar,
              onSelected: (v) => setState(() => _sugar = v),
            ),
            const SizedBox(height: 16),
            _OptionSection(
              title: '冰量',
              options: iceOptions,
              selected: _ice,
              onSelected: (v) => setState(() => _ice = v),
            ),
            const SizedBox(height: 16),
            Text('加料', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: addOns.map((a) {
                final selected = _selectedAddOns.contains(a.name);
                return FilterChip(
                  label: Text('${a.name} +\$${a.price}'),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _selectedAddOns.add(a.name);
                    } else {
                      _selectedAddOns.remove(a.name);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                IconButton.outlined(
                  onPressed: () => setState(
                      () => _quantity = _quantity > 1 ? _quantity - 1 : 1),
                  icon: const Icon(Icons.remove),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('$_quantity',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                IconButton.outlined(
                  onPressed: () => setState(() => _quantity++),
                  icon: const Icon(Icons.add),
                ),
                const Spacer(),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: () => widget.onConfirm(CartItem(
                      item: widget.item,
                      sugar: _sugar,
                      ice: _ice,
                      addOns: addOns
                          .where((a) => _selectedAddOns.contains(a.name))
                          .toList(),
                      quantity: _quantity,
                    )),
                    child: Text(
                      '加入訂單 \$${_unitPrice * _quantity}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionSection extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const _OptionSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((o) {
            final isSelected = o == selected;
            return ChoiceChip(
              label: Text(o),
              selected: isSelected,
              onSelected: (_) => onSelected(o),
            );
          }).toList(),
        ),
      ],
    );
  }
}
