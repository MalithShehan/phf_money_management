import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class WatchTransactions {
  final TransactionRepository _repository;

  WatchTransactions(this._repository);

  Stream<List<Transaction>> call() {
    return _repository.watchTransactions();
  }
}

final watchTransactionsProvider = Provider<WatchTransactions>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return WatchTransactions(repository);
});
