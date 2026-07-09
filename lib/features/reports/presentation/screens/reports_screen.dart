import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phf_money_management/core/widgets/app_drawer.dart';
import 'package:phf_money_management/features/categories/domain/entities/category.dart';
import 'package:phf_money_management/features/categories/presentation/providers/category_provider.dart';
import 'package:phf_money_management/features/transactions/presentation/providers/transaction_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  Color _hexToColor(String? hexString) {
    if (hexString == null) return const Color(0xFF1976D2);
    final hex = hexString.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionState = ref.watch(transactionProvider);
    final categoryState = ref.watch(categoryProvider);

    final expenses = transactionState.transactions
        .where((t) => t.type.toLowerCase() == 'expense')
        .toList();

    double totalExpenses = 0.0;
    final Map<int, double> categorySums = {};

    for (final exp in expenses) {
      totalExpenses += exp.amount;
      categorySums[exp.categoryId] = (categorySums[exp.categoryId] ?? 0.0) + exp.amount;
    }

    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 2);

    List<PieChartSectionData> getSections() {
      int colorIndex = 0;
      return categorySums.entries.map((entry) {
        final catId = entry.key;
        final amount = entry.value;
        final percentage = totalExpenses > 0 ? (amount / totalExpenses) * 100 : 0.0;

        final category = categoryState.categories.firstWhere(
          (c) => c.id == catId,
          orElse: () => const Category(id: 0, name: 'Other', type: 'Expense'),
        );

        final color = category.color != null ? _hexToColor(category.color) : Colors.primaries[colorIndex++ % Colors.primaries.length];

        return PieChartSectionData(
          color: color,
          value: amount,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Reports'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: expenses.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pie_chart_outline_rounded, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'No Expense Data Available',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Record some expense transactions to see a category-wise breakdown chart here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black38),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expense Breakdown by Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Pie Chart Container
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: getSections(),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Total Expenses: ${currencyFormat.format(totalExpenses)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),

                  // Detail Category Breakdowns List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categorySums.length,
                    itemBuilder: (context, index) {
                      final entry = categorySums.entries.toList()[index];
                      final catId = entry.key;
                      final amount = entry.value;
                      final percentage = totalExpenses > 0 ? (amount / totalExpenses) * 100 : 0.0;

                      final category = categoryState.categories.firstWhere(
                        (c) => c.id == catId,
                        orElse: () => const Category(id: 0, name: 'Other', type: 'Expense'),
                      );

                      final color = category.color != null ? _hexToColor(category.color) : Colors.blue;

                      return Card(
                        child: ListTile(
                          leading: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${percentage.toStringAsFixed(1)}% of total expenses'),
                          trailing: Text(
                            currencyFormat.format(amount),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
