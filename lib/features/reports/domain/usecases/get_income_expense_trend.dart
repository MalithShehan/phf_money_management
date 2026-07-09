import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transactions/domain/entities/transaction.dart';

class MonthlyTrendPoint {
  final DateTime month;
  final double income;
  final double expense;

  MonthlyTrendPoint({
    required this.month,
    required this.income,
    required this.expense,
  });
}

class GetIncomeExpenseTrend {
  List<MonthlyTrendPoint> call(List<Transaction> transactions) {
    final Map<String, double> incomeMap = {};
    final Map<String, double> expenseMap = {};
    final Map<String, DateTime> dateMap = {};

    for (final tx in transactions) {
      final key = '${tx.date.year}-${tx.date.month}';
      dateMap[key] = DateTime(tx.date.year, tx.date.month);
      if (tx.type.toLowerCase() == 'income') {
        incomeMap[key] = (incomeMap[key] ?? 0.0) + tx.amount;
      } else if (tx.type.toLowerCase() == 'expense') {
        expenseMap[key] = (expenseMap[key] ?? 0.0) + tx.amount;
      }
    }

    final sortedKeys = dateMap.keys.toList()..sort();
    return sortedKeys.map((key) {
      return MonthlyTrendPoint(
        month: dateMap[key]!,
        income: incomeMap[key] ?? 0.0,
        expense: expenseMap[key] ?? 0.0,
      );
    }).toList();
  }
}

final getIncomeExpenseTrendProvider = Provider<GetIncomeExpenseTrend>((ref) {
  return GetIncomeExpenseTrend();
});
