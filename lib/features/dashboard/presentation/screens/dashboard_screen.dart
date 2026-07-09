import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phf_money_management/core/widgets/app_drawer.dart';
import 'package:phf_money_management/features/accounts/domain/entities/account.dart';
import 'package:phf_money_management/features/accounts/presentation/providers/account_provider.dart';
import 'package:phf_money_management/features/budgets/presentation/providers/budget_provider.dart';
import 'package:phf_money_management/features/categories/domain/entities/category.dart';
import 'package:phf_money_management/features/categories/presentation/providers/category_provider.dart';
import 'package:phf_money_management/features/transactions/domain/entities/transaction.dart';
import 'package:phf_money_management/features/transactions/presentation/providers/transaction_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountState = ref.watch(accountProvider);
    final transactionState = ref.watch(transactionProvider);
    final categoryState = ref.watch(categoryProvider);
    final budgetState = ref.watch(budgetProvider);

    // Calculate total balance
    double totalBalance = 0.0;
    for (final acc in accountState.accounts) {
      totalBalance += acc.balance;
    }

    // Calculate monthly income & expense totals from this month's transactions
    final now = DateTime.now();
    double monthlyIncome = 0.0;
    double monthlyExpense = 0.0;

    for (final tx in transactionState.transactions) {
      if (tx.date.year == now.year && tx.date.month == now.month) {
        if (tx.type.toLowerCase() == 'income') {
          monthlyIncome += tx.amount;
        } else if (tx.type.toLowerCase() == 'expense') {
          monthlyExpense += tx.amount;
        }
      }
    }

    // Net balance (Income - Expense)
    final netCashFlow = monthlyIncome - monthlyExpense;
    final totalIncomeExpense = monthlyIncome + monthlyExpense;

    // Get last 5 transactions sorted descending by date
    final sortedTransactions = List<Transaction>.from(transactionState.transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    final recentTransactions = sortedTransactions.length > 5
        ? sortedTransactions.sublist(0, 5)
        : sortedTransactions;

    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 2);

    // Check budget warnings
    final budgetWarnings = <String>[];
    for (final budget in budgetState.budgets) {
      final category = categoryState.categories.firstWhere(
        (c) => c.id == budget.categoryId,
        orElse: () => const Category(id: 0, name: 'Unknown Category', type: 'Expense'),
      );

      double spentAmount = 0.0;
      for (final tx in transactionState.transactions) {
        if (tx.categoryId == budget.categoryId &&
            tx.date.year == now.year &&
            tx.date.month == now.month &&
            tx.type.toLowerCase() == 'expense') {
          spentAmount += tx.amount;
        }
      }

      if (spentAmount > budget.amountLimit) {
        budgetWarnings.add(
          '${category.name} limit exceeded: spent ${currencyFormat.format(spentAmount)} of ${currencyFormat.format(budget.amountLimit)}',
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('PHF Money Dashboard'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: (accountState.isLoading ||
              transactionState.isLoading ||
              categoryState.isLoading ||
              budgetState.isLoading)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // 1. Total Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D47A1).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL BALANCE',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white.withOpacity(0.7),
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(totalBalance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${accountState.accounts.length} Active Accounts',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        InkWell(
                          onTap: () => context.go('/accounts'),
                          child: const Text(
                            'Manage Accounts →',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Budget Alert Container (if any budget is exceeded)
              if (budgetWarnings.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[100]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.red[800]),
                          const SizedBox(width: 8),
                          Text(
                            'BUDGET EXCEEDED WARNINGS',
                            style: TextStyle(
                              color: Colors.red[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...budgetWarnings.map((warning) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_right_rounded, color: Colors.red, size: 18),
                                Expanded(
                                  child: Text(
                                    warning,
                                    style: TextStyle(color: Colors.red[955], fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 3. Income & Expense Card Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E7D32).withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Income',
                                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currencyFormat.format(monthlyIncome),
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFC62828), Color(0xFFEF5350)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC62828).withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Expenses',
                                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 20),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currencyFormat.format(monthlyExpense),
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Net Income Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: netCashFlow >= 0
                        ? [const Color(0xFF00796B), const Color(0xFF26A69A)]
                        : [const Color(0xFFE65100), const Color(0xFFFF9800)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (netCashFlow >= 0 ? const Color(0xFF00796B) : const Color(0xFFE65100)).withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          netCashFlow >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Net Savings',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      currencyFormat.format(netCashFlow),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. Chart (Visual comparison)
              if (monthlyIncome > 0 || monthlyExpense > 0) ...[
                const Text(
                  'Cash Flow Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: SizedBox(
                            height: 120,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 25,
                                sections: [
                                  PieChartSectionData(
                                    color: const Color(0xFF2E7D32),
                                    value: monthlyIncome,
                                    title: '${(totalIncomeExpense > 0 ? (monthlyIncome / totalIncomeExpense) * 100 : 0.0).toStringAsFixed(0)}%',
                                    radius: 35,
                                    titleStyle: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    color: const Color(0xFFC62828),
                                    value: monthlyExpense,
                                    title: '${(totalIncomeExpense > 0 ? (monthlyExpense / totalIncomeExpense) * 100 : 0.0).toStringAsFixed(0)}%',
                                    radius: 35,
                                    titleStyle: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegendItem(
                                color: const Color(0xFF2E7D32),
                                label: 'Income',
                                amount: currencyFormat.format(monthlyIncome),
                                percentage: '${(totalIncomeExpense > 0 ? (monthlyIncome / totalIncomeExpense) * 100 : 0.0).toStringAsFixed(1)}%',
                              ),
                              const SizedBox(height: 12),
                              _buildLegendItem(
                                color: const Color(0xFFC62828),
                                label: 'Expenses',
                                amount: currencyFormat.format(monthlyExpense),
                                percentage: '${(totalIncomeExpense > 0 ? (monthlyExpense / totalIncomeExpense) * 100 : 0.0).toStringAsFixed(1)}%',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 6. Recent Transactions List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/transactions'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (transactionState.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (transactionState.transactions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_rounded, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      const Text(
                        'No transactions recorded yet.',
                        style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tip: Go to Settings → Generate Sample Data or tap "+" to record your first transaction.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black38, fontSize: 12),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTransactions.length,
                  itemBuilder: (context, index) {
                    final tx = recentTransactions[index];
                    final isIncome = tx.type.toLowerCase() == 'income';

                    // Lookup account name & category name for friendly listing
                    final accountName = accountState.accounts
                        .firstWhere((a) => a.id == tx.accountId,
                            orElse: () => const Account(id: 0, name: 'Unknown Account', balance: 0, type: ''))
                        .name;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
                          child: Icon(
                            isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                            color: isIncome ? Colors.green[800] : Colors.red[800],
                          ),
                        ),
                        title: Text(
                          tx.description != null && tx.description!.isNotEmpty
                              ? tx.description!
                              : (isIncome ? 'Income Source' : 'Expense Detail'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '$accountName • ${DateFormat('yyyy-MM-dd').format(tx.date)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Text(
                          '${isIncome ? '+' : '-'}${currencyFormat.format(tx.amount)}',
                          style: TextStyle(
                            color: isIncome ? Colors.green[800] : Colors.red[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
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

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String amount,
    required String percentage,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    percentage,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                amount,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
