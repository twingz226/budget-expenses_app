import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/hive_service.dart';
import '../services/category_service.dart';
import '../utils/currency_formatter.dart';

class QuickStatsWidget extends StatefulWidget {
  const QuickStatsWidget({super.key});

  @override
  State<QuickStatsWidget> createState() => _QuickStatsWidgetState();
}

class _QuickStatsWidgetState extends State<QuickStatsWidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveService.expenseBox.listenable(),
      builder: (context, box, _) {
        final allExpenses = HiveService.getAllExpenses();
        final currentMonth = DateTime.now();

        // Calculate stats
        final currentMonthExpenses = HiveService.getExpensesForMonth(
          currentMonth,
        );
        final lastMonthExpenses = HiveService.getExpensesForMonth(
          DateTime(currentMonth.year, currentMonth.month - 1, 1),
        );
        final lastSevenDaysExpenses = HiveService.getExpensesForLastSevenDays();

        final currentMonthTotal = currentMonthExpenses.fold(
          0.0,
          (sum, e) => sum + e.amount,
        );
        final lastMonthTotal = lastMonthExpenses.fold(
          0.0,
          (sum, e) => sum + e.amount,
        );
        final lastSevenDaysTotal = lastSevenDaysExpenses.fold(
          0.0,
          (sum, e) => sum + e.amount,
        );

        // Calculate month-over-month change
        final monthlyChange = lastMonthTotal > 0
            ? ((currentMonthTotal - lastMonthTotal) / lastMonthTotal * 100)
            : 0.0;

        // Get top category
        final categoryTotals = HiveService.getExpensesByCategoryForMonth(
          currentMonth,
        );
        final topCategory = categoryTotals.isNotEmpty
            ? categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b)
            : null;

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
                      Text(
                        'Quick Stats',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Stats Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.8,
                        children: [
                          // Current Month Total
                          _buildStatCard(
                            context,
                            'This Month',
                            CurrencyFormatter.format(currentMonthTotal),
                            Icons.calendar_today,
                            Theme.of(context).colorScheme.primary,
                          ),

                          // Last 7 Days
                          _buildStatCard(
                            context,
                            'Last 7 Days',
                            CurrencyFormatter.format(lastSevenDaysTotal),
                            Icons.date_range,
                            Theme.of(context).colorScheme.secondary,
                          ),

                          // Monthly Change
                          _buildStatCard(
                            context,
                            'vs Last Month',
                            '${monthlyChange >= 0 ? '+' : ''}${monthlyChange.toStringAsFixed(1)}%',
                            Icons.trending_up,
                            monthlyChange >= 0 ? Colors.green : Colors.red,
                          ),

                          // Top Category
                          _buildStatCard(
                            context,
                            'Top Category',
                            topCategory?.key ?? 'N/A',
                            Icons.category,
                            CategoryService.getCategoryColor(
                              topCategory?.key ?? '',
                            ),
                          ),
                        ],
                      ),

                      // Recent transactions summary
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 20,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${allExpenses.length} total transactions • ${currentMonthExpenses.length} this month',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
