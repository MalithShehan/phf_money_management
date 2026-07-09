import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transactions/domain/entities/transaction.dart';

class GetCategoryExpenseBreakdown {
  Map<int, double> call(List<Transaction> transactions) {
    final Map<int, double> categorySums = {};
    for (final tx in transactions) {
      if (tx.type.toLowerCase() == 'expense') {
        categorySums[tx.categoryId] = (categorySums[tx.categoryId] ?? 0.0) + tx.amount;
      }
    }
    return categorySums;
  }
}

final getCategoryExpenseBreakdownProvider = Provider<GetCategoryExpenseBreakdown>((ref) {
  return GetCategoryExpenseBreakdown();
});
