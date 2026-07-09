import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class WatchBudgets {
  final BudgetRepository _repository;

  WatchBudgets(this._repository);

  Stream<List<Budget>> call() {
    return _repository.watchBudgets();
  }
}

final watchBudgetsProvider = Provider<WatchBudgets>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return WatchBudgets(repository);
});
