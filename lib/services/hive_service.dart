import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../utils/categories.dart';

class HiveService {
  static Box<Expense>? _expenseBox;

  static Box<Expense> get expenseBox {
    _expenseBox ??= Hive.box<Expense>(AppConstants.expensesBoxName);
    return _expenseBox!;
  }

  static Future<void> addExpense(Expense expense) async {
    await expenseBox.add(expense);
  }

  static Future<void> deleteExpense(int index) async {
    await expenseBox.deleteAt(index);
  }

  static Future<void> updateExpense(int index, Expense expense) async {
    await expenseBox.putAt(index, expense);
  }

  static List<Expense> getAllExpenses() {
    return expenseBox.values.toList();
  }

  static List<Expense> getExpensesForMonth(DateTime month) {
    final expenses = getAllExpenses();
    return expenses.where((expense) {
      return expense.date.year == month.year &&
          expense.date.month == month.month;
    }).toList();
  }

  static List<Expense> getExpensesForLastSevenDays() {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final expenses = getAllExpenses();
    return expenses.where((expense) {
      return expense.date.isAfter(sevenDaysAgo) &&
          expense.date.isBefore(now.add(const Duration(days: 1)));
    }).toList();
  }

  static Map<String, double> getExpensesByCategory() {
    final expenses = getAllExpenses();
    final Map<String, double> categoryTotals = {};

    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return categoryTotals;
  }

  static Map<String, double> getExpensesByCategoryForMonth(DateTime month) {
    final expenses = getExpensesForMonth(month);
    final Map<String, double> categoryTotals = {};

    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return categoryTotals;
  }

  static double getTotalForMonth(DateTime month) {
    final expenses = getExpensesForMonth(month);
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  static Map<DateTime, double> getDailyTotalsForLastSevenDays() {
    final expenses = getExpensesForLastSevenDays();
    final Map<DateTime, double> dailyTotals = {};

    for (final expense in expenses) {
      final date = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      dailyTotals[date] = (dailyTotals[date] ?? 0) + expense.amount;
    }

    return dailyTotals;
  }

  static List<Expense> searchExpenses(String query) {
    final expenses = getAllExpenses();
    final lowercaseQuery = query.toLowerCase();

    return expenses.where((expense) {
      return expense.title.toLowerCase().contains(lowercaseQuery) ||
          expense.category.toLowerCase().contains(lowercaseQuery) ||
          (expense.note?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  static List<Expense> filterExpensesByCategory(String category) {
    final expenses = getAllExpenses();
    return expenses.where((expense) => expense.category == category).toList();
  }

  static List<Expense> filterExpensesByDateRange(DateTime start, DateTime end) {
    final expenses = getAllExpenses();
    return expenses.where((expense) {
      return expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  static List<Expense> filterExpensesByAmountRange(double min, double max) {
    final expenses = getAllExpenses();
    return expenses.where((expense) {
      return expense.amount >= min && expense.amount <= max;
    }).toList();
  }

  static List<Expense> sortExpenses(
    List<Expense> expenses,
    String sortBy,
    bool ascending,
  ) {
    final sortedExpenses = List<Expense>.from(expenses);

    switch (sortBy) {
      case 'date':
        sortedExpenses.sort(
          (a, b) =>
              ascending ? a.date.compareTo(b.date) : b.date.compareTo(a.date),
        );
        break;
      case 'amount':
        sortedExpenses.sort(
          (a, b) => ascending
              ? a.amount.compareTo(b.amount)
              : b.amount.compareTo(a.amount),
        );
        break;
      case 'title':
        sortedExpenses.sort(
          (a, b) => ascending
              ? a.title.toLowerCase().compareTo(b.title.toLowerCase())
              : b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        );
        break;
      case 'category':
        sortedExpenses.sort(
          (a, b) => ascending
              ? a.category.toLowerCase().compareTo(b.category.toLowerCase())
              : b.category.toLowerCase().compareTo(a.category.toLowerCase()),
        );
        break;
    }

    return sortedExpenses;
  }
}
