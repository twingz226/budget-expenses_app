import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../services/hive_service.dart';
import '../widgets/glassmorphism_expense_item.dart';
import '../widgets/search_filter_widget.dart';
import '../utils/currency_formatter.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<Expense> _filteredExpenses = [];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveService.expenseBox.listenable(),
      builder: (context, Box<Expense> box, _) {
        final allExpenses = box.values.toList();

        return Column(
          children: [
            // Search and Filter Widget
            SearchFilterWidget(
              allExpenses: allExpenses,
              onFilteredExpensesChanged: (filtered) {
                setState(() {
                  _filteredExpenses = filtered;
                });
              },
            ),

            // Monthly Total Card (based on filtered expenses)
            _buildMonthlyTotalCard(),

            // Expenses List
            Expanded(
              child: _filteredExpenses.isEmpty
                  ? _buildEmptyState(context)
                  : RefreshIndicator(
                      onRefresh: _refreshData,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = _filteredExpenses.elementAt(index);
                          final originalIndex = allExpenses.indexOf(expense);
                          return GlassmorphismExpenseItem(
                            expense: expense,
                            onDelete: () => _deleteExpense(originalIndex),
                            onEdit: () => _editExpense(context, expense),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthlyTotalCard() {
    final currentMonth = DateTime.now();
    final currentMonthExpenses = _filteredExpenses.where((expense) {
      return expense.date.year == currentMonth.year &&
          expense.date.month == currentMonth.month;
    }).toList();
    final monthlyTotal = currentMonthExpenses.fold(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'This Month',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                '${currentMonthExpenses.length} transactions',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(monthlyTotal),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final allExpenses = HiveService.getAllExpenses();
    final hasFilters = _filteredExpenses.length != allExpenses.length;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.filter_list_off : Icons.receipt_long,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No matching expenses' : 'No expenses yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try adjusting your filters or search terms'
                : 'Add your first expense to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _deleteExpense(int index) async {
    await HiveService.deleteExpense(index);
  }

  void _editExpense(BuildContext context, Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(expense: expense),
      ),
    );
  }

  Future<void> _refreshData() async {
    // Simulate refresh delay for user feedback
    await Future.delayed(const Duration(seconds: 1));
  }
}
