import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class CreateBudget {
  final BudgetRepository _repository;

  CreateBudget(this._repository);

  Future<void> call(Budget budget) async {
    await _repository.insertBudget(budget);
  }
}

final createBudgetProvider = Provider<CreateBudget>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return CreateBudget(repository);
});
