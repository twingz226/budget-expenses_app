import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moneywise/main.dart';
import 'package:moneywise/models/expense.dart';
import 'package:moneywise/models/budget.dart';
import 'package:moneywise/models/custom_category.dart';
import 'package:moneywise/utils/categories.dart';

void main() {
  setUp(() async {
    Hive.init('test_hive_db');
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpenseAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(BudgetAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CustomCategoryAdapter());
    }

    await Hive.openBox<Expense>(AppConstants.expensesBoxName);
    await Hive.openBox<Budget>(AppConstants.budgetsBoxName);
    await Hive.openBox<CustomCategory>(AppConstants.customCategoriesBoxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
  });

  testWidgets('MoneyWise app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MoneyWiseApp());
    await tester.pumpAndSettle();

    expect(find.text('Expenses'), findsWidgets);
    expect(find.text('Statistics'), findsWidgets);
  });
}
