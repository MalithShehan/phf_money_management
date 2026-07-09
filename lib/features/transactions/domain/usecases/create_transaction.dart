import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class CreateTransaction {
  final TransactionRepository _repository;

  CreateTransaction(this._repository);

  Future<void> call(Transaction transaction) async {
    await _repository.insertTransaction(transaction);
  }
}

final createTransactionProvider = Provider<CreateTransaction>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return CreateTransaction(repository);
});
