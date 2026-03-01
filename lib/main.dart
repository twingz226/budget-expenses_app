import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/expense.dart';
import 'models/budget.dart';
import 'models/custom_category.dart';
import 'utils/categories.dart';
import 'themes/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/budget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters safely
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpenseAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(BudgetAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CustomCategoryAdapter());
    }

    // Open boxes
    await Hive.openBox<Expense>(AppConstants.expensesBoxName);
    await Hive.openBox<Budget>(AppConstants.budgetsBoxName);
    await Hive.openBox<CustomCategory>(AppConstants.customCategoriesBoxName);

    // Ensure budgets are rolled over for the current month
    await BudgetService.ensureBudgetsRolledOver();

    runApp(const MoneyWiseApp());
  } catch (e, stackTrace) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Initialization Error:\n\n$e\n\n$stackTrace',
              style: const TextStyle(color: Colors.red),
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      ),
    ));
  }
}

class MoneyWiseApp extends StatefulWidget {
  const MoneyWiseApp({super.key});

  @override
  State<MoneyWiseApp> createState() => _MoneyWiseAppState();
}

class _MoneyWiseAppState extends State<MoneyWiseApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    HapticFeedback.lightImpact();
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoneyWise',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: HomeScreen(onToggleTheme: _toggleTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}
