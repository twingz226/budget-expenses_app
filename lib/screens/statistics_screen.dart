import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/hive_service.dart';
import '../services/category_service.dart';
import '../services/budget_service.dart';
import '../utils/currency_formatter.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final int _selectedPeriod = 0; // 0 for 7 days, 1 for 30 days

  Widget _buildCurrentMonthTotal(BuildContext context) {
    final now = DateTime.now();
    final monthlyTotal = HiveService.getTotalForMonth(now);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Month Total',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.format(monthlyTotal),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              DateFormat('MMMM yyyy').format(now),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemainingDailyBudget(BuildContext context) {
    final now = DateTime.now();
    final totalBudget = BudgetService.getTotalBudgetForMonth(now);
    final totalSpent = BudgetService.getTotalSpentForMonth(now);

    if (totalBudget == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remaining Daily Budget',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'No monthly budget set',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final remainingMonthly = totalBudget - totalSpent;
    if (remainingMonthly <= 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remaining Daily Budget',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Over budget',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate remaining days in the month (from tomorrow to end of month)
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final remainingDays =
        lastDayOfMonth.difference(tomorrow).inDays +
        1; // +1 to include tomorrow

    if (remainingDays <= 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remaining Daily Budget',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Month ended',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final dailyBudget = remainingMonthly / remainingDays;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Remaining Daily Budget',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.format(dailyBudget),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              '$remainingDays days left in ${DateFormat('MMMM').format(now)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDistribution(BuildContext context) {
    final now = DateTime.now();
    final categoryData = HiveService.getExpensesByCategoryForMonth(now);

    if (categoryData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No expenses this month',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final pieSections = categoryData.entries.map((entry) {
      return PieChartSectionData(
        color: CategoryService.getCategoryColor(entry.key),
        value: entry.value,
        title: '', // Remove title to avoid overlap, use tooltips instead
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Distribution',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: pieSections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      // Touch callback for interactions
                    },
                    enabled: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Category Legend
            ...categoryData.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: CategoryService.getCategoryColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(entry.key)),
                    Text(
                      CurrencyFormatter.format(entry.value),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesChart(BuildContext context) {
    final is30Days = _selectedPeriod == 1;
    final dailyTotals = is30Days
        ? HiveService.getDailyTotalsForLastThirtyDays()
        : HiveService.getDailyTotalsForLastSevenDays();
    final now = DateTime.now();
    final days = is30Days ? 29 : 6;
    final List<Map<String, dynamic>> data = [];

    for (int i = days; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final total =
          dailyTotals[DateTime(date.year, date.month, date.day)] ?? 0.0;
      data.add({
        'day': is30Days
            ? DateFormat('MM/dd').format(date)
            : DateFormat('EEE').format(date),
        'amount': total,
      });
    }

    final maxAmount = data
        .map((d) => d['amount'] as double)
        .reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  is30Days ? 'Last 30 Days' : 'Last 7 Days',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxAmount * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.black87,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final day = data[group.x.toInt()]['day'] as String;
                        final amount = rod.toY;
                        return BarTooltipItem(
                          '$day\n${CurrencyFormatter.format(amount)}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value >= 0 && value < data.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                data[value.toInt()]['day'] as String,
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            CurrencyFormatter.format(value).replaceAll('₱', ''),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: data.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value['amount'] as double,
                          color: Theme.of(context).colorScheme.primary,
                          width: is30Days ? 8 : 12,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                            bottom: Radius.zero,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    // Simulate refresh delay for user feedback
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveService.expenseBox.listenable(),
      builder: (context, box, _) {
        return RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Month Total
                _buildCurrentMonthTotal(context),
                const SizedBox(height: 24),

                // Remaining Daily Budget
                _buildRemainingDailyBudget(context),
                const SizedBox(height: 24),

                // Category Distribution
                _buildCategoryDistribution(context),
                const SizedBox(height: 24),

                // Weekly Expenses Chart
                _buildExpensesChart(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
