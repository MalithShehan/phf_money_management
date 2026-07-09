import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../entities/budget.dart';

class BudgetProgress {
  final Budget budget;
  final double spentAmount;
  final double remainingAmount;
  final double progress;
  final bool isOverBudget;

  BudgetProgress({
    required this.budget,
    required this.spentAmount,
    required this.remainingAmount,
    required this.progress,
    required this.isOverBudget,
  });
}

class GetBudgetProgress {
  List<BudgetProgress> call({
    required List<Budget> budgets,
    required List<Transaction> transactions,
    required DateTime targetMonth,
  }) {
    final startOfMonth = DateTime(targetMonth.year, targetMonth.month, 1);
    final endOfMonth = DateTime(targetMonth.year, targetMonth.month + 1, 0, 23, 59, 59);

    final monthlyExpenses = transactions.where((tx) {
      return tx.type.toLowerCase() == 'expense' &&
          tx.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
          tx.date.isBefore(endOfMonth.add(const Duration(seconds: 1)));
    }).toList();

    final Map<int, double> categorySpent = {};
    for (final tx in monthlyExpenses) {
      categorySpent[tx.categoryId] = (categorySpent[tx.categoryId] ?? 0.0) + tx.amount;
    }

    final monthlyBudgets = budgets.where((b) {
      return b.startDate.year == targetMonth.year && b.startDate.month == targetMonth.month;
    }).toList();

    return monthlyBudgets.map((budget) {
      final spent = categorySpent[budget.categoryId] ?? 0.0;
      final remaining = budget.amountLimit - spent;
      final progressValue = budget.amountLimit > 0 ? (spent / budget.amountLimit) : 0.0;
      return BudgetProgress(
        budget: budget,
        spentAmount: spent,
        remainingAmount: remaining,
        progress: progressValue,
        isOverBudget: spent > budget.amountLimit,
      );
    }).toList();
  }
}

final getBudgetProgressProvider = Provider<GetBudgetProgress>((ref) {
  return GetBudgetProgress();
});
