import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phf_money_management/features/accounts/domain/entities/account.dart';
import 'package:phf_money_management/features/accounts/presentation/providers/account_provider.dart';
import 'package:phf_money_management/features/categories/presentation/providers/category_provider.dart';
import 'package:phf_money_management/features/transactions/domain/entities/transaction.dart';
import 'package:phf_money_management/features/transactions/presentation/providers/transaction_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  int? _selectedAccountId;
  int? _selectedCategoryId;
  String _selectedType = 'Expense';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1976D2),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountState = ref.watch(accountProvider);
    final categoryState = ref.watch(categoryProvider);

    // Filter categories by selected type (Income/Expense) to keep UI intuitive
    final filteredCategories = categoryState.categories
        .where((c) => c.type.toLowerCase() == _selectedType.toLowerCase())
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/transactions'),
        ),
      ),
      body: accountState.accounts.isEmpty || categoryState.categories.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange[800]),
                    const SizedBox(height: 16),
                    const Text(
                      'Prerequisites Required',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You must create at least one Account and one Category before adding a transaction.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => context.go('/accounts'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Go to Accounts'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () => context.go('/categories'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Go to Categories'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Transaction Type Segmented Control
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ChoiceChip(
                              label: const Text('Expense'),
                              selected: _selectedType == 'Expense',
                              selectedColor: Colors.red[100],
                              labelStyle: TextStyle(
                                color: _selectedType == 'Expense' ? Colors.red[800] : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedType = 'Expense';
                                    _selectedCategoryId = null; // Reset category
                                  });
                                }
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Income'),
                              selected: _selectedType == 'Income',
                              selectedColor: Colors.green[100],
                              labelStyle: TextStyle(
                                color: _selectedType == 'Income' ? Colors.green[800] : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedType = 'Income';
                                    _selectedCategoryId = null; // Reset category
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amount Text Field
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount (Rs.)',
                        prefixIcon: Icon(Icons.monetization_on_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an amount';
                        }
                        final parsed = double.tryParse(value);
                        if (parsed == null || parsed <= 0) {
                          return 'Please enter a valid positive amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Account Dropdown
                    DropdownButtonFormField<int>(
                      initialValue: _selectedAccountId,
                      decoration: const InputDecoration(
                        labelText: 'Select Account',
                        prefixIcon: Icon(Icons.account_balance_rounded),
                        border: OutlineInputBorder(),
                      ),
                      items: accountState.accounts.map((acc) {
                        return DropdownMenuItem<int>(
                          value: acc.id,
                          child: Text('${acc.name} (Bal: Rs. ${acc.balance.toStringAsFixed(2)})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAccountId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select an account';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    DropdownButtonFormField<int>(
                      initialValue: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Select Category',
                        prefixIcon: Icon(Icons.category_rounded),
                        border: OutlineInputBorder(),
                      ),
                      items: filteredCategories.isEmpty
                          ? [
                              const DropdownMenuItem<int>(
                                value: null,
                                child: Text('No categories for this type. Create one first.'),
                              )
                            ]
                          : filteredCategories.map((cat) {
                              return DropdownMenuItem<int>(
                                value: cat.id,
                                child: Text(cat.name),
                              );
                            }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date Picker ListTile
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.calendar_month_rounded),
                        title: const Text('Transaction Date'),
                        subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                        trailing: OutlinedButton(
                          onPressed: () => _selectDate(context),
                          child: const Text('Change'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description / Note Field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description / Note',
                        prefixIcon: Icon(Icons.note_alt_outlined),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 32),

                    // Save / Cancel Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.go('/transactions'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final txAmount = double.parse(_amountController.text.trim());

                                final newTx = Transaction(
                                  id: 0, // Auto-incremented
                                  accountId: _selectedAccountId!,
                                  categoryId: _selectedCategoryId!,
                                  amount: txAmount,
                                  type: _selectedType,
                                  date: _selectedDate,
                                  description: _descriptionController.text.trim(),
                                );

                                // Add the transaction
                                ref.read(transactionProvider.notifier).addTransaction(newTx);

                                // Subtract or add balance from corresponding account
                                final accountToUpdate = accountState.accounts.firstWhere((a) => a.id == newTx.accountId);
                                final updatedBalance = newTx.type.toLowerCase() == 'income'
                                    ? accountToUpdate.balance + txAmount
                                    : accountToUpdate.balance - txAmount;

                                final updatedAccount = Account(
                                  id: accountToUpdate.id,
                                  name: accountToUpdate.name,
                                  balance: updatedBalance,
                                  type: accountToUpdate.type,
                                );
                                ref.read(accountProvider.notifier).updateAccount(updatedAccount);

                                context.go('/transactions');

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ Transaction Saved Successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Save Transaction'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
