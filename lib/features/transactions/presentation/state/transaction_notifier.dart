import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/create_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/update_transaction.dart';
import '../../domain/usecases/watch_transactions.dart';
import 'transaction_state.dart';

class TransactionNotifier extends Notifier<TransactionState> {
  late final CreateTransaction _createTransaction;
  late final UpdateTransaction _updateTransaction;
  late final DeleteTransaction _deleteTransaction;
  late final WatchTransactions _watchTransactions;
  StreamSubscription<List<Transaction>>? _subscription;

  @override
  TransactionState build() {
    _createTransaction = ref.watch(createTransactionProvider);
    _updateTransaction = ref.watch(updateTransactionProvider);
    _deleteTransaction = ref.watch(deleteTransactionProvider);
    _watchTransactions = ref.watch(watchTransactionsProvider);

    _startWatching();

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return const TransactionState();
  }

  void _startWatching() {
    state = state.copyWith(isLoading: true);
    _subscription?.cancel();
    _subscription = _watchTransactions().listen(
      (transactions) {
        state = state.copyWith(
          transactions: transactions,
          isLoading: false,
        );
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        );
      },
    );
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _createTransaction(transaction);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> editTransaction(Transaction transaction) async {
    try {
      await _updateTransaction(transaction);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> removeTransaction(int id) async {
    try {
      await _deleteTransaction(id);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}
