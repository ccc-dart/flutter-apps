import 'package:flutter_test/flutter_test.dart';

import 'package:demo_app/main.dart';

void main() {
  testWidgets('HomePage shows demo list', (tester) async {
    await tester.pumpWidget(const DemoApp());
    expect(find.text('Flutter 視覺化元件展示'), findsOneWidget);
    expect(find.text('Buttons 按鈕'), findsOneWidget);
    expect(find.text('Animation 動畫'), findsOneWidget);
  });
}
