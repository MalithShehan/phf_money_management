import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class UpdateBudget {
  final BudgetRepository _repository;

  UpdateBudget(this._repository);

  Future<void> call(Budget budget) async {
    await _repository.updateBudget(budget);
  }
}

final updateBudgetProvider = Provider<UpdateBudget>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return UpdateBudget(repository);
});
