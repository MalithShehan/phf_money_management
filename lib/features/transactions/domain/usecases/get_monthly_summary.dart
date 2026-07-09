import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../repositories/transaction_repository.dart';

class MonthlySummary {
  final double totalIncome;
  final double totalExpense;
  final double netBalance;

  const MonthlySummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
  });
}

class GetMonthlySummary {
  final TransactionRepository _repository;

  GetMonthlySummary(this._repository);

  Future<MonthlySummary> call(int year, int month) async {
    final transactions = await _repository.getTransactions();

    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (final tx in transactions) {
      if (tx.date.year == year && tx.date.month == month) {
        if (tx.type.toLowerCase() == 'income') {
          totalIncome += tx.amount;
        } else if (tx.type.toLowerCase() == 'expense') {
          totalExpense += tx.amount;
        }
      }
    }

    return MonthlySummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netBalance: totalIncome - totalExpense,
    );
  }
}

final getMonthlySummaryProvider = Provider<GetMonthlySummary>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return GetMonthlySummary(repository);
});
