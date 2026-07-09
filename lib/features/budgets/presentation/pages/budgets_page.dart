import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phf_money_management/core/widgets/app_drawer.dart';
import 'package:phf_money_management/features/categories/domain/entities/category.dart';
import 'package:phf_money_management/features/categories/presentation/providers/category_provider.dart';
import 'package:phf_money_management/features/settings/presentation/providers/currency_provider.dart';
import 'package:phf_money_management/features/transactions/presentation/providers/transaction_provider.dart';
import '../../domain/entities/budget.dart';
import '../providers/budget_provider.dart';
import 'package:phf_money_management/features/budgets/domain/usecases/get_budget_progress.dart';

class BudgetsPage extends ConsumerStatefulWidget {
  const BudgetsPage({super.key});

  @override
  ConsumerState<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends ConsumerState<BudgetsPage> {
  DateTime _selectedMonth = DateTime.now();

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + offset);
    });
  }

  void _showDeleteConfirmation(BuildContext context, Budget budget, String categoryName) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Budget?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete the budget for "$categoryName"?',
          style: const TextStyle(color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(budgetProvider.notifier).deleteBudget(budget.id);
              Navigator.of(dialogCtx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗑 Budget Deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String? hexString) {
    if (hexString == null) return const Color(0xFF1976D2);
    final hex = hexString.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetProvider);
    final transactionState = ref.watch(transactionProvider);
    final categoryState = ref.watch(categoryProvider);
    final currencySymbol = ref.watch(currencyProvider);

    final currencyFormat = NumberFormat.currency(symbol: '$currencySymbol ', decimalDigits: 2);

    final getBudgetProgress = ref.watch(getBudgetProgressProvider);
    final progressList = getBudgetProgress(
      budgets: budgetState.budgets,
      transactions: transactionState.transactions,
      targetMonth: _selectedMonth,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracking'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Month Selector Banner
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(bottom: BorderSide(color: Colors.blue[100]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1976D2)),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_selectedMonth),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF1976D2)),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
          ),

          // Budgets List View
          Expanded(
            child: budgetState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : progressList.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '🎯',
                                style: TextStyle(fontSize: 80),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'No Budgets Found',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Set a monthly spending limit for a category to keep track of your goals.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF64748B),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: progressList.length,
                        itemBuilder: (context, index) {
                          final progressItem = progressList[index];
                          final budget = progressItem.budget;
                          final category = categoryState.categories.firstWhere(
                            (c) => c.id == budget.categoryId,
                            orElse: () => const Category(id: 0, name: 'General', type: 'Expense'),
                          );

                          final spent = progressItem.spentAmount;
                          final remaining = progressItem.remainingAmount;
                          final progress = progressItem.progress;
                          final isOverBudget = progressItem.isOverBudget;

                          Color progressColor;
                          if (progress >= 1.0) {
                            progressColor = Colors.red[800]!;
                          } else if (progress >= 0.85) {
                            progressColor = Colors.orange[800]!;
                          } else {
                            progressColor = _hexToColor(category.color);
                          }

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: progressColor.withValues(alpha: 0.1),
                                            child: Icon(Icons.circle, color: progressColor, size: 14),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            category.name,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert_rounded),
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AddBudgetDialog(
                                                budget: budget,
                                                initialMonth: _selectedMonth,
                                              ),
                                            );
                                          } else if (value == 'delete') {
                                            _showDeleteConfirmation(context, budget, category.name);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit_rounded, size: 18),
                                                SizedBox(width: 8),
                                                Text('Edit'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_rounded, color: Colors.red, size: 18),
                                                SizedBox(width: 8),
                                                Text('Delete', style: TextStyle(color: Colors.red)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Spent: ${currencyFormat.format(spent)}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                                      Text('Limit: ${currencyFormat.format(budget.amountLimit)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress.clamp(0.0, 1.0),
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                                      minHeight: 8,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        isOverBudget ? 'Over Budget' : 'Remaining',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isOverBudget ? Colors.red[800] : Colors.green[800],
                                        ),
                                      ),
                                      Text(
                                        currencyFormat.format(remaining.abs()),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isOverBudget ? Colors.red[800] : Colors.green[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddBudgetDialog(initialMonth: _selectedMonth),
          );
        },
        backgroundColor: const Color(0xFF1976D2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddBudgetDialog extends ConsumerStatefulWidget {
  final Budget? budget;
  final DateTime initialMonth;
  const AddBudgetDialog({super.key, this.budget, required this.initialMonth});

  @override
  ConsumerState<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends ConsumerState<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _limitController;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _limitController = TextEditingController(text: widget.budget?.amountLimit.toString());
    _selectedCategoryId = widget.budget?.categoryId;
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryProvider);
    final expenseCategories = categoryState.categories.where((c) => c.type.toLowerCase() == 'expense').toList();
    final isEditing = widget.budget != null;
    final currencySymbol = ref.watch(currencyProvider);

    return AlertDialog(
      title: Text(isEditing ? 'Edit Budget' : 'Set Budget limit'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Category Dropdown
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Expense Category'),
                items: expenseCategories.map((cat) {
                  return DropdownMenuItem<int>(
                    value: cat.id,
                    child: Text(cat.name),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) return 'Please select a category';
                  return null;
                },
                onChanged: isEditing
                    ? null // Category is read-only when editing a budget
                    : (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
              ),
              const SizedBox(height: 12),
              // Limit Input
              TextFormField(
                controller: _limitController,
                decoration: InputDecoration(labelText: 'Monthly Limit ($currencySymbol)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a limit';
                  }
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final startOfMonth = DateTime(widget.initialMonth.year, widget.initialMonth.month, 1);
              final endOfMonth = DateTime(widget.initialMonth.year, widget.initialMonth.month + 1, 0, 23, 59, 59);

              final newBudget = Budget(
                id: isEditing ? widget.budget!.id : 0,
                categoryId: _selectedCategoryId!,
                amountLimit: double.parse(_limitController.text.trim()),
                startDate: startOfMonth,
                endDate: endOfMonth,
              );

              if (isEditing) {
                ref.read(budgetProvider.notifier).editBudget(newBudget);
              } else {
                ref.read(budgetProvider.notifier).addBudget(newBudget);
              }

              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEditing
                        ? '🎯 Budget updated successfully!'
                        : '🎯 Budget set successfully!'
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1976D2),
            foregroundColor: Colors.white,
          ),
          child: Text(isEditing ? 'Save' : 'Set'),
        ),
      ],
    );
  }
}
