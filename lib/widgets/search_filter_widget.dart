import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/hive_service.dart';
import '../services/category_service.dart';

class SearchFilterWidget extends StatefulWidget {
  final Function(List<Expense>) onFilteredExpensesChanged;
  final List<Expense> allExpenses;

  const SearchFilterWidget({
    super.key,
    required this.onFilteredExpensesChanged,
    required this.allExpenses,
  });

  @override
  State<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _categoryFocusNode = FocusNode();
  final _sortFocusNode = FocusNode();
  String _selectedCategory = 'All Categories';
  DateTime? _startDate;
  DateTime? _endDate;
  double _minAmount = 0;
  double _maxAmount = 10000;
  String _sortBy = 'date';
  bool _sortAscending = false;
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilters();
    });
  }

  @override
  void didUpdateWidget(SearchFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.allExpenses != oldWidget.allExpenses) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyFilters();
      });
    }
  }

  void _applyFilters() {
    List<Expense> filteredExpenses = List.from(widget.allExpenses);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      filteredExpenses = HiveService.searchExpenses(
        _searchController.text,
      ).where((expense) => widget.allExpenses.contains(expense)).toList();
    }

    // Apply category filter
    if (_selectedCategory != 'All Categories') {
      filteredExpenses = filteredExpenses
          .where((expense) => expense.category == _selectedCategory)
          .toList();
    }

    // Apply date range filter
    if (_startDate != null && _endDate != null) {
      filteredExpenses = filteredExpenses
          .where(
            (expense) =>
                expense.date.isAfter(
                  _startDate!.subtract(const Duration(days: 1)),
                ) &&
                expense.date.isBefore(_endDate!.add(const Duration(days: 1))),
          )
          .toList();
    }

    // Apply amount range filter
    filteredExpenses = filteredExpenses
        .where(
          (expense) =>
              expense.amount >= _minAmount && expense.amount <= _maxAmount,
        )
        .toList();

    // Apply sorting
    filteredExpenses = HiveService.sortExpenses(
      filteredExpenses,
      _sortBy,
      _sortAscending,
    );

    widget.onFilteredExpensesChanged(filteredExpenses);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isFilterExpanded
                            ? Icons.filter_list_off
                            : Icons.filter_list,
                      ),
                      onPressed: () {
                        setState(() {
                          _isFilterExpanded = !_isFilterExpanded;
                        });
                      },
                    ),
                    if (_hasActiveFilters())
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearFilters,
                      ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Expanded filter options
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isFilterExpanded
                ? _buildFilterOptions()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category filter
          DropdownButtonFormField<String>(
            focusNode: _categoryFocusNode,
            initialValue: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              isDense: true,
            ),
            items: ['All Categories', ...CategoryService.getAllCategories()]
                .map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                })
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
                _applyFilters();
              });
            },
          ),
          const SizedBox(height: 8),

          // Date range filter
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    _categoryFocusNode.unfocus();
                    _sortFocusNode.unfocus();
                    _selectStartDate();
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      isDense: true,
                    ),
                    child: Text(
                      _startDate != null
                          ? DateFormat('MMM dd, yyyy').format(_startDate!)
                          : 'Select start date',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () {
                    _categoryFocusNode.unfocus();
                    _sortFocusNode.unfocus();
                    _selectEndDate();
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                      isDense: true,
                    ),
                    child: Text(
                      _endDate != null
                          ? DateFormat('MMM dd, yyyy').format(_endDate!)
                          : 'Select end date',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Amount range filter
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount Range: ₱${_minAmount.toStringAsFixed(0)} - ₱${_maxAmount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              RangeSlider(
                values: RangeValues(_minAmount, _maxAmount),
                min: 0,
                max: 10000,
                divisions: 100,
                labels: RangeLabels(
                  '₱${_minAmount.toStringAsFixed(0)}',
                  '₱${_maxAmount.toStringAsFixed(0)}',
                ),
                onChanged: (values) {
                  setState(() {
                    _minAmount = values.start;
                    _maxAmount = values.end;
                    _applyFilters();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Sort options
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  focusNode: _sortFocusNode,
                  initialValue: _sortBy,
                  decoration: const InputDecoration(
                    labelText: 'Sort by',
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'date', child: Text('Date')),
                    DropdownMenuItem(value: 'amount', child: Text('Amount')),
                    DropdownMenuItem(value: 'title', child: Text('Title')),
                    DropdownMenuItem(
                      value: 'category',
                      child: Text('Category'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                      _applyFilters();
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                ),
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                    _applyFilters();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _applyFilters();
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _applyFilters();
      });
    }
  }

  bool _hasActiveFilters() {
    return _selectedCategory != 'All Categories' ||
        _startDate != null ||
        _endDate != null ||
        _minAmount > 0 ||
        _maxAmount < 10000;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = 'All Categories';
      _startDate = null;
      _endDate = null;
      _minAmount = 0;
      _maxAmount = 10000;
      _sortBy = 'date';
      _sortAscending = false;
      _applyFilters();
    });
  }
}
