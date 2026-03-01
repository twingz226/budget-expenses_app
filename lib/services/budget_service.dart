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

  static Budget? getBudgetForMonth(DateTime month) {
    final budgets = budgetBox.values.where((budget) {
      return budget.month.year == month.year &&
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
    final budget = getBudgetForMonth(month);
    final totalSpent = getTotalSpentForMonth(month);
    final Map<String, double> progress = {};

    if (budget != null && budget.amount > 0) {
      progress['General'] = totalSpent / budget.amount;
    }

    return progress;
  }

  static double getTotalBudgetForMonth(DateTime month) {
    final budget = getBudgetForMonth(month);
    return budget?.amount ?? 0.0;
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
    return []; // No longer applicable with a general budget
  }

  static bool isOverBudget(DateTime month) {
    final budget = getBudgetForMonth(month);
    if (budget == null) return false;

    final totalExpenses = getTotalSpentForMonth(month);

    return totalExpenses > budget.amount;
  }

  static Future<void> ensureBudgetsRolledOver() async {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    
    // Check if there are already budgets for the current month
    final currentBudgets = getBudgetsForMonth(currentMonth);
    if (currentBudgets.isNotEmpty) {
      return; // Already have budgets for this month
    }

    // No budgets for current month, let's look for the most recent past month
    final existingMonthsWithBudgets = budgetBox.values
        .map((b) => DateTime(b.month.year, b.month.month))
        .toSet()
        .toList()
        ..sort((a, b) => b.compareTo(a)); // Sort descending

    final pastMonths = existingMonthsWithBudgets
        .where((m) => m.isBefore(currentMonth))
        .toList();

    if (pastMonths.isEmpty) {
      return; // No past budgets to roll over
    }

    final mostRecentPastMonth = pastMonths.first;
    final pastBudgets = getBudgetsForMonth(mostRecentPastMonth);

    for (final budget in pastBudgets) {
      // Calculate how much was spent in that past month in total
      final pastExpenses = HiveService.getTotalForMonth(mostRecentPastMonth);

      final remainingAmount = budget.amount - pastExpenses;

      // Only roll over if there is an unspent amount
      if (remainingAmount > 0) {
        final newBudget = Budget(
          category: 'General',
          amount: remainingAmount,
          month: currentMonth,
        );
        await addBudget(newBudget);
      }
    }
  }
}

