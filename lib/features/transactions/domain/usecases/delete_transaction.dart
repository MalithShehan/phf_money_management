import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../repositories/transaction_repository.dart';

class DeleteTransaction {
  final TransactionRepository _repository;

  DeleteTransaction(this._repository);

  Future<void> call(int id) async {
    await _repository.deleteTransaction(id);
  }
}

final deleteTransactionProvider = Provider<DeleteTransaction>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return DeleteTransaction(repository);
});
