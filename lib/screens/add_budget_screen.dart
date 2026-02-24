import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../services/budget_service.dart';
import '../services/category_service.dart';

class AddBudgetScreen extends StatefulWidget {
  final Budget? budget;

  const AddBudgetScreen({super.key, this.budget});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  String _selectedCategory = CategoryService.getAllCategories().first;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _amountController.text = widget.budget!.amount.toString();
      _selectedCategory = widget.budget!.category;
      _selectedDate = widget.budget!.month;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budget == null ? 'Add Budget' : 'Edit Budget'),
        actions: [
          if (widget.budget != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteBudget,
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
              // Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: CategoryService.getAllCategories().map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: CategoryService.getCategoryColor(
                            category,
                          ),
                          radius: 12,
                          child: Icon(
                            CategoryService.getCategoryIcon(category),
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(category),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Budget Amount',
                  hintText: 'Enter budget amount',
                  prefixText: '₱ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a budget amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Month Picker
              InkWell(
                onTap: _selectMonth,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Month'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('MMMM yyyy').format(_selectedDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _saveBudget,
                child: Text(
                  widget.budget == null ? 'Create Budget' : 'Update Budget',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  Future<void> _saveBudget() async {
    if (_formKey.currentState!.validate()) {
      final budget = Budget(
        id: widget.budget?.id,
        category: _selectedCategory,
        amount: double.parse(_amountController.text),
        month: _selectedDate,
      );

      if (widget.budget == null) {
        // Add new budget
        await BudgetService.addBudget(budget);
      } else {
        // Update existing budget
        final index = BudgetService.budgetBox.values.toList().indexWhere(
          (b) => b.id == widget.budget!.id,
        );
        if (index != -1) {
          await BudgetService.updateBudget(index, budget);
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _deleteBudget() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: const Text('Are you sure you want to delete this budget?'),
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
      final index = BudgetService.budgetBox.values.toList().indexWhere(
        (b) => b.id == widget.budget!.id,
      );
      if (index != -1) {
        await BudgetService.deleteBudget(index);
        if (mounted) {
          Navigator.pop(context);
        }
      }
    }
  }
}
