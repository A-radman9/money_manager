// This is a basic Flutter widget test for Money Manager app.

import 'package:flutter_test/flutter_test.dart';

import 'package:money_manager/main.dart';

void main() {
  testWidgets('Money Manager app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MoneyManagerApp());

    // Verify that the app loads and shows the dashboard
    expect(find.text('Money Manager'), findsOneWidget);
    expect(find.text('Total Balance'), findsOneWidget);
  });
}
