import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/expense.dart';
import 'models/budget.dart';
import 'models/custom_category.dart';
import 'utils/categories.dart';
import 'themes/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(CustomCategoryAdapter());

  // Open boxes
  await Hive.openBox<Expense>(AppConstants.expensesBoxName);
  await Hive.openBox<Budget>(AppConstants.budgetsBoxName);
  await Hive.openBox<CustomCategory>(AppConstants.customCategoriesBoxName);

  runApp(const MoneyWiseApp());
}

class MoneyWiseApp extends StatefulWidget {
  const MoneyWiseApp({super.key});

  @override
  State<MoneyWiseApp> createState() => _MoneyWiseAppState();
}

class _MoneyWiseAppState extends State<MoneyWiseApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
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
