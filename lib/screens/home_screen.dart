import 'package:flutter/material.dart';
import '../widgets/animated_background.dart';
import 'quick_stats_screen.dart';
import 'budget_progress_screen.dart';
import 'expenses_screen.dart';
import 'add_expense_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final List<String> _tabTitles = [
    'Quick Stats',
    'Budget Progress',
    'Expenses',
    'Statistics',
  ];
  final List<IconData> _tabIcons = [
    Icons.analytics,
    Icons.account_balance_wallet,
    Icons.home,
    Icons.bar_chart,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? 'Quick Stats'
              : _currentIndex == 1
              ? 'Budget Progress'
              : _currentIndex == 2
              ? 'Expenses'
              : 'Statistics',
        ),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Stack(
        children: [
          const AnimatedBackground(),
          Column(
            children: [
              // Modern Scrollable Navigation Bar
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: _tabTitles.length,
                  itemBuilder: (context, index) {
                    final isSelected = _currentIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentIndex = index;
                        });
                        // Center the selected tab
                        _scrollToTab(index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _tabIcons[index],
                                  size: 20,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _tabTitles[index],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onPrimary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 4),
                              Container(
                                height: 3,
                                width: 24,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onPrimary
                                      .withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(1.5),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Screen Content
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    const QuickStatsScreen(),
                    const BudgetProgressScreen(),
                    const ExpensesScreen(),
                    const StatisticsScreen(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 2
          ? Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddExpenseScreen(),
                    ),
                  );
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
    );
  }

  void _scrollToTab(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final estimatedTabWidth = 120.0; // Estimated width of each tab
    final targetOffset =
        (index * estimatedTabWidth) -
        (screenWidth / 2) +
        (estimatedTabWidth / 2);

    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
