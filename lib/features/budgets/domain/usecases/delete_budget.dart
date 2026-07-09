import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../repositories/budget_repository.dart';

class DeleteBudget {
  final BudgetRepository _repository;

  DeleteBudget(this._repository);

  Future<void> call(int id) async {
    await _repository.deleteBudget(id);
  }
}

final deleteBudgetProvider = Provider<DeleteBudget>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return DeleteBudget(repository);
});
