import 'package:flutter_test/flutter_test.dart';

import 'package:moneywise/main.dart';

void main() {
  testWidgets('MoneyWise app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MoneyWiseApp());

    // Verify that the app loads with the home screen
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Statistics'), findsOneWidget);
  });
}
