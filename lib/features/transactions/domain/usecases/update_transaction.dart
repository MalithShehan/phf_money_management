import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransaction {
  final TransactionRepository _repository;

  UpdateTransaction(this._repository);

  Future<void> call(Transaction transaction) async {
    await _repository.updateTransaction(transaction);
  }
}

final updateTransactionProvider = Provider<UpdateTransaction>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return UpdateTransaction(repository);
});
