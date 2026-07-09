import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phf_money_management/core/widgets/app_drawer.dart';
import 'package:phf_money_management/features/accounts/domain/entities/account.dart';
import 'package:phf_money_management/features/accounts/presentation/providers/account_provider.dart';
import 'package:phf_money_management/features/categories/domain/entities/category.dart';
import 'package:phf_money_management/features/categories/presentation/providers/category_provider.dart';
import 'package:phf_money_management/features/transactions/domain/entities/transaction.dart';
import 'package:phf_money_management/features/transactions/presentation/providers/transaction_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _generateSampleData(BuildContext context, WidgetRef ref) async {
    // 1. Generate Categories
    final categories = [
      const Category(id: 1, name: 'Salary', type: 'Income', icon: 'salary', color: '#2E7D32'),
      const Category(id: 2, name: 'Freelance', type: 'Income', icon: 'salary', color: '#1565C0'),
      const Category(id: 3, name: 'Food & Dining', type: 'Expense', icon: 'restaurant', color: '#EF6C00'),
      const Category(id: 4, name: 'Transportation', type: 'Expense', icon: 'car', color: '#1565C0'),
      const Category(id: 5, name: 'Rent & Bills', type: 'Expense', icon: 'home', color: '#C62828'),
      const Category(id: 6, name: 'Shopping', type: 'Expense', icon: 'shopping', color: '#6A1B9A'),
    ];

    for (final cat in categories) {
      await ref.read(categoryProvider.notifier).addCategory(cat);
    }

    // 2. Generate Accounts
    final accounts = [
      const Account(id: 1, name: 'Commercial Bank', balance: 145000.0, type: 'Bank'),
      const Account(id: 2, name: 'Cash Account', balance: 25000.0, type: 'Cash'),
      const Account(id: 3, name: 'Amex Credit Card', balance: -12000.0, type: 'Card'),
    ];

    for (final acc in accounts) {
      await ref.read(accountProvider.notifier).addAccount(acc);
    }

    // 3. Generate Transactions
    final transactions = [
      Transaction(
        id: 1,
        accountId: 1,
        categoryId: 1,
        amount: 125000.0,
        type: 'Income',
        date: DateTime.now().subtract(const Duration(days: 5)),
        description: 'Monthly Salary Credit',
      ),
      Transaction(
        id: 2,
        accountId: 1,
        categoryId: 5,
        amount: 35000.0,
        type: 'Expense',
        date: DateTime.now().subtract(const Duration(days: 4)),
        description: 'Apartment Monthly Rent',
      ),
      Transaction(
        id: 3,
        accountId: 2,
        categoryId: 3,
        amount: 2500.0,
        type: 'Expense',
        date: DateTime.now().subtract(const Duration(days: 3)),
        description: 'Dinner at restaurant',
      ),
      Transaction(
        id: 4,
        accountId: 2,
        categoryId: 4,
        amount: 450.0,
        type: 'Expense',
        date: DateTime.now().subtract(const Duration(days: 2)),
        description: 'Tuk tuk transport',
      ),
      Transaction(
        id: 5,
        accountId: 3,
        categoryId: 6,
        amount: 8500.0,
        type: 'Expense',
        date: DateTime.now().subtract(const Duration(days: 1)),
        description: 'Buying clothes',
      ),
      Transaction(
        id: 6,
        accountId: 2, // Cash Account
        categoryId: 1, // Salary
        amount: 25000.0,
        type: 'Income',
        date: DateTime.now(), // Today
        description: 'Salary',
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
