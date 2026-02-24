import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../models/expense.dart';
import '../services/hive_service.dart';
import '../services/category_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedCategory = CategoryService.getAllCategories().first;
  DateTime _selectedDate = DateTime.now();

  bool _isRecurring = false;
  String? _frequency;
  DateTime? _nextDueDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
      _selectedCategory = widget.expense!.category;
      _selectedDate = widget.expense!.date;
      _noteController.text = widget.expense!.note ?? '';
      _isRecurring = widget.expense!.isRecurring;
      _frequency = widget.expense!.frequency;
      _nextDueDate = widget.expense!.nextDueDate;
      _endDate = widget.expense!.endDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
        actions: [
          if (widget.expense != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteExpense,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              TextFormField(
                autofocus: true,
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter expense title',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter amount',
                  prefixText: '₱ ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: CategoryService.getAllCategories().length,
                      itemBuilder: (context, index) {
                        final category =
                            CategoryService.getAllCategories()[index];
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CategoryService.getCategoryIcon(category),
                                  size: 16,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(category),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              }
                            },
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            selectedColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            checkmarkColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date Picker
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('MMMM dd, yyyy').format(_selectedDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Note Field
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  hintText: 'Add a note',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Recurring Expense Toggle
              SwitchListTile(
                title: const Text('Recurring Expense'),
                subtitle: const Text('Set up automatic recurring transactions'),
                value: _isRecurring,
                onChanged: (value) {
                  setState(() {
                    _isRecurring = value;
                    if (!value) {
                      _frequency = null;
                      _nextDueDate = null;
                      _endDate = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              // Recurring Options
              if (_isRecurring) ...[
                // Frequency Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _frequency,
                  decoration: const InputDecoration(labelText: 'Frequency'),
                  items: ['daily', 'weekly', 'monthly', 'yearly'].map((freq) {
                    return DropdownMenuItem(
                      value: freq,
                      child: Text(freq[0].toUpperCase() + freq.substring(1)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _frequency = value;
                    });
                  },
                  validator: (value) {
                    if (_isRecurring && value == null) {
                      return 'Please select a frequency';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Next Due Date Picker
                InkWell(
                  onTap: _selectNextDueDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Next Due Date',
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _nextDueDate != null
                              ? DateFormat(
                                  'MMMM dd, yyyy',
                                ).format(_nextDueDate!)
                              : 'Select date',
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // End Date Picker (Optional)
                InkWell(
                  onTap: _selectEndDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'End Date (Optional)',
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _endDate != null
                              ? DateFormat('MMMM dd, yyyy').format(_endDate!)
                              : 'No end date',
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Save Button
              ElevatedButton(
                onPressed: _saveExpense,
                child: Text(
                  widget.expense == null ? 'Save Expense' : 'Update Expense',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectNextDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _nextDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _nextDueDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_nextDueDate ?? DateTime.now()),
      firstDate: _nextDueDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final expense = Expense(
        id: widget.expense?.id,
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        isRecurring: _isRecurring,
        frequency: _frequency,
        nextDueDate: _nextDueDate,
        endDate: _endDate,
      );

      if (widget.expense == null) {
        // Add new expense
        await HiveService.addExpense(expense);
      } else {
        // Update existing expense
        final index = HiveService.expenseBox.values.toList().indexWhere(
          (e) => e.id == widget.expense!.id,
        );
        if (index != -1) {
          await HiveService.updateExpense(index, expense);
        }
      }

      HapticFeedback.lightImpact();

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _deleteExpense() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final index = HiveService.expenseBox.values.toList().indexWhere(
        (e) => e.id == widget.expense!.id,
      );
      if (index != -1) {
        await HiveService.deleteExpense(index);
        if (mounted) {
          Navigator.pop(context);
        }
      }
    }
  }
}
