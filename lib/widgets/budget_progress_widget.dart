import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/budget_service.dart';
import '../services/hive_service.dart';
import '../models/budget.dart';
import '../utils/currency_formatter.dart';
import '../screens/budget_management_screen.dart';

class BudgetProgressWidget extends StatefulWidget {
  const BudgetProgressWidget({super.key});

  @override
  State<BudgetProgressWidget> createState() => _BudgetProgressWidgetState();
}

class _BudgetProgressWidgetState extends State<BudgetProgressWidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: BudgetService.budgetBox.listenable(),
      builder: (context, Box<Budget> budgetBox, _) {
        final currentMonth = DateTime.now();
        final budgets = BudgetService.getBudgetsForMonth(currentMonth);

        return ValueListenableBuilder(
          valueListenable: HiveService.expenseBox.listenable(),
          builder: (context, expenseBox, _) {
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                children: [
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Budget Progress',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const BudgetManagementScreen(),
                                    ),
                                  );
                                },
                                child: const Text('Manage'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          if (budgets.isEmpty) ...[
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 48,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No Budgets Set',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Set budgets to track your spending',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BudgetManagementScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Set Budgets'),
                            ),
                          ] else ...[
                            // Overall budget progress
                            _buildOverallBudgetCard(context, currentMonth),
                            const SizedBox(height: 16),

                            // Category-wise budget progress
                            ...budgets.map(
                              (budget) =>
                                  _buildCategoryBudgetCard(context, budget),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOverallBudgetCard(BuildContext context, DateTime month) {
    final totalBudget = BudgetService.getTotalBudgetForMonth(month);
    final totalSpent = BudgetService.getTotalSpentForMonth(month);
    final progress = totalBudget > 0 ? totalSpent / totalBudget : 0.0;
    final remaining = totalBudget - totalSpent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Budget',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                '${(progress * 100).toStringAsFixed(1)}% used',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: progress > 0.8
                      ? Colors.red
                      : progress > 0.6
                      ? Colors.orange
                      : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Theme.of(context).colorScheme.surface,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 0.8
                  ? Colors.red
                  : progress > 0.6
                  ? Colors.orange
                  : Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: ${CurrencyFormatter.format(totalSpent)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Remaining: ${CurrencyFormatter.format(remaining)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: remaining >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBudgetCard(BuildContext context, budget) {
    // Calculate actual spent for this category
    final currentMonthExpenses = HiveService.getExpensesForMonth(budget.month);
    final categorySpent = currentMonthExpenses
        .where((expense) => expense.category == budget.category)
        .fold(0.0, (sum, expense) => sum + expense.amount);

    final actualSpent = categorySpent;

    final progress = budget.amount > 0 ? actualSpent / budget.amount : 0.0;
    final remaining = budget.amount - actualSpent;
    final isOverBudget = BudgetService.isOverBudget(
      budget.category,
      budget.month,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                budget.category,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isOverBudget
                      ? Colors.red
                      : progress > 0.8
                      ? Colors.orange
                      : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Theme.of(context).colorScheme.surface,
            valueColor: AlwaysStoppedAnimation<Color>(
              isOverBudget
                  ? Colors.red
                  : progress > 0.8
                  ? Colors.orange
                  : Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${CurrencyFormatter.format(actualSpent)} / ${CurrencyFormatter.format(budget.amount)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '${CurrencyFormatter.format(remaining)} left',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: remaining >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    // Simulate refresh delay for user feedback
    await Future.delayed(const Duration(seconds: 1));
  }
}
