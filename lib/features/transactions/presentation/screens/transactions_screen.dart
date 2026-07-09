import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phf_money_management/core/widgets/app_drawer.dart';
import 'package:phf_money_management/features/settings/presentation/providers/currency_provider.dart';
import 'package:phf_money_management/features/accounts/domain/entities/account.dart';
import 'package:phf_money_management/features/accounts/presentation/providers/account_provider.dart';
import 'package:phf_money_management/features/categories/domain/entities/category.dart';
import 'package:phf_money_management/features/categories/presentation/providers/category_provider.dart';
import 'package:phf_money_management/features/transactions/presentation/providers/transaction_provider.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = ref.watch(transactionProvider);
    final accountState = ref.watch(accountProvider);
    final categoryState = ref.watch(categoryProvider);

    final currencySymbol = ref.watch(currencyProvider);
    final currencyFormat = NumberFormat.currency(symbol: '$currencySymbol ', decimalDigits: 2);

    void showDeleteConfirmation(BuildContext ctx, int id, String description) {
      showDialog(
        context: ctx,
        builder: (dialogCtx) {
          return AlertDialog(
            title: const Text(
              'Delete Transaction?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'This action cannot be undone.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  try {
                    final tx = transactionState.transactions.firstWhere((t) => t.id == id);
                    final accountToUpdate = accountState.accounts.firstWhere(
                      (a) => a.id == tx.accountId,
                      orElse: () => const Account(id: 0, name: '', balance: 0, type: ''),
                    );

                    if (accountToUpdate.id > 0) {
                      final updatedBalance = tx.type.toLowerCase() == 'income'
                          ? accountToUpdate.balance - tx.amount
                          : accountToUpdate.balance + tx.amount;

                      final updatedAccount = Account(
                        id: accountToUpdate.id,
                        name: accountToUpdate.name,
                        balance: updatedBalance,
                        type: accountToUpdate.type,
                      );
                      ref.read(accountProvider.notifier).updateAccount(updatedAccount);
                    }
                  } catch (_) {}

                  ref.read(transactionProvider.notifier).removeTransaction(id);
                  Navigator.of(dialogCtx).pop();
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('🗑 Transaction Deleted'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );
    }

    // Filter transaction list based on chip type selection and text search query
    final query = _searchController.text.toLowerCase().trim();
    final filteredTransactions = transactionState.transactions.where((tx) {
      // 1. Filter by Chip Selection (All / Income / Expense)
      if (_selectedFilter != 'All' && tx.type.toLowerCase() != _selectedFilter.toLowerCase()) {
        return false;
      }

      // 2. Filter by search text query
      if (query.isEmpty) return true;

      final matchesDescription = tx.description?.toLowerCase().contains(query) ?? false;
      final matchesType = tx.type.toLowerCase().contains(query);

      final categoryName = categoryState.categories.firstWhere(
        (c) => c.id == tx.categoryId,
        orElse: () => const Category(id: 0, name: 'General', type: 'Expense'),
      ).name.toLowerCase();
      final matchesCategory = categoryName.contains(query);

      final accountName = accountState.accounts.firstWhere(
        (a) => a.id == tx.accountId,
        orElse: () => const Account(id: 0, name: 'Unknown Account', balance: 0, type: ''),
      ).name.toLowerCase();
      final matchesAccount = accountName.contains(query);

      return matchesDescription || matchesType || matchesCategory || matchesAccount;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: transactionState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactionState.transactions.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '📄',
                          style: TextStyle(fontSize: 80),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No Transactions Yet',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Start tracking your income and expenses.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/add-transaction'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Text(
                            '➕',
                            style: TextStyle(fontSize: 16),
                          ),
                          label: const Text(
                            'Add Transaction',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search description, type, category or account...',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                    
                    // Filter Chips Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('All'),
                            selected: _selectedFilter == 'All',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedFilter = 'All';
                                });
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Income'),
                            selected: _selectedFilter == 'Income',
                            selectedColor: Colors.green[100],
                            labelStyle: TextStyle(
                              color: _selectedFilter == 'Income' ? Colors.green[800] : Colors.black87,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedFilter = 'Income';
                                });
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Expense'),
                            selected: _selectedFilter == 'Expense',
                            selectedColor: Colors.red[100],
                            labelStyle: TextStyle(
                              color: _selectedFilter == 'Expense' ? Colors.red[800] : Colors.black87,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedFilter = 'Expense';
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    Expanded(
                      child: filteredTransactions.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      '🔍',
                                      style: TextStyle(fontSize: 64),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No Results Found',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No transactions matched the query "${_searchController.text}".',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.black38),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: filteredTransactions.length,
                              itemBuilder: (context, index) {
                                final tx = filteredTransactions[index];
                                final isIncome = tx.type.toLowerCase() == 'income';

                                // Resolve account name
                                final account = accountState.accounts.firstWhere(
                                  (a) => a.id == tx.accountId,
                                  orElse: () => const Account(id: 0, name: 'Unknown Account', balance: 0, type: ''),
                                );

                                // Resolve category details
                                final category = categoryState.categories.firstWhere(
                                  (c) => c.id == tx.categoryId,
                                  orElse: () => const Category(id: 0, name: 'General', type: 'Expense'),
                                );

                                // Set category colors
                                Color catColor = const Color(0xFF1976D2);
                                if (category.color != null) {
                                  final hex = category.color!.replaceAll('#', '');
                                  catColor = Color(int.parse('FF$hex', radix: 16));
                                }

                                final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(tx.date);

                                return Card(
                                  elevation: 1,
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: isIncome ? Colors.green[50] : Colors.red[50],
                                      child: Icon(
                                        isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                                        color: isIncome ? Colors.green[800] : Colors.red[800],
                                      ),
                                    ),
                                    title: Text(
                                      tx.description != null && tx.description!.isNotEmpty
                                          ? tx.description!
                                          : (isIncome ? 'Income Source' : 'Expense Details'),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: catColor.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                category.name,
                                                style: TextStyle(color: catColor, fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              account.name,
                                              style: const TextStyle(fontSize: 11, color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(fontSize: 10, color: Colors.black38),
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${isIncome ? '+' : '-'}${currencyFormat.format(tx.amount)}',
                                          style: TextStyle(
                                            color: isIncome ? Colors.green[800] : Colors.red[800],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(Icons.edit_outlined, color: Colors.grey[500], size: 20),
                                          onPressed: () => context.go('/edit-transaction/${tx.id}'),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete_outline_rounded, color: Colors.grey[500], size: 20),
                                          onPressed: () => showDeleteConfirmation(
                                            context,
                                            tx.id,
                                            tx.description ?? (isIncome ? 'Income' : 'Expense'),
                                          ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/add-transaction'),
        backgroundColor: const Color(0xFF1976D2),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Transaction',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
