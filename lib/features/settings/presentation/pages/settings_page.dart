import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phf_money_management/core/widgets/app_drawer.dart';
import 'package:phf_money_management/features/accounts/domain/entities/account.dart';
import 'package:phf_money_management/features/accounts/presentation/providers/account_provider.dart';
import 'package:phf_money_management/features/categories/domain/entities/category.dart';
import 'package:phf_money_management/features/categories/presentation/providers/category_provider.dart';
import 'package:phf_money_management/features/transactions/domain/entities/transaction.dart';
import 'package:phf_money_management/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:phf_money_management/features/settings/presentation/providers/currency_provider.dart';
import 'package:phf_money_management/data/local/database_provider.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _generateSampleData(BuildContext context, WidgetRef ref) async {
    // 1. Reset database tables first to make sure we start fresh
    await ref.read(databaseProvider).resetDatabase();
    
    // Invalidate state to let notifier re-initialize
    ref.invalidate(categoryProvider);
    ref.invalidate(accountProvider);
    ref.invalidate(transactionProvider);

    // Wait briefly for the state to re-evaluate and seed defaults
    await Future.delayed(const Duration(milliseconds: 500));

    // Get current categories (seeded automatically on database empty check)
    var currentCategories = ref.read(categoryProvider).categories;

    // Helper map to resolve category name to ID
    final Map<String, int> categoryIds = {};
    for (final cat in currentCategories) {
      categoryIds[cat.name.toLowerCase()] = cat.id;
    }

    // Check/insert custom categories
    final customCategories = [
      const Category(id: 0, name: 'Freelance', type: 'Income', icon: 'salary', color: '#1565C0'),
      const Category(id: 0, name: 'Transportation', type: 'Expense', icon: 'car', color: '#1565C0'),
      const Category(id: 0, name: 'Rent & Bills', type: 'Expense', icon: 'home', color: '#C62828'),
      const Category(id: 0, name: 'Food & Dining', type: 'Expense', icon: 'restaurant', color: '#EF6C00'),
    ];

    for (final cat in customCategories) {
      final key = cat.name.toLowerCase();
      // If we don't have this category or a close match, add it
      if (!categoryIds.containsKey(key)) {
        // Special case: check if we have a default category matching
        String? matchName;
        if (key == 'transportation') matchName = 'transport';
        if (key == 'food & dining') matchName = 'food';
        if (key == 'rent & bills') matchName = 'home/rent';

        if (matchName != null && categoryIds.containsKey(matchName)) {
          categoryIds[key] = categoryIds[matchName]!;
        } else {
          await ref.read(categoryProvider.notifier).addCategory(cat);
        }
      }
    }

    // Re-retrieve categories to get the added custom categories
    final updatedCategories = ref.read(categoryProvider).categories;
    for (final cat in updatedCategories) {
      categoryIds[cat.name.toLowerCase()] = cat.id;
    }

    // 2. Generate Accounts with id: 0 to autoincrement
    final accountsToCreate = [
      const Account(id: 0, name: 'Commercial Bank', balance: 145000.0, type: 'Bank'),
      const Account(id: 0, name: 'Cash Account', balance: 25000.0, type: 'Cash'),
      const Account(id: 0, name: 'Amex Credit Card', balance: -12000.0, type: 'Card'),
    ];

    final Map<String, int> accountIds = {};
    for (final acc in accountsToCreate) {
      await ref.read(accountProvider.notifier).addAccount(acc);
    }

    // Retrieve accounts to get their assigned IDs
    final createdAccounts = ref.read(accountProvider).accounts;
    for (final acc in createdAccounts) {
      accountIds[acc.name.toLowerCase()] = acc.id;
    }

    // Helper functions to safely get IDs
    int getCatId(String name) => categoryIds[name.toLowerCase()] ?? (categoryIds.values.isNotEmpty ? categoryIds.values.first : 0);
    int getAccId(String name) => accountIds[name.toLowerCase()] ?? (accountIds.values.isNotEmpty ? accountIds.values.first : 0);

    // 3. Generate Transactions
    final transactions = [
      Transaction(
        id: 0,
        accountId: getAccId('Commercial Bank'),
        categoryId: getCatId('Salary'),
        amount: 125000.0,
        type: 'Income',
        date: DateTime.now().subtract(const Duration(days: 5)),
        description: 'Monthly Salary Credit',
      ),
      Transaction(
        id: 0,
        accountId: getAccId('Commercial Bank'),
        categoryId: getCatId('Rent & Bills'),
        amount: 35000.0,
        type: 'Expense',
        date: DateTime.now().subtract(const Duration(days: 4)),
        description: 'Apartment Monthly Rent',
      ),
      Transaction(
        id: 0,
        accountId: getAccId('Cash Account'),
        categoryId: getCatId('Food & Dining'),
        amount: 2500.0,
        type: 'Expense',
        date: DateTime.now().subtract(const Duration(days: 3)),
        description: 'Dinner at restaurant',
      ),
      Transaction(
        id: 0,
        accountId: getAccId('Cash Account'),
        categoryId: getCatId('Transportation'),
        amount: 450.0,
        type: 'Expense',
        date: DateTime.now().subtract(const Duration(days: 2)),
        description: 'Tuk tuk transport',
      ),
      Transaction(
        id: 0,
        accountId: getAccId('Amex Credit Card'),
        categoryId: getCatId('Shopping'),
        amount: 8500.0,
        type: 'Expense',
        date: DateTime.now().subtract(const Duration(days: 1)),
        description: 'Buying clothes',
      ),
      Transaction(
        id: 0,
        accountId: getAccId('Cash Account'),
        categoryId: getCatId('Salary'),
        amount: 25000.0,
        type: 'Income',
        date: DateTime.now(),
        description: 'Part-time payment',
      ),
    ];

    for (final tx in transactions) {
      await ref.read(transactionProvider.notifier).addTransaction(tx);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sample financial data populated successfully!')),
      );
    }
  }

  Future<void> _exportToJSON(BuildContext context, WidgetRef ref) async {
    final accounts = ref.read(accountProvider).accounts;
    final categories = ref.read(categoryProvider).categories;
    final transactions = ref.read(transactionProvider).transactions;

    final data = {
      'accounts': accounts.map((a) => {'id': a.id, 'name': a.name, 'balance': a.balance, 'type': a.type}).toList(),
      'categories': categories.map((c) => {'id': c.id, 'name': c.name, 'type': c.type, 'icon': c.icon, 'color': c.color}).toList(),
      'transactions': transactions.map((t) => {
        'id': t.id,
        'accountId': t.accountId,
        'categoryId': t.categoryId,
        'amount': t.amount,
        'type': t.type,
        'date': t.date.toIso8601String(),
        'description': t.description,
      }).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    await Clipboard.setData(ClipboardData(text: jsonString));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📋 JSON data copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _exportToCSV(BuildContext context, WidgetRef ref) async {
    final transactions = ref.read(transactionProvider).transactions;
    final accounts = ref.read(accountProvider).accounts;
    final categories = ref.read(categoryProvider).categories;

    final buffer = StringBuffer();
    buffer.writeln('ID,Date,Type,Amount,Category,Account,Description');

    for (final tx in transactions) {
      final acc = accounts.firstWhere((a) => a.id == tx.accountId, orElse: () => const Account(id: 0, name: 'Unknown', balance: 0, type: ''));
      final cat = categories.firstWhere((c) => c.id == tx.categoryId, orElse: () => const Category(id: 0, name: 'Unknown', type: ''));
      
      final dateStr = tx.date.toIso8601String().split('T')[0];
      final description = (tx.description ?? '').replaceAll('"', '""');

      buffer.writeln('${tx.id},$dateStr,${tx.type},${tx.amount},"${cat.name}","${acc.name}","$description"');
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📋 CSV data copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Reset Local Data?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to reset all local data? '
          'This action will permanently delete all accounts, transactions, categories, and budgets.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(databaseProvider).resetDatabase();
                
                // Invalidate providers to force reload of UI
                ref.invalidate(accountProvider);
                ref.invalidate(categoryProvider);
                ref.invalidate(transactionProvider);

                if (context.mounted) {
                  Navigator.of(dialogCtx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ All local database tables have been reset.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(dialogCtx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Error resetting database: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCurrency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'General Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(height: 8),
          
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.monetization_on_outlined, color: Color(0xFF1976D2)),
                      SizedBox(width: 12),
                      Text(
                        'Preferred Currency',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  DropdownButton<String>(
                    value: currentCurrency,
                    items: const [
                      DropdownMenuItem(value: 'Rs.', child: Text('Rs. (LKR)')),
                      DropdownMenuItem(value: '\$', child: Text('\$ (USD)')),
                      DropdownMenuItem(value: '€', child: Text('€ (EUR)')),
                      DropdownMenuItem(value: '£', child: Text('£ (GBP)')),
                      DropdownMenuItem(value: '¥', child: Text('¥ (JPY)')),
                    ],
                    onChanged: (newValue) {
                      if (newValue != null) {
                        ref.read(currencyProvider.notifier).setCurrency(newValue);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Security',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(height: 8),

          Card(
            elevation: 2,
            child: SwitchListTile(
              secondary: const Icon(Icons.lock_outline_rounded, color: Color(0xFF1976D2)),
              title: const Text('App Lock (PIN/Biometric)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Requires local authentication on app startup (Placeholder).'),
              value: false,
              onChanged: (bool value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('App Lock placeholder toggled! Full biometric integration is planned for Version 2.0.'),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Database & Diagnostics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(height: 8),
          
          // Database info card
          Card(
            child: ListTile(
              leading: const Icon(Icons.storage_rounded, color: Color(0xFF1976D2)),
              title: const Text('SQLite Local Database'),
              subtitle: const Text('Engine: Drift (schema version 1)'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green[100]!),
                ),
                child: Text(
                  'ACTIVE',
                  style: TextStyle(color: Colors.green[800], fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Reset Database Action Card
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
              title: const Text(
                'Reset Local Data',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              subtitle: const Text('Deletes all local accounts, transactions, categories, and budgets.'),
              onTap: () => _showResetConfirmation(context, ref),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Data Portability',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(height: 8),

          Card(
            elevation: 2,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.code_rounded, color: Color(0xFF1976D2)),
                  title: const Text('Export as JSON', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Copies all financial tables formatted as a JSON string.'),
                  trailing: const Icon(Icons.copy_all_rounded, size: 20),
                  onTap: () => _exportToJSON(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.table_chart_rounded, color: Color(0xFF1976D2)),
                  title: const Text('Export Transactions as CSV', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Copies transaction logs formatted as a comma-separated values table.'),
                  trailing: const Icon(Icons.copy_all_rounded, size: 20),
                  onTap: () => _exportToCSV(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'About PHF ITCore',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(height: 8),

          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.volunteer_activism_rounded, color: Color(0xFF1976D2)),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Pure Heart Family (PHF)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Developed by PHF ITCore as an offline-first personal money management solution. '
                    'Built under Clean Architecture patterns with local SQLite database powered by Drift.',
                    style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Reviewer Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(height: 8),

          // Generate sample data card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Populate Sample Data',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Instantly fill the database with mock accounts, categories, and recent transactions to preview the app components and charts.',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _generateSampleData(context, ref),
                      icon: const Icon(Icons.bolt_rounded),
                      label: const Text('Generate Sample Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Version info
          Center(
            child: Text(
              'PHF Money Management • Clean Architecture v1.0.0',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
