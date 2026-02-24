import 'package:hive_flutter/hive_flutter.dart';
import '../models/budget.dart';
import '../utils/categories.dart';
import 'hive_service.dart';

class BudgetService {
  static Box<Budget>? _budgetBox;

  static Box<Budget> get budgetBox {
    _budgetBox ??= Hive.box<Budget>(AppConstants.budgetsBoxName);
    return _budgetBox!;
  }

  static Future<void> addBudget(Budget budget) async {
    await budgetBox.add(budget);
  }

  static Future<void> updateBudget(int index, Budget budget) async {
    await budgetBox.putAt(index, budget);
  }

  static Future<void> deleteBudget(int index) async {
    await budgetBox.deleteAt(index);
  }

  static Budget? getBudgetForCategory(String category, DateTime month) {
    final budgets = budgetBox.values.where((budget) {
      return budget.category == category &&
          budget.month.year == month.year &&
          budget.month.month == month.month;
    }).toList();

    return budgets.isNotEmpty ? budgets.first : null;
  }

  static List<Budget> getBudgetsForMonth(DateTime month) {
    return budgetBox.values.where((budget) {
      return budget.month.year == month.year &&
          budget.month.month == month.month;
    }).toList();
  }

  static Map<String, double> getBudgetProgress(DateTime month) {
    final budgets = getBudgetsForMonth(month);
    final expenses = HiveService.getExpensesForMonth(month);
    final Map<String, double> progress = {};

    for (final budget in budgets) {
      final spent = expenses
          .where((expense) => expense.category == budget.category)
          .fold(0.0, (sum, expense) => sum + expense.amount);

      progress[budget.category] = spent / budget.amount;
    }

    return progress;
  }

  static double getTotalBudgetForMonth(DateTime month) {
    final budgets = getBudgetsForMonth(month);
    return budgets.fold(0.0, (sum, budget) => sum + budget.amount);
  }

  static double getTotalSpentForMonth(DateTime month) {
    final expenses = HiveService.getExpensesForMonth(month);
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  static double getTotalBudgetProgress(DateTime month) {
    final totalBudget = getTotalBudgetForMonth(month);
    if (totalBudget == 0) return 0.0;

    final totalSpent = getTotalSpentForMonth(month);
    return totalSpent / totalBudget;
  }

  static List<String> getCategoriesWithoutBudgets(DateTime month) {
    final budgets = getBudgetsForMonth(month);
    final budgetedCategories = budgets.map((b) => b.category).toSet();

    return AppConstants.expenseCategories
        .where((category) => !budgetedCategories.contains(category))
        .toList();
  }

  static bool isOverBudget(String category, DateTime month) {
    final budget = getBudgetForCategory(category, month);
    if (budget == null) return false;

    final expenses = HiveService.getExpensesForMonth(month)
        .where((expense) => expense.category == category)
        .fold(0.0, (sum, expense) => sum + expense.amount);

    return expenses > budget.amount;
  }
}
