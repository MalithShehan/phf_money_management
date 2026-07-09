import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phf_money_management/features/accounts/domain/entities/account.dart';
import 'package:phf_money_management/features/accounts/presentation/providers/account_provider.dart';
import 'package:phf_money_management/features/categories/presentation/providers/category_provider.dart';
import 'package:phf_money_management/features/transactions/domain/entities/transaction.dart';
import 'package:phf_money_management/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:phf_money_management/features/settings/presentation/providers/currency_provider.dart';

class TransactionFormPage extends ConsumerStatefulWidget {
  final int? editTransactionId;
  const TransactionFormPage({super.key, this.editTransactionId});

  @override
  ConsumerState<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends ConsumerState<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  int? _selectedAccountId;
  int? _selectedCategoryId;
  String _selectedType = 'Expense';
  DateTime _selectedDate = DateTime.now();

  Transaction? _originalTransaction;

  @override
  void initState() {
    super.initState();
    if (widget.editTransactionId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final txs = ref.read(transactionProvider).transactions;
        try {
          final tx = txs.firstWhere((t) => t.id == widget.editTransactionId);
          setState(() {
            _originalTransaction = tx;
            _amountController.text = tx.amount.toString();
            _descriptionController.text = tx.description ?? '';
            _selectedAccountId = tx.accountId;
            _selectedCategoryId = tx.categoryId;
            _selectedType = tx.type;
            _selectedDate = tx.date;
          });
        } catch (e) {
          // Transaction not found
        }
      });
    }
  }

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
    final currencySymbol = ref.watch(currencyProvider);

    // Filter categories by selected type (Income/Expense) to keep UI intuitive
    final filteredCategories = categoryState.categories
        .where((c) => c.type.toLowerCase() == _selectedType.toLowerCase())
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editTransactionId != null ? 'Edit Transaction' : 'Add Transaction'),
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
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = MediaQuery.of(context).size.width >= 750;

                      final formWidget = Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
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
                              decoration: InputDecoration(
                                labelText: 'Amount ($currencySymbol)',
                                prefixIcon: const Icon(Icons.monetization_on_outlined),
                                border: const OutlineInputBorder(),
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
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Select Account',
                                prefixIcon: Icon(Icons.account_balance_rounded),
                                border: OutlineInputBorder(),
                              ),
                              items: accountState.accounts.map((acc) {
                                return DropdownMenuItem<int>(
                                  value: acc.id,
                                  child: Text(
                                    '${acc.name} (Bal: $currencySymbol ${acc.balance.toStringAsFixed(2)})',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
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
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Select Category',
                                prefixIcon: Icon(Icons.category_rounded),
                                border: OutlineInputBorder(),
                              ),
                              items: filteredCategories.isEmpty
                                  ? [
                                      const DropdownMenuItem<int>(
                                        value: null,
                                        child: Text(
                                          'No categories for this type. Create one first.',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      )
                                    ]
                                  : filteredCategories.map((cat) {
                                      return DropdownMenuItem<int>(
                                        value: cat.id,
                                        child: Text(
                                          cat.name,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
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
                                        final isEditing = widget.editTransactionId != null && _originalTransaction != null;

                                        if (isEditing) {
                                          final origTx = _originalTransaction!;
                                          final origAccId = origTx.accountId;
                                          final origAmount = origTx.amount;
                                          final origType = origTx.type;

                                          final origAccount = accountState.accounts.firstWhere(
                                            (a) => a.id == origAccId,
                                            orElse: () => const Account(id: 0, name: '', balance: 0, type: ''),
                                          );

                                          final selectedAccount = accountState.accounts.firstWhere((a) => a.id == _selectedAccountId);

                                          if (origAccId == _selectedAccountId) {
                                            // Same account
                                            final intermediateBalance = origType.toLowerCase() == 'income'
                                                ? origAccount.balance - origAmount
                                                : origAccount.balance + origAmount;
                                            final finalBalance = _selectedType.toLowerCase() == 'income'
                                                ? intermediateBalance + txAmount
                                                : intermediateBalance - txAmount;

                                            ref.read(accountProvider.notifier).updateAccount(
                                              Account(
                                                id: selectedAccount.id,
                                                name: selectedAccount.name,
                                                balance: finalBalance,
                                                type: selectedAccount.type,
                                              ),
                                            );
                                          } else {
                                            // Different accounts
                                            if (origAccount.id > 0) {
                                              final revertedBalance = origType.toLowerCase() == 'income'
                                                  ? origAccount.balance - origAmount
                                                  : origAccount.balance + origAmount;
                                              ref.read(accountProvider.notifier).updateAccount(
                                                Account(
                                                  id: origAccount.id,
                                                  name: origAccount.name,
                                                  balance: revertedBalance,
                                                  type: origAccount.type,
                                                ),
                                              );
                                            }

                                            final finalBalance = _selectedType.toLowerCase() == 'income'
                                                ? selectedAccount.balance + txAmount
                                                : selectedAccount.balance - txAmount;
                                            ref.read(accountProvider.notifier).updateAccount(
                                              Account(
                                                id: selectedAccount.id,
                                                name: selectedAccount.name,
                                                balance: finalBalance,
                                                type: selectedAccount.type,
                                              ),
                                            );
                                          }

                                          final updatedTx = Transaction(
                                            id: origTx.id,
                                            accountId: _selectedAccountId!,
                                            categoryId: _selectedCategoryId!,
                                            amount: txAmount,
                                            type: _selectedType,
                                            date: _selectedDate,
                                            description: _descriptionController.text.trim(),
                                          );
                                          ref.read(transactionProvider.notifier).editTransaction(updatedTx);
                                        } else {
                                          // Create new transaction
                                          final newTx = Transaction(
                                            id: 0,
                                            accountId: _selectedAccountId!,
                                            categoryId: _selectedCategoryId!,
                                            amount: txAmount,
                                            type: _selectedType,
                                            date: _selectedDate,
                                            description: _descriptionController.text.trim(),
                                          );

                                          ref.read(transactionProvider.notifier).addTransaction(newTx);

                                          final accountToUpdate = accountState.accounts.firstWhere((a) => a.id == newTx.accountId);
                                          final updatedBalance = newTx.type.toLowerCase() == 'income'
                                              ? accountToUpdate.balance + txAmount
                                              : accountToUpdate.balance - txAmount;

                                          ref.read(accountProvider.notifier).updateAccount(
                                            Account(
                                              id: accountToUpdate.id,
                                              name: accountToUpdate.name,
                                              balance: updatedBalance,
                                              type: accountToUpdate.type,
                                            ),
                                          );
                                        }

                                        context.go('/transactions');

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isEditing 
                                                  ? '✅ Transaction Updated Successfully' 
                                                  : '✅ Transaction Saved Successfully'
                                            ),
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
                                    child: Text(widget.editTransactionId != null ? 'Update Transaction' : 'Save Transaction'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );

                      if (isWide) {
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: formWidget,
                          ),
                        );
                      } else {
                        return formWidget;
                      }
                    },
                  ),
                ),
              ),
            ),
    );
  }
}
