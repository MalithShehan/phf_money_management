import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phf_money_management/core/widgets/app_drawer.dart';
import 'package:phf_money_management/features/accounts/domain/entities/account.dart';
import 'package:phf_money_management/features/accounts/presentation/providers/account_provider.dart';
import 'package:phf_money_management/features/categories/domain/entities/category.dart';
import 'package:phf_money_management/features/categories/presentation/providers/category_provider.dart';
import 'package:phf_money_management/features/transactions/presentation/providers/transaction_provider.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionState = ref.watch(transactionProvider);
    final accountState = ref.watch(accountProvider);
    final categoryState = ref.watch(categoryProvider);

    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 2);

    void showDeleteConfirmation(BuildContext ctx, int id, String description) {
      showDialog(
        context: ctx,
        builder: (dialogCtx) {
          return AlertDialog(
            title: const Text('Delete Transaction'),
            content: Text('Are you sure you want to delete the transaction "$description"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('Cancel'),
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
                      ref.read(accountProvider.notifier).addAccount(updatedAccount);
                    }
                  } catch (_) {}

                  ref.read(transactionProvider.notifier).removeTransaction(id);
                  Navigator.of(dialogCtx).pop();
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Transaction deleted and balance updated successfully.')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800], foregroundColor: Colors.white),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );
    }

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
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: transactionState.transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactionState.transactions[index];
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
                                    color: catColor.withOpacity(0.1),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-transaction'),
        backgroundColor: const Color(0xFF1976D2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
