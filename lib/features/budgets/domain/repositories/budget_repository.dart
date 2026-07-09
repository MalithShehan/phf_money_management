import '../entities/budget.dart';

abstract class BudgetRepository {
  Future<List<Budget>> getBudgets();
  Future<Budget?> getBudgetById(int id);
  Future<void> insertBudget(Budget budget);
  Future<void> updateBudget(Budget budget);
  Future<void> deleteBudget(int id);
  Stream<List<Budget>> watchBudgets();
}
